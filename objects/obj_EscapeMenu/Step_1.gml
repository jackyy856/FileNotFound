/// obj_EscapeMenu — Begin Step
// Latch input edges at the very start of the frame so no one else can "eat" them.

// keep vars if they already exist
if (!variable_instance_exists(id, "esc_edge")) esc_edge = false;
if (!variable_instance_exists(id, "mb_left_edge")) mb_left_edge = false;
if (!variable_instance_exists(id, "mx_gui")) mx_gui = 0;
if (!variable_instance_exists(id, "my_gui")) my_gui = 0;

// Edge-detect ESC here (earliest phase in frame)
esc_edge = keyboard_check_pressed(vk_escape);

// Edge-detect LEFT CLICK here (earliest phase in frame)
mb_left_edge = mouse_check_button_pressed(mb_left);

// Cache mouse position in GUI space once per frame for consistent hit-tests
mx_gui = device_mouse_x_to_gui(0);
my_gui = device_mouse_y_to_gui(0);

// Advertise pause state globally so other systems can avoid clearing inputs
global.pause_menu_active = active;
