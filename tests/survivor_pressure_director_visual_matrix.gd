extends SceneTree

const MainScene := preload("res://scenes/Main.tscn")
const EXPECTED_PRESSURE_MESHES := 18
const MAX_PRESSURE_NODES := 22

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

    var visual = main.get("visual3d")
    if visual == null:
        return _fail(main, "missing visual3d.")

    var rig := visual.find_child("SurvivalDirectorPressureRig", true, false) as Node3D
    if rig == null:
        return _fail(main, "missing SurvivalDirectorPressureRig.")
    if rig.visible:
        return _fail(main, "director pressure rig should start hidden.")
    if str(rig.get_meta("combat_visual_channel", "")) != "survival_pressure_warning":
        return _fail(main, "director pressure rig channel mismatch.")
    if str(rig.get_meta("material_grade", "")) != "low_glare_survival_director":
        return _fail(main, "director pressure rig material grade mismatch.")
    if not bool(rig.get_meta("elite_squad_warning", false)):
        return _fail(main, "director pressure rig missing elite warning metadata.")
    if not bool(rig.get_meta("escort_lane_warning", false)):
        return _fail(main, "director pressure rig missing escort lane metadata.")
    if not bool(rig.get_meta("composition_readout", false)):
        return _fail(main, "director pressure rig missing composition metadata.")

    main.set("game_state", "paused")
    main.set("elapsed", 112.0)
    main.set("pressure_surge_timer", 6.0)
    main.set("boss_alive", false)
    visual.call("_sync_survival_director_pressure")
    if not rig.visible:
        return _fail(main, "director pressure rig did not become visible near surge.")
    var readiness := float(rig.get_meta("surge_readiness", -1.0))
    if readiness < 0.35 or readiness > 0.45:
        return _fail(main, "director pressure readiness mismatch: %.3f." % readiness)
    for node_name in [
        "PressureSurgeArenaMatte",
        "PressureSurgeWarningRing",
        "PressureSurgeCountdownNeedle",
        "PressureSurgeEliteMarkerLeft",
        "PressureSurgeEliteMarkerRight",
        "PressureSurgeBossEscalationBar"
    ]:
        var child := rig.get_node_or_null(node_name) as Node3D
        if child == null:
            return _fail(main, "director pressure missing %s." % node_name)
        if _count_mesh_instances(child) <= 0:
            return _fail(main, "director pressure %s has no mesh." % node_name)
        if str(child.get_meta("combat_visual_channel", "")) != "survival_pressure_warning":
            return _fail(main, "director pressure %s channel mismatch." % node_name)

    if not _require_composition_routes(main, rig, false):
        return

    if _count_mesh_instances(rig) != EXPECTED_PRESSURE_MESHES:
        return _fail(main, "director pressure mesh budget changed: %d." % _count_mesh_instances(rig))
    if _count_nodes(rig) > MAX_PRESSURE_NODES:
        return _fail(main, "director pressure node budget changed: %d." % _count_nodes(rig))
    if not _require_material_budget(rig, 0.02, 0.30):
        return _fail(main, "director pressure material budget failed.")

    main.set("pressure_surge_timer", 12.0)
    main.set("boss_alive", true)
    visual.call("_sync_survival_director_pressure")
    var boss_marker := rig.get_node_or_null("PressureSurgeBossEscalationBar") as Node3D
    if boss_marker == null or not boss_marker.visible:
        return _fail(main, "director pressure boss escalation marker did not show while boss is alive.")
    if not _require_composition_routes(main, rig, true):
        return

    var node_count := _count_nodes(rig)
    main.queue_free()
    await process_frame
    print("SURVIVOR_PRESSURE_DIRECTOR_VISUAL_MATRIX_OK meshes=%d nodes=%d readiness=%.3f routes=composition_lanes" % [EXPECTED_PRESSURE_MESHES, node_count, readiness])
    quit(0)

func _require_composition_routes(main, rig: Node3D, boss_active: bool) -> bool:
    var routes := rig.get_node_or_null("PressureSurgeCompositionRoutes") as Node3D
    if routes == null:
        _fail(main, "director pressure missing composition routes.")
        return false
    if not routes.visible:
        _fail(main, "director pressure composition routes should be visible.")
        return false
    if str(routes.get_meta("combat_visual_channel", "")) != "survival_pressure_warning":
        _fail(main, "director pressure composition route channel mismatch.")
        return false
    if str(routes.get_meta("material_grade", "")) != "low_glare_survival_director":
        _fail(main, "director pressure composition route material grade mismatch.")
        return false
    if int(routes.get_meta("route_lane_count", 0)) != 4:
        _fail(main, "director pressure route lane metadata mismatch.")
        return false
    if int(routes.get_meta("threat_pip_count", 0)) != 6:
        _fail(main, "director pressure threat pip metadata mismatch.")
        return false

    for lane_name in [
        "PressureSurgeEscortLaneLeft",
        "PressureSurgeEscortLaneRight",
        "PressureSurgeMeleeLaneFront",
        "PressureSurgeRangedLaneBack"
    ]:
        var lane := routes.get_node_or_null(lane_name) as Node3D
        if lane == null:
            _fail(main, "director pressure missing route lane %s." % lane_name)
            return false
        if not lane.visible and not boss_active:
            _fail(main, "director pressure route lane %s should be visible." % lane_name)
            return false
        if _count_mesh_instances(lane) <= 0:
            _fail(main, "director pressure route lane %s has no mesh." % lane_name)
            return false
        if str(lane.get_meta("combat_visual_channel", "")) != "survival_pressure_warning":
            _fail(main, "director pressure route lane %s channel mismatch." % lane_name)
            return false

    var visible_pips := 0
    for child in routes.get_children():
        var marker := child as Node3D
        if marker == null:
            continue
        var marker_name := str(marker.name)
        if marker_name.begins_with("PressureSurgeMeleeThreatPip") or marker_name.begins_with("PressureSurgeRangedThreatPip"):
            if _count_mesh_instances(marker) <= 0:
                _fail(main, "director pressure threat pip %s has no mesh." % marker_name)
                return false
            if marker.visible:
                visible_pips += 1
    if visible_pips < 6 and not boss_active:
        _fail(main, "director pressure expected all six threat pips near surge, got %d." % visible_pips)
        return false

    var boss_bridge := routes.get_node_or_null("PressureSurgeBossEscortBridge") as Node3D
    if boss_bridge == null:
        _fail(main, "director pressure missing boss escort bridge.")
        return false
    if boss_bridge.visible != boss_active:
        _fail(main, "director pressure boss bridge visibility mismatch.")
        return false

    var reward_badge := routes.get_node_or_null("PressureSurgeRiskRewardBadge") as Node3D
    if reward_badge == null:
        _fail(main, "director pressure missing risk reward badge.")
        return false
    if _count_mesh_instances(reward_badge) <= 0:
        _fail(main, "director pressure risk reward badge has no mesh.")
        return false
    return true

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

func _require_material_budget(node: Node, max_emission: float, max_alpha: float) -> bool:
    if node is MeshInstance3D:
        var mesh := node as MeshInstance3D
        var mat := mesh.material_override as StandardMaterial3D
        if mat != null:
            if mat.emission_enabled and mat.emission_energy_multiplier > max_emission:
                return false
            if mat.albedo_color.a < 0.99 and mat.albedo_color.a > max_alpha:
                return false
    for child in node.get_children():
        if not _require_material_budget(child, max_emission, max_alpha):
            return false
    return true

func _fail(main, message: String) -> void:
    push_error("Pressure director visual matrix: " + message)
    if main != null and is_instance_valid(main):
        main.queue_free()
    quit(1)
