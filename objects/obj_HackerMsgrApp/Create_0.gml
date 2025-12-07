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

// dialogue choice state
choice1_active     = false; // first menu
choice2_active     = false; // second menu

choice1_opt1_text  = "What are you talking about?";
choice1_opt2_text  = "Who are you?";
choice1_opt3_text  = "...";

choice2_opt1_text  = "I’m calling the police.";
choice2_opt2_text  = "What secret?";

// conversation phase: 0 = intro part 1, 1 = post-choice1 lines, 2 = post-choice2 replies
conversation_phase = 0;


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
msg_spacing     = 18;    //30
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
        spr_pfp  = spr_pfp_hacker;   
    }
    else
    {
        col_name = make_color_rgb(40, 40, 40);
        col_pfp  = make_color_rgb(90, 160, 255);
        spr_pfp  = spr_pfp_player;   // player spr
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

// helper: recompute scroll limits so newest sits at bottom
function recalc_scroll_bounds()
{
    var count = array_length(messages);

    // message area in GUI space (mirror Draw)
    var content_x1 = win_x;
    var content_x2 = win_x + win_w;
    var content_y1 = win_y + header_h - 20;
    var content_y2 = win_y + win_h_full - footer_h;

    // reserve space for dropdown choices above the footer
    var opt_margin_bottom = 10;
    var opt_height        = 40;
    var opt_gap           = 4;

    if (choice1_active)
    {
        // 3 buttons
        var opt_total_h = opt_margin_bottom + opt_height * 3 + opt_gap * 2;
        content_y2 -= opt_total_h;
    }
    else if (choice2_active)
    {
        // 2 buttons
        var opt_total_h = opt_margin_bottom + opt_height * 2 + opt_gap;
        content_y2 -= opt_total_h;
    }

    // small extra padding so last line never sits right on the menu edge
    var extra_bottom_padding = msg_margin_top;
    content_y2 -= extra_bottom_padding;

    var view_h = max(0, content_y2 - content_y1);

    if (count <= 0)
    {
        max_scroll = 0;
        scroll     = 0;
        return;
    }

    // same geometry as Draw_64 for messages
    var pfp_radius   = 28;
    var line_sep     = 4;
    var right_margin = 32;

    // measure as if scroll = 0
    var cur_y = content_y1 + msg_margin_top;

    for (var i = 0; i < count; i++)
    {
        var msg       = messages[i];
        var msg_y_top = cur_y;

        // PFP
        var pfp_x = content_x1 + msg_margin_side + pfp_radius;
        var pfp_y = msg_y_top + pfp_radius + 8;

        // username + text
        var name_x = pfp_x + pfp_radius + 18;
        var name_y = msg_y_top - 2;

        var text_x = name_x;
        var text_y = name_y + 20;

        var right_limit = content_x2 - right_margin;
        var wrap_width  = max(10, right_limit - text_x);

        var text_h      = string_height_ext(msg.text, line_sep, wrap_width);
        var text_bottom = text_y + text_h;
        var pfp_bottom  = pfp_y + pfp_radius;
        var row_bottom  = max(text_bottom, pfp_bottom);

        var row_height  = (row_bottom - msg_y_top) + msg_spacing;
        cur_y += row_height;
    }

    var content_h = cur_y - content_y1;

    max_scroll = max(0, content_h - view_h);
    scroll     = max_scroll;
}

// ----------------
// intro conversation state
// ----------------

// phase 0: first 3 hacker lines
intro_messages = [
    { sender: "UrHacker", text: "took you long enough to open this. I was starting to think you’d just ignore my message.", is_hacker: true },
    { sender: "UrHacker", text: "But now that we’re here… I'll get to the point.", is_hacker: true },
    { sender: "UrHacker", text: "i know ur hiding something in this machine. i’m going to find it.", is_hacker: true }
];

intro_index      = 0;
intro_active     = true;
typing           = true;
intro_timer_ms   = 3500;   // 3.5s per line
has_any_message  = false;
