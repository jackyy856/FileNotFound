/// obj_RecycleBinApp - Create
event_inherited(); // from obj_AppBase

// window config
title = "Recycle Bin";
w     = 820;
h     = 560;
script_execute(_recalc);

// --- bin layout ---
bin_width       = 260;
bin_height      = 220;
bin_drop_margin = 80;   // thickness of “target ring” around bin

// --- files setup ---
file_count = 4;
files      = array_create(file_count);

// offsets are relative to bin center
var off_y_top    = -40;
var off_y_mid    = 0;
var off_y_bottom = 40;

// TEXT CONTENTS – short memes + kaomojis + transcript
var content_meme1 =
"deleted_meme_01.txt\n\n" +
"(╯°□°）╯︵ ┻━┻\n" +
"\"I only changed one line.\"\n" +
"– every broken build";

var content_meme2 =
"office_meme_02.png\n\n" +
"(ಥ﹏ಥ)\n" +
"\"When the bug fix introduces\n" +
"three new bugs.\"";

var content_decoy_note =
"Slack – #random\n\n" +
"dev1: did anyone push to prod on Friday?\n" +
"dev2: (o_o)\n" +
"dev3: let's never speak of this again.\n\n" +
"(Just junk. No useful clues here.)";

var content_vanessa_thomas =
"Thomas: Close the door behind you.\n" +
"Vanessa: Did.\n" +
"Vanessa: ..\n" +
"Vanessa: What do you know?\n" +
"Thomas: Everything. I found the bank statements while clearing some data.\n" +
"Thomas: It was a coincidence, though. Figuring that out.\n" +
"Vanessa: Where are you going with this?\n" +
"Thomas: Isn’t it obvious? I haven’t reported you nor have I the intention.\n" +
"Vanessa: …You also want to get rid of Richard.\n" +
"Thomas: Exactly. But I was never able to change the CTO’s mind. This might be the solution.\n" +
"Vanessa: Great. Back me up and we can put this behind.\n" +
"Thomas: Not so fast. You do understand what you did, right?\n" +
"Vanessa: Hah, take money from the project, send it to a ghost company and put Richard's name as the party to blame. That was it.\n" +
"Thomas: More than 100K dollars…\n" +
"Thomas: And, why are you so confident in saying it out loud, what if I am recording?\n" +
"Vanessa: You are not.\n" +
"Thomas: You seem sure of it.\n" +
"Vanessa: I can bet on it.\n" +
"Thomas: …You truly know how to read people.\n" +
"Vanessa: Just go back to the point. I have work to do.\n" +
"Thomas: Alright. In that case, you should know Richard won’t be the only one to fall.\n" +
"Vanessa: What?\n" +
"Thomas: That intern.. the one you used to get Richard’s access information, he was there when Richard \"did\" the embezzlement. What was his name?\n" +
"Vanessa: …Leonn.\n" +
"Thomas: He won’t go to prison. But I’ll have to fire him and blacklist him. He won’t find a job in a company as big as ours again. Maybe not even in the IT industry.\n" +
"Vanessa: …\n" +
"Thomas: Are you feeling bad?\n" +
"Vanessa: I can’t take it back.\n" +
"Thomas: You could.\n" +
"Vanessa: So I go to prison?\n" +
"Thomas: You did the crime.\n" +
"Vanessa: For Sofia.\n" +
"Thomas: To not feel bad about Sofia.\n" +
"Vanessa: …\n" +
"Thomas: Are you okay dragging an innocent party into this and destroying their career? You make that decision.\n" +
"Vanessa: I don’t care about that guy. Sofia is more important.\n" +
"Thomas: … You are crueler than I thought.\n" +
"Vanessa: Are you on my side or not?\n" +
"Thomas: I’ll help you. But you chose this. Don’t regret it.\n" +
"Vanessa: As if I could.";

text_surface = -1; // surface for clipping popup text

// helper to build file struct
function _make_file(_label, _color, _home_x, _home_y, _bw, _bh, _content) {
    return {
        label       : _label,
        color       : _color,
        home_off_x  : _home_x,
        home_off_y  : _home_y,
        x           : 0,
        y           : 0,
        in_bin      : true,
        dragging    : false,
        drag_dx     : 0,
        drag_dy     : 0,
        box_open    : false,
        box_x       : 0,
        box_y       : 0,
        box_w       : _bw,
        box_h       : _bh,
        // offsets so popups move with the window
        box_off_x   : 0,
        box_off_y   : 0,
        content     : _content,
        scroll      : 0,
        scroll_max  : 0,
        scroll_drag : false
    };
}

// four files (different colours, same logic)
files[0] = _make_file("meme_404.txt",       make_colour_rgb(190,220,255), -70, off_y_top,    360, 230, content_meme1);
files[1] = _make_file("meme_system32.png",  make_colour_rgb(255,210,210),  60, off_y_top,    360, 230, content_meme2);
files[2] = _make_file("slack_archive.log",  make_colour_rgb(210,255,210), -40, off_y_mid,    380, 240, content_decoy_note);
files[3] = _make_file("Transcript – V/T",   make_colour_rgb(255,245,200),  40, off_y_bottom, 520, 320, content_vanessa_thomas);
