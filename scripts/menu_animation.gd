extends Control
class_name CinnaMenuAnimation

var t := 0.0
var enabled := false

func _ready() -> void:
    size = Vector2(540, 960)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(false)
    visible = false

func set_enabled(value: bool) -> void:
    enabled = value
    visible = value
    set_process(value)
    queue_redraw()

func _process(delta: float) -> void:
    if not enabled:
        return
    t += delta
    queue_redraw()

func _draw() -> void:
    if not enabled:
        return
    draw_rect(Rect2(0, 0, 540, 960), Color(0.025, 0.016, 0.012, 0.72))
    _draw_bubble_orbits()
    _draw_title_mug()
    _draw_pixel_confetti()

func _draw_title_mug() -> void:
    var bob := sin(t * 1.8) * 5.0
    var mug := Vector2(270, 550 + bob)
    draw_rect(Rect2(mug.x - 92, mug.y - 112, 184, 178), Color(0.02, 0.018, 0.015, 0.58))
    draw_rect(Rect2(mug.x - 82, mug.y - 102, 164, 158), Color(0.72, 0.94, 1.0, 0.18))
    draw_rect(Rect2(mug.x - 73, mug.y - 18, 146, 64), Color(1.0, 0.67, 0.20, 0.52))
    draw_rect(Rect2(mug.x - 64, mug.y - 86, 126, 10), Color(1.0, 1.0, 1.0, 0.30))
    draw_arc(Vector2(mug.x + 92, mug.y - 14), 40, -1.35, 1.35, 18, Color(0.72, 0.94, 1.0, 0.28), 9)
    draw_rect(Rect2(mug.x - 46, mug.y - 4, 24, 14), Color(0.50, 1.0, 0.42, 0.78))
    draw_rect(Rect2(mug.x + 18, mug.y - 46, 32, 18), Color(0.82, 0.96, 1.0, 0.58))

    var flame_y := mug.y - 150 + sin(t * 5.0) * 4.0
    draw_rect(Rect2(mug.x - 8, mug.y - 118, 16, 70), Color(0.78, 0.36, 0.12, 0.82))
    draw_rect(Rect2(mug.x - 18, mug.y - 128, 36, 10), Color(0.06, 0.045, 0.035, 0.92))
    draw_rect(Rect2(mug.x - 5, flame_y, 10, 24), Color(1.0, 0.22, 0.08, 0.86))
    draw_rect(Rect2(mug.x - 2, flame_y - 12, 4, 14), Color(1.0, 0.88, 0.26, 0.86))

func _draw_bubble_orbits() -> void:
    var center := Vector2(270, 510)
    for i in range(16):
        var angle := t * (0.35 + float(i % 5) * 0.06) + float(i) * 0.61
        var radius := 118.0 + float(i % 4) * 34.0
        var p := center + Vector2(cos(angle) * radius, sin(angle * 0.82) * 130.0)
        var s := 4.0 + float(i % 4) * 2.0
        var col := Color(0.74, 0.96, 1.0, 0.18 + float(i % 3) * 0.05)
        if i % 5 == 0:
            col = Color(0.68, 1.0, 0.44, 0.26)
        elif i % 5 == 1:
            col = Color(1.0, 0.76, 0.24, 0.26)
        draw_rect(Rect2(p.x, p.y, s, s), col)
        if i % 3 == 0:
            draw_rect(Rect2(p.x + s + 2, p.y - 2, 3, 3), Color(1.0, 1.0, 1.0, 0.30))

func _draw_pixel_confetti() -> void:
    for i in range(34):
        var x := fmod(float(i * 73) + t * (18.0 + float(i % 5) * 3.0), 560.0) - 10.0
        var y := 170.0 + fmod(float(i * 47) + sin(t + i) * 20.0, 620.0)
        var col := Color(1.0, 0.75, 0.22, 0.28)
        if i % 4 == 1:
            col = Color(0.45, 1.0, 0.48, 0.24)
        elif i % 4 == 2:
            col = Color(0.72, 0.94, 1.0, 0.24)
        elif i % 4 == 3:
            col = Color(1.0, 0.24, 0.10, 0.20)
        draw_rect(Rect2(x, y, 5, 5), col)
