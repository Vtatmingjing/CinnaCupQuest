extends CharacterBody2D
class_name CinnaEnemy

signal died(enemy: CinnaEnemy)
signal projectile_requested(position: Vector2, velocity: Vector2, damage: int, color: Color, ttl: float, label: String)
signal hazard_requested(position: Vector2, kind: String, damage: int)
signal damaged(position: Vector2, amount: int, critical: bool)

const GRAVITY := 1080.0

var kind := "bubble"
var max_health := 2
var health := 2
var speed := 74.0
var damage := 1
var score_value := 80
var boss := false
var body_color := Color(0.62, 0.92, 1.0)
var elite_modifier := ""
var depth_level := 0
var facing := -1
var attack_cooldown := 0.0
var attack_windup := 0.0
var windup_kind := ""
var hurt_flash := 0.0
var phase_timer := 0.0
var jump_timer := 0.0
var touch_cooldown := 0.0

func _ready() -> void:
    add_to_group("enemies")
    collision_layer = 4
    collision_mask = 2 | 1
    var shape := RectangleShape2D.new()
    shape.size = Vector2(28, 28) if not boss else Vector2(72, 86)
    var col := CollisionShape2D.new()
    col.shape = shape
    add_child(col)
    queue_redraw()

func setup(new_kind: String, is_boss := false, new_modifier := "", new_depth := 0) -> void:
    kind = new_kind
    boss = is_boss
    elite_modifier = new_modifier
    depth_level = new_depth
    match kind:
        "bubble":
            max_health = 2; speed = 78; damage = 1; score_value = 75; body_color = Color(0.55, 0.85, 1.0)
        "ice":
            max_health = 3; speed = 46; damage = 1; score_value = 95; body_color = Color(0.86, 0.98, 1.0)
        "lime":
            max_health = 2; speed = 124; damage = 1; score_value = 105; body_color = Color(0.78, 1.0, 0.16)
        "cork":
            max_health = 4; speed = 58; damage = 2; score_value = 140; body_color = Color(0.61, 0.34, 0.17)
        "shelf_boss":
            boss = true; max_health = 13; speed = 82; damage = 2; score_value = 520; body_color = Color(0.72, 0.36, 0.84)
        "boss":
            boss = true; max_health = 18; speed = 70; damage = 2; score_value = 800; body_color = Color(0.88, 0.31, 0.12)
    if boss:
        max_health += depth_level * 3
    else:
        max_health += int(depth_level / 2)
        speed += depth_level * 3.0
        score_value += depth_level * 10

    _apply_elite_modifier()
    health = max_health

func _apply_elite_modifier() -> void:
    match elite_modifier:
        "spicy":
            speed *= 1.18
            damage += 1
            score_value += 45
            body_color = body_color.lerp(Color(1.0, 0.22, 0.06), 0.42)
        "frosted":
            max_health += 2
            speed *= 0.86
            score_value += 40
            body_color = body_color.lerp(Color(0.75, 0.97, 1.0), 0.55)
        "bubbly":
            max_health += 1
            speed *= 1.08
            score_value += 35
            body_color = body_color.lerp(Color(0.58, 0.82, 1.0), 0.45)

func _physics_process(delta: float) -> void:
    touch_cooldown = maxf(0.0, touch_cooldown - delta)
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    hurt_flash = maxf(0.0, hurt_flash - delta)
    phase_timer += delta
    jump_timer = maxf(0.0, jump_timer - delta)

    var player := _find_player()
    if player == null:
        return

    if not is_on_floor():
        velocity.y += GRAVITY * delta

    if attack_windup > 0.0:
        attack_windup -= delta
        velocity.x = 0.0
        if attack_windup <= 0.0:
            _release_attack(player)
        move_and_slide()
        queue_redraw()
        return

    var dx := player.global_position.x - global_position.x
    if absf(dx) > 5.0:
        facing = 1 if dx > 0.0 else -1

    if _should_start_attack(player):
        _begin_attack(player)
    else:
        _move_toward_player(delta, player)

    move_and_slide()

    if _touches_player(player) and touch_cooldown <= 0.0 and kind == "bubble":
        touch_cooldown = 0.95
        if player.has_method("take_damage"):
            player.take_damage(damage, global_position.x)

    queue_redraw()

func _move_toward_player(delta: float, player: Node2D) -> void:
    var dx := player.global_position.x - global_position.x
    var target_speed := signf(dx) * speed if absf(dx) > 16.0 else 0.0
    if kind == "ice":
        target_speed *= 0.75
    if boss and phase_timer > 2.2:
        target_speed *= 0.55
    velocity.x = move_toward(velocity.x, target_speed, 880.0 * delta)

    if is_on_floor():
        if kind == "lime" and jump_timer <= 0.0 and absf(dx) < 240.0:
            velocity.y = -315.0
            jump_timer = randf_range(1.0, 1.6)
        elif elite_modifier == "bubbly" and jump_timer <= 0.0:
            velocity.y = -260.0
            jump_timer = randf_range(1.2, 2.0)
        elif boss and jump_timer <= 0.0 and randf() < 0.020:
            velocity.y = -420.0
            jump_timer = 1.6

func _should_start_attack(player: Node2D) -> bool:
    if attack_cooldown > 0.0:
        return false
    var dist := global_position.distance_to(player.global_position)
    if boss:
        if kind == "shelf_boss":
            return phase_timer >= 1.10
        return phase_timer >= 1.35
    match kind:
        "ice":
            return dist < 310.0
        "lime":
            return dist < 185.0
        "cork":
            return dist < 235.0
        _:
            return dist < 52.0

func _begin_attack(player: Node2D) -> void:
    phase_timer = 0.0
    match kind:
        "ice":
            windup_kind = "ice_shot"
            attack_windup = 0.58
            attack_cooldown = 1.85
        "lime":
            windup_kind = "lime_dash"
            attack_windup = 0.38
            attack_cooldown = 1.25
        "cork":
            windup_kind = "cork_pop"
            attack_windup = 0.50
            attack_cooldown = 1.65
        "shelf_boss":
            var shelf_choices := ["shelf_cork_rain", "shelf_elevator_slam", "shelf_bottle_beam"]
            windup_kind = shelf_choices[randi() % shelf_choices.size()]
            attack_windup = 0.60
            attack_cooldown = 0.70
        "boss":
            var choices := ["boss_volley", "boss_hazard", "boss_spice_jump"]
            windup_kind = choices[randi() % choices.size()]
            attack_windup = 0.72
            attack_cooldown = 0.75
        _:
            windup_kind = "bubble_bump"
            attack_windup = 0.25
            attack_cooldown = 0.85

func _release_attack(player: Node2D) -> void:
    var dir := Vector2(facing, 0)
    match windup_kind:
        "ice_shot":
            projectile_requested.emit(global_position + Vector2(facing * 22, -12), dir * 260.0, damage, Color(0.74, 0.95, 1.0), 2.2, "I")
        "lime_dash":
            velocity.x = facing * 420.0
            velocity.y = minf(velocity.y, -80.0)
            if global_position.distance_to(player.global_position) < 72.0 and player.has_method("take_damage"):
                player.take_damage(damage, global_position.x)
        "cork_pop":
            projectile_requested.emit(global_position + Vector2(facing * 24, -16), dir * 320.0, damage, Color(0.74, 0.39, 0.17), 1.8, "C")
        "boss_volley":
            for angle in [-0.26, 0.0, 0.26]:
                var v := Vector2(facing, angle).normalized() * 300.0
                projectile_requested.emit(global_position + Vector2(facing * 42, -20), v, damage, Color(1.0, 0.36, 0.09), 2.5, "!")
        "boss_hazard":
            hazard_requested.emit(player.global_position + Vector2(0, 28), "ember", damage)
            hazard_requested.emit(Vector2(clampf(player.global_position.x + facing * 90, 90, 450), 846), "syrup", 1)
        "boss_spice_jump":
            velocity.y = -440.0
            hazard_requested.emit(Vector2(clampf(player.global_position.x, 90, 450), 840), "ice_spike", damage)
        "shelf_cork_rain":
            for offset in [-96, 0, 96]:
                projectile_requested.emit(Vector2(clampf(player.global_position.x + offset, 80, 460), global_position.y - 92), Vector2(0, 260), damage, Color(0.78, 0.45, 0.20), 2.1, "↓")
        "shelf_elevator_slam":
            velocity.y = -360.0
            hazard_requested.emit(Vector2(clampf(player.global_position.x, 90, 450), 842), "syrup", damage)
            hazard_requested.emit(Vector2(clampf(player.global_position.x + facing * 100, 90, 450), 842), "syrup", 1)
        "shelf_bottle_beam":
            projectile_requested.emit(global_position + Vector2(facing * 42, -24), Vector2(facing * 360, -40), damage, Color(0.86, 0.50, 1.0), 2.0, "B")
            projectile_requested.emit(global_position + Vector2(facing * 42, -6), Vector2(facing * 360, 40), damage, Color(0.86, 0.50, 1.0), 2.0, "B")
        _:
            if global_position.distance_to(player.global_position) < 60.0 and player.has_method("take_damage"):
                player.take_damage(damage, global_position.x)
    if elite_modifier == "spicy" and not boss:
        hazard_requested.emit(global_position + Vector2(facing * 38, 32), "syrup", 1)

func _touches_player(player: Node2D) -> bool:
    return global_position.distance_to(player.global_position) < (50.0 if boss else 32.0)

func take_damage(amount: int, source_pos := Vector2.ZERO, critical := false) -> void:
    var final_amount := amount
    if elite_modifier == "frosted" and not critical:
        final_amount = maxi(1, final_amount - 1)
    health -= final_amount
    hurt_flash = 0.11
    if source_pos != Vector2.ZERO:
        var push_dir := 1.0 if global_position.x >= source_pos.x else -1.0
        velocity.x = push_dir * (120.0 if not boss else 55.0)
        velocity.y = minf(velocity.y, -135.0)
    damaged.emit(global_position, final_amount, critical)
    if health <= 0:
        remove_from_group("enemies")
        died.emit(self)
        queue_free()
    else:
        queue_redraw()

func _find_player() -> Node2D:
    var players := get_tree().get_nodes_in_group("player")
    if players.size() == 0:
        return null
    return players[0]

func _draw() -> void:
    var outline := Color(0.04, 0.04, 0.045)
    var draw_color := Color.WHITE if hurt_flash > 0.0 else body_color
    if boss:
        draw_rect(Rect2(-42, -56, 84, 100), outline)
        draw_rect(Rect2(-34, -46, 68, 82), draw_color)
        draw_rect(Rect2(-28, -64, 56, 18), Color(0.72, 0.36, 0.15))
        draw_rect(Rect2(-22, -21, 8, 8), outline)
        draw_rect(Rect2(15, -21, 8, 8), outline)
        draw_rect(Rect2(-22, 4, 44, 8), Color(1.0, 0.80, 0.28))
        if kind == "shelf_boss":
            draw_rect(Rect2(-30, -72, 60, 10), Color(0.20, 0.12, 0.08))
            draw_rect(Rect2(-24, -88, 12, 18), Color(0.92, 0.55, 0.22))
            draw_rect(Rect2(12, -88, 12, 18), Color(0.92, 0.55, 0.22))
            draw_rect(Rect2(-8, -88, 16, 18), Color(0.70, 0.36, 0.92))
        _draw_health_bar(80, -78)
    else:
        draw_rect(Rect2(-18, -20, 36, 36), outline)
        draw_rect(Rect2(-14, -16, 28, 28), draw_color)
        draw_rect(Rect2(-7, -6, 5, 5), outline)
        draw_rect(Rect2(4, -6, 5, 5), outline)
        if kind == "cork":
            draw_rect(Rect2(-18, -25, 36, 8), Color(0.47, 0.24, 0.12))
        if elite_modifier != "":
            _draw_elite_crown()
        if health < max_health:
            _draw_health_bar(36, -30)

    if attack_windup > 0.0:
        _draw_telegraph()

func _draw_health_bar(width: int, y: int) -> void:
    draw_rect(Rect2(-width / 2, y, width, 5), Color(0.14, 0.05, 0.04))
    draw_rect(Rect2(-width / 2, y, width * float(health) / float(max_health), 5), Color(0.95, 0.30, 0.20))

func _draw_elite_crown() -> void:
    var col := Color(1.0, 0.34, 0.12)
    if elite_modifier == "frosted":
        col = Color(0.75, 0.96, 1.0)
    elif elite_modifier == "bubbly":
        col = Color(0.50, 0.78, 1.0)
    draw_rect(Rect2(-14, -31, 28, 5), Color(0.04, 0.03, 0.025))
    draw_rect(Rect2(-11, -35, 6, 8), col)
    draw_rect(Rect2(-2, -39, 6, 12), col.lightened(0.15))
    draw_rect(Rect2(8, -35, 6, 8), col)

func _draw_telegraph() -> void:
    var pulse := 0.45 + sin(attack_windup * 38.0) * 0.18
    var col := Color(1.0, 0.14, 0.08, pulse)
    draw_rect(Rect2(-26, -28, 52, 6), col)
    draw_rect(Rect2(-30, -2, 60, 6), col)
    draw_rect(Rect2(facing * 20, -16, facing * 34, 12), Color(1.0, 0.82, 0.22, pulse))
