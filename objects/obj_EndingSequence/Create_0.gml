/// obj_EndingSequence - Create

// Only run if mini-game set a result
if (!variable_global_exists("file_minigame_result") || global.file_minigame_result == "") {
    instance_destroy();
    exit;
}

is_win = (global.file_minigame_result == "deleted");
global.file_minigame_result = ""; // consume it so it won't re-trigger

phase = 0;          // 0 = WIN/LOSE + FX, 1 = credits scroll, 2 = final THANK YOU
timer = 0;

// BIG pop-out text
text_scale   = 0.1;
text_alpha   = 0;
target_scale = 2.6;   // large final size

// FX shared storage
confetti_started = false;
confetti         = [];
confetti_count   = 0;

// Extra win-only FX (ring + rays)
ring_phase = 0;
ring_scale = 1.0;
ring_alpha = 0.0;
rays_angle = 0;

// Credits data
credits         = [];
credits_len     = 0;
credits_height  = 0;   // total vertical height of all credit lines (for scroll end)
credits_offset  = display_get_gui_height() + 80;

// Build credits list (WITHOUT final "thank you" line)
credits[credits_len++] = { text : "FileNotFound", style : "title" };

credits[credits_len++] = { text : "", style : "spacer" };
credits[credits_len++] = { text : "Production Manager", style : "role" };
credits[credits_len++] = { text : "Clay Mendiola Maldonado", style : "name" };

credits[credits_len++] = { text : "", style : "spacer" };
credits[credits_len++] = { text : "Programmers", style : "role" };
credits[credits_len++] = { text : "Jacky Leon Sanchez - Programmer Team Lead", style : "name" };
credits[credits_len++] = { text : "Shivraj Pradumansinh Jadeja - Git Wizard", style : "name" };
credits[credits_len++] = { text : "Aryan Raval", style : "name" };
credits[credits_len++] = { text : "Sherry Li", style : "name" };

credits[credits_len++] = { text : "", style : "spacer" };
credits[credits_len++] = { text : "Artists", style : "role" };
credits[credits_len++] = { text : "Kallen Vo - Artists Team Lead", style : "name" };
credits[credits_len++] = { text : "Gabriella Hernandez", style : "name" };
credits[credits_len++] = { text : "Sam Melcher", style : "name" };
credits[credits_len++] = { text : "Angel Marques De Mesquita", style : "name" };

credits[credits_len++] = { text : "", style : "spacer" };
credits[credits_len++] = { text : "Script Writers", style : "role" };
credits[credits_len++] = { text : "Clay Mendiola Maldonado", style : "name" };
credits[credits_len++] = { text : "Jacky Leon Sanchez", style : "name" };
credits[credits_len++] = { text : "Shivraj Pradumansinh Jadeja", style : "name" };
credits[credits_len++] = { text : "Aryan Raval", style : "name" };
credits[credits_len++] = { text : "Kallen Vo", style : "name" };
credits[credits_len++] = { text : "Gabriella Hernandez", style : "name" };

// Precompute total height of credits (for when to stop scrolling)
for (var i = 0; i < credits_len; i++) {
    var line  = credits[i];
    var style = line.style;
    var scale = 1.0;

    if (style == "title")      scale = 2.4;
    else if (style == "role")  scale = 1.7;
    else if (style == "name")  scale = 1.4;
    else if (style == "spacer") {
        credits_height += 28;
        continue;
    }

    credits_height += 40 * scale;
}

// Final THANK YOU timing
final_timer = 0;
