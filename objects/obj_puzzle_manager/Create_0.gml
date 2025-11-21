show_debug_message("PUZZLE CONTROLLER CREATED");

// Window / layout inside Gallery
window_x = 120;
window_y = 100;
window_w = 1700;
window_h = 900;
header_h = 50;

// Grid: 2 rows × 5 columns = 10 pieces
var piece_cols = 5;
var piece_rows = 2;

global.total_pieces  = piece_cols * piece_rows;
global.pieces_placed = 0;
global.snap_distance = 30;

// Use the puzzle image
var img_sprite = Image5;
if (!sprite_exists(img_sprite)) {
    show_debug_message("ERROR: Image5 not found!");
    instance_destroy();
    exit;
}

// LEFT: puzzle area (reference image)
puzzle_area_x      = window_x + 50;
puzzle_area_y      = window_y + header_h + 40;
puzzle_area_width  = 800;
puzzle_area_height = 600;

// RIGHT: piece area
var pieces_area_x      = puzzle_area_x + puzzle_area_width + 80;
var pieces_area_y      = puzzle_area_y;
var pieces_area_width  = 500;
var pieces_area_height = 600;

// Store for pieces
global.pieces_area_x      = pieces_area_x;
global.pieces_area_y      = pieces_area_y;
global.pieces_area_width  = pieces_area_width;
global.pieces_area_height = pieces_area_height;

// Image info & scaling
var img_width  = sprite_get_width(img_sprite);
var img_height = sprite_get_height(img_sprite);

var scale_x = puzzle_area_width  / img_width;
var scale_y = puzzle_area_height / img_height;
var target_scale = min(scale_x, scale_y);

var scaled_width  = img_width  * target_scale;
var scaled_height = img_height * target_scale;

var image_offset_x = (puzzle_area_width  - scaled_width)  / 2;
var image_offset_y = (puzzle_area_height - scaled_height) / 2;

// Store globals
global.puzzle_img        = img_sprite;
global.puzzle_scale      = target_scale;
global.puzzle_area_x     = puzzle_area_x;
global.puzzle_area_y     = puzzle_area_y;
global.puzzle_area_width = puzzle_area_width;
global.puzzle_area_height = puzzle_area_height;
global.image_offset_x    = image_offset_x;
global.image_offset_y    = image_offset_y;
global.piece_cols        = piece_cols;
global.piece_rows        = piece_rows;

// Arrays for positions, colors, and source rectangles
global.piece_positions = array_create(global.total_pieces);
global.piece_colors    = array_create(global.total_pieces);
global.piece_src       = array_create(global.total_pieces);

// Source rectangle (on original sprite) for each piece
var src_w = img_width  / piece_cols;
var src_h = img_height / piece_rows;

// Distinct colors
var colors = [c_red, c_blue, c_green, c_yellow, c_purple, c_orange, c_teal, c_maroon, c_lime, c_navy];

var i = 0;
for (var row = 0; row < piece_rows; row++) {
    for (var col = 0; col < piece_cols; col++) {
        // Target center within the scaled reference image
        var tx = puzzle_area_x + image_offset_x
                 + col * (scaled_width / piece_cols)
                 + (scaled_width / piece_cols) / 2;
        var ty = puzzle_area_y + image_offset_y
                 + row * (scaled_height / piece_rows)
                 + (scaled_height / piece_rows) / 2;
        global.piece_positions[i] = [tx, ty];

        // Source rect from original sprite
        var sx = col * src_w;
        var sy = row * src_h;
        global.piece_src[i] = [sx, sy, src_w, src_h];

        global.piece_colors[i] = colors[i mod array_length(colors)];
        i++;
    }
}

// Create the puzzle piece instances
for (var j = 0; j < global.total_pieces; j++) {
    var px = pieces_area_x + 40 + random(pieces_area_width - 80);
    var py = pieces_area_y + (pieces_area_height / 2) + random(pieces_area_height / 2 - 40);

    var piece = instance_create_depth(px, py, -1000, obj_puzzle_piece);
    if (piece != noone) {
        piece.piece_id  = j;
        piece.correct_x = global.piece_positions[j][0];
        piece.correct_y = global.piece_positions[j][1];
        
        // Set piece size based on actual image segment size
        var rect = global.piece_src[j];
        piece.piece_width = rect[2] * global.puzzle_scale;
        piece.piece_height = rect[3] * global.puzzle_scale;
    }
}

show_debug_message("Puzzle setup complete; pieces in room: " + string(instance_number(obj_puzzle_piece)));