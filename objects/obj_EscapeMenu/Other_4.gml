// Never auto-open; just reset ephemeral bits
active = false;
state  = "root";
submenu = "";
confirm_slot = -1;
if (is_struct(slider)) slider.dragging = false;
toast_t = 0;
