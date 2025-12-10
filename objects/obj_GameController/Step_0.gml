
// delayed hacker reaction after key #1
if (global.hacker_key1_delay > 0) {
    global.hacker_key1_delay--;

    if (global.hacker_key1_delay <= 0) {
        global.hacker_key1_delay = -1;

        // only fire if not already pending
        if (!global.hacker_key1_hint_pending) {
            global.hacker_key1_hint_pending = true;
            if (variable_global_exists("hacker_unread")) {
                global.hacker_unread = true;
            }
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

// Red key (Gallery) delayed ping
if (global.hacker_key2_delay > 0) {
    global.hacker_key2_delay--;
    if (global.hacker_key2_delay <= 0) {
        global.hacker_key2_delay = -1;
        if (!global.hacker_key2_hint_pending) {
            global.hacker_key2_hint_pending = true;
            if (variable_global_exists("hacker_unread")) {
                global.hacker_unread = true;
            }
        }
    }
}

// Recycle Bin transcript follow-up (20s after first open)
if (global.hacker_transcript_follow_timer > 0) {
    global.hacker_transcript_follow_timer--;
    if (global.hacker_transcript_follow_timer <= 0) {
        global.hacker_transcript_follow_timer = -1;
        global.hacker_transcript_follow_pending = true;
        if (variable_global_exists("hacker_unread")) {
            global.hacker_unread = true;
        }
    }
}

// Final key (key #3) delayed ping
if (global.hacker_key3_delay > 0) {
    global.hacker_key3_delay--;
    if (global.hacker_key3_delay <= 0) {
        global.hacker_key3_delay = -1;
        if (!global.hacker_key3_hint_pending) {
            global.hacker_key3_hint_pending = true;
            if (variable_global_exists("hacker_unread")) {
                global.hacker_unread = true;
            }
        }
    }
}

// iWork open timer (after first open)
if (global.iwork_opened_once && global.hacker_iwork_follow_timer > 0) {
    global.hacker_iwork_follow_timer--;
    if (global.hacker_iwork_follow_timer <= 0) {
        global.hacker_iwork_follow_timer = -1;
        global.hacker_iwork_follow_pending = true;
        if (variable_global_exists("hacker_unread")) {
            global.hacker_unread = true;
        }
        global.hacker_iwork_unread_queued = false;
    }
}
