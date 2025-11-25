/// obj_KeySlots - Draw GUI

// safety: if the array was nuked somewhere, re-create it
if (!variable_global_exists("key_collected")) {
    global.key_collected = array_create(slot_count, false);
}

draw_set_alpha(1);

for (var i = 0; i < slot_count; i++) {
    var pos = slot_pos[i];

    var spr_base = slot_spr_base[i];
    var spr_glow = slot_spr_glow[i];

    var spr = global.key_collected[i] ? spr_glow : spr_base;

    if (spr != -1) {
        var sw = sprite_get_width(spr);
        var sh = sprite_get_height(spr);

        // scale down to a nice height (e.g. 64px)
        var desired_h = 64;
        var sc = (sh > 0) ? (desired_h / sh) : 1;

        draw_sprite_ext(spr, 0, pos.x, pos.y, sc, sc, 0, c_white, 1);
    }
}

// don't leave weird state
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
