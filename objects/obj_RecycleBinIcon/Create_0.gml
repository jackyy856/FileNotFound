app_key = "RecycleBin";          // matches key in global.apps_unlocked
app_obj = obj_RecycleBinApp;     // icon opens email app obj


if (!variable_global_exists("apps_unlocked")) {
    global.apps_unlocked = {
        Email      : true,
        HackerMsgr : true,
        Calendar   : false,
        Files      : false,
        Gallery    : false,
        RecycleBin : false,
        Notes      : false,
        Slack      : false
    };
}

spr_locked   = spr_Hacked_RecycleBinIcon;
spr_unlocked = spr_RecycleBinIcon;

sprite_index = global.apps_unlocked.RecycleBin ? spr_unlocked : spr_locked;
