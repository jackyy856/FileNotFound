/// obj_GalleryApp - Create

// Inherit from AppBase so we get dragging + resizing + cursor changes
event_inherited();
title = "Gallery";

// Base window layout
window_w = 1700;
window_h = 900;
window_x = 120;
window_y = 100;

header_h   = 50;
row_height = 35;
nav_btn_size = 50;  // Navigation button size (needed before _recalc_gallery_layout)

// Window dragging state
window_dragging = false;
window_drag_dx = 0;
window_drag_dy = 0;

// Drag via border (for 4-way cursor)
drag_border = 12;
function _in_win(px,py){ return (px>=window_x)&&(py>=window_y)&&(px<window_x+window_w)&&(py<window_y+window_h); }
function _on_drag_border(px,py){
    var l = (abs(px - window_x) <= drag_border);
    var r = (abs(px - (window_x + window_w)) <= drag_border);
    var t = (px >= window_x && px < window_x + window_w && py >= window_y && py <= window_y + header_h); // Top bar
    var b = (abs(py - (window_y + window_h)) <= drag_border);
    return l || r || t || b;
}

// Function to recalculate all button positions (called after window moves)
function _recalc_gallery_layout() {
    close_btn    = [window_x + window_w - 40, window_y + 10, 30, 30]; 
    back_btn     = [window_x + 15, window_y + 10, 70, 30];
    left_btn     = [window_x + 30,
                    window_y + window_h / 2 - nav_btn_size / 2,
                    nav_btn_size, nav_btn_size];
    right_btn    = [window_x + window_w - nav_btn_size - 30,
                    window_y + window_h / 2 - nav_btn_size / 2,
                    nav_btn_size, nav_btn_size];
    
    zoom_in_btn    = [window_x + window_w - 50, window_y + header_h + 100, 40, 30];
    zoom_out_btn   = [window_x + window_w - 50, window_y + header_h + 140, 40, 30];
    zoom_reset_btn = [window_x + window_w - 50, window_y + header_h + 180, 40, 30];
    
    // inbox_key_rect is calculated dynamically in Draw event (like EmailApp)
    inbox_back_btn = [window_x + window_w - 140, window_y + header_h + 20,  100, 30];
    
    files_top    = window_y + header_h + 20;
    files_left   = window_x + 20;
    files_width  = window_w - 40;
    files_height = window_h - header_h - 40;
}

// Initialize button positions
_recalc_gallery_layout();

// State
gallery_open        = false;
fullscreen_mode     = false;
current_image_index = -1;
puzzle_mode         = false;
puzzle_completed    = false;
inbox_mode          = false; // inbox screen after puzzle completion
is_minimized        = false;

// Inbox key reward (local variable for immediate feedback)
inbox_key_collected = false;
inbox_key_rect = [0, 0, 0, 0]; // Calculated dynamically in Draw event

// Buttons (these are set by _recalc_gallery_layout, but keep for reference)
// close_btn, back_btn, left_btn, right_btn, etc. are all set in _recalc_gallery_layout()

// Zoom buttons
zoom_in_btn    = [window_x + window_w - 50, window_y + header_h + 100, 40, 30];
zoom_out_btn   = [window_x + window_w - 50, window_y + header_h + 140, 40, 30];
zoom_reset_btn = [window_x + window_w - 50, window_y + header_h + 180, 40, 30];

// Inbox UI: back button (now inside white area)
inbox_back_btn = [window_x + window_w - 140, window_y + header_h + 20,  100, 30];

// Image data - with puzzle integration
gallery_images = [
    { id: 0, sprite: Image1, name: "Cat",       date: "2024-01-01", is_puzzle: false },
    { id: 1, sprite: Image2, name: "People",    date: "2024-01-02", is_puzzle: false },
    { id: 2, sprite: Image3, name: "Store",     date: "2024-02-13", is_puzzle: false },
    { id: 3, sprite: Image4, name: "!!!",       date: "2024-02-29", is_puzzle: false },
    { id: 4, sprite: Image5, name: "??????",    date: "2024-05-25", is_puzzle: true }, // Puzzle image!
    { id: 5, sprite: Image6, name: "Building",  date: "2024-07-06", is_puzzle: false },
    { id: 6, sprite: Image7, name: "Personal",  date: "2024-08-25", is_puzzle: false },
];

total_images = array_length(gallery_images);

// Fullscreen viewer properties
zoom_scale  = 1.5;
min_zoom    = 0.5;
max_zoom    = 10.0;
pan_x       = 0;
pan_y       = 0;
is_dragging = false;
drag_start_x = 0;
drag_start_y = 0;

// Make sure key array exists (3 keys: green, red, golden)
if (!variable_global_exists("key_collected")) {
    global.key_collected = array_create(3, false);
}

// Function to open gallery
open_gallery = function() {
    gallery_open        = true;
    fullscreen_mode     = false;
    puzzle_mode         = false;
    inbox_mode          = false;
    current_image_index = -1;
    zoom_scale          = 1.0;
    pan_x = 0;
    pan_y = 0;
}

// Function to close gallery
close_gallery = function() {
    gallery_open    = false;
    puzzle_mode     = false;
    fullscreen_mode = false;
    inbox_mode      = false;
}

// Function to open fullscreen view 
open_fullscreen = function(index) {
    // Check if this is the puzzle image
    var is_puzzle_image = gallery_images[index].is_puzzle;
    
    if (is_puzzle_image) {
        // --- PUZZLE MODE ---
        puzzle_mode         = true;
        fullscreen_mode     = false;
        inbox_mode          = false;
        current_image_index = index;

        // Bring the Gallery window to the front
        if (!variable_global_exists("window_z_next")) {
            global.window_z_next = -10;
        }
        depth = global.window_z_next;
        global.window_z_next -= 1;

        // Create puzzle controller and put it slightly IN FRONT of Gallery
        var pm = instance_create_layer(0, 0, "Instances", obj_puzzle_manager);
        if (pm != noone) {
            pm.depth = depth - 1; 
        }

        return;
    }
    
    fullscreen_mode     = true;
    puzzle_mode         = false;
    inbox_mode          = false;
    current_image_index = index;
    
    var current_img  = gallery_images[index].sprite;
    var img_width    = sprite_get_width(current_img);
    var img_height   = sprite_get_height(current_img);
    
    var target_display_width  = 1150;
    var target_display_height = 1000;  
    
    var scale_width  = target_display_width / img_width;
    var scale_height = target_display_height / img_height;

    zoom_scale = min(scale_width, scale_height);
    zoom_scale = clamp(zoom_scale, 0.3, 3.0);
    
    pan_x = 0;
    pan_y = 0;
};

// Function to exit fullscreen
exit_fullscreen = function() {
    fullscreen_mode     = false;
    current_image_index = -1;
    zoom_scale          = 1.0;
    pan_x = 0;
    pan_y = 0;
}

// Function to exit puzzle mode
exit_puzzle = function() {
    puzzle_mode         = false;
    current_image_index = -1;
    
    // Destroy puzzle manager if it exists
    if (instance_exists(obj_puzzle_manager)) {
        instance_destroy(obj_puzzle_manager);
    }
    
    // Destroy all puzzle pieces
    with (obj_puzzle_piece) {
        instance_destroy();
    }
}

// Function to navigate between images 
navigate_image = function(direction) {
    current_image_index += direction;
    
    if (current_image_index < 0) {
        current_image_index = total_images - 1;
    } else if (current_image_index >= total_images) {
        current_image_index = 0;
    }
    
    var current_img = gallery_images[current_image_index].sprite;
    var img_width   = sprite_get_width(current_img);
    var img_height  = sprite_get_height(current_img);
    
    var target_display_width  = 1150;
    var target_display_height = 1100; 
    
    var scale_width  = target_display_width / img_width;
    var scale_height = target_display_height / img_height;

    zoom_scale = min(scale_width, scale_height);
    zoom_scale = clamp(zoom_scale, 0.3, 3.0);
    
    pan_x = 0;
    pan_y = 0;
}

// Function to check which file was clicked
get_clicked_file = function(mx, my) {
    if (mx < files_left || mx > files_left + files_width)  return -1;
    if (my < files_top  || my > files_top  + files_height) return -1;

    var file_y = files_top + 40; 

    for (var i = 0; i < total_images; i++) {
        if (check_point_in_rect(mx, my,
                                files_left, file_y,
                                files_left + files_width, file_y + row_height)) {
            return i;
        }
        file_y += (row_height + 6);
    }
    return -1;
};

// Function called when puzzle is completed
complete_puzzle = function() {
    if (puzzle_completed) return;
    
    puzzle_completed       = true;
    global.puzzleComplete  = true; 
    gallery_images[4].name = "Solved Puzzle!";
    
    // Close the puzzle UI and then open inbox (but DON'T give the key yet)
    exit_puzzle();
    gallery_open        = true;  // Ensure gallery is open so inbox can be drawn
    inbox_mode          = true;
    fullscreen_mode     = false;
    inbox_key_collected = false; // Reset local variable so key can be clicked
    // global.key_collected[1] stays false until player clicks the key in inbox
}

// Utility function
check_point_in_rect = function(px, py, x1, y1, x2, y2) {
    return (px >= x1 && px <= x2 && py >= y1 && py <= y2);
}

// Check button click
check_button_click = function(mx, my, button) {
    return check_point_in_rect(mx, my, button[0], button[1],
                               button[0] + button[2], button[1] + button[3]);
}
