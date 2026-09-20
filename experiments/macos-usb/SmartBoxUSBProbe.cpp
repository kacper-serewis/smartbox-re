// Scoped, root-triggered USB configuration bridge. Nothing runs on load.
#include <IOKit/IOLib.h>
#include <IOKit/IOService.h>
#include <IOKit/IOUserClient.h>
#include <IOKit/IOWorkLoop.h>
#include <IOKit/IOTimerEventSource.h>
#include <libkern/c++/OSContainers.h>
#include <libkern/c++/OSSerialize.h>
#include <libkern/c++/OSUnserialize.h>
#include <kern/task.h>
#include "ProbePolicy.h"
#include "DescriptorValidation.h"

struct KernelNodes {
    using Node = OSObject *;
    static bool dict(Node n) { return OSDynamicCast(OSDictionary, n); }
    static bool array(Node n) { return OSDynamicCast(OSArray, n); }
    static unsigned count(Node n) {
        OSCollection *c = OSDynamicCast(OSCollection, n); return c ? c->getCount() : 0;
    }
    static Node get(Node n, const char *key) {
        OSDictionary *d = OSDynamicCast(OSDictionary, n); return d ? d->getObject(key) : nullptr;
    }
    static Node at(Node n, unsigned i) {
        OSArray *a = OSDynamicCast(OSArray, n); return a ? a->getObject(i) : nullptr;
    }
    static const char *string(Node n) {
        OSString *s = OSDynamicCast(OSString, n);
        // Reject embedded NULs, including strings whose suffix the schema would miss.
        return s && strlen(s->getCStringNoCopy()) == s->getLength() ? s->getCStringNoCopy() : nullptr;
    }
    static bool number(Node n, long long &v) {
        OSNumber *num = OSDynamicCast(OSNumber, n);
        if (!num) return false;
        v = (long long)num->unsigned64BitValue(); return true;
    }
    static bool boolean(Node n) { return n == kOSBooleanTrue || n == kOSBooleanFalse; }
};

class SmartBoxUSBProbe : public IOService {
    OSDeclareDefaultStructors(SmartBoxUSBProbe)
    enum Operation { Invalid, Check, Republish, Publish, Restore, ForceOffBus, ReleaseOffBus };
    IOLock *lock = nullptr;
    IOWorkLoop *loop = nullptr;
    IOTimerEventSource *timer = nullptr;
    IOService *controller = nullptr;
    OSDictionary *original = nullptr;
    OSDictionary *pendingDescription = nullptr;
    Operation operation = Invalid;
    bool timerAdded = false;
    bool touched = false;
    bool forcedOff = false;
    ProbePolicy policy;
    bool targetMatches(IOService *p) const;
    bool ready(Operation op);
    OSDictionary *copyDictionaryProperty(const char *key);
    OSDictionary *copyDescription(OSDictionary *source);
    static Operation parseOperation(OSObject *name);
    void cleanup();
    IOReturn perform();
    IOReturn send(const char *command, OSObject *parameter);
    void complete(IOReturn result);
    static void execute(OSObject *owner, IOTimerEventSource *sender);
public:
    bool init(OSDictionary *dict = nullptr) override;
    bool start(IOService *provider) override;
    void stop(IOService *provider) override;
    void free() override;
    IOReturn setProperties(OSObject *object) override;
};
OSDefineMetaClassAndStructors(SmartBoxUSBProbe, IOService)

bool SmartBoxUSBProbe::targetMatches(IOService *p) const {
    if (!p || strcmp(p->getMetaClass()->getClassName(), "AppleT8142USBXDCI")) return false;
    IORegistryEntry *parent = p->getParentEntry(gIOServicePlane);
    return parent && !strcmp(parent->getName(), "usb-drd1");
}

OSDictionary *SmartBoxUSBProbe::copyDictionaryProperty(const char *key) {
    OSObject *value = controller->copyProperty(key);
    if (!strcmp(key, "CurrentState"))
        setProperty("ProbeStateObjectType", value ? value->getMetaClass()->getClassName() : "missing");
    OSDictionary *dict = OSDynamicCast(OSDictionary, value);
    if (dict) return dict;
    // Materialize only the controller's own bounded lazy properties.
    if (value && !strcmp(value->getMetaClass()->getClassName(), "OSSerializer")) {
        OSSerialize *xml = OSSerialize::withCapacity(2048);
        if (xml && value->serialize(xml) && xml->getLength() > 0 && xml->getLength() <= 16384) {
            OSObject *decoded = OSUnserializeXML(xml->text());
            dict = OSDynamicCast(OSDictionary, decoded);
            if (decoded && !dict) decoded->release();
        }
        if (xml) xml->release();
    }
    if (value) value->release();
    return dict;
}

OSDictionary *SmartBoxUSBProbe::copyDescription(OSDictionary *source) {
    if (!source) return nullptr;
    OSCollection *copy = source->copyCollection();
    OSDictionary *dict = OSDynamicCast(OSDictionary, copy);
    if (copy && !dict) copy->release();
    return dict;
}

SmartBoxUSBProbe::Operation SmartBoxUSBProbe::parseOperation(OSObject *name) {
    OSString *s = OSDynamicCast(OSString, name);
    if (!s) return Invalid;
    if (s->isEqualTo("Check")) return Check;
    if (s->isEqualTo("Republish")) return Republish;
    if (s->isEqualTo("Publish")) return Publish;
    if (s->isEqualTo("Restore")) return Restore;
    if (s->isEqualTo("ForceOffBus")) return ForceOffBus;
    if (s->isEqualTo("ReleaseOffBus")) return ReleaseOffBus;
    return Invalid;
}

bool SmartBoxUSBProbe::ready(Operation op) {
    if (!targetMatches(controller)) { setProperty("ProbeReadiness", "wrong-controller"); return false; }
    if (controller->isInactive()) { setProperty("ProbeReadiness", "inactive-controller"); return false; }
    // Configuration changes require disconnected device mode. Explicit bus
    // controls may disconnect our experiment or undo our own force-off.
    if (op == ForceOffBus && touched) { setProperty("ProbeReadiness", "ready-to-disconnect"); return true; }
    if (op == ReleaseOffBus) {
        // Undo only our own force-off, even if the published state lags behind.
        setProperty("ProbeReadiness", forcedOff ? "ready-to-release" : "not-forced-off");
        return forcedOff;
    }
    OSDictionary *state = copyDictionaryProperty("CurrentState");
    OSString *name = state ? OSDynamicCast(OSString, state->getObject("DeviceState")) : nullptr;
    bool ok = name && name->isEqualTo("Disconnected") && state->getObject("OnBus") == kOSBooleanFalse;
    setProperty("ProbeReadiness", !state ? "state-not-dictionary" : !name ? "missing-device-state" :
                !name->isEqualTo("Disconnected") ? "device-connected" :
                state->getObject("OnBus") != kOSBooleanFalse ? "on-bus-or-unknown" : "ready");
    if (state) state->release();
    return ok;
}

bool SmartBoxUSBProbe::init(OSDictionary *dict) {
    if (!IOService::init(dict)) return false;
    policy = ProbePolicy{};
    lock = IOLockAlloc();
    return lock != nullptr;
}

bool SmartBoxUSBProbe::start(IOService *provider) {
    if (!targetMatches(provider) || !IOService::start(provider)) return false;
    controller = provider; controller->retain();
    loop = IOWorkLoop::workLoop();
    timer = IOTimerEventSource::timerEventSource(this, &SmartBoxUSBProbe::execute);
    if (!loop || !timer || loop->addEventSource(timer) != kIOReturnSuccess) {
        cleanup(); IOService::stop(provider); return false;
    }
    timerAdded = true;
    if (!setProperty("ProbeVersion", "3") || !setProperty("ProbeCompleted", kOSBooleanFalse) ||
        !setProperty("ProbeLastRequestID", (uint64_t)0, 64)) {
        cleanup(); IOService::stop(provider); return false;
    }
    registerService();
    return true;
}

void SmartBoxUSBProbe::cleanup() {
    if (lock) { IOLockLock(lock); policy.stop(); IOLockUnlock(lock); }
    // Never hold our lock while removing the event source: callback takes it.
    if (timer) {
        timer->cancelTimeout();
        if (timerAdded && loop) loop->removeEventSource(timer);
        timerAdded = false; timer->release(); timer = nullptr;
    }
    if (pendingDescription) { pendingDescription->release(); pendingDescription = nullptr; }
    if (original) { original->release(); original = nullptr; }
    if (loop) { loop->release(); loop = nullptr; }
    if (controller) { controller->release(); controller = nullptr; }
}
void SmartBoxUSBProbe::stop(IOService *provider) { cleanup(); IOService::stop(provider); }
void SmartBoxUSBProbe::free() {
    cleanup();
    if (lock) { IOLockFree(lock); lock = nullptr; }
    IOService::free();
}

IOReturn SmartBoxUSBProbe::setProperties(OSObject *object) {
    if (IOUserClient::clientHasPrivilege(current_task(), kIOClientPrivilegeAdministrator) != kIOReturnSuccess)
        return kIOReturnNotPrivileged;
    OSDictionary *dict = OSDynamicCast(OSDictionary, object);
    Operation op = dict ? parseOperation(dict->getObject("Command")) : Invalid;
    OSNumber *id = dict ? OSDynamicCast(OSNumber, dict->getObject("RequestID")) : nullptr;
    OSDictionary *desc = dict ? OSDynamicCast(OSDictionary, dict->getObject("Description")) : nullptr;
    bool valid = op != Invalid && id && dict->getCount() == (op == Publish ? 3U : 2U) &&
        (op != Publish || DescriptorValidation<KernelNodes>::valid(desc));
    if (!valid || !id->unsigned64BitValue() || id->unsigned64BitValue() > 0x7fffffffffffffffULL)
        return kIOReturnBadArgument;
    IOLockLock(lock);
    ProbePolicy::Result decision = policy.request(true, valid, !policy.stopping && ready(op), id->unsigned64BitValue());
    IOReturn result = kIOReturnSuccess;
    switch (decision) {
        case ProbePolicy::BadCommand: result = kIOReturnBadArgument; break;
        case ProbePolicy::NotReady: result = kIOReturnNotReady; break;
        case ProbePolicy::Busy: result = kIOReturnBusy; break;
        case ProbePolicy::Stale: result = kIOReturnNotPermitted; break;
        case ProbePolicy::Denied: result = kIOReturnNotPrivileged; break;
        case ProbePolicy::Allow:
            operation = op;
            pendingDescription = desc ? copyDescription(desc) : nullptr;
            if (desc && !pendingDescription) result = kIOReturnNoMemory;
            if (!setProperty("ProbeCompleted", kOSBooleanFalse) ||
                !setProperty("ProbeLastRequestID", (uint64_t)policy.lastID, 64) ||
                !setProperty("ProbeOperation", dict->getObject("Command"))) result = kIOReturnNoMemory;
            if (result == kIOReturnSuccess) result = timer->setTimeoutMS(1);
            if (result != kIOReturnSuccess) complete(result);
            break;
    }
    IOLockUnlock(lock);
    return result;
}

IOReturn SmartBoxUSBProbe::send(const char *commandName, OSObject *parameter) {
    OSDictionary *command = OSDictionary::withCapacity(2);
    OSString *name = OSString::withCString(commandName);
    IOReturn result = kIOReturnNoMemory;
    if (command && name && command->setObject("USBDeviceCommand", name) &&
        (!parameter || command->setObject("USBDeviceCommandParameter", parameter)))
        result = controller->setProperties(command);
    if (name) name->release();
    if (command) command->release();
    return result;
}

IOReturn SmartBoxUSBProbe::perform() {
    if (operation == ForceOffBus || operation == ReleaseOffBus) {
        IOReturn result = send(operation == ForceOffBus ? "ForceOffBusEnable" : "ForceOffBusDisable", nullptr);
        if (result == kIOReturnSuccess) forcedOff = operation == ForceOffBus;
        setProperty("ProbeForcedOffBus", forcedOff);
        return result;
    }
    OSDictionary *current = copyDictionaryProperty("DeviceDescription");
    OSArray *configs = current ? OSDynamicCast(OSArray, current->getObject("ConfigurationDescriptors")) : nullptr;
    // A failed publication may remove the current description. Restoration
    // must still be able to use the snapshot captured before that attempt.
    if ((!configs || !configs->getCount()) && !(operation == Restore && original)) {
        if (current) current->release(); return kIOReturnNotReady;
    }
    // Preserve a deep copy before our first configuration attempt, even a failed one.
    if (!original) {
        original = copyDescription(current);
        if (!original || !setProperty("ProbeOriginalDescription", original)) {
            if (original) { original->release(); original = nullptr; }
            if (current) current->release(); return kIOReturnNoMemory;
        }
    }
    OSDictionary *source = operation == Publish ? pendingDescription : operation == Restore ? original : current;
    OSDictionary *description = copyDescription(source);
    if (current) current->release();
    if (!description) return kIOReturnNoMemory;
    IOReturn result = kIOReturnNoMemory;
    // Check deliberately keeps the old failing behavior available for comparison.
    if (operation == Check || description->setObject("AllowMultipleCreates", kOSBooleanTrue)) {
        if (ready(operation)) {
            // Failed provider calls may already have side effects: allow explicit recovery.
            touched = true;
            result = send("SetDeviceConfiguration", description);
        } else result = kIOReturnNotReady;
    }
    description->release();
    return result;
}

void SmartBoxUSBProbe::complete(IOReturn result) {
    if (pendingDescription) { pendingDescription->release(); pendingDescription = nullptr; }
    policy.finish();
    // Client matches the completion ID, so an old result cannot satisfy a new request.
    if (setProperty("ProbeResult", (uint64_t)(uint32_t)result, 32) &&
        setProperty("ProbeCompletedRequestID", (uint64_t)policy.lastID, 64))
        setProperty("ProbeCompleted", kOSBooleanTrue);
}

void SmartBoxUSBProbe::execute(OSObject *owner, IOTimerEventSource *) {
    auto *self = OSDynamicCast(SmartBoxUSBProbe, owner);
    if (!self) return;
    IOLockLock(self->lock);
    IOReturn result = self->policy.begin(self->ready(self->operation)) ? self->perform() : kIOReturnNotReady;
    self->complete(result);
    IOLockUnlock(self->lock);
}
