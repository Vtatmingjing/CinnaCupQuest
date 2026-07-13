extends CharacterBody2D
class_name CinnaPlayer

signal died
signal stats_changed
signal attacked(position: Vector2, facing: int)
signal dashed(position: Vector2, facing: int)
signal damaged(position: Vector2, amount: int)
signal hit_enemy(position: Vector2, amount: int, critical: bool)
signal landed(position: Vector2)
signal item_gained(kind: String)
signal recipe_discovered(recipe_id: String)
signal skill_used(skill_id: String, position: Vector2, facing: int)

const RecipeData := preload("res://scripts/recipe_data.gd")
const CharacterData := preload("res://scripts/character_data.gd")

const GRAVITY := 1120.0
const BASE_SPEED := 185.0
const BASE_JUMP := -430.0
const DASH_SPEED := 520.0
const DASH_TIME := 0.13
const BASE_DASH_COOLDOWN := 0.55
const BASE_ATTACK_COOLDOWN := 0.28
const COYOTE_TIME := 0.11
const JUMP_BUFFER_TIME := 0.12

var max_health := 5
var health := 5
var shield := 0
var speed := BASE_SPEED
var damage := 1
var mint_count := 0
var lime_stacks := 0
var cinnamon_stacks := 0
var almond_stacks := 0
var ember_stacks := 0
var zest_stacks := 0
var skill_power_bonus := 0
var skill_cooldown_mult := 1.0
var gold_bonus_rate := 1.0
var has_double_jump := false
var used_double_jump := false
var score := 0
var gold := 20
var inventory: Dictionary = {}
var active_recipes: Dictionary = {}
var hextech_crystals := 0
var hextech_augments: Dictionary = {}
var echo_attack_counter := 0
var character_id := "bartender"
var active_skill_id := "shaker_burst"
var active_skill_name := "摇壶爆发"
var active_skill_cooldown := 5.8
var active_skill_timer := 0.0
var body_color := Color(0.95, 0.74, 0.35)
var apron_color := Color(0.52, 0.94, 0.62)
var hat_color := Color(0.96, 0.96, 0.86)

var facing := 1
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var attack_cooldown_timer := 0.0
var invincible_timer := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var hitstop_timer := 0.0
var land_squash_timer := 0.0
var dash_cooldown_value := BASE_DASH_COOLDOWN
var attack_cooldown_value := BASE_ATTACK_COOLDOWN
var controls_enabled := true
var was_on_floor := false
var attack_flash_timer := 0.0
var skill_flash_timer := 0.0

func _ready() -> void:
    add_to_group("player")
    collision_layer = 1
    collision_mask = 2 | 4
    var shape := RectangleShape2D.new()
    shape.size = Vector2(26, 42)
    var col := CollisionShape2D.new()
    col.shape = shape
    add_child(col)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if hitstop_timer > 0.0:
        hitstop_timer = maxf(0.0, hitstop_timer - delta)
        queue_redraw()
        return

    if not controls_enabled:
        velocity.x = 0.0
        if not is_on_floor():
            velocity.y += GRAVITY * delta
            move_and_slide()
        queue_redraw()
        return

    dash_cooldown_timer = maxf(0.0, dash_cooldown_timer - delta)
    attack_cooldown_timer = maxf(0.0, attack_cooldown_timer - delta)
    active_skill_timer = maxf(0.0, active_skill_timer - delta)
    invincible_timer = maxf(0.0, invincible_timer - delta)
    attack_flash_timer = maxf(0.0, attack_flash_timer - delta)
    skill_flash_timer = maxf(0.0, skill_flash_timer - delta)
    land_squash_timer = maxf(0.0, land_squash_timer - delta)

    if is_on_floor():
        coyote_timer = COYOTE_TIME
        used_double_jump = false
    else:
        coyote_timer = maxf(0.0, coyote_timer - delta)

    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = JUMP_BUFFER_TIME
    else:
        jump_buffer_timer = maxf(0.0, jump_buffer_timer - delta)

    var dir := Input.get_axis("move_left", "move_right")
    if dir != 0:
        facing = 1 if dir > 0.0 else -1

    if dash_timer > 0.0:
        dash_timer -= delta
        velocity.x = facing * DASH_SPEED
        velocity.y = 0.0
    else:
        velocity.x = move_toward(velocity.x, dir * speed, 2400.0 * delta)
        if not is_on_floor():
            velocity.y += GRAVITY * delta

        if jump_buffer_timer > 0.0:
            if is_on_floor() or coyote_timer > 0.0:
                velocity.y = BASE_JUMP
                jump_buffer_timer = 0.0
                coyote_timer = 0.0
            elif has_double_jump and not used_double_jump:
                used_double_jump = true
                velocity.y = BASE_JUMP * 0.88
                jump_buffer_timer = 0.0

        if Input.is_action_just_released("jump") and velocity.y < 0.0:
            velocity.y *= 0.52

        if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0:
            dash_timer = DASH_TIME
            dash_cooldown_timer = dash_cooldown_value
            dashed.emit(global_position, facing)
            _apply_dash_recipe_pulse()

    move_and_slide()

    if not was_on_floor and is_on_floor():
        land_squash_timer = 0.12
        landed.emit(global_position)
    was_on_floor = is_on_floor()

    if Input.is_action_just_pressed("attack") and attack_cooldown_timer <= 0.0:
        attack_cooldown_timer = attack_cooldown_value
        perform_attack()

    if Input.is_action_just_pressed("skill"):
        try_active_skill()

    if position.y > 1100:
        take_damage(999, global_position.x)

    queue_redraw()

func set_controls_enabled(value: bool) -> void:
    controls_enabled = value
    if not value:
        dash_timer = 0.0
        velocity.x = 0.0

func apply_hitstop(duration := 0.045) -> void:
    hitstop_timer = maxf(hitstop_timer, duration)

func perform_attack() -> void:
    attack_flash_timer = 0.16
    attacked.emit(global_position, facing)
    var attack_origin := global_position + Vector2(facing * 34, -4)
    var x_range := 62.0
    var y_range := 52.0
    if character_id == "lemon_gunner":
        x_range = 146.0
        y_range = 46.0
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if not is_instance_valid(enemy):
            continue
        var offset: Vector2 = enemy.global_position - attack_origin
        if signf(offset.x) == float(facing) or absf(offset.x) < 20.0:
            pass
        else:
            continue
        if absf(offset.x) <= x_range and absf(offset.y) <= y_range:
            var final_damage := damage
			if hextech_augments.has("double_edged"):
				final_damage *= 2
            if active_recipes.has("cinnamon_flame_cup"):
                final_damage += 1
            var critical := randf() < _critical_chance()
            if critical:
                final_damage *= 2
            if enemy.has_method("take_damage"):
                enemy.take_damage(final_damage, global_position, critical)
                hit_enemy.emit(enemy.global_position, final_damage, critical)
				if hextech_augments.has("echo_strike"):
					echo_attack_counter += 1
					if echo_attack_counter >= 3:
						echo_attack_counter = 0
						if enemy.has_method("take_damage"):
							enemy.take_damage(final_damage, global_position, false)
				if hextech_augments.has("frostfire_combo") and randf() < 0.20:
					enemy.slow_timer = 2.0
                apply_hitstop(0.035 if not critical else 0.065)

func try_active_skill() -> bool:
    if active_skill_timer > 0.0:
        stats_changed.emit()
        return false
    var cooldown := _skill_cooldown_seconds()
    active_skill_timer = cooldown
    skill_flash_timer = 0.28
    skill_used.emit(active_skill_id, global_position, facing)

    match active_skill_id:
        "ice_guard":
            shield += 2 + int(skill_power_bonus / 2)
            invincible_timer = maxf(invincible_timer, 0.90)
            _skill_damage_enemies(96.0, 1 + skill_power_bonus, false)
        "mint_blink":
            invincible_timer = maxf(invincible_timer, 0.35)
            global_position = Vector2(clampf(global_position.x + facing * 112.0, 48.0, 492.0), global_position.y)
            velocity = Vector2(facing * 120.0, minf(velocity.y, -90.0))
            _skill_damage_enemies(86.0, 2 + skill_power_bonus, true)
        "lime_barrage":
            _skill_damage_cone(330.0, 82.0, 2 + lime_stacks + skill_power_bonus, true)
        _:
            _skill_damage_enemies(118.0, damage + skill_power_bonus, false)
    stats_changed.emit()
    queue_redraw()
    return true

func _skill_damage_enemies(radius: float, amount: int, force_crit := false) -> void:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if not is_instance_valid(enemy):
            continue
        if global_position.distance_to(enemy.global_position) <= radius:
            if enemy.has_method("take_damage"):
                var critical := force_crit or randf() < (_critical_chance() * 0.5)
                var final_damage := amount * (2 if critical else 1)
                enemy.take_damage(final_damage, global_position, critical)
                hit_enemy.emit(enemy.global_position, final_damage, critical)

func _skill_damage_cone(length: float, half_height: float, amount: int, bonus_crit := false) -> void:
    var origin := global_position + Vector2(facing * 22, -8)
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if not is_instance_valid(enemy):
            continue
        var offset: Vector2 = enemy.global_position - origin
        if signf(offset.x) != float(facing) and absf(offset.x) > 18.0:
            continue
        if absf(offset.x) <= length and absf(offset.y) <= half_height:
            if enemy.has_method("take_damage"):
                var critical := randf() < (_critical_chance() + (0.20 if bonus_crit else 0.0))
                var final_damage := amount * (2 if critical else 1)
                enemy.take_damage(final_damage, global_position, critical)
                hit_enemy.emit(enemy.global_position, final_damage, critical)

func _skill_cooldown_seconds() -> float:
    return maxf(1.25, active_skill_cooldown * skill_cooldown_mult)

func get_skill_status_text() -> String:
    if active_skill_timer <= 0.0:
        return "%s READY" % active_skill_name
    return "%s %.1fs" % [active_skill_name, active_skill_timer]

func get_skill_fill() -> float:
    var cd := _skill_cooldown_seconds()
    if cd <= 0.0:
        return 1.0
    return 1.0 - clampf(active_skill_timer / cd, 0.0, 1.0)

func _critical_chance() -> float:
    var chance := 0.10 + lime_stacks * 0.08
    if character_id == "mint_ninja":
        chance += 0.05
    elif character_id == "lemon_gunner":
        chance += 0.08
	if hextech_augments.has("lucky_find"):
		chance += 0.10
    if active_recipes.has("bubble_crit"):
        chance += 0.18
        if not is_on_floor():
            chance += 0.12
    return minf(chance, 0.75)

func _apply_dash_recipe_pulse() -> void:
    if not active_recipes.has("ice_mint_storm"):
        return
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if not is_instance_valid(enemy):
            continue
        if global_position.distance_to(enemy.global_position) <= 82.0:
            if enemy.has_method("take_damage"):
                enemy.take_damage(1, global_position, false)

func take_damage(amount: int, source_x := 0.0) -> void:
    if invincible_timer > 0.0:
        return
    invincible_timer = 0.75
    var remaining := amount
	if hextech_augments.has("crystal_armor"):
		remaining = maxi(1, remaining - 1)
	if hextech_augments.has("double_edged"):
		remaining = int(ceil(float(remaining) * 1.5))
    if shield > 0:
        var absorbed := mini(shield, remaining)
        shield -= absorbed
        remaining -= absorbed
    if remaining > 0:
        health -= remaining
    if source_x != 0.0:
        var push_dir := 1.0 if global_position.x >= source_x else -1.0
        velocity.x = push_dir * 210.0
        velocity.y = minf(velocity.y, -170.0)
    if active_recipes.has("honey_guard") and health > 0:
	if hextech_augments.has("cheat_death") and health - remaining <= 0:
		health = 1
		remaining = 0
		invincible_timer = 1.5
		hextech_augments.erase("cheat_death")
        shield += 1
    damaged.emit(global_position, amount)
    stats_changed.emit()
    if health <= 0:
        died.emit()

func add_score(points: int) -> void:
    score += points
    stats_changed.emit()

func add_gold(amount: int) -> void:
    var bonus_amount := maxi(0, int(round(float(amount) * gold_bonus_rate)))
    gold += bonus_amount
    stats_changed.emit()

func try_spend_gold(amount: int) -> bool:
    if gold < amount:
        return false
    gold -= amount
    stats_changed.emit()
    return true

func add_item(kind: String) -> void:
    inventory[kind] = inventory.get(kind, 0) + 1
    match kind:
        "mint":
            mint_count += 1
            speed *= 1.15
        "ice":
            shield += 1
        "cinnamon":
            cinnamon_stacks += 1
            damage += 1
        "lime":
            lime_stacks += 1
        "bubble":
            has_double_jump = true
        "honey":
            max_health += 1
            health = mini(max_health, health + 1)
        "almond":
            almond_stacks += 1
            attack_cooldown_value = maxf(0.12, attack_cooldown_value * 0.88)
        "vanilla":
            shield += 1
            health = mini(max_health, health + 2)
        "ember":
            ember_stacks += 1
            dash_cooldown_value = maxf(0.26, dash_cooldown_value * 0.85)
        "zest":
            zest_stacks += 1
            skill_power_bonus += 1
        "glass":
            max_health += 1
            health = mini(max_health, health + 1)
        "copper":
            shield += 2
        "tonic":
            skill_cooldown_mult = maxf(0.50, skill_cooldown_mult * 0.88)
        "star_anise":
            skill_power_bonus += 1
        "sugar":
            add_gold(22)
            add_score(140)
    _check_new_recipes()
    item_gained.emit(kind)
    stats_changed.emit()

func _check_new_recipes() -> void:
    var newly_available := RecipeData.discoverable_recipes(inventory, active_recipes)
    for recipe_id in newly_available:
        active_recipes[recipe_id] = true
        _apply_recipe_bonus(recipe_id)
        recipe_discovered.emit(recipe_id)

func _apply_recipe_bonus(recipe_id: String) -> void:
    match recipe_id:
        "ice_mint_storm":
            speed *= 1.10
        "cinnamon_flame_cup":
            damage += 1
        "bubble_crit":
            attack_cooldown_value = maxf(0.11, attack_cooldown_value * 0.90)
        "tavern_tankard":
            max_health += 1
            health += 1
            shield += 2
        "starry_shaker":
            skill_cooldown_mult = maxf(0.45, skill_cooldown_mult * 0.80)
            skill_power_bonus += 1
        "golden_toast":
            gold_bonus_rate = maxf(gold_bonus_rate, 1.25)
            max_health += 1
            health += 1
        "citrus_barrage":
            lime_stacks += 1
            skill_power_bonus += 1
            attack_cooldown_value = maxf(0.11, attack_cooldown_value * 0.92)

func heal(amount: int) -> void:
    health = mini(max_health, health + amount)
    stats_changed.emit()

func apply_character(new_character_id: String) -> void:
    var data := CharacterData.get_data(new_character_id)
    character_id = new_character_id if CharacterData.has_character(new_character_id) else "bartender"
    body_color = data.get("body_color", Color(0.95, 0.74, 0.35))
    apron_color = data.get("apron_color", Color(0.52, 0.94, 0.62))
    hat_color = data.get("hat_color", Color(0.96, 0.96, 0.86))
    active_skill_id = str(data.get("active_skill", "shaker_burst"))
    active_skill_name = str(data.get("skill_name", "摇壶爆发"))
    active_skill_cooldown = float(data.get("skill_cooldown", 5.8))
    active_skill_timer = 0.0
    max_health = maxi(1, max_health + int(data.get("health_bonus", 0)))
    health = max_health
    shield += int(data.get("shield_bonus", 0))
    speed *= float(data.get("speed_mult", 1.0))
    damage += int(data.get("damage_bonus", 0))
    gold += int(data.get("gold_bonus", 0))
    if bool(data.get("double_jump", false)):
        has_double_jump = true
    for item_id in data.get("starting_items", []):
        add_item(str(item_id))
    stats_changed.emit()
    queue_redraw()

func reset_run() -> void:
    max_health = 5
    health = 5
    shield = 0
    speed = BASE_SPEED
    damage = 1
    mint_count = 0
    lime_stacks = 0
    cinnamon_stacks = 0
    almond_stacks = 0
    ember_stacks = 0
    zest_stacks = 0
    skill_power_bonus = 0
    skill_cooldown_mult = 1.0
    gold_bonus_rate = 1.0
    has_double_jump = false
    used_double_jump = false
    score = 0
    gold = 20
    inventory.clear()
    active_recipes.clear()
	hextech_crystals = 0
	hextech_augments.clear()
	echo_attack_counter = 0
    character_id = "bartender"
    active_skill_id = "shaker_burst"
    active_skill_name = "摇壶爆发"
    active_skill_cooldown = 5.8
    active_skill_timer = 0.0
    body_color = Color(0.95, 0.74, 0.35)
    apron_color = Color(0.52, 0.94, 0.62)
    hat_color = Color(0.96, 0.96, 0.86)
    dash_cooldown_value = BASE_DASH_COOLDOWN
    attack_cooldown_value = BASE_ATTACK_COOLDOWN
    dash_timer = 0.0
    dash_cooldown_timer = 0.0
    attack_cooldown_timer = 0.0
    invincible_timer = 0.0
    coyote_timer = 0.0
    jump_buffer_timer = 0.0
    hitstop_timer = 0.0
    land_squash_timer = 0.0
    was_on_floor = false
    attack_flash_timer = 0.0
    skill_flash_timer = 0.0
    stats_changed.emit()
    queue_redraw()
func add_hextech_crystals(amount: int) -> void:
	hextech_crystals += amount
	stats_changed.emit()

func spend_hextech_crystals(amount: int) -> bool:
	if hextech_crystals < amount:
		return false
	hextech_crystals -= amount
	stats_changed.emit()
	return true

func add_hextech_augment(augment_id: String) -> void:
	hextech_augments[augment_id] = true
	_apply_augment_effect(augment_id)
	stats_changed.emit()

func has_hextech_augment(augment_id: String) -> bool:
	return hextech_augments.has(augment_id)

func _apply_augment_effect(augment_id: String) -> void:
	match augment_id:
		"swift_steps":
			speed *= 1.15
		"sturdy_shell":
			max_health += 2
			health = mini(max_health, health + 2)
		"quick_hands":
			attack_cooldown_value = maxf(0.10, attack_cooldown_value * 0.85)
		"overflowing_cup":
			damage += 1
			shield += 1
		"crystal_pocket":
			gold += 5
			hextech_crystals += 2

func get_recipe_names() -> Array:
    var names := []
    for recipe_id in active_recipes.keys():
        names.append(RecipeData.get_name(str(recipe_id)))
    return names

func _draw() -> void:
    if invincible_timer > 0.0 and int(invincible_timer * 18.0) % 2 == 0:
        return
    var outline := Color(0.04, 0.03, 0.025)
    var body := body_color
    var apron := apron_color
    var squash := 1.0 + (land_squash_timer / 0.12) * 0.12
    var stretch := 1.0 - (land_squash_timer / 0.12) * 0.08

    if skill_flash_timer > 0.0:
        draw_rect(Rect2(-25, -58, 50, 64), Color(1.0, 0.85, 0.24, 0.18 + skill_flash_timer))

    draw_rect(Rect2(-13 * squash, -39 * stretch, 26 * squash, 43 * stretch), outline)
    draw_rect(Rect2(-10 * squash, -36 * stretch, 20 * squash, 36 * stretch), body)
    draw_rect(Rect2(-8 * squash, -18 * stretch, 16 * squash, 16 * stretch), apron)
    draw_rect(Rect2(-7 * squash, -48 * stretch, 14 * squash, 11 * stretch), hat_color)
    draw_rect(Rect2(-5 * squash, -26 * stretch, 4, 4), outline)
    draw_rect(Rect2(5 * squash, -26 * stretch, 4, 4), outline)
    draw_rect(Rect2(-8 * squash, -9 * stretch, 16 * squash, 4), Color(0.38, 0.18, 0.08))
    if character_id == "ice_knight":
        draw_rect(Rect2(-19, -21, 7, 26), Color(0.86, 0.98, 1.0))
        draw_rect(Rect2(-18, -18, 5, 18), Color(0.40, 0.78, 1.0))
    elif character_id == "mint_ninja":
        draw_rect(Rect2(-22 * facing, -31, 14 * facing, 5), Color(0.10, 0.52, 0.25))
        draw_rect(Rect2(-20 * facing, -24, 12 * facing, 4), Color(0.72, 1.0, 0.32))
    elif character_id == "lemon_gunner":
        draw_rect(Rect2(-16, -51, 32, 7), Color(0.96, 0.92, 0.24))
        draw_rect(Rect2(facing * 10, -23, facing * 24, 6), Color(0.24, 0.50, 0.15))
        draw_rect(Rect2(facing * 30, -27, facing * 8, 14), Color(1.0, 0.96, 0.18))

    # Tiny torch-spoon silhouette.
    if character_id == "lemon_gunner":
        draw_rect(Rect2(facing * 12, -30, facing * 34, 6), outline)
        draw_rect(Rect2(facing * 39, -34, facing * 12, 14), Color(0.82, 1.0, 0.16))
    else:
        draw_rect(Rect2(facing * 12, -29, facing * 22, 5), outline)
        draw_rect(Rect2(facing * 30, -36, facing * 7, 14), Color(0.95, 0.18, 0.08))
    if attack_flash_timer > 0.0:
        var flash_len := 34 if character_id == "lemon_gunner" else 18
        draw_rect(Rect2(facing * 27, -48, facing * flash_len, 18), Color(1.0, 0.85, 0.25, 0.70))

    if dash_timer > 0.0:
        draw_rect(Rect2(-facing * 42, -30, facing * 34, 25), Color(0.72, 0.96, 1.0, 0.38))
