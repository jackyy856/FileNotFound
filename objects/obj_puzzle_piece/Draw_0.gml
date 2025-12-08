// obj_puzzle_piece - Draw Event (SHOW PLACEMENT STATUS)
if (is_placed) {
    // Draw PLACED piece - locked in position
    var rect = global.piece_src[piece_id];
    var draw_w = rect[2] * global.puzzle_scale;
    var draw_h = rect[3] * global.puzzle_scale;
    
    // Draw image segment
    draw_sprite_part_ext(
        global.puzzle_img, 0,
        rect[0], rect[1], rect[2], rect[3],
        x - draw_w/2, y - draw_h/2,
        global.puzzle_scale, global.puzzle_scale,
        c_white, 1
    );
    
    // Checkmark
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(x, y, "✓");
    draw_set_halign(fa_left);
    
} else {
    // Draw UNPLACED piece - draggable
    var rect = global.piece_src[piece_id];
    var draw_w = rect[2] * global.puzzle_scale;
    var draw_h = rect[3] * global.puzzle_scale;
    
    // Draw image segment
    draw_sprite_part_ext(
        global.puzzle_img, 0,
        rect[0], rect[1], rect[2], rect[3],
        x - draw_w/2, y - draw_h/2,
        global.puzzle_scale, global.puzzle_scale,
        c_white, 1
    );

    
    // Store sizes for collision
    piece_width = draw_w;
    piece_height = draw_h;
}