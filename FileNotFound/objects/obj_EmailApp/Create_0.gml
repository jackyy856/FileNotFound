// layout
window_w = 640;
window_h = 420;
window_x = 80;
window_y = 80;

header_h = 48;
row_h    = 36;
list_top = window_y + header_h + 8;
list_left= window_x + 16;
list_w   = window_w - 32;
list_h   = window_h - header_h - 24;

// state
selected_index = -1;

// button 
close_btn = [window_x + window_w - 36, window_y + 12, 24, 24]; //instance var
back_btn  = [window_x + 12,            window_y + 12, 64, 24]; 


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
      read:false, is_suspicious:true },

    { id:2, from:"Coworker", subject:"Photos from last Friday",
      body:"Hey! Sharing the office party photos. Don't let the boss see ;)",
      read:false, is_suspicious:false }
];