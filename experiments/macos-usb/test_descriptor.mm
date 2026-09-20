#include "FoundationNodes.h"
#include <cassert>
static NSMutableDictionary *base() {
    return [@{@"vendorID": @1452, @"productID": @6405, @"MaxPower": @-1,
              @"MPS0": @64, @"AllowMultipleCreates": @YES,
              @"ConfigurationDescriptors": @[@{@"Attributes": @192, @"MaxPower": @0,
                  @"Interfaces": @[@"SmartBoxIAP2", @"AppleUSBNCMControl", @"AppleUSBNCMData"]}]} mutableCopy];
}
int main() {
    @autoreleasepool {
        assert(DescriptorSchema::valid(base()));
        assert(!DescriptorSchema::valid(@[]));
        assert(!DescriptorSchema::valid(nil));
        for (id bad in @[@YES, @65536, @-1, @1.5, @"12", [NSNull null], @{}, @[]]) {
            auto d = base(); d[@"vendorID"] = bad;
            assert(!DescriptorSchema::valid(d));
        }
        for (id bad in @[@0, @65, @512, @YES]) {
            auto d = base(); d[@"MPS0"] = bad; assert(!DescriptorSchema::valid(d));
        }
        auto d = base(); d[@"Extra"] = @{}; assert(!DescriptorSchema::valid(d));
        d = base(); [d removeObjectForKey:@"productID"]; assert(!DescriptorSchema::valid(d));
        d = base(); d[@"AllowMultipleCreates"] = @1; assert(!DescriptorSchema::valid(d));
        for (id bad in @[@"", @"BadInterface", @"SmartBox", @"SmartBox/IAP2", @"SmartBox\nIAP2", @"SmartBox\0IAP2",
                        @"SmartBoxé", [@"SmartBox" stringByPaddingToLength:64 withString:@"X" startingAtIndex:0], @1]) {
            assert(!DescriptorSchema::function(bad));
        }
        for (id bad in @[@[], @[@"SmartBoxIAP2", @"SmartBoxIAP2"], @[@{}],
                        @[@"SmartBox1", @"SmartBox2", @"SmartBox3", @"SmartBox4", @"SmartBox5", @"SmartBox6", @"SmartBox7", @"SmartBox8", @"SmartBox9"]]) {
            d = base(); d[@"ConfigurationDescriptors"] = @[@{@"Attributes": @192, @"MaxPower": @0, @"Interfaces": bad}];
            assert(!DescriptorSchema::valid(d));
        }
        for (id bad in @[@[], @{}, @[@{}], @[@{@"Attributes": @192, @"MaxPower": @0, @"Interfaces": @[@"SmartBoxIAP2"], @"Extra": @1}]]) {
            d = base(); d[@"ConfigurationDescriptors"] = bad; assert(!DescriptorSchema::valid(d));
        }
        d = base(); d[@"ConfigurationDescriptors"] = @[d[@"ConfigurationDescriptors"][0], d[@"ConfigurationDescriptors"][0],
            d[@"ConfigurationDescriptors"][0], d[@"ConfigurationDescriptors"][0], d[@"ConfigurationDescriptors"][0]];
        assert(!DescriptorSchema::valid(d));
        for (id bad in @[@"", @"hi\n", @"a\0b", [@"a" stringByPaddingToLength:127 withString:@"b" startingAtIndex:0]]) {
            d = base(); d[@"productString"] = bad; assert(!DescriptorSchema::valid(d));
        }
        puts("PASS: descriptor bounds, types, unknown fields, interface names, duplicates, embedded NULs");
    }
}
