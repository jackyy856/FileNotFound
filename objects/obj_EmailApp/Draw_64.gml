draw_set_alpha(1);
draw_set_color(c_white);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, false);
draw_set_color(c_black);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + window_h, true);

//header
draw_set_font(font_title);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(window_x + 16, window_y + 12, "Mail");

//close button
draw_set_color(c_black);
draw_rectangle(close_btn[0], close_btn[1], close_btn[0] + close_btn[2], close_btn[1] + close_btn[3], true);
draw_set_color(c_white);
draw_text(close_btn[0] + 7, close_btn[1] + 2, "X");

//content
draw_set_font(font_body);
draw_set_color(c_black);

if (selected_index == -1) 
{
    var rowY = list_top;
    var len = array_length(inbox);
    for (var i = 0; i < len; i++) 
	{
        draw_set_alpha(0.08);
        draw_set_color(c_black);
        draw_rectangle(list_left, rowY, list_left + list_w, rowY + row_h, false);
        draw_set_alpha(1);

        if (!inbox[i].read) 
		{
            draw_circle(list_left + 10, rowY + row_h * 0.5, 4, false);
        }

        var subj = string(inbox[i].subject);
        var from = string(inbox[i].from);
        draw_text(list_left + 24, rowY + 6, from + " — " + subj);

        rowY += row_h;
        if (rowY > list_top + list_h) break;
    }
} 
else 
{
    draw_set_color(c_black);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], true);
    draw_set_color(c_white);
    draw_text(back_btn[0] + 10, back_btn[1] + 3, "< Back");

    var em = inbox[selected_index];
    var tx = window_x + 20;
    var ty = window_y + header_h + 12;

    draw_set_color(c_black);
    draw_set_font(font_title);
    draw_text(tx, ty, em.subject);
    ty += 28;

    draw_set_font(font_body);
    draw_text(tx, ty, "From: " + em.from);
    ty += 22;

    var body_w = window_w - 40;
    draw_text_ext(tx, ty, em.body, 12, body_w);
}