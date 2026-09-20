#pragma once
// All methods are called under the driver's lock. Shared with host-side tests.
struct ProbePolicy {
    enum Result { Allow, Denied, BadCommand, NotReady, AlreadyUsed };
    bool stopping = false;
    bool used = false;
    bool pending = false;
    Result request(bool admin, bool exactCommand, bool ready) {
        if (!admin) return Denied;
        if (!exactCommand) return BadCommand;
        if (stopping || !ready) return NotReady;
        if (used) return AlreadyUsed;
        used = pending = true;
        return Allow;
    }
    bool begin(bool ready) {
        bool run = pending && !stopping && ready;
        pending = false;
        return run;
    }
    void stop() { stopping = true; pending = false; }
};
