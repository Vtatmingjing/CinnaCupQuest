extends SceneTree

const MainScene := preload("res://scenes/Main.tscn")

const SIM_SECONDS := 120.0
const STEP := 0.10
const MAX_ENEMIES := 60
const MAX_PROJECTILES := 84
const MAX_PICKUPS := 60
const MAX_ZONES := 10
const MAX_MESH_INSTANCES := 5600
const MAX_TOTAL_NODES := 7200
const MAX_AVG_STEP_MS := 45.0
const MAX_WORST_STEP_MS := 850.0
const TEST_ARENA := Rect2(-1520, -900, 3040, 1800)

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    seed(20260705)
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
        push_error("Long-run performance guard could not find player.")
        quit(1)
        return
    player.set("max_health", 999)
    player.set("health", 999)
    player.set("shield", 999)
    player.set("invincible_timer", SIM_SECONDS + 10.0)
    main.set("boss_spawned", true)
    main.set("boss_alive", false)

    var center: Vector2 = player.global_position
    var elapsed_sim := 0.0
    var steps := 0
    var total_step_ms := 0.0
    var worst_step_ms := 0.0
    var sample_timer := 0.0
    var max_enemy_count := 0
    var max_projectile_count := 0
    var max_pickup_count := 0
    var max_zone_count := 0
    var max_mesh_count := 0
    var max_node_count := 0
    while elapsed_sim < SIM_SECONDS:
        var t := elapsed_sim * 0.72
        player.global_position = _clamp_to_arena(center + Vector2(cos(t) * 360.0, sin(t * 0.63) * 260.0))
        var before_us := Time.get_ticks_usec()
        main._run_survivor_loop(STEP)
        main.call("_update_camera", STEP)
        main.call("_update_camera_shake", STEP)
        await process_frame
        await _resume_to_active_play(main)
        var step_ms := float(Time.get_ticks_usec() - before_us) / 1000.0
        total_step_ms += step_ms
        worst_step_ms = maxf(worst_step_ms, step_ms)
        steps += 1
        elapsed_sim += STEP
        sample_timer -= STEP
        if sample_timer <= 0.0:
            sample_timer = 3.0
            var visual_sample = main.get("visual3d")
            if visual_sample != null:
                max_enemy_count = maxi(max_enemy_count, get_nodes_in_group("survivor_enemies").size())
                max_projectile_count = maxi(max_projectile_count, get_nodes_in_group("survivor_projectiles").size())
                max_pickup_count = maxi(max_pickup_count, get_nodes_in_group("survivor_pickups").size())
                max_zone_count = maxi(max_zone_count, get_nodes_in_group("survivor_zones").size())
                max_mesh_count = maxi(max_mesh_count, _count_mesh_instances(visual_sample))
                max_node_count = maxi(max_node_count, _count_nodes(visual_sample))

    await process_frame
    await _resume_to_active_play(main)
    main.call("_enforce_runtime_budget")
    await process_frame

    var enemy_count := get_nodes_in_group("survivor_enemies").size()
    var projectile_count := get_nodes_in_group("survivor_projectiles").size()
    var pickup_count := get_nodes_in_group("survivor_pickups").size()
    var zone_count := get_nodes_in_group("survivor_zones").size()
    var visual3d = main.get("visual3d")
    if visual3d == null:
        push_error("Long-run performance guard expected visual3d.")
        quit(1)
        return
    var mesh_count := _count_mesh_instances(visual3d)
    var node_count := _count_nodes(visual3d)
    max_enemy_count = maxi(max_enemy_count, enemy_count)
    max_projectile_count = maxi(max_projectile_count, projectile_count)
    max_pickup_count = maxi(max_pickup_count, pickup_count)
    max_zone_count = maxi(max_zone_count, zone_count)
    max_mesh_count = maxi(max_mesh_count, mesh_count)
    max_node_count = maxi(max_node_count, node_count)
    var avg_step_ms := total_step_ms / maxf(1.0, float(steps))

    if max_enemy_count > MAX_ENEMIES:
        push_error("Long-run enemy cap failed: %d > %d." % [max_enemy_count, MAX_ENEMIES])
        quit(1)
        return
    if max_projectile_count > MAX_PROJECTILES:
        push_error("Long-run projectile cap failed: %d > %d." % [max_projectile_count, MAX_PROJECTILES])
        quit(1)
        return
    if max_pickup_count > MAX_PICKUPS:
        push_error("Long-run pickup cap failed: %d > %d." % [max_pickup_count, MAX_PICKUPS])
        quit(1)
        return
    if max_zone_count > MAX_ZONES:
        push_error("Long-run zone cap failed: %d > %d." % [max_zone_count, MAX_ZONES])
        quit(1)
        return
    if max_mesh_count > MAX_MESH_INSTANCES:
        push_error("Long-run mesh budget failed: %d > %d." % [max_mesh_count, MAX_MESH_INSTANCES])
        quit(1)
        return
    if max_node_count > MAX_TOTAL_NODES:
        push_error("Long-run node budget failed: %d > %d." % [max_node_count, MAX_TOTAL_NODES])
        quit(1)
        return
    if avg_step_ms > MAX_AVG_STEP_MS:
        push_error("Long-run average step too slow: %.2f ms > %.2f ms." % [avg_step_ms, MAX_AVG_STEP_MS])
        quit(1)
        return
    if worst_step_ms > MAX_WORST_STEP_MS:
        push_error("Long-run worst step spike too slow: %.2f ms > %.2f ms." % [worst_step_ms, MAX_WORST_STEP_MS])
        quit(1)
        return

    print("SURVIVOR_LONG_RUN_PERFORMANCE_OK seconds=%.0f avg_ms=%.2f worst_ms=%.2f enemies=%d/%d projectiles=%d/%d pickups=%d/%d zones=%d/%d meshes=%d/%d nodes=%d/%d" % [
        SIM_SECONDS,
        avg_step_ms,
        worst_step_ms,
        enemy_count,
        max_enemy_count,
        projectile_count,
        max_projectile_count,
        pickup_count,
        max_pickup_count,
        zone_count,
        max_zone_count,
        mesh_count,
        max_mesh_count,
        node_count,
        max_node_count
    ])
    quit(0)

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
                main._close_shop("performance test skips shop.")
            "summary":
                push_error("Long-run performance guard reached summary early.")
                quit(1)
                return
            _:
                break
        await process_frame

func _clamp_to_arena(pos: Vector2) -> Vector2:
    pos.x = clampf(pos.x, TEST_ARENA.position.x + 96.0, TEST_ARENA.end.x - 96.0)
    pos.y = clampf(pos.y, TEST_ARENA.position.y + 96.0, TEST_ARENA.end.y - 96.0)
    return pos

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count

func _count_nodes(node: Node) -> int:
    var count := 1
    for child in node.get_children():
        count += _count_nodes(child)
    return count
