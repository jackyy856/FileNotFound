/// obj_GameController - Step: global timers, story progression

// delayed hacker reaction after key #1
if (global.hacker_key1_delay > 0) {
    global.hacker_key1_delay--;

    if (global.hacker_key1_delay <= 0) {
        global.hacker_key1_delay = -1;

        // only fire if not already pending
        if (!global.hacker_key1_hint_pending) {
            global.hacker_key1_hint_pending = true;
        }
    }
}
