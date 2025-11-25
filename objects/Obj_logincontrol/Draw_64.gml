// Draw title
draw_set_color(c_white);
draw_set_font(Login_username);

// Draw fixed username
draw_text(900, 510, "Boss");

//if hit hint
draw_set_font(Login_hint)
if (hint_clicked) {
    draw_set_color(c_red);
    draw_text(900, 630, "Hint: City");
} else {
    draw_set_color(c_white);
    draw_text(920, 630, "Hint:");
}

//incorrect message 
draw_set_font(Login_hint)
if (login_message != "") {
	draw_set_color(c_red)
    draw_text(1115, 580, login_message);
}