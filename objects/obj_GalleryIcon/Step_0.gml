var exists   = variable_struct_exists(global.apps_unlocked, app_key);
//var unlocked = exists ? variable_struct_get(global.apps_unlocked, app_key) : false;

var unlocked = false;

if (variable_struct_exists(global.apps_unlocked, "Gallery"))
{
    unlocked = global.apps_unlocked.RecycleBin;
}
//DELETE FOR FINAL--------------------------------------
if (unlocked)
{
    sprite_index = spr_GalleryIcon; 
}
else
{
    sprite_index = spr_Hacked_GalleryIcon;  
}
