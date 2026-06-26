extends Node2D
class_name CinnaSurvivorPlayer

signal died
signal stats_changed
signal damaged(position: Vector2, amount: int)
signal leveled_up
signal projectile_requested(position: Vector2, velocity: Vector2, damage: int, radius: float, color: Color, label: String, pierce: int, ttl: float)
signal pulse_requested(position: Vector2, radius: float, damage: int, color: Color)

const CharacterData := preload("res://scripts/character_data.gd")

const ARENA := Rect2(28, 92, 484, 790)
const BASE_SPEED := 188.0
const BASE_ATTACK_COOLDOWN := 0.62

var max_health := 6
var health := 6
var shield := 0
var speed := BASE_SPEED
var damage := 1
var score := 0
var gold := 0
var level := 1
var xp := 0
var xp_to_next := 8
var pending_levels := 0
var inventory: Dictionary = {}

var character_id := "bartender"
var body_color := Color(0.95, 0.74, 0.35)
var apron_color := Color(0.52, 0.94, 0.62)
var hat_color := Color(0.96, 0.96, 0.86)

var attack_cooldown := BASE_ATTACK_COOLDOWN
var attack_timer := 0.0
var skill_timer := 0.0
var invincible_timer := 0.0
var aura_timer := 0.0
var orbit_timer := 0.0
var walk_timer := 0.0
var facing := Vector2.RIGHT
var controls_enabled := false

var hit_radius := 15.0
var pickup_radius := 21.0
var magnet_radius := 92.0
var crit_chance := 0.08
var projectile_speed := 430.0
var projectile_radius := 7.0
var pierce_bonus := 0
var lime_level := 0
var aura_level := 0
var orbit_count := 0
var cooldown_mult := 1.0
var skill_power := 0
var regen_timer := 0.0

func _ready() -> void:
    add_to_group("survivor_player")
    set_process(true)
    queue_redraw()

func reset_run(new_character_id := "bartender") -> void:
    max_health = 6
    health = 6
    shield = 0
    speed = BASE_SPEED
    damage = 1
    score = 0
    gold = 0
    level = 1
    xp = 0
    xp_to_next = 8
    pending_levels = 0
    inventory.clear()
    attack_cooldown = BASE_ATTACK_COOLDOWN
    attack_timer = 0.0
    skill_timer = 0.0
    invincible_timer = 0.0
    aura_timer = 0.0
    orbit_timer = 0.0
    walk_timer = 0.0
    facing = Vector2.RIGHT
    hit_radius = 15.0
    pickup_radius = 21.0
    magnet_radius = 92.0
    crit_chance = 0.08
    projectile_speed = 430.0
    projectile_radius = 7.0
    pierce_bonus = 0
    lime_level = 0
    aura_level = 0
    orbit_count = 0
    cooldown_mult = 1.0
    skill_power = 0
    regen_timer = 0.0
    position = ARENA.get_center()
    apply_character(new_character_id)
    stats_changed.emit()
    queue_redraw()

func apply_character(new_character_id: String) -> void:
    character_id = new_character_id if CharacterData.has_character(new_character_id) else "bartender"
    var data := CharacterData.get_data(character_id)
    body_color = data.get("body_color", body_color)
    apron_color = data.get("apron_color", apron_color)
    hat_color = data.get("hat_color", hat_color)
    max_health = maxi(1, max_health + int(data.get("health_bonus", 0)))
    health = max_health
    shield += int(data.get("shield_bonus", 0))
    speed *= float(data.get("speed_mult", 1.0))
    damage += int(data.get("damage_bonus", 0))
    gold += int(data.get("gold_bonus", 0))
    match character_id:
        "ice_knight":
            shield += 1
            pierce_bonus += 1
        "mint_ninja":
            magnet_radius += 26.0
            crit_chance += 0.06
        "lemon_gunner":
            lime_level = 1
            projectile_speed += 55.0
            crit_chance += 0.08
        _:
            add_upgrade("honey_drop")

func set_controls_enabled(value: bool) -> void:
    controls_enabled = value

func _process(delta: float) -> void:
    attack_timer = maxf(0.0, attack_timer - delta)
    skill_timer = maxf(0.0, skill_timer - delta)
    invincible_timer = maxf(0.0, invincible_timer - delta)
    aura_timer = maxf(0.0, aura_timer - delta)
    orbit_timer = maxf(0.0, orbit_timer - delta)
    regen_timer += delta
    if controls_enabled:
        _move(delta)
        _tick_weapons(delta)
    queue_redraw()

func _move(delta: float) -> void:
    var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if dir.length() > 0.01:
        facing = dir.normalized()
        walk_timer += delta
    var target := position + dir * speed * delta
    target.x = clampf(target.x, ARENA.position.x, ARENA.end.x)
    target.y = clampf(target.y, ARENA.position.y, ARENA.end.y)
    position = target

func _tick_weapons(_delta: float) -> void:
    var target := _nearest_enemy()
    if attack_timer <= 0.0 and target != null:
        attack_timer = attack_cooldown * cooldown_mult
        _fire_spoon(target.global_position)
    if aura_level > 0 and aura_timer <= 0.0:
        aura_timer = maxf(0.62, 1.25 - aura_level * 0.08)
        pulse_requested.emit(global_position, 72.0 + aura_level * 12.0, damage + aura_level + skill_power, Color(1.0, 0.36, 0.10, 0.32))
    if orbit_count > 0 and orbit_timer <= 0.0:
        orbit_timer = 0.34
        _tick_orbits()

func _fire_spoon(target_pos: Vector2) -> void:
    var dir := target_pos - global_position
    if dir.length() < 1.0:
        dir = facing
    dir = dir.normalized()
    facing = dir
    var final_damage := damage
    if randf() < crit_chance:
        final_damage *= 2
    projectile_requested.emit(global_position + dir * 21.0, dir * projectile_speed, final_damage, projectile_radius, Color(1.0, 0.77, 0.28), "S", pierce_bonus, 1.45)
    if lime_level > 0:
        var spread := 0.16 + lime_level * 0.035
        for side in [-1, 1]:
            var lime_dir := dir.rotated(spread * side)
            projectile_requested.emit(global_position + lime_dir * 18.0, lime_dir * (projectile_speed + 30.0), maxi(1, final_damage - 1 + int(lime_level / 2)), 6.0, Color(0.78, 1.0, 0.16), "L", maxi(0, pierce_bonus - 1), 1.25)
        if lime_level >= 3:
            projectile_requested.emit(global_position - dir * 8.0, -dir * (projectile_speed * 0.75), maxi(1, damage), 5.5, Color(0.78, 1.0, 0.16), "L", 0, 1.0)

func _tick_orbits() -> void:
    var angle_base := Time.get_ticks_msec() / 1000.0 * 2.8
    for i in range(orbit_count):
        var angle := angle_base + TAU * float(i) / float(maxi(orbit_count, 1))
        var orb_pos := global_position + Vector2(cos(angle), sin(angle)) * 46.0
        for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
            if not is_instance_valid(enemy):
                continue
            if orb_pos.distance_to(enemy.global_position) <= 22.0:
                if enemy.has_method("take_damage"):
                    enemy.take_damage(maxi(1, damage + int(orbit_count / 2)), orb_pos, false)

func _nearest_enemy() -> Node2D:
    var best: Node2D = null
    var best_dist := INF
    for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        var dist := global_position.distance_squared_to(enemy.global_position)
        if dist < best_dist:
            best = enemy
            best_dist = dist
    return best

func take_damage(amount: int, source_pos := Vector2.ZERO) -> void:
    if invincible_timer > 0.0:
        return
    invincible_timer = 0.55
    var remaining := amount
    if shield > 0:
        var absorbed := mini(shield, remaining)
        shield -= absorbed
        remaining -= absorbed
    if remaining > 0:
        health -= remaining
    if source_pos != Vector2.ZERO:
        var push := (global_position - source_pos).normalized()
        position += push * 16.0
        position.x = clampf(position.x, ARENA.position.x, ARENA.end.x)
        position.y = clampf(position.y, ARENA.position.y, ARENA.end.y)
    damaged.emit(global_position, amount)
    stats_changed.emit()
    if health <= 0:
        died.emit()

func heal(amount: int) -> void:
    health = mini(max_health, health + amount)
    stats_changed.emit()

func add_score(points: int) -> void:
    score += points
    stats_changed.emit()

func add_gold(amount: int) -> void:
    gold += amount
    stats_changed.emit()

func add_xp(amount: int) -> void:
    xp += amount
    while xp >= xp_to_next:
        xp -= xp_to_next
        level += 1
        xp_to_next = int(round(float(xp_to_next) * 1.22 + 4.0))
        pending_levels += 1
    stats_changed.emit()
    if pending_levels > 0:
        leveled_up.emit()

func consume_pending_level() -> void:
    pending_levels = maxi(0, pending_levels - 1)

func add_upgrade(upgrade_id: String) -> void:
    inventory[upgrade_id] = int(inventory.get(upgrade_id, 0)) + 1
    match upgrade_id:
        "mint_leaf":
            speed *= 1.11
            magnet_radius += 8.0
        "ice_cube":
            shield += 2
        "cinnamon_stick":
            damage += 1
        "lime_zest":
            lime_level += 1
            crit_chance += 0.02
        "almond_syrup":
            cooldown_mult = maxf(0.48, cooldown_mult * 0.90)
        "bubble_water":
            orbit_count = mini(6, orbit_count + 1)
        "ember_spark":
            aura_level += 1
        "honey_drop":
            max_health += 1
            heal(2)
        "tonic_splash":
            skill_power += 1
            projectile_radius += 0.7
        "glass_rim":
            pierce_bonus += 1
        "star_anise":
            crit_chance = minf(0.55, crit_chance + 0.10)
        _:
            damage += 1
    stats_changed.emit()
    queue_redraw()

func get_upgrade_summary() -> String:
    if inventory.is_empty():
        return "none"
    var parts := []
    for key in inventory.keys():
        parts.append("%s x%d" % [str(key).replace("_", " "), int(inventory[key])])
    parts.sort()
    var text := ""
    for i in range(parts.size()):
        if i > 0:
            text += ", "
        text += str(parts[i])
    return text

func get_xp_fill() -> float:
    return clampf(float(xp) / float(maxi(1, xp_to_next)), 0.0, 1.0)

func _draw() -> void:
    if invincible_timer > 0.0 and int(invincible_timer * 18.0) % 2 == 0:
        return
    var outline := Color(0.04, 0.03, 0.025)
    var bob := sin(walk_timer * 12.0) * 2.0
    draw_circle(Vector2(0, 12), 15, Color(0.02, 0.015, 0.01, 0.35))
    draw_rect(Rect2(-14, -26 + bob, 28, 39), outline)
    draw_rect(Rect2(-10, -23 + bob, 20, 33), body_color)
    draw_rect(Rect2(-8, -10 + bob, 16, 16), apron_color)
    draw_rect(Rect2(-8, -34 + bob, 16, 9), hat_color)
    draw_rect(Rect2(-5, -17 + bob, 4, 4), outline)
    draw_rect(Rect2(4, -17 + bob, 4, 4), outline)
    var tool_end := facing.normalized() * 31.0
    draw_line(Vector2(0, -9 + bob), tool_end + Vector2(0, -9 + bob), Color(0.95, 0.20, 0.08), 5.0)
    draw_circle(tool_end + Vector2(0, -9 + bob), 5.5, Color(1.0, 0.82, 0.22))
    if shield > 0:
        draw_arc(Vector2.ZERO, 25.0, 0.0, TAU, 32, Color(0.70, 0.96, 1.0, 0.32), 3.0)
    if orbit_count > 0:
        var angle_base := Time.get_ticks_msec() / 1000.0 * 2.8
        for i in range(orbit_count):
            var angle := angle_base + TAU * float(i) / float(maxi(orbit_count, 1))
            draw_circle(Vector2(cos(angle), sin(angle)) * 46.0, 6.0, Color(0.44, 0.80, 1.0, 0.85))
