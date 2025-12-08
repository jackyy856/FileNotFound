/// obj_DeskViewController – Create
/// Purpose:
///   Drives the "Desk View → Email List → Email Open" flow using 1920×1080 PNGs,
///   with transparent hotspot rectangles overlaid on the art.
/// Key hotkeys (dev only):
///   F1 = edit monitor viewport (blue) with Arrows (move) + Shift+W/A/S/D (resize)
///   1..5 = capture a single hotspot by clicking TL then BR
///   F6/F7 = load / reset hotspots to INI

// ---------------------------- State machine ----------------------------
enum DeskState { DESK, EMAIL_LIST, EMAIL_OPEN }
state = DeskState.DESK;

// GUI fixed to 1920×1080 to match sprite resolution (ensures consistent hitboxes across devices)
display_set_gui_size(1920, 1080);

// ---------------------------- Art references ----------------------------
sprDesk      = spr_desk_bg;      // DeskView.png (monitor bezel + desktop)
sprEmailList = spr_email_list;   // EmailList.png (in-monitor email list)
sprEmailOpen = spr_email_open;   // EmailOpen.png (in-monitor opened email)

// ---------------------------- Monitor viewport (blue) ----------------------------
// The monitor’s visible “screen” area inside DeskView.png. Adjust once, then save (F5).
MON_X = 240;
MON_Y = 110;
MON_W = 1440;
MON_H = 810;

// Email window rect is defined relative to the monitor (so if monitor shifts, window follows)
WIN_OFF_X = 110;
WIN_OFF_Y = 60;
WIN_OFF_W = -220; // negative => MON_W + this (i.e., MON_W - 220)
WIN_OFF_H = -120;

// Desktop icon column inside the monitor
ICON_OFF_X   = 20;
ICON_OFF_TOP = 40;
ICON_W       = 52;
ICON_H       = 52;
ICON_GAP     = 36;
ICON_EMAIL_INDEX = 2; // which icon row contains the Email app

// Email List row and Email Open link geometry (relative to email window)
ROW_TOP_OFF    = 28;
ROW_H          = 42;
PHISH_ROW_INDEX = 2;  // row index of “Congratulations!” subject line

// Titlebar button offsets relative to email window (hotspots are on the art)
BACK_OFF   = [  8,  6,  96, 30 ];  // only used on EMAIL_OPEN
CLOSEX_OFF = [ -26, 6,  20, 20 ];  // -26 => (winRight - 26)

// ---------------------------- Derived rects from monitor ----------------------------
function _recalc_layout() {
    // Email window (inside monitor)
    WIN_X = MON_X + WIN_OFF_X;
    WIN_Y = MON_Y + WIN_OFF_Y;
    WIN_W = (WIN_OFF_W >= 0) ? WIN_OFF_W : (MON_W + WIN_OFF_W);
    WIN_H = (WIN_OFF_H >= 0) ? WIN_OFF_H : (MON_H + WIN_OFF_H);

    // Email icon on the desktop (inside monitor)
    var icon_x = MON_X + ICON_OFF_X;
    var icon_y = MON_Y + ICON_OFF_TOP + (ICON_H + ICON_GAP) * ICON_EMAIL_INDEX;
    BTN_EMAIL_ICON = [ icon_x, icon_y, ICON_W, ICON_H ];

    // Titlebar hotspots
    BTN_BACK   = [ WIN_X + BACK_OFF[0],  WIN_Y + BACK_OFF[1],  BACK_OFF[2],  BACK_OFF[3] ];
    BTN_CLOSEX = [ (WIN_X + WIN_W) + CLOSEX_OFF[0], WIN_Y + CLOSEX_OFF[1], CLOSEX_OFF[2], CLOSEX_OFF[3] ];

    // Email list “Congratulations!” subject row
    var row_top = WIN_Y + ROW_TOP_OFF + ROW_H * PHISH_ROW_INDEX;
    BTN_PHISH_SUBJ = [ WIN_X + 16, row_top, WIN_W - 32, ROW_H ];

    // Email open “phishing link” area
    BTN_PHISH_LINK = [ WIN_X + WIN_W * 0.26, WIN_Y + WIN_H * 0.44, WIN_W * 0.38, 44 ];
}
_recalc_layout();

// ---------------------------- UX helpers ----------------------------
edit_monitor = false; // F1

// Minimal prompt (bottom bar). Keep it unobtrusive.
dialog_text  = "";
dialog_timer = 0;
DIALOG_TIME  = room_speed * 2;

function show_prompt(txt) {
    dialog_text  = txt;
    dialog_timer = DIALOG_TIME;
}

function _in_rect(p, r) {
    return (p[0] >= r[0]) && (p[1] >= r[1]) && (p[0] < r[0] + r[2]) && (p[1] < r[1] + r[3]);
}

// ---------------------------- Manual hotspot capture (1..5) ----------------------------
// Click TL (top-left) then BR (bottom-right) to define a rectangle.
capture_mode   = false;
capture_target = -1;        // 1..5
capture_first  = undefined; // [x, y]

function _capture_begin(id) {
    capture_mode   = true;
    capture_target = id;
    capture_first  = undefined;
    show_prompt("Capture: click TOP-LEFT, then BOTTOM-RIGHT");
}

function _rect_from_points(p1, p2) {
    var x1 = min(p1[0], p2[0]);
    var y1 = min(p1[1], p2[1]);
    var x2 = max(p1[0], p2[0]);
    var y2 = max(p1[1], p2[1]);
    return [ x1, y1, x2 - x1, y2 - y1 ];
}

// ---------------------------- Persist (INI) ----------------------------
SAVE_FILE = "deskview_hotspots.ini";

function _save_layout() {
    ini_open(SAVE_FILE);

    // Monitor
    ini_write_real("MONITOR","x",MON_X);
    ini_write_real("MONITOR","y",MON_Y);
    ini_write_real("MONITOR","w",MON_W);
    ini_write_real("MONITOR","h",MON_H);

    // Hotspots
    var r;
    r = BTN_EMAIL_ICON; ini_write_real("BTN_EMAIL_ICON","x",r[0]); ini_write_real("BTN_EMAIL_ICON","y",r[1]); ini_write_real("BTN_EMAIL_ICON","w",r[2]); ini_write_real("BTN_EMAIL_ICON","h",r[3]);
    r = BTN_BACK;       ini_write_real("BTN_BACK","x",r[0]);       ini_write_real("BTN_BACK","y",r[1]);       ini_write_real("BTN_BACK","w",r[2]);       ini_write_real("BTN_BACK","h",r[3]);
    r = BTN_CLOSEX;     ini_write_real("BTN_CLOSEX","x",r[0]);     ini_write_real("BTN_CLOSEX","y",r[1]);     ini_write_real("BTN_CLOSEX","w",r[2]);     ini_write_real("BTN_CLOSEX","h",r[3]);
    r = BTN_PHISH_SUBJ; ini_write_real("BTN_PHISH_SUBJ","x",r[0]); ini_write_real("BTN_PHISH_SUBJ","y",r[1]); ini_write_real("BTN_PHISH_SUBJ","w",r[2]); ini_write_real("BTN_PHISH_SUBJ","h",r[3]);
    r = BTN_PHISH_LINK; ini_write_real("BTN_PHISH_LINK","x",r[0]); ini_write_real("BTN_PHISH_LINK","y",r[1]); ini_write_real("BTN_PHISH_LINK","w",r[2]); ini_write_real("BTN_PHISH_LINK","h",r[3]);

    ini_close();
    show_prompt("Layout saved");
}

function _load_layout() {
    if (!file_exists(SAVE_FILE)) return false;

    ini_open(SAVE_FILE);

    // Monitor
    MON_X = ini_read_real("MONITOR","x",MON_X);
    MON_Y = ini_read_real("MONITOR","y",MON_Y);
    MON_W = ini_read_real("MONITOR","w",MON_W);
    MON_H = ini_read_real("MONITOR","h",MON_H);

    _recalc_layout(); // arrays exist before overwrite

    // Hotspots
    BTN_EMAIL_ICON[0] = ini_read_real("BTN_EMAIL_ICON","x",BTN_EMAIL_ICON[0]);
    BTN_EMAIL_ICON[1] = ini_read_real("BTN_EMAIL_ICON","y",BTN_EMAIL_ICON[1]);
    BTN_EMAIL_ICON[2] = ini_read_real("BTN_EMAIL_ICON","w",BTN_EMAIL_ICON[2]);
    BTN_EMAIL_ICON[3] = ini_read_real("BTN_EMAIL_ICON","h",BTN_EMAIL_ICON[3]);

    BTN_BACK[0]       = ini_read_real("BTN_BACK","x",BTN_BACK[0]);
    BTN_BACK[1]       = ini_read_real("BTN_BACK","y",BTN_BACK[1]);
    BTN_BACK[2]       = ini_read_real("BTN_BACK","w",BTN_BACK[2]);
    BTN_BACK[3]       = ini_read_real("BTN_BACK","h",BTN_BACK[3]);

    BTN_CLOSEX[0]     = ini_read_real("BTN_CLOSEX","x",BTN_CLOSEX[0]);
    BTN_CLOSEX[1]     = ini_read_real("BTN_CLOSEX","y",BTN_CLOSEX[1]);
    BTN_CLOSEX[2]     = ini_read_real("BTN_CLOSEX","w",BTN_CLOSEX[2]);
    BTN_CLOSEX[3]     = ini_read_real("BTN_CLOSEX","h",BTN_CLOSEX[3]);

    BTN_PHISH_SUBJ[0] = ini_read_real("BTN_PHISH_SUBJ","x",BTN_PHISH_SUBJ[0]);
    BTN_PHISH_SUBJ[1] = ini_read_real("BTN_PHISH_SUBJ","y",BTN_PHISH_SUBJ[1]);
    BTN_PHISH_SUBJ[2] = ini_read_real("BTN_PHISH_SUBJ","w",BTN_PHISH_SUBJ[2]);
    BTN_PHISH_SUBJ[3] = ini_read_real("BTN_PHISH_SUBJ","h",BTN_PHISH_SUBJ[3]);

    BTN_PHISH_LINK[0] = ini_read_real("BTN_PHISH_LINK","x",BTN_PHISH_LINK[0]);
    BTN_PHISH_LINK[1] = ini_read_real("BTN_PHISH_LINK","y",BTN_PHISH_LINK[1]);
    BTN_PHISH_LINK[2] = ini_read_real("BTN_PHISH_LINK","w",BTN_PHISH_LINK[2]);
    BTN_PHISH_LINK[3] = ini_read_real("BTN_PHISH_LINK","h",BTN_PHISH_LINK[3]);

    ini_close();
    return true;
}

// Load saved layout if present
_load_layout();

// ---------------------------- Guided capture (F3) ----------------------------
// Capture order: Email icon (Desk) → Subject (List) → Link (Open) → Back (Open) → X (Open)
guided_mode      = false;
guided_ids       = [1, 4, 5, 2, 3];
guided_idx       = 0;
capture_completed = false;

function _name_for(id) {
    switch (id) {
        case 1: return "Email icon";
        case 2: return "Back button";
        case 3: return "Close (X)";
        case 4: return "\"Congratulations!\" subject";
        case 5: return "Phishing link";
    }
    return "Hotspot";
}

function _set_screen_for(id) {
    if (id == 1) {
        state = DeskState.DESK;
    } else if (id == 4) {
        state = DeskState.EMAIL_LIST;
    } else {
        state = DeskState.EMAIL_OPEN;
    }
}

function _guided_begin() {
    guided_mode = true;
    guided_idx  = 0;
    _set_screen_for(guided_ids[guided_idx]);
    _capture_begin(guided_ids[guided_idx]);
    show_prompt("Guided: " + _name_for(guided_ids[guided_idx]) + " — click TL then BR");
}

function _guided_advance() {
    guided_idx++;
    if (guided_idx < array_length(guided_ids)) {
        _set_screen_for(guided_ids[guided_idx]);
        _capture_begin(guided_ids[guided_idx]);
        show_prompt("Guided: " + _name_for(guided_ids[guided_idx]) + " — click TL then BR");
    } else {
        guided_mode = false;
        show_prompt("Guided done. Press F5 to save.");
    }
}
