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
"deleted_meme_01.txt# #" +
"(╯°□°）╯︵ ┻━┻#" +
"\"I only changed one line.\"#" +
"– every broken build";

var content_meme2 =
"office_meme_02.png# #" +
"(ಥ﹏ಥ)#" +
"\"When the bug fix introduces#" +
"three new bugs.\"";

var content_decoy_note =
"Slack – #random# #" +
"dev1: did anyone push to prod on Friday?#" +
"dev2: (o_o)#" +
"dev3: let's never speak of this again.# #" +
"(Just junk. No useful clues here.)";

var content_vanessa_thomas =
"Thomas: Close the door behind you.#" +
"Vanessa: Did.#" +
"Vanessa: ..#" +
"Vanessa: What do you know?#" +
"Thomas: Everything. (explains how*).#" +
"Thomas: It was a coincidence, though. Figuring that out.#" +
"Vanessa: Where are you going with this?#" +
"Thomas: Isn’t it obvious? I haven’t reported you nor have I the intention.#" +
"Vanessa: …You also want to get rid of Richard.#" +
"Thomas: Exactly. But I was never able to change the CTO’s mind. This might be the solution.#" +
"Vanessa: Great. Back me up and we can put this behind.#" +
"Thomas: Not so fast. You do understand what you did, right?#" +
"Vanessa: Hah, take money from the project, send it to a ghost company and put Richard's name as the party to blame. That was it.#" +
"Thomas: More than 100K dollars…#" +
"Thomas: And, why are you so confident in saying it out loud, what if I am recording?#" +
"Vanessa: You are not.#" +
"Thomas: You seem sure of it.#" +
"Vanessa: I can bet on it.#" +
"Thomas: …You truly know how to read people.#" +
"Vanessa: Just go back to the point. I have work to do.#" +
"Thomas: Alright. In that case, you should know Richard won’t be the only one to fall.#" +
"Vanessa: What?#" +
"Thomas: That intern.. the one you used to get Richard’s access information, he was there when Richard \"did\" the embezzlement. What was his name?#" +
"Vanessa: …Leonn.#" +
"Thomas: He won’t go to prison. But I’ll have to fire him and blacklist him. He won’t find a job in a company as big as ours again. Maybe not even in the IT industry.#" +
"Vanessa: …#" +
"Thomas: Are you feeling bad?#" +
"Vanessa: I can’t take it back.#" +
"Thomas: You could.#" +
"Vanessa: So I go to prison?#" +
"Thomas: You did the crime.#" +
"Vanessa: For Sofia.#" +
"Thomas: To not feel bad about Sofia.#" +
"Vanessa: …#" +
"Thomas: Are you okay dragging an innocent party into this and destroying their career? You make that decision.#" +
"Vanessa: I don’t care about that guy. Sofia is more important.#" +
"Thomas: … You are crueler than I thought.#" +
"Vanessa: Are you on my side or not?#" +
"Thomas: I’ll help you. But you chose this. Don’t regret it.#" +
"Vanessa: As if I could.";

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
