
var target = global.apps_unlocked.Files ? spr_unlocked : spr_locked;
if (sprite_index != target) sprite_index = target;


/*//DELETE FOR FINAL --------------------------------
var exists   = variable_struct_exists(global.apps_unlocked, app_key);
var unlocked = exists ? variable_struct_get(global.apps_unlocked, app_key) : false;


if (unlocked)
{
    sprite_index = spr_FilesIcon; 
}
else
{
    sprite_index = spr_Hacked_FilesIcon;   // replace with your locked/greyed sprite
}
