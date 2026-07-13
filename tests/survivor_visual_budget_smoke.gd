extends SceneTree

const MainScene := preload("res://scenes/Main.tscn")
const MAX_MESH_INSTANCES := 5600
const MAX_TOTAL_NODES := 7200
const EXPECTED_MAX_ENEMIES := 60

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
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
        push_error("Visual budget test could not find player.")
        quit(1)
        return
    main.set("spawn_timer", 999.0)
    main.set("elite_timer", 999.0)

    var center: Vector2 = player.global_position
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

    for frame in range(24):
        main._run_survivor_loop(0.05)
        await process_frame

    var visual3d = main.get("visual3d")
    if visual3d == null:
        push_error("Visual budget test expected visual3d.")
        quit(1)
        return

    var mesh_count := _count_mesh_instances(visual3d)
    var node_count := _count_nodes(visual3d)
    var enemy_count := get_nodes_in_group("survivor_enemies").size()
    if visual3d.find_child("LitePickupCore", true, false) == null:
        push_error("Visual budget expected dense XP pickups to use lite pickup LOD.")
        quit(1)
        return
    if visual3d.find_child("PickupCollectibleBackplate", true, false) == null:
        push_error("Visual budget expected pickups to use collectible stratum backplates.")
        quit(1)
        return
    if _has_pickup_enemy_hazard_leak(visual3d):
        push_error("Visual budget expected pickup collectible strata to stay out of enemy hazard channels.")
        quit(1)
        return
    if not _has_lite_zone_model(visual3d):
        push_error("Visual budget expected dense zone fields to use lite zone LOD.")
        quit(1)
        return
    if not _has_dense_elite_lod(visual3d):
        push_error("Visual budget expected dense elite enemies to use lite elite LOD.")
        quit(1)
        return
    if not _has_dense_elite_occlusion_plate(visual3d):
        push_error("Visual budget expected dense lite elites to keep low-glare threat occlusion plates.")
        quit(1)
        return
    if enemy_count > EXPECTED_MAX_ENEMIES:
        push_error("Visual budget expected enemy cap <= %d, got %d." % [EXPECTED_MAX_ENEMIES, enemy_count])
        quit(1)
        return
    if mesh_count > MAX_MESH_INSTANCES:
        push_error("Visual budget exceeded mesh count: %d > %d." % [mesh_count, MAX_MESH_INSTANCES])
        quit(1)
        return
    if node_count > MAX_TOTAL_NODES:
        push_error("Visual budget exceeded node count: %d > %d." % [node_count, MAX_TOTAL_NODES])
        quit(1)
        return

    print("SURVIVOR_VISUAL_BUDGET_OK enemies=%d meshes=%d nodes=%d projectiles=%d pickups=%d zones=%d" % [
        enemy_count,
        mesh_count,
        node_count,
        get_nodes_in_group("survivor_projectiles").size(),
        get_nodes_in_group("survivor_pickups").size(),
        get_nodes_in_group("survivor_zones").size()
    ])
    quit(0)

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

func _has_lite_zone_model(node: Node) -> bool:
    if node == null:
        return false
    if node.has_meta("lite_zone_model") and bool(node.get_meta("lite_zone_model", false)):
        return true
    for child in node.get_children():
        if _has_lite_zone_model(child):
            return true
    return false

func _has_dense_elite_lod(node: Node) -> bool:
    if node == null:
        return false
    if node.has_meta("dense_elite_lod") and bool(node.get_meta("dense_elite_lod", false)):
        return true
    for child in node.get_children():
        if _has_dense_elite_lod(child):
            return true
    return false

func _has_dense_elite_occlusion_plate(node: Node) -> bool:
    if node == null:
        return false
    if str(node.name) == "EnemyThreatOcclusionPlate" and bool(node.get_meta("lite", false)) and str(node.get_meta("material_grade", "")) == "low_glare_enemy_threat_occlusion":
        return true
    for child in node.get_children():
        if _has_dense_elite_occlusion_plate(child):
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
