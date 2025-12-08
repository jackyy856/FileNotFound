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

