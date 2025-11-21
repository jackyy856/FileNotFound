/// obj_RecycleBinApp - Step
event_inherited(); // AppBase movement / minimize / close

if (!variable_instance_exists(id, "is_minimized")) {
    is_minimized = false;
}

// mouse in GUI space
var mx       = device_mouse_x_to_gui(0);
var my       = device_mouse_y_to_gui(0);
var pressed  = mouse_check_button_pressed(mb_left);
var released = mouse_check_button_released(mb_left);
var held     = mouse_check_button(mb_left);

// content rect from AppBase
var cx1 = content_x1;
var cy1 = content_y1;
var cx2 = content_x2;
var cy2 = content_y2;

var content_w = cx2 - cx1;
var content_h = cy2 - cy1;

// bin center
var bin_cx = cx1 + content_w * 0.5;
var bin_cy = cy1 + content_h * 0.55;

var bin_half_w = bin_width * 0.5;
var bin_half_h = bin_height * 0.5;

var inner_radius = max(bin_half_w, bin_half_h);
var drop_radius  = inner_radius + bin_drop_margin;

var title_h  = 28;
var scroll_w = 10;

for (var i = 0; i < file_count; i++) {
    var f = files[i];

    // keep in-bin files glued to bin
    if (f.in_bin && !f.box_open) {
        f.x = bin_cx + f.home_off_x;
        f.y = bin_cy + f.home_off_y;
    }

    // ---------------- POPUP OPEN ----------------
    if (f.box_open) {
        // keep popup attached to the window
        f.box_x = cx1 + f.box_off_x;
        f.box_y = cy1 + f.box_off_y;

        var bx = f.box_x;
        var by = f.box_y;
        var bw = f.box_w;
        var bh = f.box_h;

        // X button
        var x_size   = 18;
        var x_left   = bx + bw - x_size - 8;
        var x_top    = by + 5;
        var x_right  = x_left + x_size;
        var x_bottom = x_top + x_size;

        if (pressed && point_in_rectangle(mx, my, x_left, x_top, x_right, x_bottom)) {
            f.box_open    = false;
            f.in_bin      = true;
            f.scroll      = 0;
            f.scroll_drag = false;
            files[i] = f;
            continue;
        }

        // scrollbar drag
        var track_left   = bx + bw - 8 - scroll_w;
        var track_right  = track_left + scroll_w;
        var track_top    = by + title_h + 6;
        var track_bottom = by + bh - 6;

        if (f.scroll_max > 0) {
            if (pressed && point_in_rectangle(mx, my, track_left, track_top, track_right, track_bottom)) {
                f.scroll_drag = true;
            }

            if (!held) {
                f.scroll_drag = false;
            }

            if (f.scroll_drag && held) {
                var track_h = track_bottom - track_top;
                var ratio = (track_h > 0) ? (my - track_top) / track_h : 0;
                ratio = clamp(ratio, 0, 1);
                f.scroll = ratio * f.scroll_max;
            }

            f.scroll = clamp(f.scroll, 0, f.scroll_max);
        }

        files[i] = f;
        continue;
    }

    // ---------------- FILE DRAGGING ----------------
    var file_half_w = 40;
    var file_half_h = 24;

    // start drag
    if (!f.dragging && pressed) {
        if (point_in_rectangle(
            mx, my,
            f.x - file_half_w, f.y - file_half_h,
            f.x + file_half_w, f.y + file_half_h
        )) {
            f.dragging = true;
            f.in_bin   = false;
            f.drag_dx  = f.x - mx;
            f.drag_dy  = f.y - my;
        }
    }

    // during drag
    if (f.dragging) {
        if (held) {
            f.x = mx + f.drag_dx;
            f.y = my + f.drag_dy;
        }

        if (released) {
            f.dragging = false;

            var dist = point_distance(f.x, f.y, bin_cx, bin_cy);

            // INSIDE halo -> back in bin
            // OUTSIDE halo -> open popup
            if (dist <= drop_radius) {
                f.in_bin   = true;
                f.box_open = false;
            } else {
                f.in_bin   = false;
                f.box_open = true;

                // choose popup location
                switch (i) {
                    case 0: // meme 1 - top-left
                        f.box_x = cx1 + 20;
                        f.box_y = cy1 + 20;
                        break;
                    case 1: // meme 2 - top-right
                        f.box_x = cx1 + content_w * 0.5 + 20;
                        f.box_y = cy1 + 20;
                        break;
                    case 2: // slack - bottom-left
                        f.box_x = cx1 + 20;
                        f.box_y = cy1 + content_h * 0.5 + 20;
                        break;
                    case 3: // transcript - centered
                        f.box_x = cx1 + (content_w - f.box_w) * 0.5;
                        f.box_y = cy1 + (content_h - f.box_h) * 0.5;
                        break;
                }

                // store offsets so box follows window movement
                f.box_off_x = f.box_x - cx1;
                f.box_off_y = f.box_y - cy1;

                // compute scroll range
                var text_left   = f.box_x + 12;
                var text_right  = f.box_x + f.box_w - 12 - scroll_w - 4;
                var text_w      = text_right - text_left;
                var text_top    = f.box_y + title_h + 8;
                var text_bottom = f.box_y + f.box_h - 10;
                var visible_h   = text_bottom - text_top;

                var text_h = string_height_ext(f.content, 0, text_w);

                f.scroll_max  = max(0, text_h - visible_h);
                f.scroll      = 0;
                f.scroll_drag = false;
            }
        }
    }

    files[i] = f;
}
