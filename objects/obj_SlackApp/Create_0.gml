/// Slack-style messaging app window

// ---------------- Window & layout ----------------
window_x = 260;
window_y = 120;
window_w = 920;   // a bit wider than before
window_h = 560;
header_h = 38;

is_dragging = false;
drag_dx = 0;
drag_dy = 0;

is_minimized = false;
open_cooldown = 6;  // avoid click-through when freshly opened

sidebar_w = 270;    // slightly wider sidebar
row_h = 26;

window_focus = true;

function _rect_contains(px, py, rx, ry, rw, rh) {
    return (px >= rx) && (py >= ry) && (px < rx + rw) && (py < ry + rh);
}

function _recalc_layout() {
    window_x2 = window_x + window_w;
    window_y2 = window_y + window_h;
    header_y2 = window_y + header_h;

    sidebar_x1 = window_x;
    sidebar_x2 = window_x + sidebar_w;

    content_y1 = header_y2 + 1;
    content_y2 = window_y2 - 1;

    chat_x1 = sidebar_x2 + 1;
    chat_x2 = window_x2 - 1;

    // header buttons
    btn_w = 24;
    btn_h = 18;
    btn_pad = 6;

    btn_close_x1 = window_x2 - btn_w - btn_pad;
    btn_close_y1 = window_y + (header_h - btn_h) div 2;

    btn_min_x1 = btn_close_x1 - btn_w - 4;
    btn_min_y1 = btn_close_y1;
}

_recalc_layout();

// ---------------- Fonts ----------------
font_title = -1; // default
font_body  = -1; // default

// ---------------- Channels ----------------
channels = [
    "#finance",
    "#fin_reminders",
    "#corpwide-events",
    "#IT_helpdesk"
];

// start in DMs (Sofia)
selected_channel = -1;
selected_dm = 0;

// ---------------- Direct Messages data ----------------
// message: { who:"me"/"them", text:"..." }

// Sofia Dove – warm emojis, lore, ending line
var sofia = [
    { who:"them", text:"hi Vanessa!! thanks again for hearing me out earlier 🧡" },
    { who:"them", text:"i still feel sick thinking about Richard cornering me in that meeting" },
    { who:"me",   text:"You did nothing wrong. HR should have listened sooner." },
    { who:"them", text:"sometimes I wonder if they only acted because the numbers looked bad…" },
    { who:"them", text:"I didn’t expect Richard to do embezzlement, but I’m happy he is out." }
];

// Corey – “did u check that spreadsheet?” + extension begging
var corey = [
    { who:"them", text:"hey, did u check that spreadsheet?" },
    { who:"them", text:"deadline is kinda brutal, can we move it to friday?" },
    { who:"me",   text:"No. We agreed on today, Corey." },
    { who:"them", text:"okok but what about the risk report extension" },
    { who:"me",   text:"Also no. Finish what you start." },
    { who:"them", text:"got it. did u check that spreadsheet?" }
];

// Elizabeth – mentor admiration, wants new supervisor
var eliz = [
    { who:"them", text:"Good afternoon Ms Myers, it is a pleasure to work with you." },
    { who:"them", text:"I would appreciate it a lot if you could mentor me a bit more." },
    { who:"me",   text:"Schedule 30 minutes on my calendar next week." },
    { who:"them", text:"Thank you! Also… I wanted to ask if it is possible to be transferred to a new supervisor." },
    { who:"them", text:"I respect Corey, but I do not feel he is the right fit for how I work." },
    { who:"them", text:"You set clear expectations, and I really admire that." }
];

// Thomas W – short messages, then the “I know what you did” thread
var thomas = [
    { who:"them", text:"I fixed this." },
    { who:"me",   text:"Ok." },
    { who:"them", text:"The meeting has started." },
    { who:"me",   text:"Alright." },
    { who:"them", text:"I need someone now to fix this." },
    { who:"me",   text:"Ok." },
    { who:"them", text:"I know what you did.\nLet’s talk face-to-face tomorrow." },
    { who:"me",   text:"I recorded it." },
    { who:"them", text:"Made sure to eliminate it." }
];

// Leonn S – starts awkward, becomes friendly & info source
var leonn = [
    { who:"them", text:"um hi Ms Myers, my name is Leonn, i’m an intern under Mr Fowler.\nI fixed the VPN thing.." },
    { who:"me",   text:"Thanks." },
    { who:"them", text:"I saw you in the cafeteria today" },
    { who:"me",   text:"?" },
    { who:"them", text:"Everyone in my office went out for lunch but me. I saw you from afar." },
    { who:"me",   text:"??" },
    { who:"them", text:"I’m heading to your office to check on the router! And also bringing some donuts?" },
    { who:"me",   text:"You should not use my DMs for this." },
    { who:"them", text:"sorry sorry omg" },
    { who:"me",   text:"Don’t do it too much." },
    { who:"them", text:"ooh. yes ma’am! 😺" },
    { who:"them", text:"can I stay in your office for a bit? Richard is being weird today." },
    { who:"me",   text:"Sure. Close the door." },
    { who:"them", text:"my boss is kinda bothersome" },
    { who:"me",   text:"Is he? How?" },
    { who:"them", text:"yes! he thinks he truly is the best but well, he is a senior but that’s all for connections – he is close to the CTO." },
    { who:"them", text:"otherwise he wouldnt be there… his code isn’t even THAT good, i can do better than that as an intern." },
    { who:"me",   text:"That’s cool." },
    { who:"them", text:"…yeah. I am. I wish I had a boss like you, Van" },
    { who:"me",   text:"Van?" },
    { who:"them", text:"likeanicknameuknow uh ah yes." },
    { who:"them", text:"whatevs. i got left behind again by the rest of IT. wanna have lunch together?" },
    { who:"me",   text:"Sure. Tell me more about Richard." },
    { who:"them", text:"😅🐱✨" } // random emojis Vanessa ignores
];

dm_names = [
    "Sofia Dove",
    "Corey",
    "Elizabeth",
    "Thomas W",
    "Leonn S"
];

dm_convos = [
    sofia,
    corey,
    eliz,
    thomas,
    leonn
];

// ---------------- Chat scroll ----------------
chat_scroll = 0;

// ---------------- Minimized tab layout ----------------
min_tab_w = 180;
min_tab_h = 24;
min_tab_margin = 12;
