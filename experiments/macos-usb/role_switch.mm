// One bounded vendor request to the verified owned dongle. Never resets USB,
// seizes an interface, changes configuration, or retries a role-switch request.
#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#include <libusb.h>
#include <cstring>
#import <mach/mach_error.h>
#include <chrono>
#include <csignal>
#include <unistd.h>

static volatile sig_atomic_t interrupted = 0;
static void interruptHandler(int) { interrupted = 1; }
static NSDictionary *ioResult(IOReturn code) {
    return @{@"hex": [NSString stringWithFormat:@"0x%08x", code], @"message": @(mach_error_string(code)),
             @"success": @(code == kIOReturnSuccess)};
}

static NSString *const portPath = @"IOService:/AppleARMPE/arm-io@10F00000/AppleSoCIO/usb-drd1@AA280000/";
static NSString *const controllerPath = @"IOService:/AppleARMPE/arm-io@10F00000/AppleSoCIO/usb-drd1@AA280000/AppleT8142USBXDCI@1";
static const char *serial = "6a001f5ae423f030c687441ff4dbcb7dbf3e8b26";
static NSDictionary *properties(io_registry_entry_t entry) {
    CFMutableDictionaryRef p = nullptr;
    return IORegistryEntryCreateCFProperties(entry, &p, kCFAllocatorDefault, 0) ? @{} : CFBridgingRelease(p);
}
static NSString *path(io_registry_entry_t entry) {
    io_string_t p;
    return IORegistryEntryGetPath(entry, kIOServicePlane, p) ? @"" : @(p);
}
static bool exactPort() {
    io_iterator_t iter = 0;
    if (IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOUSBHostDevice"), &iter)) return false;
    unsigned total = 0, matches = 0;
    io_service_t entry;
    while ((entry = IOIteratorNext(iter))) {
        NSDictionary *p = properties(entry);
        if ([p[@"USB Serial Number"] isEqual:@(serial)] && [p[@"idVendor"] unsignedIntValue] == 0x05ac &&
            [p[@"idProduct"] unsignedIntValue] == 0x12a8) {
            total++;
            if ([path(entry) hasPrefix:portPath]) matches++;
        }
        IOObjectRelease(entry);
    }
    IOObjectRelease(iter);
    return total == 1 && matches == 1;
}
static bool receiverReady() {
    io_service_t controller = IORegistryEntryFromPath(kIOMainPortDefault, controllerPath.UTF8String);
    if (!controller) return false;
    NSDictionary *state = properties(controller)[@"CurrentState"];
    bool disconnected = [state isKindOfClass:[NSDictionary class]] && [state[@"DeviceState"] isEqual:@"Disconnected"] &&
                        [state[@"OnBus"] isEqual:@NO];
    IOObjectRelease(controller);
    if (!disconnected) return false;
    io_iterator_t iter = 0;
    if (IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOUSBDeviceInterface"), &iter)) return false;
    unsigned ready = 0;
    io_service_t entry;
    while ((entry = IOIteratorNext(iter))) {
        NSDictionary *p = properties(entry);
        if ([path(entry) hasPrefix:[controllerPath stringByAppendingString:@"/"]] &&
            [p[@"USBDeviceFunction"] isEqual:@"SmartBoxIAP2"] && p[@"FinalizedTimestamp"]) {
            io_iterator_t children = 0;
            if (!IORegistryEntryGetChildIterator(entry, kIOServicePlane, &children)) {
                io_registry_entry_t child;
                while ((child = IOIteratorNext(children))) {
                    if (IOObjectConformsTo(child, "IOUSBDeviceInterfaceUserClient")) ready++;
                    IOObjectRelease(child);
                }
                IOObjectRelease(children);
            }
        }
        IOObjectRelease(entry);
    }
    IOObjectRelease(iter);
    return ready == 1;
}
static io_service_t managerForDongle() {
    io_iterator_t iter = 0;
    if (IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOPortTransportStateUSB2"), &iter)) return 0;
    io_service_t selected = 0, entry;
    unsigned matches = 0;
    while ((entry = IOIteratorNext(iter))) {
        NSDictionary *p = properties(entry);
        if ([p[@"Serial Number"] isEqual:@(serial)] && [p[@"Vendor ID"] unsignedIntValue] == 0x05ac &&
            [p[@"Product ID"] unsignedIntValue] == 0x12a8 && [p[@"ParentBuiltInPortNumber"] unsignedIntValue] == 2) {
            io_registry_entry_t node = entry; IOObjectRetain(node);
            while (node) {
                if (IOObjectConformsTo(node, "IOAccessoryManager")) {
                    NSDictionary *m = properties(node);
                    if ([m[@"PortTypeDescription"] isEqual:@"USB-C"] && [m[@"PortNumber"] unsignedIntValue] == 2 &&
                        [m[@"IOAccessoryPrimaryDevicePort"] unsignedIntValue] == 258) {
                        matches++;
                        if (!selected) { selected = node; IOObjectRetain(selected); }
                    }
                    IOObjectRelease(node); break;
                }
                io_registry_entry_t parent = 0;
                IORegistryEntryGetParentEntry(node, kIOServicePlane, &parent);
                IOObjectRelease(node); node = parent;
            }
        }
        IOObjectRelease(entry);
    }
    IOObjectRelease(iter);
    if (matches != 1) { if (selected) IOObjectRelease(selected); return 0; }
    return selected;
}
int main(int argc, const char **argv) {
    @autoreleasepool {
        bool changeMac = argc == 2 && !strcmp(argv[1], "--switch-with-mac-role");
        bool change = changeMac || (argc == 2 && !strcmp(argv[1], "--switch"));
        bool capabilities = argc == 2 && !strcmp(argv[1], "--capabilities");
        bool checkMac = argc == 2 && !strcmp(argv[1], "--check-mac-access");
        if (argc != 1 && !change && !capabilities && !checkMac) {
            fprintf(stderr, "usage: mac-usb-role [--capabilities | --switch | --check-mac-access | --switch-with-mac-role]\n"); return 2;
        }
        NSMutableDictionary *report = [@{@"role_switch_attempted": @NO, @"receiver_ready": @(receiverReady()),
                                         @"owned_dongle_on_prepared_port": @(exactPort())} mutableCopy];
        libusb_context *context = nullptr;
        libusb_device_handle *selected = nullptr;
        libusb_device **devices = nullptr;
        io_service_t manager = 0;
        io_connect_t managerConnection = 0;
        int status = 0;
        if (![report[@"owned_dongle_on_prepared_port"] boolValue] || (change && ![report[@"receiver_ready"] boolValue])) {
            report[@"error"] = @"Requires the exact dongle on the prepared port; switching also requires an open, committed SmartBoxIAP2 receiver";
            status = 2;
        } else if (checkMac) {
            io_service_t manager = managerForDongle();
            if (!manager) { report[@"error"] = @"No unique accessory manager associated with the owned dongle"; status = 2; }
            else {
                report[@"manager_path"] = path(manager);
                report[@"mode_before"] = properties(manager)[@"IOAccessoryUSBModeType"] ?: [NSNull null];
                io_connect_t connection = 0;
                IOReturn code = IOServiceOpen(manager, mach_task_self(), 0, &connection);
                report[@"manager_open"] = @{@"hex": [NSString stringWithFormat:@"0x%08x", code],
                    @"message": @(mach_error_string(code)), @"success": @(code == kIOReturnSuccess)};
                if (!code) IOServiceClose(connection);
                report[@"mode_after"] = properties(manager)[@"IOAccessoryUSBModeType"] ?: [NSNull null];
                report[@"mode_change_requested"] = @NO;
                IOObjectRelease(manager); status = code ? 3 : 0;
            }
        } else {
            int r = libusb_init(&context);
            if (r) { report[@"error"] = @(libusb_error_name(r)); status = 3; }
            else {
                ssize_t count = libusb_get_device_list(context, &devices);
                unsigned matches = 0;
                NSMutableArray *errors = [NSMutableArray array];
                if (count < 0) { report[@"error"] = @(libusb_error_name((int)count)); status = 3; }
                for (ssize_t i = 0; i < count; ++i) {
                    libusb_device_descriptor d = {};
                    if (libusb_get_device_descriptor(devices[i], &d) || d.idVendor != 0x05ac || d.idProduct != 0x12a8) continue;
                    libusb_device_handle *h = nullptr;
                    r = libusb_open(devices[i], &h);
                    if (r) { [errors addObject:@(libusb_error_name(r))]; continue; }
                    unsigned char value[256] = {};
                    int n = libusb_get_string_descriptor_ascii(h, d.iSerialNumber, value, sizeof(value));
                    if (n == (int)strlen(serial) && !memcmp(value, serial, n)) {
                        matches++;
                        if (!selected) { selected = h; h = nullptr; }
                    }
                    if (h) libusb_close(h);
                }
                report[@"usb_open_errors"] = errors;
                report[@"matching_usb_handles"] = @(matches);
                if (matches != 1 || !selected) {
                    report[@"error"] = @"Could not open exactly one USB handle with the owned dongle serial"; status = 3;
                } else if (capabilities || change) {
                    bool macReady = true;
                    if (changeMac) {
                        manager = managerForDongle();
                        if (!manager || ![properties(manager)[@"IOAccessoryUSBModeType"] isEqual:@2]) macReady = false;
                        else {
                            report[@"manager_path"] = path(manager);
                            report[@"mode_before"] = properties(manager)[@"IOAccessoryUSBModeType"];
                            IOReturn code = IOServiceOpen(manager, mach_task_self(), 0, &managerConnection);
                            report[@"manager_open"] = ioResult(code);
                            macReady = code == kIOReturnSuccess;
                        }
                    }
                    if (!macReady || !exactPort() || (change && !receiverReady())) {
                        report[@"error"] = @"Device or receiver state changed before the request"; status = 2;
                    } else {
                        unsigned char data[4] = {};
                        if (change) report[@"role_switch_attempted"] = @YES;
                        r = libusb_control_transfer(selected, change ? 0x40 : 0xc0, change ? 0x51 : 0x53,
                                                    change ? 1 : 0, 0, change ? nullptr : data, change ? 0 : 4, 2000);
                        report[@"control_request"] = @{@"bmRequestType": @(change ? 0x40 : 0xc0), @"bRequest": @(change ? 0x51 : 0x53),
                            @"wValue": @(change ? 1 : 0), @"wIndex": @0, @"wLength": @(change ? 0 : 4), @"timeout_ms": @2000};
                        report[@"transfer_result"] = @{@"return_value": @(r), @"message": r < 0 ? @(libusb_error_name(r)) : @"completed",
                            @"success": @(r == (change ? 0 : 4))};
                        if (!change && r > 0 && r <= 4) {
                            NSMutableArray *bytes = [NSMutableArray array];
                            for (int i = 0; i < r; ++i) [bytes addObject:@(data[i])];
                            report[@"capability_bytes"] = bytes;
                        }
                        if (r != (change ? 0 : 4)) status = 3;
                        if (changeMac && r == 0) {
                            // Verified in this OS: selector 1 takes one scalar USB mode.
                            // Mode 0 maps to USB DataRole=1 (device); mode 2 is the saved host mode.
                            // This is not the separate power/current-limit configuration API.
                            signal(SIGINT, interruptHandler); signal(SIGTERM, interruptHandler);
                            uint64_t mode = 0; uint32_t count = 0;
                            IOReturn code = IOConnectCallScalarMethod(managerConnection, 1, &mode, 1, nullptr, &count);
                            report[@"mac_device_mode_request"] = ioResult(code);
                            NSMutableArray *observed = [NSMutableArray array];
                            if (!code) {
                                auto start = std::chrono::steady_clock::now();
                                while (!interrupted && std::chrono::steady_clock::now() - start < std::chrono::seconds(15)) {
                                    io_service_t dc = IORegistryEntryFromPath(kIOMainPortDefault, controllerPath.UTF8String);
                                    NSMutableDictionary *s = dc ? [properties(dc)[@"CurrentState"] mutableCopy] : nil;
                                    [s removeObjectForKey:@"DSTS"];
                                    NSDictionary *row = @{@"mode": properties(manager)[@"IOAccessoryUSBModeType"] ?: [NSNull null],
                                                           @"controller_state": s ?: @{}};
                                    if (![row isEqual:observed.lastObject]) [observed addObject:row];
                                    if (dc) IOObjectRelease(dc);
                                    usleep(100000);
                                }
                            } else status = 3;
                            report[@"mac_role_observations"] = observed;
                            // Restore even if the mode request returned an error: it may have side effects.
                            mode = 2; count = 0;
                            code = IOConnectCallScalarMethod(managerConnection, 1, &mode, 1, nullptr, &count);
                            report[@"mac_host_mode_restore"] = ioResult(code);
                            report[@"mode_after"] = properties(manager)[@"IOAccessoryUSBModeType"] ?: [NSNull null];
                            if (code) status = 3;
                        }
                    }
                }
            }
        }
        if (selected) libusb_close(selected);
        if (devices) libusb_free_device_list(devices, 1);
        if (context) libusb_exit(context);
        if (managerConnection) IOServiceClose(managerConnection);
        if (manager) IOObjectRelease(manager);
        NSError *error = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:report options:NSJSONWritingPrettyPrinted|NSJSONWritingSortedKeys error:&error];
        if (!json) { fprintf(stderr, "%s\n", error.description.UTF8String); return 1; }
        fwrite(json.bytes, 1, json.length, stdout); putchar('\n'); return status;
    }
}
