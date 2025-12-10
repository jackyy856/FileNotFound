/// obj_EscapeMenu — Create
persistent = true;

// --- GUI base ---------------------------------------------------------------
display_set_gui_size(1920, 1080);
_last_gui_w = display_get_gui_width();
_last_gui_h = display_get_gui_height();

// ---------- STATE ----------
active  = false;
state   = "root";
submenu = "";
toast_txt = "";
toast_t   = 0;

// ---------- LAYOUT ----------
panel_pad = 40;
btn_w = 520; btn_h = 64; btn_gap = 26;

buttons_root = [];
btn_back     = { x:0, y:0, w:0, h:0, label:"< Back" };
slots        = [];
slider       = { x:0, y:0, w:0, h:0, knob_w:22, dragging:false };
slider_val   = 100;

// Confirm modal data
confirm_title   = "";
confirm_msg     = "";
confirm_slot    = -1;
confirm_buttons = [];

// ---------- SAVE/LOAD HELPERS ----------------------------------------------
function _slot_file(i) { return "save_slot" + string(i) + ".ini"; }
function _slot_data_file(i) { return "save_slot" + string(i) + "_data.json"; }

function _slot_meta(i) {
    var f = _slot_file(i);
    if (!file_exists(f)) return {exists:false, title:"Empty Save Slot"};
    ini_open(f);
    var title = ini_read_string("meta","title","Empty Save Slot");
    ini_close();
    return {exists:(title != "Empty Save Slot"), title:title};
}

function _json_to_struct(val) {
    if (is_struct(val) || is_array(val) || is_string(val) || is_real(val) || is_bool(val) || is_undefined(val)) {
        return val;
    }
    if (ds_exists(val, ds_type_map)) {
        var out = {};
        var key = ds_map_find_first(val);
        while (!is_undefined(key)) {
            var v = ds_map_find_value(val, key);
            variable_struct_set(out, key, _json_to_struct(v));
            key = ds_map_find_next(val, key);
        }
        ds_map_destroy(val);
        return out;
    }
    if (ds_exists(val, ds_type_list)) {
        var len = ds_list_size(val);
        var arr = array_create(len);
        for (var i = 0; i < len; i++) {
            arr[i] = _json_to_struct(ds_list_find_value(val, i));
        }
        ds_list_destroy(val);
        return arr;
    }
    return val;
}

function _save_log(msg) {
    show_debug_message("[SAVE] " + msg);
}

function _save_set_error(msg) {
    global._last_save_error = msg;
    if (msg != "") _save_log(msg);
}

function _save_pack() {
    var pack = {
        room : room_get_name(room),
        vol  : variable_global_exists("master_volume") ? global.master_volume : 100,
        flags: variable_global_exists("flags") ? global.flags : {},
        apps : variable_global_exists("apps_unlocked") ? global.apps_unlocked : {}
    };
    if (variable_global_exists("save_extra_pack") && is_callable(global.save_extra_pack)) {
        var extra = global.save_extra_pack();
        if (is_struct(extra)) {
            var ks = variable_struct_get_names(extra);
            for (var k = 0; k < array_length(ks); k++) {
                var nm = ks[k];
                variable_struct_set(pack, nm, variable_struct_get(extra, nm));
            }
        }
    }
    return pack;
}

function _save_write(slot_idx) {
    var f = _slot_file(slot_idx);
    var title = string(date_current_datetime());
    var pack = _save_pack();
    
    if (!is_struct(pack)) {
        _save_set_error("Save pack is not a valid struct");
        return false;
    }
    
    var blob = "";
    try {
        blob = json_stringify(pack);
    } catch(_err) {
        _save_set_error("JSON stringify failed: " + string(_err));
        return false;
    }
    
    if (string_length(blob) <= 2) {
        _save_set_error("Save pack serialized to empty string");
        _save_log("Pack keys: " + string(variable_struct_get_names(pack)));
        return false;
    }
    
    var parsed_ok = true;
    try {
        var _test = json_parse(blob);
        _json_to_struct(_test); // ensures ds data cleaned up on older runtimes
    } catch(_err) {
        parsed_ok = false; _save_set_error("Save serialize failed: " + string(_err));
    }
    if (!parsed_ok) return false;

    // Write blob to separate JSON file (INI files have string length limits)
    var data_file = _slot_data_file(slot_idx);
    if (file_exists(data_file)) file_delete(data_file);
    
    var file_handle = file_text_open_write(data_file);
    if (file_handle == -1) {
        _save_set_error("Could not open data file for writing");
        return false;
    }
    file_text_write_string(file_handle, blob);
    file_text_close(file_handle);
    
    // Verify the data file was written
    if (!file_exists(data_file)) {
        _save_set_error("Data file was not created");
        return false;
    }
    
    // Write metadata to INI file
    if (file_exists(f)) file_delete(f);
    ini_open(f);
    ini_write_string("meta","title", title);
    ini_write_string("meta","data_file", data_file);
    ini_close();
    
    // Verify both files exist
    if (!file_exists(f)) {
        _save_set_error("INI file was not created");
        return false;
    }
    
    _save_set_error("");
    _save_log("Wrote slot " + string(slot_idx) + " (" + string(string_length(blob)) + " chars)");
    return true;
}

function _save_load(slot_idx) {
    var f = _slot_file(slot_idx);
    if (!file_exists(f)) { 
        _save_set_error("Slot " + string(slot_idx) + " missing file"); 
        return false; 
    }

    // Try to read from separate JSON file first (new format)
    var data_file = _slot_data_file(slot_idx);
    var blob = "";
    
    if (file_exists(data_file)) {
        // New format: read from separate JSON file
        var file_handle = file_text_open_read(data_file);
        if (file_handle == -1) {
            _save_set_error("Could not open data file for reading");
            return false;
        }
        blob = file_text_read_string(file_handle);
        file_text_close(file_handle);
    } else {
        // Old format: try to read from INI (for backwards compatibility)
        ini_open(f);
        blob = ini_read_string("data","blob","");
        ini_close();
    }
    
    ini_open(f);
    var title_check = ini_read_string("meta","title","");
    ini_close();
    
    _save_log("Loading slot " + string(slot_idx) + " - blob length: " + string(string_length(blob)) + ", title: " + title_check);
    
    if (string_length(blob) <= 2) {
        _save_set_error("Slot " + string(slot_idx) + " empty blob (length: " + string(string_length(blob)) + ")");
        return false;
    }

    var pack = {};
    var ok = true;
    try { 
        pack = json_parse(blob); 
    } catch(_err) { 
        ok = false; 
        _save_set_error("Slot " + string(slot_idx) + " JSON parse failed: " + string(_err)); 
    }
    
    if (!ok) return false;
    
    pack = _json_to_struct(pack);
    
    if (!is_struct(pack)) {
        _save_set_error("Slot " + string(slot_idx) + " data invalid (not a struct)");
        return false;
    }

    if (!is_undefined(pack.vol)) {
        global.master_volume = pack.vol;
        audio_master_gain(global.master_volume/100);
        slider_val = global.master_volume;
    }
    if (!is_undefined(pack.flags)) global.flags = pack.flags;
    if (!is_undefined(pack.apps))  global.apps_unlocked = pack.apps;

    if (variable_global_exists("save_extra_apply") && is_callable(global.save_extra_apply)) {
        global.save_extra_apply(pack);
    }

    var target = _menu_room(); // default back to menu if saved room missing
    if (!is_undefined(pack.room)) {
        var rn = asset_get_index(string(pack.room));
        if (rn != -1) target = rn;
    }
    room_goto(target);
    _save_set_error("");
    return true;
}

function _capture_state_from(_obj) {
    if (!instance_exists(_obj)) return undefined;
    var inst = instance_find(_obj, 0);
    if (inst == noone) return undefined;
    if (!variable_instance_exists(inst, "_save_state_blob")) return undefined;
    var fn = variable_instance_get(inst, "_save_state_blob");
    if (!is_callable(fn)) return undefined;
    return fn();
}

function _apply_state_to(_obj, _blob) {
    if (_blob == undefined) return false;
    if (!instance_exists(_obj)) return false;
    var inst = instance_find(_obj, 0);
    if (inst == noone) return false;
    if (!variable_instance_exists(inst, "_apply_state_blob")) return false;
    var fn = variable_instance_get(inst, "_apply_state_blob");
    if (!is_callable(fn)) return false;
    fn(_blob);
    return true;
}

// ---------- MENU ROOM RESOLVER & ENSURER -----------------------------------
// Handle the "room_Menu" vs "_Menu" name mismatch safely.
function _menu_room() {
    var r = asset_get_index("room_Menu");
    if (r == -1) r = asset_get_index("_Menu");
    // Fallback to current room if neither exists to avoid crashes.
    return (r != -1) ? r : room;
}

// Make sure the Menu Controller exists when we're in the Menu room.
function _ensure_menu_controller() {
    if (room != _menu_room()) return;
    if (!instance_exists(obj_MenuController)) {
        var lyr = layer_exists("Instances") ? "Instances" : layer_get_name(layer_get_id(0));
        instance_create_layer(room_width * 0.5, room_height * 0.5, lyr, obj_MenuController);
    }
}

// ---------- LAYOUT REBUILDER -----------------------------------------------
function _layout() {
    display_set_gui_size(1920, 1080);
    var GW = display_get_gui_width();
    var GH = display_get_gui_height();
    _last_gui_w = GW; _last_gui_h = GH;

    var col_x = (GW - btn_w) * 0.5;
    var col_y = (GH * 0.5) - (btn_h*2 + btn_gap*1.5);

    buttons_root = [
        {x:col_x, y:col_y + 0*(btn_h+btn_gap), w:btn_w, h:btn_h, label:"Load Game",  kind:"load"},
        {x:col_x, y:col_y + 1*(btn_h+btn_gap), w:btn_w, h:btn_h, label:"Save Game",  kind:"save"},
        {x:col_x, y:col_y + 2*(btn_h+btn_gap), w:btn_w, h:btn_h, label:"Settings",   kind:"settings"},
        {x:col_x, y:col_y + 3*(btn_h+btn_gap), w:btn_w, h:btn_h, label:"Main Menu",  kind:"mainmenu"}
    ];

    btn_back = { x: 40, y: 40, w: 160, h: 48, label:"< Back" };

    var slot_w = 360, slot_h = 280, slot_gap = 56;
    var slot_x0 = (GW - (3*slot_w + 2*slot_gap)) * 0.5;
    var slot_y0 = (GH - slot_h) * 0.5;

    slots = [
        {x:slot_x0 + 0*(slot_w+slot_gap), y:slot_y0, w:slot_w, h:slot_h, idx:1},
        {x:slot_x0 + 1*(slot_w+slot_gap), y:slot_y0, w:slot_w, h:slot_h, idx:2},
        {x:slot_x0 + 2*(slot_w+slot_gap), y:slot_y0, w:slot_w, h:slot_h, idx:3}
    ];

    if (!variable_global_exists("master_volume")) global.master_volume = 100;
    slider_val = clamp(global.master_volume, 0, 100);
    slider = { x: (GW - 820)*0.5, y: GH*0.56, w: 820, h: 10, knob_w: 22, dragging:false };

    confirm_buttons = [
        {x: GW*0.5 - 200, y: GH*0.5 + 60, w:160, h:48, label:"Cancel",  kind:"cancel"},
        {x: GW*0.5 +  40, y: GH*0.5 + 60, w:160, h:48, label:"Confirm", kind:"confirm"}
    ];
}

// toast
function _toast(t) { toast_txt = t; toast_t = room_speed * 3; state = "toast"; }

// build once
_layout();

if (!variable_global_exists("_pending_save_chunks") || !is_struct(global._pending_save_chunks)) {
    global._pending_save_chunks = {};
}
if (!variable_global_exists("_last_save_error")) global._last_save_error = "";

global._save_tracked_globals = [
    "story_keys",
    "window_z_next",
    "key_collected",
    "file_minigame_result",
    "pieces_placed",
    "total_pieces",
    "puzzleComplete",
    "puzzle_img",
    "puzzle_scale",
    "puzzle_area_x",
    "puzzle_area_y",
    "puzzle_area_width",
    "puzzle_area_height",
    "pieces_area_x",
    "pieces_area_y",
    "pieces_area_width",
    "pieces_area_height",
    "piece_positions",
    "piece_colors",
    "piece_src",
    // wifi + hacker progression
    "wifi_ever_connected",
    "hacker_unread",
    "hacker_key1_delay",
    "hacker_key1_hint_pending",
    "hacker_key1_hint_fired",
    "hacker_key2_delay",
    "hacker_key2_hint_pending",
    "hacker_key2_hint_fired",
    "hacker_key3_delay",
    "hacker_key3_hint_pending",
    "hacker_key3_hint_fired",
    "hacker_dove_hint_pending",
    "hacker_dove_hint_fired",
    "hacker_dove_unlock_pending",
    "hacker_dove_follow_pending",
    "hacker_dove_unlock_timer",
    "hacker_dove_follow_timer",
    "hacker_dove_calendar_pending",
    "hacker_dove_calendar_fired",
    "hacker_transcript_follow_timer",
    "hacker_transcript_follow_pending",
    "hacker_transcript_follow_fired",
    "hacker_iwork_follow_timer",
    "hacker_iwork_follow_pending",
    "hacker_iwork_unread_queued",
    "hacker_wifi_hint_pending"
];

global.save_extra_pack = function () {
    var extra = {};
    for (var i = 0; i < array_length(global._save_tracked_globals); i++) {
        var nm = global._save_tracked_globals[i];
        if (variable_global_exists(nm)) {
            variable_struct_set(extra, nm, variable_global_get(nm));
        }
    }
    var desk_blob = _capture_state_from(obj_DeskViewController);
    if (!is_undefined(desk_blob)) extra.desk_state = desk_blob;
    var wifi_blob = _capture_state_from(Obj_wifi);
    if (!is_undefined(wifi_blob)) extra.wifi_state = wifi_blob;
    var hacker_blob = _capture_state_from(obj_HackerMsgrApp);
    if (!is_undefined(hacker_blob)) extra.hacker_state = hacker_blob;
    return extra;
};

global.save_extra_apply = function (pack) {
    if (!is_struct(pack)) return;

    for (var i = 0; i < array_length(global._save_tracked_globals); i++) {
        var nm = global._save_tracked_globals[i];
        if (variable_struct_exists(pack, nm)) {
            variable_global_set(nm, variable_struct_get(pack, nm));
        }
    }

    if (!is_struct(global._pending_save_chunks)) global._pending_save_chunks = {};

    if (variable_struct_exists(pack, "desk_state")) {
        var desk_blob = variable_struct_get(pack, "desk_state");
        global._pending_save_chunks.desk_state = desk_blob;
        _apply_state_to(obj_DeskViewController, desk_blob);
    }
    if (variable_struct_exists(pack, "wifi_state")) {
        var wifi_blob = variable_struct_get(pack, "wifi_state");
        global._pending_save_chunks.wifi_state = wifi_blob;
        _apply_state_to(Obj_wifi, wifi_blob);
    }
    if (variable_struct_exists(pack, "hacker_state")) {
        var hacker_blob = variable_struct_get(pack, "hacker_state");
        global._pending_save_chunks.hacker_state = hacker_blob;
        _apply_state_to(obj_HackerMsgrApp, hacker_blob);
    }
};

global.save_api = {
    slot_file : method(id, _slot_file),
    slot_meta : method(id, _slot_meta),
    save_write: method(id, _save_write),
    save_load : method(id, _save_load)
};
