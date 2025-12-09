/// obj_SlackIcon - Step
var target = global.apps_unlocked.Slack ? spr_unlocked : spr_locked;
if (sprite_index != target) sprite_index = target;

var unlocked = false;

if (variable_struct_exists(global.apps_unlocked, "Slack"))
{
    unlocked = global.apps_unlocked.RecycleBin;
}
//DELETE FOR FINAL--------------------------------------
if (unlocked)
{
    sprite_index = spr_iWorkIcon; 
}
else
{
    sprite_index = spr_Hacked_iWorkIcon;  
}
