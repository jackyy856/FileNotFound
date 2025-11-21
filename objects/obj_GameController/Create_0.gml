/// Global app unlocks and shared globals ONLY.
/// No auto-opening of any apps.

global.apps_unlocked = {
    Email      : true,
    HackerMsgr : true,
    Files      : true,
    Gallery    : true,
    RecycleBin : true,
    Notes      : true,
    Slack      : true   // Slack behaves like any other app now
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
