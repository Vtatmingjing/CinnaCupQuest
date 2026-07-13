extends Node2D
class_name CinnaSurvivorProjectile

signal hit_something(position: Vector2, amount: int, color: Color, label: String)

var velocity := Vector2.ZERO
var damage := 1
var radius := 8.0
var ttl := 1.2
var pierce := 0
var from_player := true
var projectile_color := Color(1.0, 0.76, 0.28)
var label := ""
var hit_ids: Dictionary = {}
var spin := 0.0
var trail_points: Array = []

func setup(
        start_pos: Vector2,
        new_velocity: Vector2,
        new_damage: int,
        new_radius: float,
        new_color: Color,
        new_label := "",
        new_pierce := 0,
        new_ttl := 1.2,
        player_owned := true
) -> void:
    position = start_pos
    velocity = new_velocity
    damage = new_damage
    radius = new_radius
    projectile_color = new_color
    label = new_label
    pierce = new_pierce
    ttl = new_ttl
    from_player = player_owned

func _ready() -> void:
    add_to_group("survivor_projectiles")
    queue_redraw()

func _process(delta: float) -> void:
    ttl -= delta
    spin += delta * 9.0
    position += velocity * delta
    trail_points.push_front(global_position)
    if trail_points.size() > 5:
        trail_points.pop_back()
    if ttl <= 0.0:
        queue_free()
        return
    if from_player:
        _check_enemy_hits()
    else:
        _check_player_hit()
    queue_redraw()

func _check_enemy_hits() -> void:
    for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        var id := enemy.get_instance_id()
        if hit_ids.has(id):
            continue
        var enemy_radius := 18.0
        var enemy_hit_radius = enemy.get("hit_radius")
        if enemy_hit_radius != null:
            enemy_radius = float(enemy_hit_radius)
        if global_position.distance_to(enemy.global_position) <= radius + enemy_radius:
            hit_ids[id] = true
            if enemy.has_method("take_damage"):
                enemy.take_damage(damage, global_position, false)
                hit_something.emit(global_position, damage, projectile_color, label)
                _apply_on_hit_effect(enemy)
            if pierce <= 0:
                queue_free()
                return
            pierce -= 1

func _check_player_hit() -> void:
    var players := get_tree().get_nodes_in_group("survivor_player")
    if players.size() == 0:
        return
    var player = players[0]
    if not is_instance_valid(player):
        return
    var player_radius := 16.0
    var player_hit_radius = player.get("hit_radius")
    if player_hit_radius != null:
        player_radius = float(player_hit_radius)
    if global_position.distance_to(player.global_position) <= radius + player_radius:
        if player.has_method("take_damage"):
            player.take_damage(damage, global_position)
        queue_free()

func _draw() -> void:
    _draw_trail()
    if from_player:
        _draw_player_projectile()
    else:
        _draw_enemy_projectile()

func _draw_trail() -> void:
    if trail_points.size() < 2:
        return
    for i in range(1, trail_points.size()):
        var p: Vector2 = trail_points[i] - global_position
        var prev: Vector2 = trail_points[i - 1] - global_position
        var t := 1.0 - float(i) / float(trail_points.size())
        var col := projectile_color if from_player else Color(1.0, 0.12, 0.42)
        col.a = 0.08 + t * (0.28 if from_player else 0.30)
        draw_line(p, prev, col, maxf(2.0, radius * (0.35 + t * 0.35)))

func _draw_player_projectile() -> void:
    var outline := Color(0.04, 0.025, 0.015)
    draw_circle(Vector2.ZERO, radius + 6.0 + sin(spin * 1.8) * 1.5, Color(projectile_color.r, projectile_color.g, projectile_color.b, 0.16))
    draw_circle(Vector2.ZERO, radius + 2.0, outline)
    draw_circle(Vector2.ZERO, radius, projectile_color)
    draw_circle(Vector2(-radius * 0.28, -radius * 0.35), radius * 0.32, projectile_color.lightened(0.48))
    draw_rect(Rect2(Vector2(cos(spin), sin(spin)) * -radius * 0.65, Vector2(radius * 1.3, 3.0)), projectile_color.lightened(0.25))
    if label == "*" or label == "C":
        var points := []
        for i in range(8):
            var r := radius + (4.0 if i % 2 == 0 else -1.0)
            var a := spin + TAU * float(i) / 8.0
            points.append(Vector2(cos(a), sin(a)) * r)
        draw_polygon(points, [projectile_color.lightened(0.20)])

func _draw_enemy_projectile() -> void:
    var warning := Color(1.0, 0.10, 0.38)
    var core := Color(0.72, 0.04, 0.12)
    var outline := Color(0.05, 0.00, 0.06)
    var pulse := 1.0 + sin(spin * 2.1) * 0.12
    var r := (radius + 4.5) * pulse
    draw_circle(Vector2.ZERO, r + 6.0, Color(1.0, 0.06, 0.18, 0.06))
    var diamond := [
        Vector2(0.0, -r),
        Vector2(r, 0.0),
        Vector2(0.0, r),
        Vector2(-r, 0.0)
    ]
    draw_polygon(diamond, [outline])
    draw_polygon([
        Vector2(0.0, -r + 3.0),
        Vector2(r - 3.0, 0.0),
        Vector2(0.0, r - 3.0),
        Vector2(-r + 3.0, 0.0)
    ], [warning])
    draw_circle(Vector2.ZERO, maxf(3.0, radius * 0.52), core)
    draw_line(Vector2(-r * 0.42, 0.0), Vector2(r * 0.42, 0.0), Color(1.0, 0.78, 0.72, 0.82), 2.0)
    draw_line(Vector2(0.0, -r * 0.42), Vector2(0.0, r * 0.42), Color(1.0, 0.78, 0.72, 0.82), 2.0)

func _apply_on_hit_effect(primary_enemy: Node) -> void:
    if not from_player:
        return
    match label:
        "fishbones":
            _splash_damage(primary_enemy, 62.0 + radius * 2.2, maxi(1, ceili(float(damage) * 0.55)))
        "death_rocket":
            _splash_damage(primary_enemy, 118.0 + radius * 2.8, maxi(2, ceili(float(damage) * 0.85)))
        "teemo_dart":
            if primary_enemy.has_method("apply_poison"):
                primary_enemy.apply_poison(4.0, maxi(1, ceili(float(damage) * 0.36)))
        "blind_dart":
            if primary_enemy.has_method("apply_weaken"):
                primary_enemy.apply_weaken(2.2)
            if primary_enemy.has_method("apply_slow"):
                primary_enemy.apply_slow(1.2, 0.72)
        "senna_snare":
            if primary_enemy.has_method("apply_root"):
                primary_enemy.apply_root(0.82)
        "viktor_laser":
            if primary_enemy.has_method("apply_slow"):
                primary_enemy.apply_slow(0.8, 0.62)
        "xayah_recall":
            if primary_enemy.has_method("apply_root"):
                primary_enemy.apply_root(0.64)
        _:
            pass

func _splash_damage(primary_enemy: Node, splash_radius: float, splash_damage: int) -> void:
    var primary_id := primary_enemy.get_instance_id()
    for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        if enemy.get_instance_id() == primary_id:
            continue
        var enemy_radius := 18.0
        var enemy_hit_radius = enemy.get("hit_radius")
        if enemy_hit_radius != null:
            enemy_radius = float(enemy_hit_radius)
        if global_position.distance_to(enemy.global_position) <= splash_radius + enemy_radius:
            if enemy.has_method("take_damage"):
                enemy.take_damage(splash_damage, global_position, false)
                hit_something.emit(enemy.global_position, splash_damage, projectile_color, label)
