draw_self();

var locked = !(variable_struct_exists(global.apps_unlocked, app_key)
            &&  variable_struct_get(global.apps_unlocked, app_key));
