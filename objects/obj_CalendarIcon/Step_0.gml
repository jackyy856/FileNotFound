/// Keep sprite in sync with unlock state
var target = global.apps_unlocked.Calendar ? spr_unlocked : spr_locked;
if (sprite_index != target) {
    sprite_index = target;
}
