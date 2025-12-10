/// obj_ClickFileUI - Create

// 0 = choose Delete / Share
// 1 = confirm delete ("Are you sure?")
// 2 = Share screen ("Share to Hacker")
// 3 = Done message ("Shared successfully!" or "File deleted.")
mode   = 0;
result = "";
target_inst = noone;

// Countdown for initial Delete/Share choice (5 seconds)
timer_frames = room_speed * 5;
lose_triggered = false;