--Global lookup table
--First column: id of type, Second column: descriptive name
ITEM_TYPES = {}
ITEM_TYPES[0] = {"weapon", "Weapon", "misc/achievement-frames/frame-6-royal.png"}
ITEM_TYPES[1] = {"armor", "Armor", "misc/achievement-frames/frame-2-orange.png"}
ITEM_TYPES[2] = {"trinket", "Trinket", "misc/achievement-frames/frame-4-sky.png"}
ITEM_TYPES[3] = {"amulet", "Amulet", "misc/achievement-frames/frame-3-jade.png"}

-- Equip trait
EQUIP_TRAIT = {
    id = "equipped",
    name = "equipped",
    description = "Item: "
}

-- Item locked message
LOCK_TITLE = "<span face='OldaniaADFStd' color='#ff00ff'><big>Can't Remove!</big></span>"
LOCK_MSG = "This item is <i>locked</i> and cannot be removed normally!"
---------------------------------------------------------------

-- given object, return a formatted string describing it
function format_object(object)
    local formatted_text =
        "<span foreground='yellow'><big>"
        ..object['name']
        .."</big></span>\n<i>"
        ..object['description']
        .."</i>\n"
    
    if (object['gold_value'] ~= nil) then
        formatted_text =
            formatted_text
            .."Value: "
            ..object['gold_value']
            .." gold"
    end
    return formatted_text
end

-- show the stats of a given item object in a gui
function show_stats_dialog(details_obj, btn1_text, btn2_text, btn3_text, show_sell)
    local preshow = function(dialog)
        if (details_obj['gold_value'] == nil or show_sell == false or show_sell == nil) then
            dialog:find('btn4').visible = false
        elseif (show_sell == true) then
            dialog:find('btn4').visible = true
        end
        
        local details = dialog:find('details')
        details.label = format_object(details_obj)
        local image = dialog:find('image')
        image.label = details_obj.image.."~BLIT(misc/achievement-frames/frame-9-red.png)"
        
        if btn1_text ~= nil then
            local btn1 = dialog:find('btn1')
            btn1.label = btn1_text
        end
        if btn2_text ~= nil then
            local btn2 = dialog:find('btn2')
            btn2.label = btn2_text
        end
        if btn3_text ~= nil then
            local btn3 = dialog:find('btn3')
            btn3.label = btn3_text
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
        -- check if any other items exist, if not, remove trait
        if (check_has_item(curr_unit) == false) then
            curr_unit:remove_modifications({id = "equipped"}, "trait")
        end
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
        local trait = EQUIP_TRAIT
        trait.description = EQUIP_TRAIT.description..item.name
        curr_unit:add_modification("trait", EQUIP_TRAIT, true)
        curr_unit.variables[item_type..'.object'] = item
    end
end

-- drop an item, rest of the work is done in wml
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
        if curr_unit.variables[ITEM_TYPES[i][1]..'.object'] ~= nil then
            has_item = true
        end
    end
    return has_item
end

--------------------------------------------------------------
-- Inventory preshow method
-- accessed via the "Inventory" menu item
--------------------------------------------------------------

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
    items_count = 0
    for i=0,3 do
        local len = wml.variables['stored_'..ITEM_TYPES[i][1]..'s.length']
        items_count = items_count + len
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

    -- Set name and type of unit
    dialog:find("unit_name").label = "<span size='x-large' face='Serif'>"..curr_unit.name.."</span><span face='OldaniaADFStd' size='x-large'> ("..curr_unit.type..")".."</span>"
    
    local imgs = {}
    local items = {}
    if check_has_item(curr_unit) then
        for i=0,3 do
            if curr_unit.variables[ITEM_TYPES[i][1]] ~= nil then
                imgs[i] = dialog:find(ITEM_TYPES[i][1])
                items[i] = curr_unit.variables[ITEM_TYPES[i][1]][1][2]
                imgs[i].label = items[i].image.."~BLIT("..ITEM_TYPES[i][3]..")"
                dialog:find(ITEM_TYPES[i][1].."_btn").on_button_click = function()
                    local status = show_stats_dialog(items[i], "Unequip", "Drop", nil, true)
                    if status == 1 then
                        local item_readonly = get_item_from_unit(curr_unit, ITEM_TYPES[i][1], false)
                        if (item_readonly.locked ~= true) then
                            local item = get_item_from_unit(curr_unit, ITEM_TYPES[i][1], true)
                            imgs[i].label = ITEM_TYPES[i][3]
                            add_item_to_storage(ITEM_TYPES[i][1], item)
                        else
                            if (item_readonly.lock_msg ~= nil) then
                                gui.show_popup(LOCK_TITLE, item_readonly.lock_msg)
                            else
                                gui.show_popup(LOCK_TITLE, LOCK_MSG)
                            end
                        end
                    elseif status == 3 then
                        local item_readonly = get_item_from_unit(curr_unit, ITEM_TYPES[i][1], false)
                        if (item_readonly.locked ~= true) then
                            local item = get_item_from_unit(curr_unit, ITEM_TYPES[i][1], true)
                            imgs[i].label = ITEM_TYPES[i][3]
                            drop(item, ITEM_TYPES[i][1])
                        else
                            if (item_readonly.lock_msg ~= nil) then
                                gui.show_popup(LOCK_TITLE, item_readonly.lock_msg)
                            else
                                gui.show_popup(LOCK_TITLE, LOCK_MSG)
                            end
                        end
                    elseif status == 4 then
                        local item_readonly = get_item_from_unit(curr_unit, ITEM_TYPES[i][1], false)
                        if (item_readonly.locked ~= true) then
                            get_item_from_unit(curr_unit, ITEM_TYPES[i][1], true)
                            imgs[i].label = ITEM_TYPES[i][3]
                            local cost = item_readonly.gold_value
                            -- this adds the gold to the side gold amount
                            wesnoth.sides.get(curr_unit.side).gold = wesnoth.sides.get(curr_unit.side).gold + cost
                            -- play sound to give audible cue
                            wesnoth.audio.play("gold.ogg")
                            -- we give feedback to the user on what has been done
                            wesnoth.interface.add_chat_message("WISh", "Item "..item_readonly.name.." sold for "..cost.." gold.")
                        else
                            if (item_readonly.lock_msg ~= nil) then
                                gui.show_popup(LOCK_TITLE, item_readonly.lock_msg)
                            else
                                gui.show_popup(LOCK_TITLE, LOCK_MSG)
                            end
                        end
                    end
                    items[i] = nil
                end
            end
        end
    end
    
    -- Inventory Show Button handling
    local inventory_show = dialog:find("inv_show")
    local storage_list = dialog:find("storage_list")

    -- disable by default, only enable on valid selection
    inventory_show.enabled = false
    storage_list.on_modified = function()
        inventory_show.enabled = (storage_list.selected_item_path[2] ~= nil) and (items_count ~= 0)
    end

    inventory_show.on_button_click = function()
        local node_id = storage_list.selected_item_path[1]-1
        local sel_subnode_id = storage_list.selected_item_path[2]
        if sel_subnode_id == nil then
            return
        end

        local node_name = ITEM_TYPES[node_id][1]
        local subnode_id = sel_subnode_id-1
        local item_obj = get_item_from_storage(node_name, subnode_id, false)
        local status = show_stats_dialog(item_obj, "Equip", "Drop", nil, true)
        if status ~= 2 then
            remove_from_storage(node_name, subnode_id)
            nodes[node_id]:remove_items_at(subnode_id, 1)
        end

        if status == 3 then
            drop(item_obj, node_name)
        elseif status == 1 then
            equip(curr_unit, node_name, item_obj)
        elseif status == 4 then
            local cost = item_obj.gold_value
            -- this adds the gold to the side gold amount
            wesnoth.sides.get(curr_unit.side).gold = wesnoth.sides.get(curr_unit.side).gold + cost
            -- play sound to give audible cue
            wesnoth.audio.play("gold.ogg")
            -- we give feedback to the user on what has been done
            wesnoth.interface.add_chat_message("WISh", "Item "..item_obj.name.." sold for "..cost.." gold.")
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
            --gui.alert(wesnoth.as_text(child))
        end
    }
end
