/// Global app unlocks and shared globals ONLY.
audio_play_sound(bg_mus_intro, 1, true);

global.apps_unlocked = {
    Email      : true,
    HackerMsgr : true,
	Calendar   : false,
    Files      : false,
    Gallery    : false,
    RecycleBin : false,
    Notes      : true,
    Slack      : false   
};

// Story progression keys for the desktop key slots
// [ key1_from_email, key2_future, key3_future ]
if (!variable_global_exists("story_keys")) {
    global.story_keys = [false, false, false];
}

// Global z-order counter for app windows
if (!variable_global_exists("window_z_next")) {
    global.window_z_next = -10;
}

global.hacker_unread = true;

// --- Hacker key #1 hint timing ---
if (!variable_global_exists("hacker_key1_delay")) {
    global.hacker_key1_delay = -1;
}

//hacker hint state for key1
if (!variable_global_exists("hacker_key1_hint_pending")) {
    global.hacker_key1_hint_pending = false;
}
if (!variable_global_exists("hacker_key1_hint_fired")) {
    global.hacker_key1_hint_fired = false;
}

// hacker hint state for key2 (after red key from Gallery)
if (!variable_global_exists("hacker_key2_hint_pending")) {
    global.hacker_key2_hint_pending = false;
}

// Dove flow guards
if (!variable_global_exists("hacker_dove_hint_pending"))    global.hacker_dove_hint_pending    = false;
if (!variable_global_exists("hacker_dove_hint_fired"))      global.hacker_dove_hint_fired      = false;
if (!variable_global_exists("hacker_dove_unlock_pending"))  global.hacker_dove_unlock_pending  = false;
if (!variable_global_exists("hacker_dove_follow_pending"))  global.hacker_dove_follow_pending  = false;
if (!variable_global_exists("hacker_dove_unlock_timer"))    global.hacker_dove_unlock_timer    = -1;
if (!variable_global_exists("hacker_dove_follow_timer"))    global.hacker_dove_follow_timer    = -1;
if (!variable_global_exists("calendar_opened_once"))        global.calendar_opened_once        = false;
if (!variable_global_exists("hacker_dove_calendar_pending")) global.hacker_dove_calendar_pending = false;
if (!variable_global_exists("hacker_dove_calendar_fired"))   global.hacker_dove_calendar_fired   = false;
if (!variable_global_exists("dove_unlocked"))               global.dove_unlocked               = false;
if (!variable_global_exists("iwork_opened_once"))           global.iwork_opened_once           = false;
if (!variable_global_exists("hacker_iwork_follow_timer"))   global.hacker_iwork_follow_timer   = -1;
if (!variable_global_exists("hacker_iwork_follow_pending")) global.hacker_iwork_follow_pending = false;
if (!variable_global_exists("hacker_iwork_unread_queued"))  global.hacker_iwork_unread_queued  = false;

// one-time desktop notification meow ---
if (!variable_global_exists("desktop_meow_played")) {
    global.desktop_meow_played = false;
}

if (!global.desktop_meow_played) {
    audio_play_sound(sfx_meow3, 1, false);
    global.desktop_meow_played = true;
}