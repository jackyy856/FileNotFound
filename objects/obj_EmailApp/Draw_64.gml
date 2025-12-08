draw_set_alpha(1);

// HEADER BAR COLORS
var hdr_bg = make_color_rgb(74, 82, 139);   
var hdr_border = c_black;


// draw header bar (always)
draw_set_color(hdr_bg);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, false);
draw_set_color(hdr_border);
draw_rectangle(window_x, window_y, window_x + window_w, window_y + header_h, true);

// if not minimized, draw full body frame
if (!is_minimized) {
    draw_set_color(c_white);
    draw_rectangle(window_x, window_y + header_h, window_x + window_w, window_y + window_h, false);
    draw_set_color(c_black);
    draw_rectangle(window_x, window_y + header_h, window_x + window_w, window_y + window_h, true);
}

// header text
var title_w = sprite_get_width(spr_mail_title);
var title_h = sprite_get_height(spr_mail_title);

var title_x = window_x + 16;
var title_y = window_y + (header_h - title_h) / 2;

draw_sprite(spr_mail_title, 0, title_x, title_y);

// buttons

var btn_size = 30;
var btn_y = window_y + (header_h - btn_size) / 2;

// Pre-calc button positions
var min_x1   = window_x + window_w - (btn_size * 2) - 8;
var min_x2   = min_x1 + btn_size;

var close_x1 = window_x + window_w - btn_size - 4;
var close_x2 = close_x1 + btn_size;


// ---- minimize button ----
draw_set_color(make_color_rgb(240, 220, 60));
draw_rectangle(min_x1, btn_y, min_x2, btn_y + btn_size, false);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text(min_x1 + btn_size/2, btn_y + btn_size/2, "-");


// ---- close button ----
draw_set_color(c_red);
draw_rectangle(close_x1, btn_y, close_x2, btn_y + btn_size, false);

draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(close_x1 + btn_size/2, btn_y + btn_size/2, "X");


// If minimized: don't draw the body/content; only title bar visible
if (is_minimized) {
    // reset state for others and exit
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_alpha(1);
    exit;
}

// locked wifi state – show simple modal and skip normal content
if (email_locked) {
    // body area
    var x1 = window_x;
    var y1 = window_y + header_h;
    var x2 = window_x + window_w;
    var y2 = window_y + window_h;

    // optional: light dim over body (you already drew white frame)
    draw_set_color(c_white);
    draw_rectangle(x1, y1, x2, y2, false);

    // centered modal box
    var box_w = 360;
    var box_h = 120;
    var cx    = (x1 + x2) * 0.5;
    var cy    = (y1 + y2) * 0.5;

    var bx1 = cx - box_w * 0.5;
    var by1 = cy - box_h * 0.5;
    var bx2 = cx + box_w * 0.5;
    var by2 = cy + box_h * 0.5;

    draw_set_color(c_white);
    draw_roundrect(bx1, by1, bx2, by2, false);

    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(font_body);

    draw_text(cx, cy, email_locked_msg);

    // reset state and exit, so no inbox/puzzle is drawn
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_alpha(1);
    exit;
}

// content
draw_set_font(font_body);
draw_set_color(c_black);


/// ADDED MIGHT CHANGE LATER1!

row_h = 50;

// ─────────────────────────────────────────────
// TOP TAB BAR  
// ─────────────────────────────────────────────

var tab_h = 48;  // height of the bar
var tab_x = window_x;
var tab_y = window_y + header_h; 
var tab_w = window_w;

// background
draw_set_color(make_color_rgb(240, 240, 240));
draw_rectangle(tab_x, tab_y, tab_x + tab_w, tab_y + tab_h, false);

// bottom line (divider)
draw_set_color(c_black);
draw_line(tab_x, tab_y + tab_h, tab_x + tab_w, tab_y + tab_h);

// draw the PNG (spr_mail_principal)
var icon_w = sprite_get_width(spr_mail_principal);
var icon_h = sprite_get_height(spr_mail_principal);

// center it vertically
var icon_x = tab_x + 16;
var icon_y = tab_y + (tab_h - icon_h) * 0.5;

// draw the sprite
draw_sprite(spr_mail_principal, 0, icon_x, icon_y);

// update list_top so emails start *below* the new tab bar
list_top = tab_y + tab_h + 8;



if (selected_index == -1) {


    // ============================
    // 2. DRAW INBOX NORMALLY
    // ============================
    var rowY = list_top;
    var len = array_length(inbox);

    for (var i = 0; i < len; i++) {
        // Only show emails marked for inbox display
        var show_in_inbox = variable_struct_exists(inbox[i], "show_in_inbox") ? inbox[i].show_in_inbox : true;
        if (!show_in_inbox) continue;

        // Tint for read/unread
        if (!inbox[i].read) draw_set_alpha(0.09);
        else                draw_set_alpha(0.04);

        draw_set_color(c_black);
        draw_rectangle(list_left, rowY, list_left + list_w, rowY + row_h, false);
        draw_set_alpha(1);

        // Unread bullet
        if (!inbox[i].read) {
            draw_circle(list_left + 10, rowY + row_h*0.5, 4, false);
        }

        // SUBJECT + FROM NAME
        var subj      = string(inbox[i].subject);
        var from_full = string(inbox[i].from);

        // Extract name
        var lt_pos = string_pos("<", from_full);
        var sender_name = (lt_pos > 0)
            ? string_copy(from_full, 1, lt_pos - 2)
            : from_full;

        // Draw text


        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text(list_left + 24, rowY + 6, sender_name + " — " + subj);

        rowY += row_h;
        if (rowY > list_top + list_h) break;
    }
}

else {
    // back button
    var bcol_back = make_colour_rgb(230,230,230);
    draw_set_color(bcol_back);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], false);
    draw_set_color(c_black);
    draw_rectangle(back_btn[0], back_btn[1], back_btn[0] + back_btn[2], back_btn[1] + back_btn[3], true);
    draw_text(back_btn[0] + 40, back_btn[1] + 10, "< Back");
	
	    // solution
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var em = inbox[selected_index];

    var _em_cor = variable_struct_exists(em, "is_corrupted") && em.is_corrupted;
	

    // == Normal mail / solved ==
	if (!_em_cor || puzzle_solved) {
	    var tx = window_x + 20;
	    // Start below back button and tab bar to prevent overlap
	    var tab_h = 48;
	    var back_btn_bottom = back_btn[1] + back_btn[3];
	    var safe_start_y = max(back_btn_bottom + 15, window_y + header_h + tab_h + 15);
	    var ty = safe_start_y;
		
		var is_thread = variable_struct_exists(em, "thread_id");

		if (!is_thread) {
		    // Subject
		    draw_set_color(c_black);
		    draw_set_font(font_title);
		    draw_text(tx, ty, em.subject);
		    ty += 30;

		    // From
		    draw_set_font(font_body);
		    draw_text(tx, ty, "From: " + em.from);
		    ty += 30;

		    // To - check if field exists (corrupted email might not have it)
		    draw_set_font(font_body);
		    var to_text = variable_struct_exists(em, "to") ? em.to : "";
		    if (to_text != "") {
		        draw_text(tx, ty, "To: " + to_text);
		        ty += 30;
		    } else {
		        ty += 30; // Still advance if no "To" field
		    }
		    ty += 30; // Extra spacing before body
		}


	    // Special layout for recovered corrupted email
	    if (selected_index == corrupted_index && puzzle_solved) {
	        // Line 1 + line 2
	        var line1 = "it sure does.";
	        var line2 = "here's your key, sucker. click it to claim it :P";

	        // First line
	        draw_text(tx, ty, line1);
	        ty += 24; 

	        // Second line
	        draw_text(tx, ty, line2);

	        // Choose key sprite (glow variant if collected)
	        var key_spr = email_key1_collected ? spr_green_glow_key : spr_green_key;

	        var raw_w = sprite_get_width(key_spr);
	        var raw_h = sprite_get_height(key_spr);

	        // scale down big PNGs to a nice height (e.g. 64px)
	        var desired_h = 64;
	        var key_scale = (raw_h > 0) ? (desired_h / raw_h) : 1;

	        var key_w = raw_w * key_scale;
	        var key_h = raw_h * key_scale;

	        // Place key just to the right of the second line
	        var gap   = 20; // space between text and key
	        var key_x = tx + string_width(line2) + gap;
	        var key_y = ty - key_h * 0.6; // slight lift so it sits nicely with text

	        // store rect for Step click detection (scaled)
	        email_key1_rect = [key_x, key_y, key_w, key_h];

	        // subtle glow if not yet collected
	        if (!email_key1_collected) {
	            draw_set_alpha(0.4);
	            draw_set_color(c_white);
	            draw_roundrect(key_x - 6, key_y - 6,
	                           key_x + key_w + 6, key_y + key_h + 6, false);
	            draw_set_alpha(1);
	        }

	        // draw key sprite at scale
	        draw_sprite_ext(key_spr, 0, key_x, key_y, key_scale, key_scale, 0, c_white, 1);
	    }
		else {
		    // normal or threaded emails
		    var body_w = window_w - 40;

		    // Determine thread ID (fallback: use this email’s id)
		    var thread = (variable_struct_exists(em, "thread_id") ? em.thread_id : em.id);

		    // Collect emails in the same thread
		    var chain = [];
		    for (var i = 0; i < array_length(inbox); i++) {
		        if (variable_struct_exists(inbox[i], "thread_id")) {
		            if (inbox[i].thread_id == thread) {
		                array_push(chain, inbox[i]);
		            }
		        }
		    }

		    // If only one email → draw normally with scrollbar support
		    if (array_length(chain) <= 1) {
		        // Use same safe_start_y calculation as thread view
		        var tab_h = 48;
		        var back_btn_bottom = back_btn[1] + back_btn[3];
		        var safe_top = max(back_btn_bottom + 15, window_y + header_h + tab_h + 15);
		        ty = safe_top; // Ensure we start below back button
		        
		        var email_header_h = 30 + 30; // subject + from
		        var has_to = variable_struct_exists(em, "to") && em.to != "";
		        if (has_to) email_header_h += 30; // to
		        email_header_h += 60; // spacing
		        
		        var content_area_h = window_y + window_h - 40 - ty;
		        
		        // Calculate body height with full width first
		        var full_body_w = window_w - 40;
		        var body_h = string_height_ext(em.body, 12, full_body_w);
		        var total_content_h = email_header_h + body_h;
		        var needs_scroll = total_content_h > content_area_h;
		        
		        // Adjust body width if scrollbar is needed
		        if (needs_scroll) {
		            var scroll_w = 12;
		            var scroll_x = window_x + window_w - scroll_w - 8;
		            body_w = scroll_x - tx - 20; // Adjust body width for scrollbar
		            // Recalculate body height with adjusted width
		            body_h = string_height_ext(em.body, 12, body_w);
		            total_content_h = email_header_h + body_h;
		        } else {
		            body_w = full_body_w;
		        }
		        
		        if (needs_scroll) {
		            // Handle scrollbar for single email
		            var max_scroll = max(0, total_content_h - content_area_h);
		            thread_scroll = clamp(thread_scroll, 0, max_scroll);
		            
		            var scroll_track_y = ty;
		            var scroll_track_h = content_area_h;
		            
		            // Draw scrollbar track
		            draw_set_color(make_color_rgb(240, 240, 240));
		            draw_rectangle(scroll_x, scroll_track_y, scroll_x + scroll_w, scroll_track_y + scroll_track_h, false);
		            
		            // Draw scrollbar thumb
		            var thumb_h = max(20, (content_area_h / total_content_h) * scroll_track_h);
		            var thumb_y = scroll_track_y + (thread_scroll / max_scroll) * (scroll_track_h - thumb_h);
		            draw_set_color(make_color_rgb(180, 180, 180));
		            draw_rectangle(scroll_x + 2, thumb_y, scroll_x + scroll_w - 2, thumb_y + thumb_h, false);
		            draw_set_color(c_black);
		            draw_rectangle(scroll_x + 2, thumb_y, scroll_x + scroll_w - 2, thumb_y + thumb_h, true);
		        }
		        
		        // Draw all content with scroll offset, but clip to visible area
		        var draw_y = ty - thread_scroll;
		        var content_bottom = window_y + window_h - 40;
		        
		        // Subject - only draw if visible
		        if (draw_y >= ty && draw_y <= content_bottom) {
		            draw_set_color(c_black);
		            draw_set_font(font_title);
		            draw_text(tx, draw_y, em.subject);
		        }
		        draw_y += 30;
		        
		        // From - only draw if visible
		        if (draw_y >= ty && draw_y <= content_bottom) {
		            draw_set_font(font_body);
		            draw_text(tx, draw_y, "From: " + em.from);
		        }
		        draw_y += 30;
		        
		        // To - only draw if visible
		        var has_to = variable_struct_exists(em, "to") && em.to != "";
		        if (has_to) {
		            if (draw_y >= ty && draw_y <= content_bottom) {
		                draw_text(tx, draw_y, "To: " + em.to);
		            }
		            draw_y += 30;
		        }
		        
		        draw_y += 30; // Extra spacing
		        
		        // Body - only draw if any part is visible
		        var body_h = string_height_ext(em.body, 12, body_w);
		        if (draw_y < content_bottom && draw_y + body_h > ty) {
		            draw_text_ext(tx, draw_y, em.body, 12, body_w);
		        }
		        return;
		    }

		    // Sort chain oldest → newest by id
		    array_sort(chain, function(a, b) { return a.id - b.id; });

		    // Calculate total height for scrollbar
		    var total_h = 0;
		    for (var m = 0; m < array_length(chain); m++) {
		        total_h += 26 + 26 + 26 + 34; // subject + from + to + sent spacing
		        total_h += string_height_ext(chain[m].body, 12, body_w) + 22;
		        if (m < array_length(chain) - 1) total_h += 24; // divider spacing
		    }
		    
		    // Define visible content area (clipping region)
		    // Make sure content starts below tab bar and back button
		    var tab_h = 48;
		    var back_btn_bottom = back_btn[1] + back_btn[3];
		    // Content top must be below back button and tab bar
		    var safe_top = max(back_btn_bottom + 15, window_y + header_h + tab_h + 15);
		    var content_top = safe_top; // Always use safe_top to prevent overlap
		    var content_bottom = window_y + window_h - 40;
		    var visible_h = content_bottom - content_top;
		    
		    // Update ty to match content_top for consistency
		    ty = content_top;
		    
		    // Recalculate body_w accounting for scrollbar if needed
		    var tentative_total_h = 0;
		    for (var m_test = 0; m_test < array_length(chain); m_test++) {
		        tentative_total_h += 26 + 26 + 26 + 34;
		        tentative_total_h += string_height_ext(chain[m_test].body, 12, body_w) + 22;
		        if (m_test < array_length(chain) - 1) tentative_total_h += 24;
		    }
		    
		    if (tentative_total_h > visible_h) {
		        // Need scrollbar - adjust body_w
		        var scroll_w = 12;
		        var scroll_x = window_x + window_w - scroll_w - 8;
		        body_w = scroll_x - tx - 20;
		    }
		    
		    var scroll_max = max(0, total_h - visible_h);
		    thread_scroll = clamp(thread_scroll, 0, scroll_max);
		    
		    // Apply scroll offset
		    var block_y = ty - thread_scroll;
		    
		    // Draw scrollbar if needed
		    if (scroll_max > 0) {
		        var scroll_w = 12;
		        var scroll_x = window_x + window_w - scroll_w - 8;
		        var scroll_track_y = content_top;
		        var scroll_track_h = visible_h;
		        
		        // Track background
		        draw_set_color(make_color_rgb(240, 240, 240));
		        draw_rectangle(scroll_x, scroll_track_y, scroll_x + scroll_w, scroll_track_y + scroll_track_h, false);
		        
		        // Thumb
		        var thumb_h = max(20, (visible_h / total_h) * scroll_track_h);
		        var thumb_y = scroll_track_y + (thread_scroll / scroll_max) * (scroll_track_h - thumb_h);
		        
		        draw_set_color(make_color_rgb(180, 180, 180));
		        draw_rectangle(scroll_x + 2, thumb_y, scroll_x + scroll_w - 2, thumb_y + thumb_h, false);
		        draw_set_color(c_black);
		        draw_rectangle(scroll_x + 2, thumb_y, scroll_x + scroll_w - 2, thumb_y + thumb_h, true);
		        
		        // Adjust body width to account for scrollbar
		        body_w = scroll_x - tx - 20;
		    }
		    
		    // Draw with proper clipping - only draw elements within visible bounds
		    for (var m = 0; m < array_length(chain); m++) {
		        var msg = chain[m];
		        
		        var email_start_y = block_y;
		        var email_end_y = block_y + 26 + 26 + 26 + 34 + string_height_ext(msg.body, 12, body_w) + 22;
		        
		        // Skip if entirely above visible area
		        if (email_end_y < content_top) {
		            block_y = email_end_y;
		            if (m < array_length(chain) - 1) block_y += 24; // divider spacing
		            continue;
		        }
		        
		        // Stop drawing if entirely below visible area
		        if (email_start_y > content_bottom) break;
				
		        draw_set_font(font_title);
				draw_set_color(c_black);
				
				// Only draw if within visible bounds (strict - must be >= content_top)
				if (block_y >= content_top && block_y <= content_bottom) {
				    draw_text(tx, block_y, msg.subject);
				}
		        block_y += 26;
				
				draw_set_font(font_body);
				
		        // Only draw if fully within visible area
		        if (block_y >= content_top && block_y <= content_bottom) {
		            draw_text(tx, block_y, "From: " + msg.from);
		        }
		        block_y += 26;

		        if (block_y >= content_top && block_y <= content_bottom) {
		            draw_text(tx, block_y, "To: " + msg.to);
		        }
		        block_y += 26;

		        if (block_y >= content_top && block_y <= content_bottom) {
		            draw_text(tx, block_y, "Sent: (time redacted)");
		        }
		        block_y += 34;

		        // Draw body only if any part is visible AND starts below content_top
		        // Use draw_text_ext to properly wrap long lines and prevent word overlap
		        var body_h = string_height_ext(msg.body, 12, body_w);
		        if (block_y >= content_top && block_y < content_bottom && block_y + body_h > content_top) {
		            // Draw text with proper wrapping to prevent word overlap
		            draw_text_ext(tx, block_y, msg.body, 12, body_w);
		        }
		        block_y += body_h + 22;

		        // Divider with better spacing
		        if (m < array_length(chain) - 1) {
		            if (block_y >= content_top - 5 && block_y <= content_bottom + 5) {
		                draw_set_color(make_color_rgb(160,160,160));
		                draw_line(tx, block_y, tx + body_w, block_y);
		            }
		            block_y += 24; // Increased spacing between emails
		        }
		    }
		}
	}
	
    // == Corrupted view with riddle, binary rain, and puzzle ==
    else {
        var neon = make_colour_rgb(0, 200, 0);
        
        // Draw back button in header (more to the left to avoid minimize button)
        var puzzle_back_btn_x = window_x + window_w - (30 * 4) - 20; // More to the left
        var puzzle_back_btn_y = window_y + (header_h - 26) / 2;
        var puzzle_back_btn_w = 70;
        var puzzle_back_btn_h = 26;
        
        var back_col_puzzle = make_colour_rgb(230,230,230);
        draw_set_color(back_col_puzzle);
        draw_rectangle(puzzle_back_btn_x, puzzle_back_btn_y, 
                       puzzle_back_btn_x + puzzle_back_btn_w, 
                       puzzle_back_btn_y + puzzle_back_btn_h, false);
        draw_set_color(c_black);
        draw_rectangle(puzzle_back_btn_x, puzzle_back_btn_y, 
                       puzzle_back_btn_x + puzzle_back_btn_w, 
                       puzzle_back_btn_y + puzzle_back_btn_h, true);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_black);
        draw_text(puzzle_back_btn_x + puzzle_back_btn_w / 2, 
                  puzzle_back_btn_y + puzzle_back_btn_h / 2, "< Back");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        // Binary rain background area (ABS using local struct)
        var rx = window_x + bin_area_local.x;
        var ry = window_y + bin_area_local.y;
        var rw = bin_area_local.w;
        var rh = bin_area_local.h;

        // base
        draw_set_color(make_colour_rgb(16, 24, 16));
        draw_rectangle(rx, ry, rx + rw, ry + rh, false);

        // Puzzle area bounds (to exclude from binary rain)
        var pax = window_x + puzzle_area_local.x;
        var pay = window_y + puzzle_area_local.y;
        var paw = puzzle_area_local.w;
        var pah = puzzle_area_local.h;

        // rows of digits (no overshoot, smaller font like old version)
        var cell       = 14; // Fixed cell size for smaller digits
        var scroll_mod = bin_scroll % cell;
        var first_row  = ry + ((cell - scroll_mod) % cell);
        if (first_row == ry + cell) first_row = ry;

        for (var gy = first_row; gy <= ry + rh - cell; gy += cell) {
            var row = floor((gy - ry) / cell);
            for (var gx = rx; gx <= rx + rw - cell; gx += cell) {
                // Skip if inside puzzle black box area
                if (gx >= pax && gx < pax + paw && gy >= pay && gy < pay + pah) {
                    continue;
                }
                
                var col = floor((gx - rx) / cell);
                var h = (col * 73856093) ^ (row * 19349663);
                var bit = h & 1;
                var ch  = bit ? "1" : "0";
                // Use exact same color as word box borders (neon: 0, 200, 0)
                draw_set_color(neon); // Same as puzzle word box border color
                // Use default font (-1) with smaller size transformation (like old version)
                draw_set_font(-1);
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
                // Draw smaller text using draw_text_transformed with smaller scale
                draw_text_transformed(gx + 1, gy, ch, 0.6, 0.6, 0);
            }
        }

        // Email Corrupted title in white area above hacker box
		var neon    = make_colour_rgb(0, 200, 0);
		draw_set_font(font_title);
		draw_set_color(neon);

		var title_x = window_x + 100;
		var title_y = window_y + 30;
		draw_text(title_x, title_y, "Email Corrupted");

		// Riddle text, plain black, in the white box
		var riddle_text = "Riddle: What an awful job!";
		var riddle_x    = title_x + 600;
		var riddle_y    = title_y - 5;

		draw_set_font(font_body); // or font_riddle if you prefer that one
		draw_set_color(c_black);
		draw_text(riddle_x, riddle_y, riddle_text);


        // Hint dialog box (on top of binary rain, so readable)
        if (puzzle_show_hint) {
            var hw = 420;
            var hh = 80;
            var hx = rx + (rw - hw) * 0.5;
            var hy = ry + 20;

            draw_set_color(make_colour_rgb(240,240,240));
            draw_rectangle(hx, hy, hx + hw, hy + hh, false);
            draw_set_color(c_black);
            draw_rectangle(hx, hy, hx + hw, hy + hh, true);

            var hint_tx = hx + 12;
            var hint_ty = hy + 14;

            draw_set_font(font_body);
            draw_set_color(c_black);
            draw_text(hint_tx, hint_ty, "Hint: Those emails look messy....");
            draw_text(hint_tx, hint_ty + 20, "What do you really think about that place?");
        }

        // Puzzle area (ABS) - already calculated above for binary rain exclusion

        draw_set_color(c_black);
        draw_rectangle(pax, pay, pax + paw, pay + pah, false);
        draw_set_color(neon);
        draw_rectangle(pax, pay, pax + paw, pay + pah, true);

        // Instruction
        var itext = "Arrange the words (left > right).";
        draw_set_font(font_body);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_black);
        draw_text(pax-1, pay-26, itext);
        draw_text(pax+1, pay-26, itext);
        draw_text(pax,   pay-27, itext);
        draw_text(pax,   pay-25, itext);
        draw_set_color(c_white);
        draw_text(pax, pay-26, itext);

        // === WORD TILES (ABS from LOCAL, old style: black bg, green outline) ===
        for (var i2 = 0; i2 < array_length(word_btns); i2++) {
            var b2 = word_btns[i2];
            var ax = window_x + b2.x;
            var ay = window_y + b2.y;

            var w2 = b2.w;
            var h2 = b2.h;

            // fill
            draw_set_color(c_black);
            draw_rectangle(ax, ay, ax + w2, ay + h2, false);

            // outline
            draw_set_color(neon);
            draw_rectangle(ax, ay, ax + w2, ay + h2, true);

            // text
            draw_set_font(font_body);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(neon);
            draw_text(ax + w2 * 0.5, ay + h2 * 0.5, b2.text);
        }

        // (Optional modal if you ever re-enable it; harmless now)
        if (puzzle_solved) {
            var mw = 420, mh = 160;
            var mx2 = window_x + (window_w - mw) * 0.5;
            var my2 = window_y + (window_h - mh) * 0.5;

            draw_set_color(make_colour_rgb(250,250,250));
            draw_rectangle(mx2, my2, mx2+mw, my2+mh, false);
            draw_set_color(c_black);
            draw_rectangle(mx2, my2, mx2+mw, my2+mh, true);

            draw_set_font(font_title);
            draw_text(mx2 + 16, my2 + 16, "Email Recovered");

            draw_set_font(font_body);
            draw_text_ext(mx2 + 16, my2 + 52, puzzle_message, 12, mw - 32);

            ok_btn_local[0] = (mx2 + mw - 16 - ok_btn_local[2]) - window_x;
            ok_btn_local[1] = (my2 + mh - 16 - ok_btn_local[3]) - window_y;

            var bcol2 = make_colour_rgb(230,230,230);
            var obx = mx2 + mw - 16 - ok_btn_local[2];
            var oby = my2 + mh - 16 - ok_btn_local[3];
            draw_set_color(bcol2);
            draw_rectangle(obx, oby, obx+ok_btn_local[2], oby+ok_btn_local[3], false);
            draw_set_color(c_black);
            draw_rectangle(obx, oby, obx+ok_btn_local[2], oby+ok_btn_local[3], true);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(obx+ok_btn_local[2]*0.5, oby+ok_btn_local[3]*0.5, "Ok");
        }
    }
}

// ---- RESET DRAW STATE so other apps (taskbar clock, notes) aren't affected ----
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
