/// obj_ClickFileMover - Step

// stop moving while a UI modal is open
if (instance_exists(obj_ClickFileUI)) {
    exit;
}

// move
x += hspeed;
y += vspeed;

// bounce off room edges
if (x < edge_margin) {
    x = edge_margin;
    hspeed = abs(hspeed);
}
if (x > room_width - edge_margin) {
    x = room_width - edge_margin;
    hspeed = -abs(hspeed);
}
if (y < edge_margin) {
    y = edge_margin;
    vspeed = abs(vspeed);
}
if (y > room_height - edge_margin) {
    y = room_height - edge_margin;
    vspeed = -abs(vspeed);
}

// random wandering
wander_timer--;
if (wander_timer <= 0) {
    var spd = point_distance(0, 0, hspeed, vspeed);
    var dir = point_direction(0, 0, hspeed, vspeed);

    dir += irandom_range(-60, 60);
    spd  = clamp(spd + (random(2) - 1), 2, 7);

    hspeed = lengthdir_x(spd, dir);
    vspeed = lengthdir_y(spd, dir);

    wander_timer = irandom_range(15, 45);
}
