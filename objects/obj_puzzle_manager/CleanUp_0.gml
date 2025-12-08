// Clean up surfaces
show_debug_message("Cleaning up puzzle surfaces...");

// Clean up piece surfaces
if (variable_global_exists("piece_surfaces")) {
    for (var i = 0; i < array_length(global.piece_surfaces); i++) {
        if (surface_exists(global.piece_surfaces[i])) {
            surface_free(global.piece_surfaces[i]);
        }
    }
    show_debug_message("Piece surfaces cleaned up");
}

// Clean up blurred surface (NEW NAME)
if (variable_global_exists("blurred_surface") && surface_exists(global.blurred_surface)) {
    surface_free(global.blurred_surface);
    show_debug_message(" Blurred surface cleaned up");
}

// Clean up masks array (if it exists)
if (variable_global_exists("piece_masks")) {
    // No need to free arrays, just clear the reference
    show_debug_message("Piece masks cleaned up");
}

show_debug_message("All puzzle resources cleaned up");