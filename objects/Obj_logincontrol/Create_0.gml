// Username is fixed as "Boss"
username = "Boss";

// Create password box
password_box = instance_create_layer(820, 600, "Instances", Obj_text);
password_box.text = "";  // Start empty
password_box.placeholder = "Enter:";   
password_box.active = false;
password_box.width = 300;
password_box.height = 40;


//Hints
hint_text = "hint";
hint_clicked = false;
hint_x = 920;
hint_y = 650;
hint_width = 100;
hint_height = 20;
correct_password = "Paris";
login_message = "";
