// Block interaction when locked
if (!global.apps_unlocked.Calendar) {
    // optional: audio_play_sound(sfx_locked, 1, 0);
    exit;
}

// existing code that opens the Calendar app goes below this
