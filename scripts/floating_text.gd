extends Node2D
class_name CinnaFloatingText

var text := ""
var body_color := Color(1.0, 0.90, 0.45)
var velocity := Vector2(0, -48)
var life := 0.75
var start_life := 0.75
var font_size := 18

func _ready() -> void:
    add_to_group("survivor_floating_text")

func setup(new_text: String, new_color := Color(1.0, 0.90, 0.45), new_size := 18) -> void:
    text = new_text
    body_color = new_color
    font_size = new_size
    queue_redraw()

func _process(delta: float) -> void:
    life -= delta
    position += velocity * delta
    velocity.y -= 12.0 * delta
    if life <= 0.0:
        queue_free()
    queue_redraw()

func _draw() -> void:
    var a := clampf(life / start_life, 0.0, 1.0)
    var outline := Color(0.02, 0.012, 0.01, a)
    var col := Color(body_color.r, body_color.g, body_color.b, a)
    draw_string(ThemeDB.fallback_font, Vector2(-12, 1), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, outline)
    draw_string(ThemeDB.fallback_font, Vector2(-14, -1), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, col)
