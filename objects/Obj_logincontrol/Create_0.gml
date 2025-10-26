// Username is fixed as "Boss"
username = "Boss";

// Create password box
password_box = instance_create_layer(860, 580, "Instances", Obj_text);
password_box.text = "";  // Start empty
password_box.placeholder = "Enter:";   
password_box.active = false;
password_box.width = 250;
password_box.height = 40;


//Hints
hint_text = "Hint";
hint_clicked = false;
hint_x = 920;
hint_y = 630;
hint_width = 100;
hint_height = 20;
correct_password = "Paris";
login_message = "";
