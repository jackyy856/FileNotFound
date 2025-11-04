// grid of 3 save-slot buttons
panel_w = 900; panel_h = 500;
panel_x = (display_get_gui_width()  - panel_w) * 0.5;
panel_y = (display_get_gui_height() - panel_h) * 0.5;

slot_w = 240; slot_h = 240;
gap = 40;

var start_x = panel_x + (panel_w - (3*slot_w + 2*gap)) * 0.5;
var row_y   = panel_y + 120; // <-- don't shadow built-in y

slots = [
    {x:start_x + 0*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:1, art:false},
    {x:start_x + 1*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:2, art:false},
    {x:start_x + 2*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:3, art:false}
];

back_btn = { x: panel_x + 20, y: panel_y + panel_h - 64, w:120, h:40, label:"< Back" };

function _hit(r, mx, my) { return (mx>=r.x)&&(my>=r.y)&&(mx<r.x+r.w)&&(my<r.y+r.h); }
