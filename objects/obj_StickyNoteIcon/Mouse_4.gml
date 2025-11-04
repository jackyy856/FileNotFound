// Open, no global checks here to keep it simple
if (!instance_exists(obj_StickyNoteApp)) {
    instance_create_layer(0, 0, "Instances", obj_StickyNoteApp);
} else {
    with (obj_StickyNoteApp) window_focus = true;
}
