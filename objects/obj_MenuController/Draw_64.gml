

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text(16, 16, "state=" + string(state) + "  exit_state=" + string(exit_state));


// Draw exit states overlay
switch (exit_state)
{
           case "confirm":
        // Darken background
        draw_set_alpha(0.7);
        draw_set_color(c_black);
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
        draw_set_alpha(1);
        
        // Draw dialog box
        var dialog_w = 500;
        var dialog_h = 250;
        var dialog_x = (display_get_gui_width() - dialog_w) * 0.5;
        var dialog_y = (display_get_gui_height() - dialog_h) * 0.5;
        
        // Panel background
        draw_set_color(make_color_rgb(28,32,38));
        draw_roundrect(dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h, false);
        
        // Panel border/shadow
        draw_set_alpha(0.3);
        draw_set_color(c_black);
        draw_roundrect(dialog_x + 4, dialog_y + 4, dialog_x + dialog_w + 4, dialog_y + dialog_h + 4, false);
        draw_set_alpha(1);
        
        // Title
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_text(dialog_x + dialog_w * 0.5, dialog_y + 40, "Exit Game");
        
        // Message
        draw_set_color(make_color_rgb(220,220,220));
        draw_set_halign(fa_center);
        draw_text(dialog_x + dialog_w * 0.5, dialog_y + 100, "Do you want to save before exiting?");
        
        // Buttons - Only Save & Exit and Exit buttons
        var btn_w = 140;
        var btn_h = 48;
        
        // Save button (Left side)
        var btn_save_x = dialog_x + 100;
        var btn_save_y = dialog_y + dialog_h - btn_h - 30;
        var save_hover = _hit({x:btn_save_x, y:btn_save_y, w:btn_w, h:btn_h}, 
                           device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
        
        draw_set_color(save_hover ? make_color_rgb(80,170,120) : make_color_rgb(230,230,230));
        draw_roundrect(btn_save_x, btn_save_y, btn_save_x + btn_w, btn_save_y + btn_h, false);
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(btn_save_x + btn_w * 0.5, btn_save_y + btn_h * 0.5, "Save & Exit");
        
        // Exit button (Right side) - Exit without saving
        var btn_exit_x = dialog_x + dialog_w - btn_w - 100;
        var btn_exit_y = dialog_y + dialog_h - btn_h - 30;
        var exit_hover = _hit({x:btn_exit_x, y:btn_exit_y, w:btn_w, h:btn_h}, 
                            device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
        
        draw_set_color(exit_hover ? make_color_rgb(200,80,80) : make_color_rgb(230,230,230));
        draw_roundrect(btn_exit_x, btn_exit_y, btn_exit_x + btn_w, btn_exit_y + btn_h, false);
        draw_set_color(c_black);
        draw_text(btn_exit_x + btn_w * 0.5, btn_exit_y + btn_h * 0.5, "Exit");
        
        // ESC instruction (centered at bottom)
        draw_set_color(make_color_rgb(150,150,150));
        draw_text(dialog_x + dialog_w * 0.5, dialog_y + dialog_h - 10, "Press ESC to cancel");
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        exit;
        
        case "save_select":
        // Darken background
        draw_set_alpha(0.7);
        draw_set_color(c_black);
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
        draw_set_alpha(1);
        
        // Draw save selection panel
        var panel_w = 900;
        var panel_h = 500;
        var panel_x = (display_get_gui_width() - panel_w) * 0.5;
        var panel_y = (display_get_gui_height() - panel_h) * 0.5;
        
        // Panel background
        draw_set_alpha(0.15); 
        draw_set_color(c_black);
        draw_roundrect(panel_x+6, panel_y+6, panel_x+panel_w+6, panel_y+panel_h+6, false);
        draw_set_alpha(1);
        
        draw_set_color(make_color_rgb(28,32,38));
        draw_roundrect(panel_x, panel_y, panel_x+panel_w, panel_y+panel_h, false);
        
        // Title
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_text(panel_x + 24, panel_y + 24, "Select Save Slot");
        
        // Draw save slots (3 slots)
        var slot_w = 240; 
        var slot_h = 240;
        var gap = 40;
        
        var start_x = panel_x + (panel_w - (3*slot_w + 2*gap)) * 0.5;
        var row_y = panel_y + 120;
        
        var save_slots = [
            {x:start_x + 0*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:1},
            {x:start_x + 1*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:2},
            {x:start_x + 2*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:3}
        ];
        
        for (var i = 0; i < array_length(save_slots); i++)
        {
            var s = save_slots[i];
            var mx = device_mouse_x_to_gui(0);
            var my = device_mouse_y_to_gui(0);
            var over = _hit(s, mx, my);
            
            // Highlight selected slot
            var is_selected = (selected_save_slot == s.idx);
            
            if (is_selected)
            {
                draw_set_color(make_color_rgb(80,200,120));
            }
            else if (over)
            {
                draw_set_color(make_color_rgb(80,170,120));
            }
            else
            {
                draw_set_color(make_color_rgb(230,230,230));
            }
            
            draw_roundrect(s.x, s.y, s.x + s.w, s.y + s.h, false);
            
            // Art placeholder
            draw_set_color(make_color_rgb(210,210,210));
            draw_roundrect(s.x + 16, s.y + 16, s.x + s.w - 16, s.y + 120, false);
            
            // Slot info
            draw_set_color(c_black);
            draw_text(s.x + 24, s.y + 24, "(art)");
            draw_text(s.x + 24, s.y + 140, "Save Slot " + string(s.idx));
            
            // Check if slot has existing save
            if (_save_exists(s.idx))
            {
                draw_set_color(make_color_rgb(100,100,100));
                draw_text(s.x + 24, s.y + 164, _get_save_date(s.idx));
            }
            else
            {
                draw_set_color(make_color_rgb(120,120,120));
                draw_text(s.x + 24, s.y + 164, "Empty");
            }
        }
        
        // Instructions - Remove Back button instructions, only show ESC
        draw_set_color(make_color_rgb(180,180,180));
        draw_set_halign(fa_center);
        draw_text(panel_x + panel_w * 0.5, panel_y + panel_h - 70, "Select a save slot to save your progress");
        draw_text(panel_x + panel_w * 0.5, panel_y + panel_h - 45, "Press ESC to go back");
        
        draw_set_halign(fa_left);
        exit;
        
    case "saving":
        // Draw saving overlay
        draw_set_alpha(0.7);
        draw_set_color(c_black);
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
        draw_set_alpha(1);
        
        var center_x = display_get_gui_width() * 0.5;
        var center_y = display_get_gui_height() * 0.5;
        
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // Success message
        draw_text(center_x, center_y - 30, "Game Saved Successfully!");
        
        // Exit message
        draw_text(center_x, center_y + 30, "Exiting game...");
        
        // Progress indicator
        var progress = 1 - (save_message_timer / (room_speed * 2));
        var bar_w = 300;
        var bar_h = 10;
        var bar_x = center_x - bar_w * 0.5;
        var bar_y = center_y + 70;
        
        draw_set_color(make_color_rgb(100,100,100));
        draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);
        
        draw_set_color(make_color_rgb(80,200,120));
        draw_rectangle(bar_x, bar_y, bar_x + bar_w * progress, bar_y + bar_h, true);
        
        // Cancel instruction
        draw_set_color(make_color_rgb(150,150,150));
        draw_text(center_x, center_y + 100, "Press ESC to cancel exit");
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        exit;
}

// Original menu drawing (only if not in exit state)
if (exit_state == "none")
{
    // narration fills full window (works for narr1 and narr2)
    if (state == "narr1" || state == "narr2") {
        var gw = display_get_gui_width(), gh = display_get_gui_height();
        draw_set_color(c_black); draw_rectangle(0,0,gw,gh,false);

        var full  = lines[line_index];
        var shown = string_copy(full, 1, floor(visible_chars));

        var tw = string_width_ext(full, 12, max_w);
        var th = string_height_ext(full, 12, max_w);
        var x_left = (gw - tw) * 0.5;
        var y_top  = (gh - th) * 0.5;

        draw_set_alpha(0.15); draw_set_color(c_black);
        draw_roundrect(x_left-18, y_top-18, x_left+tw+18, y_top+th+18, false);
        draw_set_alpha(1);

        draw_set_color(c_white);
        draw_text_ext(x_left, y_top, shown, 12, max_w);

        if (done_line) {
            draw_set_alpha(0.6);
            draw_set_halign(fa_center); draw_set_valign(fa_middle);
            draw_text(gw*0.5, y_top + th + 32, "[ click ]");
            draw_set_alpha(1);
            draw_set_halign(fa_left); draw_set_valign(fa_top);
        }
		
		draw_sprite(BacktoMenu, 0, 40, taskbar_y);
        exit;
	
    }

    // full-window panel
    var gw = display_get_gui_width(), gh = display_get_gui_height();
    draw_set_alpha(0.15); draw_set_color(c_black);
    draw_roundrect(8, 8, gw+8, gh+8, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(28,32,38));
    draw_roundrect(0, 0, gw, gh, false);
    draw_set_color(c_white);

    switch (state) {

    case "main":
        draw_text(32, 32, "Main Menu");
        for (var i = 0; i < array_length(buttons); i++) {
            var b = buttons[i];
            var over = ((device_mouse_x_to_gui(0)>=b.x)&&(device_mouse_y_to_gui(0)>=b.y)
                     && (device_mouse_x_to_gui(0)<b.x+b.w)&&(device_mouse_y_to_gui(0)<b.y+b.h));
            draw_set_color(over ? make_color_rgb(80,170,120) : make_color_rgb(230,230,230));
            draw_roundrect(b.x, b.y, b.x+b.w, b.y+b.h, false);
            draw_set_color(over ? c_white : c_black);
            draw_text(b.x + 22, b.y + 20, b.label);
        }
        
        //draw Back to Menu
        draw_sprite(ExitGame, 0, 40, taskbar_y);
        
      
    break;

    case "load":
    draw_text(32, 32, "Load Game");
    for (var s = 0; s < array_length(slots); s++) {
        var sl = slots[s];
        var over = ((device_mouse_x_to_gui(0)>=sl.x)&&(device_mouse_y_to_gui(0)>=sl.y)
                 && (device_mouse_x_to_gui(0)<sl.x+sl.w)&&(device_mouse_y_to_gui(0)<sl.y+sl.h));
        draw_set_color(over ? make_color_rgb(80,170,120) : make_color_rgb(230,230,230));
        draw_roundrect(sl.x, sl.y, sl.x+sl.w, sl.y+sl.h, false);

        draw_set_color(make_color_rgb(210,210,210));
        draw_roundrect(sl.x+22, sl.y+22, sl.x+sl.w-22, sl.y+138, false);
        draw_set_color(c_black);
        draw_text(sl.x + 30, sl.y + 30, "(art)");
        
        // Save slot title
        draw_text(sl.x + 30, sl.y + 154, "Save Slot " + string(sl.idx));
        
        // Check if slot has save data
        if (_save_exists(sl.idx))
        {
            // Show save info
            draw_set_color(make_color_rgb(60,60,60));
            draw_text(sl.x + 30, sl.y + 182, "Saved: " + _get_save_date(sl.idx));
            draw_text(sl.x + 30, sl.y + 204, "Location: " + _get_save_info(sl.idx));
            
            // Optional: Show progress
            draw_text(sl.x + 30, sl.y + 226, "Click to load");
        }
        else
        {
            draw_set_color(make_color_rgb(120,120,120));
            draw_text(sl.x + 30, sl.y + 182, "Empty Slot");
            draw_text(sl.x + 30, sl.y + 204, "No save data");
        }
    }
    var b = back_btn;
    draw_set_color(make_color_rgb(230,230,230));
    draw_roundrect(b.x, b.y, b.x+b.w, b.y+b.h, false);
    draw_set_color(c_black);
    draw_text(b.x + 18, b.y + 12, b.label);
    
    //draw Back to Menu
    draw_sprite(BacktoMenu, 0, 40, taskbar_y);
break;

    case "settings":
        draw_text(32, 32, "Settings");
        draw_text(slider.x, slider.y - 48, "Master Volume: " + string(slider_val));

        draw_set_color(make_color_rgb(210,210,210));
        draw_rectangle(slider.x, slider.y, slider.x + slider.w, slider.y + slider.h, false);

        var knob_x = slider.x + (slider_val/100) * slider.w - slider.knob_w*0.5;
        draw_set_color(make_color_rgb(80,170,120));
        draw_roundrect(knob_x, slider.y - 10, knob_x + slider.knob_w, slider.y + slider.h + 10, false);

        var bb = back_btn;
        draw_set_color(make_color_rgb(230,230,230));
        draw_roundrect(bb.x, bb.y, bb.x+bb.w, bb.y+bb.h, false);
        draw_set_color(c_black);
        draw_text(bb.x + 18, bb.y + 12, bb.label);
        
        //draw Back to Menu
        draw_sprite(BacktoMenu, 0, 40, taskbar_y);
       
       
    break;
    }
}