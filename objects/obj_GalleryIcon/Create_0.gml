
app_key = "Gallery";
app_obj = obj_GalleryApp;


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

spr_locked   = spr_Hacked_GalleryIcon;
spr_unlocked = spr_GalleryIcon;

sprite_index = global.apps_unlocked.Gallery ? spr_unlocked : spr_locked;
