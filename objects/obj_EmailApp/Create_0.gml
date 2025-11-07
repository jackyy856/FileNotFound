// layout
//testing commit 
event_inherited();   // gets base geometry and state
title = "Mail";     // window title
script_execute(_recalc); // update rects after changing size
window_w = 1700;
window_h = 900;
window_x = 90;   //x position (left edge) of window
window_y = 90;   //y position (top edge) of window

header_h = 55;   //header height
row_h    = 36;   //inbox row height
list_top = window_y + header_h + 8;  //y start of inbox list; below header
list_left= window_x + 16;            //x start of inbox list
list_w   = window_w - 32;            //inbox list width
list_h   = window_h - header_h - 24; //inbox list height

// state
selected_index = -1;      //-1 = inbox view; 0... = full email view

// button 
close_btn = [window_x + window_w - 36, window_y + 12, 24, 24]; 
back_btn  = [window_x + 12,            window_y + 40, 64, 24]; 

// --- NEW: minimize button next to X ---
min_btn   = [window_x + window_w - 66, window_y + 12, 24, 24];
is_minimized = false;

// --- NEW: window move/drag + cursor + click shield ---
dragging = false; drag_dx = 0; drag_dy = 0;
drag_border = 12; // draggable frame width (all sides)
function _in_win(px,py){ return (px>=window_x)&&(py>=window_y)&&(px<window_x+window_w)&&(py<window_y+window_h); }
function _on_drag_border(px,py){
    var l = (abs(px - window_x) <= drag_border);
    var r = (abs(px - (window_x + window_w)) <= drag_border);
    var t = (abs(py - window_y) <= drag_border);
    var b = (abs(py - (window_y + window_h)) <= drag_border);
    return l || r || t || b;
}

// fonts (figure out font assets
var fTitle = asset_get_index("f_mail_title");
var fBody  = asset_get_index("f_mail_body");
font_title = (fTitle != -1) ? fTitle : -1; // -1 = default font
font_body  = (fBody  != -1) ? fBody  : -1;

// inbox data
inbox = [
	{ id:0, from:"announcementz@rosenwood.hr", subject:"You have been selected for a bonus opportunity!",
      body:"Congratulations! Thanks to your outstanding performance, we have an amazing notice to share. Please click here to redeem your certificate of recognition. Thank you for your hard work!",
      read:false, is_suspicious:true, is_corrupted:false },
	  
    { id:1, from:"IT Support", subject:"Action Required: Password Reset",
      body:"Your password expires today. Click the in-app link to reset.", read:false, is_suspicious:false, is_corrupted:false },

    { id:2, from:"Unknown", subject:"[URGENT] Outstanding invoice (open immediately)",
      body:"This message contains your invoice.",
      read:false, is_suspicious:false, is_corrupted:false },
      
    { id:3, from:"Patrica Conway", subject:"Friday Office Party",
      body:"Hey! Sharing the office party photos. Don't let the boss see ;)",
      read:false, is_suspicious:false, is_corrupted:false }
];

/// --- Email Puzzle ---
/// Gate: flip this when the story reaches post-prologue
puzzle_gate = true; // TODO: wire to your real story flag, e.g., global.after_prologue

// Add a corrupted email entry (kept unread; has custom flag)
var _len = array_length(inbox); // _len is to avoid confusion with len in Draw GUI
inbox[_len] = {
    id           : 4,
    from         : "System",
    subject      : "[CORRUPTED] \u2588\u2592\u2591\u2592\u2588", // glitch blocks
    body         : "This email is corrupted. Recover it to reveal the Wi-Fi password.",
    read         : false,
    is_suspicious: false,
    is_corrupted : true
};
corrupted_index = _len;

// ------- Flexible puzzle definition --------
// Change only this to alter solution text:
puzzle_target = ["Recover", "your", "password"];

// Pool of 10 buttons (case sensitive, per spec)
puzzle_words = [
    "your","where","find","Steal","Recover","I","for","password","Ground","down"
];

// Layout: puzzle area and word button grid
puzzle_active  = false;   // becomes true when the corrupted email is opened
puzzle_solved  = false;
puzzle_scattered = false;
puzzle_message = "";      // for modal text after solve
ok_btn = [0,0,120,36];    // set later when we draw modal

// Puzzle area rectangle (centerish)
puzzle_area = {
    x : window_x + 140,
    y : window_y + 320,
    w : window_w - 280,
    h : 160
};

// Build word buttons (two rows, bottom section)
word_btn_w = 150;
word_btn_h = 34;
var cols   = 5;
word_gap   = 10;

// --- Binary rain (Matrix-style) visual state ---
bin_cell   = 14;
bin_speed  = 1.2;
bin_scroll = 0;
bin_area = {
    x : window_x + 12,
    y : window_y + header_h + 8,
    w : window_w - 24,
    h : window_h - header_h - 80
};

// Bottom margin region for buttons
var btn_left = window_x + 40;
var btn_top  = window_y + window_h - (word_btn_h*2 + word_gap + 40);

word_btns = [];
for (var i = 0; i < array_length(puzzle_words); i++) {
    var r = i div cols;
    var c = i mod cols;

    var bx = btn_left + c * (word_btn_w + word_gap);
	var by = btn_top  + r * (word_btn_h + word_gap);

    word_btns[i] = {
        text     : puzzle_words[i],
        x        : bx,  y : by,
        ox       : bx,  oy: by,   // original
        w        : word_btn_w, h: word_btn_h,
        dragging : false,
        dx       : 0, dy: 0,
        placed   : false
    };
}

// --- NEW: centralized recalc when window moves ---
function _recalc_email_layout() {
    list_top = window_y + header_h + 8;
    list_left= window_x + 16;
    list_w   = window_w - 32;
    list_h   = window_h - header_h - 24;

    close_btn[0] = window_x + window_w - 36; close_btn[1] = window_y + 12;
    min_btn[0]   = window_x + window_w - 66; min_btn[1]   = window_y + 12;
    back_btn[0]  = window_x + 12;            back_btn[1]  = window_y + 40;

    bin_area.x = window_x + 12;
    bin_area.y = window_y + header_h + 8;
    bin_area.w = window_w - 24;
    bin_area.h = window_h - header_h - 80;

    puzzle_area.x = window_x + 140;
    puzzle_area.y = window_y + 320;
    puzzle_area.w = window_w - 280;

    var btn_left2 = window_x + 40;
    var btn_top2  = window_y + window_h - (word_btn_h*2 + word_gap + 40);
    // keep scattered tiles where they are; just update their "snap-back" baseline proportionally
    // (we don't change ox/oy here to preserve puzzle placements)
}

// initial cursor
window_set_cursor(cr_default);
