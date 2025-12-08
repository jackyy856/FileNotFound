/// obj_HackerMsgrIcon.Step

// If globals or sprite vars somehow aren't defined yet, bail safely
if (!variable_global_exists("hacker_unread")) exit;
if (!variable_instance_exists(id, "sprite_normal")) exit;
if (!variable_instance_exists(id, "sprite_unread")) exit;

// Choose sprite based on unread flag
if (global.hacker_unread)
{
    sprite_index = sprite_unread;
}
else
{
    sprite_index = sprite_normal;
}

var unread_now = global.hacker_unread;

if (unread_now && !unread_prev)
{
    audio_play_sound(sfx_meow3, 1, false);
}

unread_prev = unread_now;