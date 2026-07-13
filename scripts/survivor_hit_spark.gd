extends Node2D
class_name CinnaSurvivorHitSpark

var spark_label := ""
var spark_family := "physical"
var spark_radius := 52.0
var spark_color := Color(1.0, 0.66, 0.22, 0.48)
var spark_amount := 1
var priority := false
var life := 0.24
var max_life := 0.24

func _ready() -> void:
    if not is_in_group("survivor_hit_sparks"):
        add_to_group("survivor_hit_sparks")

func setup(start_pos: Vector2, label: String, family: String, amount: int, radius: float, color: Color, important := false) -> void:
    if not is_in_group("survivor_hit_sparks"):
        add_to_group("survivor_hit_sparks")
    name = "HitSpark"
    position = start_pos
    spark_label = label
    spark_family = family
    spark_amount = amount
    spark_radius = radius
    spark_color = color
    priority = important
    max_life = 0.32 if priority else 0.24
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
    var radius := lerpf(8.0, spark_radius, progress)
    var col := spark_color
    col.a *= 1.0 - progress
    var slash_count := 7 if priority else 5
    for i in range(slash_count):
        var angle := TAU * float(i) / float(slash_count) + progress * 1.6
        var inner := Vector2(cos(angle), sin(angle)) * radius * 0.16
        var outer := Vector2(cos(angle), sin(angle)) * radius * (0.42 + progress * 0.28)
        draw_line(inner, outer, col.lightened(0.16), 2.4 if priority else 1.8)
    draw_arc(Vector2.ZERO, radius * 0.58, 0.0, TAU, 28, col, 2.0 if priority else 1.4)
