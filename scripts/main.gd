extends Node2D

const PlayerScene := preload("res://scripts/player.gd")
const EnemyScene := preload("res://scripts/enemy.gd")
const ItemScene := preload("res://scripts/item_pickup.gd")
const DoorScene := preload("res://scripts/door.gd")
const BackgroundScene := preload("res://scripts/background.gd")
const HUDScene := preload("res://scripts/hud.gd")
const DecorScene := preload("res://scripts/decor.gd")
const ProjectileScene := preload("res://scripts/projectile.gd")
const HazardScene := preload("res://scripts/hazard.gd")
const FloatingTextScene := preload("res://scripts/floating_text.gd")
const PlatformVisualScene := preload("res://scripts/platform_visual.gd")
const SoundScene := preload("res://scripts/sound_manager.gd")
const SkillBurstScene := preload("res://scripts/skill_burst.gd")
const RecipeData := preload("res://scripts/recipe_data.gd")
const MetaProgress := preload("res://scripts/meta_progress.gd")
const CharacterData := preload("res://scripts/character_data.gd")
const RegionData := preload("res://scripts/region_data.gd")

var player: CinnaPlayer
var hud: CinnaHUD
var door: CinnaDoor
var camera: Camera2D
var background: CinnaBackground
var sound: CinnaSoundManager
var meta_data: Dictionary = {}
var current_depth := 0
var total_rooms := 13
var current_room_type := "fight"
var current_elite_modifier := ""
var current_region_id := "bar_top"
var selected_character_id := "bartender"
var settings_data: Dictionary = {}
var selected_next_room := ""
var path_choices: Array = []
var awaiting_path_choice := false
var awaiting_event_choice := false
var current_event_id := ""
var enemies_alive := 0
var game_finished := false
var game_state := "menu"
var state_before_codex := "menu"
var state_before_settings := "menu"
var last_summary_won := false
var last_summary_shards := 0
var last_summary_unlocks: Array = []
var shake_time := 0.0
var shake_strength := 0.0
var mid_boss_cleared := false
var victory_timer := 0.0
var tutorial_seen: Dictionary = {}

func _ready() -> void:
    _ensure_input_map()
    randomize()
    meta_data = MetaProgress.load_meta()
    settings_data = MetaProgress.get_settings(meta_data)
    _build_world()
    _show_title_menu()

func _process(delta: float) -> void:
    match game_state:
        "menu":
            _handle_menu_input()
        "playing":
            _handle_playing_input()
            _handle_choice_input()
        "paused":
            _handle_pause_input()
        "summary":
            _handle_summary_input()
        "victory_scene":
            _handle_victory_scene(delta)
        "codex":
            _handle_codex_input()
        "settings":
            _handle_settings_input()
    _update_camera_shake(delta)
    if hud != null and player != null and game_state == "playing":
        hud.update_stats(player)

func _ensure_input_map() -> void:
    var defaults := {
        "move_left": [KEY_A, KEY_LEFT],
        "move_right": [KEY_D, KEY_RIGHT],
        "jump": [KEY_SPACE, KEY_W],
        "dash": [KEY_J, KEY_SHIFT],
        "attack": [KEY_K],
        "skill": [KEY_L, KEY_E],
        "restart": [KEY_R],
        "choice_1": [KEY_1],
        "choice_2": [KEY_2],
        "choice_3": [KEY_3],
        "choice_4": [KEY_4],
        "confirm": [KEY_ENTER, KEY_KP_ENTER],
        "pause": [KEY_P, KEY_ESCAPE],
        "codex": [KEY_C],
        "settings": [KEY_S],
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

    sound = SoundScene.new()
    add_child(sound)

    camera = Camera2D.new()
    camera.position = Vector2(270, 480)
    add_child(camera)
    camera.make_current()

    player = PlayerScene.new()
    player.position = Vector2(84, 780)
    add_child(player)
    player.died.connect(_on_player_died)
    player.stats_changed.connect(_on_player_stats_changed)
    player.item_gained.connect(_on_player_item_gained)
    player.recipe_discovered.connect(_on_recipe_discovered)
    player.attacked.connect(_on_player_attacked)
    player.dashed.connect(_on_player_dashed)
    player.damaged.connect(_on_player_damaged)
    player.hit_enemy.connect(_on_player_hit_enemy)
    player.landed.connect(_on_player_landed)
    player.skill_used.connect(_on_player_skill_used)

    hud = HUDScene.new()
    add_child(hud)

func _show_title_menu() -> void:
    game_state = "menu"
    game_finished = true
    current_depth = 0
    current_region_id = "bar_top"
    if background != null:
        background.set_region(current_region_id)
    _clear_room()
    player.visible = false
    player.set_controls_enabled(false)
    _set_room_actors_active(false)
    hud.hide_choices()
    hud.hide_overlay()
    hud.hide_route_overlay()
    hud.hide_tutorial()
    hud.show_title_menu(meta_data, selected_character_id, settings_data)
    hud.update_route_map(current_depth, total_rooms, [], "", RegionData.get_name(current_region_id))
    hud.update_room(0, total_rooms, "menu")
    hud.show_message("", 0.01)

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
    elif Input.is_action_just_pressed("codex"):
        _open_codex("menu")
    elif Input.is_action_just_pressed("settings"):
        _open_settings("menu")

func _select_character(character_id: String) -> void:
    if not CharacterData.has_character(character_id):
        return
    selected_character_id = character_id
    _play_sound("menu")
    hud.show_title_menu(meta_data, selected_character_id, settings_data)
    hud.show_message("Selected: %s" % CharacterData.get_name(selected_character_id), 1.5)

func _handle_playing_input() -> void:
    if Input.is_action_just_pressed("pause"):
        _pause_run()
    elif Input.is_action_just_pressed("codex"):
        _pause_run()
        _open_codex("paused")
    elif Input.is_action_just_pressed("settings"):
        _open_settings("playing")

func _handle_pause_input() -> void:
    if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("choice_1"):
        _resume_run()
    elif Input.is_action_just_pressed("choice_2") or Input.is_action_just_pressed("restart"):
        _start_new_run()
    elif Input.is_action_just_pressed("choice_3"):
        _show_title_menu()
    elif Input.is_action_just_pressed("codex"):
        _open_codex("paused")
    elif Input.is_action_just_pressed("settings"):
        _open_settings("paused")

func _handle_summary_input() -> void:
    if Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("restart"):
        _start_new_run()
    elif Input.is_action_just_pressed("choice_2") or Input.is_action_just_pressed("pause"):
        _show_title_menu()
    elif Input.is_action_just_pressed("codex"):
        _open_codex("summary")
    elif Input.is_action_just_pressed("settings"):
        _open_settings("summary")

func _handle_victory_scene(delta: float) -> void:
    victory_timer -= delta
    if Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("restart") or Input.is_action_just_pressed("choice_1"):
        _finish_run(true)
        return
    if victory_timer <= 0.0:
        _finish_run(true)

func _handle_codex_input() -> void:
    if Input.is_action_just_pressed("back") or Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("codex"):
        _close_codex()

func _pause_run() -> void:
    if game_state != "playing":
        return
    game_state = "paused"
    player.set_controls_enabled(false)
    _set_room_actors_active(false)
    hud.show_pause(meta_data, player)

func _resume_run() -> void:
    if game_state != "paused":
        return
    game_state = "playing"
    game_finished = false
    hud.hide_overlay()
    player.set_controls_enabled(true)
    _set_room_actors_active(true)

func _open_codex(return_state: String) -> void:
    state_before_codex = return_state
    game_state = "codex"
    player.set_controls_enabled(false)
    _set_room_actors_active(false)
    hud.hide_route_overlay()
    hud.show_codex(meta_data)

func _close_codex() -> void:
    if state_before_codex == "paused":
        game_state = "paused"
        hud.show_pause(meta_data, player)
    elif state_before_codex == "summary":
        game_state = "summary"
        hud.show_summary(last_summary_won, player, last_summary_shards, last_summary_unlocks, meta_data)
    else:
        _show_title_menu()

func _open_settings(return_state: String) -> void:
    state_before_settings = return_state
    game_state = "settings"
    if player != null:
        player.set_controls_enabled(false)
    _set_room_actors_active(false)
    hud.hide_route_overlay()
    hud.show_settings(meta_data, settings_data)

func _handle_settings_input() -> void:
    if Input.is_action_just_pressed("choice_1"):
        settings_data["sound_enabled"] = not bool(settings_data.get("sound_enabled", true))
        MetaProgress.set_settings(meta_data, settings_data)
        hud.show_settings(meta_data, settings_data)
        _play_sound("menu")
    elif Input.is_action_just_pressed("choice_2"):
        settings_data["screen_shake"] = not bool(settings_data.get("screen_shake", true))
        MetaProgress.set_settings(meta_data, settings_data)
        hud.show_settings(meta_data, settings_data)
        _play_sound("menu")
    elif Input.is_action_just_pressed("choice_3"):
        settings_data["difficulty"] = MetaProgress.next_difficulty(str(settings_data.get("difficulty", "normal")))
        MetaProgress.set_settings(meta_data, settings_data)
        hud.show_settings(meta_data, settings_data)
        _play_sound("menu")
    elif Input.is_action_just_pressed("back") or Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("settings"):
        _close_settings()

func _close_settings() -> void:
    if state_before_settings == "playing":
        game_state = "playing"
        hud.hide_overlay()
        if awaiting_path_choice:
            hud.show_route_overlay("SCOUT ROUTE / 选择路线", path_choices, selected_next_room, RegionData.get_name(current_region_id), current_depth, total_rooms)
            player.set_controls_enabled(false)
            _set_room_actors_active(false)
        elif awaiting_event_choice:
            hud.hide_route_overlay()
            player.set_controls_enabled(false)
            _set_room_actors_active(false)
        else:
            hud.hide_route_overlay()
            player.set_controls_enabled(true)
            _set_room_actors_active(true)
    elif state_before_settings == "paused":
        game_state = "paused"
        hud.show_pause(meta_data, player)
    elif state_before_settings == "summary":
        game_state = "summary"
        hud.show_summary(last_summary_won, player, last_summary_shards, last_summary_unlocks, meta_data)
    else:
        _show_title_menu()

func _set_room_actors_active(active: bool) -> void:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if is_instance_valid(enemy):
            enemy.set_physics_process(active)
    for item in get_tree().get_nodes_in_group("room_content"):
        if is_instance_valid(item) and item.has_method("set_process"):
            item.set_process(active)

func _start_new_run() -> void:
    hud.hide_overlay()
    hud.hide_tutorial()
    game_state = "playing"
    game_finished = false
    current_depth = 0
    current_room_type = "fight"
    current_elite_modifier = ""
    current_region_id = "bar_top"
    selected_next_room = ""
    mid_boss_cleared = false
    victory_timer = 0.0
    tutorial_seen.clear()
    awaiting_path_choice = false
    awaiting_event_choice = false
    player.visible = true
    player.reset_run()
    player.apply_character(selected_character_id)
    _apply_difficulty_start_bonus()
    player.set_controls_enabled(true)
    _spawn_room("fight")
    _grant_starting_unlocks()
    _play_sound("start")
    hud.show_message("Run Start! Light the Aroma Beacon.", 2.5)
    _show_tutorial_once("basics", "新手提示：A/D 移动，Space/W 跳跃，J 冲刺，K 攻击，L/E 释放角色主动技能。")

func _grant_starting_unlocks() -> void:
    var starters := MetaProgress.get_starting_items(meta_data)
    if starters.size() == 0:
        return
    starters.shuffle()
    var count := mini(2, starters.size())
    var names := []
    for i in range(count):
        var item_id := str(starters[i])
        player.add_item(item_id)
        names.append(CinnaItemData.get_display_name(item_id))
    hud.show_message("Starter pocket: %s" % [_join_inline(names)], 3.0)

func _apply_difficulty_start_bonus() -> void:
    var difficulty := str(settings_data.get("difficulty", "normal"))
    if difficulty == "cozy":
        player.max_health += 1
        player.health = player.max_health
        player.shield += 1
    elif difficulty == "spicy":
        player.add_score(50)

func _spawn_room(room_type: String) -> void:
    _clear_room()
    if hud != null:
        hud.hide_route_overlay()
    current_room_type = room_type
    current_region_id = RegionData.get_region_id(current_depth, total_rooms)
    if background != null:
        background.set_region(current_region_id)
    current_elite_modifier = ""
    selected_next_room = ""
    path_choices.clear()
    awaiting_path_choice = false
    awaiting_event_choice = false
    player.position = Vector2(82, 780)
    player.velocity = Vector2.ZERO
    enemies_alive = 0

    if room_type == "elite":
        current_elite_modifier = _random_elite_modifier()

    _create_stage_geometry(room_type)
    _create_door(room_type)

    match room_type:
        "fight":
            _spawn_enemies(2 + int(current_depth / 2), false, "")
            hud.show_message("%s：%s" % [RegionData.get_name(current_region_id), RegionData.get_subtitle(current_region_id)], 2.4)
            door.set_open(false)
        "elite":
            _spawn_enemies(3 + int(current_depth / 2), false, current_elite_modifier)
            _spawn_enemy(Vector2(390, 772), "cork", false, current_elite_modifier)
            _spawn_hazard(Vector2(270, 846), "syrup", 1)
            hud.show_message("Elite Room: %s foes. Greedy route, spicy bill." % [_elite_modifier_label(current_elite_modifier)], 2.6)
            door.set_open(false)
        "treasure":
            _spawn_decor(Vector2(270, 726), "chest", "free flavors")
            _spawn_item(Vector2(215, 690), CinnaItemData.random_reward_item(current_depth, room_type))
            _spawn_item(Vector2(325, 690), CinnaItemData.random_reward_item(current_depth, room_type))
            hud.show_message("Treasure: two flavors, zero paperwork.", 2.0)
            _offer_path_choices()
        "rest":
            player.heal(2)
            _spawn_decor(Vector2(270, 720), "chest", "rest stop")
            _spawn_item(Vector2(270, 690), "honey")
            hud.show_message("Rest Stop: honey, warmth, tiny victory snacks.", 2.0)
            _offer_path_choices()
        "shop":
            _spawn_decor(Vector2(270, 718), "shopkeeper", "brush items to buy")
            _spawn_shop_items()
            hud.show_message("Shop: walk into an item to buy it. No haggling with tiny spoons.", 2.6)
            _show_tutorial_once("shop", "商店提示：带价格的配料需要金币。钱不够时会被礼貌拒绝，没有讨价还价按钮。")
            _offer_path_choices()
        "event":
            _spawn_decor(Vector2(270, 720), "event", "press 1/2/3")
            _start_event()
        "shelf_boss":
            _spawn_decor(Vector2(270, 782), "beacon", "BOTTLE GATE")
            _spawn_enemy(Vector2(382, 748), "shelf_boss", true, "")
            hud.show_message("区域 Boss：瓶塞升降机长挡住了酒瓶货架入口！", 2.7)
            _show_tutorial_once("midboss", "Boss 提示：红色预警是攻击前摇。先躲开，再把勺子、冰杯或柠檬弹幕送上账单。")
            door.set_open(false)
        "boss":
            _spawn_decor(Vector2(270, 782), "beacon")
            _spawn_enemy(Vector2(390, 750), "boss", true, "")
            hud.show_message("Final Boss: 香气祭坛开锅了，读招、躲避、点亮信标！", 2.7)
            _show_tutorial_once("final_boss", "最终提示：保持移动，别贪刀。主动技能冷却好了就用，香气信标等着你点亮。")
            door.set_open(false)

    _set_room_actors_active(game_state == "playing")
    hud.update_room(current_depth, total_rooms, room_type, RegionData.get_name(current_region_id))
    hud.update_route_map(current_depth, total_rooms, path_choices, selected_next_room, RegionData.get_name(current_region_id))
    hud.update_stats(player)

func _clear_room() -> void:
    if hud != null:
        hud.hide_choices()
    for child in get_tree().get_nodes_in_group("room_content"):
        if is_instance_valid(child):
            child.queue_free()

func _create_stage_geometry(room_type: String) -> void:
    var base_color := RegionData.get_color(current_region_id, "floor_color")
    var floor_style := RegionData.get_style(current_region_id, "floor_style")
    var left_style := RegionData.get_style(current_region_id, "left_platform_style")
    var right_style := RegionData.get_style(current_region_id, "right_platform_style")
    var bridge_style := RegionData.get_style(current_region_id, "bridge_style")

    _create_platform(Vector2(270, 870), Vector2(560, 90), base_color, floor_style)
    _create_platform(Vector2(-20, 480), Vector2(40, 900), Color(0.18, 0.09, 0.06), "wood")
    _create_platform(Vector2(560, 480), Vector2(40, 900), Color(0.18, 0.09, 0.06), "wood")

    if room_type == "boss" or room_type == "shelf_boss":
        _create_platform(Vector2(150, 710), Vector2(150, 22), _style_color("cinnamon"), "cinnamon")
        _create_platform(Vector2(390, 650), Vector2(130, 22), _style_color("ice"), "ice")
        _create_platform(Vector2(270, 565), Vector2(120, 22), _style_color("mint"), "mint")
        _create_platform(Vector2(270, 455), Vector2(90, 20), _style_color("glass"), "glass")
    elif room_type == "treasure" or room_type == "rest" or room_type == "shop" or room_type == "event":
        _create_platform(Vector2(270, 760), Vector2(180, 24), _style_color(right_style), right_style)
        _create_platform(Vector2(150, 650), Vector2(110, 22), _style_color(left_style), left_style)
        _create_platform(Vector2(390, 650), Vector2(110, 22), _style_color(bridge_style), bridge_style)
        if current_region_id == "bottle_shelf":
            _create_platform(Vector2(270, 540), Vector2(100, 20), _style_color("glass"), "glass")
    else:
        _create_platform(Vector2(162, 710), Vector2(130, 22), _style_color(left_style), left_style)
        _create_platform(Vector2(390, 638), Vector2(134, 22), _style_color(right_style), right_style)
        _create_platform(Vector2(265, 545), Vector2(160, 24), _style_color(bridge_style), bridge_style)
        if current_region_id == "bottle_shelf":
            _create_platform(Vector2(90, 585), Vector2(86, 20), _style_color("glass"), "glass")
            _create_platform(Vector2(450, 510), Vector2(86, 20), _style_color("cinnamon"), "cinnamon")

func _style_color(style: String) -> Color:
    match style:
        "wood": return Color(0.49, 0.30, 0.16)
        "ice": return Color(0.78, 0.94, 1.0)
        "mint": return Color(0.40, 0.93, 0.38)
        "cinnamon": return Color(0.74, 0.39, 0.17)
        "glass": return Color(0.66, 0.90, 1.0)
    return Color(0.49, 0.30, 0.16)

func _create_platform(center: Vector2, size: Vector2, color: Color, style := "wood") -> StaticBody2D:
    var body := StaticBody2D.new()
    body.position = center
    body.collision_layer = 2
    body.collision_mask = 1 | 4
    body.add_to_group("room_content")

    var shape := RectangleShape2D.new()
    shape.size = size
    var col := CollisionShape2D.new()
    col.shape = shape
    body.add_child(col)

    var visual: CinnaPlatformVisual = PlatformVisualScene.new()
    visual.setup(size, color, style)
    body.add_child(visual)

    add_child(body)
    return body

func _create_door(room_type: String) -> void:
    door = DoorScene.new()
    door.position = Vector2(490, 790)
    door.label = "CLEAR" if room_type == "boss" or room_type == "shelf_boss" else "PICK"
    door.add_to_group("room_content")
    door.entered.connect(_on_door_entered)
    add_child(door)

func _spawn_enemies(count: int, is_boss := false, modifier := "") -> void:
    var kinds := RegionData.get_enemy_pool(current_region_id)
    for i in range(count):
        var x := 120 + (i * 88) % 360
        var y := 790 - (i % 3) * (95 if current_region_id == "bottle_shelf" else 110)
        var kind: String = str(kinds[randi() % kinds.size()])
        if kind == "boss":
            kind = "cork"
        _spawn_enemy(Vector2(x, y), kind, is_boss, modifier)

func _spawn_enemy(pos: Vector2, kind: String, is_boss := false, modifier := "") -> void:
    var enemy: CinnaEnemy = EnemyScene.new()
    enemy.setup(kind, is_boss, modifier, current_depth)
    _apply_difficulty_to_enemy(enemy)
    enemy.position = pos
    enemy.add_to_group("room_content")
    enemy.died.connect(_on_enemy_died)
    enemy.projectile_requested.connect(_on_enemy_projectile_requested)
    enemy.hazard_requested.connect(_on_enemy_hazard_requested)
    enemy.damaged.connect(_on_enemy_damaged)
    add_child(enemy)
    enemies_alive += 1


func _apply_difficulty_to_enemy(enemy: CinnaEnemy) -> void:
    var difficulty := str(settings_data.get("difficulty", "normal"))
    if difficulty == "cozy":
        enemy.max_health = maxi(1, enemy.max_health - (2 if enemy.boss else 1))
        enemy.health = mini(enemy.health, enemy.max_health)
        enemy.damage = maxi(1, enemy.damage - 1)
        enemy.speed *= 0.90
    elif difficulty == "spicy":
        enemy.max_health += 3 if enemy.boss else 1
        enemy.health = enemy.max_health
        enemy.damage += 1 if current_depth >= 3 or enemy.boss else 0
        enemy.speed *= 1.08
        enemy.score_value += 35

func _spawn_item(pos: Vector2, kind: String, price := 0) -> void:
    var item: CinnaItemPickup = ItemScene.new()
    item.setup(kind, price)
    item.position = pos
    item.add_to_group("room_content")
    item.picked.connect(_on_item_picked)
    item.rejected.connect(_on_item_rejected)
    add_child(item)

func _spawn_shop_items() -> void:
    var used := {}
    for i in range(3):
        var kind := CinnaItemData.random_shop_item(current_depth)
        var guard := 0
        while used.has(kind) and guard < 12:
            kind = CinnaItemData.random_shop_item(current_depth)
            guard += 1
        used[kind] = true
        var price := CinnaItemData.get_price(kind) + current_depth * 3
        _spawn_item(Vector2(150 + i * 120, 690), kind, price)

func _spawn_decor(pos: Vector2, kind: String, label := "") -> void:
    var decor: CinnaDecor = DecorScene.new()
    decor.setup(kind, label)
    decor.position = pos
    decor.add_to_group("room_content")
    add_child(decor)

func _spawn_projectile(pos: Vector2, vel: Vector2, damage: int, color: Color, ttl: float, label := "") -> void:
    var projectile: CinnaProjectile = ProjectileScene.new()
    projectile.setup(vel, damage, color, ttl, label)
    projectile.position = pos
    projectile.add_to_group("room_content")
    projectile.z_index = 4
    add_child(projectile)

func _spawn_hazard(pos: Vector2, kind: String, damage: int) -> void:
    var hazard: CinnaHazard = HazardScene.new()
    hazard.setup(kind, damage)
    hazard.position = pos
    hazard.add_to_group("room_content")
    hazard.z_index = 3
    add_child(hazard)

func _spawn_floating_text(pos: Vector2, text: String, color := Color(1.0, 0.9, 0.45), size := 18) -> void:
    var floating: CinnaFloatingText = FloatingTextScene.new()
    floating.setup(text, color, size)
    floating.position = pos
    floating.add_to_group("room_content")
    floating.z_index = 20
    add_child(floating)

func _random_elite_modifier() -> String:
    var modifiers := ["spicy", "frosted", "bubbly"]
    return modifiers[randi() % modifiers.size()]

func _elite_modifier_label(modifier: String) -> String:
    match modifier:
        "spicy":
            return "SPICY / 辣味"
        "frosted":
            return "FROSTED / 霜冻"
        "bubbly":
            return "BUBBLY / 气泡"
    return "NORMAL"

func _start_event() -> void:
    var events := ["mint_dance", "cinnamon_riddle", "ice_toast", "lime_choir", "torch_rehearsal"]
    if current_region_id == "bottle_shelf":
        events.append("bottle_elevator")
        events.append("shelf_auditor")
        events.append("garnish_fountain")
    current_event_id = events[randi() % events.size()]
    awaiting_event_choice = true
    match current_event_id:
        "mint_dance":
            hud.show_choices("Mint Sprite wants a cup-top dance:", ["Dance: gain 薄荷叶", "Spin harder: gain 薄荷叶 + 10 gold, take 1 damage", "Politely clap: heal 1"])
        "cinnamon_riddle":
            hud.show_choices("A cinnamon bridge asks a riddle in tiny bark-language:", ["Answer boldly: gain 肉桂棒", "Pay 12 gold for a hint: gain 打火星芯", "Make a pun: gain 25 score and 8 gold"])
        "ice_toast":
            hud.show_choices("Ice-cube buddies raise a sparkling toast:", ["Toast to courage: gain 清脆冰块", "Toast to bubbles: gain 气泡水", "Toast to snacks: gain 蜂蜜滴"])
        "bottle_elevator":
            hud.show_choices("A bottle elevator rattles upward with dramatic cork noises:", ["Ride safely: gain 20 score and 10 gold", "Jump between shelves: gain 气泡水, take 1 damage", "Polish the glass: gain 厚玻璃杯壁"])
        "lime_choir":
            hud.show_choices("A choir of tiny lime slices sings wildly off-key:", ["Sing along: gain 青柠星片", "Conduct them: gain 18 gold", "Request encore: gain score, take 1 damage"])
        "torch_rehearsal":
            hud.show_choices("A nervous torch-lighter practices dramatic entrances:", ["Offer timing tips: gain 打火星芯", "Stand very still: gain shield", "Applaud loudly: gain 160 score"])
        "shelf_auditor":
            hud.show_choices("A bottle-shelf auditor demands flavor paperwork:", ["Submit receipts: spend 10g, gain 稀有机会", "Invent a form: gain 金糖晶 chance", "Hide behind mint: gain 薄荷叶"])
        "garnish_fountain":
            hud.show_choices("A garnish fountain bubbles with suspicious generosity:", ["Drink carefully: heal 2", "Bottle a sample: gain 滋补汤力水", "Toss in coin: spend 8g, gain random item"])
    if player != null:
        player.set_controls_enabled(false)
    hud.show_message("Event Room: choose with 1 / 2 / 3.", 2.6)
    _show_tutorial_once("event", "事件提示：事件没有标准答案，只有风味后果。1/2/3 选择你这杯的命运。")

func _resolve_event_choice(index: int) -> void:
    awaiting_event_choice = false
    match current_event_id:
        "mint_dance":
            if index == 0:
                player.add_item("mint")
                hud.show_message("You danced. The mint sprite awards suspiciously fresh speed.", 2.5)
            elif index == 1:
                player.add_item("mint")
                player.add_gold(10)
                player.take_damage(1, player.global_position.x - 1.0)
                hud.show_message("Heroic over-spin! Stylish, dizzy, profitable.", 2.5)
            else:
                player.heal(1)
                hud.show_message("Polite clapping restores morale. Very tactical.", 2.5)
        "cinnamon_riddle":
            if index == 0:
                player.add_item("cinnamon")
                hud.show_message("Correct enough. The bridge respects confidence.", 2.5)
            elif index == 1:
                if player.try_spend_gold(12):
                    player.add_item("ember")
                    hud.show_message("The hint was: fire likes snacks. Useful? Somehow yes.", 2.8)
                else:
                    player.add_score(120)
                    hud.show_message("Not enough gold. The bridge gives pity points.", 2.4)
            else:
                player.add_score(250)
                player.add_gold(8)
                hud.show_message("The pun lands with a wooden thud. Rewarded by tradition.", 2.8)
        "ice_toast":
            if index == 0:
                player.add_item("ice")
            elif index == 1:
                player.add_item("bubble")
            else:
                player.add_item("honey")
            hud.show_message("Cheers! A tiny glass clink echoes across the mug kingdom.", 2.6)
        "bottle_elevator":
            if index == 0:
                player.add_score(200)
                player.add_gold(10)
                hud.show_message("The elevator wheezes upward. Somehow, this counts as progress.", 2.6)
            elif index == 1:
                player.add_item("bubble")
                player.take_damage(1, player.global_position.x + 1.0)
                hud.show_message("Shelf parkour! Stylish, fizzy, only mildly unsafe.", 2.8)
            else:
                player.add_item("glass")
                hud.show_message("You polish a giant glass panel until destiny reflects back.", 2.8)
        "lime_choir":
            if index == 0:
                player.add_item("lime")
            elif index == 1:
                player.add_gold(18)
            else:
                player.add_score(240)
                player.take_damage(1, player.global_position.x - 1.0)
            hud.show_message("The choir hits one heroic pixel note. Everyone pretends it was planned.", 2.7)
        "torch_rehearsal":
            if index == 0:
                player.add_item("ember")
            elif index == 1:
                player.shield += 2
                player.stats_changed.emit()
            else:
                player.add_score(160)
            hud.show_message("The torch bows. The curtain is mostly not on fire.", 2.6)
        "shelf_auditor":
            if index == 0 and player.try_spend_gold(10):
                player.add_item(CinnaItemData.random_reward_item(current_depth + 3, "elite"))
            elif index == 1:
                if randf() < 0.35:
                    player.add_item("sugar")
                else:
                    player.add_gold(12)
                    player.add_score(120)
            else:
                player.add_item("mint")
            hud.show_message("The auditor stamps a napkin. Legally binding, probably.", 2.8)
        "garnish_fountain":
            if index == 0:
                player.heal(2)
            elif index == 1:
                player.add_item("tonic")
            else:
                if player.try_spend_gold(8):
                    player.add_item(CinnaItemData.random_reward_item(current_depth, "treasure"))
                else:
                    player.heal(1)
            hud.show_message("The fountain burbles approval in tiny carbonation syllables.", 2.7)
    _play_sound("route")
    _offer_path_choices()

func _offer_path_choices() -> void:
    if current_depth >= total_rooms - 2:
        selected_next_room = "boss"
        awaiting_path_choice = false
        if door != null:
            door.label = "BOSS"
            door.set_open(true)
        if player != null:
            player.set_controls_enabled(true)
        hud.hide_choices()
        hud.hide_route_overlay()
        hud.update_route_map(current_depth, total_rooms, ["boss"], "boss", RegionData.get_name(current_region_id))
        hud.show_message("The Aroma Beacon calls. Enter the golden gate!", 2.5)
        return

    if not mid_boss_cleared and current_depth >= 5:
        selected_next_room = "shelf_boss"
        awaiting_path_choice = false
        if door != null:
            door.label = "MIDBOSS"
            door.set_open(true)
        if player != null:
            player.set_controls_enabled(true)
        hud.hide_choices()
        hud.hide_route_overlay()
        hud.update_route_map(current_depth, total_rooms, ["shelf_boss"], "shelf_boss", RegionData.get_name(current_region_id))
        hud.show_message("Bottle Gate discovered: enter the mid-boss lift!", 2.6)
        return

    path_choices = _generate_path_choices()
    awaiting_path_choice = true
    selected_next_room = ""
    if door != null:
        door.label = "PICK"
        door.set_open(false)
    if player != null:
        player.set_controls_enabled(false)
    _set_room_actors_active(false)
    var labels := []
    for room_type in path_choices:
        labels.append(_room_display_name(room_type))
    hud.show_choices("Choose next route, then enter the door:", labels)
    hud.show_route_overlay("SCOUT ROUTE / 选择路线", path_choices, selected_next_room, RegionData.get_name(current_region_id), current_depth, total_rooms)
    hud.update_route_map(current_depth, total_rooms, path_choices, selected_next_room, RegionData.get_name(current_region_id))
    _show_tutorial_once("route", "路线提示：精英房更危险但奖励更香；宝箱房稳，事件房怪，商店房看钱包脸色。")

func _generate_path_choices() -> Array:
    var pool := ["fight", "fight", "elite", "treasure", "shop", "event", "rest"]
    pool.shuffle()
    var result := []
    for room_type in pool:
        if result.size() >= 3:
            break
        if result.has(room_type) and room_type != "fight":
            continue
        result.append(room_type)
    while result.size() < 3:
        result.append("fight")
    return result

func _room_display_name(room_type: String) -> String:
    match room_type:
        "fight":
            return "战斗房：普通奖励"
        "elite":
            return "精英房：危险，但奖励更香"
        "treasure":
            return "宝箱房：免费配料"
        "rest":
            return "休息房：回血 + 蜂蜜"
        "shop":
            return "商店房：花金币买构筑"
        "event":
            return "事件房：奇怪选择题"
        "shelf_boss":
            return "区域 Boss：瓶塞升降机长"
        "boss":
            return "Boss 房：点亮香气信标"
    return room_type

func _handle_choice_input() -> void:
    var chosen := -1
    if Input.is_action_just_pressed("choice_1"):
        chosen = 0
    elif Input.is_action_just_pressed("choice_2"):
        chosen = 1
    elif Input.is_action_just_pressed("choice_3"):
        chosen = 2
    if chosen < 0:
        return

    if awaiting_event_choice:
        _resolve_event_choice(chosen)
        return
    if awaiting_path_choice and chosen < path_choices.size():
        selected_next_room = path_choices[chosen]
        awaiting_path_choice = false
        if door != null:
            door.label = _door_short_label(selected_next_room)
            door.set_open(true)
        if player != null:
            player.set_controls_enabled(true)
        _set_room_actors_active(true)
        hud.hide_choices()
        hud.hide_route_overlay()
        hud.update_route_map(current_depth, total_rooms, path_choices, selected_next_room, RegionData.get_name(current_region_id))
        _play_sound("route")
        hud.show_message("Route locked: %s. Walk into the gate." % [_room_display_name(selected_next_room)], 2.4)

func _door_short_label(room_type: String) -> String:
    match room_type:
        "fight":
            return "FIGHT"
        "elite":
            return "ELITE"
        "treasure":
            return "LOOT"
        "rest":
            return "REST"
        "shop":
            return "SHOP"
        "event":
            return "EVENT"
        "shelf_boss":
            return "MID"
        "boss":
            return "BOSS"
    return "NEXT"

func _on_enemy_died(enemy: CinnaEnemy) -> void:
    if game_state != "playing":
        return
    enemies_alive -= 1
    player.add_score(enemy.score_value)
    _play_sound("enemy_down")
    _shake(3.0 if not enemy.boss else 9.0, 0.16)
    _spawn_floating_text(enemy.global_position + Vector2(-10, -52), "+%d" % enemy.score_value, Color(1.0, 0.82, 0.25), 18)
    if enemy.boss:
        if current_room_type == "boss":
            _on_victory()
            return
        mid_boss_cleared = true
        var boss_gold := randi_range(24, 42)
        player.add_gold(boss_gold)
        _spawn_item(enemy.global_position + Vector2(-28, -36), CinnaItemData.random_reward_item(current_depth + 2, "elite"))
        _spawn_item(enemy.global_position + Vector2(28, -36), CinnaItemData.random_reward_item(current_depth + 2, "treasure"))
        hud.show_message("Bottle Gate Clear! +%dg. 酒瓶货架正式开门。" % boss_gold, 3.0)
        _offer_path_choices()
        return

    var gold_reward := randi_range(6, 14)
    if current_room_type == "elite":
        gold_reward += randi_range(8, 14)
    player.add_gold(gold_reward)

    if enemies_alive <= 0:
        var reward_kind := CinnaItemData.random_reward_item(current_depth, current_room_type)
        _spawn_item(enemy.global_position + Vector2(0, -35), reward_kind)
        hud.show_message("Room Clear! +%dg and reward: [%s] %s" % [gold_reward, CinnaItemData.get_rarity_zh(reward_kind), CinnaItemData.get_display_name(reward_kind)], 2.3)
        _offer_path_choices()

func _on_enemy_projectile_requested(pos: Vector2, vel: Vector2, damage: int, color: Color, ttl: float, label: String) -> void:
    if game_state != "playing":
        return
    _spawn_projectile(pos, vel, damage, color, ttl, label)

func _on_enemy_hazard_requested(pos: Vector2, kind: String, damage: int) -> void:
    if game_state != "playing":
        return
    _spawn_hazard(pos, kind, damage)

func _on_enemy_damaged(pos: Vector2, amount: int, critical: bool) -> void:
    var text := "%d" % amount
    var col := Color(1.0, 0.86, 0.32)
    var size := 18
    if critical:
        text = "CRIT %d" % amount
        col = Color(1.0, 0.38, 0.12)
        size = 21
    _spawn_floating_text(pos + Vector2(-12, -44), text, col, size)
    _shake(4.5 if critical else 2.0, 0.08 if critical else 0.045)

func _on_item_picked(kind: String) -> void:
    MetaProgress.mark_discovered_item(meta_data, kind)
    var rarity := CinnaItemData.get_rarity(kind)
    _play_sound("rare" if rarity == "rare" or rarity == "legendary" else "pickup")
    _spawn_floating_text(player.global_position + Vector2(-20, -62), CinnaItemData.get_icon(kind), CinnaItemData.get_rarity_color(kind), 23)
    hud.show_message("Gained [%s] %s: %s" % [CinnaItemData.get_rarity_zh(kind), CinnaItemData.get_display_name(kind), CinnaItemData.get_desc(kind)], 3.0)

func _on_item_rejected(kind: String, price: int) -> void:
    hud.show_message("Need %dg for %s. The shopkeeper blinks in pixel economy." % [price, CinnaItemData.get_display_name(kind)], 2.5)

func _on_player_item_gained(kind: String) -> void:
    MetaProgress.mark_discovered_item(meta_data, kind)
    hud.update_stats(player)

func _on_recipe_discovered(recipe_id: String) -> void:
    MetaProgress.mark_discovered_recipe(meta_data, recipe_id)
    hud.update_stats(player)
    _play_sound("recipe")
    _shake(7.0, 0.22)
    _spawn_floating_text(player.global_position + Vector2(-44, -86), "RECIPE!", Color(0.68, 1.0, 0.36), 24)
    hud.show_message("RECIPE DISCOVERED: %s | %s" % [RecipeData.get_name(recipe_id), RecipeData.get_desc(recipe_id)], 4.0)

func _on_player_stats_changed() -> void:
    if hud != null:
        hud.update_stats(player)

func _on_player_attacked(pos: Vector2, facing: int) -> void:
    if game_state != "playing":
        return
    _play_sound("attack")
    _spawn_attack_spark(pos + Vector2(48 * facing, -8), facing)

func _on_player_dashed(pos: Vector2, facing: int) -> void:
    if game_state != "playing":
        return
    _play_sound("dash")
    if player.active_recipes.has("ice_mint_storm"):
        _spawn_ice_spark(pos + Vector2(-20 * facing, 10), facing)

func _on_player_damaged(pos: Vector2, amount: int) -> void:
    if game_state != "playing":
        return
    _play_sound("hurt")
    _shake(8.0, 0.18)
    _spawn_floating_text(pos + Vector2(-18, -58), "-%d" % amount, Color(1.0, 0.24, 0.12), 22)

func _on_player_skill_used(skill_id: String, pos: Vector2, facing: int) -> void:
    if game_state != "playing":
        return
    _play_sound("skill")
    var color := Color(1.0, 0.80, 0.24)
    var radius := 118.0
    var label := "SHAKER!"
    if skill_id == "ice_guard":
        color = Color(0.74, 0.96, 1.0)
        radius = 96.0
        label = "ICE GUARD!"
    elif skill_id == "mint_blink":
        color = Color(0.45, 1.0, 0.48)
        radius = 86.0
        label = "MINT BLINK!"
    elif skill_id == "lime_barrage":
        color = Color(0.86, 1.0, 0.18)
        radius = 132.0
        label = "LIME BARRAGE!"
    _spawn_skill_burst(pos, skill_id, color, radius)
    _spawn_floating_text(player.global_position + Vector2(-44, -92), label, color, 22)
    _shake(6.0, 0.15)

func _on_player_hit_enemy(_pos: Vector2, _amount: int, _critical: bool) -> void:
    if game_state != "playing":
        return
    # Damage numbers are emitted by the enemy, this callback keeps the hook for future combo meters.

func _on_player_landed(pos: Vector2) -> void:
    if game_state != "playing":
        return
    _spawn_floating_text(pos + Vector2(-18, 10), "dust", Color(0.66, 0.42, 0.22), 12)

func _spawn_attack_spark(pos: Vector2, facing: int) -> void:
    var spark := load("res://scripts/spark.gd").new()
    spark.position = pos
    spark.facing = facing
    spark.add_to_group("room_content")
    add_child(spark)

func _spawn_ice_spark(pos: Vector2, facing: int) -> void:
    var spark := load("res://scripts/spark.gd").new()
    spark.position = pos
    spark.facing = facing
    spark.modulate = Color(0.50, 0.95, 1.0)
    spark.add_to_group("room_content")
    add_child(spark)

func _spawn_skill_burst(pos: Vector2, kind: String, color: Color, radius: float) -> void:
    var burst: CinnaSkillBurst = SkillBurstScene.new()
    burst.setup(kind, color, radius)
    burst.position = pos
    burst.add_to_group("room_content")
    burst.z_index = 12
    add_child(burst)

func _on_door_entered() -> void:
    if game_state != "playing" or game_finished:
        return
    if selected_next_room == "":
        hud.show_message("Pick a route with 1 / 2 / 3 first.", 1.8)
        return
    current_depth += 1
    _spawn_room(selected_next_room)

func _on_player_died() -> void:
    _finish_run(false)

func _on_victory() -> void:
    if game_state != "playing":
        return
    player.add_score(1000)
    _play_sound("victory")
    _spawn_decor(Vector2(270, 650), "beacon", "VICTORY")
    _begin_victory_sequence()

func _begin_victory_sequence() -> void:
    game_state = "victory_scene"
    game_finished = true
    victory_timer = 5.2
    player.set_controls_enabled(false)
    _set_room_actors_active(false)
    hud.hide_choices()
    hud.hide_route_overlay()
    hud.show_victory_ceremony(player, RegionData.get_name(current_region_id))
    _shake(10.0, 0.30)

func _finish_run(won: bool) -> void:
    if game_state == "summary":
        return
    if not won:
        _play_sound("defeat")
    game_state = "summary"
    game_finished = true
    player.set_controls_enabled(false)
    _set_room_actors_active(false)
    hud.hide_choices()
    if door != null:
        door.set_open(won)
    var shards := MetaProgress.calculate_shards(won, current_depth, player.score)
    var unlocks := MetaProgress.apply_run_result(meta_data, won, player.score, current_depth, shards)
    last_summary_won = won
    last_summary_shards = shards
    last_summary_unlocks = unlocks
    hud.update_route_map(current_depth, total_rooms, [], "", RegionData.get_name(current_region_id))
    hud.show_summary(won, player, shards, unlocks, meta_data)

func _shake(strength: float, duration: float) -> void:
    if not bool(settings_data.get("screen_shake", true)):
        return
    shake_strength = maxf(shake_strength, strength)
    shake_time = maxf(shake_time, duration)

func _update_camera_shake(delta: float) -> void:
    if camera == null:
        return
    if shake_time > 0.0:
        shake_time -= delta
        camera.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
        shake_strength = maxf(0.0, shake_strength - delta * 25.0)
    else:
        camera.offset = Vector2.ZERO
        shake_strength = 0.0

func _play_sound(key: String) -> void:
    if not bool(settings_data.get("sound_enabled", true)):
        return
    if sound != null:
        sound.play_sfx(key)

func _show_tutorial_once(tutorial_id: String, text: String) -> void:
    if tutorial_seen.has(tutorial_id):
        return
    tutorial_seen[tutorial_id] = true
    if hud != null:
        hud.show_tutorial_tip(text, 6.5)

func _join_inline(values: Array) -> String:
    var text := ""
    for i in range(values.size()):
        if i > 0:
            text += ", "
        text += str(values[i])
    return text
