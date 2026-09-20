// Reusable user-space client for bridge protocol 3. No USB role-switch request.
#include "FoundationNodes.h"
#import <IOKit/IOKitLib.h>
#import <mach/mach_error.h>
#include <unistd.h>
#include <limits.h>

static NSDictionary *properties(io_registry_entry_t entry) {
    CFMutableDictionaryRef value = nullptr;
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
            IORegistryEntryGetRegistryEntryID(entry, &found); IOObjectRelease(entry); break;
        }
        io_registry_entry_t parent = 0;
        IORegistryEntryGetParentEntry(entry, kIOServicePlane, &parent);
        IOObjectRelease(entry); entry = parent;
    }
    return found;
}
static NSDictionary *result(IOReturn code) {
    return @{@"hex": [NSString stringWithFormat:@"0x%08x", code],
             @"message": @(mach_error_string(code)), @"success": @(code == kIOReturnSuccess)};
}
static NSDictionary *diagnostics(io_service_t service) {
    NSDictionary *p = properties(service);
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    for (NSString *k in p) if ([k hasPrefix:@"Probe"]) d[k] = p[k];
    return d;
}
static NSDictionary *loadDescription(const char *filename) {
    NSError *error = nil;
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:@(filename) error:&error];
    if (!attr || [attr fileSize] > 16384) return nil;
    NSData *data = [NSData dataWithContentsOfFile:@(filename)];
    if (!data || data.length > 16384) return nil;
    id doc = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    return DescriptorSchema::valid(doc) ? doc : nil;
}
static int output(NSDictionary *report, int status) {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:report options:NSJSONWritingPrettyPrinted|NSJSONWritingSortedKeys error:&error];
    if (!data) { fprintf(stderr, "%s\n", error.description.UTF8String); return 1; }
    fwrite(data.bytes, 1, data.length, stdout); putchar('\n'); return status;
}
int main(int argc, const char **argv) {
    @autoreleasepool {
        NSString *action = argc >= 2 ? @(argv[1]) : @"--status";
        NSDictionary *commands = @{@"--check": @"Check", @"--republish": @"Republish", @"--publish": @"Publish",
            @"--restore": @"Restore", @"--force-off-bus": @"ForceOffBus", @"--release-off-bus": @"ReleaseOffBus"};
        BOOL fileAction = [action isEqual:@"--publish"] || [action isEqual:@"--validate"] || [action isEqual:@"--make-profile"];
        if ((fileAction ? argc != 3 : argc > 2) || (!commands[action] &&
            ![@[@"--status", @"--validate", @"--make-profile"] containsObject:action])) {
            fprintf(stderr, "usage: mac-usb-bridge [--status | --check | --republish | --restore | --force-off-bus | --release-off-bus | --publish FILE | --validate FILE | --make-profile FILE]\n"); return 2;
        }
        NSDictionary *description = nil;
        if ([action isEqual:@"--publish"] || [action isEqual:@"--validate"]) {
            description = loadDescription(argv[2]);
            if (!description) return output(@{@"error": @"Invalid or oversized USB description; no request sent"}, 2);
            if ([action isEqual:@"--validate"]) return output(@{@"valid": @YES, @"description": description}, 0);
        }
        NSMutableDictionary *report = [@{@"action": action, @"role_switch_sent": @NO} mutableCopy];
        io_iterator_t iter = 0;
        IOReturn kr = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("SmartBoxUSBProbe"), &iter);
        if (kr) return output(@{@"enumeration_error": result(kr)}, 1);
        io_service_t entry, bridge = 0, controller = 0;
        unsigned matches = 0;
        while ((entry = IOIteratorNext(iter))) {
            io_registry_entry_t parent = 0;
            if (!IORegistryEntryGetParentEntry(entry, kIOServicePlane, &parent)) {
                if ([path(parent) isEqual:@"IOService:/AppleARMPE/arm-io@10F00000/AppleSoCIO/usb-drd1@AA280000/AppleT8142USBXDCI@1"]) {
                    matches++;
                    if (!bridge) { bridge = entry; controller = parent; IOObjectRetain(bridge); IOObjectRetain(controller); }
                }
                IOObjectRelease(parent);
            }
            IOObjectRelease(entry);
        }
        IOObjectRelease(iter);
        if (matches != 1) {
            if (bridge) IOObjectRelease(bridge);
            if (controller) IOObjectRelease(controller);
            return output(@{@"error": @"Exactly one bridge on the prepared Mac port is required"}, 2);
        }
        NSDictionary *before = properties(controller);
        NSDictionary *bridgeBefore = diagnostics(bridge);
        report[@"bridge"] = bridgeBefore;
        report[@"controller_path"] = path(controller);
        report[@"state_before"] = before[@"CurrentState"] ?: @{};
        report[@"description_before"] = before[@"DeviceDescription"] ?: @{};
        unsigned targets = 0;
        kr = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOUSBHostDevice"), &iter);
        if (!kr) {
            while ((entry = IOIteratorNext(iter))) {
                NSDictionary *p = properties(entry);
                if ([p[@"USB Serial Number"] isEqual:@"6a001f5ae423f030c687441ff4dbcb7dbf3e8b26"] &&
                    [p[@"idVendor"] unsignedIntValue] == 0x05ac && [p[@"idProduct"] unsignedIntValue] == 0x12a8 &&
                    portID(entry) == portID(controller)) targets++;
                IOObjectRelease(entry);
            }
            IOObjectRelease(iter);
        }
        report[@"matching_dongles"] = @(targets);
        int status = 0;
        if ([action isEqual:@"--make-profile"]) {
            NSMutableDictionary *profile = [before[@"DeviceDescription"] mutableCopy];
            if (![profile isKindOfClass:[NSMutableDictionary class]]) {
                report[@"error"] = @"Controller has no description"; status = 2;
            } else {
                profile[@"AllowMultipleCreates"] = @YES;
                profile[@"productString"] = @"SmartBox Mac receiver test";
                profile[@"ConfigurationDescriptors"] = @[@{@"Description": @"SmartBox iAP2 and NCM", @"Attributes": @192,
                    @"MaxPower": @0, @"Interfaces": @[@"SmartBoxIAP2", @"AppleUSBNCMControl", @"AppleUSBNCMData"]}];
                NSError *error = nil;
                NSData *json = DescriptorSchema::valid(profile) ? [NSJSONSerialization dataWithJSONObject:profile options:NSJSONWritingPrettyPrinted error:&error] : nil;
                if (!json || ![json writeToFile:@(argv[2]) options:NSDataWritingWithoutOverwriting error:&error]) {
                    report[@"error"] = error.description ?: @"Profile schema rejected controller fields"; status = 2;
                } else report[@"profile_saved"] = @(argv[2]);
            }
        } else if (commands[action]) {
            BOOL recovery = [@[@"--restore", @"--force-off-bus", @"--release-off-bus"] containsObject:action];
            unsigned long long lastID = [bridgeBefore[@"ProbeLastRequestID"] unsignedLongLongValue];
            if (![bridgeBefore[@"ProbeVersion"] isEqual:@"3"]) {
                report[@"error"] = @"Bridge protocol 3 (kext 0.2.0) must be loaded first"; status = 2;
            } else if (getuid() != 0) {
                report[@"error"] = @"Administrator access is required; no request sent"; status = 2;
            } else if ((!recovery && targets != 1) || (recovery && !bridgeBefore[@"ProbeOriginalDescription"])) {
                report[@"error"] = @"Requires the owned dongle on this port, or a saved description for recovery"; status = 2;
            } else if (lastID >= LLONG_MAX) {
                report[@"error"] = @"Request IDs exhausted"; status = 2;
            } else {
                NSNumber *requestID = @(lastID + 1);
                NSMutableDictionary *request = [@{@"Command": commands[action], @"RequestID": requestID} mutableCopy];
                if (description) request[@"Description"] = description;
                report[@"request_id"] = requestID;
                kr = IORegistryEntrySetCFProperties(bridge, (__bridge CFDictionaryRef)request);
                report[@"request_result"] = result(kr);
                if (kr == kIOReturnSuccess) {
                    kr = kIOReturnTimeout;
                    for (int i = 0; i < 100; i++) {
                        NSDictionary *p = diagnostics(bridge);
                        if ([p[@"ProbeCompleted"] isEqual:@YES] && [p[@"ProbeCompletedRequestID"] isEqual:requestID] &&
                            [p[@"ProbeResult"] isKindOfClass:[NSNumber class]]) {
                            kr = [p[@"ProbeResult"] unsignedIntValue]; break;
                        }
                        usleep(100000);
                    }
                    report[@"operation_result"] = result(kr);
                    if (kr == kIOReturnTimeout) report[@"error"] = @"Still pending or completion unavailable; inspect --status, do not auto-retry";
                }
                status = kr == kIOReturnSuccess ? 0 : 3;
            }
        }
        NSDictionary *after = properties(controller);
        report[@"state_after"] = after[@"CurrentState"] ?: @{};
        report[@"description_after"] = after[@"DeviceDescription"] ?: @{};
        report[@"description_unchanged"] = @([before[@"DeviceDescription"] isEqual:after[@"DeviceDescription"]]);
        report[@"bridge_after"] = diagnostics(bridge);
        if ([action isEqual:@"--restore"] && bridgeBefore[@"ProbeOriginalDescription"]) {
            NSMutableDictionary *expected = [bridgeBefore[@"ProbeOriginalDescription"] mutableCopy];
            NSMutableDictionary *actual = [after[@"DeviceDescription"] mutableCopy];
            [expected removeObjectForKey:@"AllowMultipleCreates"];
            [actual removeObjectForKey:@"AllowMultipleCreates"];
            report[@"original_configuration_restored"] = @([expected isEqual:actual]);
        }
        IOObjectRelease(controller); IOObjectRelease(bridge);
        return output(report, status);
    }
}
