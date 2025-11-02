/// obj_BlackNarrationBase: Create
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

lines = [];            // child sets this
line_i = 0;
typed  = "";
char_i = 0;
spd    = 2;           // chars per step
wrap_w = min(1100, gui_w * 0.82);
y_text = gui_h * 0.70;

next_room = noone;     // child sets this
_ready_for_click = false;
