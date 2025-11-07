// one-frame desktop click shield (safe init if the gate isn't placed)
if (!variable_global_exists("_ui_click_consumed")) global._ui_click_consumed = false;
if (global._ui_click_consumed) { global._ui_click_consumed = false; exit; }

// Open Notes
if (!instance_exists(obj_StickyNoteApp)) {
    instance_create_layer(0, 0, "Instances", obj_StickyNoteApp);
} else {
    with (obj_StickyNoteApp) window_focus = true;
}
