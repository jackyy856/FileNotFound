// Draw title
draw_set_color(c_white);
draw_set_font(Login_username);

// Draw fixed username
draw_text(780, 520, "Vanessa Myers");

//if hit hint
draw_set_font(Login_hint)
if (hint_clicked) {
    draw_set_color(c_black);
    draw_text(780, 650, "hint: you've been to this city");
} else {
    draw_set_color(c_white);
    draw_text(920, 650, "hint");
}

//incorrect message 
draw_set_font(Login_hint)
if (login_message != "") {
	draw_set_color(c_red)
    draw_text(1115, 600, login_message);
}