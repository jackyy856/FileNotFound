/// obj_puzzle_controller – Step
// When all pieces are placed, notify the Gallery app once
if (global.pieces_placed >= global.total_pieces) {
    if (instance_exists(obj_GalleryApp)) {
        with (obj_GalleryApp) {
            if (!puzzle_mode) exit;
            if (!puzzle_completed) {
                complete_puzzle();
            }
        }
    }
}

// Better debug - show piece positions
if (mouse_check_button_pressed(mb_left)) {
    var pieces = instance_number(obj_puzzle_piece);
    show_debug_message("--- MOUSE CLICK at " + string(mouse_x) + "," + string(mouse_y) + " ---");
    show_debug_message("Total pieces in room: " + string(pieces));
    
    // Check each piece's position
    for (var i = 0; i < pieces; i++) {
        var piece = instance_find(obj_puzzle_piece, i);
        if (piece != noone) {
            var dist = point_distance(mouse_x, mouse_y, piece.x, piece.y);
            show_debug_message("Piece " + string(piece.piece_id) + " at " + string(piece.x) + "," + string(piece.y) + " - Distance: " + string(dist));
        }
    }
}