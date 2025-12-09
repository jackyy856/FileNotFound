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
        if (video_active) {
            video_close();
            video_active = false;
        }
        instance_destroy();
        exit;
    }
    if (over_min) {
        is_minimized = !is_minimized;
    }
}

// ----------------- HEADER DRAGGING (works even when minimized) ---------
if (mouse_check_button_pressed(mb_left)) {
    var on_header = (mx >= window_x && mx <= window_x + window_w &&
                     my >= window_y && my <= window_y + header_h);

    if (on_header && !over_close && !over_min) {
        window_dragging = true;
        window_drag_dx  = mx - window_x;
        window_drag_dy  = my - window_y;
    }
}

if (window_dragging) {
    if (mouse_check_button(mb_left)) {
        var old_x = window_x;
        var old_y = window_y;

        window_x = mx - window_drag_dx;
        window_y = my - window_drag_dy;

        var dx = window_x - old_x;
        var dy = window_y - old_y;

        // move buttons
        files_close_btn[0] += dx; files_close_btn[1] += dy;
        files_min_btn[0]   += dx; files_min_btn[1]   += dy;

        // move frame and panels
        fw_frame.x += dx; fw_frame.y += dy;
        fw_deny.x  += dx; fw_deny.y  += dy;
        fw_admit.x += dx; fw_admit.y += dy;

        // move home entries
        for (var he = 0; he < array_length(home_entries); he++) {
            home_entries[he].rx += dx;
            home_entries[he].ry += dy;
        }

        // move firewall tiles
        for (var tt = 0; tt < array_length(fw_tiles); tt++) {
            var tile_d = fw_tiles[tt];
            tile_d.x        += dx;
            tile_d.y        += dy;
            tile_d.home_x   += dx;
            tile_d.home_y   += dy;
            tile_d.start_x  += dx;
            tile_d.start_y  += dy;
            tile_d.target_x += dx;
            tile_d.target_y += dy;
            fw_tiles[tt]     = tile_d;
        }

        // move key rect
        fw_key_rect[0] += dx;
        fw_key_rect[1] += dy;

    } else {
        window_dragging = false;
    }
}

// ----------------- IGNORE FIRST CLICK AFTER SPAWN ----------------------
if (spawn_click_cooldown > 0) {
    spawn_click_cooldown -= 1;
    exit;
}

// if minimized, don't process clicks inside content
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

                // Gate FileNotFound until all 3 keys are collected
                if (e.label == "FileNotFound") {
                    if (!variable_global_exists("key_collected")) {
                        global.key_collected = array_create(3, false);
                    }
                    var keys_ok = (global.key_collected[0] && global.key_collected[1] && global.key_collected[2]);
                    if (!keys_ok) {
                        if (variable_global_exists("_toast_files")) {
                            global._toast_files = "You need to collect 3 keys to unlock it.";
                        } else {
                            show_message_async("You need to collect 3 keys to unlock it.");
                        }
                        exit;
                    }
                }

                if (e.kind == "file_minigame") {
                    // Launch the Click-the-File mini-game
                    room_goto(room_ClickFiles);
                }
                else if (e.kind == "firewall") {
                    if (video_active) {
                        video_close();
                        video_active = false;
                    }
                    view_mode = 1; // go to firewall puzzle
                }
                else {
                    // Regular folder (OPEN ME, HR, etc.)
                    current_folder = e.label;
                    view_mode      = 3;

                    if (current_folder == "OPEN ME") {
                        if (video_active) {
                            video_close();
                            video_active = false;
                        }
                        open_me_stage = 0; // show bait file
                    } else {
                        if (video_active) {
                            video_close();
                            video_active = false;
                        }
                    }
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

    var back_btn_x = window_x + window_w - 120;
    var back_btn_y = window_y + 60;
    var back_btn_w = 80;
    var back_btn_h = 24;

    if (!fw_confirm_open && !fw_animating && !fw_anim_hold) {
        if (mouse_check_button_pressed(mb_left)) {
            if (mx >= back_btn_x && mx <= back_btn_x + back_btn_w &&
                my >= back_btn_y && my <= back_btn_y + back_btn_h) {

                for (var rb = 0; rb < array_length(fw_tiles); rb++) {
                    var tb = fw_tiles[rb];
                    tb.side     = -1;
                    tb.dragging = false;
                    tb.x        = tb.home_x;
                    tb.y        = tb.home_y;
                    fw_tiles[rb]= tb;
                }
                fw_confirm_open   = false;
                fw_animating      = false;
                fw_anim_hold      = false;
                fw_anim_t         = 0;
                fw_anim_hold_time = 0;

                view_mode = 0;
                exit;
            }
        }
    }

    if (fw_anim_hold) {
        fw_anim_hold_time += 1;
        if (fw_anim_hold_time >= room_speed * 2) {
            fw_anim_hold      = false;
            fw_anim_hold_time = 0;
            view_mode         = 2;
        }
        exit;
    }

    if (fw_animating) {
        fw_anim_t += 0.03;
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

            for (var aj = 0; aj < array_length(fw_tiles); aj++) {
                var f = fw_tiles[aj];
                f.x = f.target_x;
                f.y = f.target_y;
                fw_tiles[aj] = f;
            }
        }

        exit;
    }

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
                fw_confirm_open = false;
                fw_animating    = true;
                fw_anim_t       = 0;

                var n      = array_length(fw_tiles);
                var sy     = 12;
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
                    tile_ok.side     = 1;

                    fw_tiles[iok] = tile_ok;
                }

            } else if (over_cancel) {
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

    // drag start
    if (mouse_check_button_pressed(mb_left)) {
        for (var i2 = array_length(fw_tiles) - 1; i2 >= 0; i2--) {
            var t2 = fw_tiles[i2];
            if (mx >= t2.x && mx <= t2.x + t2.w &&
                my >= t2.y && my <= t2.y + t2.h) {

                t2.dragging = true;
                t2.dx = mx - t2.x;
                t2.dy = my - t2.y;
                fw_tiles[i2] = t2;
                break;
            }
        }
    }

    // drag move
    if (mouse_check_button(mb_left)) {
        for (var j = 0; j < array_length(fw_tiles); j++) {
            if (fw_tiles[j].dragging) {
                fw_tiles[j].x = mx - fw_tiles[j].dx;
                fw_tiles[j].y = my - fw_tiles[j].dy;
            }
        }
    }

    // drag release
    if (mouse_check_button_released(mb_left)) {
        for (var k = 0; k < array_length(fw_tiles); k++) {
            if (fw_tiles[k].dragging) {
                var tt2 = fw_tiles[k];
                tt2.dragging = false;

                var in_deny  = (mx >= fw_deny.x && mx <= fw_deny.x + fw_deny.w &&
                                my >= fw_deny.y && my <= fw_deny.y + fw_deny.h);
                var in_admit = (mx >= fw_admit.x && mx <= fw_admit.x + fw_admit.w &&
                                my >= fw_admit.y && my <= fw_admit.y + fw_admit.h);

                if (in_deny) {
                    tt2.side = 0;
                    tt2.x = clamp(tt2.x, fw_deny.x + 8, fw_deny.x + fw_deny.w - tt2.w - 8);
                    tt2.y = clamp(tt2.y, fw_deny.y + 8, fw_deny.y + fw_deny.h - tt2.h - 8);
                }
                else if (in_admit) {
                    tt2.side = 1;
                    tt2.x = clamp(tt2.x, fw_admit.x + 8, fw_admit.x + fw_admit.w - tt2.w - 8);
                    tt2.y = clamp(tt2.y, fw_admit.y + 8, fw_admit.y + fw_admit.h - tt2.h - 8);
                }
                else {
                    tt2.side = -1;
                    tt2.x = tt2.home_x;
                    tt2.y = tt2.home_y;
                }

                fw_tiles[k] = tt2;
            }
        }

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

    var back_btn_x2 = window_x + window_w - 120;
    var back_btn_y2 = window_y + 60;
    var back_btn_w2 = 80;
    var back_btn_h2 = 24;

    if (mouse_check_button_pressed(mb_left)) {
        if (mx >= back_btn_x2 && mx <= back_btn_x2 + back_btn_w2 &&
            my >= back_btn_y2 && my <= back_btn_y2 + back_btn_h2) {

            view_mode = 0;
        } else {
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

                global.key_collected[2] = true;
            }
        }
    }

    exit;
}

// =======================================================================
//                      GENERIC FOLDER VIEW (OPEN ME / HR / Images)
// =======================================================================
if (view_mode == 3) {

    var back_btn_x3 = window_x + window_w - 120;
    var back_btn_y3 = window_y + 60;
    var back_btn_w3 = 80;
    var back_btn_h3 = 24;

    if (mouse_check_button_pressed(mb_left)) {

        if (mx >= back_btn_x3 && mx <= back_btn_x3 + back_btn_w3 &&
            my >= back_btn_y3 && my <= back_btn_y3 + back_btn_h3) {

            // BACK button behaviour depends on OPEN ME stage
            if (current_folder == "OPEN ME") {

                if (open_me_stage == 1) {
                    // video → go back to bait file
                    if (video_active) {
                        video_close();
                        video_active = false;
                    }
                    open_me_stage = 0;

                } else {
                    // from bait file, go back Home
                    view_mode      = 0;
                    current_folder = "";
                    open_me_stage  = 0;
                }

            } else {
                // normal folder: just go Home
                view_mode      = 0;
                current_folder = "";
            }

        } else if (current_folder == "OPEN ME" && open_me_stage == 0) {
            // click on inner bait folder
            var card_wi = 160;
            var card_hi = 140;
            var fx = window_x + (window_w - card_wi) * 0.5;
            var fy = window_y + header_h + 120;

            if (mx >= fx && mx <= fx + card_wi &&
                my >= fy && my <= fy + card_hi) {

                if (video_active) {
                    video_close();
                    video_active = false;
                }

                video_open("open_me_rickroll.mp4");
                video_set_volume(1.0);
                video_enable_loop(false);
                video_active  = true;
                open_me_stage = 1;
            }
        }
    }

    exit;
}
