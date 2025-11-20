/// obj_KeySlots - Create

// three keys: 0 = green, 1 = red, 2 = golden
slot_count = 3;

// base sprites (outline)
slot_spr_base = array_create(slot_count);
slot_spr_base[0] = spr_green_key;
slot_spr_base[1] = spr_red_key;
slot_spr_base[2] = spr_golden_key;

// glow sprites (collected)
slot_spr_glow = array_create(slot_count);
slot_spr_glow[0] = spr_green_glow_key;
slot_spr_glow[1] = spr_red_glow_key;
slot_spr_glow[2] = spr_golden_glow_key;

// ensure global key array exists
if (!variable_global_exists("key_collected")) {
    global.key_collected = array_create(slot_count, false);
}

// precompute gui positions (far right center)
var gw = display_get_gui_width();
var gh = display_get_gui_height();

slot_pos = array_create(slot_count);

var spacing = 80;
var total_h = (slot_count - 1) * spacing;
var start_y = gh * 0.5 - total_h * 0.5;
var base_x  = gw - 80; // far right-ish

for (var i = 0; i < slot_count; i++) {
    slot_pos[i] = { x: base_x, y: start_y + i * spacing };
}
