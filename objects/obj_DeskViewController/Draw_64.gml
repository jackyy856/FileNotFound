/// obj_DeskViewController – Draw GUI
/// Renders current background art and (optionally) debug overlays + prompt bar.

// Current background
var spr_id = -1;
if (state == DeskState.DESK)       spr_id = sprDesk;
if (state == DeskState.EMAIL_LIST) spr_id = sprEmailList;
if (state == DeskState.EMAIL_OPEN) spr_id = sprEmailOpen;
if (spr_id != -1) draw_sprite_stretched(spr_id, 0, 0, 0, 1920, 1080);

// Prompt bar (bottom)
if (dialog_timer > 0 && dialog_text != "") {
    var m = 24, bar_h = 92;
    var y1 = 1080 - bar_h - m, y2 = 1080 - m;

    draw_set_alpha(0.92);
    draw_set_color(make_color_rgb(48,18,82));
    draw_roundrect(m, y1, 1920-m, y2, false);
    draw_set_alpha(1);

    draw_set_color(make_color_rgb(156,90,255));
    draw_rectangle(m, y1, 1920-m, y1+3, false);

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_ext(m+24, y1+22, dialog_text, 16, 1840);
}

// ---- Debug overlay (D): monitor (blue) + hotspots (green) ----
if (show_dev) {
    draw_set_alpha(0.28);

    // Monitor viewport
    draw_set_color(c_aqua);
    draw_rectangle(MON_X, MON_Y, MON_X + MON_W, MON_Y + MON_H, false);

    // State-specific hotspots
    var rects;
    switch (state) {
        case DeskState.DESK:
            rects = [BTN_EMAIL_ICON];
        break;
        case DeskState.EMAIL_LIST:
            rects = [BTN_PHISH_SUBJ, BTN_CLOSEX]; // Back not on this PNG
        break;
        case DeskState.EMAIL_OPEN:
            rects = [BTN_PHISH_LINK, BTN_BACK, BTN_CLOSEX];
        break;
    }

    draw_set_color(c_lime);
    for (var i = 0; i < array_length(rects); i++) {
        var r = rects[i];
        draw_rectangle(r[0], r[1], r[0] + r[2], r[1] + r[3], false);
    }
    draw_set_alpha(1);
}

// Hotspot edit overlay (F2)
if (edit_hotspot) {
    var label = "HOTSPOT EDIT: F2 exit | 1..5 select | Arrows move | Shift+W/A/S/D resize | Editing: " + string(selected_hotspot);
    draw_set_color(c_black); draw_text(12, 92, label);
    draw_set_color(c_lime);  draw_text(10, 90, label);

    // highlight currently edited rect
    var rr = _get_rect(selected_hotspot);
    draw_set_alpha(0.6);
    draw_set_color(c_yellow);
    draw_rectangle(rr[0], rr[1], rr[0] + rr[2], rr[1] + rr[3], false);
    draw_set_alpha(1);
}

// ---- Guided overlay (F3) ----
if (guided_mode) {
    var lbl = "GUIDED RUN: Click TL then BR for " + _name_for(guided_ids[guided_idx]) + "  •  Press F5 to save when done";
    draw_set_color(c_black); draw_text(12, 112, lbl);
    draw_set_color(c_aqua);  draw_text(10, 110, lbl);
}
