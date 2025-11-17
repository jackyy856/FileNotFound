
// ----------------
// window size / pos
// ----------------
win_w      = 900;       //560
win_h_full = 600;        // 380 
win_h      = win_h_full;

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

win_x = (gui_w - win_w) * 0.5;
win_y = (gui_h - win_h) * 0.5;

// layout
header_h = round(win_h_full * 0.10); 
footer_h = round(win_h_full / 12);   

// state
minimized = false;

// dragging
dragging = false;
drag_dx  = 0;
drag_dy  = 0;

// button rects
btn_close_x1 = 0;
btn_close_y1 = 0;
btn_close_x2 = 0;
btn_close_y2 = 0;

btn_min_x1   = 0;
btn_min_y1   = 0;
btn_min_x2   = 0;
btn_min_y2   = 0;


// ----------------
// Message layout
// ----------------
msg_margin_top  = 8;     //0
msg_margin_side = 10;  
msg_spacing     = 8;    //30
msg_row_h       = 90;   //80 


scroll      = 0;     
max_scroll  = 0;

// message data
messages = [];          




// helper: add one message
function add_message(_user, _text, _is_hacker)
{
    var col_name;
    var col_pfp;
    var spr_pfp;

    if (_is_hacker)
    {
        col_name = make_color_rgb(0, 220, 180);
        col_pfp  = make_color_rgb(255, 90, 90);
        spr_pfp  = spr_pfp_hacker;   // hacker sprite
    }
    else
    {
        col_name = make_color_rgb(40, 40, 40);
        col_pfp  = make_color_rgb(90, 160, 255);
        spr_pfp  = spr_pfp_player;   // player sprite
    }

    var msg = {
        user    : _user,
        text    : _text,
        col_name: col_name,
        col_pfp : col_pfp,
        spr_pfp : spr_pfp
    };

    var len = array_length(messages);
    messages[len] = msg;
}


/*// helper: recompute scroll limits so newest sits at bottom
function recalc_scroll_bounds()
{
    var count       = array_length(messages);
    var msg_total_h = msg_row_h + msg_spacing;
    var content_h   = msg_margin_top * 2 + count * msg_total_h;

    var content_y1  = win_y + header_h;
    var content_y2  = win_y + win_h_full - footer_h;
    var view_h      = max(0, content_y2 - content_y1);

    max_scroll = max(0, content_h - view_h);

    // place view at bottom so newest message is at bottom
    scroll = max_scroll;
}
*/

// helper: recompute scroll limits so newest sits at bottom
function recalc_scroll_bounds()
{
    var count = array_length(messages);

    // message area in GUI space
    var content_y1 = win_y + header_h - 20;            
    var content_y2 = win_y + win_h_full - footer_h;
    var view_h     = max(0, content_y2 - content_y1);

    if (count <= 0)
    {
        max_scroll = 0;
        scroll     = 0;
        return;
    }

    var pfp_radius   = 28;
    var line_sep     = 4;
    var right_margin = 32;

    // start under header
    var cur_y = content_y1 + msg_margin_top;

    for (var i = 0; i < count; i++)
    {
        var msg       = messages[i];
        var msg_y_top = cur_y;

        // horizontal layout
        var pfp_x   = win_x + msg_margin_side + pfp_radius;
        var name_x  = pfp_x + pfp_radius + 18;
        var text_x  = name_x;
        var right_limit = win_x + win_w - right_margin;
        var wrap_width  = max(10, right_limit - text_x);

        // vertical layout
        var name_y  = msg_y_top - 2;
        var text_y  = name_y + 20;

        // height of wrapped text 
        var text_h      = string_height_ext(msg.text, line_sep, wrap_width);
        var text_bottom = text_y + text_h;

        var pfp_y      = msg_y_top + pfp_radius + 8;
        var pfp_bottom = pfp_y + pfp_radius;

        var row_bottom = max(text_bottom, pfp_bottom);

        var row_height = (row_bottom - msg_y_top) + msg_spacing;

        cur_y += row_height;
    }

    var content_h = (cur_y - (content_y1 + msg_margin_top)) + msg_margin_top;

    max_scroll = max(0, content_h - view_h);
    scroll     = max_scroll;
}


// ----------------
// placeholder convo
// ----------------
add_message("HACKER", "took you long enough to get here. i was starting to think you'd just ignore my messages lol.", true);
add_message("HACKER", "but now that we’re here… i'll get to the point. ", true);
add_message("HACKER", "somewhere in this machine, there’s a file that documents your secret. i'm gonna find it. ", true);
add_message("You",    "What are you talking about?", false);
add_message("HACKER", "b4 u think you can just go and erase it.. ", true);
add_message("HACKER", "u downloaded a virus that has changed all ur passwords… to things in your computer.", true);
add_message("HACKER", "so if you want ur file… try to decipher them before I got to it and share it with the world x_x =) ", true);
add_message("You",    "What file?", false);


recalc_scroll_bounds();

