/// obj_FilesApp - Step

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// ----------------- WINDOW CLOSE / MINIMIZE (top-right) -----------------
var over_close = (mx >= files_close_btn[0] && mx <= files_close_btn[0] + files_close_btn[2] &&
                  my >= files_close_btn[1] && my <= files_close_btn[1] + files_close_btn[3]);
var over_min   = (mx >= files_min_btn[0] && mx <= files_min_btn[0] + files_min_btn[2] &&
                  my >= files_min_btn[1] && my <= files_min_btn[1] + files_min_btn[3]);

if (mouse_check_button_pressed(mb_left)) {
    if (over_close) {
        instance_destroy();
        exit;
    }
    if (over_min) {
        is_minimized = !is_minimized;
    }
}

if (is_minimized) {
    exit;
}

// =======================================================================
//                               HOME VIEW
// =======================================================================
if (view_mode == 0) {

    if (mouse_check_button_pressed(mb_left)) {
        for (var i = 0; i < array_length(home_entries); i++) {
            var e = home_entries[i];
            if (mx >= e.rx && mx <= e.rx + e.rw &&
                my >= e.ry && my <= e.ry + e.rh) {

                if (e.kind == "file_minigame") {
                    // Launch the Click-the-File mini-game
                    room_goto(room_ClickFiles);
                }
                else if (e.kind == "firewall") {
                    view_mode = 1; // go to firewall puzzle
                }
                break;
            }
        }
    }

    exit;
}


// =======================================================================
//                          FIREWALL PUZZLE VIEW
// =======================================================================
if (view_mode == 1) {

    // ----------------- HOLD AFTER ANIMATION (extra couple seconds) -----------------
    if (fw_anim_hold) {
        fw_anim_hold_time += 1;
        if (fw_anim_hold_time >= room_speed * 2) { // ~2 seconds
            fw_anim_hold      = false;
            fw_anim_hold_time = 0;
            view_mode         = 2;
        }
        exit;
    }

    // ----------------- ANIMATION: slide everything to Admit -----------------
    if (fw_animating) {
        fw_anim_t += 0.06;
        var t = clamp(fw_anim_t, 0, 1);

        for (var ai = 0; ai < array_length(fw_tiles); ai++) {
            var atile = fw_tiles[ai];
            atile.x = atile.start_x + (atile.target_x - atile.start_x) * t;
            atile.y = atile.start_y + (atile.target_y - atile.start_y) * t;
            fw_tiles[ai] = atile;
        }

        if (fw_anim_t >= 1) {
            fw_animating      = false;
            fw_anim_t         = 1;
            fw_anim_hold      = true;
            fw_anim_hold_time = 0;

            // snap to final positions
            for (var aj = 0; aj < array_length(fw_tiles); aj++) {
                var f = fw_tiles[aj];
                f.x = f.target_x;
                f.y = f.target_y;
                fw_tiles[aj] = f;
            }
        }

        exit;
    }

    // ----------------- CONFIRM POPUP HANDLING -----------------
    if (fw_confirm_open) {
        if (mouse_check_button_pressed(mb_left)) {
            var mw  = 420;
            var mh  = 160;
            var mx2 = window_x + (window_w - mw) * 0.5;
            var my2 = window_y + (window_h - mh) * 0.5;

            var btn_w = 100;
            var btn_h = 30;
            var gap_x = 30;
            var btn_y = my2 + mh - 50;

            var cancel_x = mx2 + 40;
            var ok_x     = cancel_x + btn_w + gap_x;

            var over_cancel = (mx >= cancel_x && mx <= cancel_x + btn_w &&
                               my >= btn_y   && my <= btn_y   + btn_h);
            var over_ok     = (mx >= ok_x     && mx <= ok_x     + btn_w &&
                               my >= btn_y   && my <= btn_y   + btn_h);

            if (over_ok) {
                // set up animation to move all tiles into Admit
                fw_confirm_open = false;
                fw_animating    = true;
                fw_anim_t       = 0;

                var n      = array_length(fw_tiles);
                var sy     = 12; // vertical spacing
                var base_x = fw_admit.x + (fw_admit.w - fw_tile_max_w) * 0.5;
                var base_y = fw_admit.y + 60;

                for (var iok = 0; iok < n; iok++) {
                    var tile_ok = fw_tiles[iok];

                    var row = iok;
                    var tx  = base_x;
                    var ty  = base_y + row * (tile_ok.h + sy);

                    tile_ok.start_x  = tile_ok.x;
                    tile_ok.start_y  = tile_ok.y;
                    tile_ok.target_x = tx;
                    tile_ok.target_y = ty;
                    tile_ok.side     = 1; // everything ends in Admit

                    fw_tiles[iok] = tile_ok;
                }

            } else if (over_cancel) {
                // Cancel: close popup and reset all tiles back to home positions
                fw_confirm_open = false;

                for (var ic = 0; ic < array_length(fw_tiles); ic++) {
                    var tile_c = fw_tiles[ic];
                    tile_c.side     = -1;
                    tile_c.dragging = false;
                    tile_c.x        = tile_c.home_x;
                    tile_c.y        = tile_c.home_y;
                    fw_tiles[ic]    = tile_c;
                }
            }
        }

        exit;
    }

    // ----------------- DRAG START -----------------
    if (mouse_check_button_pressed(mb_left)) {
        for (var i2 = array_length(fw_tiles) - 1; i2 >= 0; i2--) {
            var t = fw_tiles[i2];
            if (mx >= t.x && mx <= t.x + t.w &&
                my >= t.y && my <= t.y + t.h) {

                t.dragging = true;
                t.dx = mx - t.x;
                t.dy = my - t.y;
                fw_tiles[i2] = t;
                break;
            }
        }
    }

    // ----------------- DRAG MOVE -----------------
    if (mouse_check_button(mb_left)) {
        for (var j = 0; j < array_length(fw_tiles); j++) {
            if (fw_tiles[j].dragging) {
                fw_tiles[j].x = mx - fw_tiles[j].dx;
                fw_tiles[j].y = my - fw_tiles[j].dy;
            }
        }
    }

    // ----------------- DRAG RELEASE -----------------
    if (mouse_check_button_released(mb_left)) {
        for (var k = 0; k < array_length(fw_tiles); k++) {
            if (fw_tiles[k].dragging) {
                var tt = fw_tiles[k];
                tt.dragging = false;

                // check deny / admit zones
                var in_deny  = (mx >= fw_deny.x && mx <= fw_deny.x + fw_deny.w &&
                                my >= fw_deny.y && my <= fw_deny.y + fw_deny.h);
                var in_admit = (mx >= fw_admit.x && mx <= fw_admit.x + fw_admit.w &&
                                my >= fw_admit.y && my <= fw_admit.y + fw_admit.h);

                if (in_deny) {
                    tt.side = 0;
                    tt.x = clamp(tt.x, fw_deny.x + 8, fw_deny.x + fw_deny.w - tt.w - 8);
                    tt.y = clamp(tt.y, fw_deny.y + 8, fw_deny.y + fw_deny.h - tt.h - 8);
                }
                else if (in_admit) {
                    tt.side = 1;
                    tt.x = clamp(tt.x, fw_admit.x + 8, fw_admit.x + fw_admit.w - tt.w - 8);
                    tt.y = clamp(tt.y, fw_admit.y + 8, fw_admit.y + fw_admit.h - tt.h - 8);
                }
                else {
                    // return to home row
                    tt.side = -1;
                    tt.x = tt.home_x;
                    tt.y = tt.home_y;
                }

                fw_tiles[k] = tt;
            }
        }

        // if all tiles are placed (side != -1), open confirm
        var all_placed = true;
        for (var p = 0; p < array_length(fw_tiles); p++) {
            if (fw_tiles[p].side == -1) {
                all_placed = false;
                break;
            }
        }
        if (all_placed) {
            fw_confirm_open = true;
        }
    }

    exit;
}

// =======================================================================
//                         FIREWALL LOG / KEY VIEW
// =======================================================================
if (view_mode == 2) {

    // back button near top-right of Files window
    var back_btn_x = window_x + window_w - 120;
    var back_btn_y = window_y + 60;
    var back_btn_w = 80;
    var back_btn_h = 24;

    if (mouse_check_button_pressed(mb_left)) {
        // back to home
        if (mx >= back_btn_x && mx <= back_btn_x + back_btn_w &&
            my >= back_btn_y && my <= back_btn_y + back_btn_h) {

            view_mode = 0;
        } else {
            // gold key click
            var kx = fw_key_rect[0];
            var ky = fw_key_rect[1];
            var kw = fw_key_rect[2];
            var kh = fw_key_rect[3];

            if (mx >= kx && mx <= kx + kw &&
                my >= ky && my <= ky + kh) {

                fw_key_collected_local = true;

                if (!variable_global_exists("key_collected")) {
                    global.key_collected = array_create(3, false);
                }

                // 2 = golden key slot
                global.key_collected[2] = true;
            }
        }
    }

    exit;
}
