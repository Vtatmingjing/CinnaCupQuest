extends Node2D

var life := 0.14
var facing := 1

func _process(delta: float) -> void:
    life -= delta
    if life <= 0.0:
        queue_free()
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, -7, 42 * facing, 14), Color(1.0, 0.75, 0.18, 0.72))
    draw_rect(Rect2(18 * facing, -17, 10 * facing, 34), Color(1.0, 0.23, 0.08, 0.65))
