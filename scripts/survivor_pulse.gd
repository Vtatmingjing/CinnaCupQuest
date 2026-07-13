extends Node2D
class_name CinnaSurvivorPulse

var pulse_radius := 80.0
var pulse_color := Color(1.0, 0.36, 0.08, 0.30)
var life := 0.34
var max_life := 0.34

func _ready() -> void:
    add_to_group("survivor_pulses")

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
    var soft := col
    soft.a *= 0.22
    draw_circle(Vector2.ZERO, radius * 0.74, soft)
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 72, col, 5.5)
    draw_arc(Vector2.ZERO, radius * 0.72, 0.0, TAU, 64, col.lightened(0.24), 3.0)
    draw_arc(Vector2.ZERO, radius * 0.42, 0.0, TAU, 48, col.lightened(0.45), 2.0)
    for i in range(10):
        var angle := TAU * float(i) / 10.0 + t * 1.6
        var inner := Vector2(cos(angle), sin(angle)) * radius * 0.36
        var outer := Vector2(cos(angle), sin(angle)) * radius * (0.55 + 0.28 * t)
        var ray_col := col.lightened(0.38)
        ray_col.a *= 0.60
        draw_line(inner, outer, ray_col, 2.0)
