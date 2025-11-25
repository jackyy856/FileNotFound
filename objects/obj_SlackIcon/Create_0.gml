/// Slack desktop icon setup (same pattern as other app icons)

app_key = "Slack";       // key used in global.apps_unlocked
app_obj = obj_SlackApp;  // app window object for this icon

// Safety: if you forgot to assign a sprite in the editor, reuse Files icon art
if (sprite_index == -1) {
    sprite_index = spr_FilesIcon;
}
