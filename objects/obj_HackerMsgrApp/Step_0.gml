var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var x1 = win_x;
var y1 = win_y;
var x2 = win_x + win_w;
var y2 = win_y + win_h;

// Ensure Dove globals exist to avoid undefined reads
if (!variable_global_exists("hacker_dove_hint_pending"))   global.hacker_dove_hint_pending   = false;
if (!variable_global_exists("hacker_dove_hint_fired"))     global.hacker_dove_hint_fired     = false;
if (!variable_global_exists("hacker_dove_unlock_pending")) global.hacker_dove_unlock_pending = false;
if (!variable_global_exists("hacker_dove_follow_pending")) global.hacker_dove_follow_pending = false;
if (!variable_global_exists("hacker_dove_unlock_timer"))   global.hacker_dove_unlock_timer   = -1;
if (!variable_global_exists("hacker_dove_follow_timer"))   global.hacker_dove_follow_timer   = -1;
if (!variable_global_exists("hacker_dove_calendar_pending")) global.hacker_dove_calendar_pending = false;
if (!variable_global_exists("hacker_dove_calendar_fired"))   global.hacker_dove_calendar_fired   = false;

var header_bottom   = y1 + header_h - 20;
var header_vis_h    = header_bottom - y1;         
var footer_top_full = win_y + win_h_full - footer_h; 

// NEW: as long as the window is open (not minimized), consider messages "read"
if (!minimized && visible && !intro_active && !choice_active && !typing)
{
    global.hacker_unread = false;
}


// ----------------
// buttons
// ----------------
var btn_margin = 8;
var btn_size   = max(12, header_vis_h - btn_margin * 2); // keep in header

// Close "x" button 
btn_close_x2 = x2 - btn_margin ;
btn_close_x1 = btn_close_x2 - btn_size;
btn_close_y1 = y1 + btn_margin;
btn_close_y2 = btn_close_y1 + btn_size;

// minimize button
btn_min_x2 = btn_close_x1 - btn_margin;
btn_min_x1 = btn_min_x2 - btn_size;
btn_min_y1 = btn_close_y1;
btn_min_y2 = btn_close_y2;

// ----------------
// mouse press: buttons + drag start
// ----------------
if (mouse_check_button_pressed(mb_left))
{
    // close = hide window but keep instance/state
    if (mx >= btn_close_x1 && mx <= btn_close_x2 &&
        my >= btn_close_y1 && my <= btn_close_y2)
    {
        visible   = false;
        minimized = true;
        // win_h can stay whatever; we'll reset on reopen if needed

        // play exit sound
        audio_play_sound(sfx_meow1, 1, 0.30);
    }
    // minimize
    else if (mx >= btn_min_x1 && mx <= btn_min_x2 &&
             my >= btn_min_y1 && my <= btn_min_y2)
    {
        minimized = !minimized;
        win_h     = minimized ? header_vis_h : win_h_full;
    }
    // drag start in header area
    else if (mx >= x1 && mx <= x2 &&
             my >= y1 && my <= header_bottom)
    {
        dragging = true;
        drag_dx  = mx - win_x;
        drag_dy  = my - win_y;
    }
}


// stop dragging
if (!mouse_check_button(mb_left))
{
    dragging = false;
}

// drag move
if (dragging)
{
    win_x = mx - drag_dx;
    win_y = my - drag_dy;
}

// dropdown choice click (generic)
if (!minimized && choice_active && mouse_check_button_pressed(mb_left))
{
    var opt_margin_side   = 16;
    var opt_margin_bottom = 10;
    var opt_height        = 40;
    var opt_gap           = 4;

    var opt_width = (x2 - x1) - opt_margin_side * 2;
    var opt_x1    = x1 + opt_margin_side;
    var opt_x2    = opt_x1 + opt_width;

    var opt_count = array_length(choice_options);
    if (opt_count > 0)
    {
        var opt_total_h = opt_height * opt_count
                        + opt_gap * max(0, opt_count - 1)
                        + opt_margin_bottom;

        var first_y1 = footer_top_full - opt_total_h;

        var clicked_index = -1;

        for (var i = 0; i < opt_count; i++)
        {
            var opt_y1 = first_y1 + i * (opt_height + opt_gap);
            var opt_y2 = opt_y1 + opt_height;

            if (mx >= opt_x1 && mx <= opt_x2 &&
                my >= opt_y1 && my <= opt_y2)
            {
                clicked_index = i;
                break;
            }
        }

        if (clicked_index != -1)
        {
            var picked_text = choice_options[clicked_index];

            // add player's line
            add_message("You", picked_text, false);
            recalc_scroll_bounds();

            // close the menu
            choice_active  = false;

            // menu-specific behavior
            switch (choice_menu_id)
            {
                // ----------------
                // Menu 1: first 3 options
                // ----------------
                case 1:
                    conversation_phase = 1;

                    intro_messages = [
                        { sender: "UrHacker", text: "b4 u think you can just go and erase it..", is_hacker: true },
                        { sender: "UrHacker", text: "u downloaded a virus that has changed all ur passwords… to things in your computer.", is_hacker: true },
                        { sender: "UrHacker", text: "so if you want ur file…" , is_hacker: true },
						{ sender: "UrHacker", text: "try to decipher them before i get to it and share ur secret with the world x_x =)", is_hacker: true }
                    ];

                    intro_index    = 0;
                    intro_active   = true;
                    typing         = true;
                    intro_timer_ms = 2500;
                    break;

                // ----------------
                // Menu 2: two options with different follow-ups
                // ----------------
                case 2:
                    conversation_phase = 2;

                    if (clicked_index == 0)
                    {
                        // "I’m calling the police."
                        intro_messages = [
                            { sender: "UrHacker", text: "try that and i won’t even give you a chance to find the file lol (>-<)", is_hacker: true },
                            { sender: "UrHacker", text: "whatever u do, don’t look for external help. i'll know and u won’t be able to fix this.", is_hacker: true }
                        ];
                    }
                    else
                    {
                        // "What secret?"
                        intro_messages = [
                            { sender: "UrHacker", text: "u don't know ur own secret? don’t play dumb.", is_hacker: true },
                            { sender: "UrHacker", text: "whatever u do, don’t look for external help. i'll know and u won’t be able to fix this.", is_hacker: true }
                        ];
                    }

                    intro_index    = 0;
                    intro_active   = true;
                    typing         = true;
                    intro_timer_ms = 2500;
                    break;

                // ----------------
                // Menu 3: farewell options, all same outcome
                // ----------------
                case 3:
                    conversation_phase = 3;

                    intro_messages = [
                        { sender: "UrHacker", text: "if u wanna save yourself… figure it out hehe", is_hacker: true },
                        { sender: "UrHacker", text: "good luck! (>w<)", is_hacker: true }
                    ];

                    intro_index    = 0;
                    intro_active   = true;
                    typing         = true;
                    intro_timer_ms = 2500;
                    break;

                // ----------------
                // Menu 4 (wifi branch):
                // option: "It's not the same as before"
                // ----------------
                case 4:
                    conversation_phase = 11;

                    intro_messages = [
                        { sender: "UrHacker", text: "no shit sherlock", is_hacker: true },
                        { sender: "UrHacker", text: "ur past passwords weren't exactly hard to guess...", is_hacker: true }
                    ];

                    intro_index    = 0;
                    intro_active   = true;
                    typing         = true;
                    intro_timer_ms = 3000;
                    break;

                // ----------------
                // Menu 5 (wifi branch):
                // choices: "So?" / "Now what?"
                // ----------------
                case 5:
                    conversation_phase = 12;

                    intro_messages = [
                        { sender: "UrHacker", text: "i took it upon myself to change it and made it more fitting for u in the process :)", is_hacker: true }
                    ];

                    intro_index    = 0;
                    intro_active   = true;
                    typing         = true;
                    intro_timer_ms = 3000;
                    break;

                // ----------------
                // Menu 6 (wifi branch):
                // choices: "Are you kidding me?" / "Just tell me the password."
                // ----------------
                case 6:
                    conversation_phase = 13;

                    intro_messages = [
                        { sender: "UrHacker", text: "lol just relax princess", is_hacker: true },
                        { sender: "UrHacker", text: "u should easily be able to come up with it. since ur so familar with the term.", is_hacker: true },
                        { sender: "UrHacker", text: "so it's kinda on u if you can't figure it out", is_hacker: true }
                    ];

                    intro_index    = 0;
                    intro_active   = true;
                    typing         = true;
                    intro_timer_ms = 3000;
                    break;

                // ----------------
                // Menu 7 (wifi branch):
                // choices: "Where is it?" / "Just tell me already!" / "I don't have time for this."
                // ----------------
                case 7:
                    conversation_phase = 14;

                    intro_messages = [
                        { sender: "UrHacker", text: "fine fine",      is_hacker: true },
                        { sender: "UrHacker", text: "check ur notes", is_hacker: true }
                    ];

                    intro_index    = 0;
                    intro_active   = true;
                    typing         = true;
                    intro_timer_ms = 3000;
                    break;

                // ----------------
                // Menu 8 (post iWork follow-up):
                // single option: "..."
                // ----------------
                case 8:
                    conversation_phase = 50;

                    // unlock Gallery when delivering the final message
                    if (variable_global_exists("apps_unlocked") && is_struct(global.apps_unlocked)) {
                        global.apps_unlocked.Gallery = true;
                    }

                    intro_messages = [
                        { sender: "UrHacker", text: "Go to your pictures and take one last look at what you took from me.", is_hacker: true }
                    ];

                    intro_index    = 0;
                    intro_active   = true;
                    typing         = true;
                    intro_timer_ms = 3000;

                    if (variable_global_exists("hacker_unread")) {
                        global.hacker_unread = true;
                    }
                    break;

                // ----------------
                // Menu 9 (post red key reveal):
                // choices: "...?" / "What are you talking about?" / "Who are you?"
                // ----------------
                case 9:
                    conversation_phase = 31;

                    intro_messages = [
                        { sender: "UrHacker", text: "oh come ON", is_hacker: true },
                        { sender: "UrHacker", text: "u don’t remember whose life u ruined???", is_hacker: true },
                        { sender: "Leonn",    text: "u said i could trust you.", is_hacker: true },
                        { sender: "Leonn",    text: "but u threw me to the trash", is_hacker: true },
                        { sender: "Leonn",    text: "now go to the Recycle Bin and pick up the scraps you left behind.", is_hacker: true }
                    ];

                    intro_index    = 0;
                    intro_active   = true;
                    typing         = true;
                    intro_timer_ms = 3000;

                    if (variable_global_exists("hacker_unread")) {
                        global.hacker_unread = true;
                    }
                    break;
            }
        }
    }
}

// ----------------
// scroll (mouse wheel) – only when not minimized
// -----------------

if (!minimized && max_scroll > 0)
{
    var step_px = 18;

    if (mouse_wheel_up())
    {
        scroll = max(0, scroll - step_px);
    }
    if (mouse_wheel_down())
    {
        scroll = min(max_scroll, scroll + step_px);
    }
}


// ----------------
// intro auto-messages with typing
// ----------------
if (intro_active)
{
    var dt_ms = delta_time / 1000;
    intro_timer_ms -= dt_ms;

    if (intro_timer_ms <= 0)
    {
        if (intro_index < array_length(intro_messages))
        {
            var m = intro_messages[intro_index];

            add_message(m.sender, m.text, m.is_hacker);
            recalc_scroll_bounds();
            has_any_message = true;

            intro_index++;

            if (intro_index < array_length(intro_messages))
            {
                typing         = true;
                intro_timer_ms = 2500; // per-line delay; wifi entry uses 3000 for first line in each batch
            }
            else
            {
                // finished current queue
                typing       = false;
                intro_active = false;

                switch (conversation_phase)
                {
                    case 0:
                        // finished first 3 hacker lines -> show first menu
                        choice_menu_id = 1;
                        choice_options = [ choice1_opt1_text, choice1_opt2_text, choice1_opt3_text ];
                        choice_active  = true;
                        recalc_scroll_bounds();
                        break;

                    case 1:
                        // fini  shed "b4 u think..." block -> show second menu
                        choice_menu_id = 2;
                        choice_options = [ choice2_opt1_text, choice2_opt2_text ];
                        choice_active  = true;
                        recalc_scroll_bounds();
                        break;

                    case 2:
                        // finished post-choice2 replies -> show farewell menu
                        choice_menu_id = 3;
                        choice_options = [ choice3_opt1_text, choice3_opt2_text, choice3_opt3_text ];
                        choice_active  = true;
                        recalc_scroll_bounds();
                        break;

                    case 3:
                        // finished final farewell lines -> mark hacker offline
                        hacker_offline = true;
                        break;

                    // --- WIFI BRANCH PHASES ---

                    // After "stuck?" + "dont tell me..."
                    case 10:
                        choice_menu_id = 4;
                        choice_options = [ "It's not the same as before." ];
                        choice_active  = true;
                        recalc_scroll_bounds();
                        global.hacker_unread = true;
                        break;

                    // After "no shit sherlock" + "ur past passwords..."
                    case 11:
                        choice_menu_id = 5;
                        choice_options = [
                            "So?",
                            "Now what?"
                        ];
                        choice_active  = true;
                        recalc_scroll_bounds();
                        global.hacker_unread = true;
                        break;

                    // After "i took it upon myself..."
                    case 12:
                        choice_menu_id = 6;
                        choice_options = [
                            "Are you kidding me?",
                            "Just tell me the password."
                        ];
                        choice_active  = true;
                        recalc_scroll_bounds();
                        global.hacker_unread = true;
                        break;

                    // After the 3-line rant
                    case 13:
                        choice_menu_id = 7;
                        choice_options = [
                            "Where is it?",
                            "Just tell me already!",
                            "I don't have time for this."
                        ];
                        choice_active  = true;
                        recalc_scroll_bounds();
                        global.hacker_unread = true;
                        break;

                    // After "fine fine" / "check ur notes"
                    case 14:
                        // wifi hint fully delivered; hacker can go offline again if you want
                        hacker_offline = true;
                        // optionally: global.hacker_notes_hint_unlocked = true;
                        break;
					// After key #1 calendar hint lines
                    case 20:
                        // key-1 hint done → hacker goes offline
                        hacker_offline = true;
                        break;

                    // After red key intro lines -> show choice
                    case 30:
                        choice_menu_id = 9;
                        choice_options = [
                            "...?",
                            "What are you talking about?",
                            "Who are you?"
                        ];
                        choice_active  = true;
                        recalc_scroll_bounds();
                        if (variable_global_exists("hacker_unread")) {
                            global.hacker_unread = true;
                        }
                        break;

                    // After Leonn reveal / recycle bin unlock
                    case 31:
                        if (variable_global_exists("apps_unlocked") && is_struct(global.apps_unlocked)) {
                            global.apps_unlocked.RecycleBin = true;
                        }
                        hacker_offline = true;
                        break;

                    // After transcript follow-up
                    case 60:
                        hacker_offline = true;
                        break;

                    // After final key follow-up
                    case 70:
                        hacker_offline = true;
                        break;

                    // After iWork follow-up lines (either path)
                    case 42:
                    case 43:
                        choice_menu_id = 8;
                        choice_options = [ "..." ];
                        choice_active  = true;
                        recalc_scroll_bounds();
                        if (variable_global_exists("hacker_unread")) {
                            global.hacker_unread = true;
                        }
                        break;

                    // After the Gallery unlock line
                    case 50:
                        hacker_offline = true;
                        break;

                }

            }
        }
        else
        {
            // safety: no message left
            typing       = false;
            intro_active = false;

            switch (conversation_phase)
            {
                case 0:
                    choice_menu_id = 1;
                    choice_options = [ choice1_opt1_text, choice1_opt2_text, choice1_opt3_text ];
                    choice_active  = true;
                    recalc_scroll_bounds();
                    break;

                case 1:
                    choice_menu_id = 2;
                    choice_options = [ choice2_opt1_text, choice2_opt2_text ];
                    choice_active  = true;
                    recalc_scroll_bounds();
                    break;

                case 2:
                    choice_menu_id = 3;
                    choice_options = [ choice3_opt1_text, choice3_opt2_text, choice3_opt3_text ];
                    choice_active  = true;
                    recalc_scroll_bounds();
                    break;

                case 3:
                    hacker_offline = true;
                    break;

                // --- WIFI BRANCH PHASES ---
                case 10:
                    choice_menu_id = 4;
                    choice_options = [ "It's not the same as before." ];
                    choice_active  = true;
                    recalc_scroll_bounds();
                    global.hacker_unread = true;
                    break;

                case 11:
                    choice_menu_id = 5;
                    choice_options = [
                        "So?",
                        "Now what?"
                    ];
                    choice_active  = true;
                    recalc_scroll_bounds();
                    global.hacker_unread = true;
                    break;

                case 12:
                    choice_menu_id = 6;
                    choice_options = [
                        "Are you kidding me?",
                        "Just tell me the password."
                    ];
                    choice_active  = true;
                    recalc_scroll_bounds();
                    global.hacker_unread = true;
                    break;

                case 13:
                    choice_menu_id = 7;
                    choice_options = [
                        "Where is it?",
                        "Just tell me already!",
                        "I don't have time for this."
                    ];
                    choice_active  = true;
                    recalc_scroll_bounds();
                    global.hacker_unread = true;
                    break;

                case 14:
                    hacker_offline = true;
                    break;
				// --- KEY #1 HINT  ---
                case 20:
                    hacker_offline = true;
                    break;
            }
        }
    }
}

// --- KEY #1 HINT: after first key is collected in Email ---
// Deliver even if the app window is closed/minimized; unread flag handles UX.
if (global.hacker_key1_hint_pending
    && !global.hacker_key1_hint_fired
    && !intro_active
    && !choice_active
    && !typing)
{
    global.hacker_key1_hint_pending = false;
    global.hacker_key1_hint_fired   = true;
    if (variable_global_exists("hacker_key1_delay")) {
        global.hacker_key1_delay = -1;
    }

    hacker_offline = false;

    // key #1 branch phase
    conversation_phase = 20;

    intro_messages = [
        { sender: "UrHacker", text: "u won't be able to open *that* email quite just yet, i've locked it for now", is_hacker: true },
        { sender: "UrHacker", text: "i unlocked the calendar for you. go look.", is_hacker: true },
        { sender: "UrHacker", text: "the next password u enter will mean something important to you.", is_hacker: true },
        { sender: "UrHacker", text: "format: ####", is_hacker: true }
    ];

    intro_index    = 0;
    intro_active   = true;
    typing         = true;
    intro_timer_ms = 3000; // 3s "is typing..." 

    global.hacker_unread = true;
    // stay offline until opened
    hacker_offline = true;
}

// --- CALENDAR OPENED: DOVE PASSWORD HINT ---
if (global.hacker_dove_calendar_pending
    && !intro_active
    && !choice_active
    && !typing
    && visible
    && !minimized)
{
    global.hacker_dove_calendar_pending = false;
    global.hacker_dove_calendar_fired   = true;

    hacker_offline = false;
    conversation_phase = 25; // calendar hint phase

    intro_messages = [
        { sender: "UrHacker", text: "what? i thought she was sooooooooo special and all of a sudden you forgot her birthday?", is_hacker: true },
        { sender: "UrHacker", text: "the answer is a month and day. quit acting stupid.", is_hacker: true }
    ];

    intro_index    = 0;
    intro_active   = true;
    typing         = true;
    intro_timer_ms = 3000; // 3s "is typing..."

    global.hacker_unread = true;
    hacker_offline = true;
}

// --- KEY #2 HINT: after red key is collected in Gallery ---
if (global.hacker_key2_hint_pending
    && !intro_active
    && !choice_active
    && !typing
    && visible
    && !minimized)
{
    global.hacker_key2_hint_pending = false;

    hacker_offline = false;

    // key #2 branch phase (new)
    conversation_phase = 30;

    intro_messages = [
        { sender: "UrHacker", text: "i thought we made such a great team", is_hacker: true },
        { sender: "UrHacker", text: "the young credulous intern... getting buddy-buddy with the director of a different dept.", is_hacker: true },
        { sender: "UrHacker", text: "i should’ve know it was too good to be true.", is_hacker: true }
    ];

    intro_index    = 0;
    intro_active   = true;
    typing         = true;
    intro_timer_ms = 3000; // 3s "is typing..."

    global.hacker_unread = true;
}

// --- WIFI HINT: after both fake wifi passwords are tried ---
if (global.hacker_wifi_hint_pending
    && !intro_active
    && !choice_active
    && !typing
    && visible
    && !minimized)
{
    global.hacker_wifi_hint_pending = false;

    hacker_offline = false;

    // wifi branch entry
    conversation_phase = 10;

    intro_messages = [
        { sender: "UrHacker", text: "stuck?", is_hacker: true },
        { sender: "UrHacker", text: "dont tell me ur still reusing the same passwords…", is_hacker: true }
    ];

    intro_index    = 0;
    intro_active   = true;
    typing         = true;
    intro_timer_ms = 3000; // 3s "is typing..."

    global.hacker_unread = true;
    hacker_offline = true;
}

// --- DOVE PASSWORD HINT (wrong password) ---
if (global.hacker_dove_hint_pending
    && !intro_active
    && !choice_active
    && !typing
    && visible
    && !minimized)
{
    global.hacker_dove_hint_pending = false;

    hacker_offline = false;
    conversation_phase = 40;
    intro_messages = [
        { sender: "UrHacker", text: "what? i thought she was sooooooooo special and all of a sudden you forgot her birthday?", is_hacker: true },
        { sender: "UrHacker", text: "it's just a month and day. quit acting stupid.", is_hacker: true }
    ];
    intro_index    = 0;
    intro_active   = true;
    typing         = true;
    intro_timer_ms = 3000;
    global.hacker_unread = true;
    hacker_offline = true;
}

// --- DOVE UNLOCK FOLLOW-UP AFTER 15s READ ---
if (global.hacker_dove_unlock_pending
    && !intro_active
    && !choice_active
    && !typing
    && visible
    && !minimized)
{
    global.hacker_dove_unlock_pending = false;

    hacker_offline = false;
    conversation_phase = 41;
    intro_messages = [
        { sender: "UrHacker", text: "doves don’t fly very high", is_hacker: true },
        { sender: "UrHacker", text: "HR ignored her.. and u.. what could you have done..", is_hacker: true },
        { sender: "UrHacker", text: "but u tried everything to make it right, didn't u?", is_hacker: true },
        { sender: "UrHacker", text: "even acting like a good person :)", is_hacker: true },
        { sender: "UrHacker", text: "even disposing of anyone who got in ur way", is_hacker: true },
        { sender: "UrHacker", text: "let's review those records again. don't worry, it's just ur dayjob (o-<)", is_hacker: true },
        { sender: "UrHacker", text: "i opened the iWork app for you.", is_hacker: true }
    ];

    if (variable_global_exists("apps_unlocked") && is_struct(global.apps_unlocked)) {
        global.apps_unlocked.Slack = true;
    }

    intro_index    = 0;
    intro_active   = true;
    typing         = true;
    intro_timer_ms = 3000;
    global.hacker_unread = true;
    hacker_offline = true;
}

// --- DOVE FOLLOW-UP AFTER 30s ---
if (global.hacker_dove_follow_pending
    && !intro_active
    && !choice_active
    && !typing
    && visible
    && !minimized)
{
    global.hacker_dove_follow_pending = false;

    hacker_offline = false;
    conversation_phase = 42;
    intro_messages = [
        { sender: "UrHacker", text: "u really were SO nice to her", is_hacker: true },
        { sender: "UrHacker", text: "checking in on her", is_hacker: true },
        { sender: "UrHacker", text: "comforting her", is_hacker: true },
        { sender: "UrHacker", text: "doing anything to keep her safe", is_hacker: true },
        { sender: "UrHacker", text: "must be NICE", is_hacker: true },
        { sender: "UrHacker", text: "must feel good to be someone’s hero", is_hacker: true },
        { sender: "UrHacker", text: "so why wasn’t I worth that?", is_hacker: true }
    ];

    intro_index    = 0;
    intro_active   = true;
    typing         = true;
    intro_timer_ms = 3000;
    global.hacker_unread = true;
    hacker_offline = true;
}

// --- RECYCLE BIN TRANSCRIPT FOLLOW-UP (20s after open) ---
if (global.hacker_transcript_follow_pending
    && !intro_active
    && !choice_active
    && !typing
    && visible
    && !minimized)
{
    global.hacker_transcript_follow_pending = false;

    hacker_offline = false;
    conversation_phase = 60;
    intro_messages = [
        { sender: "Leonn", text: "ur unbelievable.", is_hacker: true },
        { sender: "Leonn", text: "u ruined me… for her.", is_hacker: true },
        { sender: "Leonn", text: "yet i still hoped u’d apologize on ur own terms.", is_hacker: true },
        { sender: "Leonn", text: "but it's too late to go back now!", is_hacker: true },
        { sender: "Leonn", text: "ur not getting away with this...", is_hacker: true },
        { sender: "Leonn", text: "the proof of ur crime is in ur Files. now i know where to look.", is_hacker: true }
    ];

    if (variable_global_exists("apps_unlocked") && is_struct(global.apps_unlocked)) {
        global.apps_unlocked.Files = true;
    }

    intro_index    = 0;
    intro_active   = true;
    typing         = true;
    intro_timer_ms = 3000;
    global.hacker_unread = true;
    hacker_offline = true;
}

// --- FINAL KEY (KEY #3) FOLLOW-UP AFTER 2s ---
if (global.hacker_key3_hint_pending
    && !intro_active
    && !choice_active
    && !typing
    && visible
    && !minimized)
{
    global.hacker_key3_hint_pending = false;

    hacker_offline = false;
    conversation_phase = 70;
    intro_messages = [
        { sender: "Leonn", text: "i had faith u would make the right choice, miss myers...", is_hacker: true },
        { sender: "Leonn", text: "here's ur last chance to do the right thing.", is_hacker: true },
        { sender: "Leonn", text: "Congrats on collecting all 3 keys, FileNotFound folder is unlocked now!", is_hacker: true },
        { sender: "Leonn", text: "let's get this over with.", is_hacker: true }
    ];

    intro_index    = 0;
    intro_active   = true;
    typing         = true;
    intro_timer_ms = 3000;
    global.hacker_unread = true;
    hacker_offline = true;
}

// --- IWORK FOLLOW-UP (30s after first open) ---
if (global.hacker_iwork_follow_pending
    && !intro_active
    && !choice_active
    && !typing
    && visible
    && !minimized)
{
    global.hacker_iwork_follow_pending = false;

    hacker_offline = false;
    conversation_phase = 43;
    intro_messages = [
        { sender: "UrHacker", text: "u really were SO nice to her", is_hacker: true },
        { sender: "UrHacker", text: "checking in on her", is_hacker: true },
        { sender: "UrHacker", text: "comforting her", is_hacker: true },
        { sender: "UrHacker", text: "doing anything to keep her safe", is_hacker: true },
        { sender: "UrHacker", text: "must be NICE", is_hacker: true },
        { sender: "UrHacker", text: "must feel good to be someone’s hero", is_hacker: true },
        { sender: "UrHacker", text: "so why wasn’t I worth that?", is_hacker: true }
    ];

    intro_index    = 0;
    intro_active   = true;
    typing         = true;
    intro_timer_ms = 3000;
    global.hacker_unread = true;
    hacker_offline = true;
}
