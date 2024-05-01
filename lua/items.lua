function format_object (object)
    local formatted_text
    formatted_text =
        "<span foreground='yellow'><big>"
        ..object['name']
        .."</big></span>\n<i>"
        ..object['description']
        .."</i>"
    return formatted_text
end
