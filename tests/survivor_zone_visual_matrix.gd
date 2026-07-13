extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const ZoneScript := preload("res://scripts/survivor_zone.gd")

const CASES := [
    {"kind": "viktor_gravity", "color": Color(0.58, 0.82, 1.0, 0.26), "status": "slow", "detail": "ZoneSourceProfileHexcoreField", "champion": "viktor", "resolution_type": "containment_lock", "resolution_detail": "ZoneResolutionHexcoreLock", "min_meshes": 46},
    {"kind": "asol_singularity", "color": Color(0.64, 0.34, 1.0, 0.25), "status": "slow", "detail": "ZoneSourceProfileStarForgeField", "champion": "aurelion_sol", "resolution_type": "gravity_collapse", "resolution_detail": "ZoneResolutionStarCollapse", "min_meshes": 53},
    {"kind": "morde_realm", "color": Color(0.40, 1.0, 0.45, 0.22), "status": "weaken", "detail": "ZoneSourceProfileRealmSeal", "champion": "mordekaiser", "resolution_type": "realm_execution", "resolution_detail": "ZoneResolutionRealmJudgement", "min_meshes": 47},
    {"kind": "teemo_mushroom", "color": Color(0.52, 1.0, 0.22, 0.24), "status": "poison", "detail": "ZoneSourceProfileMushroomTrap", "champion": "teemo", "resolution_type": "poison_bloom", "resolution_detail": "ZoneResolutionPoisonBloom", "min_meshes": 45},
    {"kind": "boss_cho_rupture", "color": Color(0.82, 0.34, 1.0, 0.30), "status": "", "detail": "ZoneSourceProfileBossChoRupture", "champion": "boss_cho", "resolution_type": "rupture_maw", "resolution_detail": "ZoneResolutionBossChoTeeth", "min_meshes": 62, "from_player": false},
    {"kind": "boss_velkoz_focus", "color": Color(1.0, 0.32, 1.0, 0.28), "status": "", "detail": "ZoneSourceProfileBossVelkozFocus", "champion": "boss_velkoz", "resolution_type": "laser_disintegration", "resolution_detail": "ZoneResolutionBossVelkozEye", "min_meshes": 62, "from_player": false},
    {"kind": "boss_reksai_tunnel", "color": Color(1.0, 0.42, 0.18, 0.28), "status": "", "detail": "ZoneSourceProfileBossReksaiTunnel", "champion": "boss_reksai", "resolution_type": "burrow_tremor", "resolution_detail": "ZoneResolutionBossReksaiSpines", "min_meshes": 58, "from_player": false},
    {"kind": "boss_belveth_swarm", "color": Color(0.82, 0.22, 1.0, 0.28), "status": "", "detail": "ZoneSourceProfileBossBelvethSwarm", "champion": "boss_belveth", "resolution_type": "swarm_execution", "resolution_detail": "ZoneResolutionBossBelvethNeedles", "min_meshes": 62, "from_player": false}
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    var total_meshes := 0
    for case in CASES:
        var kind := str(case["kind"])
        var zone = ZoneScript.new()
        var from_player := bool(case.get("from_player", true))
        zone.setup(Vector2.ZERO, kind, 128.0, 4, 8.0, 0.58, case["color"], str(case["status"]), 3, from_player)
        var model: Node3D = view.call("_create_zone_model", zone)
        if model == null:
            push_error("Zone visual matrix could not create model for %s." % kind)
            quit(1)
            return
        model.name = "ZoneMatrix_" + kind
        view.add_child(model)
        await process_frame

        if not _require_node(model, "Disc", kind):
            return
        if not _require_node(model, "Marker", kind):
            return
        if not _require_node(model, "ZoneRunePlate", kind):
            return
        if not _require_node(model, "ZonePulseCore", kind):
            return
        if not _require_node(model, "ZoneProgressSigils", kind):
            return
        if not _require_zone_channel(model, from_player, kind):
            return
        if not _require_source_profile(model, kind, str(case["detail"]), str(case["champion"])):
            return
        if not _require_resolution_profile(model, kind, str(case["resolution_type"]), str(case["resolution_detail"])):
            return
        if kind == "teemo_mushroom":
            if not _require_node(model, "ZoneArmedSigils", kind):
                return
            view.call("_sync_zone_duration_rig", model, kind, false, 0.85, 0.15, 41)
            var profile := model.find_child("ZoneSourceProfile", true, false) as Node3D
            if profile == null or bool(profile.visible):
                push_error("Zone visual matrix expected Teemo source profile hidden before trigger.")
                quit(1)
                return
            var resolution_profile := model.find_child("ZoneResolutionProfile", true, false) as Node3D
            if resolution_profile == null or bool(resolution_profile.visible):
                push_error("Zone visual matrix expected Teemo resolution profile hidden before trigger.")
                quit(1)
                return
            view.call("_sync_zone_duration_rig", model, kind, true, 0.70, 0.30, 41)
            if profile == null or not bool(profile.visible):
                push_error("Zone visual matrix expected Teemo source profile visible after trigger.")
                quit(1)
                return
            if resolution_profile == null or not bool(resolution_profile.visible):
                push_error("Zone visual matrix expected Teemo resolution profile visible after trigger.")
                quit(1)
                return
        elif not from_player:
            if not _require_boss_hazard_frame(model, kind):
                return

        var mesh_count := _count_mesh_instances(model)
        if mesh_count < int(case["min_meshes"]):
            push_error("Zone %s looks underbuilt: %d meshes." % [kind, mesh_count])
            quit(1)
            return
        total_meshes += mesh_count
        model.queue_free()
        await process_frame

    print("SURVIVOR_ZONE_VISUAL_MATRIX_OK zones=%d meshes=%d" % [CASES.size(), total_meshes])
    quit(0)

func _require_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) == null:
        push_error("Zone visual matrix: %s missing %s." % [label, node_name])
        quit(1)
        return false
    return true

func _require_zone_channel(model: Node3D, from_player: bool, kind: String) -> bool:
    var expected_channel := "player_zone" if from_player else "boss_hazard_zone"
    if str(model.get_meta("zone_threat_channel", "")) != expected_channel:
        push_error("Zone visual matrix: %s expected channel %s, got %s." % [kind, expected_channel, str(model.get_meta("zone_threat_channel", ""))])
        quit(1)
        return false
    if bool(model.get_meta("from_player", not from_player)) != from_player:
        push_error("Zone visual matrix: %s from_player metadata mismatch." % kind)
        quit(1)
        return false
    return true

func _require_boss_hazard_frame(model: Node3D, kind: String) -> bool:
    var frame := model.find_child("BossHazardZoneFrame", true, false) as Node3D
    if frame == null:
        push_error("Zone visual matrix: %s missing BossHazardZoneFrame." % kind)
        quit(1)
        return false
    if str(frame.get_meta("zone_threat_channel", "")) != "boss_hazard_zone":
        push_error("Zone visual matrix: %s boss hazard frame channel mismatch." % kind)
        quit(1)
        return false
    if _count_mesh_instances(frame) < 10:
        push_error("Zone visual matrix: %s boss hazard frame looks underbuilt." % kind)
        quit(1)
        return false
    return true

func _require_source_profile(model: Node3D, kind: String, expected_detail: String, expected_champion: String) -> bool:
    var root := model.find_child("ZoneSourceProfile", true, false) as Node3D
    if root == null:
        push_error("Zone visual matrix: %s missing ZoneSourceProfile." % kind)
        quit(1)
        return false
    if str(root.get_meta("source_champion", "")) != expected_champion:
        push_error("Zone visual matrix: %s source champion metadata mismatch." % kind)
        quit(1)
        return false
    if str(root.get_meta("profile_family", "")) == "":
        push_error("Zone visual matrix: %s missing profile family metadata." % kind)
        quit(1)
        return false
    if str(root.get_meta("profile_role", "")) == "":
        push_error("Zone visual matrix: %s missing profile role metadata." % kind)
        quit(1)
        return false
    var required_children := [
        "ZoneSourceProfileRing",
        "ZoneSourceClassBadge",
        expected_detail
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Zone visual matrix: %s source profile missing %s." % [kind, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Zone visual matrix: %s source profile child %s has no mesh content." % [kind, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 4:
        push_error("Zone visual matrix: %s source profile looks underbuilt." % kind)
        quit(1)
        return false
    return true

func _require_resolution_profile(model: Node3D, kind: String, expected_type: String, expected_detail: String) -> bool:
    var root := model.find_child("ZoneResolutionProfile", true, false) as Node3D
    if root == null:
        push_error("Zone visual matrix: %s missing ZoneResolutionProfile." % kind)
        quit(1)
        return false
    if str(root.get_meta("resolution_type", "")) != expected_type:
        push_error("Zone visual matrix: %s resolution type metadata mismatch." % kind)
        quit(1)
        return false
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Zone visual matrix: %s resolution detail metadata mismatch." % kind)
        quit(1)
        return false
    var required_children := [
        "ZoneResolutionFrame",
        "ZoneResolutionEdge",
        "ZoneResolutionTimerNeedle",
        expected_detail
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Zone visual matrix: %s resolution profile missing %s." % [kind, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Zone visual matrix: %s resolution child %s has no mesh content." % [kind, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 4:
        push_error("Zone visual matrix: %s resolution profile looks underbuilt." % kind)
        quit(1)
        return false
    return true

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count
