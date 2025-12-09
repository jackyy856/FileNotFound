app_key = "Files";          // matches key in global.apps_unlocked
app_obj = obj_FilesApp;     // icon opens files app obj

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

spr_locked   = spr_Hacked_FilesIcon;
spr_unlocked = spr_FilesIcon;

sprite_index = global.apps_unlocked.Files ? spr_unlocked : spr_locked;
