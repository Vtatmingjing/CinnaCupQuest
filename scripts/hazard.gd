extends Area2D
class_name CinnaHazard

var kind := "syrup"
var damage := 1
var warning_time := 0.55
var active_time := 0.75
var age := 0.0
var hit_cooldown := 0.0
var radius := Vector2(70, 22)
var body_color := Color(1.0, 0.43, 0.10)

func _ready() -> void:
    collision_layer = 64
    collision_mask = 1
    monitoring = true
    var shape := RectangleShape2D.new()
    shape.size = radius
    var col := CollisionShape2D.new()
    col.shape = shape
    add_child(col)
    queue_redraw()

func setup(new_kind := "syrup", new_damage := 1) -> void:
    kind = new_kind
    damage = new_damage
    match kind:
        "syrup":
            warning_time = 0.45
            active_time = 1.35
            radius = Vector2(86, 20)
            body_color = Color(0.95, 0.58, 0.10)
        "ember":
            warning_time = 0.65
            active_time = 0.55
            radius = Vector2(76, 48)
            body_color = Color(1.0, 0.22, 0.06)
        "ice_spike":
            warning_time = 0.70
            active_time = 0.70
            radius = Vector2(58, 64)
            body_color = Color(0.72, 0.95, 1.0)
    if get_child_count() > 0 and get_child(0) is CollisionShape2D:
        var shape := RectangleShape2D.new()
        shape.size = radius
        get_child(0).shape = shape
    queue_redraw()

func _process(delta: float) -> void:
    age += delta
    hit_cooldown = maxf(0.0, hit_cooldown - delta)
    if age >= warning_time + active_time:
        queue_free()
        return
    if _is_active() and hit_cooldown <= 0.0:
        for body in get_overlapping_bodies():
            if body.is_in_group("player") and body.has_method("take_damage"):
                body.take_damage(damage, global_position.x)
                hit_cooldown = 0.55
                break
    queue_redraw()

func _is_active() -> bool:
    return age >= warning_time

func _draw() -> void:
    var outline := Color(0.05, 0.03, 0.02)
    var alpha := 0.38 + sin(age * 22.0) * 0.15
    if not _is_active():
        draw_rect(Rect2(-radius.x / 2, -radius.y / 2, radius.x, radius.y), Color(1.0, 0.15, 0.08, alpha))
        draw_rect(Rect2(-radius.x / 2, -radius.y / 2 - 7, radius.x, 5), Color(1.0, 0.92, 0.35, alpha))
        return

    draw_rect(Rect2(-radius.x / 2 - 3, -radius.y / 2 - 3, radius.x + 6, radius.y + 6), outline)
    match kind:
        "ice_spike":
            draw_rect(Rect2(-24, -31, 14, 62), body_color)
            draw_rect(Rect2(-6, -25, 18, 56), body_color.lightened(0.18))
            draw_rect(Rect2(16, -34, 14, 65), body_color.darkened(0.10))
            draw_rect(Rect2(-30, -38, 10, 10), Color(1.0, 1.0, 1.0, 0.75))
        "ember":
            draw_rect(Rect2(-radius.x / 2, -radius.y / 2, radius.x, radius.y), body_color)
            draw_rect(Rect2(-20, -33, 40, 22), Color(1.0, 0.84, 0.22))
            draw_rect(Rect2(-7, -46, 14, 18), Color(1.0, 0.95, 0.50))
        _:
            draw_rect(Rect2(-radius.x / 2, -radius.y / 2, radius.x, radius.y), body_color)
            draw_rect(Rect2(-radius.x / 2 + 8, -radius.y / 2 + 4, radius.x - 16, 5), Color(1.0, 0.86, 0.28))
