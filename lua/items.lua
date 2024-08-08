--Global lookup table
--First column: id of type, Second column: descriptive name
ITEM_TYPES = {}
ITEM_TYPES[0] = {"weapon", "Weapon", "misc/achievement-frames/frame-6-royal.png"}
ITEM_TYPES[1] = {"armor", "Armor", "misc/achievement-frames/frame-2-orange.png"}
ITEM_TYPES[2] = {"trinket", "Trinket", "misc/achievement-frames/frame-4-sky.png"}
ITEM_TYPES[3] = {"amulet", "Amulet", "misc/achievement-frames/frame-3-jade.png"}
---------------------------------------------------------------

-- given object, return a string nicely formatted with pango markup describing it
function format_object(object)
    local formatted_text
    formatted_text =
    "<span foreground='yellow'><big>"
    ..object['name']
    .."</big></span>\n<i>"
    ..object['description']
    .."</i>"
    return formatted_text
end

-- show the stats of a given item object in a gui
function show_stats_dialog(item_img, details_obj, btn1_text, btn2_text)
    local preshow = function(dialog)
        local details = dialog:find('details')
        details.label = format_object(details_obj)
        local image = dialog:find('image')
        image.label = item_img.."~BLIT(misc/achievement-frames/frame-9-red.png)"
        if btn1_text ~= nil then
            local btn1 = dialog:find('btn1')
            btn1.label = btn1_text
        end
        if btn2_text ~= nil then
            local btn2 = dialog:find('btn2')
            btn2.label = btn2_text
        end
    end
    
    return gui.show_dialog(wml.get_child(wml.load("~add-ons/WISh/gui/item_stats.cfg"), "resolution"), preshow, function() end)
end

-- get item from storage
-- item is removed from storage once this is called
function get_item_from_storage(item_type, item_num, remove)
    var_name = 'stored_'..item_type..'s['..item_num..']'
    item_obj = wml.variables[var_name..'.object']
    if remove then
        wesnoth.wml_actions.clear_variable{name = var_name}
    end
    return item_obj
end

-- wrapper for removing an item from storage
function remove_from_storage(item_type, item_num)
    get_item_from_storage(item_type, item_num, true)
end

-- get item from unit
function get_item_from_unit(curr_unit, item_type, remove)
    var_name = item_type..'.object'
    item = curr_unit.variables[var_name]
    if remove then
        curr_unit.variables[item_type] = nil
        curr_unit:remove_modifications({id = item.id})
    end
    return item
end

-- add an item to the storage
function add_item_to_storage(item_type, item)
    var_name = 'stored_'..item_type..'s'
    wesnoth.wml_actions.set_variables{
        name = var_name,
        mode = "append",
        wml.tag.value{wml.tag.object(item)}
    }
end

-- handler for item equip
function equip(curr_unit, item_type, item)
    if item ~= nil then
        curr_unit:add_modification("object", item)
        curr_unit.variables[item_type..'.object'] = item
    end
end

-- drop an item, half of the work is done in wml
function drop(item, type)
    if item ~= nil then
        wml.variables['drop'] = true
        wml.variables['drop_item'] = item
        wml.variables['drop_item_type'] = type
    end
end

-- function to check if an unit has item
function check_has_item(curr_unit)
    local has_item = false
    for i=0,3 do
        if get_item_from_unit(curr_unit, ITEM_TYPES[i][1], false) ~= nil then
            has_item = true
        end
    end
    return has_item
end

--------------------------------------------------------------
-- Inventory preshow method
-- accessed via the "Inventory" menu item
function inventory_init(dialog)
    -- Storage --
    -- Initialize treeview
    local root_node = dialog:find("storage_list")
    local nodes = {}
    for i=0,3 do
        nodes[i] = root_node:add_item_of_type("category")
        nodes[i].item_name.label = ITEM_TYPES[i][2]
        nodes[i].unfolded = true
    end

    -- Add items to the treeview
    for i=0,3 do
        local len = wml.variables['stored_'..ITEM_TYPES[i][1]..'s.length']
        for j=0,len-1 do
            local node = nodes[i]:add_item_of_type("item")
            node.item_name.label = wml.variables['stored_'..ITEM_TYPES[i][1]..'s['..j..'].object.name']
        end
    end
    
    -- Show Equipped Items --
    local curr_unit = wesnoth.units.find_on_map{
        x = wml.variables['x1'],
        y = wml.variables['y1']
    }[1]

    local imgs = {}
    local items = {}
    if check_has_item(curr_unit) then
        for i=0,3 do
            if curr_unit.variables[ITEM_TYPES[i][1]] ~= nil then
                imgs[i] = dialog:find(ITEM_TYPES[i][1])
                items[i] = curr_unit.variables[ITEM_TYPES[i][1]][1][2]
                imgs[i].label = items[i].image.."~BLIT("..ITEM_TYPES[i][3]..")"
                dialog:find(ITEM_TYPES[i][1].."_btn").on_button_click = function()
                    local status = show_stats_dialog(items[i].image, items[i], "Unequip", "Drop")
                    if status == 1 then
                        local item = get_item_from_unit(curr_unit, ITEM_TYPES[i][1], true)
                        imgs[i].label = ITEM_TYPES[i][3]
                        add_item_to_storage(ITEM_TYPES[i][1], item)
                    elseif status == 3 then
                        local item = get_item_from_unit(curr_unit, ITEM_TYPES[i][1], true)
                        drop(item, ITEM_TYPES[i][1])
                        imgs[i].label = ITEM_TYPES[i][3]
                    end
                    items[i] = nil
                end
            end
        end
    end

    local storage_list = dialog:find("storage_list")

    -- Inventory Show Button
    local inventory_show = dialog:find("inv_show")
    inventory_show.on_button_click = function()
        local node_id = storage_list.selected_item_path[1]-1
        local node_name = ITEM_TYPES[node_id][1]
        local subnode_id = storage_list.selected_item_path[2]-1
        local item_obj = get_item_from_storage(node_name, subnode_id, false)
        local status = show_stats_dialog(item_obj.image, item_obj, "Equip", "Drop")
        if status == 3 then
            remove_from_storage(node_name, subnode_id)
            nodes[node_id]:remove_items_at(subnode_id, 1)
            drop(item_obj, node_name)
        elseif status == 1 then
            remove_from_storage(node_name, subnode_id)
            nodes[node_id]:remove_items_at(subnode_id, 1)
            equip(curr_unit, node_name, item_obj)
        end
        dialog:close()
    end

end

-- Show the inventory
function show_inventory()
    gui.show_dialog(wml.get_child(wml.load("~add-ons/WISh/gui/inventory.cfg"), "resolution"), inventory_init, function() end)
end

----------------------------------------------------------
-- WIP
-- custom tag for placing items in a map
function wesnoth.wml_actions.put_item(cfg)
    wesnoth.interface.add_item_image(cfg.x, cfg.y, cfg.image)
    --gui.alert(wesnoth.as_text(wml.get_child(wml.parsed(cfg), "filter")))
    --filter = {x = cfg.x, y = cfg.y, race = cfg.race, level = cfg.level},
    child, _ = wml.get_child(wml.parsed(cfg), "filter")
    wesnoth.game_events.add{
        name = 'moveto',
        id = cfg.id..'_pickup_event',
        first_time_only = false,
        filter = child,
        action = function()
            gui.alert(wesnoth.as_text(child))
        end
    }
end