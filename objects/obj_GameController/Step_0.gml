
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

// Dove email timers (15s post-unlock, 30s follow-up)
if (global.hacker_dove_unlock_timer > 0) {
    global.hacker_dove_unlock_timer--;
    if (global.hacker_dove_unlock_timer <= 0) {
        global.hacker_dove_unlock_timer = -1;
        global.hacker_dove_unlock_pending = true;
        if (variable_global_exists("hacker_unread")) global.hacker_unread = true;
    }
}

if (global.hacker_dove_follow_timer > 0) {
    global.hacker_dove_follow_timer--;
    if (global.hacker_dove_follow_timer <= 0) {
        global.hacker_dove_follow_timer = -1;
        global.hacker_dove_follow_pending = true;
        if (variable_global_exists("hacker_unread")) global.hacker_unread = true;
    }
}
