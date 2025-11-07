/// --- CLICK-THROUGH CLAIM (End Step) ---
if (__ui_click_inside) {
    // Tell icons / other things under us to ignore this frame’s click.
    global._ui_click_consumed = true;
    __ui_click_inside = false;
}
