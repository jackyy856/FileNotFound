// Force GUI to 1920x1080 for this room so layout is exact.
display_set_gui_size(1920, 1080);

// Debug initialization
show_debug_message("=========================================");
show_debug_message("MENU CONTROLLER CREATE EVENT");
show_debug_message("Room: " + room_get_name(room));

// ----- state machine -----
state = "main";   
exit_state = "none"; 
pre_exit_state = "main"; 

// ---- full-window panel ----
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

menu_x = 0;
menu_y = 0;
menu_w = gui_w;   
menu_h = gui_h;

//exit 
taskbar_y = 1000;
system_btn_size = 25;

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
// FIXED: Changed from gui_h - 1000 to gui_h - 100
back_btn = { x: 40, y: gui_h - 100, w:160, h:55, label:"< Back" };

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

// ---- exit dialog variables ----
save_message_timer = 0;
selected_save_slot = -1;

// ---- helpers ----
function _hit(r, mx, my){ return (mx>=r.x)&&(my>=r.y)&&(mx<r.x+r.w)&&(my<r.y+r.h); }

// Save game function for puzzle/mystery game
function _save_game_to_slot(slot_idx)
{
    // Create save data
    var save_data = ds_map_create();
    
    // Save metadata
    save_data[? "save_slot"] = slot_idx;
    save_data[? "save_date"] = date_current_datetime();
    save_data[? "game_version"] = "1.0";
    
    // Save current room/state
    if (variable_global_exists("current_room"))
    {
        save_data[? "current_room"] = global.current_room;
    }
    else
    {
        save_data[? "current_room"] = "room_Menu"; 
    }
    
    // Save game flags if they exist
    if (variable_global_exists("game_flags"))
    {
        // Create a copy to avoid reference issues
        var flags_copy = ds_map_create();
        var keys = ds_map_find_all(global.game_flags, -1);
        for (var i = 0; i < array_length(keys); i++)
        {
            flags_copy[? keys[i]] = global.game_flags[? keys[i]];
        }
        save_data[? "game_flags"] = json_encode(flags_copy);
        ds_map_destroy(flags_copy);
    }
    else
    {
        save_data[? "game_flags"] = "{}"; 
    }
    
    // Convert to JSON and save
    var json_string = json_encode(save_data);
    var filename = "save" + string(slot_idx) + ".sav";
    
    // Delete old save if exists
    if (file_exists(filename))
    {
        file_delete(filename);
    }
    
    // Write new save
    var file = file_text_open_write(filename);
    if (file != -1)
    {
        file_text_write_string(file, json_string);
        file_text_close(file);
        
        // Update global save slot
        global.last_save_slot = slot_idx;
        
        // Show debug message
        show_debug_message("Game saved to slot " + string(slot_idx));
        
        ds_map_destroy(save_data);
        return true;
    }
    else
    {
        show_debug_message("Error: Could not create save file");
        ds_map_destroy(save_data);
        return false;
    }
}

// Check if save slot exists
function _save_exists(slot_idx)
{
    var filename = "save" + string(slot_idx) + ".sav";
    if (!file_exists(filename)) return false;
    
    // Quick validation
    var file = file_text_open_read(filename);
    if (file == -1) return false;
    
    var content = file_text_read_string(file);
    file_text_close(file);
    
    return (string_length(content) > 10); // Basic check
}

// Get save date from slot
function _get_save_date(slot_idx)
{
    if (!_save_exists(slot_idx)) return "Empty";
    
    var filename = "save" + string(slot_idx) + ".sav";
    var file = file_text_open_read(filename);
    if (file == -1) return "Empty";
    
    var json_string = file_text_read_string(file);
    file_text_close(file);
    
    try
    {
        var save_data = json_decode(json_string);
        var date_str = save_data[? "save_date"];
        ds_map_destroy(save_data);
        
        if (is_string(date_str))
        {
            // Format: show only date part (first 10 chars: YYYY-MM-DD)
            return string_copy(date_str, 1, 10);
        }
        return "Unknown";
    }
    catch (e)
    {
        return "Corrupted";
    }
}

// Get save info for display
function _get_save_info(slot_idx)
{
    if (!_save_exists(slot_idx)) return "Empty Slot";
    
    var filename = "save" + string(slot_idx) + ".sav";
    var file = file_text_open_read(filename);
    if (file == -1) return "Error";
    
    var json_string = file_text_read_string(file);
    file_text_close(file);
    
    try
    {
        var save_data = json_decode(json_string);
        var room_name = save_data[? "current_room"];
        ds_map_destroy(save_data);
        
        // Convert room name to readable text
        if (room_name == "room_Menu") return "Main Menu";
        if (room_name == "room_Desk_View") return "Desk View";
        if (room_name == "Login") return "Login Screen";
        
        return string_replace_all(room_name, "room_", "");
    }
    catch (e)
    {
        return "Save File";
    }
}

// Load game function
function _load_game_from_slot(slot_idx)
{
    if (!_save_exists(slot_idx)) 
    {
        show_debug_message("No save file in slot " + string(slot_idx));
        return false;
    }
    
    var filename = "save" + string(slot_idx) + ".sav";
    var file = file_text_open_read(filename);
    if (file == -1) return false;
    
    var json_string = file_text_read_string(file);
    file_text_close(file);
    
    try
    {
        var save_data = json_decode(json_string);
        
        // Load basic info
        global.save_slot = slot_idx;
        
        // Load room
        if (save_data[? "current_room"] != undefined)
        {
            global.current_room = save_data[? "current_room"];
        }
        
        // Load game flags
        if (save_data[? "game_flags"] != undefined)
        {
            global.flags = json_decode(save_data[? "game_flags"]);
        }
        else
        {
            global.flags = ds_map_create();
        }
        
        ds_map_destroy(save_data);
        show_debug_message("✓ Game loaded from slot " + string(slot_idx));
        return true;
    }
    catch (e)
    {
        show_debug_message("✗ Error loading save: " + string(e));
        return false;
    }
}

// Advance narration
function _advance(){
    if (!done_line){
        visible_chars = string_length(lines[line_index]);
        done_line = true;
    } else {
        line_index++;
        if (line_index >= array_length(lines)) {
            if (variable_global_exists("_queued_narr_return_room")
                && !is_undefined(global._queued_narr_return_room)) {

                var target_room = global._queued_narr_return_room;
                global._queued_narr_return_room = undefined;
                room_goto(target_room);
            } else {
                if (state == "narr1") {
                    room_goto(room_Desk_View);
                } else if (state == "narr2") {
                    room_goto(Login);
                }
            }
        } else {
            visible_chars = 0; 
            done_line = false;
        }
    }
}

// Check for queued narration from other rooms
if (variable_global_exists("_queued_narr_lines") && variable_global_exists("_queued_narr_state")) {
    show_debug_message("FOUND QUEUED NARRATION!");
    show_debug_message("State: " + string(global._queued_narr_state));
    show_debug_message("Lines: " + string(array_length(global._queued_narr_lines)));
    
    lines = global._queued_narr_lines;
    line_index = 0; 
    visible_chars = 0; 
    done_line = false;
    state = global._queued_narr_state;
    
    // Clear the queued variables
    global._queued_narr_lines = undefined;
    global._queued_narr_state = undefined;
    
    show_debug_message("Set state to: " + string(state));
}

show_debug_message("Initial state: " + string(state));
show_debug_message("=========================================");