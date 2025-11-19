/// Global app unlocks and shared globals ONLY.
/// No auto-opening of any apps.

global.apps_unlocked = 
{
    Email      : true,
    HackerMsgr : true,
    Files      : true,
    Gallery    : true,
    RecycleBin : true,
    Notes      : true,
    Slack      : true   // Slack behaves like any other app now
};

// Global z-order counter for app windows
if (!variable_global_exists("window_z_next")) {
    global.window_z_next = -10;
}
