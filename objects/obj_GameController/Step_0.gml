
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

//DELETE FOR REAL SUBMISSION -----------------------------
/// Auto-unlock gallery, slack, recycle bin when Calendar is unlocked

if (variable_struct_exists(global.apps_unlocked, "Calendar"))
{
    if (global.apps_unlocked.Calendar)
    {
        // Mirror Calendar's unlock state
        global.apps_unlocked.Gallery    = true;
        global.apps_unlocked.Slack      = true;
        global.apps_unlocked.RecycleBin = true;
    }
}
