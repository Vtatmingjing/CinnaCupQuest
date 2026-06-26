extends Node2D
class_name CinnaSurvivorEnemy

signal died(enemy: CinnaSurvivorEnemy)
signal damaged(position: Vector2, amount: int, critical: bool)
signal projectile_requested(position: Vector2, velocity: Vector2, damage: int, radius: float, color: Color, label: String)

var kind := "bubble"
var max_health := 3
var health := 3
var speed := 70.0
var damage := 1
var score_value := 30
var xp_value := 1
var hit_radius := 16.0
var boss := false
var body_color := Color(0.58, 0.86, 1.0)
var contact_timer := 0.0
var attack_timer := 0.0
var hurt_flash := 0.0
var wobble := 0.0
var wave_level := 1

func setup(new_kind: String, new_wave: int, is_boss := false) -> void:
    kind = new_kind
    wave_level = new_wave
    boss = is_boss
    match kind:
        "bubble":
            max_health = 3; speed = 86; damage = 1; score_value = 28; xp_value = 1; body_color = Color(0.55, 0.85, 1.0)
        "ice":
            max_health = 7; speed = 45; damage = 1; score_value = 45; xp_value = 2; body_color = Color(0.82, 0.97, 1.0)
        "lime":
            max_health = 4; speed = 132; damage = 1; score_value = 42; xp_value = 2; body_color = Color(0.78, 1.0, 0.16)
        "cork":
            max_health = 8; speed = 58; damage = 2; score_value = 72; xp_value = 3; body_color = Color(0.62, 0.36, 0.18)
        "mold":
            max_health = 11; speed = 38; damage = 2; score_value = 88; xp_value = 4; body_color = Color(0.64, 0.88, 0.35)
        "boss":
            boss = true
            max_health = 160 + new_wave * 18
            speed = 62
            damage = 3
            score_value = 1500
            xp_value = 30
            hit_radius = 42
            body_color = Color(0.88, 0.30, 0.12)
        _:
            max_health = 4; speed = 76; damage = 1; score_value = 30; xp_value = 1; body_color = Color(0.55, 0.85, 1.0)
    if not boss:
        max_health += int(new_wave * 0.72)
        speed += minf(55.0, new_wave * 1.9)
        score_value += new_wave * 4
    health = max_health

func _ready() -> void:
    add_to_group("survivor_enemies")
    attack_timer = randf_range(0.5, 2.0)
    queue_redraw()

func _process(delta: float) -> void:
    contact_timer = maxf(0.0, contact_timer - delta)
    attack_timer = maxf(0.0, attack_timer - delta)
    hurt_flash = maxf(0.0, hurt_flash - delta)
    wobble += delta
    var player := _find_player()
    if player == null:
        return
    _move_toward_player(delta, player)
    _try_attack(player)
    var player_radius := 16.0
    var player_hit_radius = player.get("hit_radius")
    if player_hit_radius != null:
        player_radius = float(player_hit_radius)
    if global_position.distance_to(player.global_position) <= hit_radius + player_radius:
        if contact_timer <= 0.0:
            contact_timer = 0.72 if not boss else 0.45
            if player.has_method("take_damage"):
                player.take_damage(damage, global_position)
    queue_redraw()

func _move_toward_player(delta: float, player: Node2D) -> void:
    var dir := player.global_position - global_position
    if dir.length() < 1.0:
        return
    dir = dir.normalized()
    if kind == "lime":
        dir = dir.rotated(sin(wobble * 4.2) * 0.42)
    elif kind == "cork":
        if global_position.distance_to(player.global_position) < 165.0:
            dir = -dir
    position += dir * speed * delta

func _try_attack(player: Node2D) -> void:
    if attack_timer > 0.0:
        return
    var to_player := player.global_position - global_position
    if to_player.length() < 1.0:
        to_player = Vector2.DOWN
    var dir := to_player.normalized()
    match kind:
        "ice":
            attack_timer = 2.6
            projectile_requested.emit(global_position + dir * 22.0, dir * 210.0, damage, 8.0, Color(0.72, 0.95, 1.0), "I")
        "cork":
            attack_timer = 2.1
            projectile_requested.emit(global_position + dir * 24.0, dir * 260.0, damage, 8.0, Color(0.74, 0.40, 0.18), "C")
        "boss":
            attack_timer = 1.35
            var shots := 10
            for i in range(shots):
                var angle := TAU * float(i) / float(shots) + wobble * 0.2
                var v := Vector2(cos(angle), sin(angle)) * 205.0
                projectile_requested.emit(global_position + v.normalized() * 40.0, v, damage, 8.5, Color(1.0, 0.35, 0.08), "!")
        _:
            attack_timer = randf_range(1.4, 2.2)

func take_damage(amount: int, _source_pos := Vector2.ZERO, critical := false) -> void:
    health -= amount
    hurt_flash = 0.10
    damaged.emit(global_position, amount, critical)
    if health <= 0:
        remove_from_group("survivor_enemies")
        died.emit(self)
        queue_free()
    else:
        queue_redraw()

func _find_player() -> Node2D:
    var players := get_tree().get_nodes_in_group("survivor_player")
    if players.size() == 0:
        return null
    return players[0]

func _draw() -> void:
    var outline := Color(0.04, 0.035, 0.035)
    var color := Color.WHITE if hurt_flash > 0.0 else body_color
    if boss:
        draw_circle(Vector2.ZERO, 52.0, outline)
        draw_circle(Vector2.ZERO, 45.0, color)
        draw_rect(Rect2(-30, -58, 60, 16), Color(0.70, 0.36, 0.14))
        draw_circle(Vector2(-16, -10), 5.0, outline)
        draw_circle(Vector2(16, -10), 5.0, outline)
        draw_rect(Rect2(-22, 18, 44, 8), Color(1.0, 0.80, 0.26))
        _draw_health_bar(86, -68)
        return
    var s := 18.0 + sin(wobble * 6.0) * 1.5
    draw_circle(Vector2.ZERO, s + 3.0, outline)
    draw_circle(Vector2.ZERO, s, color)
    draw_circle(Vector2(-6, -4), 3.0, outline)
    draw_circle(Vector2(7, -4), 3.0, outline)
    if kind == "ice":
        draw_rect(Rect2(-12, -22, 24, 7), Color(0.86, 1.0, 1.0))
    elif kind == "lime":
        draw_rect(Rect2(-18, 8, 36, 5), Color(0.45, 0.88, 0.10))
    elif kind == "cork":
        draw_rect(Rect2(-18, -22, 36, 8), Color(0.46, 0.24, 0.12))
    elif kind == "mold":
        draw_circle(Vector2(-12, -12), 5.0, Color(0.36, 0.68, 0.24))
        draw_circle(Vector2(14, 9), 4.0, Color(0.36, 0.68, 0.24))
    if health < max_health:
        _draw_health_bar(36, -28)

func _draw_health_bar(width: int, y: int) -> void:
    draw_rect(Rect2(-width / 2, y, width, 5), Color(0.12, 0.04, 0.035))
    draw_rect(Rect2(-width / 2, y, width * float(maxi(0, health)) / float(max_health), 5), Color(0.95, 0.28, 0.16))
