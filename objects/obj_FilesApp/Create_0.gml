// --- Window/Layout (mirrors EmailApp sizing) ---
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
back_btn  = [window_x + window_w - 200, buttons_y,     74, 24]; // "< Back" (view mode only)
up_btn    = [window_x + window_w - 116, buttons_y,     64, 24]; // "Up" (when parent exists)

// Fonts
var fTitle = asset_get_index("f_mail_title");
var fBody  = asset_get_index("f_mail_body");
if (fTitle != -1) { font_title = fTitle; } else { font_title = -1; }
if (fBody  != -1) { font_body  = fBody;  } else { font_body  = -1;  }

// --- State ---
mode = "list";           // "list" (grid) or "view"
selected_index = -1;     // selected grid index
viewer_type = "";        // "text" | "image"
viewer_text = "";
viewer_sprite = -1;

// --- Helpers ---
function is_locked() {
    return is_undefined(global.apps_unlocked) || !is_struct(global.apps_unlocked) || !global.apps_unlocked.Files;
}

// --- Filesystem Trees ---
fs_root = {
    name: "Home", type: "folder", parent: noone, children: [
        { name:"Projects", type:"folder", parent: noone, children:[
            { name:"Q3_Report.txt", type:"text", content:
              "Quarterly notes:\n- Budget variances flagged\n- Pending approvals\n- Reminder: HR audit next week", parent:noone },
            { name:"TeamPhoto.jpg", type:"image", sprite:-1, parent:noone } // assign sprite later if you want
        ]},
        { name:"HR", type:"folder", parent: noone, children:[
            { name:"Policy.txt", type:"text", content:
              "All password hints are work-related. Start with your manager’s initials.", parent:noone }
        ]},
        { name:"todo.txt", type:"text", content:
          "- Call IT\n- Clean desktop\n- Delete old backups", parent:noone }
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

// Minimal tree while locked (Clues + Images)
fs_locked = {
    name: "Files", type: "folder", parent: noone, children: [
        { name:"Clues", type:"folder", parent:noone, children: [
            { name:"Note.txt", type:"text", content:
              "hey — if you're reading this, you're early.\n\nhint: Get the clue from images folder.\n", parent:noone }
        ]},
        { name:"Images", type:"folder", parent:noone, children: [
            { name:"clue.jpg", type:"image", sprite:-1, parent:noone } // will assign a sprite below
        ]}
    ]
};
set_parents(fs_locked);

// Choose initial root based on lock
was_locked = is_locked();
if (was_locked) { cwd = fs_locked; } else { cwd = fs_root; }
breadcrumbs = [cwd];

// Example: use Gallery app icon as the image thumbnail/content for clue.jpg
var spr = asset_get_index("spr_GalleryIcon");
if (spr != -1) {
    // fs_locked.children[1] is "Images"; its first child is "clue.jpg"
    fs_locked.children[1].children[0].sprite = spr;
}

// (Optional) Give TeamPhoto.jpg a sprite too (reusing Gallery icon)
var spr2 = asset_get_index("spr_GalleryIcon");
if (spr2 != -1) {
    // fs_root.children[0] == Projects; second child == TeamPhoto.jpg
    fs_root.children[0].children[1].sprite = spr2;
}
