// One bounded vendor request to the verified owned dongle. Never resets USB,
// seizes an interface, changes configuration, or retries a role-switch request.
#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#include <libusb.h>
#include <cstring>

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
int main(int argc, const char **argv) {
    @autoreleasepool {
        bool change = argc == 2 && !strcmp(argv[1], "--switch");
        bool capabilities = argc == 2 && !strcmp(argv[1], "--capabilities");
        if (argc != 1 && !change && !capabilities) {
            fprintf(stderr, "usage: mac-usb-role [--capabilities | --switch]\n"); return 2;
        }
        NSMutableDictionary *report = [@{@"role_switch_attempted": @NO, @"receiver_ready": @(receiverReady()),
                                         @"owned_dongle_on_prepared_port": @(exactPort())} mutableCopy];
        libusb_context *context = nullptr;
        libusb_device_handle *selected = nullptr;
        libusb_device **devices = nullptr;
        int status = 0;
        if (![report[@"owned_dongle_on_prepared_port"] boolValue] || (change && ![report[@"receiver_ready"] boolValue])) {
            report[@"error"] = @"Requires the exact dongle on the prepared port; switching also requires an open, committed SmartBoxIAP2 receiver";
            status = 2;
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
                    if (!exactPort() || (change && !receiverReady())) {
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
                    }
                }
            }
        }
        if (selected) libusb_close(selected);
        if (devices) libusb_free_device_list(devices, 1);
        if (context) libusb_exit(context);
        NSError *error = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:report options:NSJSONWritingPrettyPrinted|NSJSONWritingSortedKeys error:&error];
        if (!json) { fprintf(stderr, "%s\n", error.description.UTF8String); return 1; }
        fwrite(json.bytes, 1, json.length, stdout); putchar('\n'); return status;
    }
}
