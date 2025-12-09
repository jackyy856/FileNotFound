// Minimal intro email app (no wifi lock, fixed size, top-5 emails only)
// Place this object in intro room; it does not depend on DeskView hitboxes.

// Window geometry (centered, higher on monitor)
window_w = 840;
window_h = 490;
window_x = (display_get_gui_width()  - window_w) * 0.5;
window_y = (display_get_gui_height() - window_h) * 0.5 - 120;

header_h = 32;
row_h    = 56; // more height to avoid overlap with wrapped lines

// Derived rects
function _recalc_email_layout() {
    list_top  = window_y + header_h + 6;
    list_left = window_x + 10;
    list_w    = window_w - 20;
    list_h    = window_h - header_h - 12;
    back_btn  = [window_x + 12, window_y + header_h + 6, 70, 24];
}
_recalc_email_layout();

// Visibility/minimize
app_visible   = false; // start hidden until email icon is clicked
is_minimized  = true;

// State
selected_index = -1; // -1 = inbox view
thread_scroll  = 0;
link_rect      = undefined;
wrong_body_clicks = 0;
function open_app() { app_visible = true; is_minimized = false; }

// Fonts
font_title = font_emailT;
font_body  = font_email;

// Prompt
PROMPT_TIME = room_speed * 2;
prompt_txt   = "";
prompt_timer = 0;
function _prompt(txt) { prompt_txt = txt; prompt_timer = PROMPT_TIME; }

// Inbox (top 5 from announcement downward; announcement unread, others read/locked)
inbox = [
    { id:0,  from:"announcementz@rosenw00d.hr", subject:"You have been selected for a bonus opportunity!",
      body:"Congratulations!\n\n\n\nThanks to your outstanding performance, we have an amazing notice to share.\n\n\n\nPlease click here to redeem your certificate of recognition.\n\n\n\nThank you for your hard work!",
      read:false, show_in_inbox:true },
    { id:20, from:"Rosenwood Corps HR <hr@rosenwood.com>", subject:"Mandatory Review: Code of Conduct Update",
      body:"Hello Vanessa, ...", read:true, show_in_inbox:true },
    { id:30, from:"Thomas Wylde <twylde@rosenwood.com>", subject:"Log review complete",
      body:"I've examined the access logs you asked for.", read:true, show_in_inbox:true },
    { id:60, from:"Elizabeth Newman <enewman@rosenwood.com>", subject:"Corey finish the reconciliations and fix the numbers",
      body:"Hey, I can't finalize the report without your section.", read:true, show_in_inbox:true },
    { id:59, from:"Corey Lewis <clewis@rosenwood.com>", subject:"RE: Corey finish the reconciliations and fix the numbers",
      body:"Hello, forgot about it, should be done now.", read:true, show_in_inbox:true }
];

