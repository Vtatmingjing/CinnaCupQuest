extends Node2D

const PlayerScene := preload("res://scripts/survivor_player.gd")
const EnemyScene := preload("res://scripts/survivor_enemy.gd")
const ProjectileScene := preload("res://scripts/survivor_projectile.gd")
const PickupScene := preload("res://scripts/survivor_pickup.gd")
const HUDScene := preload("res://scripts/survivor_hud.gd")
const BackgroundScene := preload("res://scripts/background.gd")
const SoundScene := preload("res://scripts/sound_manager.gd")
const FloatingTextScene := preload("res://scripts/floating_text.gd")
const PulseScene := preload("res://scripts/survivor_pulse.gd")

const ARENA := Rect2(28, 92, 484, 790)
const BOSS_SPAWN_TIME := 360.0
const MAX_ENEMIES := 88

const UPGRADES := {
    "mint_leaf": {
        "name": "Mint Leaf",
        "desc": "Move faster and pull flavor drops from farther away.",
        "color": Color(0.28, 1.0, 0.48)
    },
    "ice_cube": {
        "name": "Clear Ice Cube",
        "desc": "Gain 2 shield. Shields block the next hits before HP.",
        "color": Color(0.72, 0.96, 1.0)
    },
    "cinnamon_stick": {
        "name": "Cinnamon Stick",
        "desc": "Main spoon projectiles deal +1 damage.",
        "color": Color(0.78, 0.38, 0.16)
    },
    "lime_zest": {
        "name": "Lime Zest",
        "desc": "Add or strengthen side lime shots.",
        "color": Color(0.78, 1.0, 0.16)
    },
    "almond_syrup": {
        "name": "Almond Syrup",
        "desc": "Reduce auto-fire cooldown.",
        "color": Color(0.93, 0.78, 0.52)
    },
    "bubble_water": {
        "name": "Bubble Water",
        "desc": "Add an orbiting bubble that bumps nearby enemies.",
        "color": Color(0.45, 0.78, 1.0)
    },
    "ember_spark": {
        "name": "Torch Ember",
        "desc": "Add or strengthen a cinnamon fire aura pulse.",
        "color": Color(1.0, 0.27, 0.08)
    },
    "honey_drop": {
        "name": "Honey Drop",
        "desc": "Increase max HP and heal.",
        "color": Color(1.0, 0.72, 0.18)
    },
    "tonic_splash": {
        "name": "Tonic Splash",
        "desc": "Increase special weapon power and projectile size.",
        "color": Color(0.62, 0.88, 1.0)
    },
    "glass_rim": {
        "name": "Glass Rim",
        "desc": "Main spoon projectiles pierce one more enemy.",
        "color": Color(0.70, 0.95, 1.0)
    },
    "star_anise": {
        "name": "Star Anise",
        "desc": "Raise critical hit chance.",
        "color": Color(1.0, 0.72, 0.25)
    }
}

var player
var hud
var background
var sound
var camera: Camera2D

var game_state := "menu"
var selected_character_id := "bartender"
var elapsed := 0.0
var spawn_timer := 0.0
var elite_timer := 22.0
var wave := 1
var boss_spawned := false
var boss_alive := false
var current_upgrade_options: Array = []
var shake_time := 0.0
var shake_strength := 0.0

func _ready() -> void:
    randomize()
    _ensure_input_map()
    _build_world()
    _show_menu()

func _process(delta: float) -> void:
    match game_state:
        "menu":
            _handle_menu_input()
        "playing":
            _run_survivor_loop(delta)
            _handle_playing_input()
        "levelup":
            _handle_upgrade_input()
        "paused":
            _handle_pause_input()
        "summary":
            _handle_summary_input()
    _update_camera_shake(delta)
    if hud != null and player != null and (game_state == "playing" or game_state == "levelup" or game_state == "paused"):
        hud.update_run(player, elapsed, wave, get_tree().get_nodes_in_group("survivor_enemies").size(), boss_alive, BOSS_SPAWN_TIME - elapsed)

func _ensure_input_map() -> void:
    var defaults := {
        "move_left": [KEY_A, KEY_LEFT],
        "move_right": [KEY_D, KEY_RIGHT],
        "move_up": [KEY_W, KEY_UP],
        "move_down": [KEY_S, KEY_DOWN],
        "restart": [KEY_R],
        "choice_1": [KEY_1],
        "choice_2": [KEY_2],
        "choice_3": [KEY_3],
        "choice_4": [KEY_4],
        "confirm": [KEY_ENTER, KEY_KP_ENTER],
        "pause": [KEY_P, KEY_ESCAPE],
        "back": [KEY_ESCAPE]
    }
    for action in defaults.keys():
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        if InputMap.action_get_events(action).size() == 0:
            for keycode in defaults[action]:
                var event := InputEventKey.new()
                event.keycode = keycode
                InputMap.action_add_event(action, event)

func _build_world() -> void:
    background = BackgroundScene.new()
    background.z_index = -100
    add_child(background)
    background.set_region("bar_top")

    sound = SoundScene.new()
    add_child(sound)

    camera = Camera2D.new()
    camera.position = Vector2(270, 480)
    add_child(camera)
    camera.make_current()

    player = PlayerScene.new()
    add_child(player)
    player.died.connect(_on_player_died)
    player.damaged.connect(_on_player_damaged)
    player.leveled_up.connect(_on_player_leveled_up)
    player.projectile_requested.connect(_on_player_projectile_requested)
    player.pulse_requested.connect(_on_player_pulse_requested)

    hud = HUDScene.new()
    add_child(hud)

func _show_menu() -> void:
    game_state = "menu"
    _clear_arena()
    player.visible = false
    player.set_controls_enabled(false)
    hud.show_title(selected_character_id)
    hud.show_message("")

func _start_new_run() -> void:
    _clear_arena()
    elapsed = 0.0
    spawn_timer = 0.0
    elite_timer = 22.0
    wave = 1
    boss_spawned = false
    boss_alive = false
    current_upgrade_options.clear()
    game_state = "playing"
    player.visible = true
    player.reset_run(selected_character_id)
    player.set_controls_enabled(true)
    player.set_process(true)
    hud.hide_overlay()
    hud.show_message("Survive the bar-top storm. Auto-fire is on.", 3.0)
    _play_sound("start")

func _run_survivor_loop(delta: float) -> void:
    elapsed += delta
    wave = maxi(1, int(elapsed / 24.0) + 1)
    spawn_timer -= delta
    elite_timer -= delta
    var enemy_count := get_tree().get_nodes_in_group("survivor_enemies").size()
    if spawn_timer <= 0.0 and enemy_count < MAX_ENEMIES:
        _spawn_pack()
        spawn_timer = maxf(0.16, 1.15 - elapsed * 0.0035)
    if elite_timer <= 0.0:
        elite_timer = maxf(12.0, 27.0 - wave * 0.55)
        if enemy_count < MAX_ENEMIES - 4:
            _spawn_enemy(_random_spawn_position(), _elite_kind(), true)
    if not boss_spawned and elapsed >= BOSS_SPAWN_TIME:
        _spawn_boss()

func _handle_menu_input() -> void:
    if Input.is_action_just_pressed("choice_1"):
        _select_character("bartender")
    elif Input.is_action_just_pressed("choice_2"):
        _select_character("ice_knight")
    elif Input.is_action_just_pressed("choice_3"):
        _select_character("mint_ninja")
    elif Input.is_action_just_pressed("choice_4"):
        _select_character("lemon_gunner")
    elif Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("restart"):
        _start_new_run()

func _select_character(character_id: String) -> void:
    selected_character_id = character_id
    hud.show_title(selected_character_id)
    _play_sound("menu")

func _handle_playing_input() -> void:
    if Input.is_action_just_pressed("pause"):
        _pause_run()
    elif Input.is_action_just_pressed("restart"):
        _start_new_run()

func _pause_run() -> void:
    if game_state != "playing":
        return
    game_state = "paused"
    player.set_controls_enabled(false)
    _set_arena_active(false)
    hud.show_pause()

func _resume_run() -> void:
    if game_state != "paused":
        return
    game_state = "playing"
    hud.hide_overlay()
    player.set_controls_enabled(true)
    _set_arena_active(true)

func _handle_pause_input() -> void:
    if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("back"):
        _resume_run()
    elif Input.is_action_just_pressed("restart"):
        _start_new_run()

func _handle_upgrade_input() -> void:
    if Input.is_action_just_pressed("choice_1"):
        _choose_upgrade(0)
    elif Input.is_action_just_pressed("choice_2"):
        _choose_upgrade(1)
    elif Input.is_action_just_pressed("choice_3"):
        _choose_upgrade(2)

func _handle_summary_input() -> void:
    if Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("restart"):
        _start_new_run()

func _on_player_leveled_up() -> void:
    if game_state != "playing":
        return
    game_state = "levelup"
    player.set_controls_enabled(false)
    _set_arena_active(false)
    current_upgrade_options = _roll_upgrade_options()
    hud.show_upgrade_choices(current_upgrade_options)
    _play_sound("recipe")

func _choose_upgrade(index: int) -> void:
    if index < 0 or index >= current_upgrade_options.size():
        return
    var option: Dictionary = current_upgrade_options[index]
    var upgrade_id := str(option.get("id", "cinnamon_stick"))
    player.add_upgrade(upgrade_id)
    player.consume_pending_level()
    hud.show_message("Mixed: %s" % option.get("name", upgrade_id), 2.0)
    _play_sound("rare")
    if player.pending_levels > 0:
        current_upgrade_options = _roll_upgrade_options()
        hud.show_upgrade_choices(current_upgrade_options)
        return
    game_state = "playing"
    hud.hide_overlay()
    player.set_controls_enabled(true)
    _set_arena_active(true)

func _roll_upgrade_options() -> Array:
    var ids := UPGRADES.keys()
    ids.shuffle()
    var result := []
    for i in range(mini(3, ids.size())):
        var id := str(ids[i])
        var data: Dictionary = UPGRADES[id]
        result.append({
            "id": id,
            "name": data.get("name", id),
            "desc": data.get("desc", ""),
            "color": data.get("color", Color.WHITE)
        })
    return result

func _spawn_pack() -> void:
    var count := 2 + int(wave / 2)
    if elapsed > 120.0:
        count += 2
    if elapsed > 240.0:
        count += 2
    for i in range(count):
        _spawn_enemy(_random_spawn_position(), _weighted_enemy_kind(), false)

func _spawn_boss() -> void:
    boss_spawned = true
    boss_alive = true
    _spawn_enemy(_random_spawn_position(), "boss", true)
    hud.show_message("Aroma Beacon Guardian arrives!", 3.0)
    _shake(9.0, 0.45)
    _play_sound("victory")

func _spawn_enemy(pos: Vector2, kind: String, elite := false) -> void:
    var enemy = EnemyScene.new()
    enemy.setup(kind, wave + (3 if elite else 0), kind == "boss")
    if elite and kind != "boss":
        enemy.max_health += 12 + wave
        enemy.health = enemy.max_health
        enemy.speed *= 0.90
        enemy.score_value += 90
        enemy.xp_value += 4
        enemy.scale = Vector2(1.25, 1.25)
        enemy.hit_radius += 6.0
    enemy.position = pos
    enemy.died.connect(_on_enemy_died)
    enemy.damaged.connect(_on_enemy_damaged)
    enemy.projectile_requested.connect(_on_enemy_projectile_requested)
    add_child(enemy)

func _random_spawn_position() -> Vector2:
    var side := randi() % 4
    var margin := 56.0
    match side:
        0:
            return Vector2(randf_range(ARENA.position.x, ARENA.end.x), ARENA.position.y - margin)
        1:
            return Vector2(randf_range(ARENA.position.x, ARENA.end.x), ARENA.end.y + margin)
        2:
            return Vector2(ARENA.position.x - margin, randf_range(ARENA.position.y, ARENA.end.y))
        _:
            return Vector2(ARENA.end.x + margin, randf_range(ARENA.position.y, ARENA.end.y))

func _weighted_enemy_kind() -> String:
    var pool := ["bubble", "bubble", "bubble", "ice", "lime"]
    if wave >= 3:
        pool.append("cork")
    if wave >= 5:
        pool.append("mold")
        pool.append("lime")
    if wave >= 9:
        pool.append("cork")
        pool.append("ice")
    return pool[randi() % pool.size()]

func _elite_kind() -> String:
    var pool := ["ice", "cork", "mold", "lime"]
    return pool[randi() % pool.size()]

func _on_player_projectile_requested(pos: Vector2, vel: Vector2, damage: int, radius: float, color: Color, label: String, pierce: int, ttl: float) -> void:
    _spawn_projectile(pos, vel, damage, radius, color, label, pierce, ttl, true)
    _play_sound("attack")

func _on_enemy_projectile_requested(pos: Vector2, vel: Vector2, damage: int, radius: float, color: Color, label: String) -> void:
    _spawn_projectile(pos, vel, damage, radius, color, label, 0, 4.0, false)

func _spawn_projectile(pos: Vector2, vel: Vector2, damage: int, radius: float, color: Color, label: String, pierce: int, ttl: float, from_player: bool) -> void:
    var projectile = ProjectileScene.new()
    projectile.setup(pos, vel, damage, radius, color, label, pierce, ttl, from_player)
    projectile.hit_something.connect(_on_projectile_hit)
    add_child(projectile)

func _on_player_pulse_requested(pos: Vector2, radius: float, damage: int, color: Color) -> void:
    for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        if pos.distance_to(enemy.global_position) <= radius + enemy.hit_radius:
            enemy.take_damage(damage, pos, false)
    _spawn_pulse_visual(pos, radius, color)
    _play_sound("skill")

func _spawn_pulse_visual(pos: Vector2, radius: float, color: Color) -> void:
    var pulse = PulseScene.new()
    pulse.setup(pos, radius, color)
    add_child(pulse)

func _on_projectile_hit(pos: Vector2, amount: int) -> void:
    _spawn_floating_text(pos + Vector2(-8, -12), str(amount), Color(1.0, 0.86, 0.34), 14)

func _on_enemy_damaged(pos: Vector2, amount: int, critical: bool) -> void:
    _spawn_floating_text(pos + Vector2(randf_range(-10, 10), -28), "%d%s" % [amount, "!" if critical else ""], Color(1.0, 0.92, 0.40), 14 if not critical else 18)

func _on_enemy_died(enemy) -> void:
    if not is_instance_valid(enemy):
        return
    var death_pos: Vector2 = enemy.global_position
    player.add_score(enemy.score_value)
    _spawn_pickup(death_pos, "xp", enemy.xp_value, _xp_color(enemy.xp_value))
    if randf() < 0.08:
        _spawn_pickup(death_pos + Vector2(randf_range(-18, 18), randf_range(-18, 18)), "gold", 1 + int(wave / 2), Color(1.0, 0.76, 0.20))
    if randf() < 0.035:
        _spawn_pickup(death_pos + Vector2(randf_range(-18, 18), randf_range(-18, 18)), "heal", 1, Color(1.0, 0.30, 0.32))
    _play_sound("enemy_down")
    if enemy.kind == "boss":
        boss_alive = false
        _finish_run(true)

func _spawn_pickup(pos: Vector2, kind: String, amount: int, color: Color) -> void:
    var pickup = PickupScene.new()
    pickup.setup(pos, kind, amount, color)
    pickup.collected.connect(_on_pickup_collected)
    add_child(pickup)

func _on_pickup_collected(kind: String, amount: int, pos: Vector2) -> void:
    match kind:
        "xp":
            player.add_xp(amount)
        "gold":
            player.add_gold(amount)
            player.add_score(amount * 25)
        "heal":
            player.heal(amount)
        _:
            player.add_xp(amount)
    _spawn_floating_text(pos + Vector2(-8, -14), "+" + str(amount), Color(0.62, 1.0, 0.58), 13)
    _play_sound("pickup")

func _on_player_damaged(pos: Vector2, amount: int) -> void:
    _spawn_floating_text(pos + Vector2(-12, -34), "-%d" % amount, Color(1.0, 0.32, 0.22), 18)
    _shake(6.0, 0.18)
    _play_sound("hurt")

func _on_player_died() -> void:
    _finish_run(false)

func _finish_run(won: bool) -> void:
    if game_state == "summary":
        return
    game_state = "summary"
    player.set_controls_enabled(false)
    _set_arena_active(false)
    hud.show_summary(won, player, elapsed)
    _play_sound("victory" if won else "defeat")

func _clear_arena() -> void:
    for group in ["survivor_enemies", "survivor_projectiles", "survivor_pickups"]:
        for node in get_tree().get_nodes_in_group(group):
            if is_instance_valid(node):
                node.queue_free()
    for child in get_children():
        if str(child.name).begins_with("Pulse") or str(child.name).begins_with("Float"):
            child.queue_free()

func _set_arena_active(active: bool) -> void:
    for group in ["survivor_enemies", "survivor_projectiles", "survivor_pickups"]:
        for node in get_tree().get_nodes_in_group(group):
            if is_instance_valid(node):
                node.set_process(active)

func _spawn_floating_text(pos: Vector2, text: String, color: Color, size := 16) -> void:
    var floating = FloatingTextScene.new()
    floating.name = "Float"
    floating.position = pos
    floating.setup(text, color, size)
    add_child(floating)

func _xp_color(amount: int) -> Color:
    if amount >= 5:
        return Color(0.55, 0.72, 1.0)
    if amount >= 3:
        return Color(0.74, 1.0, 0.22)
    return Color(0.40, 1.0, 0.46)

func _play_sound(key: String) -> void:
    if sound != null and sound.has_method("play_sfx"):
        sound.play_sfx(key)

func _shake(strength: float, duration: float) -> void:
    shake_strength = maxf(shake_strength, strength)
    shake_time = maxf(shake_time, duration)

func _update_camera_shake(delta: float) -> void:
    if camera == null:
        return
    if shake_time <= 0.0:
        camera.offset = Vector2.ZERO
        return
    shake_time -= delta
    camera.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
    shake_strength = lerpf(shake_strength, 0.0, 8.0 * delta)

func _draw() -> void:
    if game_state == "menu":
        return
    draw_rect(ARENA, Color(1.0, 0.78, 0.28, 0.04))
    draw_rect(Rect2(ARENA.position, Vector2(ARENA.size.x, 4)), Color(1.0, 0.82, 0.32, 0.32))
    draw_rect(Rect2(ARENA.position + Vector2(0, ARENA.size.y - 4), Vector2(ARENA.size.x, 4)), Color(1.0, 0.82, 0.32, 0.28))
    draw_rect(Rect2(ARENA.position, Vector2(4, ARENA.size.y)), Color(1.0, 0.82, 0.32, 0.22))
    draw_rect(Rect2(ARENA.position + Vector2(ARENA.size.x - 4, 0), Vector2(4, ARENA.size.y)), Color(1.0, 0.82, 0.32, 0.22))
