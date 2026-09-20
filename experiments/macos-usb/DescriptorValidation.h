#pragma once
// One bounded schema for the kernel and the Foundation client/tests.
// Traits only provide dictionary/array/scalar access; no recursive traversal.
template<class T> struct DescriptorValidation {
    using N = typename T::Node;
    static bool text(N n, unsigned max) {
        const char *s = T::string(n);
        if (!s) return false;
        unsigned i = 0;
        for (; s[i] && i <= max; ++i)
            if ((unsigned char)s[i] < 32 || (unsigned char)s[i] > 126) return false;
        return i > 0 && i <= max;
    }
    static bool number(N n, long long min, long long max) {
        long long value = 0;
        return T::number(n, value) && value >= min && value <= max;
    }
    static bool eq(const char *a, const char *b) {
        if (!a || !b) return false;
        while (*a && *a == *b) { ++a; ++b; }
        return *a == *b;
    }
    static bool function(N n) {
        if (!text(n, 63)) return false;
        const char *s = T::string(n);
        const char *names[] = {"AppleUSBNCMControl", "AppleUSBNCMData",
                              "AppleUSBNCMControlAux", "AppleUSBNCMDataAux", "AppleUSBMux"};
        for (const char *name : names) if (eq(s, name)) return true;
        const char *prefix = "SmartBox";
        while (*prefix) { if (*s++ != *prefix++) return false; }
        if (!*s) return false;
        for (; *s; ++s)
            if (!((*s >= 'a' && *s <= 'z') || (*s >= 'A' && *s <= 'Z') ||
                  (*s >= '0' && *s <= '9') || *s == '_')) return false;
        return true;
    }
    static bool configuration(N n) {
        if (!T::dict(n)) return false;
        unsigned recognized = 0;
        const char *numbers[] = {"Attributes", "MaxPower"};
        for (const char *key : numbers) {
            N v = T::get(n, key);
            if (!number(v, 0, 255)) return false;
            ++recognized;
        }
        N desc = T::get(n, "Description");
        if (desc) { if (!text(desc, 126)) return false; ++recognized; }
        N interfaces = T::get(n, "Interfaces");
        if (!T::array(interfaces) || T::count(interfaces) < 1 || T::count(interfaces) > 8) return false;
        for (unsigned i = 0; i < T::count(interfaces); ++i) {
            if (!function(T::at(interfaces, i))) return false;
            for (unsigned j = 0; j < i; ++j)
                if (eq(T::string(T::at(interfaces, i)), T::string(T::at(interfaces, j)))) return false;
        }
        return T::count(n) == recognized + 1;
    }
    static bool valid(N n) {
        if (!T::dict(n) || T::count(n) > 18) return false;
        unsigned recognized = 0;
        const char *words[] = {"vendorID", "productID", "deviceID", "BcdUSBVersion", "DefaultBcdUSBVersion"};
        for (const char *key : words) {
            N v = T::get(n, key);
            if (v) { if (!number(v, 0, 65535)) return false; ++recognized; }
        }
        if (!T::get(n, "vendorID") || !T::get(n, "productID")) return false;
        const char *bytes[] = {"deviceClass", "deviceSubClass", "deviceProtocol", "Attributes"};
        for (const char *key : bytes) {
            N v = T::get(n, key);
            if (v) { if (!number(v, 0, 255)) return false; ++recognized; }
        }
        N mps = T::get(n, "MPS0");
        if (mps) {
            long long v = 0;
            if (!T::number(mps, v) || (v != 8 && v != 16 && v != 32 && v != 64)) return false;
            ++recognized;
        }
        N power = T::get(n, "MaxPower");
        if (power) { if (!number(power, -1, 255)) return false; ++recognized; }
        const char *strings[] = {"manufacturerString", "productString", "serialNumber"};
        for (const char *key : strings) {
            N v = T::get(n, key);
            if (v) { if (!text(v, 126)) return false; ++recognized; }
        }
        N multi = T::get(n, "AllowMultipleCreates");
        if (multi) { if (!T::boolean(multi)) return false; ++recognized; }
        N configs = T::get(n, "ConfigurationDescriptors");
        if (!T::array(configs) || T::count(configs) < 1 || T::count(configs) > 4) return false;
        for (unsigned i = 0; i < T::count(configs); ++i)
            if (!configuration(T::at(configs, i))) return false;
        return T::count(n) == recognized + 1;
    }
};
