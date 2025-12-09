
/// Renders current background art and (optionally) debug overlays + prompt bar.

// Current background - scale to actual GUI size
var spr_id = -1;
if (state == DeskState.DESK)       spr_id = sprDesk;
if (state == DeskState.EMAIL_LIST) spr_id = sprEmailList;
if (state == DeskState.EMAIL_OPEN) spr_id = sprEmailOpen;
if (spr_id != -1) {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    draw_sprite_stretched(spr_id, 0, 0, 0, gui_w, gui_h);
}

// Prompt bar (bottom) - scale to actual GUI size
if (dialog_timer > 0 && dialog_text != "") {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var m = 24, bar_h = 92;
    var y1 = gui_h - bar_h - m, y2 = gui_h - m;

    draw_set_alpha(0.92);
    draw_set_color(make_color_rgb(48,18,82));
    draw_roundrect(m, y1, gui_w-m, y2, false);
    draw_set_alpha(1);

    draw_set_color(make_color_rgb(156,90,255));
    draw_rectangle(m, y1, gui_w-m, y1+3, false);

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_ext(m+24, y1+22, dialog_text, 16, gui_w - (m+24)*2);
}

