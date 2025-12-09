// Force GUI to 1920x1080 for this room so layout is exact.
display_set_gui_size(1920, 1080);

// ----- state machine -----
state = "main";   // "main" | "load" | "settings" | "narr1" | "narr2"

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

var col_x = (gui_w - btn_w) * 0.5;
var col_y = (gui_h * 0.5) - (btn_h*1.5 + btn_gap);

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

// Advance the active narration; destination depends on which narration state we’re in.
// Now also supports an optional global._queued_narr_return_room override.
function _advance(){
    if (!done_line){
        // Finish current line instantly on first click/press
        visible_chars = string_length(lines[line_index]);
        done_line = true;
    } else {
        // Move to next line or finish narration
        line_index++;
        if (line_index >= array_length(lines)) {

            // ---- NEW: optional custom return room for queued narrations ----
            if (variable_global_exists("_queued_narr_return_room")
                && !is_undefined(global._queued_narr_return_room)) {

                var target_room = global._queued_narr_return_room;
                // clear it so it doesn't leak into later narrations
                global._queued_narr_return_room = undefined;
                room_goto(target_room);

            } else {
                // Original behaviour: fixed destinations by narration state
                if (state == "narr1") {
                    room_goto(room_Desk_View);  // After Narration 1
                } else if (state == "narr2") {
                    room_goto(Login);           // After Narration 2
                }
            }

        } else {
            visible_chars = 0; 
            done_line = false;
        }
    }
}

// ---- queued narration trigger from other rooms ----
// Consume only when the globals actually carry a payload.
if (variable_global_exists("_queued_narr_lines")
&&  variable_global_exists("_queued_narr_state")
&& !is_undefined(global._queued_narr_lines)
&& !is_undefined(global._queued_narr_state)) {
    lines = global._queued_narr_lines;
    line_index = 0; visible_chars = 0; done_line = false;
    state = global._queued_narr_state;    // "narr1" or "narr2" or any other narration tag you use

    // "Remove" by nulling; check with is_undefined later if needed.
    global._queued_narr_lines = undefined;
    global._queued_narr_state = undefined;

    // if some room set _queued_narr_return_room, we leave it for _advance() to consume.
}

toast_txt = "";
toast_timer = 0;

function _has_save_api_ready() {
    return (variable_global_exists("save_api") && is_struct(global.save_api)
        && variable_struct_exists(global.save_api, "save_load") && is_callable(global.save_api.save_load)
        && variable_struct_exists(global.save_api, "slot_meta") && is_callable(global.save_api.slot_meta));
}

function _ensure_save_api_ready() {
    if (_has_save_api_ready()) return true;

    if (!instance_exists(obj_EscapeMenu)) {
        var lyr = layer_exists("Instances") ? "Instances" : layer_get_name(layer_get_id(0));
        var inst = instance_create_layer(menu_x + menu_w * 0.5, menu_y + menu_h * 0.5, lyr, obj_EscapeMenu);
        if (inst != noone) inst.active = false;
    }

    return _has_save_api_ready();
}

function _slot_meta_data(idx) {
    if (_ensure_save_api_ready()) {
        var meta = global.save_api.slot_meta(idx);
        if (is_struct(meta)) return meta;
    }
    return {exists:false, title:"Empty Save Slot"};
}

function _menu_toast(txt) {
    toast_txt = txt;
    toast_timer = room_speed * 2;
}

_ensure_save_api_ready();
