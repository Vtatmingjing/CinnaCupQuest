extends Area2D
class_name CinnaDoor

signal entered

var is_open := false
var label := "NEXT"

func _ready() -> void:
    collision_layer = 16
    collision_mask = 1
    body_entered.connect(_on_body_entered)
    var shape := RectangleShape2D.new()
    shape.size = Vector2(58, 82)
    var col := CollisionShape2D.new()
    col.shape = shape
    add_child(col)
    queue_redraw()

func set_open(value: bool) -> void:
    is_open = value
    queue_redraw()

func _on_body_entered(body: Node) -> void:
    if is_open and body.is_in_group("player"):
        entered.emit()

func _draw() -> void:
    var outline := Color(0.04, 0.035, 0.03)
    var closed := Color(0.22, 0.12, 0.07)
    var open_col := Color(1.0, 0.77, 0.18)
    draw_rect(Rect2(-31, -44, 62, 88), outline)
    draw_rect(Rect2(-25, -38, 50, 76), open_col if is_open else closed)
    if is_open:
        draw_rect(Rect2(-14, -25, 28, 50), Color(0.20, 0.08, 0.05))
        draw_rect(Rect2(-5, -6, 10, 12), Color(0.95, 0.95, 0.72))
    else:
        draw_rect(Rect2(-18, -6, 36, 9), Color(0.72, 0.36, 0.15))
    draw_string(ThemeDB.fallback_font, Vector2(-27, -52), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.93, 0.65))
