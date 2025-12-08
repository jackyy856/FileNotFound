/// obj_ClickFileMover - Create

// default values (controller will overwrite these after creation)
is_real_file  = false;
index_in_game = -1;

// random speed and direction
var base_speed = 4 + random(2);        // between 4 and 6
var dir        = irandom_range(0, 359);

hspeed = lengthdir_x(base_speed, dir);
vspeed = lengthdir_y(base_speed, dir);

// how long until we randomly steer again
wander_timer = irandom_range(15, 45);

// margin from room edges so they stay fully on screen
edge_margin = 64;
