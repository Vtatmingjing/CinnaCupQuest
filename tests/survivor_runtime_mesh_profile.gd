extends SceneTree

const MainScene := preload("res://scenes/Main.tscn")

const SIM_SECONDS := 18.0
const STEP := 0.10

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    seed(20260706)
    var main = MainScene.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame

    main._start_new_run()
    await process_frame
    main._choose_fate(0)
    await process_frame

    var player = main.get("player")
    if player == null:
        push_error("Runtime mesh profile could not find player.")
        quit(1)
        return
    player.set("max_health", 999)
    player.set("health", 999)
    player.set("shield", 999)
    player.set("invincible_timer", SIM_SECONDS + 10.0)
    main.set("spawn_timer", 999.0)
    main.set("elite_timer", 999.0)
    main.set("boss_spawned", true)
    main.set("boss_alive", false)

    var center: Vector2 = player.global_position
    _fill_budget_stress_scene(main, center)

    var elapsed_sim := 0.0
    while elapsed_sim < SIM_SECONDS:
        var t := elapsed_sim * 0.72
        player.global_position = center + Vector2(cos(t) * 360.0, sin(t * 0.63) * 260.0)
        main._run_survivor_loop(STEP)
        main.call("_update_camera", STEP)
        main.call("_update_camera_shake", STEP)
        await process_frame
        await _resume_to_active_play(main)
        elapsed_sim += STEP

    var visual = main.get("visual3d")
    if visual == null:
        push_error("Runtime mesh profile expected visual3d.")
        quit(1)
        return

    var total_meshes := _count_mesh_instances(visual)
    var total_nodes := _count_nodes(visual)
    var player_meshes := _count_mesh_instances(visual.get("player_model"))
    var enemy_meshes := _count_dictionary_meshes(visual.get("enemy_models"))
    var projectile_meshes := _count_dictionary_meshes(visual.get("projectile_models"))
    var pickup_meshes := _count_dictionary_meshes(visual.get("pickup_models"))
    var zone_meshes := _count_dictionary_meshes(visual.get("zone_models"))
    var pulse_meshes := _count_dictionary_meshes(visual.get("pulse_models"))
    var spawn_rift_meshes := _count_dictionary_meshes(visual.get("spawn_rift_models"))
    var death_burst_meshes := _count_dictionary_meshes(visual.get("death_burst_models"))
    var hit_spark_meshes := _count_dictionary_meshes(visual.get("hit_spark_models"))
    var dynamic_meshes := player_meshes + enemy_meshes + projectile_meshes + pickup_meshes + zone_meshes + pulse_meshes + spawn_rift_meshes + death_burst_meshes + hit_spark_meshes
    var static_meshes := total_meshes - dynamic_meshes

    print("SURVIVOR_RUNTIME_MESH_PROFILE total=%d nodes=%d static=%d player=%d enemies=%d projectiles=%d pickups=%d zones=%d pulses=%d rifts=%d death_bursts=%d hit_sparks=%d enemy_count=%d projectile_count=%d pickup_count=%d" % [
        total_meshes,
        total_nodes,
        static_meshes,
        player_meshes,
        enemy_meshes,
        projectile_meshes,
        pickup_meshes,
        zone_meshes,
        pulse_meshes,
        spawn_rift_meshes,
        death_burst_meshes,
        hit_spark_meshes,
        get_nodes_in_group("survivor_enemies").size(),
        get_nodes_in_group("survivor_projectiles").size(),
        get_nodes_in_group("survivor_pickups").size()
    ])
    quit(0)

func _fill_budget_stress_scene(main: Node, center: Vector2) -> void:
    var enemy_kinds := ["voidling", "skitter", "spitter", "burrower", "carapace", "void_eye", "rift_crystal"]
    for i in range(128):
        var angle := TAU * float(i) / 128.0
        var ring := 260.0 + float(i % 8) * 42.0
        main._spawn_enemy(center + Vector2(cos(angle), sin(angle)) * ring, str(enemy_kinds[i % enemy_kinds.size()]), i % 13 == 0)

    var projectile_labels := ["fishbones", "senna", "samira", "viktor", "xayah", "teemo", "comet", "A", "V", "X", "B", "C"]
    for i in range(230):
        var angle := TAU * float(i) / 230.0
        var dir := Vector2(cos(angle), sin(angle))
        var from_player := i % 5 != 0
        var label := str(projectile_labels[i % projectile_labels.size()])
        var color := Color(0.92, 0.42, 1.0) if not from_player else Color(0.34, 0.84, 1.0)
        main._spawn_projectile(center + dir * 74.0, dir * (260.0 if from_player else 190.0), 3, 8.0, color, label, 1, 1.4, from_player)

    for i in range(190):
        var angle := TAU * float(i) / 190.0
        var pos := center + Vector2(cos(angle), sin(angle)) * (100.0 + float(i % 9) * 24.0)
        var amount := 2 + i % 10
        var kind := "xp"
        var color: Color = main._xp_color(amount)
        if i % 17 == 0:
            kind = "gold"
            amount = 14
            color = Color(1.0, 0.76, 0.20)
        main._spawn_pickup(pos, kind, amount, color)

    var zone_kinds := ["viktor_gravity", "asol_singularity", "morde_realm", "teemo_mushroom"]
    for i in range(32):
        var angle := TAU * float(i) / 32.0
        var zone_kind := str(zone_kinds[i % zone_kinds.size()])
        var color := Color(0.60, 0.82, 1.0, 0.25)
        var status := "slow"
        if zone_kind == "asol_singularity":
            color = Color(0.64, 0.34, 1.0, 0.25)
        elif zone_kind == "morde_realm":
            color = Color(0.40, 1.0, 0.45, 0.22)
            status = "weaken"
        elif zone_kind == "teemo_mushroom":
            color = Color(0.52, 1.0, 0.22, 0.24)
            status = "poison"
        main._on_player_zone_requested(center + Vector2(cos(angle), sin(angle)) * (160.0 + float(i % 5) * 36.0), zone_kind, 112.0, 4, 8.0, 0.58, color, status, 3)

func _resume_to_active_play(main: Node) -> void:
    var guard := 0
    while str(main.get("game_state")) != "playing" and guard < 12:
        guard += 1
        match str(main.get("game_state")):
            "levelup":
                main._choose_upgrade(0)
            "hextech":
                main._choose_hextech_augment(0)
            "shop":
                main._close_shop("performance profile skips shop.")
            "summary":
                push_error("Runtime mesh profile reached summary early.")
                quit(1)
                return
            _:
                break
        await process_frame

func _count_dictionary_meshes(value) -> int:
    if not (value is Dictionary):
        return 0
    var total := 0
    for key in value.keys():
        total += _count_mesh_instances(value[key])
    return total

func _count_mesh_instances(node) -> int:
    if node == null or not is_instance_valid(node):
        return 0
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count

func _count_nodes(node) -> int:
    if node == null or not is_instance_valid(node):
        return 0
    var count := 1
    for child in node.get_children():
        count += _count_nodes(child)
    return count
