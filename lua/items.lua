-- given object, return a nicely formatted string describing it
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
        --details.label = format_object(details_obj[1][2])
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

    return gui.show_dialog(wml.get_child(wml.load("~add-ons/Frost_Mage/gui/item_stats.cfg"), "resolution"), preshow, function() end)
end
