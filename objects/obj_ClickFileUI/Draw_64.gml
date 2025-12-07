/// obj_ClickFileUI - Draw GUI

// darken background
draw_set_alpha(0.45);
draw_set_color(c_black);
draw_rectangle(0, 0, 1920, 1080, false);
draw_set_alpha(1);

// panel
var cx = 1920 * 0.5;
var cy = 1080 * 0.5;

var panel_w = 600;
var panel_h = 240;

var px1 = cx - panel_w * 0.5;
var py1 = cy - panel_h * 0.5;
var px2 = cx + panel_w * 0.5;
var py2 = cy + panel_h * 0.5;

draw_set_color(c_white);
draw_rectangle(px1, py1, px2, py2, false);

draw_set_color(c_black);
draw_rectangle(px1, py1, px2, py2, true);

draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(c_black);

// title & message
if (mode == 0) {
    draw_text(cx, py1 + 24, "You clicked the real file!");
    draw_text(cx, py1 + 60, "What do you want to do with it?");
}
else if (mode == 1) {
    draw_text(cx, py1 + 24, "Are you sure?");
    draw_text(cx, py1 + 60, "Deleting will permanently remove this file.");
}
else if (mode == 2) {
    draw_text(cx, py1 + 24, "Share file");
    draw_text(cx, py1 + 60, "Share this file directly to the hacker.");
}
else if (mode == 3) {
    var msg = (result == "deleted") ? "File deleted." : "Shared successfully!";
    draw_text(cx, py1 + 24, msg);
}

// draw buttons
draw_set_valign(fa_middle);

var bw = 220;
var bh = 50;
var btn_y = cy + 40;

if (mode == 0) {
    var del_x1   = cx - bw - 20;
    var del_x2   = del_x1 + bw;
    var share_x1 = cx + 20;
    var share_x2 = share_x1 + bw;

    // Delete button
    draw_set_color(c_ltgray);
    draw_rectangle(del_x1, btn_y, del_x2, btn_y + bh, false);
    draw_set_color(c_black);
    draw_rectangle(del_x1, btn_y, del_x2, btn_y + bh, true);
    draw_text((del_x1 + del_x2) * 0.5, btn_y + bh * 0.5, "Delete");

    // Share button
    draw_set_color(c_ltgray);
    draw_rectangle(share_x1, btn_y, share_x2, btn_y + bh, false);
    draw_set_color(c_black);
    draw_rectangle(share_x1, btn_y, share_x2, btn_y + bh, true);
    draw_text((share_x1 + share_x2) * 0.5, btn_y + bh * 0.5, "Share");
}
else if (mode == 1) {
    var yes_x1 = cx - bw - 20;
    var yes_x2 = yes_x1 + bw;
    var no_x1  = cx + 20;
    var no_x2  = no_x1 + bw;

    // Yes button
    draw_set_color(c_ltgray);
    draw_rectangle(yes_x1, btn_y, yes_x2, btn_y + bh, false);
    draw_set_color(c_black);
    draw_rectangle(yes_x1, btn_y, yes_x2, btn_y + bh, true);
    draw_text((yes_x1 + yes_x2) * 0.5, btn_y + bh * 0.5, "Yes");

    // Cancel button
    draw_set_color(c_ltgray);
    draw_rectangle(no_x1, btn_y, no_x2, btn_y + bh, false);
    draw_set_color(c_black);
    draw_rectangle(no_x1, btn_y, no_x2, btn_y + bh, true);
    draw_text((no_x1 + no_x2) * 0.5, btn_y + bh * 0.5, "Cancel");
}
else if (mode == 2) {
    var share_x1  = cx - bw - 20;
    var share_x2  = share_x1 + bw;
    var cancel_x1 = cx + 20;
    var cancel_x2 = cancel_x1 + bw;

    // Share to Hacker button
    draw_set_color(c_ltgray);
    draw_rectangle(share_x1, btn_y, share_x2, btn_y + bh, false);
    draw_set_color(c_black);
    draw_rectangle(share_x1, btn_y, share_x2, btn_y + bh, true);
    draw_text((share_x1 + share_x2) * 0.5, btn_y + bh * 0.5, "Share to Hacker");

    // Cancel button
    draw_set_color(c_ltgray);
    draw_rectangle(cancel_x1, btn_y, cancel_x2, btn_y + bh, false);
    draw_set_color(c_black);
    draw_rectangle(cancel_x1, btn_y, cancel_x2, btn_y + bh, true);
    draw_text((cancel_x1 + cancel_x2) * 0.5, btn_y + bh * 0.5, "Cancel");
}
else if (mode == 3) {
    var back_y  = cy + 60;
    var back_x1 = cx - bw * 0.5;
    var back_x2 = cx + bw * 0.5;

    draw_set_color(c_ltgray);
    draw_rectangle(back_x1, back_y, back_x2, back_y + bh, false);
    draw_set_color(c_black);
    draw_rectangle(back_x1, back_y, back_x2, back_y + bh, true);
    draw_text((back_x1 + back_x2) * 0.5, back_y + bh * 0.5, "Go back");
}
