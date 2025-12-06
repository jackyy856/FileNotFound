// --- Window/Layout ---
window_w = 1700;
window_h = 900;
window_x = 120;
window_y = 100;

header_h = 55;

// Second header line (breadcrumbs + buttons) and content start
breadcrumbs_y = window_y + header_h + 8;
buttons_y     = breadcrumbs_y - 4;
content_top   = breadcrumbs_y + 28;  // icon grid/content begins here

// Content area bounds
list_left = window_x + 16;
list_w    = window_w - 32;
list_h    = window_h - (content_top - window_y) - 16;

// Large icon grid params
icon_w   = 96;
icon_h   = 96;
cell_w   = 128;  // horizontal spacing per item
cell_h   = 140;  // vertical spacing per item (icon + label)
grid_cols = 10;  // tweak to taste

// Buttons (on breadcrumbs line)
close_btn = [window_x + window_w - 36,  window_y + 12, 24, 24];
// "< Back" (view mode only)
back_btn  = [window_x + window_w - 200, buttons_y,     74, 24];
// "Up" (when parent exists)
up_btn    = [window_x + window_w - 116, buttons_y,     64, 24];

// --- NEW: minimize + dragging (frame edges) ---
min_btn   = [window_x + window_w - 66, window_y + 12, 24, 24];
is_minimized = false;
dragging = false; 
drag_dx = 0; 
drag_dy = 0; 
drag_border = 12;

function _in_win(px,py){
    return (px>=window_x)&&(py>=window_y)&&(px<window_x+window_w)&&(py<window_y+window_h);
}
function _on_drag_border(px,py){
    var l = (abs(px - window_x) <= drag_border);
    var r = (abs(px - (window_x + window_w)) <= drag_border);
    var t = (abs(py - window_y) <= drag_border);
    var b = (abs(py - (window_y + window_h)) <= drag_border);
    return l || r || t || b;
}

// Fonts
var fTitle = asset_get_index("f_mail_title");
var fBody  = asset_get_index("f_mail_body");
if (fTitle != -1) { font_title = fTitle; } else { font_title = -1; }
if (fBody  != -1) { font_body  = fBody;  } else { font_body  = -1;  }

// --- State ---
mode = "list";           // "list" (grid) | "view" | "firewall"
selected_index = -1;     // selected grid index
viewer_type = "";        // "text" | "image"
viewer_text = "";
viewer_sprite = -1;

// show a key icon next to certain views
viewer_show_red_key = false;

// --- Firewall puzzle state ---
firewall_state     = "idle"; // "idle","play","auto","done"
firewall_cards     = [];
firewall_auto_t    = 0;
firewall_key_given = false; // set true once red key is awarded

// --- Filesystem (3 folders at root + Firewall puzzle file) ---
fs_root = {
    name: "Home", type: "folder", parent: noone, children: [
        { name:"Projects", type:"folder", parent:noone, children:[
            { name:"Note.txt", type:"text", content:
              "Project scratch:\n- Find backup codes\n- Meeting @ 3pm\n- Check sticky notes on the monitor", parent:noone }
        ]},
        { name:"HR", type:"folder", parent:noone, children:[
            { name:"Policy.txt", type:"text", content:
              "Password hints must be work-related. Start with your manager’s initials.", parent:noone }
        ]},
        { name:"Images", type:"folder", parent:noone, children:[
            { name:"clue.jpg", type:"image", sprite:-1, parent:noone }
        ]},
        // NEW: special puzzle file
        { name:"Firewall.exe", type:"puzzle_firewall", parent:noone }
    ]
};

// Wire parent pointers for navigation
function set_parents(node) {
    if (node.type == "folder") {
        var n = array_length(node.children);
        for (var i = 0; i < n; i++) {
            node.children[i].parent = node;
            set_parents(node.children[i]);
        }
    }
}
set_parents(fs_root);

// Start at root
cwd = fs_root;
breadcrumbs = [cwd];

// Assign an image sprite to Images/clue.jpg using your Gallery icon for now
var spr_gallery = asset_get_index("spr_GalleryIcon");
if (spr_gallery != -1) {
    fs_root.children[2].children[0].sprite = spr_gallery;
}

// --- NEW: centralized recalc when window moves ---
function _recalc_files_layout() {
    breadcrumbs_y = window_y + header_h + 8;
    buttons_y     = breadcrumbs_y - 4;
    content_top   = breadcrumbs_y + 28;

    list_left = window_x + 16;
    list_w    = window_w - 32;
    list_h    = window_h - (content_top - window_y) - 16;

    close_btn[0] = window_x + window_w - 36;  close_btn[1] = window_y + 12;
    min_btn[0]   = window_x + window_w - 66;  min_btn[1]   = window_y + 12;
    back_btn[0]  = window_x + window_w - 200; back_btn[1]  = buttons_y;
    up_btn[0]    = window_x + window_w - 116; up_btn[1]    = buttons_y;
}

// --- Firewall puzzle helpers ---
function firewall_add_card(_text, _index) {
    // cards start in a horizontal row near the bottom, not in either column
    var belt_y      = window_y + window_h - 180;
    var belt_x0     = window_x + 220;
    var belt_spacing = 220;

    var c = {
        text: _text,
        x: belt_x0 + _index * belt_spacing,
        y: belt_y,
        w: 520,
        h: 60,
        col: -1,        // -1 = not placed, 0 = Deny, 1 = Admit
        dragging:false,
        drag_dx:0,
        drag_dy:0
    };
    firewall_cards[array_length(firewall_cards)] = c;
}

function firewall_start() {
    firewall_state  = "play";
    firewall_auto_t = 0;
    firewall_cards  = [];
    viewer_show_red_key = false;

    // Sentences – tweak text as you like
    firewall_add_card("I didn't do it for Sophia",            0);
    firewall_add_card("I ruined his life",                    1);
    firewall_add_card("I lied about the fire",                2);
    firewall_add_card("I thought I could control everything", 3);
}

window_set_cursor(cr_default);
open_cooldown = 2;
