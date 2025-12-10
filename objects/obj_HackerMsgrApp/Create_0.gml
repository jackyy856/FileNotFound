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
choice_active   = false;  // any menu visible?
choice_menu_id  = 0;      // 0 = none, 1/2/3/... = which menu
choice_options  = [];     // arr of strs

// text constants for specific menus
// menu 1
choice1_opt1_text  = "What are you talking about?";
choice1_opt2_text  = "Who are you?";
choice1_opt3_text  = "...";

// menu 2
choice2_opt1_text  = "I'm calling the police.";
choice2_opt2_text  = "What secret?";

// menu 3
choice3_opt1_text  = "Don't leave yet.";
choice3_opt2_text  = "Answer my questions first.";
choice3_opt3_text  = "Why are you doing this?";

// conversation phase:
// 0 = intro part 1,
// 1 = post-choice1 lines,
// 2 = post-choice2 replies,
// 3 = final farewell lines
conversation_phase = 0;



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

        // only flag unread if window
        // is not currently open in front of player
        if (minimized || !visible)
        {
            global.hacker_unread = true;
        }
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

    // reserve space for dropdown choices above the footer (generic)
    var opt_margin_bottom = 10;
    var opt_height        = 40;
    var opt_gap           = 4;

    if (choice_active)
    {
        var opt_count = array_length(choice_options);
        if (opt_count > 0)
        {
            var opt_total_h = opt_margin_bottom
                            + opt_height * opt_count
                            + opt_gap * max(0, opt_count - 1);
            content_y2 -= opt_total_h;
        }
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

    // *** keep the rest of your existing recalc_scroll_bounds code here ***
    // (pfp_radius, line_sep, loop over messages to compute content_h, etc.)


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
    { sender: "UrHacker", text: "took you long enough to open this. i was starting to think u'd just ignore my message.", is_hacker: true },
    { sender: "UrHacker", text: "but now that we're here… i'll get to the point.", is_hacker: true },
    { sender: "UrHacker", text: "i know ur hiding something in this machine. i’m going to find it.", is_hacker: true }
];

intro_index      = 0;
intro_active     = true;
typing           = true;
intro_timer_ms   = 3500;   // 3.5s per line
has_any_message  = false;
hacker_offline = false;

// ---- Save/load helpers for messenger state ----
function _save_state_blob() {
    return {
        win_x             : win_x,
        win_y             : win_y,
        win_w             : win_w,
        win_h_full        : win_h_full,
        win_h             : win_h,
        minimized         : minimized,
        visible           : visible,
        messages          : messages,
        conversation_phase: conversation_phase,
        intro_messages    : intro_messages,
        intro_index       : intro_index,
        intro_active      : intro_active,
        typing            : typing,
        intro_timer_ms    : intro_timer_ms,
        has_any_message   : has_any_message,
        hacker_offline    : hacker_offline,
        choice_active     : choice_active,
        choice_menu_id    : choice_menu_id,
        choice_options    : choice_options,
        scroll            : scroll,
        max_scroll        : max_scroll
    };
}

function _apply_state_blob(blob) {
    if (!is_struct(blob)) return;

    // geometry first so scroll calcs use latest layout
    if (variable_struct_exists(blob, "win_x")) win_x = blob.win_x;
    if (variable_struct_exists(blob, "win_y")) win_y = blob.win_y;
    if (variable_struct_exists(blob, "win_w")) win_w = blob.win_w;
    if (variable_struct_exists(blob, "win_h_full")) win_h_full = blob.win_h_full;
    if (variable_struct_exists(blob, "win_h")) win_h = blob.win_h;
    if (variable_struct_exists(blob, "minimized")) minimized = blob.minimized;
    if (variable_struct_exists(blob, "visible")) visible = blob.visible;

    if (variable_struct_exists(blob, "messages")) messages = blob.messages;
    if (variable_struct_exists(blob, "conversation_phase")) conversation_phase = blob.conversation_phase;
    if (variable_struct_exists(blob, "intro_messages")) intro_messages = blob.intro_messages;
    if (variable_struct_exists(blob, "intro_index")) intro_index = blob.intro_index;
    if (variable_struct_exists(blob, "intro_active")) intro_active = blob.intro_active;
    if (variable_struct_exists(blob, "typing")) typing = blob.typing;
    if (variable_struct_exists(blob, "intro_timer_ms")) intro_timer_ms = blob.intro_timer_ms;
    if (variable_struct_exists(blob, "has_any_message")) has_any_message = blob.has_any_message;
    if (variable_struct_exists(blob, "hacker_offline")) hacker_offline = blob.hacker_offline;
    if (variable_struct_exists(blob, "choice_active")) choice_active = blob.choice_active;
    if (variable_struct_exists(blob, "choice_menu_id")) choice_menu_id = blob.choice_menu_id;
    if (variable_struct_exists(blob, "choice_options")) choice_options = blob.choice_options;
    if (variable_struct_exists(blob, "scroll")) scroll = blob.scroll;
    if (variable_struct_exists(blob, "max_scroll")) max_scroll = blob.max_scroll;

    recalc_scroll_bounds();
}

// Apply any state saved while this app instance was missing
if (variable_global_exists("_pending_save_chunks") && is_struct(global._pending_save_chunks)) {
    if (variable_struct_exists(global._pending_save_chunks, "hacker_state")
    && !is_undefined(global._pending_save_chunks.hacker_state)) {
        _apply_state_blob(global._pending_save_chunks.hacker_state);
        global._pending_save_chunks.hacker_state = undefined;
    }
}