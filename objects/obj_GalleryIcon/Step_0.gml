var unlocked = (variable_global_exists("apps_unlocked") && is_struct(global.apps_unlocked) && variable_struct_exists(global.apps_unlocked, app_key))
    ? variable_struct_get(global.apps_unlocked, app_key)
    : false;

sprite_index = unlocked ? spr_GalleryIcon : spr_Hacked_GalleryIcon;
