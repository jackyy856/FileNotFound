if (variable_global_exists("_ui_click_consumed") && global._ui_click_consumed) {
    global._ui_click_consumed = false;
    exit;
}

if (!instance_exists(obj_StickyNoteApp)) {
    instance_create_layer(0, 0, "Instances", obj_StickyNoteApp);
} else {
    with (obj_StickyNoteApp) window_focus = true;
}
