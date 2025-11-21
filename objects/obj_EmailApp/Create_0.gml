// layout
event_inherited();   // gets base geometry and state (from AppBase if needed)
title = "Mail";      // window title

// Base window geom (absolute GUI)
window_w = 1700;
window_h = 900;
window_x = 90;
window_y = 90;

header_h = 55;   //header height
row_h    = 36;   //inbox row height

// ---- window state ----
window_dragging = false;
window_drag_dx = 0;
window_drag_dy = 0;
is_minimized   = false;   // minimize like Sticky Note

// drag via border (for 4-way cursor like Files/Gallery)
drag_border = 12;
function _in_win(px,py){ return (px>=window_x)&&(py>=window_y)&&(px<window_x+window_w)&&(py<window_y+window_h); }
function _on_drag_border(px,py){
    var l = (abs(px - window_x) <= drag_border);
    var r = (abs(px - (window_x + window_w)) <= drag_border);
    var t = (abs(py - (window_y + header_h)) <= drag_border);
    var b = (abs(py - (window_y + window_h)) <= drag_border);
    return l || r || t || b;
}

// derived rects (recomputed on move)
function _recalc_email_layout() {
    list_top  = window_y + header_h + 8;
    list_left = window_x + 16;
    list_w    = window_w - 32;
    list_h    = window_h - header_h - 24;

    // buttons
    close_btn = [window_x + window_w - 36,  window_y + 12, 24, 24];
    min_btn   = [window_x + window_w - 66,  window_y + 12, 24, 24]; // minimize
    back_btn  = [window_x + 12,             window_y + 40, 64, 24];
}
_recalc_email_layout();

// state
selected_index = -1;      //-1 = inbox view; 0... = full email view

// fonts
var fTitle = asset_get_index("f_mail_title");
var fBody  = asset_get_index("f_mail_body");
font_title = (fTitle != -1) ? fTitle : -1; // -1 = default font
font_body  = (fBody  != -1) ? fBody  : -1;

// inbox data
inbox = [
    {
        id:0,
        from:"announcementz@rosenwood.hr",
        subject:"You have been selected for a bonus opportunity!",
        body:"Congratulations! Thanks to your outstanding performance, we have an amazing notice to share. Please click here to redeem your certificate of recognition. Thank you for your hard work!",
        read:false, is_suspicious:true, is_corrupted:false
    },
    {
        id:1,
        from:"IT Support",
        subject:"Action Required: Password Reset",
        body:"Your password expires today. Click the in-app link to reset.",
        read:false, is_suspicious:false, is_corrupted:false
    },
    {
        id:2,
        from:"Unknown",
        subject:"[URGENT] Outstanding invoice (open immediately)",
        body:"This message contains your invoice.",
        read:false, is_suspicious:false, is_corrupted:false
    },
    {
        id:3,
        from:"Patrica Conway",
        subject:"Friday Office Party",
        body:"Hey! Sharing the office party photos. Don't let the boss see ;)",
        read:false, is_suspicious:false, is_corrupted:false
    }
];

/// --- Email Puzzle / Corrupted mail ---

puzzle_gate = true; // still here if you want to gate later

// Add a corrupted email entry
var _len = array_length(inbox);
inbox[_len] = {
    id           : 4,
    from         : "System",
    subject      : "[CORRUPTED] \u2588\u2592\u2591\u2592\u2588",
    body         : "This email is corrupted. Recover it to reveal your first key.",
    read         : false,
    is_suspicious: false,
    is_corrupted : true
};
corrupted_index = _len;

// Target sentence & word list
puzzle_target = ["Rosenwood", "Corps", "sucks"];

puzzle_words  = [
    "Rosenwood",
    "Lilywood",
    "family",
    "Recover",
    "Corps",
    "amazing",
    "is",
    "dogs",
    "sucks",
    "where"
];

// ---- LOCAL GEOMETRY (relative to window_x, window_y) ----
bin_area_local = {
    x : 12,
    y : header_h + 8,
    w : window_w - 24,
    h : window_h - header_h - 80
};

// Puzzle target area (LOCAL; where pieces snap)
puzzle_area_local = {
    x : 140,
    y : 320,
    w : window_w - 280,
    h : 160
};

// Word tile sizing + centered 2-row layout (spawn rows at bottom)
word_btn_w = 150;
word_btn_h = 34;
var cols   = 5;
var gap    = 10;

var total_w = cols * word_btn_w + (cols - 1) * gap;
var start_x = bin_area_local.x + floor((bin_area_local.w - total_w) * 0.5);

var row0_y = bin_area_local.y + bin_area_local.h - (2 * word_btn_h + gap + 24);
var row1_y = row0_y + word_btn_h + gap;
row0_y = max(row0_y, header_h + 80);
row1_y = row0_y + word_btn_h + gap;

word_btns = [];
for (var i = 0; i < array_length(puzzle_words); i++) {
    var r = (i < cols) ? 0 : 1;
    var c = (i < cols) ? i : (i - cols);
    var bx = start_x + c * (word_btn_w + gap);
    var by = (r == 0) ? row0_y : row1_y;

    word_btns[i] = {
        text      : puzzle_words[i],
        x         : bx,  y : by,     // LOCAL coords
        ox        : bx,  oy: by,     // LOCAL spawn
        w         : word_btn_w, h: word_btn_h,
        dragging  : false,
        dx        : 0, dy: 0,
        placed    : false,
        slot_index: -1,
        shape_start: 0,
        shape_end  : 0,
        shape_start_group: 1,
        shape_end_group  : 1
    };
}

// Assign shape patterns based on word text
for (var j = 0; j < array_length(word_btns); j++) {
    var btxt = word_btns[j].text;

    var s_start = 0;
    var s_end   = 0;
    var g_start = 1; // 0 = first-group, 1 = middle-group, 2 = last-group
    var g_end   = 1;

    // First words: Rosenwood, Lilywood, Recover
    //   - edge on END side (type 1), visually "first" group (higher teeth)
    if (btxt == "Rosenwood" || btxt == "Lilywood" || btxt == "Recover") {
        s_end = 1;
        g_end = 0; // first group
    }
    // Middle words: Corps, is
    //   - start edge fits first words (type 1)
    //   - end edge fits last words (type 2)
    else if (btxt == "Corps" || btxt == "is") {
        s_start = 1;
        s_end   = 2;
        g_start = 1; // middle group
        g_end   = 1; // middle group
    }
    // Last words: family, amazing, sucks, dogs
    //   - only START edge (type 2), in "last" group (lowest)
    else if (btxt == "family" || btxt == "amazing" || btxt == "sucks" || btxt == "dogs") {
        s_start = 2;
        g_start = 2; // last group
    }
    // "where" stays flat

    word_btns[j].shape_start       = s_start;
    word_btns[j].shape_end         = s_end;
    word_btns[j].shape_start_group = g_start;
    word_btns[j].shape_end_group   = g_end;
}

// --- Puzzle snap slots for the 3 target words inside the black box (LOCAL) ---
// Use structs { x, y } so we can control spacing and vertical center
var slot_count = array_length(puzzle_target);
puzzle_slots   = array_create(slot_count);

var base_spacing = word_btn_w + 24; // give extra space so teeth don't overlap
var total_span   = base_spacing * (slot_count - 1) + word_btn_w;
var slots_left   = puzzle_area_local.x + max(0, (puzzle_area_local.w - total_span) * 0.5);
var slot_y       = puzzle_area_local.y + (puzzle_area_local.h - word_btn_h) * 0.5;

for (var s = 0; s < slot_count; s++) {
    var sx = slots_left + s * base_spacing;
    puzzle_slots[s] = { x: sx, y: slot_y };
}

// Binary rain
bin_cell   = 14;
bin_speed  = 1.2;
bin_scroll = 0;

// Puzzle state
puzzle_active    = false;
puzzle_solved    = false;
puzzle_scattered = true; // keep neat rows
puzzle_message   = "";
ok_btn_local     = [0,0,120,36];

// Riddle / hint timer
puzzle_hint_timer = 0;
puzzle_show_hint  = false;

// Email key reward
email_key1_collected = false;
email_key1_rect      = [0,0,0,0]; // x,y,w,h

// click-through claim helpers
if (!variable_global_exists("_ui_click_consumed")) global._ui_click_consumed = false;
__ui_click_inside = false;
__ui_first_frame_block = 1; // avoid opener click passing through

// small delay to stop icon click from also selecting an email row
open_cooldown = 2;
