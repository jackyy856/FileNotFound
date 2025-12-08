// ---------- Window/layout ----------
x1 = 260; y1 = 120;  w = 820; h = 560;  bar_h = 40;
x2 = x1 + w; y2 = y1 + h;

title = "Notes";
window_focus = true;
dragging = false; drag_dx = 0; drag_dy = 0;
is_minimized = false;

btn_w = 24; btn_h = 20; btn_pad = 8;

pad = 30;
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
font_title = fnt_gen;  // default font
font_body  = fnt_gen;

// ---------- Data model ----------
/*
 Each note:
  { id, title, body, locked, password, read, tag }
*/
notes = [
    // Most notes: normal life / work clutter
    { id:0, title:"Groceries", locked:false, password:"", read:false, tag:"list",
      body:"milk\n\ncoffee\n\nfrozen meals\n\nsticky notes (again)\n\nreminder: do NOT leave the fridge empty." },

    { id:1, title:"Meeting - Q4 sync", locked:false, password:"", read:false, tag:"meeting",
      body:"Q4 sync with Helena\n\n\nAgenda:\n\n- targets and stretch goals\n\n- budget fire drill\n\n- headcount rightsizing\n\nremember: update Q4 sheets before Helena gets on my ass" },

    { id:2, title:"Phrases to sound important", locked:false, password:"", read:false, tag:"jargon",
      body:"corporate phrases to overuse:\n\n- circle back on that\n\n- low-hanging fruit\n\n- action items\n\n- driving alignment across stakeholders\n\n- parking lot this for later" },
	  
    // Locked notes: not meant to open yet - the one underneath im taking off bc no reason to have it anymore. 
    //{ id:3, title:"1 out of 5", locked:true, password:"", read:false, tag:"locked",
     // body:"[locked]\nthis one isnt ready yet." },

    { id:4, title:"doves case.", locked:true, password:"", read:false, tag:"locked",
      body: "\n\nThere's an issue with Richard and HR. Or maybe more than just him.\n\n\n\nI tried to reach out to HR multiple times, including the head of it, when we met at  \n\na corporate dinner. But she seemed to avoid my view.  \n\n \n\nIt feels more than just negligence.\n\nIt feels. . . like he has some sort of guardian angel.\n\n\nBut nobody is willing to talk about him. Or they hate him too much to know, or \n\nthey are terrified of the consequences...\n\n \n\nI think he has an intern under his wing.\n\n \n\nMaybe that guy knows Richard's weakness; maybe I can take care of Richard \n\nthrough him.\n\n\n\nI should befriend Leonn." },

    // Special wifi puzzle note
    { id:5, title:"dont open me >-<", locked:false, password:"", read:false, tag:"wifi",
      body:"wifi? hehe, i choose one about you! so check ur reflection hehe.try one of this >u<\n\n\n- greedy77\n\n- mean28\n\n- controlling45\n\n- liar93\n\n- collateral85\n\n- sadistic82\n\n- fake62\n\n- bossy" }
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
