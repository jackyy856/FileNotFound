// Clean up data structures when Obj_wifi is destroyed
if (ds_exists(global_opened_apps, ds_type_list)) {
    ds_list_destroy(global_opened_apps);
}
if (ds_exists(global_app_data, ds_type_map)) {
    ds_map_destroy(global_app_data);
}