/// obj_ClickFileMover - Mouse Left Pressed

// do nothing if a modal is already on screen
if (instance_exists(obj_ClickFileUI)) {
    exit;
}

// only the real file opens the options
if (is_real_file) {
    var ui = instance_create_layer(room_width / 2, room_height / 2, "Instances", obj_ClickFileUI);
    ui.target_inst = id;
    ui.mode        = 0;
    ui.result      = "";
}
