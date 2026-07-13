extends Node2D
class_name CinnaSurvivorSpawnRift

var enemy_kind := "voidling"
var elite := false
var boss := false
var rift_radius := 72.0
var rift_color := Color(0.70, 0.20, 1.0, 0.40)
var life := 0.44
var max_life := 0.44

func _ready() -> void:
    if not is_in_group("survivor_spawn_rifts"):
        add_to_group("survivor_spawn_rifts")

func setup(start_pos: Vector2, new_kind: String, was_elite: bool, was_boss: bool, new_radius: float, new_color: Color) -> void:
    if not is_in_group("survivor_spawn_rifts"):
        add_to_group("survivor_spawn_rifts")
    name = "EnemySpawnRift"
    position = start_pos
    enemy_kind = new_kind
    elite = was_elite
    boss = was_boss
    rift_radius = new_radius
    rift_color = new_color
    if boss:
        max_life = 0.84
    elif elite:
        max_life = 0.64
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
    var radius := lerpf(8.0, rift_radius, progress)
    var col := rift_color
    col.a *= 1.0 - progress * 0.78
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 44, col, 3.0 if not boss else 5.0)
    draw_arc(Vector2.ZERO, radius * 0.58, 0.0, TAU, 28, col.lightened(0.22), 1.8 if not boss else 3.0)
    var shard_count := 10 if boss else 7 if elite else 5
    for i in range(shard_count):
        var angle := TAU * float(i) / float(shard_count) - progress * 1.6
        var inner := Vector2(cos(angle), sin(angle)) * radius * 0.26
        var outer := Vector2(cos(angle), sin(angle)) * radius * (0.54 + progress * 0.20)
        draw_line(inner, outer, col.lightened(0.16), 2.0 if not boss else 3.2)
