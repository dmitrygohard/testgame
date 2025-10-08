function draw_tabs_section(panel_y, panel_height) {
    var section_x = global.squad_width;
    var section_y = panel_y;
    var section_width = global.tabs_width;
    var section_height = panel_height;

    // Вкладки
    var tab_names = ["📊 Статистика", "🎒 Инвентарь", "🗺️ Экспедиции", "🛒 Магазин", "🏆 Трофеи", "✨ Способности"];
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
    draw_modern_panel(x, y, width, height);

    if (!variable_global_exists("inv_scroll_offset")) global.inv_scroll_offset = 0;
    if (!variable_global_exists("inv_scroll_dragging")) global.inv_scroll_dragging = false;

    global.inv_buttons = [];
    global.inventory_hover_tooltip = undefined;

    var margin = 12;
    var content_gap = 24;
    var min_equipment_width = 240;
    var max_equipment_width = max(min_equipment_width, width - 280);
    var equipment_width = clamp(floor(width * 0.32), min_equipment_width, max_equipment_width);
    var equipment_x = x + margin;
    var inventory_x = equipment_x + equipment_width + content_gap;
    var inventory_width = width - (equipment_width + content_gap + margin * 2);
    var panel_height = height - margin * 2;

    draw_equipment_section(equipment_x, y + margin, equipment_width, panel_height);
    draw_inventory_cards(inventory_x, y + margin, inventory_width, panel_height);

    draw_inventory_tooltip();
}

function draw_inventory_cards(x, y, width, height) {
    draw_set_color(ui_bg_dark);
    draw_rectangle(x, y, x + width, y + height, false);
    draw_set_color(ui_border_color);
    draw_rectangle(x, y, x + width, y + height, true);

    var padding = 16;
    var header_height = 32;

    draw_set_color(ui_text);
    draw_text(x + padding, y + 6, "Коллекция предметов");

    var total_items = ds_list_size(global.playerInventory);
    var cards_per_row = max(2, floor((width - padding * 2) / 190));
    var card_spacing = 14;
    var available_width = width - padding * 2 - card_spacing * (cards_per_row - 1);
    var card_width = floor(available_width / cards_per_row);
    card_width = clamp(card_width, 150, 220);
    var card_height = 118;

    var total_rows = ceil(total_items / cards_per_row);
    var content_height = total_rows * (card_height + card_spacing);
    var visible_height = height - header_height - padding;

    global.inv_max_scroll = max(0, content_height - visible_height);
    global.inv_scroll_offset = clamp(global.inv_scroll_offset, 0, global.inv_max_scroll);

    var start_x = x + padding;
    var start_y = y + header_height;

    for (var i = 0; i < total_items; i++) {
        var column = i mod cards_per_row;
        var row = i div cards_per_row;

        var card_x = start_x + column * (card_width + card_spacing);
        var card_y = start_y + row * (card_height + card_spacing) - global.inv_scroll_offset;

        if (card_y + card_height < y + header_height - 4 || card_y > y + height) {
            continue;
        }

        var item_data = ds_list_find_value(global.playerInventory, i);
        if (!is_undefined(item_data)) {
            var is_hovered = point_in_rectangle(mouse_x, mouse_y, card_x, card_y, card_x + card_width, card_y + card_height);
            draw_inventory_card(card_x, card_y, card_width, card_height, item_data, i, is_hovered);
        }
    }

    if (global.inv_max_scroll > 0) {
        draw_inventory_scrollbar(x, y, width, height, content_height, visible_height, header_height);
    } else {
        global.inv_scrollbar_rect = -1;
    }

    if (total_items == 0) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_center);
        draw_text(x + width/2, y + height/2, "Инвентарь пуст. Загляните в магазин или на экспедиции");
        draw_set_halign(fa_left);
    }
}

function draw_inventory_card(x, y, width, height, item_data, index, is_hovered) {
    if (is_undefined(item_data)) return;

    var item_id = item_data[? "id"];
    var db_data = ds_map_find_value(global.ItemDB, item_id);
    if (db_data == -1) return;

    var rarity_color = inventory_get_rarity_color(db_data[? "rarity"]);
    var left_color = merge_color(rarity_color, ui_bg_dark, 0.6);
    var right_color = merge_color(rarity_color, c_white, 0.1);
    var border_color = is_hovered ? merge_color(rarity_color, c_white, 0.35) : merge_color(rarity_color, ui_border_color, 0.25);

    draw_rectangle_color(x, y, x + width, y + height, left_color, right_color, left_color, right_color, left_color);
    draw_set_color(border_color);
    draw_rectangle(x, y, x + width, y + height, true);

    var icon_text = inventory_get_item_icon(db_data);
    var icon_radius = 24;
    var icon_cx = x + 28;
    var icon_cy = y + 32;

    draw_set_color(merge_color(rarity_color, c_white, 0.25));
    draw_circle(icon_cx, icon_cy, icon_radius, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(icon_cx, icon_cy - 4, icon_text);
    draw_set_valign(fa_top);

    var name_x = x + 60;
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    var name_text = string_copy(db_data[? "name"], 1, 24);
    if (string_length(db_data[? "name"]) > 24) name_text += "…";
    draw_text(name_x, y + 6, name_text);

    var quantity = item_data[? "quantity"];
    if (quantity > 1) {
        draw_set_color(ui_highlight);
        draw_set_halign(fa_right);
        draw_text(x + width - 8, y + 6, "x" + string(quantity));
        draw_set_halign(fa_left);
    }

    draw_set_color(ui_text_secondary);
    draw_text(name_x, y + 24, inventory_get_item_tag(db_data));

    if (is_hovered) {
        inventory_register_tooltip(item_id, quantity, "inventory");
    }

    var stat_segments = inventory_collect_item_stats(db_data);

    draw_set_font(fnt_small);
    if (array_length(stat_segments) > 0) {
        draw_text(name_x, y + 42, array_join(stat_segments, "   "));
    } else {
        var desc = string_copy(db_data[? "description"], 1, 52);
        if (string_length(db_data[? "description"]) > 52) desc += "...";
        draw_text(name_x, y + 42, desc);
    }
    draw_set_font(fnt_main);

    var set_progress_text = inventory_get_set_progress_text(item_id, db_data);
    if (set_progress_text != "") {
        draw_set_font(fnt_small);
        draw_set_color(ui_text_secondary);
        draw_text(name_x, y + height - 48, set_progress_text);
        draw_set_font(fnt_main);
    }

    var button_defs = [];
    var item_type = db_data[? "type"];
    var equip_slot = db_data[? "equip_slot"];
    var item_class = db_data[? "item_class"];
    var can_equip = (equip_slot != -1);
    var can_use = (item_type == global.ITEM_TYPE.POTION || item_type == global.ITEM_TYPE.SCROLL);
    var can_sell = (item_class != "trophy");

    if (can_equip) array_push(button_defs, { label: "Экипировать", type: "inventory_equip" });
    if (can_use) array_push(button_defs, { label: "Использовать", type: "inventory_use" });
    if (can_sell) array_push(button_defs, { label: "Продать", type: "inventory_sell" });

    var button_count = array_length(button_defs);
    if (button_count > 0) {
        var button_area_y = y + height - 30;
        var button_gap = 8;
        var button_width = (width - 20 - button_gap * (button_count - 1));
        if (button_count > 0) button_width = button_width / button_count;
        var button_x = x + 10;

        for (var b = 0; b < button_count; b++) {
            var btn = button_defs[b];
            var bx1 = button_x + b * (button_width + button_gap);
            var bx2 = bx1 + button_width;
            var by1 = button_area_y;
            var by2 = button_area_y + 22;

            var active_color = btn.type == "inventory_sell" ? ui_danger : ui_highlight;
            draw_set_color(merge_color(active_color, c_white, 0.15));
            draw_rectangle(bx1, by1, bx2, by2, false);
            draw_set_color(border_color);
            draw_rectangle(bx1, by1, bx2, by2, true);
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_text((bx1 + bx2) / 2, by1 + 4, btn.label);
            draw_set_halign(fa_left);

            array_push(global.inv_buttons, {
                type: btn.type,
                cell_index: index,
                x1: bx1, y1: by1,
                x2: bx2, y2: by2
            });
        }
    }

    if (can_sell) {
        array_push(global.inv_buttons, {
            type: "inventory_card_quick_sell",
            cell_index: index,
            x1: x, y1: y,
            x2: x + width, y2: y + height
        });
    }
}

function equip_item_from_inventory(cell_index) {
    show_debug_message("=== ЭКИПИРОВКА ПРЕДМЕТА ИЗ ИНВЕНТАРЯ ===");

    if (!variable_global_exists("playerInventory") || !ds_exists(global.playerInventory, ds_type_list)) {
        show_debug_message("Ошибка: Инвентарь не инициализирован!");
        return false;
    }

    if (cell_index < 0 || cell_index >= ds_list_size(global.playerInventory)) {
        show_debug_message("Ошибка: Неверный индекс предмета: " + string(cell_index));
        return false;
    }

    var item_data = ds_list_find_value(global.playerInventory, cell_index);
    if (is_undefined(item_data)) {
        show_debug_message("Ошибка: Данные предмета не найдены!");
        return false;
    }

    var item_id = item_data[? "id"];

    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        show_debug_message("Ошибка: База данных предметов не инициализирована!");
        return false;
    }

    var db_data = ds_map_find_value(global.ItemDB, item_id);
    if (db_data == -1) {
        show_debug_message("Ошибка: Предмет с ID " + string(item_id) + " не найден в базе данных!");
        return false;
    }

    var equip_slot = db_data[? "equip_slot"];
    if (equip_slot == -1) {
        add_notification("Этот предмет нельзя экипировать!");
        return false;
    }

    var slot_type = "";
    switch(equip_slot) {
        case global.EQUIP_SLOT.WEAPON: slot_type = "weapon"; break;
        case global.EQUIP_SLOT.ARMOR: slot_type = "armor"; break;
        case global.EQUIP_SLOT.ACCESSORY: slot_type = "accessory"; break;
        case global.EQUIP_SLOT.RELIC: slot_type = "relic"; break;
        default:
            add_notification("Неизвестный тип слота для экипировки!");
            return false;
    }

    var success = EquipItem(cell_index, 0, slot_type);

    if (success) {
        add_notification("Предмет экипирован на главного героя");
    } else {
        add_notification("Не удалось экипировать предмет!");
    }

    return success;
}

function get_hero_name(hero_index) {
    switch(hero_index) {
        case 0: return "Главного героя";
        case 1: return "Hepo";
        case 2: return "Fatty";
        case 3: return "Discipline";
        default: return "Неизвестного героя";
    }
}

function draw_inventory_scrollbar(x, y, width, height, total_content_height, visible_height, header_height) {
    var scrollbar_width = 8;
    var scrollbar_x = x + width - scrollbar_width - 6;
    var track_y = y + header_height;
    var scrollbar_track_height = visible_height;

    var scrollbar_height = max(32, visible_height * (visible_height / total_content_height));
    var scroll_ratio = global.inv_scroll_offset / global.inv_max_scroll;
    var scrollbar_y = track_y + scroll_ratio * (visible_height - scrollbar_height);

    draw_set_color(make_color_rgb(60, 60, 80));
    draw_rectangle(scrollbar_x, track_y, scrollbar_x + scrollbar_width, track_y + scrollbar_track_height, false);

    var slider_color = global.inv_scroll_dragging ? merge_color(ui_highlight, c_white, 0.3) : ui_highlight;
    draw_set_color(slider_color);
    draw_rectangle(scrollbar_x, scrollbar_y, scrollbar_x + scrollbar_width, scrollbar_y + scrollbar_height, false);

    global.inv_scrollbar_rect = {
        x1: scrollbar_x,
        y1: scrollbar_y,
        x2: scrollbar_x + scrollbar_width,
        y2: scrollbar_y + scrollbar_height,
        track_y1: track_y,
        track_y2: track_y + scrollbar_track_height
    };
}

function draw_equipment_section(x, y, width, height) {
    draw_set_color(ui_bg_dark);
    draw_rectangle(x, y, x + width, y + height, false);
    draw_set_color(ui_border_color);
    draw_rectangle(x, y, x + width, y + height, true);

    var padding = 14;
    draw_set_color(ui_text);
    draw_text(x + padding, y + 6, "Снаряжение героя");

    var portrait_cx = x + width / 2;
    var portrait_cy = y + 70;
    var portrait_r = 40;

    draw_set_color(make_color_rgb(55, 65, 95));
    draw_circle(portrait_cx, portrait_cy, portrait_r + 4, false);
    draw_set_color(merge_color(ui_highlight, c_white, 0.35));
    draw_circle(portrait_cx, portrait_cy, portrait_r, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(portrait_cx, portrait_cy - 4, "🛡️");
    draw_set_valign(fa_top);

    var hero_equipment = global.equipment_slots[0];
    var slot_size = 72;
    var slot_gap = 26;
    var grid_width = slot_size * 2 + slot_gap;
    var grid_x = x + (width - grid_width) / 2;
    var grid_y = portrait_cy + portrait_r + 20;

    var slots = [
        { type: "weapon", name: "Оружие", col: 0, row: 0 },
        { type: "armor", name: "Броня", col: 1, row: 0 },
        { type: "accessory", name: "Аксессуар", col: 0, row: 1 },
        { type: "relic", name: "Реликвия", col: 1, row: 1 }
    ];

    for (var i = 0; i < array_length(slots); i++) {
        var slot = slots[i];
        var slot_x = grid_x + slot.col * (slot_size + slot_gap);
        var slot_y = grid_y + slot.row * (slot_size + slot_gap);
        var item_id = variable_struct_get(hero_equipment, slot.type);
        var filled = (item_id != -1);
        var hovered = point_in_rectangle(mouse_x, mouse_y, slot_x, slot_y, slot_x + slot_size, slot_y + slot_size);

        var slot_color = filled ? merge_color(ui_highlight, c_white, hovered ? 0.35 : 0.2) : merge_color(ui_bg_dark, c_white, hovered ? 0.25 : 0.1);
        draw_set_color(slot_color);
        draw_rectangle(slot_x, slot_y, slot_x + slot_size, slot_y + slot_size, false);
        draw_set_color(ui_border_color);
        draw_rectangle(slot_x, slot_y, slot_x + slot_size, slot_y + slot_size, true);

        if (filled) {
            var slot_item = ds_map_find_value(global.ItemDB, item_id);
            if (slot_item != -1) {
                draw_set_color(c_white);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(slot_x + slot_size/2, slot_y + slot_size/2 - 8, inventory_get_item_icon(slot_item));

                var short_name = string_copy(slot_item[? "name"], 1, 10);
                draw_set_color(ui_text_secondary);
                draw_set_font(fnt_small);
                draw_text(slot_x + slot_size/2, slot_y + slot_size - 12, short_name);
                draw_set_font(fnt_main);
                draw_set_valign(fa_top);

                if (hovered) {
                    inventory_register_tooltip(item_id, 1, "equipment");
                }
            }
        } else {
            draw_set_color(ui_text_secondary);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(slot_x + slot_size/2, slot_y + slot_size/2, "+");
            draw_set_valign(fa_top);
        }

        draw_set_color(ui_text);
        draw_set_halign(fa_center);
        draw_text(slot_x + slot_size/2, slot_y + slot_size + 6, slot.name);
        draw_set_halign(fa_left);

        array_push(global.inv_buttons, {
            type: "equip_slot",
            hero_index: 0,
            slot_type: slot.type,
            x1: slot_x, y1: slot_y,
            x2: slot_x + slot_size, y2: slot_y + slot_size
        });
    }

    var bonus_y = grid_y + slot_size * 2 + slot_gap + 20;
    var info_lines = [];
    if (global.hero.equipment_bonuses.strength > 0) array_push(info_lines, "Сила +" + string(global.hero.equipment_bonuses.strength));
    if (global.hero.equipment_bonuses.intelligence > 0) array_push(info_lines, "Интеллект +" + string(global.hero.equipment_bonuses.intelligence));
    if (global.hero.equipment_bonuses.defense > 0) array_push(info_lines, "Защита +" + string(global.hero.equipment_bonuses.defense));

    draw_set_color(ui_text_secondary);
    draw_set_halign(fa_center);
    if (array_length(info_lines) > 0) {
        var info_text = "";
        for (var bi = 0; bi < array_length(info_lines); bi++) {
            info_text += info_lines[bi];
            if (bi < array_length(info_lines) - 1) info_text += "   ";
        }
        draw_text(x + width/2, bonus_y, info_text);
    } else {
        draw_text(x + width/2, bonus_y, "Пока нет бонусов от экипировки");
    }
    draw_set_halign(fa_left);

    var set_y = bonus_y + 26;
    draw_set_font(fnt_small);
    draw_set_color(ui_text_secondary);
    if (variable_struct_exists(global.hero, "active_sets") && is_array(global.hero.active_sets) && array_length(global.hero.active_sets) > 0) {
        for (var si = 0; si < array_length(global.hero.active_sets); si++) {
            var set_info = global.hero.active_sets[si];
            var header = set_info.name + " · " + string(set_info.owned) + "/" + string(set_info.total);
            draw_set_color(set_info.owned >= set_info.total ? ui_highlight : ui_text_secondary);
            draw_text(x + padding, set_y, header);
            set_y += 16;

            var unlocked = set_info.unlocked;
            if (is_array(unlocked)) {
                draw_set_color(ui_text_secondary);
                for (var ui_line = 0; ui_line < array_length(unlocked); ui_line++) {
                    draw_text(x + padding + 12, set_y, "• " + unlocked[ui_line]);
                    set_y += 14;
                }
            }

            if (set_info.next != "") {
                draw_set_color(ui_text_secondary);
                draw_text(x + padding + 12, set_y, "Следующая цель: " + set_info.next);
                set_y += 16;
            }

            set_y += 4;
        }
    } else {
        draw_text(x + padding, set_y, "Соберите предметы сетов для уникальных эффектов");
    }
    draw_set_font(fnt_main);
}

function inventory_get_rarity_color(rarity) {
    switch(rarity) {
        case 0: return make_color_rgb(70, 75, 95);
        case 1: return make_color_rgb(80, 105, 150);
        case 2: return make_color_rgb(110, 140, 190);
        case 3: return make_color_rgb(170, 120, 210);
        default: return make_color_rgb(215, 150, 75);
    }
}

function inventory_get_item_icon(db_data) {
    switch(db_data[? "type"]) {
        case global.ITEM_TYPE.WEAPON: return "⚔️";
        case global.ITEM_TYPE.ARMOR: return "🛡️";
        case global.ITEM_TYPE.ACCESSORY: return "💍";
        case global.ITEM_TYPE.POTION: return "🧪";
        case global.ITEM_TYPE.SCROLL: return "📜";
        case global.ITEM_TYPE.TROPHY: return "🏆";
        default:
            if (db_data[? "item_class"] == "trophy") return "🏆";
            return "🎁";
    }
}

function inventory_get_item_tag(db_data) {
    switch(db_data[? "type"]) {
        case global.ITEM_TYPE.WEAPON: return "Оружие · " + rarity_names[rarity_index];
        case global.ITEM_TYPE.ARMOR: return "Броня · " + rarity_names[rarity_index];
        case global.ITEM_TYPE.ACCESSORY: return "Аксессуар · " + rarity_names[rarity_index];
        case global.ITEM_TYPE.POTION: return "Зелье · " + rarity_names[rarity_index];
        case global.ITEM_TYPE.SCROLL: return "Свиток · " + rarity_names[rarity_index];
        case global.ITEM_TYPE.TROPHY: return "Трофей · Единственный";
        default:
            if (db_data[? "item_class"] == "trophy") return "Трофей · Единственный";
            return "Артефакт · " + rarity_names[rarity_index];
    }
}

function inventory_collect_item_stats(db_data) {
    var segments = [];
    if (db_data[? "strength_bonus"] != 0) array_push(segments, "⚔ +" + string(db_data[? "strength_bonus"]));
    if (db_data[? "agility_bonus"] != 0) array_push(segments, "⚡ +" + string(db_data[? "agility_bonus"]));
    if (db_data[? "intelligence_bonus"] != 0) array_push(segments, "🧠 +" + string(db_data[? "intelligence_bonus"]));
    if (db_data[? "defense_bonus"] != 0) array_push(segments, "🛡 +" + string(db_data[? "defense_bonus"]));
    if (db_data[? "max_health_bonus"] != 0) array_push(segments, "❤️ +" + string(db_data[? "max_health_bonus"]));
    if (db_data[? "health_bonus"] != 0) array_push(segments, "🩸 +" + string(db_data[? "health_bonus"]));
    if (db_data[? "gold_bonus"] != 0) array_push(segments, "💰 +" + string(db_data[? "gold_bonus"]) + "%");
    return segments;
}

function inventory_collect_special_effects(db_data) {
    var lines = [];
    var highlight = variable_global_exists("ui_highlight") ? ui_highlight : c_aqua;
    var accent = variable_global_exists("ui_accent") ? ui_accent : highlight;

    if (ds_map_exists(db_data, "companion_buff")) {
        var buff_type = db_data[? "companion_buff"];
        if (!is_undefined(buff_type) && buff_type != "") {
            var details = "";
            if (ds_map_exists(db_data, "companion_buff_description")) {
                details = db_data[? "companion_buff_description"];
            }
            if (details == "" && ds_map_exists(db_data, "buff_power")) {
                var powerx = db_data[? "buff_power"];
                switch (buff_type) {
                    case "hepo_success":
                        details = "🎯 +" + string(power) + "% к шансу успеха экспедиций.";
                        break;
                    case "fatty_health":
                        details = "🍰 +" + string(power) + "% к здоровью отряда.";
                        break;
                    case "discipline_gold":
                        details = "💰 +" + string(power) + "% к наградам экспедиций.";
                        break;
                    case "all_buffs_boost":
                        details = "✨ Усиление всех бафов помощниц на +" + string(power) + "%";
                        break;
                    case "expedition_speed":
                        details = "🧭 Сокращает длительность экспедиции на " + string(power) + "%";
                        break;
                    case "double_rewards":
                        details = "🎲 " + string(power) + "% шанс удвоить награды.";
                        break;
                }
            }
            if (details != "") {
                array_push(lines, { text: details, color: highlight });
            }
        }
    }

    if (ds_map_exists(db_data, "health")) {
        var heal = db_data[? "health"];
        if (heal > 0) {
            array_push(lines, { text: "💖 Мгновенно лечит " + string(heal) + " здоровья.", color: accent });
        }
    }

    if (ds_map_exists(db_data, "temp_strength")) {
        var temp_strength = db_data[? "temp_strength"];
        if (temp_strength > 0) {
            array_push(lines, { text: "💪 +" + string(temp_strength) + " силы на 30 секунд.", color: accent });
        }
    }

    if (ds_map_exists(db_data, "temp_agility")) {
        var temp_agility = db_data[? "temp_agility"];
        if (temp_agility > 0) {
            array_push(lines, { text: "⚡ +" + string(temp_agility) + " ловкости на 30 секунд.", color: accent });
        }
    }

    if (ds_map_exists(db_data, "temp_intelligence")) {
        var temp_intelligence = db_data[? "temp_intelligence"];
        if (temp_intelligence > 0) {
            array_push(lines, { text: "🧠 +" + string(temp_intelligence) + " интеллекта на 30 секунд.", color: accent });
        }
    }

    if (ds_map_exists(db_data, "temp_defense")) {
        var temp_defense = db_data[? "temp_defense"];
        if (temp_defense > 0) {
            array_push(lines, { text: "🛡️ +" + string(temp_defense) + " защиты на 30 секунд.", color: accent });
        }
    }

    if (ds_map_exists(db_data, "expedition_success_bonus")) {
        var success_bonus = db_data[? "expedition_success_bonus"];
        if (success_bonus > 0) {
            array_push(lines, { text: "🎯 +" + string(success_bonus) + "% к шансу успеха следующей экспедиции.", color: highlight });
        }
    }

    if (ds_map_exists(db_data, "expedition_gold_bonus")) {
        var gold_bonus = db_data[? "expedition_gold_bonus"];
        if (gold_bonus > 0) {
            array_push(lines, { text: "💰 +" + string(gold_bonus) + "% к наградам следующей экспедиции.", color: highlight });
        }
    }

    if (ds_map_exists(db_data, "instant_complete")) {
        if (db_data[? "instant_complete"]) {
            array_push(lines, { text: "📜 Мгновенно завершает текущую экспедицию.", color: highlight });
        }
    }

    if (ds_map_exists(db_data, "defense_multiplier")) {
        var defense_mult = db_data[? "defense_multiplier"];
        if (defense_mult > 0) {
            var def_percent = round((defense_mult - 1) * 100);
            array_push(lines, { text: "🛡️ +" + string(def_percent) + "% к защите на одну экспедицию.", color: highlight });
        }
    }

    if (ds_map_exists(db_data, "reward_multiplier")) {
        var reward_mult = db_data[? "reward_multiplier"];
        if (reward_mult > 0) {
            var reward_percent = round((reward_mult - 1) * 100);
            array_push(lines, { text: "💎 +" + string(reward_percent) + "% к наградам следующей экспедиции.", color: highlight });
        }
    }

    if (ds_map_exists(db_data, "expedition_speed")) {
        var speed_value = db_data[? "expedition_speed"];
        if (speed_value > 0) {
            var speed_text = "⚡ Ускоряет экспедицию.";
            var percent_value = 0;
            if (speed_value < 1) {
                percent_value = round((1 - speed_value) * 100);
                speed_text = "⚡ Сокращает длительность экспедиции на " + string(percent_value) + "%";
            } else {
                percent_value = round(speed_value);
                speed_text = "⚡ Ускоряет экспедицию на " + string(percent_value) + "%";
            }
            array_push(lines, { text: speed_text, color: highlight });
        }
    }

    return lines;
}

function inventory_get_set_progress_text(item_id, db_data) {
    if (!function_exists(get_set_definition)) return "";
    var set_id = db_data[? "set_id"];
    if (is_undefined(set_id) || set_id == "") return "";

    var set_data = get_set_definition(set_id);
    if (set_data == -1) return "";

    var total = array_length(set_data[? "pieces"]);
    var equipped = function_exists(get_equipped_set_piece_count) ? get_equipped_set_piece_count(set_id) : 0;
    var preview = equipped;
    if (function_exists(is_item_equipped) && !is_item_equipped(item_id)) {
        preview = min(total, equipped + 1);
    }

    var progress_text = set_data[? "name"] + " · " + string(equipped) + "/" + string(total);
    if (preview > equipped && preview <= total) {
        progress_text += " (→ " + string(preview) + ")";
    }

    return progress_text;
}

function inventory_register_tooltip(item_id, quantity, source) {
    if (is_undefined(item_id)) return;

    var tip = {
        item_id: item_id,
        quantity: max(1, quantity),
        source: source,
        anchor_x: mouse_x + 24,
        anchor_y: mouse_y + 24
    };

    global.inventory_hover_tooltip = tip;
}

function draw_inventory_tooltip() {
    if (!variable_global_exists("inventory_hover_tooltip")) return;
    var tip = global.inventory_hover_tooltip;
    if (!is_struct(tip)) return;

    var item_id = tip.item_id;
    if (is_undefined(item_id)) return;

    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) return;
    var db_data = ds_map_find_value(global.ItemDB, item_id);
    if (db_data == -1) return;

    var width = 320;
    var padding = 12;
    var text_width = width - padding * 2;
    var line_gap = 6;

    var name = db_data[? "name"];
    var tag_text = inventory_get_item_tag(db_data);
    var description = db_data[? "description"];
    if (is_undefined(description)) description = "";

    var stats = inventory_collect_item_stats(db_data);
    var stats_height = array_length(stats) > 0 ? 18 : 0;
    var desc_height = string_length(description) > 0 ? string_height_ext(description, 4, text_width) : 0;

    var special_lines = inventory_collect_special_effects(db_data);
    var special_heights = [];
    var special_height = 0;
    for (var sl = 0; sl < array_length(special_lines); sl++) {
        var entry = special_lines[sl];
        var entry_text = entry.text;
        var line_height = string_height_ext(entry_text, 4, text_width);
        line_height = max(16, line_height);
        array_push(special_heights, line_height);
        special_height += line_height;
    }

    var piece_text = "";
    if (!is_undefined(db_data[? "set_piece_name"]) && db_data[? "set_piece_name"] != "") {
        piece_text = "Часть: " + db_data[? "set_piece_name"];
    }

    var set_lines = [];
    if (function_exists(get_set_definition)) {
        var set_id = db_data[? "set_id"];
        if (!is_undefined(set_id) && set_id != "") {
            var set_data = get_set_definition(set_id);
            if (set_data != -1) {
                var total = array_length(set_data[? "pieces"]);
                var equipped = function_exists(get_equipped_set_piece_count) ? get_equipped_set_piece_count(set_id) : 0;
                var preview = equipped;
                if (function_exists(is_item_equipped) && !is_item_equipped(item_id)) {
                    preview = min(total, equipped + 1);
                }

                var header = set_data[? "name"] + " · " + string(equipped) + "/" + string(total);
                if (preview > equipped && preview <= total) {
                    header += " (→ " + string(preview) + ")";
                }
                array_push(set_lines, { text: header, color: ui_highlight });

                var bonuses = set_data[? "bonuses"];
                for (var b = 0; b < array_length(bonuses); b++) {
                    var entry = bonuses[b];
                    var bonus_text = string(entry.count) + " предмета: " + entry.description;
                    var unlocked = (equipped >= entry.count);
                    var upcoming = (!unlocked && preview >= entry.count);
                    var line_color = unlocked ? ui_text : (upcoming ? ui_highlight : ui_text_secondary);
                    array_push(set_lines, { text: bonus_text, color: line_color });
                }

                var set_desc = set_data[? "description"];
                if (!is_undefined(set_desc) && string_length(set_desc) > 0) {
                    array_push(set_lines, { text: set_desc, color: ui_text_secondary });
                }
            }
        }
    }

    var set_height = array_length(set_lines) * 16;

    var trophy_text = "";
    if (db_data[? "type"] == global.ITEM_TYPE.TROPHY || db_data[? "item_class"] == "trophy") {
        trophy_text = db_data[? "trophy_condition"];
        if ((is_undefined(trophy_text) || trophy_text == "") && function_exists(get_trophy_definition)) {
            var trophy_data = get_trophy_definition(item_id);
            if (trophy_data != undefined) {
                trophy_text = trophy_data.condition;
            }
        }
        if (is_undefined(trophy_text)) trophy_text = "";
    }
    var trophy_height = trophy_text != "" ? string_height_ext(trophy_text, 4, text_width) : 0;

    var quantity_text = "";
    if (db_data[? "stackable"]) {
        quantity_text = "В стопке: " + string(tip.quantity);
    }

    var total_height = padding * 2 + 24 + 18;
    if (stats_height > 0) total_height += line_gap + stats_height;
    if (desc_height > 0) total_height += line_gap + desc_height;
    if (special_height > 0) total_height += line_gap + special_height;
    if (piece_text != "") total_height += line_gap + 16;
    if (set_height > 0) total_height += line_gap + set_height;
    if (trophy_height > 0) total_height += line_gap + trophy_height;
    if (quantity_text != "") total_height += line_gap + 16;

    var screen_w = variable_global_exists("screen_width") ? global.screen_width : display_get_gui_width();
    var screen_h = variable_global_exists("screen_height") ? global.screen_height : display_get_gui_height();

    var final_x = tip.anchor_x;
    var final_y = tip.anchor_y;

    if (final_x + width > screen_w - 12) final_x = screen_w - width - 12;
    if (final_y + total_height > screen_h - 12) final_y = screen_h - total_height - 12;
    final_x = max(12, final_x);
    final_y = max(12, final_y);

    var rarity_color = inventory_get_rarity_color(db_data[? "rarity"]);

    draw_set_color(ui_bg_dark);
    draw_rectangle(final_x, final_y, final_x + width, final_y + total_height, false);
    draw_set_color(rarity_color);
    draw_rectangle(final_x, final_y, final_x + width, final_y + 4, false);
    draw_set_color(ui_border_color);
    draw_rectangle(final_x, final_y, final_x + width, final_y + total_height, true);

    var cursor_y = final_y + padding;
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_font(fnt_main);
    draw_text(final_x + padding, cursor_y, name);
    cursor_y += 24;

    draw_set_font(fnt_small);
    draw_set_color(ui_text_secondary);
    draw_text(final_x + padding, cursor_y, tag_text);
    cursor_y += 18;

    if (array_length(stats) > 0) {
        cursor_y += line_gap;
        draw_set_color(ui_text);
        draw_text(final_x + padding, cursor_y, array_join(stats, "   "));
        cursor_y += 18;
    }

    if (desc_height > 0) {
        cursor_y += line_gap;
        draw_set_color(ui_text_secondary);
         draw_text_ext(final_x + padding, cursor_y, description, 4, text_width);
        cursor_y += desc_height;
    }

    if (special_height > 0) {
        cursor_y += line_gap;
        for (var sl = 0; sl < array_length(special_lines); sl++) {
            var entry = special_lines[sl];
            var entry_color = variable_struct_exists(entry, "color") ? entry.color : ui_highlight;
            draw_set_color(entry_color);
            draw_text_ext(final_x + padding, cursor_y, entry.text, 4, text_width);
            cursor_y += special_heights[sl];
        }
    }

    if (piece_text != "") {
        cursor_y += line_gap;
        draw_set_color(ui_text_secondary);
        draw_text(final_x + padding, cursor_y, piece_text);
        cursor_y += 16;
    }

    if (set_height > 0) {
        cursor_y += line_gap;
        for (var sl = 0; sl < array_length(set_lines); sl++) {
            var line = set_lines[sl];
            draw_set_color(line.color);
            draw_text(final_x + padding, cursor_y, line.text);
            cursor_y += 16;
        }
    }

    if (trophy_height > 0) {
        cursor_y += line_gap;
        draw_set_color(ui_highlight);
        draw_text_ext(final_x + padding, cursor_y, trophy_text, 4, text_width);
        cursor_y += trophy_height;
    }

    if (quantity_text != "") {
        cursor_y += line_gap;
        draw_set_color(ui_text_secondary);
        draw_text(final_x + padding, cursor_y, quantity_text);
    }

    draw_set_font(fnt_main);
    draw_set_color(c_white);
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



function draw_trophies_tab(x, y, width, height) {
    if (!variable_global_exists("trophy_buttons")) global.trophy_buttons = [];
    if (!variable_global_exists("trophy_showcase_buttons")) global.trophy_showcase_buttons = [];
    global.trophy_buttons = [];
    global.trophy_showcase_buttons = [];

    draw_set_color(ui_text);
    draw_text(x, y, "ЗАЛ ТРОФЕЕВ");

    var showcase_y = y + 30;
    var showcase_height = 120;
    var slot_gap = 18;
    var slot_width = (width - slot_gap * 2) / 3;

    draw_set_color(ui_text_secondary);
    draw_text(x, showcase_y - 18, "Избранные трофеи украшают вашу витрину");

    for (var i = 0; i < 3; i++) {
        var slot_x = x + i * (slot_width + slot_gap);
        var slot_y = showcase_y;
        var trophy_id = global.featured_trophies[i];
        var has_trophy = (trophy_id != "" && is_trophy_unlocked(trophy_id));
        var base_color = has_trophy ? merge_color(ui_highlight, c_white, 0.18) : merge_color(ui_bg_dark, c_white, 0.12);
        var border_color = has_trophy ? ui_highlight : ui_border_color;

        draw_set_color(base_color);
        draw_rectangle(slot_x, slot_y, slot_x + slot_width, slot_y + showcase_height, false);
        draw_set_color(border_color);
        draw_rectangle(slot_x, slot_y, slot_x + slot_width, slot_y + showcase_height, true);

        draw_set_halign(fa_center);
        if (has_trophy) {
            var trophy_data = get_trophy_definition(trophy_id);
            draw_set_color(c_white);
            draw_set_font(fnt_main);
            draw_text(slot_x + slot_width/2, slot_y + 24, trophy_data.icon);
            draw_set_color(ui_text);
            draw_text(slot_x + slot_width/2, slot_y + 60, trophy_data.name);
            draw_set_color(ui_text_secondary);
            draw_set_font(fnt_small);
            draw_text(slot_x + slot_width/2, slot_y + 88, "Витрина украшена");
            draw_set_font(fnt_main);

            var btn_x1 = slot_x + slot_width - 26;
            var btn_y1 = slot_y + 6;
            var btn_x2 = btn_x1 + 20;
            var btn_y2 = btn_y1 + 20;
            draw_set_color(ui_danger);
            draw_rectangle(btn_x1, btn_y1, btn_x2, btn_y2, false);
            draw_set_color(c_white);
            draw_text((btn_x1 + btn_x2)/2, btn_y1 + 2, "✕");

            array_push(global.trophy_showcase_buttons, {
                type: "clear_feature_slot",
                slot: i,
                x1: btn_x1, y1: btn_y1,
                x2: btn_x2, y2: btn_y2
            });
        } else {
            draw_set_color(ui_text_secondary);
            draw_set_font(fnt_small);
            draw_text(slot_x + slot_width/2, slot_y + 60, "Выберите трофей из списка");
            draw_set_font(fnt_main);
        }
        draw_set_halign(fa_left);
    }

    var list_y = showcase_y + showcase_height + 28;
    var card_gap = 16;
    var card_height = 110;
    var columns = max(1, floor(width / 320));
    var card_width = (width - card_gap * (columns - 1)) / columns;

    for (var t = 0; t < array_length(global.trophy_catalog); t++) {
        var trophy = global.trophy_catalog[t];
        var column = t mod columns;
        var row = t div columns;
        var card_x = x + column * (card_width + card_gap);
        var card_y = list_y + row * (card_height + card_gap);

        var unlocked = is_trophy_unlocked(trophy.id);
        var featured = false;
        for (var f = 0; f < array_length(global.featured_trophies); f++) {
            if (global.featured_trophies[f] == trophy.id) {
                featured = true;
                break;
            }
        }

        var card_color = unlocked ? merge_color(ui_bg_light, c_white, featured ? 0.25 : 0.12) : merge_color(ui_bg_dark, c_white, 0.08);
        var card_border = unlocked ? (featured ? ui_highlight : ui_border_color) : ui_border_color;

        draw_set_color(card_color);
        draw_rectangle(card_x, card_y, card_x + card_width, card_y + card_height, false);
        draw_set_color(card_border);
        draw_rectangle(card_x, card_y, card_x + card_width, card_y + card_height, true);

        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_text(card_x + 16, card_y + 14, trophy.icon);
        draw_set_color(ui_text);
        draw_text(card_x + 48, card_y + 12, trophy.name);
        draw_set_color(ui_text_secondary);
        draw_set_font(fnt_small);
        draw_text(card_x + 48, card_y + 32, trophy.condition);
        draw_set_font(fnt_main);

        if (unlocked) {
            draw_set_color(ui_text_secondary);
            draw_text(card_x + 48, card_y + 52, featured ? "На витрине" : "Готов к размещению");

            var btn_x1 = card_x + 48;
            var btn_y1 = card_y + card_height - 28;
            var btn_x2 = card_x + card_width - 16;
            var btn_y2 = btn_y1 + 20;
            draw_set_color(featured ? ui_danger : ui_highlight);
            draw_rectangle(btn_x1, btn_y1, btn_x2, btn_y2, false);
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_text((btn_x1 + btn_x2)/2, btn_y1 + 4, featured ? "Убрать из витрины" : "Добавить в витрину");
            draw_set_halign(fa_left);

            array_push(global.trophy_buttons, {
                type: "feature_trophy",
                trophy_id: trophy.id,
                x1: btn_x1, y1: btn_y1,
                x2: btn_x2, y2: btn_y2
            });
        } else {
            draw_set_color(ui_text_secondary);
            draw_text(card_x + 48, card_y + card_height - 28, "Требуется выполнить условие");
        }
    }

    if (array_length(global.trophy_catalog) == 0) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_center);
        draw_text(x + width/2, list_y + 40, "Трофеи ещё не добавлены");
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