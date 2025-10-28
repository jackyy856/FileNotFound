// Force GUI to 1920x1080 for this room so layout is exact.
display_set_gui_size(1920, 1080);

// ----- state machine -----
state = "main";   // "main" | "load" | "settings" | "narr1"

// ---- full-window panel ----
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

menu_x = 0;
menu_y = 0;
menu_w = gui_w;   // stretch to full window
menu_h = gui_h;

// ---- buttons (center column) ----
btn_w  = 520;
btn_h  = 64;
btn_gap = 28;

var col_x = (gui_w - btn_w) * 0.5;          // centered column
var col_y = (gui_h * 0.5) - (btn_h*1.5 + btn_gap); // stack centered vertically

buttons = [
    {x:col_x, y:col_y + 0*(btn_h+btn_gap), w:btn_w, h:btn_h, label:"Load Game", kind:"load"},
    {x:col_x, y:col_y + 1*(btn_h+btn_gap), w:btn_w, h:btn_h, label:"New Game",  kind:"new"},
    {x:col_x, y:col_y + 2*(btn_h+btn_gap), w:btn_w, h:btn_h, label:"Settings",  kind:"settings"}
];

// ---- load screen: 3 centered boxes across ----
slot_w = 320; slot_h = 280; var gap = 56;
var start_x = (gui_w - (3*slot_w + 2*gap)) * 0.5;
var row_y   = (gui_h - slot_h) * 0.5;
slots = [
    {x:start_x + 0*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:1},
    {x:start_x + 1*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:2},
    {x:start_x + 2*(slot_w+gap), y:row_y, w:slot_w, h:slot_h, idx:3}
];
back_btn = { x: 40, y: gui_h - 84, w:160, h:48, label:"< Back" };

// ---- settings slider centered ----
if (!variable_global_exists("master_volume")) global.master_volume = 100;
slider     = { x: (gui_w - 820)*0.5, y: gui_h*0.55, w: 820, h: 10, knob_w: 22, dragging:false };
slider_val = clamp(global.master_volume,0,100);

// ---- narration (typewriter) ----
lines = [];
line_index = 0;
visible_chars = 0;
done_line = false;
type_speed = 1.5;
max_w = 1200;
cx_text = gui_w * 0.5;
cy_text = gui_h * 0.5;

// ---- helpers ----
function _hit(r, mx, my){ return (mx>=r.x)&&(my>=r.y)&&(mx<r.x+r.w)&&(my<r.y+r.h); }
function _advance(){
    if (!done_line){
        visible_chars = string_length(lines[line_index]);
        done_line = true;
    } else {
        line_index++;
        if (line_index >= array_length(lines)) {
            room_goto(Login);  // keep your proper Login room
        } else {
            visible_chars = 0; done_line = false;
        }
    }
}
