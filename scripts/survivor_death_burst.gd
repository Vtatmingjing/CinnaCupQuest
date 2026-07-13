extends Node2D
class_name CinnaSurvivorDeathBurst

var enemy_kind := "voidling"
var elite := false
var boss := false
var burst_radius := 80.0
var burst_color := Color(0.72, 0.20, 1.0, 0.42)
var life := 0.46
var max_life := 0.46

func _ready() -> void:
    if not is_in_group("survivor_death_bursts"):
        add_to_group("survivor_death_bursts")

func setup(start_pos: Vector2, new_kind: String, was_elite: bool, was_boss: bool, new_radius: float, new_color: Color) -> void:
    if not is_in_group("survivor_death_bursts"):
        add_to_group("survivor_death_bursts")
    name = "EnemyDeathBurst"
    position = start_pos
    enemy_kind = new_kind
    elite = was_elite
    boss = was_boss
    burst_radius = new_radius
    burst_color = new_color
    if boss:
        max_life = 0.72
    elif elite:
        max_life = 0.58
    life = max_life

func _process(delta: float) -> void:
    life -= delta
    if life <= 0.0:
        queue_free()
        return
    if modulate.a > 0.01:
        queue_redraw()

func _draw() -> void:
    if modulate.a <= 0.01:
        return
    var progress := 1.0 - life / max_life
    var radius := lerpf(12.0, burst_radius, progress)
    var col := burst_color
    col.a *= 1.0 - progress
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, col, 4.0)
    draw_arc(Vector2.ZERO, radius * 0.58, 0.0, TAU, 36, col.lightened(0.26), 2.2)
    var shard_count := 12 if boss else 8 if elite else 5
    for i in range(shard_count):
        var angle := TAU * float(i) / float(shard_count) + progress * 1.2
        var inner := Vector2(cos(angle), sin(angle)) * radius * 0.24
        var outer := Vector2(cos(angle), sin(angle)) * radius * (0.44 + progress * 0.34)
        draw_line(inner, outer, col.lightened(0.18), 2.0 if not boss else 3.0)
