/// obj_EscapeBoot — Create
// Ensure the pause menu singleton exists once, then self-destruct.
if (!instance_exists(obj_EscapeMenu)) {
    var lyr = layer_exists("Instances") ? "Instances" : layer_get_name(layer_get_id(0));
    instance_create_layer(0, 0, lyr, obj_EscapeMenu);
}
instance_destroy();
