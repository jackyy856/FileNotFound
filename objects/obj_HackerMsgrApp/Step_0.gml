var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var x1 = win_x;
var y1 = win_y;
var x2 = win_x + win_w;
var y2 = win_y + win_h;

var header_bottom   = y1 + header_h - 20;
var header_vis_h    = header_bottom - y1;         
var footer_top_full = win_y + win_h_full - footer_h; 

// ----------------
// buttons
// ----------------
var btn_margin = 8;
var btn_size   = max(12, header_vis_h - btn_margin * 2); // keep in header

// Close "x" button 
btn_close_x2 = x2 - btn_margin ;
btn_close_x1 = btn_close_x2 - btn_size;
btn_close_y1 = y1 + btn_margin;
btn_close_y2 = btn_close_y1 + btn_size;

// minimize button
btn_min_x2 = btn_close_x1 - btn_margin;
btn_min_x1 = btn_min_x2 - btn_size;
btn_min_y1 = btn_close_y1;
btn_min_y2 = btn_close_y2;

// ----------------
// mouse press: buttons + drag start
// ----------------
if (mouse_check_button_pressed(mb_left))
{
    // close
    if (mx >= btn_close_x1 && mx <= btn_close_x2 &&
        my >= btn_close_y1 && my <= btn_close_y2)
    {
        instance_destroy();
    }
    // minimize
    else if (mx >= btn_min_x1 && mx <= btn_min_x2 &&
             my >= btn_min_y1 && my <= btn_min_y2)
    {
        minimized = !minimized;
        win_h     = minimized ? header_vis_h : win_h_full; // only show visible header when minimized
    }
    // drag start in header area
    else if (mx >= x1 && mx <= x2 &&
             my >= y1 && my <= header_bottom)
    {
        dragging = true;
        drag_dx  = mx - win_x;
        drag_dy  = my - win_y;
    }
}

// stop dragging
if (!mouse_check_button(mb_left))
{
    dragging = false;
}

// drag move
if (dragging)
{
    win_x = mx - drag_dx;
    win_y = my - drag_dy;
}

// dropdown choice click
if (!minimized && (choice1_active || choice2_active) && mouse_check_button_pressed(mb_left))
{
    var opt_margin_side   = 16;
    var opt_margin_bottom = 10;
    var opt_height        = 40;
    var opt_gap           = 4;

    var opt_width = (x2 - x1) - opt_margin_side * 2;
    var opt_x1    = x1 + opt_margin_side;
    var opt_x2    = opt_x1 + opt_width;

    if (choice1_active)
    {
        // 3-button layout for first menu
        var opt3_y2 = footer_top_full - opt_margin_bottom;
        var opt3_y1 = opt3_y2 - opt_height;

        var opt2_y2 = opt3_y1 - opt_gap;
        var opt2_y1 = opt2_y2 - opt_height;

        var opt1_y2 = opt2_y1 - opt_gap;
        var opt1_y1 = opt1_y2 - opt_height;

        if (mx >= opt_x1 && mx <= opt_x2)
        {
            var picked_text = "";

            if (my >= opt1_y1 && my <= opt1_y2)
            {
                picked_text = choice1_opt1_text;
            }
            else if (my >= opt2_y1 && my <= opt2_y2)
            {
                picked_text = choice1_opt2_text;
            }
            else if (my >= opt3_y1 && my <= opt3_y2)
            {
                picked_text = choice1_opt3_text;
            }

            if (picked_text != "")
            {
                // player response (all three lead to same outcome)
                add_message("You", picked_text, false);
                recalc_scroll_bounds();

                choice1_active    = false;
                conversation_phase = 1;

                // phase 1: next 3 hacker lines
                intro_messages = [
                    { sender: "UrHacker", text: "b4 u think you can just go and erase it..", is_hacker: true },
                    { sender: "UrHacker", text: "u downloaded a virus that has changed all ur passwords… to things in your computer.", is_hacker: true },
                    { sender: "UrHacker", text: "so if you want ur file… try to decipher them before I get to it and share it with the world x_x =)", is_hacker: true }
                ];

                intro_index    = 0;
                intro_active   = true;
                typing         = true;
                intro_timer_ms = 2500;
            }
        }
    }
    else if (choice2_active)
    {
        // 2-button layout for second menu
        var opt2_y2 = footer_top_full - opt_margin_bottom;
        var opt2_y1 = opt2_y2 - opt_height;

        var opt1_y2 = opt2_y1 - opt_gap;
        var opt1_y1 = opt1_y2 - opt_height;

        if (mx >= opt_x1 && mx <= opt_x2)
        {
            if (my >= opt1_y1 && my <= opt1_y2)
            {
                // "I’m calling the police."
                add_message("You", choice2_opt1_text, false);
                recalc_scroll_bounds();

                choice2_active    = false;
                conversation_phase = 2;

                intro_messages = [
                    { sender: "UrHacker", text: "Try that and I won’t even give you a chance to find the file, lol (⌒‿⌒)", is_hacker: true },
                    { sender: "UrHacker", text: "Whatever you do, don’t look for external help. I’ll know and you won’t be able to fix this.", is_hacker: true }
                ];

                intro_index    = 0;
                intro_active   = true;
                typing         = true;
                intro_timer_ms = 2500;
            }
            else if (my >= opt2_y1 && my <= opt2_y2)
            {
                // "What secret?"
                add_message("You", choice2_opt2_text, false);
                recalc_scroll_bounds();

                choice2_active    = false;
                conversation_phase = 2;

                intro_messages = [
                    { sender: "UrHacker", text: "You don’t know your own secret? Don’t play dumb.", is_hacker: true },
                    { sender: "UrHacker", text: "Whatever you do, don’t look for external help. I’ll know and you won’t be able to fix this.", is_hacker: true }
                ];

                intro_index    = 0;
                intro_active   = true;
                typing         = true;
                intro_timer_ms = 2500;
            }
        }
    }
}



// ----------------
// scroll (mouse wheel) – only when not minimized
// -----------------

if (!minimized && max_scroll > 0)
{
    var step_px = 18;

    if (mouse_wheel_up())
    {
        scroll = max(0, scroll - step_px);
    }
    if (mouse_wheel_down())
    {
        scroll = min(max_scroll, scroll + step_px);
    }
}


// ----------------
// intro auto-messages with typing
// ----------------
if (intro_active)
{
    var dt_ms = delta_time / 1000;
    intro_timer_ms -= dt_ms;

    if (intro_timer_ms <= 0)
    {
        if (intro_index < array_length(intro_messages))
        {
            var m = intro_messages[intro_index];

            add_message(m.sender, m.text, m.is_hacker);
            recalc_scroll_bounds();
            has_any_message = true;

            intro_index++;

            if (intro_index < array_length(intro_messages))
            {
                typing         = true;
                intro_timer_ms = 2500;
            }
            else
            {
                // finished current queue
				typing       = false;
				intro_active = false;

				switch (conversation_phase)
				{
				    case 0:
				        // finished first 3 hacker lines -> show first menu
				        choice1_active = true;
				        recalc_scroll_bounds();
				        break;

				    case 1:
				        // finished "b4 u think..." block -> show second menu
				        choice2_active = true;
				        recalc_scroll_bounds();
				        break;

				    case 2:
				        // finished final replies 
				        break;
				}
            }
        }
        else
        {
            // safety: no messages left
            typing       = false;
			intro_active = false;

			switch (conversation_phase)
			{
			    case 0:
			        choice1_active = true;
			        recalc_scroll_bounds();
			        break;

			    case 1:
			        choice2_active = true;
			        recalc_scroll_bounds();
			        break;

			    case 2:
			        break;
			}
        }
    }
}
