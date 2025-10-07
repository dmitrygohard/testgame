// Step_0.gml - исправленная версия с работающими кнопками переключения героев
// Обновление системы способностей
if (variable_global_exists("update_abilities_cooldowns")) {
    update_abilities_cooldowns();
    update_ability_buffs();
    update_mana_regeneration();
}
// ОБНОВЛЕНИЕ ЭКСПЕДИЦИИ ДОЛЖНО БЫТЬ В САМОМ НАЧАЛЕ!
if (global.expedition.active) {
    // Проверяем мгновенное завершение от Концепции Победы
    if (!check_instant_expedition_completion()) {
        update_expedition();
    }
}

// Обновление тренировок
update_trainings();

// Убедитесь, что функция update_buff_system вызывается
update_buff_system();
// ОБНОВЛЕНИЕ ВРЕМЕННЫХ БАФОВ - ДОБАВЛЯЕМ ЭТУ СТРОКУ
if (variable_global_exists("update_temp_buffs")) {
    update_temp_buffs();
}
// Обновление системы здоровья
update_health_system();

// Периодический пересчет бонусов
if (global.frame_count mod 60 == 0) {
    calculate_companion_bonuses();
}

global.frame_count++;

// Инициализация флага предотвращения двойной покупки
if (!variable_global_exists("shop_purchase_processed")) {
    global.shop_purchase_processed = false;
}

// Обработка кликов мыши
if (mouse_check_button_pressed(mb_left)) {
    // Инициализация shop_handled в начале обработки кликов
    var shop_handled = false;
    var click_handled = false;
        // Обработка кликов по способностям
    if (!click_handled && active_tab == 5) {
        for (var i = 0; i < array_length(global.ability_buttons); i++) {
            var btn = global.ability_buttons[i];
            if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                if (btn.type == "learn_ability") {
                    learn_ability(btn.ability_id);
                    click_handled = true;
                    break;
                } else if (btn.type == "use_ability") {
                    use_ability(btn.ability_id);
                    click_handled = true;
                    break;
                }
            }
        }
    }
    // Обработка кликов по вкладкам
    for (var i = 0; i < array_length(global.tab_buttons); i++) {
        var btn = global.tab_buttons[i];
        if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
            active_tab = btn.index;
            click_handled = true;
            break;
        }
    }
    
    // Обработка кликов по аренам
    if (!click_handled) {
        for (var i = 0; i < array_length(global.arena_buttons); i++) {
            var btn = global.arena_buttons[i];
            if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                if (btn.type == "start_training") {
                    start_training(btn.index);
                } else if (btn.type == "complete_training") {
                    complete_training_early(btn.index);
                } else if (btn.type == "enter_arena") {
                    // Переходим на арену
                    room_goto(room_hepo_arena);
                    add_notification("Переход на арену Hepo!");
                }
                click_handled = true;
                break;
            }
        }
    }
    
    // Обработка кликов по отряду (отправка на тренировку)
    if (!click_handled) {
        for (var i = 0; i < array_length(global.squad_buttons); i++) {
            var btn = global.squad_buttons[i];
            if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                start_training(btn.index);
                click_handled = true;
                break;
            }
        }
    }
    
    // Обработка кликов в магазине
    if (!click_handled && active_tab == 3 && !global.shop_purchase_processed) {
        // Обработка кликов по категориям
        for (var i = 0; i < array_length(global.shop_buttons); i++) {
            var btn = global.shop_buttons[i];
            if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                if (btn.type == "category") {
                    global.shop_current_category = btn.index;
                    // Сбрасываем страницу при смене категории
                    global.shop_category_current_page[global.shop_current_category] = 0;
                    shop_handled = true;
                    break;
                }
                else if (btn.type == "shop_item") {
                    var item_data = ds_map_find_value(global.ItemDB, btn.item_id);
                    
                    if (item_data == -1) {
                        show_debug_message("Ошибка: не найден предмет с ID " + btn.item_id);
                        break;
                    }
                    
                    var price = item_data[? "price"];
                    
                    if (global.gold >= price) {
                        // ПОКУПКА
                        global.gold -= price;
                        var success = AddItemToInventory(btn.item_id, 1);
                        
                        if (success) {
                            add_notification("Куплено: " + item_data[? "name"]);
                        } else {
                            add_notification("Ошибка: не удалось добавить предмет!");
                        }
                        
                        global.shop_purchase_processed = true;
                        shop_handled = true;
                    } else {
                        add_notification("Недостаточно золота!");
                    }
                    break;
                }
            }
        }
        
        // Обработка пагинации категорий
        if (!shop_handled) {
            for (var i = 0; i < array_length(global.shop_page_buttons); i++) {
                var btn = global.shop_page_buttons[i];
                if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                    if (btn.type == "category_prev_page") {
                        change_shop_category_page(-1);
                        shop_handled = true;
                        show_debug_message("Переход на предыдущую страницу категории");
                    } else if (btn.type == "category_next_page") {
                        change_shop_category_page(1);
                        shop_handled = true;
                        show_debug_message("Переход на следующую страницу категории");
                    }
                    
                    if (shop_handled) {
                        break;
                    }
                }
            }
        }
        
        if (shop_handled) {
            global.shop_purchase_processed = true;
            click_handled = true;
        }
    }
    
    // Обработка кликов в экспедициях
    if (!click_handled && active_tab == 2 && !global.expedition.active) {
        for (var i = 0; i < array_length(global.expedition_buttons); i++) {
            var btn = global.expedition_buttons[i];
            if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                var diff = global.expedition_difficulties[btn.difficulty];
                
                // Проверяем, есть ли в экспедиции босс
                if (diff.boss != -1) {
                    // Показываем подтверждение для экспедиций с боссом
                    global.expedition_confirmation_required = true;
                    global.pending_expedition_difficulty = btn.difficulty;
                } else {
                    // Для обычных экспедиций начинаем сразу
                    start_expedition(btn.difficulty);
                }
                click_handled = true;
                break;
            }
        }
    }

    // Обработка подтверждения экспедиции
    if (!click_handled && global.expedition_confirmation_required) {
        // Проверяем клик по кнопкам подтверждения
        for (var i = 0; i < array_length(global.expedition_confirmation_buttons); i++) {
            var btn = global.expedition_confirmation_buttons[i];
            if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                if (btn.type == "confirm_yes") {
                    start_expedition(global.pending_expedition_difficulty);
                }
                // Сбрасываем независимо от ответа
                global.expedition_confirmation_required = false;
                global.pending_expedition_difficulty = -1;
                click_handled = true;
                break;
            }
        }
    }
    
    // Обработка кликов для вкладки статистики
    if (!click_handled && active_tab == 0) {
        for (var i = 0; i < array_length(global.inv_buttons); i++) {
            var btn = global.inv_buttons[i];
            if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                if (btn.type == "use_potion" && btn.potion_type == "health") {
                    use_health_potion();
                    click_handled = true;
                }
                break;
            }
        }
    }
    
    // Обработка кликов в разделе трофеев
    if (!click_handled && active_tab == 4) {
        if (variable_global_exists("trophy_showcase_buttons")) {
            for (var i = 0; i < array_length(global.trophy_showcase_buttons); i++) {
                var btn = global.trophy_showcase_buttons[i];
                if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                    clear_featured_slot(btn.slot);
                    click_handled = true;
                    break;
                }
            }
        }

        if (!click_handled && variable_global_exists("trophy_buttons")) {
            for (var i = 0; i < array_length(global.trophy_buttons); i++) {
                var btn = global.trophy_buttons[i];
                if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                    toggle_featured_trophy(btn.trophy_id);
                    click_handled = true;
                    break;
                }
            }
        }
    }
    
    // Обработка кликов в инвентаре - ВАЖНО: эта секция должна быть ВНУТРИ условия mouse_check_button_pressed
    if (!click_handled && active_tab == 1) {
        show_debug_message("Обработка кликов в инвентаре, всего кнопок: " + string(array_length(global.inv_buttons)));
        
        for (var i = 0; i < array_length(global.inv_buttons); i++) {
            var btn = global.inv_buttons[i];
            
            if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
                show_debug_message("Клик на кнопку типа: " + btn.type);
                
                if (btn.type == "equip_slot") {
                    // Снятие предмета с экипировки
                    var slot_struct = global.equipment_slots[btn.hero_index];
                    var slot_item_id = variable_struct_get(slot_struct, btn.slot_type);
                    if (slot_item_id != -1) {
                        UnequipItem(btn.hero_index, btn.slot_type);
                        show_debug_message("Снят предмет из слота: " + btn.slot_type);
                    } else {
                        show_debug_message("Слот " + btn.slot_type + " пуст");
                    }
                    click_handled = true;
                    break;
                } else if (btn.type == "inventory_equip") {
                    // Экипировка предмета кликом на карточку (левая кнопка)
                    show_debug_message("Экипировка предмета с индексом: " + string(btn.cell_index));
                    equip_item_from_inventory(btn.cell_index);
                    click_handled = true;
                    break;
                } else if (btn.type == "inventory_use") {
                    // Использование предмета (зелья/свитки)
                    show_debug_message("Использование предмета с индексом: " + string(btn.cell_index));
                    use_item_from_inventory(btn.cell_index);
                    click_handled = true;
                    break;
                } else if (btn.type == "inventory_sell") {
                    // Продажа через кнопку продажи
                    show_debug_message("Клик на продажу предмета с индексом: " + string(btn.cell_index));
                    sell_item_direct(btn.cell_index, 1);
                    click_handled = true;
                    break;
                } else if (btn.type == "inventory_card_quick_sell") {
                    // Быстрая продажа по правому клику на всю карточку
                    if (mouse_check_button_pressed(mb_right)) {
                        show_debug_message("Правый клик на карточку для продажи: " + string(btn.cell_index));
                        sell_item_direct(btn.cell_index, 1);
                        click_handled = true;
                        break;
                    }
                }
            }
        }
    }
    
    // Обработка кликов по кнопке возврата (если находимся на арене Hepo)
    if (!click_handled && room == room_hepo_arena) {
        if (variable_global_exists("return_button") && global.return_button != undefined) {
            var return_btn = global.return_button;
            if (point_in_rectangle(mouse_x, mouse_y, return_btn.x1, return_btn.y1, return_btn.x2, return_btn.y2)) {
                // Возвращаемся в основную комнату
                room_goto(room_main);
                add_notification("Возврат из арены Hepo");
                click_handled = true;
            }
        }
    }
}

// Обработка нажатия клавиши ESC для возврата
if (keyboard_check_pressed(vk_escape)) {
    if (room == room_hepo_arena) {
        // Возвращаемся в основную комнату по ESC
        room_goto(room_main);
        add_notification("Возврат из арены Hepo");
    }
}

// Очистка старых эффектов покупки/продажи (дольше 1.5 секунд)
if (variable_global_exists("purchase_effects")) {
    var i = 0;
    while (i < ds_list_size(global.purchase_effects)) {
        var effect = ds_list_find_value(global.purchase_effects, i);
        // ИСПРАВЛЕНО: проверяем существование поля purchase_frame
        if (variable_struct_exists(effect, "purchase_frame") && global.frame_count - effect.purchase_frame >= 90) { // 90 кадров = 1.5 секунды
            ds_list_delete(global.purchase_effects, i);
        } else {
            i++;
        }
    }
}

// Обработка прокрутки инвентаря колесиком мыши
if (active_tab == 1) {
    var scroll = mouse_wheel_down() - mouse_wheel_up();
    if (scroll != 0) {
        global.inv_scroll_offset -= scroll * 30;
        global.inv_scroll_offset = clamp(global.inv_scroll_offset, 0, global.inv_max_scroll);
    }
}

// Обработка перетаскивания ползунка инвентаря
if (active_tab == 1) {
    // Если нажали кнопку мыши
    if (mouse_check_button_pressed(mb_left)) {
        if (variable_global_exists("inv_scrollbar_rect") && global.inv_scrollbar_rect != -1) {
            var rect = global.inv_scrollbar_rect;
            if (point_in_rectangle(mouse_x, mouse_y, rect.x1, rect.y1, rect.x2, rect.y2)) {
                global.inv_scroll_dragging = true;
                global.inv_scroll_drag_start_y = mouse_y;
                global.inv_scroll_drag_start_offset = global.inv_scroll_offset;
            }
        }
    }
    
    // Если отпустили кнопку мыши, сбрасываем перетаскивание
    if (mouse_check_button_released(mb_left)) {
        global.inv_scroll_dragging = false;
    }
    
    // Если перетаскиваем ползунок
    if (global.inv_scroll_dragging) {
        if (variable_global_exists("inv_scrollbar_rect") && global.inv_scrollbar_rect != -1) {
            var rect = global.inv_scrollbar_rect;
            var drag_delta = mouse_y - global.inv_scroll_drag_start_y;
            var track_height = rect.track_y2 - rect.track_y1;
            var scroll_delta = (drag_delta / track_height) * global.inv_max_scroll;
            
            global.inv_scroll_offset = clamp(global.inv_scroll_drag_start_offset + scroll_delta, 0, global.inv_max_scroll);
        }
    }
}

// Сброс флага покупки в магазине в следующем кадре
if (global.shop_purchase_processed) {
    global.shop_purchase_processed = false;
}