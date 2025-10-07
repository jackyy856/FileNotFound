// layout
event_inherited();   // gets base geometry and state
title = "Mail";     // window title
script_execute(_recalc); // update rects after changing size
window_w = 1700;
window_h = 900;
window_x = 90;   //x position (left edge) of window
window_y = 90;   //y position (top edge) of window

header_h = 55;   //header height
row_h    = 36;   //inbox row height
list_top = window_y + header_h + 8;  //y start of inbox list; below header
list_left= window_x + 16;            //x start of inbox list
list_w   = window_w - 32;            //inbox list width
list_h   = window_h - header_h - 24; //inbox list height

// state
selected_index = -1;      //-1 = inbox view; 0... = full email view

// button 
close_btn = [window_x + window_w - 36, window_y + 12, 24, 24]; 
back_btn  = [window_x + 12,            window_y + 40, 64, 24]; 


// fonts (figure out font assets
var fTitle = asset_get_index("f_mail_title");
var fBody  = asset_get_index("f_mail_body");
font_title = (fTitle != -1) ? fTitle : -1; // -1 = default font
font_body  = (fBody  != -1) ? fBody  : -1;

// inbox data
inbox = [
    { id:0, from:"IT Support", subject:"Action Required: Password Reset",
      body:"Your password expires today. Click the in-app link to reset.", read:false, is_suspicious:false },

    { id:1, from:"Unknown", subject:"[URGENT] Outstanding invoice (open immediately)",
      body:"This message contains your invoice.",
      read:false, is_suspicious:false },
	  
	{ id:2, from:"announcementz@rosenwood.hr", subject:"You have been selected for a bonus opportunity!",
      body:"Congratulations! Thanks to your outstanding performance, we have an amazing notice to share. Please click here to redeem your certificate of recognition. Thank you for your hard work!",
      read:false, is_suspicious:true },
	  
    { id:3, from:"Patrica Conway", subject:"Friday Office Party",
      body:"Hey! Sharing the office party photos. Don't let the boss see ;)",
      read:false, is_suspicious:false }
];