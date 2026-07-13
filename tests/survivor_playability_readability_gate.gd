extends SceneTree

const MainScene := preload("res://scenes/Main.tscn")

const EXPECTED_VIEWPORT := Vector2i(1280, 720)
const MIN_EARLY_SURVIVAL_SECONDS := 10.0
const MIN_RUNTIME_ENEMIES := 10
const MIN_RUNTIME_PROJECTILES := 8
const MIN_RUNTIME_PICKUPS := 8
const MIN_VISIBLE_MATERIALS := 650
const MIN_BRIGHT_MATERIALS := 95
const MIN_MAX_LUMINANCE := 0.46
const MIN_FLOOR_AVG_LUMINANCE := 0.055
const MIN_FLOOR_MAX_LUMINANCE := 0.22
const MIN_ENV_AMBIENT := 0.18
const MIN_ENV_EXPOSURE := 0.70
const MIN_KEY_LIGHT := 0.70
const MIN_FLOOR_MATERIAL_LUMINANCE := 0.82
const TEST_ARENA := Rect2(-1520, -900, 3040, 1800)

const REQUIRED_CHANNEL_PREFIXES := [
    "arena_readability",
    "champion",
    "enemy",
    "enemy_hazard",
    "pickup"
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    seed(20260704)

    if not _require_project_window():
        return

    var main = MainScene.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame

    if not _require_startup_surface(main):
        return

    main._start_new_run()
    await process_frame
    main._choose_fate(0)
    await process_frame

    if str(main.get("game_state")) != "playing":
        push_error("Playability gate expected game_state=playing after fate choice.")
        quit(1)
        return

    var player = main.get("player")
    if player == null or not bool(player.visible):
        push_error("Playability gate expected visible player after start.")
        quit(1)
        return
    if not bool(player.get("controls_enabled")):
        push_error("Playability gate expected keyboard controls to be enabled in play.")
        quit(1)
        return

    main.set("spawn_timer", 0.02)
    main.set("elite_timer", 1.2)
    var center: Vector2 = player.global_position
    _seed_runtime_readability_objects(main, center)
    await process_frame

    var elapsed_sim := 0.0
    while elapsed_sim < MIN_EARLY_SURVIVAL_SECONDS:
        var t := elapsed_sim * 0.62
        player.global_position = _clamp_to_arena(main, center + Vector2(cos(t) * 175.0, sin(t * 0.83) * 118.0))
        main._run_survivor_loop(0.05)
        main.call("_update_camera", 0.05)
        main.call("_update_camera_shake", 0.05)
        elapsed_sim += 0.05
        await process_frame

    await _resume_to_active_play(main)
    if int(player.get("health")) <= 0 or str(main.get("game_state")) == "summary":
        push_error("Playability gate expected player to survive the first %.1f seconds." % MIN_EARLY_SURVIVAL_SECONDS)
        quit(1)
        return
    if str(main.get("game_state")) != "playing":
        push_error("Playability gate expected to return to active play after legal choice interrupts, got %s." % str(main.get("game_state")))
        quit(1)
        return

    _seed_runtime_readability_objects(main, player.global_position)
    await process_frame
    await process_frame
    await _resume_to_active_play(main)

    var enemy_count := get_nodes_in_group("survivor_enemies").size()
    var projectile_count := get_nodes_in_group("survivor_projectiles").size()
    var pickup_count := get_nodes_in_group("survivor_pickups").size()
    if enemy_count < MIN_RUNTIME_ENEMIES:
        push_error("Playability gate expected active enemies, got %d." % enemy_count)
        quit(1)
        return
    if projectile_count < MIN_RUNTIME_PROJECTILES:
        push_error("Playability gate expected readable projectile pressure, got %d." % projectile_count)
        quit(1)
        return
    if pickup_count < MIN_RUNTIME_PICKUPS:
        push_error("Playability gate expected visible rewards/pickups, got %d." % pickup_count)
        quit(1)
        return

    var visual3d = main.get("visual3d")
    if visual3d == null:
        push_error("Playability gate expected live 3D view.")
        quit(1)
        return

    if not _require_human_view_camera(main, visual3d):
        return
    if not _require_overlay_not_blocking(main):
        return
    if not _require_lighting_floor_not_black(visual3d):
        return
    if not _require_runtime_readability_nodes(visual3d):
        return

    var stats := _collect_material_readability(visual3d)
    if int(stats["visible_materials"]) < MIN_VISIBLE_MATERIALS:
        push_error("Playability gate expected enough visible materials, got %d." % int(stats["visible_materials"]))
        quit(1)
        return
    if int(stats["bright_materials"]) < MIN_BRIGHT_MATERIALS:
        push_error("Playability gate expected enough highlights/readability anchors, got %d." % int(stats["bright_materials"]))
        quit(1)
        return
    if float(stats["max_luminance"]) < MIN_MAX_LUMINANCE:
        push_error("Playability gate scene is too dark; max luminance %.3f." % float(stats["max_luminance"]))
        quit(1)
        return
    for prefix in REQUIRED_CHANNEL_PREFIXES:
        if not _has_channel_prefix(stats, str(prefix)):
            push_error("Playability gate missing readable visual channel prefix: %s." % str(prefix))
            quit(1)
            return
    if _has_pickup_enemy_hazard_leak(visual3d):
        push_error("Playability gate detected pickup visuals leaking into enemy hazard language.")
        quit(1)
        return

    print("SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=%dx%d alive=true enemies=%d projectiles=%d pickups=%d visible=%d bright=%d max_luma=%.3f floor_avg=%.3f floor_max=%.3f" % [
        EXPECTED_VIEWPORT.x,
        EXPECTED_VIEWPORT.y,
        enemy_count,
        projectile_count,
        pickup_count,
        int(stats["visible_materials"]),
        int(stats["bright_materials"]),
        float(stats["max_luminance"]),
        float(stats["floor_avg_luminance"]),
        float(stats["floor_max_luminance"])
    ])
    quit(0)

func _require_project_window() -> bool:
    var width := int(ProjectSettings.get_setting("display/window/size/viewport_width", 0))
    var height := int(ProjectSettings.get_setting("display/window/size/viewport_height", 0))
    if width != EXPECTED_VIEWPORT.x or height != EXPECTED_VIEWPORT.y:
        push_error("Playability gate expected %dx%d viewport, got %dx%d." % [EXPECTED_VIEWPORT.x, EXPECTED_VIEWPORT.y, width, height])
        quit(1)
        return false
    return true

func _require_startup_surface(main: Node) -> bool:
    if not bool(main.get("use_3d_view")):
        push_error("Playability gate expected 3D view to be enabled.")
        quit(1)
        return false
    if main.get("visual3d") == null:
        push_error("Playability gate expected 3D view at startup.")
        quit(1)
        return false
    if main.get("hud") == null:
        push_error("Playability gate expected HUD at startup.")
        quit(1)
        return false
    return true

func _seed_runtime_readability_objects(main: Node, center: Vector2) -> void:
    var enemy_kinds := ["voidling", "skitter", "spitter", "burrower", "carapace", "void_eye", "rift_crystal"]
    for i in range(18):
        var angle := TAU * float(i) / 18.0
        var radius := 245.0 + float(i % 4) * 46.0
        main._spawn_enemy(center + Vector2(cos(angle), sin(angle)) * radius, str(enemy_kinds[i % enemy_kinds.size()]), i % 9 == 0)

    var projectile_labels := ["fishbones", "viktor", "teemo", "comet", "A", "V", "X", "B", "void_spit"]
    for i in range(24):
        var angle := TAU * float(i) / 24.0
        var dir := Vector2(cos(angle), sin(angle))
        var from_player := i % 3 != 0
        var label := str(projectile_labels[i % projectile_labels.size()])
        var color := Color(0.34, 0.84, 1.0) if from_player else Color(1.0, 0.10, 0.34)
        main._spawn_projectile(center + dir * 72.0, dir * (230.0 if from_player else 165.0), 3, 8.0, color, label, 1, 1.35, from_player)

    for i in range(22):
        var angle := TAU * float(i) / 22.0
        var radius := 340.0 + float(i % 5) * 28.0
        var kind := "xp"
        var amount := 2 + i % 8
        var color: Color = main._xp_color(amount)
        if i % 7 == 0:
            kind = "gold"
            amount = 14
            color = Color(1.0, 0.76, 0.20)
        main._spawn_pickup(center + Vector2(cos(angle), sin(angle)) * radius, kind, amount, color)

func _clamp_to_arena(main: Node, pos: Vector2) -> Vector2:
    var arena := TEST_ARENA
    pos.x = clampf(pos.x, arena.position.x + 96.0, arena.end.x - 96.0)
    pos.y = clampf(pos.y, arena.position.y + 96.0, arena.end.y - 96.0)
    return pos

func _resume_to_active_play(main: Node) -> void:
    for _i in range(8):
        var state := str(main.get("game_state"))
        match state:
            "playing":
                return
            "levelup":
                main._choose_upgrade(0)
            "hextech":
                main._choose_hextech_augment(0)
            "shop":
                main._close_shop()
            "paused":
                main._resume_run()
            _:
                return
        await process_frame

func _require_human_view_camera(main: Node, visual3d: Node) -> bool:
    var camera2d := main.get("camera") as Camera2D
    if camera2d == null:
        push_error("Playability gate expected 2D camera controller.")
        quit(1)
        return false
    if camera2d.offset.length() > 0.01:
        push_error("Playability gate expected no camera shake offset in 3D mode.")
        quit(1)
        return false

    var camera3d := visual3d.get("camera") as Camera3D
    if camera3d == null:
        push_error("Playability gate expected top-down 3D camera.")
        quit(1)
        return false
    var rot := camera3d.rotation_degrees
    if absf(rot.x + 90.0) > 0.05 or absf(rot.y) > 0.05 or absf(rot.z) > 0.05:
        push_error("Playability gate expected stable top-down camera, got rotation %s." % str(rot))
        quit(1)
        return false
    if camera3d.projection != Camera3D.PROJECTION_ORTHOGONAL:
        push_error("Playability gate expected orthogonal camera.")
        quit(1)
        return false
    if camera3d.size < 24.0 or camera3d.size > 32.0:
        push_error("Playability gate expected readable camera size, got %.2f." % camera3d.size)
        quit(1)
        return false
    return true

func _require_overlay_not_blocking(main: Node) -> bool:
    var hud = main.get("hud")
    if hud == null:
        push_error("Playability gate expected HUD.")
        quit(1)
        return false
    var overlay_rect := hud.get("overlay_rect") as Control
    if overlay_rect != null and bool(overlay_rect.visible):
        push_error("Playability gate expected no blocking overlay during active play.")
        quit(1)
        return false
    var choice_buttons: Array = hud.get("choice_buttons")
    for button in choice_buttons:
        if button is Control and bool(button.visible):
            push_error("Playability gate expected choice cards hidden during active play.")
            quit(1)
            return false
    var start_button := hud.get("start_button") as Control
    if start_button != null and bool(start_button.visible):
        push_error("Playability gate expected start button hidden during active play.")
        quit(1)
        return false
    return true

func _require_lighting_floor_not_black(visual3d: Node) -> bool:
    var env_node := visual3d.find_child("HextechVoidWorldEnvironment", true, false) as WorldEnvironment
    if env_node == null or env_node.environment == null:
        push_error("Playability gate expected world environment.")
        quit(1)
        return false
    var environment := env_node.environment
    if environment.ambient_light_energy < MIN_ENV_AMBIENT:
        push_error("Playability gate ambient light too low: %.3f." % environment.ambient_light_energy)
        quit(1)
        return false
    if environment.tonemap_exposure < MIN_ENV_EXPOSURE:
        push_error("Playability gate tonemap exposure too low: %.3f." % environment.tonemap_exposure)
        quit(1)
        return false
    var key_light := visual3d.find_child("HextechKeyLight", true, false) as DirectionalLight3D
    if key_light == null or key_light.light_energy < MIN_KEY_LIGHT:
        push_error("Playability gate key light too low or missing.")
        quit(1)
        return false
    for light_name in ["HextechFillLight", "VoidRimLight", "HextechGoldRimLight"]:
        if visual3d.find_child(light_name, true, false) == null:
            push_error("Playability gate missing readable rim/fill light %s." % light_name)
            quit(1)
            return false

    var floor := visual3d.find_child("ArenaPaintedFloor", true, false) as MeshInstance3D
    var floor_mat := floor.material_override as StandardMaterial3D if floor != null else null
    if floor_mat == null or floor_mat.albedo_texture == null:
        push_error("Playability gate expected textured arena floor.")
        quit(1)
        return false
    if _luminance(floor_mat.albedo_color) < MIN_FLOOR_MATERIAL_LUMINANCE:
        push_error("Playability gate floor material tint too dark: %.3f." % _luminance(floor_mat.albedo_color))
        quit(1)
        return false
    var floor_stats := _sample_floor_texture(visual3d)
    if float(floor_stats["avg"]) < MIN_FLOOR_AVG_LUMINANCE or float(floor_stats["max"]) < MIN_FLOOR_MAX_LUMINANCE:
        push_error("Playability gate floor texture too dark: avg %.3f max %.3f." % [float(floor_stats["avg"]), float(floor_stats["max"])])
        quit(1)
        return false
    return true

func _require_runtime_readability_nodes(visual3d: Node) -> bool:
    for node_name in [
        "ChampionIdentityProjection",
        "ChampionFanReadableSilhouetteRig",
        "EnemyGroundSilhouettePickupGap",
        "EnemyThreatOcclusionPlate",
        "EnemyProjectileDangerBackplate",
        "EnemyProjectileDangerNeedle",
        "EnemyProjectilePickupSeparationRing",
        "PickupCollectibleBackplate",
        "PickupRewardBeacon",
        "ArenaCombatReadabilityStrataSet"
    ]:
        if visual3d.find_child(node_name, true, false) == null:
            push_error("Playability gate missing readability node %s." % node_name)
            quit(1)
            return false
    var alternate_groups := [
        ["EnemyReadabilityPlate", "LiteEnemyReadabilityPlate"],
        ["EnemyTacticalReadabilityPlaque", "EnemySpeciesRoleBanner", "LiteEnemyReadabilityPlate"]
    ]
    for group in alternate_groups:
        if not _has_any_node(visual3d, group):
            push_error("Playability gate missing runtime readability node group %s." % str(group))
            quit(1)
            return false
    return true

func _has_any_node(root_node: Node, names: Array) -> bool:
    for node_name in names:
        if root_node.find_child(str(node_name), true, false) != null:
            return true
    return false

func _collect_material_readability(visual3d: Node) -> Dictionary:
    var stats := {
        "visible_materials": 0,
        "bright_materials": 0,
        "max_luminance": 0.0,
        "floor_avg_luminance": 0.0,
        "floor_max_luminance": 0.0,
        "channels": {}
    }
    var floor_stats := _sample_floor_texture(visual3d)
    stats["floor_avg_luminance"] = float(floor_stats["avg"])
    stats["floor_max_luminance"] = float(floor_stats["max"])
    _scan_materials(visual3d, stats)
    return stats

func _scan_materials(node: Node, stats: Dictionary) -> void:
    if node is MeshInstance3D:
        var mesh := node as MeshInstance3D
        var mat := mesh.material_override as StandardMaterial3D
        if mat != null:
            var channel := _inherited_meta(mesh, "combat_visual_channel")
            var stratum := _inherited_meta(mesh, "visual_stratum")
            if channel != "grounding_shadow":
                var alpha := mat.albedo_color.a
                var luma := _luminance(mat.albedo_color)
                if alpha >= 0.08:
                    stats["visible_materials"] = int(stats["visible_materials"]) + 1
                    stats["max_luminance"] = maxf(float(stats["max_luminance"]), luma)
                    if luma >= 0.24 or (mat.emission_enabled and mat.emission_energy_multiplier > 0.015):
                        stats["bright_materials"] = int(stats["bright_materials"]) + 1
                _add_channel_stat(stats, channel, luma, alpha)
                if stratum.begins_with("pickup_collectible"):
                    _add_channel_stat(stats, "pickup", luma, alpha)
    for child in node.get_children():
        _scan_materials(child, stats)

func _add_channel_stat(stats: Dictionary, channel: String, luma: float, alpha: float) -> void:
    if channel == "":
        return
    var channels: Dictionary = stats["channels"]
    if not channels.has(channel):
        channels[channel] = {"count": 0, "max_luminance": 0.0, "visible": 0}
    var channel_stats: Dictionary = channels[channel]
    channel_stats["count"] = int(channel_stats["count"]) + 1
    channel_stats["max_luminance"] = maxf(float(channel_stats["max_luminance"]), luma)
    if alpha >= 0.08:
        channel_stats["visible"] = int(channel_stats["visible"]) + 1

func _has_channel_prefix(stats: Dictionary, prefix: String) -> bool:
    var channels: Dictionary = stats["channels"]
    for channel in channels.keys():
        var channel_name := str(channel)
        var channel_stats: Dictionary = channels[channel]
        if channel_name.begins_with(prefix) and int(channel_stats["visible"]) >= 3 and float(channel_stats["max_luminance"]) >= 0.10:
            return true
    return false

func _has_pickup_enemy_hazard_leak(node: Node) -> bool:
    if node == null:
        return false
    var stratum := str(node.get_meta("visual_stratum", ""))
    if stratum.begins_with("pickup_collectible"):
        if str(node.get_meta("combat_visual_channel", "")).begins_with("enemy_hazard"):
            return true
        if bool(node.get_meta("enemy_hazard_language", false)):
            return true
    for child in node.get_children():
        if _has_pickup_enemy_hazard_leak(child):
            return true
    return false

func _sample_floor_texture(visual3d: Node) -> Dictionary:
    var path := ""
    if visual3d.has_method("_arena_floor_texture_path"):
        path = str(visual3d.call("_arena_floor_texture_path"))
    if path == "" or not FileAccess.file_exists(path):
        return {"avg": 0.0, "max": 0.0}
    var image := Image.new()
    if image.load(path) != OK:
        return {"avg": 0.0, "max": 0.0}
    var step_x := maxi(1, int(image.get_width() / 96))
    var step_y := maxi(1, int(image.get_height() / 54))
    var total := 0.0
    var max_luma := 0.0
    var count := 0
    for y in range(0, image.get_height(), step_y):
        for x in range(0, image.get_width(), step_x):
            var luma := _luminance(image.get_pixel(x, y))
            total += luma
            max_luma = maxf(max_luma, luma)
            count += 1
    return {"avg": total / maxf(1.0, float(count)), "max": max_luma}

func _inherited_meta(node: Node, key: String) -> String:
    var current: Node = node
    while current != null:
        if current.has_meta(key):
            return str(current.get_meta(key, ""))
        current = current.get_parent()
    return ""

func _luminance(color: Color) -> float:
    return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
