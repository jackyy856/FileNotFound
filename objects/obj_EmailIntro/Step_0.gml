/// obj_EmailIntro - Step

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

function _in_win(px,py){ return (px>=window_x)&&(py>=window_y)&&(px<window_x+window_w)&&(py<window_y+window_h); }
function _hit_rect(px,py,r){ return (px>=r[0])&&(py>=r[1])&&(px<r[0]+r[2])&&(py<r[1]+r[3]); }

// Prompt timer
if (prompt_timer > 0) prompt_timer--;

// If app not visible yet, do nothing until someone calls open_app()
if (!app_visible) exit;

// Clicking outside app reminds to open it (in intro desk)
if (selected_index == -1 && mouse_check_button_pressed(mb_left) && !_in_win(mx,my)) {
    _prompt("I should check my email.");
}

// Inbox navigation
if (selected_index == -1) {
    if (mouse_check_button_pressed(mb_left) &&
        mx >= list_left && mx <= list_left + list_w &&
        my >= list_top  && my <= list_top  + list_h)
    {
        var idx = floor((my - list_top) / row_h);
        if (idx >= 0 && idx < array_length(inbox)) {
            if (idx == 0) {
                selected_index = 0;
                inbox[0].read = true;
                thread_scroll = 0;
            } else {
                _prompt("Congratulations…? Another $15 gift card from Shelby over at Systems, I presume…");
            }
        }
    }
} else {
    // In email view
    if (mouse_check_button_pressed(mb_left)) {
        var clicked_link = false;
        if (!is_undefined(link_rect)) {
            if (_hit_rect(mx,my,link_rect)) clicked_link = true;
        }
        if (clicked_link) {
            // Go to narr2
            global._queued_narr_lines = [
                "What just happened?",
                "Oh right... that tech intern warned you about random links...",
                "multiple times..."
            ];
            global._queued_narr_state = "narr2";
            room_goto(room_Menu);
            exit;
        } else {
            wrong_body_clicks += 1;
            if (wrong_body_clicks == 1) {
                _prompt("Are you kidding? It’s about time I got rewarded for my work.");
            } else {
                _prompt("Redeem your reward!");
            }
        }
    }
}

