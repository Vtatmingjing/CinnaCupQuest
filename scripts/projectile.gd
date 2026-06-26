extends Area2D
class_name CinnaProjectile

var velocity := Vector2.ZERO
var damage := 1
var ttl := 2.0
var body_color := Color(1.0, 0.75, 0.20)
var label := ""
var spin := 0.0

func _ready() -> void:
    collision_layer = 32
    collision_mask = 1 | 2
    body_entered.connect(_on_body_entered)
    var shape := RectangleShape2D.new()
    shape.size = Vector2(22, 14)
    var col := CollisionShape2D.new()
    col.shape = shape
    add_child(col)
    queue_redraw()

func setup(new_velocity: Vector2, new_damage := 1, new_color := Color(1.0, 0.75, 0.20), new_ttl := 2.0, new_label := "") -> void:
    velocity = new_velocity
    damage = new_damage
    body_color = new_color
    ttl = new_ttl
    label = new_label
    queue_redraw()

func _process(delta: float) -> void:
    ttl -= delta
    if ttl <= 0.0:
        queue_free()
        return
    position += velocity * delta
    spin += delta * 11.0
    queue_redraw()

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player") and body.has_method("take_damage"):
        body.take_damage(damage, global_position.x)
        queue_free()
    elif body is StaticBody2D:
        queue_free()

func _draw() -> void:
    var outline := Color(0.04, 0.025, 0.018)
    var dir := 1.0 if velocity.x >= 0.0 else -1.0
    var wobble := sin(spin) * 2.0
    draw_rect(Rect2(-13, -9 + wobble, 26, 18), outline)
    draw_rect(Rect2(-9, -6 + wobble, 18, 12), body_color)
    draw_rect(Rect2(7 * dir, -3 + wobble, 10 * dir, 6), body_color.lightened(0.35))
    if label != "":
        draw_string(ThemeDB.fallback_font, Vector2(-7, 5 + wobble), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, outline)
