// Short-lived user-space test of our own iAP2 interface. No role switch or data IO.
#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <mach/mach_error.h>
#include <cstring>

static NSString *const controllerPath = @"IOService:/AppleARMPE/arm-io@10F00000/AppleSoCIO/usb-drd1@AA280000/AppleT8142USBXDCI@1";
static NSDictionary *properties(io_registry_entry_t entry) {
    CFMutableDictionaryRef value = nullptr;
    if (IORegistryEntryCreateCFProperties(entry, &value, kCFAllocatorDefault, 0)) return @{};
    return CFBridgingRelease(value);
}
static NSString *path(io_registry_entry_t entry) {
    io_string_t value;
    return IORegistryEntryGetPath(entry, kIOServicePlane, value) ? @"" : @(value);
}
static NSDictionary *result(IOReturn code) {
    return @{@"hex": [NSString stringWithFormat:@"0x%08x", code],
             @"message": @(mach_error_string(code)), @"success": @(code == kIOReturnSuccess)};
}
static bool disconnected(io_registry_entry_t controller) {
    NSDictionary *state = properties(controller)[@"CurrentState"];
    return [state isKindOfClass:[NSDictionary class]] && [state[@"OnBus"] isEqual:@NO] &&
           [state[@"DeviceState"] isEqual:@"Disconnected"];
}
int main(int argc, const char **argv) {
    @autoreleasepool {
        BOOL configure = argc == 2 && !strcmp(argv[1], "--configure");
        BOOL open = configure || (argc == 2 && !strcmp(argv[1], "--open"));
        if (argc != 1 && !open) {
            fprintf(stderr, "usage: mac-usb-interface [--open | --configure]\n"); return 2;
        }
        NSMutableDictionary *report = [@{@"role_switch_sent": @NO, @"data_transfer_attempted": @NO,
            @"configure_requested": @(configure)} mutableCopy];
        io_service_t controller = IORegistryEntryFromPath(kIOMainPortDefault, controllerPath.UTF8String);
        io_service_t selected = 0;
        io_connect_t connection = 0;
        bool opened = false;
        unsigned matches = 0;
        IOReturn operation = kIOReturnSuccess;
        io_iterator_t iter = 0;
        IOReturn kr = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOUSBDeviceInterface"), &iter);
        NSMutableArray *interfaces = [NSMutableArray array];
        if (!kr) {
            io_service_t entry;
            while ((entry = IOIteratorNext(iter))) {
                NSDictionary *p = properties(entry);
                if ([path(entry) hasPrefix:[controllerPath stringByAppendingString:@"/"]]) {
                    [interfaces addObject:@{@"path": path(entry), @"function": p[@"USBDeviceFunction"] ?: @"",
                                            @"properties": p}];
                    if ([p[@"USBDeviceFunction"] isEqual:@"SmartBoxIAP2"]) {
                        matches++;
                        if (!selected) { selected = entry; IOObjectRetain(selected); }
                    }
                }
                IOObjectRelease(entry);
            }
            IOObjectRelease(iter);
        } else operation = kr;
        report[@"interfaces_before"] = interfaces;
        report[@"matching_iap2_interfaces"] = @(matches);
        if (open && operation == kIOReturnSuccess) {
            if (matches != 1 || !controller || !disconnected(controller)) {
                report[@"error"] = @"Requires one SmartBoxIAP2 interface on the prepared, disconnected controller";
                operation = kIOReturnNotReady;
            } else {
                operation = IOServiceOpen(selected, mach_task_self(), 123, &connection);
                report[@"user_client_open"] = result(operation);
                if (operation == kIOReturnSuccess) {
                    // Dispatch signatures were verified in this OS's IOUSBDeviceFamily.
                    auto call = [&](NSString *name, uint32_t selector, const uint64_t *args, uint32_t count,
                                    uint64_t *out, uint32_t outCount) -> IOReturn {
                        uint32_t actual = outCount;
                        IOReturn r = IOConnectCallScalarMethod(connection, selector, args, count, out, &actual);
                        report[name] = result(r);
                        if (r == kIOReturnSuccess && actual != outCount) {
                            report[@"error"] = @"Unexpected scalar output count";
                            return kIOReturnBadArgument;
                        }
                        return r;
                    };
                    uint64_t flags = 0;
                    operation = call(@"interface_open", 0, &flags, 1, nullptr, 0);
                    opened = operation == kIOReturnSuccess;
                    if (configure && opened) {
                        operation = [&]() -> IOReturn {
                            if (!disconnected(controller)) return kIOReturnNotReady;
                            // Vendor-specific iAP2 interface: FF/F0/00, configuration 1.
                            const uint64_t classes[] = {0xff, 0xf0, 0x00};
                            NSArray *names = @[@"set_class", @"set_subclass", @"set_protocol"];
                            for (unsigned i = 0; i < 3; ++i) {
                                uint64_t args[] = {classes[i], 1};
                                IOReturn r = call(names[i], 3 + i, args, 2, nullptr, 0);
                                if (r) return r;
                            }
                            NSMutableArray *pipes = [NSMutableArray array];
                            for (unsigned direction = 0; direction < 2; ++direction) {
                                // Bulk, OUT/IN, 512-byte HS packet, interval 0, options 0, config 1.
                                uint64_t args[] = {2, direction, 512, 0, 0, 1};
                                uint64_t pipe = 0;
                                IOReturn r = call(direction ? @"create_in_pipe" : @"create_out_pipe", 10, args, 6, &pipe, 1);
                                if (r) return r;
                                [pipes addObject:@{@"direction": direction ? @"IN" : @"OUT", @"id": @(pipe)}];
                            }
                            report[@"pipes"] = pipes;
                            if (!disconnected(controller)) return kIOReturnNotReady;
                            return call(@"commit_configuration", 11, nullptr, 0, nullptr, 0);
                        }();
                    }
                    report[@"interface_after"] = properties(selected);
                    if (opened) {
                        IOReturn close = call(@"interface_close", 1, nullptr, 0, nullptr, 0);
                        if (!operation) operation = close;
                    }
                    IOReturn close = IOServiceClose(connection);
                    report[@"user_client_close"] = result(close);
                    if (!operation) operation = close;
                }
            }
        }
        if (controller) {
            report[@"controller_state_after"] = properties(controller)[@"CurrentState"] ?: @{};
            IOObjectRelease(controller);
        }
        if (selected) IOObjectRelease(selected);
        report[@"result"] = result(operation);
        NSError *error = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:report options:NSJSONWritingPrettyPrinted|NSJSONWritingSortedKeys error:&error];
        if (!json) { fprintf(stderr, "%s\n", error.description.UTF8String); return 1; }
        fwrite(json.bytes, 1, json.length, stdout); putchar('\n');
        return operation == kIOReturnSuccess ? 0 : 3;
    }
}
