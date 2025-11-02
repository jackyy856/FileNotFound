// Self-contained sticky-notes window. No parents, no globals, no dependencies.

// ---------- Window/layout ----------
x1 = 260; y1 = 120;  w = 820; h = 560;  bar_h = 40;
x2 = x1 + w; y2 = y1 + h;

title = "Notes";
window_focus = true;
dragging = false; drag_dx = 0; drag_dy = 0;
is_minimized = false;

btn_w = 24; btn_h = 20; btn_pad = 8;

pad = 12;
content_x1 = x1 + pad;
content_y1 = y1 + bar_h + pad;
content_x2 = x2 - pad;
content_y2 = y2 - pad;

function _recalc() {
    x2 = x1 + w; y2 = y1 + h;
    content_x1 = x1 + pad;
    content_y1 = y1 + bar_h + pad;
    content_x2 = x2 - pad;
    content_y2 = y2 - pad;
}

function point_in_rect(px, py, rx, ry, rw, rh) {
    return (px >= rx) && (py >= ry) && (px < rx + rw) && (py < ry + rh);
}

// ---------- Fonts (safe fallbacks) ----------
font_title = -1;  // default font
font_body  = -1;

// ---------- Data model ----------
/*
 Each note:
  { id, title, body, locked, password, read, tag }
*/
notes = [
    { id:0, title:"Daily Plan (Mon)", locked:false, password:"", read:false, tag:"work",
      body:"9:00 standup\n11:30 vendor call\n3:00 budget sync\nReminder: gallery photos have timestamps." },

    { id:1, title:"Manager’s Initials", locked:false, password:"", read:false, tag:"policy",
      body:"Password hints must be work-related. Start with your manager’s initials." },

    { id:2, title:"Conf Room Notes (Locked)", locked:true, password:"0729", read:false, tag:"clue",
      body:"Meeting write-up from late July. Key is last two digits of month+day." },

    { id:3, title:"Next Step (Hint)", locked:false, password:"", read:false, tag:"hint",
      body:"After Notes, check the next app (fill this in later)."}
];

selected_index = -1; // -1 = list view
row_h = 44;
list_scroll = 0;

// ---------- Password modal ----------
pw_modal_open = false;
pw_note_index = -1;
pw_input = "";
pw_attempts = 0;
pw_max_attempts = 3;
pw_feedback = "";
pw_box_w = 420; pw_box_h = 180;
