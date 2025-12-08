// obj_puzzle_piece - Step Event (FIXED PLACEMENT)
if (is_placed) {
    // If placed, STAY in correct position and ignore all other logic
    x = correct_x;
    y = correct_y;
    exit; // Important: exit immediately so no other code runs
}

// Check for click - only if not placed and not already dragging
if (mouse_check_button_pressed(mb_left) && !is_dragging) {
    // Check if mouse is over THIS piece
    if (point_distance(mouse_x, mouse_y, x, y) < piece_width/2) {
        // Make sure no other piece is being dragged
        var other_dragging = false;
        with (obj_puzzle_piece) {
            if (id != other.id && is_dragging) {
                other_dragging = true;
                break;
            }
        }
        
        if (!other_dragging) {
            is_dragging = true;
        }
    }
}

// Dragging logic
if (is_dragging) {
    x = mouse_x;
    y = mouse_y;
    
    // Check for mouse release
    if (mouse_check_button_released(mb_left)) {
        is_dragging = false;
        
        // Check if close enough to correct position
        var dist = point_distance(x, y, correct_x, correct_y);
        if (dist < 60) { // Snap distance
            // SNAP to correct position and MARK AS PLACED
            x = correct_x;
            y = correct_y;
            is_placed = true; // This is the key line!
            global.pieces_placed++;
            show_debug_message("🎯 Piece " + string(piece_id) + " LOCKED in position!");
        } else {
            // Return to pile
            var new_x = global.pieces_area_x + 60 + random(global.pieces_area_width - 120);
            var new_y = global.pieces_area_y + 100 + random(global.pieces_area_height - 200);
            x = new_x;
            y = new_y;
            show_debug_message("↩️ Piece " + string(piece_id) + " returned to pile");
        }
    }
}