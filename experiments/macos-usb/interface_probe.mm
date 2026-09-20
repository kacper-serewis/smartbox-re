// Bounded user-space test of our own iAP2 interface. Never sends a role switch.
#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <mach/mach_error.h>
#include <cstring>
#include <chrono>
#include <csignal>
#include <cstdlib>
#include <unistd.h>

static volatile sig_atomic_t interrupted = 0;
static void interruptHandler(int) { interrupted = 1; }

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
        unsigned listenSeconds = 0;
        if (argc == 3 && !strcmp(argv[1], "--listen")) {
            char *end = nullptr;
            long value = strtol(argv[2], &end, 10);
            if (!end || *end || value < 1 || value > 60) {
                fprintf(stderr, "Listen duration must be 1..60 seconds\n"); return 2;
            }
            listenSeconds = (unsigned)value;
        }
        BOOL configure = listenSeconds || (argc == 2 && !strcmp(argv[1], "--configure"));
        BOOL open = configure || (argc == 2 && !strcmp(argv[1], "--open"));
        if (argc != 1 && !open) {
            fprintf(stderr, "usage: mac-usb-interface [--open | --configure | --listen SECONDS]\n"); return 2;
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
                    if (listenSeconds && operation == kIOReturnSuccess) {
                        signal(SIGINT, interruptHandler); signal(SIGTERM, interruptHandler);
                        uint64_t size = 4096, mapping[3] = {};
                        operation = call(@"allocate_buffer", 18, &size, 1, mapping, 3);
                        if (operation == kIOReturnSuccess) {
                            // The mapped buffer belongs to this user client; no caller pointers enter the kernel.
                            if (!mapping[0] || mapping[1] < size) operation = kIOReturnBadArgument;
                            else {
                                auto *buffer = reinterpret_cast<unsigned char *>(mapping[0]);
                                NSMutableArray *states = [NSMutableArray array], *received = [NSMutableArray array], *detectWrites = [NSMutableArray array];
                                NSDictionary *previous = nil;
                                unsigned totalReceived = 0, writes = 0;
                                bool configured = false;
                                const uint8_t detect[] = {0xff, 0x55, 0x02, 0x00, 0xee, 0x10};
                                auto start = std::chrono::steady_clock::now();
                                auto nextDetect = start;
                                fprintf(stderr, "READY: SmartBoxIAP2 committed; listening for %u seconds\n", listenSeconds);
                                fflush(stderr);
                                while (!interrupted && std::chrono::steady_clock::now() - start < std::chrono::seconds(listenSeconds)) {
                                    NSDictionary *state = properties(controller)[@"CurrentState"] ?: @{};
                                    if (![state isEqual:previous]) {
                                        if (states.count < 128) [states addObject:state];
                                        previous = state;
                                    }
                                    if ([state[@"OnBus"] isEqual:@YES] && [state[@"SelectedConfiguration"] unsignedIntValue] > 0) {
                                        configured = true;
                                        report[@"data_transfer_attempted"] = @YES;
                                        if (writes < 3 && std::chrono::steady_clock::now() >= nextDetect) {
                                            memcpy(buffer, detect, sizeof(detect));
                                            uint64_t args[] = {[report[@"pipes"][1][@"id"] unsignedLongLongValue], mapping[2], sizeof(detect), 100};
                                            uint64_t bytes = 0; uint32_t count = 1;
                                            IOReturn r = IOConnectCallScalarMethod(connection, 14, args, 4, &bytes, &count);
                                            [detectWrites addObject:@{@"result": result(r), @"bytes": @(bytes)}];
                                            writes++;
                                            nextDetect = std::chrono::steady_clock::now() + std::chrono::milliseconds(200);
                                            if (r && r != kIOReturnTimeout && (uint32_t)r != 0xe0000001) {
                                                operation = r; break;
                                            }
                                        }
                                        uint64_t args[] = {[report[@"pipes"][0][@"id"] unsignedLongLongValue], mapping[2], size, 100};
                                        uint64_t bytes = 0; uint32_t count = 1;
                                        IOReturn r = IOConnectCallScalarMethod(connection, 13, args, 4, &bytes, &count);
                                        if (!r) {
                                            if (count != 1 || bytes > size) { operation = kIOReturnBadArgument; break; }
                                            if (bytes) {
                                                NSMutableString *hex = [NSMutableString string];
                                                for (uint64_t i = 0; i < bytes; ++i) [hex appendFormat:@"%02x", buffer[i]];
                                                [received addObject:hex]; totalReceived += (unsigned)bytes;
                                                if (totalReceived >= 16384) break;
                                            }
                                        } else if (r != kIOReturnTimeout && (uint32_t)r != 0xe0000001) {
                                            report[@"read_error"] = result(r); operation = r; break;
                                        }
                                    }
                                    usleep(100000);
                                }
                                report[@"state_changes"] = states;
                                report[@"observed_configured"] = @(configured);
                                report[@"detect_writes"] = detectWrites;
                                report[@"received_hex"] = received;
                                report[@"received_bytes"] = @(totalReceived);
                                report[@"interrupted"] = @(interrupted != 0);
                            }
                            IOReturn release = call(@"release_buffer", 19, &mapping[2], 1, nullptr, 0);
                            if (!operation) operation = release;
                        }
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
