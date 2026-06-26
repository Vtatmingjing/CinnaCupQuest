extends Node2D
class_name CinnaSurvivorProjectile

signal hit_something(position: Vector2, amount: int)

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
                hit_something.emit(global_position, damage)
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
    var outline := Color(0.04, 0.025, 0.015)
    draw_circle(Vector2.ZERO, radius + 2.0, outline)
    draw_circle(Vector2.ZERO, radius, projectile_color)
    draw_rect(Rect2(Vector2(cos(spin), sin(spin)) * -radius * 0.65, Vector2(radius * 1.3, 3.0)), projectile_color.lightened(0.25))
