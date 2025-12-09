/// Slack desktop icon setup (same pattern as other app icons)

app_key = "Slack";       // key used in global.apps_unlocked
app_obj = obj_SlackApp;  // app window object for this icon

// safety, in case controller hasn’t run yet
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

spr_locked   = spr_Hacked_iWorkIcon;
spr_unlocked = spr_iWorkIcon;

sprite_index = global.apps_unlocked.Slack ? spr_unlocked : spr_locked;

