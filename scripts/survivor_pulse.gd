extends Node2D
class_name CinnaSurvivorPulse

var pulse_radius := 80.0
var pulse_color := Color(1.0, 0.36, 0.08, 0.30)
var life := 0.34
var max_life := 0.34

func setup(start_pos: Vector2, new_radius: float, new_color: Color) -> void:
    name = "Pulse"
    position = start_pos
    pulse_radius = new_radius
    pulse_color = new_color

func _process(delta: float) -> void:
    life -= delta
    if life <= 0.0:
        queue_free()
        return
    queue_redraw()

func _draw() -> void:
    var t := 1.0 - life / max_life
    var radius := lerpf(14.0, pulse_radius, t)
    var col := pulse_color
    col.a *= 1.0 - t
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, col, 5.0)
    draw_arc(Vector2.ZERO, radius * 0.72, 0.0, TAU, 64, col.lightened(0.22), 3.0)
