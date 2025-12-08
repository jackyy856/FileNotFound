// Draw the gallery window background
draw_set_color(c_white);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, false);

// Draw header
draw_set_color(c_dkgray);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, false);

// Draw title
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(window_x + window_w/2, window_y + header_h/2, "Jigsaw Puzzle - Match the Image");
draw_set_halign(fa_left);

// ==== LEFT SIDE: Puzzle Area (reference image) ====
draw_set_color(c_black);
draw_rectangle(global.puzzle_area_x - 10, global.puzzle_area_y - 10, 
               global.puzzle_area_x + global.puzzle_area_width + 10, 
               global.puzzle_area_y + global.puzzle_area_height + 10, false);

draw_set_color(c_white);
draw_text(global.puzzle_area_x, global.puzzle_area_y - 30, "Reference Image");

// Reference image (darkened)
draw_sprite_ext(global.puzzle_img, 0,
    global.puzzle_area_x + global.puzzle_area_width/2,
    global.puzzle_area_y + global.puzzle_area_height/2,
    global.puzzle_scale, global.puzzle_scale, 
    0, c_white, 0.2);

// ==== RIGHT SIDE: Pieces Area label only (white background) ====
draw_set_color(c_black);
draw_text(global.pieces_area_x, global.pieces_area_y - 30, "Puzzle Pieces");

// Progress + instructions
draw_set_color(c_black);
draw_text(global.puzzle_area_x, global.puzzle_area_y + global.puzzle_area_height + 20, 
          "Pieces placed: " + string(global.pieces_placed) + "/" + string(global.total_pieces));

draw_set_halign(fa_center);
draw_text(window_x + window_w/2, window_y + window_h - 30, "Drag pieces to match the reference image");
draw_set_halign(fa_left);
