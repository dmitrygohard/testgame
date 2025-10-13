// В Step_0.gml добавляем обработку клавиш для мини-игр:
// =============================================================================
// MAIN ROOM CONTROLLER - Step Event  
// =============================================================================
aty_step(1);

// Обработка кликов мыши
if (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right)) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var button = mb_left;
    if (mouse_check_button_pressed(mb_right)) {
        button = mb_right;
    }
    aty_handle_click(mx, my, button);
}

// Обработка клавиш для мини-игр
if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right) ||
    keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down) ||
    keyboard_check_pressed(vk_space)) {
    
    var key = keyboard_lastkey;
    if (aty_handle_minigame_input(key)) {
        // Ввод обработан мини-игрой
    }
}
// Обновляем обработку ввода для рейд-босса:
function aty_handle_minigame_input(key) {
    // Проверяем активен ли рейд-босс
    if (variable_struct_exists(global.aty, "raid_boss") && global.aty.raid_boss.active && key == vk_space) {
        var damage = aty_player_attack_boss();
        return true; // Ввод обработан
    }
    
    return false;
}

// ESC для возврата в главную комнату или выхода из мини-игры
if (keyboard_check_pressed(vk_escape)) {
    if (global.aty.minigame.active) {
        // Выход из мини-игры
        aty_end_minigame(MINIGAME_RESULT.FAILED);
    } else if (room_exists(room_main)) {
        room_goto(room_main);
    }
}