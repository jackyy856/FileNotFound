/// obj_EscapeMenu — Create
persistent = true;

// GUI base
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

// ---------- SAVE/LOAD HELPERS ----------
function _slot_file(i) { return "save_slot" + string(i) + ".ini"; }

function _slot_meta(i) {
    var f = _slot_file(i);
    if (!file_exists(f)) return {exists:false, title:"Empty Save Slot"};
    ini_open(f);
    var title = ini_read_string("meta","title","Empty Save Slot");
    ini_close();
    return {exists:(title != "Empty Save Slot"), title:title};
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
    var title = string(date_current_datetime()); // simple, no re-declare drama
    var blob  = json_stringify(_save_pack());

    ini_open(f);
    ini_write_string("meta","title", title);
    ini_write_string("data","blob",  blob);
    ini_close();
}

function _save_load(slot_idx) {
    var f = _slot_file(slot_idx);
    if (!file_exists(f)) return false;

    ini_open(f);
    var blob = ini_read_string("data","blob","{}");
    ini_close();

    // guard against bad/corrupt data
    var pack = {};
    var ok = true;
    try {
        pack = json_parse(blob);
    } catch(_) {
        ok = false;
    }
    if (!ok || !is_struct(pack)) return false;

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

    var target = room_Menu;
    if (!is_undefined(pack.room)) {
        var rn = asset_get_index(string(pack.room));
        if (rn != -1) target = rn;
    }
    room_goto(target);
    return true;
}

// ---------- LAYOUT REBUILDER ----------
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
