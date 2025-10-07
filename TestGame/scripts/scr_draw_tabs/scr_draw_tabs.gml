function draw_tabs_section(panel_y, panel_height) {
    var section_x = global.squad_width;
    var section_y = panel_y;
    var section_width = global.tabs_width;
    var section_height = panel_height;

    // Вкладки
    var tab_names = ["📊 Статистика", "🎒 Инвентарь", "🗺️ Экспедиции", "🛒 Магазин", "👥 Помощницы", "✨ Способности"];
    var tab_count = array_length(tab_names);
    
    // ВЫЧИСЛЯЕМ ширину вкладки - ДОБАВЬТЕ ЭТУ СТРОКУ
    var tab_width = section_width / tab_count;
    
    global.tab_buttons = [];
    
    for (var i = 0; i < tab_count; i++) {
        var tab_x = section_x + i * tab_width;
        var tab_y = section_y;
        var tab_height = 40;
        
        var is_active = (i == active_tab);
        var is_hovered = point_in_rectangle(mouse_x, mouse_y, tab_x, tab_y, tab_x + tab_width, tab_y + tab_height);
        
        // Цвет вкладки
        var tab_color = is_active ? ui_highlight : (is_hovered ? ui_bg_accent : ui_bg_medium);
        
        // Фон вкладки
        draw_set_color(tab_color);
        draw_rectangle(tab_x, tab_y, tab_x + tab_width, tab_y + tab_height, false);
        
        // Рамка
        draw_set_color(is_active ? ui_highlight : ui_border_color);
        draw_rectangle(tab_x, tab_y, tab_x + tab_width, tab_y + tab_height, true);
        
        // Текст
        draw_set_color(is_active ? c_white : ui_text);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(tab_x + tab_width/2, tab_y + tab_height/2, tab_names[i]);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        // Кнопка вкладки
        array_push(global.tab_buttons, {
            index: i,
            x1: tab_x, y1: tab_y,
            x2: tab_x + tab_width, y2: tab_y + tab_height
        });
    }
    
    // Содержимое вкладки будет отрисовано в другой функции
}

function draw_stats_tab(x, y, width, height) {
    global.inv_buttons = [];
    
    // Используем современную панель
    draw_modern_panel(x, y, width, height);
    
    if (room == room_hepo_arena) {
        // На арене Hepo показываем статистику только Hepo
        draw_hepo_stats_section(x, y, width, height);
    } else {
        // В основной комнате - обычную статистику
        draw_set_color(ui_text);
        draw_set_halign(fa_center);
        draw_text(x - 220 + width/2, y, "📊 ПОДРОБНАЯ СТАТИСТИКА ОТРЯДА");
        draw_set_halign(fa_left);
        
        // Две колонки с современным оформлением
        var col_width = width / 2 - 15;
        var current_y = y + 35;
        
        // Левая колонка - характеристики
        draw_character_stats_section(x + 10, current_y, col_width, height - 50);
        
        // Правая колонка - боевые показатели и бонусы
        draw_combat_stats_section(x + col_width + 20, current_y, col_width, height - 50);
    }
}

function draw_hepo_stats_section(x, y, width, height) {
    var hepo = global.companions[0]; // Hepo - первый компаньон
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(x + width/2, y + 10, "⭐ СТАТИСТИКА HEPO");
    draw_set_halign(fa_left);
    
    // Центральная информация о Hepo
    var center_x = x + width/2;
    var current_y = y + 35;
    
    // Аватар и основная информация
    draw_set_color(companion_colors[0]); // Цвет Hepo
    draw_set_halign(fa_center);
    draw_text(center_x, current_y, "👑 " + hepo.name);
    current_y += 25;
    
    draw_set_color(ui_text);
    draw_text(center_x, current_y, "Уровень: " + string(hepo.level));
    current_y += 20;
    
    draw_text(center_x, current_y, "Ранг: " + string(hepo.rank) + "/" + string(hepo.max_rank));
    current_y += 20;
    
    // Здоровье
    var health_percent = hepo.health / hepo.max_health;
    draw_text(center_x, current_y, "❤️ Здоровье: " + string(floor(hepo.health)) + "/" + string(hepo.max_health));
    current_y += 25;
    
    // Прогресс-бар здоровья
    var bar_width = width * 0.6;
    var bar_x = center_x - bar_width/2;
    var bar_y = current_y;
    
    draw_set_color(ui_bg_dark);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + 12, false);
    
    // Градиент здоровья
    for (var i = 0; i < bar_width * health_percent; i++) {
        var ratio = i / bar_width;
        var r = lerp(86, 255, ratio);
        var g = lerp(213, 100, ratio);
        var b = lerp(150, 100, ratio);
        draw_set_color(make_color_rgb(r, g, b));
        draw_rectangle(bar_x + i, bar_y, bar_x + i + 1, bar_y + 12, false);
    }
    
    draw_set_color(ui_border_color);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + 12, true);
    current_y += 25;
    
    // Опыт
    var exp_percent = hepo.exp / hepo.exp_to_level;
    draw_text(center_x, current_y, "📊 Опыт: " + string(hepo.exp) + "/" + string(hepo.exp_to_level));
    current_y += 25;
    
    // Прогресс-бар опыта
    var exp_bar_y = current_y;
    draw_set_color(ui_bg_dark);
    draw_rectangle(bar_x, exp_bar_y, bar_x + bar_width, exp_bar_y + 8, false);
    
    draw_set_color(ui_highlight);
    draw_rectangle(bar_x, exp_bar_y, bar_x + bar_width * exp_percent, exp_bar_y + 8, false);
    
    draw_set_color(ui_border_color);
    draw_rectangle(bar_x, exp_bar_y, bar_x + bar_width, exp_bar_y + 8, true);
    current_y += 20;
    
    // Основной бонус
    draw_set_color(ui_highlight);
    draw_text(center_x, current_y, "🎯 Основной бонус:");
    current_y += 20;
    
    draw_set_color(ui_text);
    draw_text(center_x, current_y, hepo.effect);
    current_y += 25;
    
    // Эффекты рангов
    if (hepo.rank > 0) {
        draw_set_color(ui_highlight);
        draw_text(center_x, current_y, "✨ Эффекты рангов:");
        current_y += 20;
        
        draw_set_color(ui_text);
        draw_set_font(fnt_small);
        
        for (var i = 0; i <= hepo.rank; i++) {
            if (i < array_length(hepo.rank_effects)) {
                draw_text(center_x, current_y, "• " + hepo.rank_effects[i]);
                current_y += 16;
            }
        }
        
        draw_set_font(fnt_main);
    }
    
    // Информация о тренировке
    if (hepo.training) {
        current_y += 10;
        draw_set_color(ui_success_color);
        draw_text(center_x, current_y, "⚡ На тренировке: " + string(floor(hepo.training_progress)) + " опыта");
    }
    
    draw_set_halign(fa_left);
}

function draw_character_stats_section(x, y, width, height) {
    draw_modern_panel(x, y, width, height, false);
    
    var current_y = y + 15;
    
    // Заголовок с иконкой
    draw_set_color(ui_highlight);
    draw_text(x + 5, current_y - 5, "⭐ ОСНОВНЫЕ ХАРАКТЕРИСТИКИ");
    current_y += 25;
    
    // Полоска здоровья
    var health_percent = global.hero.health / global.hero.max_health;
    var health_width = width - 25;
    
    // Фон полоски здоровья
    draw_set_color(ui_bg_dark);
    draw_rectangle(x + 10, current_y, x + 10 + health_width, current_y + 20, false);
    
    // Заполнение с градиентом
    for (var i = 0; i < health_width * health_percent; i++) {
        var color_ratio = i / health_width;
        var r = lerp(255, 86, color_ratio);
        var g = lerp(100, 213, color_ratio);
        var b = lerp(100, 150, color_ratio);
        draw_set_color(make_color_rgb(r, g, b));
        draw_rectangle(x + 10 + i, current_y, x + 10 + i + 1, current_y + 20, false);
    }
    
    draw_set_color(ui_border_color);
    draw_rectangle(x + 10, current_y, x + 10 + health_width, current_y + 20, true);
    
    // Текст здоровья
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(x + 10 + health_width/2, current_y + 3, "❤️ " + string(floor(global.hero.health)) + "/" + string(global.hero.max_health));
    draw_set_halign(fa_left);
    current_y += 35;
    
    // Основные характеристики
    var stats = [
        "🎯 Уровень: " + string(global.hero.level),
        "📈 Опыт: " + string(global.hero.exp) + "/" + string(global.hero.exp_to_level),
        "🔧 Очки навыков: " + string(global.hero.skill_points),
        "💪 Сила: " + string(global.hero.strength),
        "⚡ Ловкость: " + string(global.hero.agility),
        "🧠 Интеллект: " + string(global.hero.intelligence)
    ];
    
    // Увеличиваем отступ между строками
    for (var i = 0; i < array_length(stats); i++) {
        draw_set_color(ui_text);
        draw_text(x + 5, current_y - 5, stats[i]);
        current_y += 25;
    }
    
    // Бонусы от экипировки
    current_y += 10;
    draw_set_color(c_yellow);
    draw_text(x, current_y - 10, "🛡️ БОНУСЫ ОТ ЭКИПИРОВКИ");
    draw_set_color(c_ltgray);
    current_y += 25;
    
    var bonuses = [];
    if (global.hero.equipment_bonuses.strength > 0) {
        array_push(bonuses, "💪 +" + string(global.hero.equipment_bonuses.strength) + " силы");
    }
    if (global.hero.equipment_bonuses.defense > 0) {
        array_push(bonuses, "🛡️ +" + string(global.hero.equipment_bonuses.defense) + " защиты");
    }
    if (global.hero.equipment_bonuses.intelligence > 0) {
        array_push(bonuses, "🧠 +" + string(global.hero.equipment_bonuses.intelligence) + " интеллекта");
    }
    
    if (array_length(bonuses) > 0) {
        for (var i = 0; i < array_length(bonuses); i++) {
            draw_text(x + 5, current_y - 10, bonuses[i]);
            current_y += 20;
        }
    } else {
        draw_set_color(ui_text_secondary);
        draw_text(x + 5, current_y - 10, "Нет бонусов от экипировки");
        current_y += 20;
    }
}

function draw_combat_stats_section(x, y, width, height) {
    draw_modern_panel(x, y, width, height, false);
    
    var current_y = y + 15;
    
    // Боевые характеристики
    draw_set_color(c_yellow);
    draw_text(x, current_y - 2, "⚔️ БОЕВЫЕ ХАРАКТЕРИСТИКИ");
    draw_set_color(c_white);
    current_y += 25;
    
    var total_attack = global.hero.strength + global.hero.equipment_bonuses.strength;
    var total_defense = global.hero.equipment_bonuses.defense;
    
    var combat_stats = [
        "⚔️ Атака: " + string(total_attack),
        "🛡️ Защита: " + string(total_defense),
        "❤️ Макс. здоровье: " + string(global.hero.max_health),
        "🎯 Шанс успеха: " + string(round(calculate_success_chance(0))) + "%"
    ];
    
    for (var i = 0; i < array_length(combat_stats); i++) {
        draw_text(x, current_y, combat_stats[i]);
        current_y += 22;
    }
    // ВРЕМЕННЫЕ БАФЫ - ДОБАВЛЯЕМ ЭТУ СЕКЦИЮ
    if (variable_global_exists("temp_buffs") && array_length(global.temp_buffs) > 0) {
        current_y += 10;
        draw_set_color(ui_highlight);
        draw_text(x, current_y, "⏱️ ВРЕМЕННЫЕ БАФЫ:");
        draw_set_color(ui_text);
        current_y += 20;
        
        for (var i = 0; i < min(array_length(global.temp_buffs), 3); i++) {
            var buff = global.temp_buffs[i];
            var time_left = buff.duration - (global.frame_count - buff.start_time);
            var seconds_left = ceil(time_left / 60);
            
            draw_set_color(buff.color);
            draw_text(x + 5, current_y, buff.icon + " " + string_copy(buff.name, 1, 12));
            
            draw_set_color(ui_text_secondary);
            draw_set_halign(fa_right);
            draw_text(x + width - 25, current_y, string(seconds_left) + "с");
            draw_set_halign(fa_left);
            
            current_y += 16;
        }
    }
    // Бонусы помощниц
    current_y += 10;
    draw_set_color(ui_highlight);
    draw_text(x, current_y, "👥 БОНУСЫ ПОМОЩНИЦ");
    draw_set_color(ui_text);
    current_y += 25;
    
    var companion_bonuses = get_active_companion_bonuses();
    var companion_stats = [];
    
    if (companion_bonuses.success_chance > 0) {
        array_push(companion_stats, "🎯 +" + string(floor(companion_bonuses.success_chance)) + "% к успеху");
    }
    if (companion_bonuses.health > 0) {
        array_push(companion_stats, "❤️ +" + string(floor(companion_bonuses.health)) + "% к здоровью");
    }
    if (companion_bonuses.gold > 0) {
        array_push(companion_stats, "💰 +" + string(floor(companion_bonuses.gold)) + "% к золоту");
    }
    
    if (array_length(companion_stats) > 0) {
        for (var i = 0; i < array_length(companion_stats); i++) {
            draw_text(x + 5, current_y - 10, companion_stats[i]);
            current_y += 20;
        }
    } else {
        draw_set_color(ui_text_secondary);
        draw_text(x + 5, current_y - 10, "Нет активных помощниц");
        current_y += 20;
    }

    // Секция активных бафов в правой колонке
    current_y += 10;
    draw_set_color(ui_highlight);
    draw_text(x, current_y - 10, "✨ АКТИВНЫЕ БАФЫ");
    draw_set_color(ui_text);
    current_y += 25;

    if (array_length(global.active_buffs) > 0) {
        for (var i = 0; i < min(array_length(global.active_buffs), 3); i++) {
            var buff = global.active_buffs[i];
            var display_value = get_buff_display_text(buff);
            var buff_color = get_buff_color(buff);
            
            // Компактное отображение
            draw_set_color(buff_color);
            draw_text(x + 5, current_y - 10, buff.icon + " " + string_copy(buff.name, 1, 12));
            
            draw_set_color(ui_success_color);
            draw_set_halign(fa_right);
            draw_text(x + width - 25, current_y - 10, display_value);
            draw_set_halign(fa_left);
            
            current_y += 18;
        }
    } else {
        draw_set_color(ui_text_secondary);
        draw_text(x + 5, current_y - 10, "Нет активных бафов");
        current_y += 18;
    }
}

// scr_draw_tabs.gml - обновленная функция draw_inventory_tab и связанные функции

function draw_inventory_tab(x, y, width, height) {
    // НА АРЕНЕ HEPO: автоматически выбираем Hepo для экипировки
    if (room == room_hepo_arena) {
        global.selected_hero_index = 1; // 1 = Hepo (0=герой, 1=Hepo, 2=Fatty, 3=Discipline)
    }
    
    draw_set_color(ui_text);
    draw_text(x, y, "ИНВЕНТАРЬ"); 

    // Разделяем на левую часть (экипировка) и правую (инвентарь)
    var left_width = width * 0.4; 
    var right_width = width * 0.6;
    var right_x = x + left_width + 10;
    
    // Левая часть - экипировка
    draw_equipment_section(x, y + 30, left_width, height - 30);
    
    // Правая часть - инвентарь в виде карточек
    draw_inventory_cards(right_x, y + 30, right_width, height - 30);
}

// Обновленная функция draw_inventory_cards
function draw_inventory_cards(x, y, width, height) {
    // Проверяем границы
    if (x + width > global.screen_width) width = global.screen_width - x - 10;
    if (y + height > global.screen_height) height = global.screen_height - y - 10;
    
    draw_set_color(ui_bg_medium);
    
    draw_set_color(ui_text);
    draw_text(x + 10, y + 10, "ПРЕДМЕТЫ В ИНВЕНТАРЕ");
    
    // Карточки предметов - проверяем минимальный размер
    var cards_per_row = 3;
    var card_width = floor((width - 40) / cards_per_row);
    var card_height = 120;
    
    // ОГРАНИЧИВАЕМ минимальный размер карточки
    card_width = max(card_width, 80);
    card_height = max(card_height, 100);
    
    var start_x = x + 10;
    var start_y = y + 40;
    
    var total_items = ds_list_size(global.playerInventory);
    var rows = ceil(total_items / cards_per_row);
    var total_content_height = rows * (card_height + 10);
    var visible_height = height - 50;
    
    // Рассчитываем максимальную прокрутку
    global.inv_max_scroll = max(0, total_content_height - visible_height);
    global.inv_scroll_offset = clamp(global.inv_scroll_offset, 0, global.inv_max_scroll);
    
    global.inv_buttons = []; // Очищаем кнопки инвентаря
    
    // Отрисовка карточек предметов
    for (var i = 0; i < total_items; i++) {
        var column = i mod cards_per_row;
        var row = i div cards_per_row;
        
        var card_x = start_x + column * (card_width + 10);
        var card_y = start_y + row * (card_height + 10) - global.inv_scroll_offset;
        
        // Проверяем, находится ли карточка в видимой области
        if (card_y + card_height < y || card_y > y + height) {
            continue; // Пропускаем невидимые карточки
        }
        
        var item_data = ds_list_find_value(global.playerInventory, i);
        if (!is_undefined(item_data)) {
            var is_hovered = point_in_rectangle(mouse_x, mouse_y, card_x, card_y, card_x + card_width, card_y + card_height);
            draw_inventory_card(card_x, card_y, card_width, card_height, item_data, i, is_hovered);
        }
    }
    
    // Отрисовка ползунка прокрутки, если контент не помещается
    if (global.inv_max_scroll > 0) {
        draw_inventory_scrollbar(x, y, width, height, total_content_height, visible_height);
    } else {
        global.inv_scrollbar_rect = -1;
    }
    
    // Информация о пустом инвентаре
    if (total_items == 0) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_center);
        draw_text(x + width/2, y + height/2, "Инвентарь пуст\nКупите предметы в магазине");
        draw_set_halign(fa_left);
    }
}

// scr_draw_tabs.gml - обновленная функция draw_inventory_card

function draw_inventory_card(x, y, width, height, item_data, index, is_hovered) {
    // Проверяем, что item_data не undefined
    if (is_undefined(item_data)) {
        return;
    }
    
    var item_id = item_data[? "id"];
    var db_data = ds_map_find_value(global.ItemDB, item_id);
    
    if (db_data == -1) return;
    
    var rarity = db_data[? "rarity"];
    var rarity_color = get_rarity_color(rarity);
    var quantity = item_data[? "quantity"];
    var item_type = db_data[? "type"];
    var equip_slot = db_data[? "equip_slot"];
    var can_equip = (equip_slot != -1); // Предмет можно экипировать
    var can_use = (item_type == global.ITEM_TYPE.POTION || item_type == global.ITEM_TYPE.SCROLL); // Предмет можно использовать
    
    // Фон карточки с эффектом наведения
    var card_bg_color = is_hovered ? merge_color(ui_bg_medium, c_white, 0.1) : ui_bg_medium;
    draw_set_color(card_bg_color);
    draw_rectangle(x, y, x + width, y + height, false);
    
    // Верхняя полоса редкости
    var stripe_color = is_hovered ? merge_color(rarity_color, c_white, 0.2) : rarity_color;
    draw_set_color(stripe_color);
    draw_rectangle(x, y, x + width, y + 3, false);
    
    // Рамка карточки с эффектом наведения
    var border_color = is_hovered ? merge_color(ui_border_color, c_white, 0.3) : ui_border_color;
    draw_set_color(border_color);
    draw_rectangle(x, y, x + width, y + height, true);
    
    // Иконка типа предмета
    var icon_x = x + 8;
    var icon_y = y + 8;
    draw_item_type_icon_simple(icon_x, icon_y, item_type, is_hovered);
    
    // Название предмета (обрезаем если длинное)
    var name = string_copy(db_data[? "name"], 1, 12);
    if (string_length(db_data[? "name"]) > 12) name += "...";
    
    var name_color = is_hovered ? merge_color(ui_text, c_white, 0.2) : ui_text;
    draw_set_color(name_color);
    draw_set_font(fnt_main);
    draw_text(x + 25, y + 10, name);
    
    // Индикатор возможности экипировки/использования
    if (is_hovered) {
        draw_set_color(ui_highlight);
        draw_set_halign(fa_center);
        if (can_equip) {
            draw_text(x + width/2, y + 25, "👆 ЛКМ - экипировать");
        } else if (can_use) {
            draw_text(x + width/2, y + 25, "👆 ЛКМ - использовать");
        }
        draw_set_halign(fa_left);
    }
    
    // Количество предметов (для стакающихся)
    if (quantity > 1) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_right);
        draw_text(x + width - 8, y + 10, "x" + string(quantity));
        draw_set_halign(fa_left);
    }
    
    // Разделительная линия
    draw_set_color(is_hovered ? merge_color(ui_border_color, c_white, 0.1) : ui_border_color);
    draw_rectangle(x + 5, y + 30, x + width - 5, y + 31, false);
    
    // Бонусы предмета в компактном формате
    var bonus_y = y + 40;
    var bonuses = [];
    
    if (db_data[? "strength_bonus"] > 0) {
        array_push(bonuses, "💪 +" + string(db_data[? "strength_bonus"]));
    }
    if (db_data[? "defense_bonus"] > 0) {
        array_push(bonuses, "🛡️ +" + string(db_data[? "defense_bonus"]));
    }
    if (db_data[? "intelligence_bonus"] > 0) {
        array_push(bonuses, "🧠 +" + string(db_data[? "intelligence_bonus"]));
    }
    if (db_data[? "agility_bonus"] > 0) {
        array_push(bonuses, "⚡ +" + string(db_data[? "agility_bonus"]));
    }
    
    // Для зелий показываем эффекты
    if (item_type == global.ITEM_TYPE.POTION) {
        if (db_data[? "health"] > 0) {
            array_push(bonuses, "❤️ +" + string(db_data[? "health"]));
        }
        if (db_data[? "temp_strength"] > 0) {
            array_push(bonuses, "💪 +" + string(db_data[? "temp_strength"]));
        }
    }
    
    // Для свитков показываем эффекты
    if (item_type == global.ITEM_TYPE.SCROLL) {
        if (db_data[? "instant_complete"] == true) {
            array_push(bonuses, "⚡ Мгновенное завершение");
        }
        if (db_data[? "reward_multiplier"] > 0) {
            array_push(bonuses, "💰 x" + string(db_data[? "reward_multiplier"]) + " награда");
        }
    }
    
    // Отрисовываем бонусы
    if (array_length(bonuses) > 0) {
        draw_set_color(ui_text);
        draw_set_font(fnt_main);
        
        for (var i = 0; i < min(array_length(bonuses), 2); i++) {
            var bonus_text = bonuses[i];
            if (string_length(bonus_text) > 15) {
                bonus_text = string_copy(bonus_text, 1, 12) + "...";
            }
            draw_text(x + 8, bonus_y + i * 15, bonus_text);
        }
    }
    
    // Цена продажи
    var sell_price = get_sell_price(item_id, 1);
    if (sell_price > 0) {
        draw_set_color(ui_text_secondary);
        draw_set_font(fnt_small);
        draw_set_halign(fa_center);
        draw_text(x + width/2, y + height, "Продажа: " + string(sell_price) + "g");
        draw_set_halign(fa_left);
        draw_set_font(fnt_main);
    }
    
    // Кнопки действий
    var action_y = y + height - 35;
    var action_height = 20;
    var button_width = width - 20;
    
    // Кнопка продажи
    var is_sell_hovered = point_in_rectangle(mouse_x, mouse_y, x + 10, action_y, x + 10 + button_width, action_y + action_height);
    var sell_btn_color = is_sell_hovered ? merge_color(ui_warning_color, c_white, 0.2) : ui_warning_color;
    
    draw_set_color(sell_btn_color);
    draw_rectangle(x + 10, action_y, x + 10 + button_width, action_y + action_height, false);
    
    draw_set_color(ui_border_color);
    draw_rectangle(x + 10, action_y, x + 10 + button_width, action_y + action_height, true);
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    //draw_text(x + 10 + button_width/2, action_y + action_height/2, "💰 Продать за " + string(sell_price) + "g");
    draw_set_halign(fa_left);
    
    // Добавляем кнопки в массив для обработки кликов
    
    // Кнопка продажи
    array_push(global.inv_buttons, {
        type: "inventory_sell",
        cell_index: index,
        x1: x + 10, y1: action_y,
        x2: x + 10 + button_width, y2: action_y + action_height
    });
    
    // Кнопка экипировки или использования (вся карточка, кроме кнопки продажи)
    if (can_equip) {
        array_push(global.inv_buttons, {
            type: "inventory_equip",
            cell_index: index,
            x1: x, y1: y,
            x2: x + width, y2: action_y - 5 // Исключаем область кнопки продажи
        });
    } else if (can_use) {
        array_push(global.inv_buttons, {
            type: "inventory_use",
            cell_index: index,
            x1: x, y1: y,
            x2: x + width, y2: action_y - 5 // Исключаем область кнопки продажи
        });
    }
    
    // Также добавляем кнопку для всей карточки для быстрой продажи по правому клику
    array_push(global.inv_buttons, {
        type: "inventory_card_quick_sell",
        cell_index: index,
        x1: x, y1: y,
        x2: x + width, y2: y + height
    });
}
// Новая функция для экипировки предмета из инвентаря
function equip_item_from_inventory(cell_index) {
    show_debug_message("=== ЭКИПИРОВКА ПРЕДМЕТА ИЗ ИНВЕНТАРЯ ===");
    
    // Проверяем существование инвентаря
    if (!variable_global_exists("playerInventory") || !ds_exists(global.playerInventory, ds_type_list)) {
        show_debug_message("Ошибка: Инвентарь не инициализирован!");
        return false;
    }
    
    // Проверяем корректность индекса
    if (cell_index < 0 || cell_index >= ds_list_size(global.playerInventory)) {
        show_debug_message("Ошибка: Неверный индекс предмета: " + string(cell_index));
        return false;
    }
    
    // Получаем данные предмета из инвентаря
    var item_data = ds_list_find_value(global.playerInventory, cell_index);
    if (is_undefined(item_data)) {
        show_debug_message("Ошибка: Данные предмета не найдены!");
        return false;
    }
    
    var item_id = item_data[? "id"];
    
    // Проверяем существование базы данных предметов
    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        show_debug_message("Ошибка: База данных предметов не инициализирована!");
        return false;
    }
    
    // Получаем полные данные предмета из базы
    var db_data = ds_map_find_value(global.ItemDB, item_id);
    if (db_data == -1) {
        show_debug_message("Ошибка: Предмет с ID " + string(item_id) + " не найден в базе данных!");
        return false;
    }
    
    // Проверяем возможность экипировки
    var equip_slot = db_data[? "equip_slot"];
    if (equip_slot == -1) {
        add_notification("Этот предмет нельзя экипировать!");
        return false;
    }
    
    // Определяем тип слота для экипировки
    var slot_type = "";
    switch(equip_slot) {
        case global.EQUIP_SLOT.WEAPON: 
            slot_type = "weapon"; 
            break;
        case global.EQUIP_SLOT.ARMOR: 
            slot_type = "armor"; 
            break;
        case global.EQUIP_SLOT.ACCESSORY: 
            slot_type = "accessory"; 
            break;
        case global.EQUIP_SLOT.RELIC: 
            slot_type = "relic"; 
            break;
        default:
            add_notification("Неизвестный тип слота для экипировки!");
            return false;
    }
    
    show_debug_message("Экипировка предмета в слот: " + slot_type + " для героя: " + string(global.selected_hero_index));
    
    // Вызываем основную функцию экипировки
    var success = EquipItem(cell_index, global.selected_hero_index, slot_type);
    
    if (success) {
        add_notification("Предмет экипирован на " + get_hero_name(global.selected_hero_index));
    } else {
        add_notification("Не удалось экипировать предмет!");
    }
    
    return success;
}

// scr_draw_tabs.gml - убедитесь, что эта функция существует

function get_hero_name(hero_index) {
    switch(hero_index) {
        case 0: return "Главного героя";
        case 1: return "Hepo";
        case 2: return "Fatty"; 
        case 3: return "Discipline";
        default: return "Неизвестного героя";
    }
}
function draw_inventory_scrollbar(x, y, width, height, total_content_height, visible_height) {
    var scrollbar_width = 8;
    var scrollbar_x = x + width - scrollbar_width - 5;
    var scrollbar_track_height = visible_height;
    var track_y = y + 40;
    
    // Вычисляем размер и позицию ползунка
    var scrollbar_height = max(30, visible_height * (visible_height / total_content_height));
    var scroll_ratio = global.inv_scroll_offset / global.inv_max_scroll;
    var scrollbar_y = track_y + scroll_ratio * (visible_height - scrollbar_height);
    
    // Фон ползунка (трек)
    draw_set_color(make_color_rgb(60, 60, 80));
    draw_rectangle(scrollbar_x, track_y, scrollbar_x + scrollbar_width, track_y + scrollbar_track_height, false);
    
    // Ползунок
    var slider_color = global.inv_scroll_dragging ? merge_color(ui_highlight, c_white, 0.3) : ui_highlight;
    draw_set_color(slider_color);
    draw_rectangle(scrollbar_x, scrollbar_y, scrollbar_x + scrollbar_width, scrollbar_y + scrollbar_height, false);
    
    // Сохраняем данные ползунка для обработки кликов
    global.inv_scrollbar_rect = {
        x1: scrollbar_x, 
        y1: scrollbar_y, 
        x2: scrollbar_x + scrollbar_width, 
        y2: scrollbar_y + scrollbar_height,
        track_y1: track_y,
        track_y2: track_y + scrollbar_track_height
    };
}
// scr_draw_tabs.gml - исправленная функция draw_equipment_section

function draw_equipment_section(x, y, width, height) {
    draw_set_color(ui_bg_medium);
    //draw_rectangle(x, y, x + width, y + height, false);
    
    draw_set_color(ui_text);
    draw_text(x + 10, y + 10, "ЭКИПИРОВКА");
    
    // Определяем вкладки героев в зависимости от комнаты
    var tab_names;
    var tab_width;
    
    // НА АРЕНЕ HEPO: показываем только вкладку Hepo
    if (room == room_hepo_arena) {
        tab_names = ["Hepo"];
        tab_width = width;
        // Гарантируем, что выбран Hepo
        global.selected_hero_index = 1;
    } else {
        // В основной комнате - все герои
        tab_names = ["Герой", "Hepo", "Fatty", "Discipline"];
        tab_width = width / array_length(tab_names);
    }
    
    var tab_height = 25;
    
    // Отрисовываем вкладки героев
    for (var i = 0; i < array_length(tab_names); i++) {
        var tab_x = x + i * tab_width;
        var is_active = (i == global.selected_hero_index);
        var is_hovered = point_in_rectangle(mouse_x, mouse_y, tab_x, y + 40, tab_x + tab_width, y + 40 + tab_height);
        
        // Цвет вкладки (активная/неактивная) с эффектом наведения
        var tab_color = is_active ? ui_highlight : (is_hovered ? ui_bg_accent : ui_bg_dark);
        
        draw_set_color(tab_color);
        draw_rectangle(tab_x, y + 40, tab_x + tab_width, y + 40 + tab_height, false);
        
        // Рамка вкладки
        draw_set_color(is_active ? ui_highlight : ui_border_color);
        draw_rectangle(tab_x, y + 40, tab_x + tab_width, y + 40 + tab_height, true);
        
        // Текст вкладки
        draw_set_color(is_active ? c_white : ui_text);
        draw_set_halign(fa_center);
        draw_text(tab_x + tab_width/2, y + 40 + tab_height/2 - 5, tab_names[i]);
        draw_set_halign(fa_left);
        
        // Добавляем кнопку вкладки для обработки кликов (только если не на арене Hepo)
        if (room != room_hepo_arena) {
            array_push(global.inv_buttons, {
                type: "hero_tab",
                index: i,
                x1: tab_x, y1: y + 40,
                x2: tab_x + tab_width, y2: y + 40 + tab_height
            });
        }
    }
    
    // Слоты экипировки для выбранного персонажа - ГОРИЗОНТАЛЬНОЕ РАСПОЛОЖЕНИЕ
    var slots_y = y + 40 + tab_height + 20;
    var slot_size = 60;
    
    // Определяем слоты для выбранного персонажа
    var slots = [];
    if (global.selected_hero_index == 0) {
        // Главный герой: оружие, броня, аксессуар, реликвия
        var total_slots_width = slot_size * 3 + 20 * 2;
        var start_x = x + (width - total_slots_width) / 2;
        
        slots = [
            { type: "weapon", name: "Оружие", x: start_x, y: slots_y },
            { type: "armor", name: "Броня", x: start_x, y: slots_y + slot_size + 30 },
            { type: "accessory", name: "Аксессуар", x: start_x + (slot_size + 9) * 2.5, y: slots_y },
            { type: "relic", name: "Реликвия", x: start_x + (slot_size + 9) * 2.5, y: slots_y + slot_size + 30 }
        ];
    } else {
        // Помощницы: оружие и броня
        var total_slots_width = slot_size * 2 + 10;
        var start_x = x + (width - total_slots_width) / 2;
        
        slots = [
            { type: "weapon", name: "Оружие", x: start_x - 35, y: slots_y },
            { type: "armor", name: "Броня", x: start_x + slot_size + 60, y: slots_y },
            { type: "accessory", name: "Аксессуар", x: start_x - 50 + slot_size + 30, y: slots_y + 120 }
        ];
    }
    
    // Отрисовка слотов
    for (var i = 0; i < array_length(slots); i++) {
        var slot = slots[i];
        
        // Проверяем, есть ли предмет в слоте
        var item_id = variable_struct_get(global.equipment_slots[global.selected_hero_index], slot.type);
        var is_slot_filled = (item_id != -1);
        var is_hovered = point_in_rectangle(mouse_x, mouse_y, slot.x, slot.y, slot.x + slot_size, slot.y + slot_size);
        
        // Цвет слота (заполненный/пустой) с эффектом наведения
        var slot_color = is_slot_filled ? 
            (is_hovered ? merge_color(ui_success_color, c_white, 0.2) : ui_success_color) : 
            (is_hovered ? merge_color(ui_bg_dark, c_white, 0.1) : ui_bg_dark);
        
        // Фон слота
        draw_set_color(slot_color);
        draw_rectangle(slot.x, slot.y, slot.x + slot_size, slot.y + slot_size, false);
        
        // Рамка слота
        var border_color = is_hovered ? merge_color(ui_border_color, c_white, 0.2) : ui_border_color;
        draw_set_color(border_color);
        draw_rectangle(slot.x, slot.y, slot.x + slot_size, slot.y + slot_size, true);
        
        // Название слота под слотом
        draw_set_color(ui_text);
        draw_set_halign(fa_center);
        draw_text(slot.x + slot_size/2, slot.y + slot_size + 5, slot.name);
        draw_set_halign(fa_left);
        
        // Если в слоте есть предмет, отображаем его
        if (is_slot_filled) {
            var item_data = ds_map_find_value(global.ItemDB, item_id);
            if (item_data != -1) {
                // Сокращенное название (максимум 2 строки)
                var item_name = item_data[? "name"];
                var max_chars_per_line = 8;
                
                // Разбиваем название на две строки если нужно
                if (string_length(item_name) > max_chars_per_line) {
                    var first_line = string_copy(item_name, 1, max_chars_per_line);
                    var second_line = string_copy(item_name, max_chars_per_line + 1, max_chars_per_line);
                    if (string_length(second_line) > max_chars_per_line - 2) {
                        second_line = string_copy(second_line, 1, max_chars_per_line - 2) + "..";
                    }
                    item_name = first_line + "\n" + second_line;
                }
                
                draw_set_color(ui_text);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(slot.x + slot_size/2, slot.y + slot_size/2 - 8, item_name);
                
                // Бонусы предмета (компактно внизу)
                var bonus_text = "";
                if (item_data[? "strength_bonus"] > 0) {
                    bonus_text += "S:" + string(item_data[? "strength_bonus"]) + " ";
                }
                if (item_data[? "defense_bonus"] > 0) {
                    bonus_text += "D:" + string(item_data[? "defense_bonus"]) + " ";
                }
                if (item_data[? "intelligence_bonus"] > 0) {
                    bonus_text += "I:" + string(item_data[? "intelligence_bonus"]);
                }
                
                if (bonus_text != "") {
                    draw_set_font(fnt_small);
                    draw_text(slot.x + slot_size/2, slot.y + slot_size - 15, bonus_text);
                    draw_set_font(fnt_main);
                }
                
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }
        } else {
            // Иконка пустого слота
            draw_set_color(ui_text_secondary);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(slot.x + slot_size/2, slot.y + slot_size/2, "+");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        
        // Добавляем кнопку слота для обработки кликов
        array_push(global.inv_buttons, {
            type: "equip_slot",
            hero_index: global.selected_hero_index,
            slot_type: slot.type,
            x1: slot.x, y1: slot.y,
            x2: slot.x + slot_size, y2: slot.y + slot_size
        });
    }
    
    // Информация о выбранном персонаже
    var info_y = slots_y + slot_size + 30;
    draw_set_color(ui_text_secondary);
    draw_set_halign(fa_center);
    
    var hero_name = "";
    switch(global.selected_hero_index) {
        case 0: hero_name = "Главный герой"; break;
        case 1: hero_name = "Hepo"; break;
        case 2: hero_name = "Fatty"; break;
        case 3: hero_name = "Discipline"; break;
    }
    
    //draw_text(x + width/2, info_y - 5, hero_name);
    
    // Показываем текущие бонусы от экипировки
    var bonus_info = "";
    if (global.hero.equipment_bonuses.strength > 0) {
        bonus_info += "Сила: +" + string(global.hero.equipment_bonuses.strength) + " ";
    }
    if (global.hero.equipment_bonuses.defense > 0) {
        bonus_info += "Защита: +" + string(global.hero.equipment_bonuses.defense) + " ";
    }
    if (global.hero.equipment_bonuses.intelligence > 0) {
        bonus_info += "Интеллект: +" + string(global.hero.equipment_bonuses.intelligence);
    }
    
    if (bonus_info != "") {
        draw_set_font(fnt_small);
        draw_text(x + width/2, info_y + 115, bonus_info);
        draw_set_font(fnt_main);
    }
    
    draw_set_halign(fa_left);
}



function draw_shop_tab(x, y, width, height) {
    // Проверяем существование необходимых переменных
    if (!variable_global_exists("shop_buttons")) global.shop_buttons = [];
    if (!variable_global_exists("shop_page_buttons")) global.shop_page_buttons = [];
    
    // Очищаем кнопки магазина
    global.shop_buttons = [];
    global.shop_page_buttons = [];
    
    // Защитная проверка текущей категории
    if (global.shop_current_category < 0 || global.shop_current_category >= 5) {
        global.shop_current_category = 0;
    }
    
    // Фон магазина
    draw_set_color(ui_bg_medium);
   // draw_rectangle(x, y, x + width, y + height, false);
    
    // Рамка
    draw_set_color(ui_border_color);
    //draw_rectangle(x, y, x + width, y + height, true);
    
    // Заголовок магазина
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(x + width/2, y + 15, "🎮 YOUTH EMPORIUM");
    draw_set_halign(fa_left);
    
    // Информация о золоте
    draw_set_color(ui_text);
    draw_text(x + 10, y + 5, "💰 Золото: " + format_large_number(global.gold));
    
    // Вкладки категорий
    draw_shop_categories(x + 10, y + 50, width - 20, 40);
    
    // Контент магазина
    var content_y = y + 100;
    var content_height = height - 110;
    
    // Отрисовка предметов с пагинацией
    draw_shop_category_items(x + 10, content_y, width - 20, content_height);
}


function draw_companions_tab(x, y, width, height) {
    draw_set_color(ui_text);
    draw_text(x, y, "СИСТЕМА РАНГОВ ПОМОЩНИЦ");
    
    global.companion_rank_buttons = [];
    var companion_height = 110;
    var start_y = y + 30;
    var displayed_count = 0;
    
    for (var i = 0; i < array_length(global.companions); i++) {
        var companion = global.companions[i];
        
        // Показываем только разблокированных помощниц
        if (!companion.unlocked) {
            continue;
        }
        
        var companion_y = start_y + displayed_count * companion_height;
        displayed_count++;
        
        draw_set_color(ui_bg_medium);
        draw_rectangle(x, companion_y, x + width, companion_y + 110, false);
        
        // Цветная полоса
        draw_set_color(companion_colors[i]);
        draw_rectangle(x, companion_y, x + 5, companion_y + 110, false);
        
        // Информация о помощнице
        draw_set_color(ui_text);
        draw_text(x + 15, companion_y + 10, companion.name);
        draw_text(x + 15, companion_y + 30, "Уровень: " + string(companion.level));
        draw_text(x + 15, companion_y + 50, "Ранг: " + string(companion.rank) + "/" + string(companion.max_rank));
        
        // Эффект помощницы (учитывает текущий ранг)
        var current_rank_effect = "";
        if (companion.rank >= 0 && companion.rank < array_length(companion.rank_effects)) {
            current_rank_effect = companion.rank_effects[companion.rank];
        } else {
            // Если ранг вышел за границы, показываем последний доступный эффект
            var last_index = array_length(companion.rank_effects) - 1;
            current_rank_effect = companion.rank_effects[last_index];
        }
        draw_set_color(ui_text_secondary);
        draw_text(x + 15, companion_y + 70, current_rank_effect);
        
        // Прогресс до следующего ранга
        var progress = get_rank_progress(i);
        if (companion.rank < companion.max_rank) {
            draw_set_color(ui_text);
            draw_text(x + width - 200, companion_y + 10, "Следующий ранг: ур. " + string(progress.required));
            
            // Прогресс-бар уровня
            var bar_width = 150;
            var bar_x = x + width - 200;
            var bar_y = companion_y + 30;
            
            draw_set_color(ui_bg_dark);
            draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + 10, false);
            draw_set_color(ui_highlight);
            draw_rectangle(bar_x, bar_y, bar_x + bar_width * (progress.percent / 100), bar_y + 10, false);
            draw_set_color(ui_border_color);
            draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + 10, true);
            
            draw_set_color(ui_text);
            draw_text(bar_x + bar_width + 5, bar_y, string(progress.current) + "/" + string(progress.required));
            
            // Кнопка повышения ранга
            var btn_x = x + width - 200;
            var btn_y = companion_y + 50;
            var btn_width = 180;
            var btn_height = 25;
            
            var cost = get_rank_upgrade_cost(i);
            var can_afford = global.gold >= cost;
            var btn_color = can_afford ? ui_success_color : ui_danger;
            
            // Проверка наведения мыши
            var mouse_over = point_in_rectangle(mouse_x, mouse_y, btn_x, btn_y, btn_x + btn_width, btn_y + btn_height);
            if (mouse_over) {
                btn_color = merge_color(btn_color, c_white, 0.2);
            }
            
            // Фон кнопки
            draw_set_color(btn_color);
            draw_rectangle(btn_x, btn_y, btn_x + btn_width, btn_y + btn_height, false);
            
            // Рамка кнопки
            draw_set_color(ui_border_color);
            draw_rectangle(btn_x, btn_y, btn_x + btn_width, btn_y + btn_height, true);
            
            // Текст кнопки
            draw_set_color(ui_text);
            draw_set_halign(fa_center);
            draw_text(btn_x + btn_width/2, btn_y + btn_height/2, "Повысить ранг (" + string(cost) + "g)");
            draw_set_halign(fa_left);
            
            // Добавляем кнопку в массив
            array_push(global.companion_rank_buttons, {
                companion_index: i,
                x1: btn_x, y1: btn_y,
                x2: btn_x + btn_width, y2: btn_y + btn_height
            });
        } else {
            draw_set_color(ui_success_color);
            draw_text(x + width - 200, companion_y + 10, "Максимальный ранг достигнут!");
        }
        
        // Информация о следующем эффекте
        if (companion.rank < companion.max_rank) {
            var next_rank = companion.rank + 1;
            if (next_rank >= 0 && next_rank < array_length(companion.rank_effects)) {
                draw_set_color(ui_text_secondary);
                draw_text(x + 15, companion_y + 90, "Следующий ранг: " + companion.rank_effects[next_rank]);
            }
        }
    }
    
    // Если нет разблокированных помощниц
    if (displayed_count == 0) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_center);
        draw_text(x + width/2, y + height/2, "Помощницы будут разблокированы после прохождения экспедиций");
        draw_set_halign(fa_left);
    }
}
// scr_draw_tabs.gml - добавьте эту функцию

function handle_inventory_tab_click(mouse_x, mouse_y) {
    // Обработка кликов по вкладкам героев
    for (var i = 0; i < array_length(global.inv_buttons); i++) {
        var btn = global.inv_buttons[i];
        if (point_in_rectangle(mouse_x, mouse_y, btn.x1, btn.y1, btn.x2, btn.y2)) {
            switch (btn.type) {
                case "hero_tab":
                    global.selected_hero_index = btn.index;
                    add_notification("Выбран: " + get_hero_name(btn.index));
                    return true;
                    
                case "inventory_equip":
                    // Экипировка предмета
                    equip_item_from_inventory(btn.cell_index);
                    return true;
                    
                case "inventory_use":
                    // Использование предмета (зелья/свитки)
                    use_item_from_inventory(btn.cell_index);
                    return true;
                    
                case "inventory_sell":
                    // Продажа предмета
                    sell_item_direct(btn.cell_index, 1);
                    return true;
                    
                case "equip_slot":
                    // Снятие предмета с слота экипировки
                    unequip_item_from_slot(btn.hero_index, btn.slot_type);
                    return true;
            }
        }
    }
    return false;
}
