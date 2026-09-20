// Experimental access probe, not a USB receiver. Nothing runs automatically.
// A root-only, one-shot command republishes the provider's existing descriptor.
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

class SmartBoxUSBProbe : public IOService {
    OSDeclareDefaultStructors(SmartBoxUSBProbe)
    IOLock *lock = nullptr;
    IOWorkLoop *loop = nullptr;
    IOTimerEventSource *timer = nullptr;
    IOService *controller = nullptr;
    bool timerAdded = false;
    ProbePolicy policy;
    bool targetMatches(IOService *p) const;
    bool ready();
    OSDictionary *copyState();
    void cleanup();
    IOReturn performProbe();
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
    // Also checked by the personality. Runtime guard rejects other hardware
    // and ports even if someone edits only the bundle's matching dictionary.
    if (!p || strcmp(p->getMetaClass()->getClassName(), "AppleT8142USBXDCI")) return false;
    IORegistryEntry *parent = p->getParentEntry(gIOServicePlane);
    return parent && !strcmp(parent->getName(), "usb-drd1");
}

OSDictionary *SmartBoxUSBProbe::copyState() {
    OSObject *value = controller->copyProperty("CurrentState");
    setProperty("ProbeStateObjectType", value ? value->getMetaClass()->getClassName() : "missing");
    OSDictionary *state = OSDynamicCast(OSDictionary, value);
    if (state) return state; // copyProperty already retained it.
    // Registry properties may be lazy serializers. Materialize only this
    // trusted controller property, never caller-supplied XML, and cap parsing.
    if (value && !strcmp(value->getMetaClass()->getClassName(), "OSSerializer")) {
        OSSerialize *xml = OSSerialize::withCapacity(2048);
        if (xml && value->serialize(xml) && xml->getLength() > 0 && xml->getLength() <= 16384) {
            OSObject *decoded = OSUnserializeXML(xml->text());
            state = OSDynamicCast(OSDictionary, decoded);
            if (decoded && !state) decoded->release();
        }
        if (xml) xml->release();
    }
    if (value) value->release();
    return state;
}

bool SmartBoxUSBProbe::ready() {
    if (!targetMatches(controller)) { setProperty("ProbeReadiness", "wrong-controller"); return false; }
    if (controller->isInactive()) { setProperty("ProbeReadiness", "inactive-controller"); return false; }
    OSDictionary *state = copyState();
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
    controller = provider;
    controller->retain();
    loop = IOWorkLoop::workLoop();
    timer = IOTimerEventSource::timerEventSource(this, &SmartBoxUSBProbe::execute);
    if (!loop || !timer || loop->addEventSource(timer) != kIOReturnSuccess) {
        cleanup(); IOService::stop(provider); return false;
    }
    timerAdded = true;
    if (!setProperty("ProbeVersion", "2") || !setProperty("ProbeCompleted", kOSBooleanFalse)) {
        cleanup(); IOService::stop(provider); return false;
    }
    registerService();
    return true;
}

void SmartBoxUSBProbe::cleanup() {
    if (lock) { IOLockLock(lock); policy.stop(); IOLockUnlock(lock); }
    // Do not hold lock while waiting for the callback: it takes the same lock.
    if (timer) {
        timer->cancelTimeout();
        if (timerAdded) loop->removeEventSource(timer);
        timerAdded = false;
        timer->release(); timer = nullptr;
    }
    if (loop) { loop->release(); loop = nullptr; }
    if (controller) { controller->release(); controller = nullptr; }
}

void SmartBoxUSBProbe::stop(IOService *provider) {
    cleanup();
    IOService::stop(provider);
}

void SmartBoxUSBProbe::free() {
    cleanup();
    if (lock) { IOLockFree(lock); lock = nullptr; }
    IOService::free();
}

IOReturn SmartBoxUSBProbe::setProperties(OSObject *object) {
    // Never take arbitrary descriptors, pointers, commands, or port names.
    if (IOUserClient::clientHasPrivilege(current_task(), kIOClientPrivilegeAdministrator) != kIOReturnSuccess)
        return kIOReturnNotPrivileged;
    OSDictionary *dict = OSDynamicCast(OSDictionary, object);
    bool exact = dict && dict->getCount() == 1 && dict->getObject("CheckConfigurationAccess") == kOSBooleanTrue;
    IOLockLock(lock);
    ProbePolicy::Result decision = policy.request(true, exact, !policy.stopping && ready());
    IOReturn result = kIOReturnSuccess;
    switch (decision) {
        case ProbePolicy::BadCommand: result = kIOReturnBadArgument; break;
        case ProbePolicy::NotReady: result = kIOReturnNotReady; break;
        case ProbePolicy::AlreadyUsed: result = kIOReturnExclusiveAccess; break;
        case ProbePolicy::Denied: result = kIOReturnNotPrivileged; break;
        case ProbePolicy::Allow:
            result = timer->setTimeoutMS(1);
            if (result != kIOReturnSuccess) policy.pending = false;
            break;
    }
    IOLockUnlock(lock);
    return result;
}

IOReturn SmartBoxUSBProbe::performProbe() {
    OSObject *value = controller->copyProperty("DeviceDescription");
    OSDictionary *original = OSDynamicCast(OSDictionary, value);
    OSArray *configs = original ? OSDynamicCast(OSArray, original->getObject("ConfigurationDescriptors")) : nullptr;
    if (!configs || !configs->getCount()) { if (value) value->release(); return kIOReturnNotReady; }
    // Retain the current descriptor rather than allowing caller-supplied data.
    // We never edit it. The provider consumes it synchronously.
    OSDictionary *command = OSDictionary::withCapacity(2);
    OSString *name = OSString::withCString("SetDeviceConfiguration");
    IOReturn result = kIOReturnNoMemory;
    if (command && name && command->setObject("USBDeviceCommand", name) &&
        command->setObject("USBDeviceCommandParameter", original)) {
        // Recheck immediately before the private call. No host-role request.
        result = ready() ? controller->setProperties(command) : kIOReturnNotReady;
    }
    if (name) name->release();
    if (command) command->release();
    value->release();
    return result;
}

void SmartBoxUSBProbe::execute(OSObject *owner, IOTimerEventSource *) {
    auto *self = OSDynamicCast(SmartBoxUSBProbe, owner);
    if (!self) return;
    IOLockLock(self->lock);
    IOReturn result = self->policy.begin(self->ready()) ? self->performProbe() : kIOReturnNotReady;
    // Completion is published only after the underlying result is available.
    if (self->setProperty("ProbeResult", (uint64_t)(uint32_t)result, 32))
        self->setProperty("ProbeCompleted", kOSBooleanTrue);
    IOLockUnlock(self->lock);
}
