#pragma once
#import <Foundation/Foundation.h>
#include <cstring>
#include "DescriptorValidation.h"
struct FoundationNodes {
    using Node = id;
    static bool dict(Node n) { return [n isKindOfClass:[NSDictionary class]]; }
    static bool array(Node n) { return [n isKindOfClass:[NSArray class]]; }
    static unsigned count(Node n) { return (unsigned)[n count]; }
    static Node get(Node n, const char *key) { return [(NSDictionary *)n objectForKey:@(key)]; }
    static Node at(Node n, unsigned i) { return [(NSArray *)n objectAtIndex:i]; }
    static const char *string(Node n) {
        if (![n isKindOfClass:[NSString class]]) return nullptr;
        const char *s = [(NSString *)n UTF8String];
        return s && strlen(s) == [(NSString *)n lengthOfBytesUsingEncoding:NSUTF8StringEncoding] ? s : nullptr;
    }
    static bool boolean(Node n) {
        return n && CFGetTypeID((__bridge CFTypeRef)n) == CFBooleanGetTypeID();
    }
    static bool number(Node n, long long &v) {
        if (![n isKindOfClass:[NSNumber class]] || boolean(n) ||
            CFNumberIsFloatType((__bridge CFNumberRef)n)) return false;
        return CFNumberGetValue((__bridge CFNumberRef)n, kCFNumberLongLongType, &v);
    }
};
using DescriptorSchema = DescriptorValidation<FoundationNodes>;
