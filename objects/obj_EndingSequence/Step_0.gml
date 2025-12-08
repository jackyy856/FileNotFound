/// obj_EndingSequence - Step

timer += 1;

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

if (phase == 0) {
    // Pop-out YOU WIN / YOU LOSE
    if (text_scale < target_scale) {
        text_scale += 0.06;
        if (text_scale > target_scale) text_scale = target_scale;
    } else {
        // tiny breathing effect once fully popped
        text_scale = target_scale + 0.03 * sin(timer * 0.25);
    }

    if (text_alpha < 1) {
        text_alpha += 0.07;
        if (text_alpha > 1) text_alpha = 1;
    }

    // Start file "confetti" once text is basically done
    if (!confetti_started && text_scale >= target_scale - 0.05) {
        confetti_started = true;

        confetti_count = 220;
        confetti       = array_create(confetti_count, undefined);

        var spr_icon = is_win ? spr_FilesIcon : spr_HackedFilesIcon;

        for (var i = 0; i < confetti_count; i++) {
            var p = {
                x   : irandom_range(0, gui_w),
                y   : irandom_range(-gui_h, 0),
                vx  : -0.5 + random(1),
                vy  : 2.0 + random(3.0),
                spr : spr_icon,
                sc  : 0.18 + random(0.10),   // small icon size
                a   : 0.65 + random(0.30)    // slight alpha variation
            };
            confetti[i] = p;
        }
    }

    // Update falling file icons
    if (confetti_started) {
        for (var j = 0; j < confetti_count; j++) {
            var p = confetti[j];

            p.x += p.vx;
            p.y += p.vy;

            // small horizontal wobble
            p.vx += (random(0.08) - 0.04);

            // loop back to top when off-screen
            if (p.y > gui_h + 40) {
                p.y = irandom_range(-gui_h, -40);
                p.x = irandom_range(0, gui_w);
                p.vx = -0.5 + random(1);
                p.vy = 2.0 + random(3.0);
            }

            confetti[j] = p;
        }
    }

    // After a few seconds, go to credits
    if (timer > room_speed * 4) {
        phase = 1;
    }
}
else if (phase == 1) {
    // Scroll credits upwards
    credits_offset -= 1;

    // Once the whole credits block has scrolled off the top, show final THANK YOU
    if (credits_offset < -credits_height - 80) {
        phase = 2;
        final_timer = 0;
    }
}
else if (phase == 2) {
    // Final THANK YOU, then quit
    final_timer += 1;
    if (final_timer > room_speed * 3) {
        game_end(); // exit game after a pause
    }
}
