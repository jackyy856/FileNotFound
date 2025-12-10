// ---------- Window/layout ----------
x1 = 260; y1 = 120;  w = 820; h = 800;  bar_h = 40;
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
    { id:0, title:"Groceries", locked:false, password:"", read:true, tag:"list",
      body:"-Milk\n\n-Coffee\n\n-Frozen meals\n\n-Protein (chicken?)\n\n-Salad stuff\n\n-Paprika\n\n-Thyme\n\nReminder: don't let fridge get to 'wine and mustard only' level." },

    { id:1, title:"Meeting - Q4 sync", locked:false, password:"", read:true, tag:"meeting",
      body:"Q4 sync with Helena\n\n\nAgenda:\n\n-Targets and stretch goals (have both ready)\n\n-Budget fire drill (what can be cut)\n\n-Headcount 'rightsizing'\n\n*Remember: Update Q4 sheets before Helena gets on my ass" },

    { id:2, title:"Cancel subscriptions", locked:false, password:"", read:true, tag:"budget",
      body:"-Yoga app\n\n-Productivity app" },
	  
	 { id:3, title:"Weekend errands", locked:false, password:"", read:true, tag:"chores",
      body:"Saturday:\n\n -Pharmacy: migraine meds \n\n -Wine for Helena's 'casual catch-up' (not casual) \n\n -Return blazer that fits weird \n\n\n\n Sunday: \n\n -Clear old paperwork from dining table \n\n -Water plants before they die... again\n\n-Pick up dry-cleaning" },

    { id:4, title:"Dove's Case", locked:false, password:"", read:false, tag:"documentation",
      body: "\n\nWork log/thoughts\n\n\n\n Reached out to HR:\n\n - 2/03 - No reply \n\n - 2/11 - Auto-response only\n\n - 2/27 - 'Still under review'\n\n -Dinner w/ HR head > Avoided me? Why? \n\n\n\n Check:\n\n - Others also ignored? (Ask Elizabeth quietly?)\n\n - Why is everyone scared of Fowler? \n\n - Or... pretending not to know? \n\n\n\nPatterns? \n\n - More than negligence?\n\n - Someone shielding him?? \n\n - 'Guardian angel' ??  \n\n\n\nInsider?\n\n - Blonde one always w/ Richard\n\n - Follows him everywhere\n\n - Maybe sees more than he says \n\n - Find out his name and befriend for info" },
	  
	  { id:3, title:"Therapy?", locked:false, password:"", read:true, tag:"needed",
      body:"-Therapists w/ evening sessions \n\n-Check insurance coverage \n\n\n\nQuestions: \n\n -'High-functioning burnout'? \n\n -Imposter syndrome\n\n -Bring up Dove's case??" },

    // Special wifi puzzle note
    { id:5, title:"don't open meee >-<", locked:false, password:"", read:false, tag:"wifi",
      body:"password01 and password02? ur so predictable, myers...\n\nwifi...? this one's simple. most of these describe u already so just try the one that \n\ndoesn't >u<\n\n\n\n- greedy77\n\n- mean28\n\n- controlling45\n\n- liar93\n\n- collateral85\n\n- sadistic82\n\n- fake62\n\n- bossy91" },
	  
	{ id:6, title:"Phrases to sound important", locked:false, password:"", read:true, tag:"jargon",
      body:"Corporate phrases to overuse:\n\n-Circle back on that\n\n-Low-hanging fruit\n\n-Action items\n\n-Driving alignment across stakeholders\n\n-Sanity check" },
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
