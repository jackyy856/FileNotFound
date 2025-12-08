/// obj_ClickFileGame - Create

file_count = 6;
files = array_create(file_count, noone);

// pick index of real file
real_index = irandom_range(0, file_count - 1);

// spawn files
for (var i = 0; i < file_count; i++) {
    var xx = irandom_range(96, room_width - 96);
    var yy = irandom_range(96, room_height - 96);

    // depth-based create, no layer-name drama
    var inst = instance_create_depth(xx, yy, 0, obj_ClickFileMover);
    inst.is_real_file  = (i == real_index);
    inst.index_in_game = i;

    files[i] = inst;
}

// basic state
state  = 0;
result = "";
