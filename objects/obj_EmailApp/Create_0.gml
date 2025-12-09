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

// height for principal tab png
tab_sprite = spr_mail_principal;
tab_h = sprite_get_height(tab_sprite) + 10;

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
    list_top  = window_y + header_h + tab_h + 8;
    list_left = window_x + 16;
    list_w    = window_w - 32;
    list_h    = window_h - header_h - tab_h - 24;

   // buttons
	// match Draw's btn_size and placement (30x30, centered vertically in header)
	var btn_size = 30;
	var btn_y = window_y + (header_h - btn_size) / 2;

	var min_x1   = window_x + window_w - (btn_size * 2) - 8;
	var min_x2   = min_x1 + btn_size;

	var close_x1 = window_x + window_w - btn_size - 4;
	var close_x2 = close_x1 + btn_size;

	// store as [x, y, w, h]
	min_btn   = [min_x1, btn_y, btn_size, btn_size];
	close_btn = [close_x1, btn_y, btn_size, btn_size];

	back_btn  = [window_x + 12, window_y + 120, 80, 26];
	
}

_recalc_email_layout();

// state
selected_index = -1;      //-1 = inbox view; 0... = full email view
thread_scroll = 0;        // Scroll position for thread view

// fonts

font_title = font_emailT;
font_body  = font_email;

// (intro-mode support removed; see obj_EmailIntro for intro flow)

function _intro_prompt(txt) {
    intro_prompt_txt   = txt;
    intro_prompt_timer = INTRO_PROMPT_TIME;
}

// inbox data
inbox = [
    // Move Vanessa Myers Case #2931 to the top
    {
        id:145,
		thread_id: 11,
        from:"Vanessa Myers <vmyers@rosenwood.com>",
		to: "HR Department <hr@rosenwood.com>",
        subject:"Follow Up - Case #2931",
        body:"Hi,\n\n\n\nI'm following up again on the case regarding Richard Fowler (Case #2931). The employee involved hasn't received any update or response to her inquiries.\n\n\n\nPlease advise.\n\n\n\nVanessa Myers\n\n\n\nRosenwood Financial Director",
        read:false, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
    {
        id:0,
        from:"announcementz@rosenw00d.hr",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"You have been selected for a bonus opportunity!",
        body:"Congratulations! \n\n\n\nThanks to your outstanding performance, we have an amazing notice to share. Please click here to redeem your certificate of recognition. Thank you for your hard work!",
        read:false, is_suspicious:true, is_corrupted:false, show_in_inbox:true
    },
    // Removed per request: Elizabeth Newman anomaly email
    {
        id:20,
        from:"Rosenwood Corps HR <hr@rosenwood.com>",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"Mandatory Review: Code of Conduct Update",
        body:"Hello Vanessa, \n\n\n\nRosenwood has updated its Code of Conduct for 2025, effective immediately. \n\nAll department leads are required to review the document and ensure compliance within their teams. \n\nPlease acknowledge receipt by replying to this email. \n\n\n\nHR Department",
        read:false, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
    {
        id:30,
        from:"Thomas Wylde <twylde@rosenwood.com>",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"Log review complete",
        body:"I've examined the access logs you asked for. Everything aligns with your statement. No further action required on your end. \n\n\n\nGood luck,  \n\n\n\nThomas Wylde  \n\nIT Director  \n\nRosenwood Corps",
        read:false, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
	 {
        id:60,
		thread_id: 1,
        from:"Elizabeth Newman <enewman@rosenwood.com>",
		to: "Corey Lewis <clewis@rosenwood.com>, Vanessa Myers <vmyers@rosenwood.com>",
        subject:"Corey finish the reconciliations and fix the numbers",
        body:"Hey, \n\n\n\nI can't finalize the report without your section. Please upload it before lunch. I'm making this a formal email so Vanessa is aware.\n\n\n\nThanks,  \n\n\n\nElizabeth Newman  \n\nJunior Financial Analyst  \n\nRosenwood Corps",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
	 {
        id:59,
		thread_id: 1,
        from:"Corey Lewis <clewis@rosenwood.com>",
		to: "Elizabeth Newman <enewman@rosenwood.com>, Vanessa Myers <vmyers@rosenwood.com>",
        subject:"RE: Corey finish the reconciliations and fix the numbers",
        body:"Hello, \n\n\n\ni forgot about it because i went out to eat. should be done now.”.\n\n\n\nSup,  \n\n\n\nCorey Lewis  \n\nSenior Financial Analyst  \n\nRosenwood Corps",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
	{
        id:70,
        from:"Justin Fleming <jfleming@rosenwood.com>",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"PLEASE approve marketing expense (tiny one this time)",
        body:"Dear Vanessa, \n\n\n\nI promise this is small. We need $6K for promotional stands, you can't reject another one of our proposals. \n\nThis will boost conversions by at least 6%. \n\nPlease let a man dream..\n\n\n\nThank you very much,  \n\n\n\nJustin Fleming  \n\nMarketing Director  \n\nRosenwood Corps",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
	{
        id:89,
		thread_id: 5,
        from:"Vanessa Myers <vmyers@rosenwood.com>",
		to: "Helena Rodriguez <hrodriguez@rosenwood.com>",
        subject:"RE: Status of the Audit Preparation",
        body:"Hello Helena, \n\n\n\nMy secretary left them printed in your office.\n\n\n\nBest,  \n\n\n\nVanessa Myers  \n\nFinance Director  \n\nRosenwood Corps",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:false
    },
	{
        id:90,
		thread_id: 5,
        from:"Helena Rodriguez <hrodriguez@rosenwood.com>",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"Status of the Audit Preparation",
        body:"Hello Vanessa,\n\n\n\nplease send me the finalized Q3 package by end of day. The board is requesting preliminary numbers earlier than expected.\n\n\n\nLet me know if anything delays your delivery.\n\n\n\nExpecting the best,\n\n\n\nHelena Rodriguez\n\n\n\nChief Financial Officer\n\n\n\nRosenwood Corps",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
	{
        id:100,
        from:"Facilities Manager <facilities@rosenwood.com>",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"Maintenance Notice: Elevator Inspection",
        body:"Please note that Elevator B will be unavailable from 1 PM to 3 PM on Tuesday for mandatory inspection. We apologize for the inconvenience.",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
	 {
        id:110,
        from:"Thomas Wylde <twylde@rosenwood.com>",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"Tonight's Update Cycle",
        body:"Hi Vanessa, \n\n\n\nWe will be running system updates tonight at 22:30. If you need anything preserved or delayed, notify me directly — not the team. I assume you understand why. \n\n\n\nGood luck,  \n\n\n\nThomas Wylde  \n\nIT Director  \n\nRosenwood Corps",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
	{
        id:120,
        from:"Richard Fowler <rfowler@rosenwood.com>",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"Equipment being moved without my approval",
        body:"Hey. \n\n\n\nNot sure who authorized changes in the Finance office layout, but someone unplugged one of the server pass-through cables again. This keeps happening. \n\nTell your team to contact IT before touching anything. Also, tell Sofia to come to my office for some training.\n\n\n\nAlways unmatched,  \n\n\n\nRichard Fowler \n\nSenior IT officer  \n\nRosenwood Corps",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
	 {
        id:130,
        from:"Rosenwood Corps HR <hr@rosenwood.com>",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"Upcoming Performance Review Deadlines",
        body:"Hello Vanessa, \n\nPlease submit completed performance evaluations for your direct reports by the 28th. All documentation must be uploaded through the internal portal.",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
	{
        id:146,
		thread_id: 11,
        from:"HR Department <hr@rosenwoodcorp.com>",
		to: "Vanessa Myers <v.myers@rosenwoodcorp.com>",
        subject:"Re: Follow-up — Case #2931",
        body:"Hi Vanessa,\n\nThank you for your concern and reaching out. Unfortunately, the investigation is still active and we are unable to disclose information to outside parties. We will contact \n\nMs. Dove if additional information is required.\n\nThank you,\n\nRosenwood HR Team",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:false
    },
	{
        id:147,
		thread_id: 11,
        from:"HR Automated Inbox <donotreplyhr@rosenwoodcorp.com>",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"Case Received — Please Do Not Reply",
        body:"Your email has been received.\n\nStatus: Under Review\n\nNo further action is needed.",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:false
    },
	{
        id:148,
		thread_id: 11,
        from:"Vanessa Myers <vmyers@rosenwood.com>",
		to: "HR Department <hr@rosenwood.com>",
        subject:"Follow Up - Case #2931",
        body:"Hi,\n\nI'm following up again on the case regarding Richard Fowler (Case #2931). The employee involved hasn't received any update or response to her inquiries.\n\nPlease advise.\n\nVanessa Myers\n\nRosenwood Financial Director",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:false
    },
	// Thread 10: Concern about Richard Fowler (Sofia's thread)
	 {
        id:150,
		thread_id: 10,
        from:"Sofia Dove <sdove@rosenwood.com>",
		to: "Vanessa Myers <vmyers@rosenwood.com>",
        subject:"Concern about Richard Fowler",
        body:"Hi Vanessa,\n\n\n\nThank you for listening earlier.\n\n\n\nI sent a formal email to HR last Friday about the situation I told you on Slack. I haven't heard anything back yet.\n\n\n\nI know you're busy, but… could you check if reports like that take often that long?\n\n\n\nI'm just really scared he'll find out I said anything.\n\n\n\nThanks again for caring.\n\n\n\nIt means a lot.\n\n\n\nSincerely,\n\n\n\nSofia Dove\n\n\n\nJunior Financial Analyst\n\n\n\nRosenwood Corps",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:true
    },
	 {
        id:149,
		thread_id: 10,
        from:"Vanessa Myers <vmyers@rosenwood.com>",
		to: "Sofia Dove <sdove@rosenwood.com>",
        subject:"RE:Concern about Richard Fowler",
        body:"Hi Sofia,\n\n\n\nWill do right now, I'm sending them an email.\n\n\n\nLet me know if you want to move into my office for the time being.\n\n\n\nSincerely,\n\n\n\nVanessa Myers\n\n\n\nFinance Director\n\n\n\nRosenwood Corps",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:false
    },
	{
        id:151,
		thread_id: 10,
        from:"Sofia Dove <s.dove@rosenwoodcorp.com>",
		to: "Vanessa Myers <v.myers@rosenwoodcorp.com>",
        subject:"Re: Concern about My Case",
        body:"Hi Vanessa,\n\n\n\nI've been trying to reach out to HR about my dispute with Mr. Fowler, but HR has yet to reply. It's been weeks.\n\n\n\nI don't know why they are not responding to my emails.\n\n\n\nI know everyone is swamped with work as we're approaching the end of the quarter, but this situation is affecting my work. I really wish I could move past this, and I'm \n\nsorry to make things awkward, but he's really starting to affect my work. He tried adding me on social media the other day and my name isn't even on it.\n\n\n\nI don't want to make a scene, but I don't feel safe.\n\n\n\nIf it's alright, I'd like to request a few days off just to pass the time away while HR investigates.\n\n\n\nThank you for your understanding.\n\n\n\nSincerely,\n\n\n\nSofia Dove",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:false
    },
	 {
        id:152,
		thread_id: 10,
        from:"Vanessa Myers <vmyers@rosenwood.com>",
		to: "Sofia Dove <sdove@rosenwood.com>",
        subject:"Re: Concern about My Case",
        body:"Granted.\n\n\n\nTake the days you need. I will take care of distributing your end of the reports.\n\n\n\nI'll escalate this to HR again.\n\n\n\nVanessa Myers\n\n\n\nRosenwood Financial Director",
        read:true, is_suspicious:false, is_corrupted:false, show_in_inbox:false
    },
];


/// --- Email Puzzle / Corrupted mail ---

puzzle_gate = true; // still here if you want to gate later

// Add a corrupted email entry
var _len = array_length(inbox);
inbox[_len] = {
    id           : 4,
    from         : "System",
    subject      : "System [CORRUPTED] !!!",
    body         : "This email is corrupted. Recover it to reveal your first key.",
    read         : false,
    is_suspicious: false,
    is_corrupted : true
};
corrupted_index = _len;

// Target sentence & word list
puzzle_target = ["Rosenwood", "Corporation", "sucks"];

puzzle_words  = [
    "Rosenwood",
    "Lilywood",
    "family",
    "Recover",
    "Corporation",
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

// start locked behind wifi, unless wifi has already been solved earlier
if (variable_global_exists("wifi_ever_connected") && global.wifi_ever_connected) {
    email_locked = false;
} else {
    email_locked = true;
}

email_locked_msg = "Cannot access Email.\nPlease connect to Wifi.";
