draw_set_alpha(1);
if (!is_minimized) {
    draw_set_color(c_white);
    draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, false);
    draw_set_color(c_black);
    draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, true);
} else {
    // only draw header area when minimized
    draw_set_color(c_white);
    draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, false);
    draw_set_color(c_black);
    draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, true);
}
//Testing Commit Comment
// Title bar
draw_set_font(font_title);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_text(window_x + 16, window_y + 12, "Files");

// Minimize button
var bmin = make_colour_rgb(230,230,230);
draw_set_color(bmin);
draw_rectangle(min_btn[0], min_btn[1], min_btn[0] + min_btn[2], min_btn[1] + min_btn[3], false);
draw_set_color(c_black);
draw_rectangle(min_btn[0], min_btn[1], min_btn[0] + min_btn[2], min_btn[1] + min_btn[3], true);
draw_text(min_btn[0] + 8, min_btn[1] + 2, "-");

// Close button
var bcol = make_colour_rgb(230,230,230);
draw_set_color(bcol);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], false);
draw_set_color(c_black);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], true);
draw_text(close_btn[0] + 7, close_btn[1] + 2, "X");

// If minimized, skip body rendering
if (is_minimized) exit;


// Breadcrumbs (second line)
draw_set_font(font_body);
draw_set_color(make_colour_rgb(60,60,60));
var bc_text = "";
for (var i = 0; i < array_length(breadcrumbs); i++) {
    if (i > 0) { bc_text += " / "; }
    bc_text += string(breadcrumbs[i].name);
}
draw_text(list_left, breadcrumbs_y, bc_text);

// Back / Up buttons
if (mode == "view") {
    var bcol1 = make_colour_rgb(230,230,230);
    draw_set_color(bcol1);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], false);
    draw_set_color(c_black);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], true);
    draw_text(back_btn[0] + 10, back_btn[1] + 3, "< Back");
}
if (cwd.parent != noone) {
    var bcol2 = make_colour_rgb(230,230,230);
    draw_set_color(bcol2);
    draw_rectangle(up_btn[0], up_btn[1], up_btn[0] + up_btn[2], up_btn[1] + up_btn[3], false);
    draw_set_color(c_black);
    draw_rectangle(up_btn[0], up_btn[1], up_btn[0] + up_btn[2], up_btn[1] + up_btn[3], true);
    draw_text(up_btn[0] + 14, up_btn[1] + 3, "Up");
}

// Content
draw_set_font(font_body);
draw_set_color(c_black);

if (mode == "list") {
    var folder_spr = asset_get_index("spr_FilesIcon");
    var text_spr   = asset_get_index("spr_StickyNoteIcon");

    var items = cwd.children;
    var len   = array_length(items);
    var cols  = grid_cols;
    var x0    = list_left;
    var y0    = content_top;

    for (var i2 = 0; i2 < len; i2++) {
        var col = i2 mod cols;
        var row = i2 div cols;

        var cell_x = x0 + col * cell_w;
        var cell_y = y0 + row * cell_h;

        var icon_x = cell_x + (cell_w - icon_w) * 0.5;
        var icon_y = cell_y;

        var it = items[i2];

        if (it.type == "folder") {
            if (folder_spr != -1) {
                draw_sprite_ext(folder_spr, 0, icon_x + icon_w*0.5, icon_y + icon_h*0.5, 1, 1, 0, c_white, 1);
            } else {
                draw_set_alpha(0.06);
                draw_set_color(c_black);
                draw_rectangle(icon_x, icon_y, icon_x + icon_w, icon_y + icon_h, false);
                draw_set_alpha(1);
            }
        } else if (it.type == "text") {
            if (text_spr != -1) {
                draw_sprite_ext(text_spr, 0, icon_x + icon_w*0.5, icon_y + icon_h*0.5, 1, 1, 0, c_white, 1);
            } else {
                draw_set_alpha(0.06);
                draw_set_color(c_black);
                draw_rectangle(icon_x, icon_y, icon_x + icon_w, icon_y + icon_h, false);
                draw_set_alpha(1);
                draw_set_color(c_black);
                draw_text(icon_x + 8, icon_y + 8, "TXT");
            }
        } else if (it.type == "image") {
            if (!is_undefined(it.sprite) && it.sprite != -1) {
                var scale = 0.75;
                draw_sprite_ext(it.sprite, 0,
                    icon_x + icon_w*0.5, icon_y + icon_h*0.5,
                    scale, scale, 0, c_white, 1);
            } else {
                draw_set_alpha(0.06);
                draw_set_color(c_black);
                draw_rectangle(icon_x, icon_y, icon_x + icon_w, icon_y + icon_h, false);
                draw_set_alpha(1);
                draw_set_color(c_black);
                draw_text(icon_x + 8, icon_y + 8, "IMG");
            }
        }

        draw_set_color(c_black);
        draw_set_halign(fa_center);
        var label_x = cell_x + cell_w * 0.5;
        var label_y = icon_y + icon_h + 8;
        draw_text_ext(label_x, label_y, string(it.name), 8, cell_w - 8);
        draw_set_halign(fa_left);
    }
}
else if (mode == "view") {
    var tx = list_left;
    var ty = content_top;

    draw_set_font(font_title);
    draw_text(tx, breadcrumbs_y + 28, "Preview");

    draw_set_font(font_body);
    if (viewer_type == "text") {
        var body_w = window_w - 40;
        draw_text_ext(tx, ty + 24, viewer_text, 12, body_w);
    } else if (viewer_type == "image") {
        if (viewer_sprite != -1) {
            var cx = window_x + window_w * 0.5;
            var cy = window_y + header_h + (window_h - header_h) * 0.5;
            draw_sprite_ext(viewer_sprite, 0, cx, cy, 1, 1, 0, c_white, 1);
        } else {
            draw_set_alpha(0.05);
            draw_set_color(c_black);
            var px1 = tx, py1 = ty, px2 = window_x + window_w - 20, py2 = window_y + window_h - 20;
            draw_rectangle(px1, py1, px2, py2, false);
            draw_set_alpha(1);
            draw_set_color(c_black);
            draw_text(tx, ty, "(Image placeholder — assign a sprite to this file to preview)");
        }
    }
}
