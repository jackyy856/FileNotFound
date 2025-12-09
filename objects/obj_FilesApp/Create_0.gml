/// obj_FilesApp - Create

// If you inherit from an AppBase, keep this:
event_inherited();

// ------------------------------------
// WINDOW LAYOUT (fixed app-sized window)
// ------------------------------------
window_w = 1700;
window_h = 900;
window_x = 90;
window_y = 60;

title    = "Files";
header_h = 40;

// close / minimize buttons in top-right of this window
files_close_btn = [window_x + window_w - 36, window_y + 8, 24, 24];
files_min_btn   = [window_x + window_w - 66, window_y + 8, 24, 24];

is_minimized    = false;
window_dragging = false;
window_drag_dx  = 0;
window_drag_dy  = 0;

// ------------------------------------
// STATE
// ------------------------------------
view_mode = 0; // 0 = home, 1 = firewall puzzle, 2 = firewall log/preview

// ------------------------------------
// HOME ENTRIES (Projects / HR / Images / Firewall.exe)
// ------------------------------------
home_entries = [];

var card_w   = 120;
var card_h   = 120;
var margin_x = 40;
var base_x   = window_x + 40;
var base_y   = window_y + header_h + 40;

var labels = [
    "Projects",
    "HR",
    "Images",
    "Firewall.exe"
];

for (var i = 0; i < array_length(labels); i++) {
    var cx = base_x + i * (card_w + margin_x);
    var cy = base_y;

    var kind = "folder";
    if (i == 3) kind = "firewall";

    home_entries[i] = {
        label : labels[i],
        kind  : kind,
        rx    : cx,
        ry    : cy,
        rw    : card_w,
        rh    : card_h
    };
}

// ------------------------------------
// FIREWALL PUZZLE GEOMETRY
// ------------------------------------
//
// Slightly smaller black frame & panels so tiles feel bigger.
//

// black frame
fw_frame = {
    x : window_x + 220,
    y : window_y + 90,
    w : window_w - 440,
    h : window_h - 340
};

// panels inside the frame
var panel_gap   = 40;                            // gap between deny & admit
var panel_w     = (fw_frame.w - panel_gap - 60); // side padding
panel_w         = panel_w * 0.5;
var panel_h     = fw_frame.h - 60;               // top/bottom padding

fw_deny = {
    x : fw_frame.x + 30,
    y : fw_frame.y + 30,
    w : panel_w,
    h : panel_h
};

fw_admit = {
    x : fw_deny.x + panel_w + panel_gap,
    y : fw_deny.y,
    w : panel_w,
    h : panel_h
};

// ------------------------------------
// FIREWALL SENTENCE TILES
// ------------------------------------

// permanent texts
fw_texts = [
    "It wasnt only about Sofia.",
    "I ruined Leonns life.",
    "I liked the power.",
    "I am guilty.",
    "I used him for my benefit.",
    "I control everyone around me.",
    "I should pay for what I did."
];

// tile array
fw_tiles = [];

// use text width + padding for tile width
draw_set_font(-1);
var padding = 48;
var tile_h  = 40;  // taller tiles

var total_tiles   = array_length(fw_texts);
var spacing       = 16;
var row0_count    = 4;
var row1_count    = total_tiles - row0_count;
var widths        = array_create(total_tiles);
fw_tile_max_w     = 0;
var min_tile_w    = 230;

// measure widths and track max
for (var i2 = 0; i2 < total_tiles; i2++) {
    var wtxt = string_width(fw_texts[i2]) + padding;
    if (wtxt < min_tile_w) wtxt = min_tile_w;
    widths[i2] = wtxt;
    if (wtxt > fw_tile_max_w) fw_tile_max_w = wtxt;
}

// total widths per row for centering
var row0_total_w = 0;
for (var r0 = 0; r0 < row0_count; r0++) {
    row0_total_w += widths[r0];
}
row0_total_w += spacing * (row0_count - 1);

var row1_total_w = 0;
for (var r1 = 0; r1 < row1_count; r1++) {
    row1_total_w += widths[row0_count + r1];
}
row1_total_w += spacing * max(row1_count - 1, 0);

// y positions for the two rows (inside white strip)
var row0_y = window_y + window_h - 130;
var row1_y = window_y + window_h - 80;

// centered starting x for each row
var center_x     = window_x + window_w * 0.5;
var row0_start_x = center_x - row0_total_w * 0.5;
var row1_start_x = center_x - row1_total_w * 0.5;

// build tiles
var cur_x = row0_start_x;
for (var t = 0; t < total_tiles; t++) {
    var txt  = fw_texts[t];
    var tw   = widths[t];
    var tx;
    var ty;

    if (t < row0_count) {
        tx = cur_x;
        ty = row0_y;
        cur_x += tw + spacing;
    } else {
        if (t == row0_count) {
            cur_x = row1_start_x;
        }
        tx = cur_x;
        ty = row1_y;
        cur_x += tw + spacing;
    }

    fw_tiles[t] = {
        text     : txt,
        x        : tx,
        y        : ty,
        w        : tw,
        h        : tile_h,
        home_x   : tx,
        home_y   : ty,
        dragging : false,
        dx       : 0,
        dy       : 0,
        side     : -1,   // -1 none, 0 deny, 1 admit
        start_x  : tx,   // for animation
        start_y  : ty,
        target_x : tx,
        target_y : ty
    };
}

// ------------------------------------
// CONFIRM POPUP + ANIMATION
// ------------------------------------
fw_confirm_open   = false;
fw_animating      = false;
fw_anim_t         = 0;
fw_anim_hold      = false;
fw_anim_hold_time = 0;

// ------------------------------------
// FIREWALL LOG / GOLD KEY
// ------------------------------------
fw_log_text = "FIREWALL LOG UNLOCKED\n\n" +
              "Hacker: \"Yeah. Thats right, Vanessa. You did all of it.\"\n\n" +
              "You lit the match. You walked away. You buried the truth.\"\n\n" +
              "Hacker: \"I know everything you tried to bury. And now you do too.\"\n\n" +
              "Click the gold key.";

fw_key_rect            = [0,0,0,0];   // x,y,w,h for clicking in Step
fw_key_collected_local = false;

// make sure global keys array exists (0=green,1=red,2=gold)
if (!variable_global_exists("key_collected")) {
    global.key_collected = array_create(3, false);
}

// ------------------------------------
// SHARED UI CLICK HELPERS
// ------------------------------------
if (!variable_global_exists("_ui_click_consumed")) {
    global._ui_click_consumed = false;
}
__ui_click_inside      = false;
__ui_first_frame_block = 1;
