// Reset the per-frame click-pass-through flag before anyone handles input.
if (!variable_global_exists("_ui_click_consumed")) global._ui_click_consumed = false;
else global._ui_click_consumed = false;
