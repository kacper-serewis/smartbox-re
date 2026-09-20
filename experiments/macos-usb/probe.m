// Probe macOS USB gadget configuration access on the owned dongle's port.
// Default is read-only. --check-access submits the existing, disconnected
// device-controller configuration unchanged. No role-switch request is sent.
#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <mach/mach_error.h>
#include <unistd.h>

static NSDictionary *properties(io_registry_entry_t entry) {
    CFMutableDictionaryRef value = NULL;
    if (IORegistryEntryCreateCFProperties(entry, &value, kCFAllocatorDefault, 0)) return @{};
    return CFBridgingRelease(value);
}
static NSString *path(io_registry_entry_t entry) {
    io_string_t value;
    return IORegistryEntryGetPath(entry, kIOServicePlane, value) ? @"" : @(value);
}
static uint64_t portID(io_registry_entry_t entry) {
    IOObjectRetain(entry);
    uint64_t found = 0;
    while (entry) {
        io_name_t name;
        if (!IORegistryEntryGetName(entry, name) && !strncmp(name, "usb-drd", 7) &&
            name[7] && strspn(name + 7, "0123456789") == strlen(name + 7)) {
            IORegistryEntryGetRegistryEntryID(entry, &found);
            IOObjectRelease(entry);
            break;
        }
        io_registry_entry_t parent = 0;
        IORegistryEntryGetParentEntry(entry, kIOServicePlane, &parent);
        IOObjectRelease(entry);
        entry = parent;
    }
    return found;
}
static NSDictionary *result(IOReturn code) {
    return @{@"hex": [NSString stringWithFormat:@"0x%08x", code],
             @"message": @(mach_error_string(code)), @"success": @(code == kIOReturnSuccess)};
}
static IOReturn kernelProbe(io_service_t controller, NSMutableDictionary *report) {
    io_iterator_t iter = 0;
    IOReturn kr = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("SmartBoxUSBProbe"), &iter);
    if (kr) return kr;
    io_service_t entry, selected = 0;
    unsigned matches = 0;
    while ((entry = IOIteratorNext(iter))) {
        io_registry_entry_t parent = 0;
        if (!IORegistryEntryGetParentEntry(entry, kIOServicePlane, &parent)) {
            if (IOObjectIsEqualTo(parent, controller)) {
                matches++;
                if (!selected) { selected = entry; IOObjectRetain(selected); }
            }
            IOObjectRelease(parent);
        }
        IOObjectRelease(entry);
    }
    IOObjectRelease(iter);
    if (matches != 1) {
        if (selected) IOObjectRelease(selected);
        report[@"kernel_probe_error"] = @"Exactly one loaded SmartBoxUSBProbe on the dongle controller is required";
        return kIOReturnNotFound;
    }
    report[@"kernel_probe_path"] = path(selected);
    NSDictionary *command = @{@"CheckConfigurationAccess": @YES};
    kr = IORegistryEntrySetCFProperties(selected, (__bridge CFDictionaryRef)command);
    report[@"kernel_request"] = result(kr);
    if (kr == kIOReturnSuccess) {
        kr = kIOReturnTimeout;
        for (int i = 0; i < 50; i++) {
            NSDictionary *p = properties(selected);
            if ([p[@"ProbeCompleted"] isEqual:@YES] && [p[@"ProbeResult"] isKindOfClass:[NSNumber class]]) {
                kr = [p[@"ProbeResult"] unsignedIntValue];
                break;
            }
            usleep(100000);
        }
        report[@"kernel_configuration_result"] = result(kr);
    }
    IOObjectRelease(selected);
    return kr;
}
int main(int argc, const char **argv) {
    @autoreleasepool {
        BOOL kernel = argc == 2 && !strcmp(argv[1], "--kernel-check-access");
        BOOL check = kernel || (argc == 2 && !strcmp(argv[1], "--check-access"));
        if (argc != 1 && !check) {
            fprintf(stderr, "usage: probe-mac-usb [--check-access | --kernel-check-access]\n"); return 2;
        }
        NSMutableDictionary *report = [@{@"check_access_requested": @(check),
            @"kernel_check_requested": @(kernel),
            @"role_switch_sent": @NO, @"custom_configuration_sent": @NO} mutableCopy];
        io_iterator_t iter = 0;
        IOReturn kr = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOUSBHostDevice"), &iter);
        if (kr) { fprintf(stderr, "USB enumeration: %s\n", mach_error_string(kr)); return 1; }
        uint64_t targetPort = 0;
        unsigned targets = 0;
        io_service_t entry;
        while ((entry = IOIteratorNext(iter))) {
            NSDictionary *p = properties(entry);
            if ([p[@"USB Serial Number"] isEqual:@"6a001f5ae423f030c687441ff4dbcb7dbf3e8b26"] &&
                [p[@"idVendor"] unsignedIntValue] == 0x05ac && [p[@"idProduct"] unsignedIntValue] == 0x12a8) {
                targets++;
                targetPort = portID(entry);
                report[@"dongle"] = @{@"path": path(entry), @"physical_port_id": @(targetPort),
                    @"configuration": p[@"kUSBCurrentConfiguration"] ?: [NSNull null]};
            }
            IOObjectRelease(entry);
        }
        IOObjectRelease(iter);
        NSMutableArray *controllers = [NSMutableArray array];
        io_service_t selected = 0;
        unsigned matches = 0;
        kr = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOUSBDeviceController"), &iter);
        if (kr) { fprintf(stderr, "Gadget enumeration: %s\n", mach_error_string(kr)); return 1; }
        while ((entry = IOIteratorNext(iter))) {
            NSDictionary *p = properties(entry);
            uint64_t port = portID(entry);
            BOOL match = targetPort && port == targetPort && targets == 1;
            [controllers addObject:@{@"path": path(entry), @"physical_port_id": @(port), @"matches_dongle_port": @(match),
                @"state": p[@"CurrentState"] ?: @{}, @"description": p[@"DeviceDescription"] ?: @{}}];
            if (match) { matches++; if (!selected) { selected = entry; IOObjectRetain(selected); } }
            IOObjectRelease(entry);
        }
        IOObjectRelease(iter);
        report[@"controllers"] = controllers;
        report[@"matching_controllers"] = @(matches);
        int status = 0;
        if (check) {
            NSDictionary *p = selected ? properties(selected) : @{};
            NSDictionary *state = p[@"CurrentState"];
            NSDictionary *description = p[@"DeviceDescription"];
            if (targets != 1 || matches != 1 ||
                ![state isKindOfClass:[NSDictionary class]] ||
                ![state[@"DeviceState"] isEqual:@"Disconnected"] ||
                ![state[@"OnBus"] isEqual:@NO] ||
                ![description isKindOfClass:[NSDictionary class]] ||
                ![description[@"ConfigurationDescriptors"] isKindOfClass:[NSArray class]] ||
                ![description[@"ConfigurationDescriptors"] count]) {
                report[@"refused"] = @"Requires the exact dongle, one matching controller, disconnected device mode, and an existing configuration";
                status = 2;
            } else {
                NSDictionary *command = @{@"USBDeviceCommand": @"SetDeviceConfiguration",
                    @"USBDeviceCommandParameter": description};
                if (kernel) kr = kernelProbe(selected, report);
                else {
                    kr = IORegistryEntrySetCFProperties(selected, (__bridge CFDictionaryRef)command);
                    report[@"set_existing_configuration"] = result(kr);
                }
                NSDictionary *after = properties(selected);
                report[@"description_unchanged"] = @([description isEqual:after[@"DeviceDescription"]]);
                report[@"state_after"] = after[@"CurrentState"] ?: @{};
                // Success is only API acceptance, never proof of a CarPlay session.
                status = kr == kIOReturnSuccess ? 0 : 3;
            }
        }
        if (selected) IOObjectRelease(selected);
        NSError *error = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:report options:NSJSONWritingPrettyPrinted|NSJSONWritingSortedKeys error:&error];
        if (!json) { fprintf(stderr, "JSON: %s\n", error.description.UTF8String); return 1; }
        fwrite(json.bytes, 1, json.length, stdout); putchar('\n');
        return status;
    }
}
