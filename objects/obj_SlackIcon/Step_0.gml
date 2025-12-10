/// obj_SlackIcon - Step
var unlocked = (variable_global_exists("apps_unlocked") && is_struct(global.apps_unlocked) && variable_struct_exists(global.apps_unlocked, app_key))
    ? variable_struct_get(global.apps_unlocked, app_key)
    : false;

var target = unlocked ? spr_unlocked : spr_locked;
if (sprite_index != target) sprite_index = target;
