/// obj_EscapeMenu — Draw GUI
if (!active) exit;

var GW = display_get_gui_width();
var GH = display_get_gui_height();

if (sprite_exists(spr_menu_BG)) {
    draw_set_alpha(1);
    draw_sprite_stretched(spr_menu_BG, 0, 0, 0, GW, GH);
    draw_set_alpha(0.35); draw_set_color(c_black);
    draw_rectangle(0, 0, GW, GH, false);
    draw_set_alpha(1);
} else {
    draw_set_alpha(0.62);
    draw_set_color(c_black);
    draw_rectangle(0,0,GW,GH,false);
    draw_set_alpha(1);

    draw_set_color(make_color_rgb(28,32,38));
    draw_roundrect(0, 0, GW, GH, false);
}

draw_set_color(c_white);
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_text(32, 32, "Pause");

// live hit test for hover
function _over(r) {
    var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
    return (_mx>=r.x)&&(_my>=r.y)&&(_mx<r.x+r.w)&&(_my<r.y+r.h);
}

if (state == "root") {
    for (var i = 0; i < array_length(buttons_root); i++) {
        var b = buttons_root[i];
        var over = _over(b);
        draw_set_color(over ? make_color_rgb(80,170,120) : make_color_rgb(230,230,230));
        draw_roundrect(b.x, b.y, b.x+b.w, b.y+b.h, false);
        draw_set_color(over ? c_white : c_black);
        draw_text(b.x + 22, b.y + 20, b.label);
    }
    exit;
}

var bb = btn_back;
draw_set_color(make_color_rgb(230,230,230));
draw_roundrect(bb.x, bb.y, bb.x+bb.w, bb.y+bb.h, false);
draw_set_color(c_black);
draw_text(bb.x + 18, bb.y + 12, bb.label);

if (state == "submenu" && (submenu == "load" || submenu == "save")) {
    var title = (submenu == "load") ? "Load Game" : "Save Game";
    draw_set_color(c_white);
    draw_text(32, 100, title);

    for (var s = 0; s < array_length(slots); s++) {
        var sl = slots[s];
        var over = _over(sl);
        draw_set_color(over ? make_color_rgb(80,170,120) : make_color_rgb(230,230,230));
        draw_roundrect(sl.x, sl.y, sl.x+sl.w, sl.y+sl.h, false);

        var meta = _slot_meta(sl.idx);
        draw_set_color(make_color_rgb(210,210,210));
        draw_roundrect(sl.x+22, sl.y+22, sl.x+sl.w-22, sl.y+138, false);
        draw_set_color(c_black);
        draw_text(sl.x + 30, sl.y + 30, "(art)");
        draw_text(sl.x + 30, sl.y + 154, meta.title);
        if (!meta.exists) {
            draw_set_color(make_color_rgb(120,120,120));
            draw_text(sl.x + 30, sl.y + 182, "Empty");
        }
    }
    exit;
}

if (state == "submenu" && submenu == "settings") {
    draw_set_color(c_white);
    draw_text(32, 100, "Settings");

    draw_text(slider.x, slider.y - 48, "Master Volume: " + string(slider_val));
    draw_set_color(make_color_rgb(210,210,210));
    draw_rectangle(slider.x, slider.y, slider.x + slider.w, slider.y + slider.h, false);

    var knob_x = slider.x + (slider_val/100) * slider.w - slider.knob_w*0.5;
    draw_set_color(make_color_rgb(80,170,120));
    draw_roundrect(knob_x, slider.y - 10, knob_x + slider.knob_w, slider.y + slider.h + 10, false);
    exit;
}

if (state == "confirm") {
    var W = 700, H = 220;
    var X = (GW - W)*0.5, Y = (GH - H)*0.5;
    draw_set_alpha(0.85);
    draw_set_color(make_color_rgb(24,24,24));
    draw_roundrect(X, Y, X+W, Y+H, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_text(X+24, Y+20, confirm_title);
    draw_set_color(make_color_rgb(200,200,200));
    draw_text(X+24, Y+64, confirm_msg);

    for (var i = 0; i < array_length(confirm_buttons); i++) {
        var b = confirm_buttons[i];
        var over = _over(b);
        draw_set_color(over ? make_color_rgb(80,170,120) : make_color_rgb(230,230,230));
        draw_roundrect(b.x, b.y, b.x+b.w, b.y+b.h, false);
        draw_set_color(over ? c_white : c_black);
        draw_text(b.x + 18, b.y + 12, b.label);
    }
    exit;
}

if (state == "toast") {
    var W2 = 520, H2 = 80;
    var X2 = (GW - W2)*0.5, Y2 = GH - H2 - 60;
    draw_set_alpha(0.92);
    draw_set_color(c_black);
    draw_roundrect(X2, Y2, X2+W2, Y2+H2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(X2 + W2*0.5, Y2 + H2*0.5, toast_txt);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
}