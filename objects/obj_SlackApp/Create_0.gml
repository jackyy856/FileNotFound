/// obj_SlackApp - Create

// ---------------- Window geometry ----------------
window_w = 820;
window_h = 460;
window_x = 40;
window_y = 40;

header_h = 32;

// header button size
btn_w  = 24;
btn_h  = 18;

// Helper: recompute all layout rectangles based on window position/size
_recalc_layout = function () {
    window_x2 = window_x + window_w;
    window_y2 = window_y + window_h;

    header_y2 = window_y + header_h;

    sidebar_x1 = window_x;
    sidebar_x2 = window_x + 260;

    content_y1 = header_y2 + 1;
    content_y2 = window_y2 - 1;

    chat_x1 = sidebar_x2 + 1;
    chat_x2 = window_x2 - 1;

    // header buttons depend on window edges
    btn_close_x1 = window_x2 - 8 - btn_w;
    btn_close_y1 = window_y + 7;
    btn_min_x1   = btn_close_x1 - 4 - btn_w;
    btn_min_y1   = window_y + 7;
};

// Helper: rectangle hit-test
_rect_contains = function(px, py, rx, ry, rw, rh) {
    return (px >= rx) && (px <= rx + rw) && (py >= ry) && (py <= ry + rh);
};

// Helper: word-wrap text into an array of lines that fit within max_w
_wrap_text = function(str, max_w) {
    var words = string_split(str, " ");
    var line  = "";
    var lines = [];

    var count = array_length(words);
    for (var i = 0; i < count; i++) {
        var w = words[i];
        var candidate;

        if (line == "") candidate = w;
        else            candidate = line + " " + w;

        // measure candidate
        if (string_width(candidate) > max_w) {
            // push current line, start new
            array_push(lines, line);
            line = w;
        } else {
            line = candidate;
        }
    }

    if (line != "") {
        array_push(lines, line);
    }

    return lines;
};

// set font used by Slack app
if (variable_global_exists("font_body")) {
    font_body = global.font_body;   // use global UI font if defined
} else {
    font_body = draw_get_font();    // fall back to current font
}

// initialize layout once
_recalc_layout();

// ---------------- Minimized tab ----------------
is_minimized   = false;
min_tab_w      = 90;
min_tab_h      = 24;
min_tab_margin = 8;

// Dragging
is_dragging = false;
drag_dx     = 0;
drag_dy     = 0;

window_focus   = true;
open_cooldown  = 0;

// ---------------- Channels & DM list ----------------
channels = [
    "#finance",
    "#fin_reminders",
    "#corpwide-events",
    "#IT_helpdesk"
];

dm_names = [
    "Sofia Dove",
    "Corey",
    "Elizabeth",
    "Thomas W",
    "Leonn S"
];

// ====== DM conversations (all with timestamps) ======

var sofia_msgs = [
    { text: "Hey, are you free to look at the quarterly report later?", who: "them", time: "9:41 AM" },
    { text: "I’ll be in the office after 3.",                            who: "them", time: "9:43 AM" },
    { text: "Sure, send it over.",                                      who: "me",   time: "9:45 AM" }
];

var corey_msgs = [
    { text: "VPN is acting strange on my laptop again.",                 who: "them", time: "10:12 AM" },
    { text: "Try reconnecting to the corp network. If it breaks again, screenshot the error.", who: "me", time: "10:15 AM" }
];

var elizabeth_msgs = [
    { text: "Reminder: audit logs need to be exported by EOD.",          who: "them", time: "11:02 AM" },
    { text: "Got it. I’ll send you a link when they’re ready.",          who: "me",   time: "11:05 AM" }
];

var thomas_msgs = [
    { text: "Security wants a summary of the incident from last week.",  who: "them", time: "2:18 PM" },
    { text: "I’ll draft something and send it to you for review.", who: "me", time: "2:22 PM" },

    // ---- Your added escalation ----
    { text: "I know what you did.",                                     who: "them", time: "4:10 PM" },
    { text: "Let’s meet tomorrow at C-306. 6PM.",                        who: "them", time: "4:12 PM" },

    // hours later
    { text: "I voice-recorded the meeting.",                             who: "me",   time: "9:03 PM" },
    { text: "Of course you did... Just delete. And also, keep the bank statements in a safe place.", who: "them", time: "9:05 PM" }
];

// =======================
// Leonn S conversation with dates + timestamps
// =======================
var leonn_msgs = [

    // ---- Day 1 ----
    { kind: "day", label: "7 mos. ago" },

    { kind: "msg", who: "them",
      text: "um hi Ms Myers, my name is Leonn, i'm an intern under Mr Fowler. I fixed the VPN issue we've been having..",
      time: "10:08 AM" },

    { kind: "msg", who: "me",
      text: "Thanks.",
      time: "10:11 AM" },


    // ---- Day 2 ----
    { kind: "day", label: "7 mos. ago" },

    { kind: "msg", who: "them",
      text: "i saw you in the cafeteria today",
      time: "11:23 AM" },

    { kind: "msg", who: "me",
      text: "?",
      time: "11:24 AM" },

    { kind: "msg", who: "them",
      text: "you looked really stressed.",
      time: "11:25 AM" },

    { kind: "msg", who: "me",
      text: "Comes with the job.",
      time: "11:26 AM" },

    { kind: "msg", who: "them",
      text: "i can help if you like. i've been studying our logs.",
      time: "11:30 AM" },

    { kind: "msg", who: "me",
      text: "You’re an intern.",
      time: "11:32 AM" },

    { kind: "msg", who: "them",
      text: "yeah but im good at this! i already flagged 3 weird access patterns. im not supposed to touch them though.",
      time: "11:34 AM" },

    { kind: "msg", who: "me",
      text: "Send me what you have.",
      time: "11:36 AM" },


    // ---- Day 3 ----
    { kind: "day", label: "6 mos. ago" },

    { kind: "msg", who: "them",
      text: "sent you an email with my notes btw.",
      time: "9:02 AM" },

    { kind: "msg", who: "me",
      text: "I saw it.",
      time: "9:05 AM" },

    { kind: "msg", who: "them",
      text: "mr fowler doesnt listen when i talk about these things. he says “stay in your lane”.",
      time: "9:07 AM" },

    { kind: "msg", who: "me",
      text: "He’s old-school.",
      time: "9:09 AM" },

    { kind: "msg", who: "them",
      text: "but YOU listened. :)",
      time: "9:10 AM" },

    { kind: "msg", who: "me",
      text: "I listened because the numbers matter.",
      time: "9:11 AM" },

    { kind: "msg", who: "them",
      text: "numbers and people… maybe?",
      time: "9:12 AM" },


    // ---- Day 4 ----
    { kind: "day", label: "6 mos. ago" },

    { kind: "msg", who: "them",
      text: "I think someone’s trying to cover their tracks now. the logs look scrubbed.",
      time: "3:01 PM" },

    { kind: "msg", who: "me",
      text: "Whose tracks.",
      time: "3:03 PM" },

    { kind: "msg", who: "them",
      text: "not sure yet. but the IP range lines up with an office on C-floor.",
      time: "3:04 PM" },

    { kind: "msg", who: "me",
      text: "Forward me everything. Do not mention this to anyone else.",
      time: "3:06 PM" },

    { kind: "msg", who: "them",
      text: "ok. promise.",
      time: "3:07 PM" },


    // ---- later that day ----
    { kind: "msg", who: "them",
      text: "c-floor is where the execs sit right?",
      time: "4:01 PM" },

    { kind: "msg", who: "me",
      text: "Focus on the data, Leonn.",
      time: "4:03 PM" },

    { kind: "msg", who: "them",
      text: "sorry miss myers. data only. got it.",
      time: "4:05 PM" },


    // ---- Day 5 ----
    { kind: "day", label: "6 mos. ago" },

    { kind: "msg", who: "them",
      text: "I ran another pass on the logs… it’s definitely someone with elevated access.",
      time: "1:12 PM" },

    { kind: "msg", who: "me",
      text: "Leave it with me.",
      time: "1:14 PM" },

    { kind: "msg", who: "them",
      text: "ok. be careful though.",
      time: "1:15 PM" },

    { kind: "msg", who: "me",
      text: "I know what I’m doing.",
      time: "1:16 PM" },


    // ---- Later, softer ----
    { kind: "msg", who: "them",
      text: "you always sound so sure. its kinda cool.",
      time: "2:01 PM" },

    { kind: "msg", who: "me",
      text: "Confidence is a tool.",
      time: "2:03 PM" },

    { kind: "msg", who: "them",
      text: "you’re good at using it.",
      time: "2:04 PM" },

    { kind: "msg", who: "me",
      text: "You should not use my DMs for this.",
      time: "2:04 PM" },

    { kind: "msg", who: "them",
      text: "sorry sorry omg",
      time: "2:05 PM" },

    { kind: "msg", who: "me",
      text: "Dont do it too much.",
      time: "2:07 PM" },

    { kind: "msg", who: "them",
      text: "ooh. yes ma'am! :3",
      time: "2:08 PM" },


    // ---- Same day, later ----
    { kind: "msg", who: "them",
      text: "can i stay in your office for a bit? richard is being weird today.",
      time: "3:19 PM" },

    { kind: "msg", who: "me",
      text: "Sure. Close the door.",
      time: "3:21 PM" },


    // ---- Richard gossip block ----
    { kind: "msg", who: "them",
      text: "my boss is kinda bothersome",
      time: "4:03 PM" },

    { kind: "msg", who: "me",
      text: "Is he? How?",
      time: "4:04 PM" },

    { kind: "msg", who: "them",
      text: "yes! he thinks he truly is the best but well, he is...he isnt even THAT good, i can do better than that as an intern.",
      time: "4:08 PM" },

    { kind: "msg", who: "me",
      text: "Thats cool.",
      time: "4:10 PM" },

    { kind: "msg", who: "them",
      text: "...yeah. i am. i wish i had a boss like you, Miss Myers",
      time: "4:12 PM" },

    { kind: "msg", who: "them",
      text: "whatevs. i got left behind again by the rest of IT. wanna have lunch together?",
      time: "4:27 PM" },

    { kind: "msg", who: "me",
      text: "Sure. While we're at it, I'd like to discuss Richard.",
      time: "4:30 PM" }
];

// Pack DM conversations into array
dm_convos = [
    sofia_msgs,
    corey_msgs,
    elizabeth_msgs,
    thomas_msgs,
    leonn_msgs
];

// ---------------- Selection & scrolling defaults ----------------

// No channel selected by default
selected_channel = -1;

// Default DM: the last one ("Leonn S")
selected_dm = array_length(dm_names) - 1;

// Start with large scroll; Draw GUI clamps so we begin at bottom
chat_scroll = 100000;
