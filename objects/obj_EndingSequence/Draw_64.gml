/// obj_EndingSequence - Draw GUI

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

// Background overlay:
// WIN: lighter dim so the desktop is still visible.
// LOSS: heavier dim to feel worse.
if (phase == 0) {
    draw_set_alpha(is_win ? 0.35 : 0.75);
} else {
    draw_set_alpha(1);
}
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

if (phase == 0) {
    // =========================
    // PHASE 0: YOU WIN / YOU LOSE
    // =========================

    var cx = gui_w * 0.5;
    var cy = gui_h * 0.5;

    // Falling file-icons behind the text
    if (confetti_started) {
        for (var i = 0; i < confetti_count; i++) {
            var p = confetti[i];

            draw_set_alpha(p.a);
            draw_sprite_ext(p.spr, 0, p.x, p.y, p.sc, p.sc, 0, c_white, 1);
        }
        draw_set_alpha(1);
    }

    // YOU WIN / YOU LOSE text
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_set_alpha(text_alpha);

    var msg = is_win ? "YOU WIN" : "YOU LOSE";
    var tx = cx;
    var ty = cy;

    // LOSS: slight jitter/glitch
    if (!is_win) {
        tx += irandom_range(-3, 3);
        ty += irandom_range(-1, 1);
    }

    draw_text_transformed(tx, ty, msg, text_scale, text_scale, 0);

    draw_set_alpha(1);
}
else if (phase == 1) {
    // =========================
    // PHASE 1: SCROLLING CREDITS
    // =========================
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    var yy = credits_offset;
    var center_x = gui_w * 0.5;

    for (var i2 = 0; i2 < credits_len; i2++) {
        var line_struct = credits[i2];
        var txt   = line_struct.text;
        var style = line_struct.style;

        var scale = 1.0;
        if (style == "title")      scale = 2.4;
        else if (style == "role")  scale = 1.7;
        else if (style == "name")  scale = 1.4;
        else if (style == "spacer") {
            yy += 28;
            continue;
        }

        draw_text_transformed(center_x, yy, txt, scale, scale, 0);
        yy += 40 * scale;
    }
}
else if (phase == 2) {
    // =========================
    // PHASE 2: FINAL THANK YOU
    // =========================
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);

    var alpha_val = clamp(final_timer / (room_speed * 0.7), 0, 1);
    draw_set_alpha(alpha_val);

    draw_text_transformed(
        gui_w * 0.5,
        gui_h * 0.5,
        "THANK YOU FOR PLAYING OUR GAME :)",
        1.8, 1.8, 0
    );

    draw_set_alpha(1);
}
