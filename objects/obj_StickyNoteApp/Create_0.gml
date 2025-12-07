// Self-contained sticky-notes window. No parents, no globals, no dependencies.

// ---------- Window/layout ----------
x1 = 260; y1 = 120;  w = 820; h = 560;  bar_h = 60;
x2 = x1 + w; y2 = y1 + h;

title = "Notes";
window_focus = true;
dragging = false; drag_dx = 0; drag_dy = 0;
is_minimized = false;

btn_w = 35; btn_h = 35; btn_pad = 20;

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
    // Most notes: normal life / work clutter
    { id:0, title:"Groceries", locked:false, password:"", read:false, tag:"list",
      body:"milk\ncoffee\nfrozen meals\nsticky notes (again)\nreminder: do NOT leave the fridge empty." },

    { id:1, title:"Meeting - Q4 sync", locked:false, password:"", read:false, tag:"meeting",
      body:"Q4 sync with Helena\n\nAgenda:\n- targets and stretch goals\n- budget fire drill\n- headcount rightsizing\n\nremember: update Q4 sheets before Helena gets on my ass" },

    { id:2, title:"Phrases to sound important", locked:false, password:"", read:false, tag:"jargon",
      body:"corporate phrases to overuse:\n- circle back on that\n- low-hanging fruit\n- action items\n- driving alignment across stakeholders\n- parking lot this for later" },

    // Locked notes: not meant to open yet
    { id:3, title:"1 out of 5", locked:true, password:"", read:false, tag:"locked",
      body:"[locked]\nthis one isnt ready yet." },

    { id:4, title:"doves case.", locked:true, password:"", read:false, tag:"locked",
      body:"[locked]\nseriously, stop trying to open this.\nnot for you. (yet)" },

    // Special wifi puzzle note
    { id:5, title:"dont open me >-<", locked:false, password:"", read:false, tag:"wifi",
      body:"wifi? hehe, where u can see a reflection\n\npassword...? try one of this >u<\n- greedy\n- mean\n- controlling\n- liar\n- sadistic\n- fake\n- bossy" }
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
