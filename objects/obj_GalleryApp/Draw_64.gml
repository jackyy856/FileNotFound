if (gallery_open) {
    // Draw window background
    draw_set_color(c_white);
    draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, false);
    
    // Draw header
    draw_set_color(c_dkgray);
    draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, false);
    
    // Draw title
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(window_x + window_w/2, window_y + header_h/2, "Gallery");
    
    // Draw close button
    draw_set_color(c_red);
    draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], false);
    draw_set_color(c_white);
    draw_text(close_btn[0] + close_btn[2]/2, close_btn[1] + close_btn[3]/2, "X");

    if (!fullscreen_mode) {
        // Draw file browser style
        draw_set_color(c_black);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        
        // Draw column headers
        draw_set_color(c_gray);
        draw_rectangle(files_left, files_top, files_left + files_width, files_top + 24, false);
        draw_set_color(c_black);
        draw_text(files_left + 10, files_top + 12, "Name");
        draw_text(files_left + files_width - 100, files_top + 12, "Date");
        
        var file_y = files_top + 40;  
        for (var i = 0; i < total_images; i++) {
            var is_hover = (get_clicked_file(mouse_x, mouse_y) == i);
            var is_selected = (i == current_image_index);
            
            // Draw file row background
            if (is_selected) {
                draw_set_color(c_blue);
                draw_rectangle(files_left, file_y, files_left + files_width, file_y + row_height, false);
                draw_set_color(c_white);
            } else if (is_hover) {
                draw_set_color(c_ltgray);
                draw_rectangle(files_left, file_y, files_left + files_width, file_y + row_height, false);
                draw_set_color(c_black);
            } else if (i % 2 == 0) {
                draw_set_color(c_white);
                draw_rectangle(files_left, file_y, files_left + files_width, file_y + row_height, false);
                draw_set_color(c_black);
            } else {
                draw_set_color(c_white);
                draw_rectangle(files_left, file_y, files_left + files_width, file_y + row_height, false);
                draw_set_color(c_black);
            }
            
            // Draw file icon
            var icon_size = 28;
            var img_sprite = gallery_images[i].sprite;
            if (sprite_exists(img_sprite)) {
                var scale = icon_size / max(sprite_get_width(img_sprite), sprite_get_height(img_sprite));
                draw_sprite_ext(img_sprite, 0, files_left + 30, file_y + row_height/2, scale, scale, 0, c_white, 1);
            }
            
            // Draw file name
            draw_text(files_left + 50, file_y + row_height/2, gallery_images[i].name);
            
            // Draw date
            draw_set_halign(fa_right);
            draw_text(files_left + files_width - 15, file_y + row_height/2, gallery_images[i].date);
            draw_set_halign(fa_left);
            
            file_y += (row_height + 6);
        }
        
    } else {
        // Draw fullscreen view background
        draw_set_color(c_black);
        draw_rectangle(window_x + 10, window_y + header_h + 10, window_x + window_w - 10, window_y + window_h - 10, false);
        
        // Draw image with pan and zoom - AUTO-SIZED AND CENTERED
        if (current_image_index >= 0 && current_image_index < total_images) {
            var current_img = gallery_images[current_image_index].sprite;
            
            if (sprite_exists(current_img)) {
                var img_width = sprite_get_width(current_img);
                var img_height = sprite_get_height(current_img);
                
                // Calculate available display area (with margins)
                var display_x = window_x + 10;
                var display_y = window_y + header_h + 10;
                var display_width = window_w - 20;
                var display_height = window_h - header_h - 20;
                
                // Calculate center of display area
                var center_x = display_x + display_width / 2;
                var center_y = display_y + display_height / 2;
                
                // Draw image perfectly centered with zoom and pan
                draw_sprite_ext(current_img, 0, center_x + pan_x, center_y + pan_y, zoom_scale, zoom_scale, 0, c_white, 1);
            }
        }
        
        // Draw back button
        draw_set_color(c_white);
        draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], false);
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_text(back_btn[0] + back_btn[2]/2, back_btn[1] + back_btn[3]/2, "<");

        // Draw navigation arrows
        draw_set_color(c_white);
        draw_rectangle(left_btn[0], left_btn[1], left_btn[0] + left_btn[2], left_btn[1] + left_btn[3], false);
        draw_rectangle(right_btn[0], right_btn[1], right_btn[0] + right_btn[2], right_btn[1] + right_btn[3], false);
        draw_set_color(c_black);
        draw_text(left_btn[0] + left_btn[2]/2, left_btn[1] + left_btn[3]/2, "<");
        draw_text(right_btn[0] + right_btn[2]/2, right_btn[1] + right_btn[3]/2, ">");

        // DRAW ZOOM BUTTONS
        draw_set_color(c_white);
        draw_rectangle(zoom_in_btn[0], zoom_in_btn[1], zoom_in_btn[0] + zoom_in_btn[2], zoom_in_btn[1] + zoom_in_btn[3], false);
        draw_rectangle(zoom_out_btn[0], zoom_out_btn[1], zoom_out_btn[0] + zoom_out_btn[2], zoom_out_btn[1] + zoom_out_btn[3], false);
        draw_rectangle(zoom_reset_btn[0], zoom_reset_btn[1], zoom_reset_btn[0] + zoom_reset_btn[2], zoom_reset_btn[1] + zoom_reset_btn[3], false);
        
        draw_set_color(c_black);
        draw_text(zoom_in_btn[0] + zoom_in_btn[2]/2, zoom_in_btn[1] + zoom_in_btn[3]/2, "+");
        draw_text(zoom_out_btn[0] + zoom_out_btn[2]/2, zoom_out_btn[1] + zoom_out_btn[3]/2, "-");
        draw_text(zoom_reset_btn[0] + zoom_reset_btn[2]/2, zoom_reset_btn[1] + zoom_reset_btn[3]/2, "R");
        
        // Draw image info
        if (current_image_index >= 0 && current_image_index < total_images) {
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_text(window_x + window_w/2, window_y + window_h - 30, 
                     gallery_images[current_image_index].name + " (" + string(current_image_index + 1) + "/" + string(total_images) + ")");
           
        }
    }
    
    // Reset drawing settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}