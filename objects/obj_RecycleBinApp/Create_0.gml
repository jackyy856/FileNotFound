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
"Vanessa: ...\n" +
"Vanessa: What do you know?\n" +
"Thomas: Enough.\n" +
"Thomas: Q3 backup routine flagged a mismatch on the finance server.\n" +
"Thomas: I pulled the raw logs. Night access from your laptop, 2:13 a.m., three days before the internal audit.\n" +
"Vanessa: You go through everyone’s late-night sessions now?\n" +
"Thomas: Only the ones that reroute a five-figure transfer through a ghost vendor with no payroll, no tax ID, and an address that’s a parking lot.\n" +
"Thomas: The money leaves Rosenwood, lands in that shell, then vanishes into three smaller accounts. Classic.\n" +
"Vanessa: Where are you going with this?\n" +
"Thomas: Isn’t it obvious? I know you did the embezzlement, Vanessa. And I know you rewrote the trail.\n" +
"Thomas: Access keys, approval stamps, device IDs… all rewritten so it looks like Richard pushed the payment himself.\n" +
"Thomas: Take money from the project, send it to a ghost company, put Richard’s name on the paperwork, and let everyone finally see him as the problem.\n" +
"Vanessa: That’s the summary...\n" +
"Thomas: A few dozen grand...\n" +
"Thomas: I have to admit, it's genious\n" +
"Vanessa: ...\n" +
"Thomas: Don't give me that look. You're not in trouble quite yet." +
"Vanessa: I don't follow?\n" +
"Thomas: We were already watching him for Sofia’s case, nobody will question it.\n" +
"Vanessa: HR wasn’t watching him. HR buried her case.\n" +
"Thomas: Exactly. Several emails from Sofia. More follow-ups from you. Case number, timestamps, nothing done.\n" +
"Thomas: Legal told them to be careful because Richard is close to the CTO. HR chose to sit on it.\n" +
"Thomas: You decided to solve it another way.\n" +
"Vanessa: I did what they refused to do.\n" +
"Thomas: And where's your denial? What if I’m recording?\n" +
"Vanessa: You’re not.\n" +
"Thomas: You seem very sure of that.\n" +
"Vanessa: I can bet on it.\n" +
"Thomas: ...You really do know how to read people.\n" +
"Vanessa: Then stop circling. You haven’t reported me, and you don’t intend to.\n" +
"Vanessa: Because you also want Richard gone.\n" +
"Thomas: Correct.\n" +
"Thomas: I’ve tried to get the CTO to cut him loose for years. Complaints, performance flags, nothing sticks.\n" +
"Thomas: This? This sticks.\n" +
"Vanessa: Good. Back me up, and we can put this behind us.\n" +
"Thomas: Not so fast.\n" +
"Thomas: You do understand what you actually set in motion, right?\n" +
"Vanessa: You just explained it.\n" +
"Thomas: No. I explained the money.\n" +
"Thomas: I’m talking about everyone who gets dragged down with him on paper.\n" +
"Vanessa: ...What are you implying?\n" +
"Thomas: The night 'Richard' did the embezzlement, he wasn’t logged in alone.\n" +
"Thomas: Your little leverage. The intern he keeps glued to his side.\n" +
"Thomas: He’s on the same VPN tunnel, same room, same timestamp. Witness by proximity.\n" +
"Vanessa: ...Leonn.\n" +
"Thomas: Yes. Your friendly IT puppy.\n" +
"Thomas: The logs show him escalating Richard’s permissions earlier that week. Under orders, sure, but HR and Legal won’t care.\n" +
"Thomas: When this goes up the chain, they’ll see a senior officer and his junior both tied to the same dirty transaction.\n" +
"Vanessa: Is he going to prison?\n" +
"Thomas: No. Richard will. The intern will just be fired, blacklisted, and quietly flagged as 'security risk' in every reference call.\n" +
"Thomas: No big firm will touch him again. Maybe not even a mid-tier one.\n" +
"Vanessa: ...\n" +
"Thomas: Are you feeling bad?\n" +
"Vanessa: I can’t take it back.\n" +
"Thomas: You could.\n" +
"Thomas: I redact the report, kill the alerts, restore the original transaction trail, and we both pretend I never saw any of this.\n" +
"Vanessa: So I go to prison instead, is that it?\n" +
"Thomas: You did the crime.\n" +
"Vanessa: I did it because HR left Sofia alone.\n" +
"Thomas: You did it because you couldn’t live with feeling helpless about Sofia.\n" +
"Thomas: That’s not the same thing.\n" +
"Vanessa: ...\n" +
"Thomas: So here it is.\n" +
"Thomas: Are you okay dragging an innocent party into this and destroying his career to get Richard out and protect yourself?\n" +
"Thomas: You decide that. Not me.\n" +
"Vanessa: I don’t care about that guy.\n" +
"Vanessa: Sofia is more important. My life is more important.\n" +
"Thomas: ...You’re crueler than I thought.\n" +
"Vanessa: Are you on my side or not?\n" +
"Thomas: I’ll help you.\n" +
"Thomas: I’ll write the report so Richard takes the full fall, and Leonn is just 'careless' enough to be disposable.\n" +
"Thomas: HR gets their neat resolution, the CTO loses his favorite dog, and nobody asks why the numbers never quite balanced before.\n" +
"Thomas: But you chose this. Don’t pretend you were forced.\n" +
"Vanessa: As if I could ever forget...";

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
