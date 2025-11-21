// Gallery layout
window_w = 1700;
window_h = 900;
window_x = 120;
window_y = 100;

header_h = 50;
row_height = 35;

// File browser style layout
files_top = window_y + header_h + 20;
files_left = window_x + 20;
files_width = window_w - 40;
files_height = window_h - header_h - 40;

// State
gallery_open = false;
fullscreen_mode = false;
current_image_index = -1;
puzzle_mode = false;
puzzle_completed = false;

// Buttons
close_btn = [window_x + window_w - 40, window_y + 10, 30, 30]; 
back_btn  = [window_x + 15, window_y + 10, 70, 30];
nav_btn_size = 50;
left_btn  = [window_x + 30, window_y + window_h/2 - nav_btn_size/2, nav_btn_size, nav_btn_size];
right_btn = [window_x + window_w - nav_btn_size - 30, window_y + window_h/2 - nav_btn_size/2, nav_btn_size, nav_btn_size];
// Zoom buttons
zoom_in_btn = [window_x + window_w - 50, window_y + header_h + 100, 40, 30];
zoom_out_btn = [window_x + window_w - 50, window_y + header_h + 140, 40, 30];
zoom_reset_btn = [window_x + window_w - 50, window_y + header_h + 180, 40, 30];

// Image data - with puzzle integration
gallery_images = [
    { id: 0, sprite: Image1, name: "Info", date: "2024-01-01", is_puzzle: false },
    { id: 1, sprite: Image2, name: "files", date: "2024-03-02", is_puzzle: false },
    { id: 2, sprite: Image3, name: "Images", date: "2024-04-13", is_puzzle: false },
    { id: 3, sprite: Image4, name: "Latop", date: "2024-04-29", is_puzzle: false },
    { id: 4, sprite: Image5, name: "??????", date: "2024-05-25", is_puzzle: true }, // Puzzle image!
    { id: 5, sprite: Image6, name: "****", date: "2024-07-06", is_puzzle: false },
    { id: 6, sprite: Image7, name: "Project", date: "2024-08-25", is_puzzle: false },
    { id: 7, sprite: Image8, name: "Personal", date: "2024-10-08", is_puzzle: false },
    { id: 8, sprite: Image9, name: "Document", date: "2024-11-29", is_puzzle: false },
    { id: 9, sprite: Image10, name: "Desktop", date: "2024-12-14", is_puzzle: false }
];

total_images = array_length(gallery_images);

// Fullscreen viewer properties
zoom_scale = 1.5;
min_zoom = 0.5;
max_zoom = 10.0;
pan_x = 0;
pan_y = 0;
is_dragging = false;
drag_start_x = 0;
drag_start_y = 0;

// Function to open gallery
open_gallery = function() {
    gallery_open = true;
    fullscreen_mode = false;
    puzzle_mode = false;
    current_image_index = -1;
    zoom_scale = 1.0;
    pan_x = 0;
    pan_y = 0;
}

// Function to close gallery
close_gallery = function() {
    gallery_open = false;
    puzzle_mode = false;
    fullscreen_mode = false;
}

// Function to open fullscreen view
open_fullscreen = function(index) {
    // Check if this is the puzzle image
    var is_puzzle_image = gallery_images[index].is_puzzle;
    
    if (is_puzzle_image) {
        // Open puzzle mode instead of normal fullscreen
        puzzle_mode = true;
        fullscreen_mode = false;
        current_image_index = index;
        
        // Create puzzle controller
        instance_create_layer(0, 0, "Instances", obj_puzzle_manager);
        
        return;
    }
    
    // Normal image - proceed with regular fullscreen
    fullscreen_mode = true;
    puzzle_mode = false;
    current_image_index = index;
    
    var current_img = gallery_images[index].sprite;
    var img_width = sprite_get_width(current_img);
    var img_height = sprite_get_height(current_img);
    
    // Set fixed box size
    var box_width = 600;   
    var box_height = 400;  
    
    // Calculate scale to fit within box (maintains aspect ratio)
    var scale_x = box_width / img_width;
    var scale_y = box_height / img_height;
    zoom_scale = min(scale_x, scale_y);  // Fits entirely within box
    
    pan_x = 0;
    pan_y = 0;
}

// Function to exit fullscreen
exit_fullscreen = function() {
    fullscreen_mode = false;
    current_image_index = -1;
    zoom_scale = 1.0;
    pan_x = 0;
    pan_y = 0;
}

// Function to exit puzzle mode
exit_puzzle = function() {
    puzzle_mode = false;
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
    
    // Set the same pixel width for the new image
    var current_img = gallery_images[current_image_index].sprite;
    var img_width = sprite_get_width(current_img);
    zoom_scale = 600 / img_width;  // Same 600 pixel width
    
    pan_x = 0;
    pan_y = 0;
}

// Function to check which file was clicked
get_clicked_file = function(mx, my) {
    if (mx < files_left || mx > files_left + files_width) return -1;
    if (my < files_top || my > files_top + files_height) return -1;
    
    var file_y = files_top + 10;
    for (var i = 0; i < total_images; i++) {
        if (check_point_in_rect(mx, my, files_left, file_y, files_left + files_width, file_y + row_height)) {
            return i;
        }
        file_y += (row_height + 6);
    }
    return -1;
}

// Function called when puzzle is completed
complete_puzzle = function() {
    puzzle_completed = true;
    global.puzzleComplete = true; // Set global flag for save system
    
    // Change the puzzle image name to show it's solved
    gallery_images[4].name = "Solved Puzzle!";
}

// Utility function
check_point_in_rect = function(px, py, x1, y1, x2, y2) {
    return (px >= x1 && px <= x2 && py >= y1 && py <= y2);
}

// Check button click
check_button_click = function(mx, my, button) {
    return check_point_in_rect(mx, my, button[0], button[1], button[0] + button[2], button[1] + button[3]);
}