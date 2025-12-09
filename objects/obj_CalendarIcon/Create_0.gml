
// safety, in case this runs before GameController
if (!variable_global_exists("apps_unlocked")) {
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
}

// assign sprites
spr_locked   = spr_Hacked_CalendarIcon; // locked version
spr_unlocked = spr_CalendarIcon;        // normal version

// initial sprite based on unlock state
sprite_index = global.apps_unlocked.Calendar ? spr_unlocked : spr_locked;
