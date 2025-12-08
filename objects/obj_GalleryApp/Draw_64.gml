/// obj_GalleryApp - Draw GUI
if (gallery_open) {
    
    if (puzzle_mode) {
        // Puzzle-mode header/back handled here
        draw_set_color(c_red);
        draw_rectangle(close_btn[0], close_btn[1],
                       close_btn[0] + close_btn[2],
                       close_btn[1] + close_btn[3], false);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(close_btn[0] + close_btn[2] / 2,
                  close_btn[1] + close_btn[3] / 2, "X");
        
        var back_col = make_colour_rgb(230,230,230);
        draw_set_color(back_col);
        draw_rectangle(back_btn[0], back_btn[1],
                       back_btn[0] + back_btn[2],
                       back_btn[1] + back_btn[3], false);
        draw_set_color(c_black);
        draw_rectangle(back_btn[0], back_btn[1],
                       back_btn[0] + back_btn[2],
                       back_btn[1] + back_btn[3], true);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(back_btn[0] + back_btn[2] / 2,
                  back_btn[1] + back_btn[3] / 2, "Back");
    }
    else if (inbox_mode) {
        // =======================
        //  INBOX / RED KEY SCREEN
        // =======================
        
        // Window background
        draw_set_color(c_white);
        draw_rectangle(window_x, window_y,
                       window_x + window_w, window_y + window_h, false);
        
        // Header
        draw_set_color(c_dkgray);
        draw_rectangle(window_x, window_y,
                       window_x + window_w, window_y + header_h, false);
        
        // Title (centered)
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(window_x + window_w / 2,
                  window_y + header_h / 2, "Inbox");
        
        // Close button
        draw_set_color(c_red);
        draw_rectangle(close_btn[0], close_btn[1],
                       close_btn[0] + close_btn[2],
                       close_btn[1] + close_btn[3], false);
        draw_set_color(c_white);
        draw_text(close_btn[0] + close_btn[2] / 2,
                  close_btn[1] + close_btn[3] / 2, "X");
        
        // Inbox Back button (now inside white content area)
        var back_col_inbox = make_colour_rgb(230,230,230);
        draw_set_color(back_col_inbox);
        draw_rectangle(inbox_back_btn[0], inbox_back_btn[1],
                       inbox_back_btn[0] + inbox_back_btn[2],
                       inbox_back_btn[1] + inbox_back_btn[3], false);
        draw_set_color(c_black);
        draw_rectangle(inbox_back_btn[0], inbox_back_btn[1],
                       inbox_back_btn[0] + inbox_back_btn[2],
                       inbox_back_btn[1] + inbox_back_btn[3], true);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(inbox_back_btn[0] + inbox_back_btn[2] / 2,
                  inbox_back_btn[1] + inbox_back_btn[3] / 2, "< Back");
        
        // Message text (scaled slightly bigger)
        var msg_x = window_x + 140;
        var msg_y = window_y + header_h + 120;
        
        draw_set_color(c_black);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        draw_text_transformed(msg_x, msg_y,
                              "here's ur second key loser",
                              1.4, 1.4, 0);
        draw_text_transformed(msg_x, msg_y + 60,
                              "don't expect to get the last one as easily, bitch",
                              1.4, 1.4, 0);
        draw_text_transformed(msg_x, msg_y + 120,
                              "(=^-ω-^=)",
                              1.4, 1.4, 0);
        
        // Hint text
        draw_set_halign(fa_center);
        draw_text(window_x + window_w / 2,
                  window_y + window_h - 60,
                  "Click the key to add it to your collection.");
        draw_set_halign(fa_left);
        
        // Draw red key sprite next to the text (similar to EmailApp)
        // Choose key sprite (glow variant if collected) - use local variable for immediate feedback
        var key_spr = inbox_key_collected ? spr_red_glow_key : spr_red_key;
        
        if (key_spr != -1) {
            var raw_w = sprite_get_width(key_spr);
            var raw_h = sprite_get_height(key_spr);
            
            // Scale down to desired height (like EmailApp uses 64, but we want bigger)
            var desired_h = 96;
            var key_scale = (raw_h > 0) ? (desired_h / raw_h) : 1;
            
            var key_w = raw_w * key_scale;
            var key_h = raw_h * key_scale;
            
            // Position key to the right of the text (after the last line)
            var line3_text = "(=^-ω-^=)";
            var gap = 20; // space between text and key
            // Calculate scaled text width (text is drawn with 1.4x scale)
            var text_width = string_width(line3_text) * 1.4;
            var key_x = msg_x + text_width + gap;
            var key_y = msg_y + 120 - key_h * 0.4; // align with text baseline
            
            // Store rect for Step click detection (like EmailApp does)
            inbox_key_rect = [key_x, key_y, key_w, key_h];
            
            // Draw key sprite
            draw_sprite_ext(key_spr, 0, key_x, key_y, key_scale, key_scale, 0, c_white, 1);
        }
    }
    else if (!fullscreen_mode) {
        // =======================
        //  BROWSER / LIST VIEW
        // =======================
        
        // Draw window background
        draw_set_color(c_white);
        draw_rectangle(window_x, window_y,
                       window_x + window_w, window_y + window_h, false);
        
        // Draw header
        draw_set_color(c_dkgray);
        draw_rectangle(window_x, window_y,
                       window_x + window_w, window_y + header_h, false);
        
        // Draw title
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(window_x + window_w / 2,
                  window_y + header_h / 2, "Gallery");
        
        // Draw close button
        draw_set_color(c_red);
        draw_rectangle(close_btn[0], close_btn[1],
                       close_btn[0] + close_btn[2],
                       close_btn[1] + close_btn[3], false);
        draw_set_color(c_white);
        draw_text(close_btn[0] + close_btn[2] / 2,
                  close_btn[1] + close_btn[3] / 2, "X");
        
        // Draw file browser style
        draw_set_color(c_black);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        
        // Draw column headers
        draw_set_color(c_gray);
        draw_rectangle(files_left, files_top,
                       files_left + files_width, files_top + 24, false);
        draw_set_color(c_black);
        draw_text(files_left + 10,  files_top + 12, "Name");
        draw_text(files_left + files_width - 100, files_top + 12, "Date");
        
        var file_y = files_top + 40;  
        for (var i = 0; i < total_images; i++) {
            var gmx = device_mouse_x_to_gui(0);
            var gmy = device_mouse_y_to_gui(0);
            var is_hover    = (get_clicked_file(gmx, gmy) == i);
            var is_selected = (i == current_image_index);
            
            // Draw file row background
            if (is_selected) {
                draw_set_color(c_blue);
                draw_rectangle(files_left, file_y,
                               files_left + files_width,
                               file_y + row_height, false);
                draw_set_color(c_white);
            } else if (is_hover) {
                draw_set_color(c_ltgray);
                draw_rectangle(files_left, file_y,
                               files_left + files_width,
                               file_y + row_height, false);
                draw_set_color(c_black);
            } else if (i % 2 == 0) {
                draw_set_color(c_white);
                draw_rectangle(files_left, file_y,
                               files_left + files_width,
                               file_y + row_height, false);
                draw_set_color(c_black);
            } else {
                draw_set_color(c_white);
                draw_rectangle(files_left, file_y,
                               files_left + files_width,
                               file_y + row_height, false);
                draw_set_color(c_black);
            }
            
            // Draw file icon
            var icon_size  = 28;
            var img_sprite = gallery_images[i].sprite;
            if (sprite_exists(img_sprite)) {
                var scale = icon_size /
                    max(sprite_get_width(img_sprite),
                        sprite_get_height(img_sprite));
                draw_sprite_ext(img_sprite, 0,
                                files_left + 30, file_y + row_height / 2,
                                scale, scale, 0, c_white, 1);
            }
            
            // Draw file name
            draw_text(files_left + 50,
                      file_y + row_height / 2,
                      gallery_images[i].name);
            
            // Draw date
            draw_set_halign(fa_right);
            draw_text(files_left + files_width - 15,
                      file_y + row_height / 2,
                      gallery_images[i].date);
            draw_set_halign(fa_left);
            
            file_y += (row_height + 6);
        }
        
    } else {
        // =======================
        //  FULLSCREEN IMAGE VIEW
        // =======================
        
        // Draw window background
        draw_set_color(c_white);
        draw_rectangle(window_x, window_y,
                       window_x + window_w, window_y + window_h, false);
        
        // Draw header
        draw_set_color(c_dkgray);
        draw_rectangle(window_x, window_y,
                       window_x + window_w, window_y + header_h, false);
        
        // Draw title
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(window_x + window_w / 2,
                  window_y + header_h / 2, "Gallery");
        
        // Draw close button
        draw_set_color(c_red);
        draw_rectangle(close_btn[0], close_btn[1],
                       close_btn[0] + close_btn[2],
                       close_btn[1] + close_btn[3], false);
        draw_set_color(c_white);
        draw_text(close_btn[0] + close_btn[2] / 2,
                  close_btn[1] + close_btn[3] / 2, "X");
        
        // Draw fullscreen view background
        draw_set_color(c_black);
        draw_rectangle(window_x + 10, window_y + header_h + 10,
                       window_x + window_w - 10,
                       window_y + window_h - 10, false);
        
        // Draw image with pan and zoom
        if (current_image_index >= 0 && current_image_index < total_images) {
            var current_img = gallery_images[current_image_index].sprite;
            
            if (sprite_exists(current_img)) {
                var img_width  = sprite_get_width(current_img);
                var img_height = sprite_get_height(current_img);
                
                // Calculate available display area
                var display_x      = window_x + 10;
                var display_y      = window_y + header_h + 10;
                var display_width  = window_w - 20;
                var display_height = window_h - header_h - 20;
                
                // Calculate center of display area
                var center_x = display_x + display_width / 2;
                var center_y = display_y + display_height / 2;
                
                // Draw image perfectly centered with zoom and pan
                draw_sprite_ext(current_img, 0,
                                center_x + pan_x, center_y + pan_y,
                                zoom_scale, zoom_scale,
                                0, c_white, 1);
            }
        }
        
        // Draw back button
        var back_col_fs = make_colour_rgb(230,230,230);
        draw_set_color(back_col_fs);
        draw_rectangle(back_btn[0], back_btn[1],
                       back_btn[0] + back_btn[2],
                       back_btn[1] + back_btn[3], false);
        draw_set_color(c_black);
        draw_rectangle(back_btn[0], back_btn[1],
                       back_btn[0] + back_btn[2],
                       back_btn[1] + back_btn[3], true);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(back_btn[0] + back_btn[2] / 2,
                  back_btn[1] + back_btn[3] / 2, "< Back");

        // Draw navigation arrows
        draw_set_color(c_white);
        draw_rectangle(left_btn[0], left_btn[1],
                       left_btn[0] + left_btn[2],
                       left_btn[1] + left_btn[3], false);
        draw_rectangle(right_btn[0], right_btn[1],
                       right_btn[0] + right_btn[2],
                       right_btn[1] + right_btn[3], false);
        draw_set_color(c_black);
        draw_text(left_btn[0] + left_btn[2] / 2,
                  left_btn[1] + left_btn[3] / 2, "<");
        draw_text(right_btn[0] + right_btn[2] / 2,
                  right_btn[1] + right_btn[3] / 2, ">");
        
        // DRAW ZOOM BUTTONS
        draw_set_color(c_white);
        draw_rectangle(zoom_in_btn[0], zoom_in_btn[1],
                       zoom_in_btn[0] + zoom_in_btn[2],
                       zoom_in_btn[1] + zoom_in_btn[3], false);
        draw_rectangle(zoom_out_btn[0], zoom_out_btn[1],
                       zoom_out_btn[0] + zoom_out_btn[2],
                       zoom_out_btn[1] + zoom_out_btn[3], false);
        draw_rectangle(zoom_reset_btn[0], zoom_reset_btn[1],
                       zoom_reset_btn[0] + zoom_reset_btn[2],
                       zoom_reset_btn[1] + zoom_reset_btn[3], false);
        
        draw_set_color(c_black);
        draw_text(zoom_in_btn[0] + zoom_in_btn[2] / 2,
                  zoom_in_btn[1] + zoom_in_btn[3] / 2, "+");
        draw_text(zoom_out_btn[0] + zoom_out_btn[2] / 2,
                  zoom_out_btn[1] + zoom_out_btn[3] / 2, "-");
        draw_text(zoom_reset_btn[0] + zoom_reset_btn[2] / 2,
                  zoom_reset_btn[1] + zoom_reset_btn[3] / 2, "R");
        
        // Draw image info
        if (current_image_index >= 0 && current_image_index < total_images) {
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(window_x + window_w / 2,
                      window_y + window_h - 30,
                     gallery_images[current_image_index].name
                     + " (" + string(current_image_index + 1) + "/"
                     + string(total_images) + ")");
        }
    }
    
    // Reset drawing settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
