extends Node2D
class_name CinnaSkillBurst

var life := 0.34
var max_life := 0.34
var burst_color := Color(1.0, 0.82, 0.28)
var burst_radius := 96.0
var kind := "shaker_burst"

func setup(new_kind: String, color: Color, radius: float) -> void:
    kind = new_kind
    burst_color = color
    burst_radius = radius
    queue_redraw()

func _process(delta: float) -> void:
    life -= delta
    if life <= 0.0:
        queue_free()
        return
    queue_redraw()

func _draw() -> void:
    var t := 1.0 - clampf(life / max_life, 0.0, 1.0)
    var r := lerpf(18.0, burst_radius, t)
    var alpha := 0.75 * (1.0 - t)
    var col := Color(burst_color.r, burst_color.g, burst_color.b, alpha)
    draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, col, 5.0)
    draw_arc(Vector2.ZERO, r * 0.62, 0.0, TAU, 24, Color(col.r, col.g, col.b, alpha * 0.65), 3.0)
    if kind == "mint_blink":
        draw_rect(Rect2(-burst_radius * 0.55, -8, burst_radius * 1.1, 16), Color(0.38, 1.0, 0.48, alpha * 0.65))
    elif kind == "lime_barrage":
        for y in [-22, 0, 22]:
            draw_rect(Rect2(0, y - 4, burst_radius * 1.25, 8), Color(0.84, 1.0, 0.18, alpha * 0.72))
            draw_rect(Rect2(burst_radius * 0.72, y - 8, 18, 16), Color(1.0, 0.96, 0.20, alpha))
    elif kind == "ice_guard":
        for i in range(6):
            var angle := TAU * float(i) / 6.0
            var p := Vector2(cos(angle), sin(angle)) * r * 0.75
            draw_rect(Rect2(p.x - 5, p.y - 5, 10, 10), Color(0.74, 0.96, 1.0, alpha))
    else:
        for i in range(8):
            var angle2 := TAU * float(i) / 8.0
            var p2 := Vector2(cos(angle2), sin(angle2)) * r * 0.82
            draw_rect(Rect2(p2.x - 4, p2.y - 4, 8, 8), Color(1.0, 0.72, 0.20, alpha))
