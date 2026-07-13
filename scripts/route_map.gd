extends Control
class_name CinnaRouteMap

var depth := 0
var total_rooms := 12
var choices: Array = []
var selected_room := ""
var region_name := "吧台起点"
var active := true

func _ready() -> void:
    size = Vector2(196, 126)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func set_state(new_depth: int, new_total: int, new_choices: Array, new_selected: String, new_region_name: String) -> void:
    depth = new_depth
    total_rooms = new_total
    choices = new_choices.duplicate()
    selected_room = new_selected
    region_name = new_region_name
    visible = active
    queue_redraw()

func set_active(value: bool) -> void:
    active = value
    visible = value

func _draw() -> void:
    if not active:
        return
    var panel := Color(0.04, 0.025, 0.02, 0.78)
    draw_rect(Rect2(0, 0, size.x, size.y), panel)
    draw_rect(Rect2(0, 0, size.x, 18), Color(0.17, 0.09, 0.045, 0.92))
    draw_string(ThemeDB.fallback_font, Vector2(7, 14), "ROUTE MAP  " + region_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.88, 0.52))

    var start_x := 18.0
    var end_x := size.x - 18.0
    var y := 50.0
    var count := maxi(total_rooms, 2)
    for i in range(total_rooms):
        var x := lerpf(start_x, end_x, float(i) / float(count - 1))
        var col := Color(0.35, 0.22, 0.12)
        if i < depth:
            col = Color(0.56, 0.72, 0.38)
        elif i == depth:
            col = Color(1.0, 0.74, 0.20)
        elif i == total_rooms - 1:
            col = Color(1.0, 0.25, 0.10)
        if i > 0:
            var prev_x := lerpf(start_x, end_x, float(i - 1) / float(count - 1))
            draw_line(Vector2(prev_x, y), Vector2(x, y), Color(0.55, 0.38, 0.20, 0.85), 3.0)
        draw_rect(Rect2(x - 5, y - 5, 10, 10), Color(0.02, 0.015, 0.01))
        draw_rect(Rect2(x - 3, y - 3, 6, 6), col)

    draw_string(ThemeDB.fallback_font, Vector2(8, 78), "NOW: %d/%d" % [depth + 1, total_rooms], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.92, 0.90, 0.70))
    if choices.size() > 0:
        var text := "NEXT: "
        for i in range(choices.size()):
            if i > 0:
                text += "  "
            var label := _short(str(choices[i]))
            if selected_room == str(choices[i]):
                label = "[" + label + "]"
            text += str(i + 1) + label
        draw_string(ThemeDB.fallback_font, Vector2(8, 100), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.68, 1.0, 0.56))
    elif selected_room != "":
        draw_string(ThemeDB.fallback_font, Vector2(8, 100), "LOCKED: " + _short(selected_room), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.68, 1.0, 0.56))
    else:
        draw_string(ThemeDB.fallback_font, Vector2(8, 100), "CLEAR ROOM TO SCOUT", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.70, 0.84, 1.0))

func _short(room_type: String) -> String:
    match room_type:
        "fight":
            return "F"
        "elite":
            return "E"
        "treasure":
            return "T"
        "rest":
            return "R"
        "shop":
            return "S"
        "event":
            return "?"
        "shelf_boss":
            return "MB"
        "boss":
            return "BOSS"
		"hextech_forge": return "HF"
		"hextech_shop": return "HS"
    return room_type.substr(0, 1).to_upper()
