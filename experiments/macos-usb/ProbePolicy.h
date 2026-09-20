#pragma once
// All methods are called under the driver's lock. Shared with host-side tests.
struct ProbePolicy {
    enum Result { Allow, Denied, BadCommand, NotReady, Busy, Stale };
    bool stopping = false;
    bool pending = false;
    bool running = false;
    unsigned long long lastID = 0;
    Result request(bool admin, bool exactCommand, bool ready, unsigned long long id) {
        if (!admin) return Denied;
        if (!exactCommand || !id) return BadCommand;
        if (stopping || !ready) return NotReady;
        if (pending || running) return Busy;
        if (id <= lastID) return Stale;
        lastID = id;
        pending = true;
        return Allow;
    }
    bool begin(bool ready) {
        bool run = pending && !stopping && ready;
        pending = false;
        running = run;
        return run;
    }
    void finish() { pending = running = false; }
    void stop() { stopping = true; pending = false; }
};
