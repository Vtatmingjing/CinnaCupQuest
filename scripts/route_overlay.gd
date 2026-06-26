extends Control
class_name CinnaRouteOverlay

var title_text := "SCOUT ROUTE"
var choices: Array = []
var selected_room := ""
var region_name := ""
var depth := 0
var total_rooms := 13
var active := false

func _ready() -> void:
    size = Vector2(540, 960)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    visible = false
    queue_redraw()

func show_routes(new_title: String, new_choices: Array, new_selected: String, new_region_name: String, new_depth: int, new_total: int) -> void:
    title_text = new_title
    choices = new_choices.duplicate()
    selected_room = new_selected
    region_name = new_region_name
    depth = new_depth
    total_rooms = new_total
    active = true
    visible = true
    queue_redraw()

func hide_routes() -> void:
    active = false
    visible = false
    queue_redraw()

func _draw() -> void:
    if not active:
        return
    draw_rect(Rect2(0, 0, 540, 960), Color(0.025, 0.018, 0.015, 0.86))
    draw_rect(Rect2(42, 156, 456, 552), Color(0.075, 0.045, 0.035, 0.96))
    draw_rect(Rect2(42, 156, 456, 54), Color(0.19, 0.09, 0.035, 0.98))
    draw_string(ThemeDB.fallback_font, Vector2(64, 192), title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color(1.0, 0.80, 0.32))
    draw_string(ThemeDB.fallback_font, Vector2(64, 234), "Region: %s     Floor %d/%d" % [region_name, depth + 1, total_rooms], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.90, 0.88, 0.72))
    draw_string(ThemeDB.fallback_font, Vector2(64, 260), "按 1 / 2 / 3 选择下一格。选完后进入右侧大门。", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.66, 1.0, 0.62))

    var start := Vector2(110, 596)
    var current := Vector2(270, 470)
    var exit := Vector2(430, 596)
    draw_line(start, current, Color(0.58, 0.35, 0.16, 0.75), 6.0)
    _draw_node(start, "NOW", Color(1.0, 0.74, 0.22), true)
    _draw_node(current, "SCOUT", Color(0.70, 0.96, 1.0), true)

    var node_positions := [Vector2(150, 344), Vector2(270, 326), Vector2(390, 344)]
    for i in range(choices.size()):
        var pos: Vector2 = node_positions[i]
        var room_type := str(choices[i])
        var is_selected := selected_room == room_type
        draw_line(current, pos, Color(0.55, 0.38, 0.20, 0.85), 5.0)
        draw_line(pos, exit, Color(0.36, 0.25, 0.15, 0.55), 4.0)
        _draw_node(pos, "%d" % (i + 1), _room_color(room_type), is_selected)
        var text_pos := pos + Vector2(-54, 46)
        draw_string(ThemeDB.fallback_font, text_pos, _room_name(room_type), HORIZONTAL_ALIGNMENT_CENTER, 108, 15, Color(0.98, 0.91, 0.68))
        draw_string(ThemeDB.fallback_font, text_pos + Vector2(0, 22), _room_hint(room_type), HORIZONTAL_ALIGNMENT_CENTER, 108, 12, Color(0.78, 0.74, 0.62))
    _draw_node(exit, "GATE", Color(0.92, 0.42, 0.22), false)

func _draw_node(pos: Vector2, label: String, color: Color, selected: bool) -> void:
    var outline := Color(0.02, 0.015, 0.01)
    var r := 29.0 if selected else 24.0
    draw_circle(pos, r + 5.0, outline)
    draw_circle(pos, r, color)
    draw_circle(pos + Vector2(-6, -7), r * 0.42, Color(1.0, 1.0, 1.0, 0.22))
    draw_string(ThemeDB.fallback_font, pos + Vector2(-22, 6), label, HORIZONTAL_ALIGNMENT_CENTER, 44, 15, Color(0.03, 0.02, 0.01))

func _room_color(room_type: String) -> Color:
    match room_type:
        "fight": return Color(0.90, 0.60, 0.30)
        "elite": return Color(1.0, 0.28, 0.14)
        "treasure": return Color(1.0, 0.82, 0.22)
        "rest": return Color(0.50, 0.95, 0.52)
        "shop": return Color(0.64, 0.72, 1.0)
        "event": return Color(0.78, 0.52, 1.0)
        "shelf_boss": return Color(0.95, 0.42, 0.92)
        "boss": return Color(1.0, 0.18, 0.08)
    return Color(0.86, 0.82, 0.62)

func _room_name(room_type: String) -> String:
    match room_type:
        "fight": return "战斗房"
        "elite": return "精英房"
        "treasure": return "宝箱房"
        "rest": return "休息房"
        "shop": return "商店房"
        "event": return "事件房"
        "shelf_boss": return "区域Boss"
        "boss": return "最终Boss"
    return room_type

func _room_hint(room_type: String) -> String:
    match room_type:
        "fight": return "稳妥奖励"
        "elite": return "高危高香"
        "treasure": return "免费配料"
        "rest": return "回血喘口气"
        "shop": return "花金币构筑"
        "event": return "问号小剧场"
        "shelf_boss": return "货架入口"
        "boss": return "点亮信标"
    return "未知节点"
