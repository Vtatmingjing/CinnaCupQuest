extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const EnemyScript := preload("res://scripts/survivor_enemy.gd")

const CASES := [
    {"kind": "boss_cho", "pattern": "BossCastPatternCho", "signature": "BossCastChoRuptureRing", "detail": "BossCastChoImpactTeeth", "intent": "devour_rupture", "intent_detail": "BossCastIntentChoDevour", "safety_type": "ring_gap", "safety_detail": "BossCastSafetyChoBiteGaps", "safe_pockets": 5, "domain": "BossDomainChoRupture", "domain_type": "rupture_devour", "domain_detail": "BossDomainChoRuptureMaw", "lockdown": "BossArenaLockdownChoMaw"},
    {"kind": "boss_velkoz", "pattern": "BossCastPatternVelkoz", "signature": "BossCastVelkozLaserFan", "detail": "BossCastVelkozEyeCore", "intent": "laser_fan", "intent_detail": "BossCastIntentVelkozLaser", "safety_type": "laser_between_lanes", "safety_detail": "BossCastSafetyVelkozLaserGaps", "safe_pockets": 4, "domain": "BossDomainVelkozFocus", "domain_type": "focus_laser", "domain_detail": "BossDomainVelkozFocusFan", "lockdown": "BossArenaLockdownVelkozEye"},
    {"kind": "boss_reksai", "pattern": "BossCastPatternReksai", "signature": "BossCastReksaiBurrowLane", "detail": "BossCastReksaiTremorWake", "intent": "burrow_charge", "intent_detail": "BossCastIntentReksaiBurrow", "safety_type": "side_dodge_pocket", "safety_detail": "BossCastSafetyReksaiSidePockets", "safe_pockets": 4, "domain": "BossDomainReksaiBurrow", "domain_type": "burrow_tunnel", "domain_detail": "BossDomainReksaiTunnelLane", "lockdown": "BossArenaLockdownReksaiTunnel"},
    {"kind": "boss_belveth", "pattern": "BossCastPatternBelveth", "signature": "BossCastBelvethWingSweep", "detail": "BossCastBelvethRoyalNeedles", "intent": "royal_sweep", "intent_detail": "BossCastIntentBelvethSweep", "safety_type": "sweep_center_seam", "safety_detail": "BossCastSafetyBelvethSweepSeam", "safe_pockets": 3, "domain": "BossDomainBelvethSwarm", "domain_type": "royal_swarm", "domain_detail": "BossDomainBelvethWingCrown", "lockdown": "BossArenaLockdownBelvethCrown"}
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    if view.find_child("BossPressureRig", true, false) != null:
        push_error("Boss cast pattern matrix expected BossPressureRig to be lazy before a boss exists.")
        quit(1)
        return

    var total_meshes := 0
    for case in CASES:
        _clear_bosses()
        var kind := str(case["kind"])
        var enemy = EnemyScript.new()
        enemy.setup(kind, 12, true)
        enemy.position = Vector2.ZERO
        root.add_child(enemy)
        await process_frame
        enemy.set("attack_timer", 0.10)
        enemy.set("health", enemy.get("max_health"))

        view.call("_sync_boss_pressure")
        await process_frame
        view.call("_sync_boss_pressure")

        var rig := view.find_child("BossCastPatternRig", true, false) as Node3D
        if rig == null:
            push_error("Boss cast pattern matrix expected BossCastPatternRig after spawning %s." % kind)
            quit(1)
            return
        var warning_frame := view.find_child("BossCastWarningFrame", true, false) as Node3D
        if warning_frame == null or not bool(warning_frame.visible):
            push_error("Boss cast pattern matrix expected visible BossCastWarningFrame for %s." % kind)
            quit(1)
            return
        if warning_frame.find_child("BossCastCountdownPip0", true, false) == null:
            push_error("Boss cast pattern matrix expected countdown pips for %s." % kind)
            quit(1)
            return
        var domain := _require_domain_profile(view, kind, str(case["domain"]), str(case["domain_type"]), str(case["domain_detail"]))
        if domain == null:
            return
        var lockdown := _require_arena_lockdown(view, kind, str(case["lockdown"]))
        if lockdown == null:
            return
        if not bool(rig.visible):
            push_error("Boss cast pattern matrix expected visible rig for %s." % kind)
            quit(1)
            return
        var pattern_name := str(case["pattern"])
        var pattern := rig.get_node_or_null(pattern_name) as Node3D
        if pattern == null or not bool(pattern.visible):
            push_error("Boss cast pattern matrix expected visible %s for %s." % [pattern_name, kind])
            quit(1)
            return
        var signature_name := str(case["signature"])
        if pattern.find_child(signature_name, true, false) == null:
            push_error("Boss cast pattern matrix expected %s inside %s." % [signature_name, pattern_name])
            quit(1)
            return
        var detail_name := str(case["detail"])
        if pattern.find_child(detail_name, true, false) == null:
            push_error("Boss cast pattern matrix expected %s inside %s." % [detail_name, pattern_name])
            quit(1)
            return
        if not _require_intent_profile(pattern, kind, str(case["intent"]), str(case["intent_detail"])):
            return
        if not _require_safety_profile(pattern, kind, str(case["safety_type"]), str(case["safety_detail"]), int(case["safe_pockets"])):
            return
        for other in CASES:
            var other_pattern_name := str(other["pattern"])
            if other_pattern_name == pattern_name:
                continue
            var other_pattern := rig.get_node_or_null(other_pattern_name) as Node3D
            if other_pattern != null and bool(other_pattern.visible):
                push_error("Boss cast pattern matrix: %s leaked while testing %s." % [other_pattern_name, kind])
                quit(1)
                return
        var mesh_count := _count_mesh_instances(pattern)
        if mesh_count < 10:
            push_error("Boss cast pattern matrix: %s looks underbuilt with %d meshes." % [pattern_name, mesh_count])
            quit(1)
            return
        total_meshes += mesh_count + _count_mesh_instances(domain) + _count_mesh_instances(lockdown)
        enemy.remove_from_group("survivor_enemies")
        enemy.queue_free()
        await process_frame

    print("SURVIVOR_BOSS_CAST_PATTERN_MATRIX_OK bosses=%d meshes=%d" % [CASES.size(), total_meshes])
    quit(0)

func _require_intent_profile(pattern: Node3D, boss_kind: String, expected_intent: String, expected_detail: String) -> bool:
    var profile := pattern.get_node_or_null("BossCastIntentProfile") as Node3D
    if profile == null or not bool(profile.visible):
        push_error("Boss cast pattern matrix expected visible BossCastIntentProfile for %s." % boss_kind)
        quit(1)
        return false
    if str(profile.get_meta("boss_kind", "")) != boss_kind:
        push_error("Boss cast pattern matrix expected intent profile boss metadata for %s." % boss_kind)
        quit(1)
        return false
    if str(profile.get_meta("intent_type", "")) != expected_intent:
        push_error("Boss cast pattern matrix expected intent %s for %s." % [expected_intent, boss_kind])
        quit(1)
        return false
    if str(profile.get_meta("detail_node", "")) != expected_detail:
        push_error("Boss cast pattern matrix expected intent detail metadata %s for %s." % [expected_detail, boss_kind])
        quit(1)
        return false
    for child_name in ["BossCastIntentFrame", "BossCastIntentPip", expected_detail]:
        var child := profile.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Boss cast pattern matrix expected %s for %s." % [child_name, boss_kind])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Boss cast pattern matrix expected mesh content in %s for %s." % [child_name, boss_kind])
            quit(1)
            return false
    if _count_mesh_instances(profile) < 5:
        push_error("Boss cast pattern matrix expected richer intent profile for %s." % boss_kind)
        quit(1)
        return false
    return true

func _require_safety_profile(pattern: Node3D, boss_kind: String, expected_type: String, expected_detail: String, expected_pockets: int) -> bool:
    var profile := pattern.get_node_or_null("BossCastSafetyProfile") as Node3D
    if profile == null or not bool(profile.visible):
        push_error("Boss cast pattern matrix expected visible BossCastSafetyProfile for %s." % boss_kind)
        quit(1)
        return false
    if str(profile.get_meta("boss_kind", "")) != boss_kind:
        push_error("Boss cast pattern matrix expected safety profile boss metadata for %s." % boss_kind)
        quit(1)
        return false
    if str(profile.get_meta("safety_type", "")) != expected_type:
        push_error("Boss cast pattern matrix expected safety type %s for %s." % [expected_type, boss_kind])
        quit(1)
        return false
    if str(profile.get_meta("detail_node", "")) != expected_detail:
        push_error("Boss cast pattern matrix expected safety detail metadata %s for %s." % [expected_detail, boss_kind])
        quit(1)
        return false
    if int(profile.get_meta("safe_pocket_count", 0)) != expected_pockets:
        push_error("Boss cast pattern matrix expected %d safe pockets for %s." % [expected_pockets, boss_kind])
        quit(1)
        return false
    if str(profile.get_meta("combat_visual_channel", "")) != "boss_cast_safety_readability":
        push_error("Boss cast pattern matrix expected safety combat channel for %s." % boss_kind)
        quit(1)
        return false
    if str(profile.get_meta("material_grade", "")) != "low_glare_boss_cast_safety_profile":
        push_error("Boss cast pattern matrix expected low glare safety material grade for %s." % boss_kind)
        quit(1)
        return false
    if not bool(profile.get_meta("boss_cast_safe_gap_layer", false)):
        push_error("Boss cast pattern matrix expected safe gap metadata for %s." % boss_kind)
        quit(1)
        return false

    for child_name in ["BossCastSafetyBase", "BossCastSafePocketRoot", "BossCastHazardMarginRoot", "BossCastSafeExitArrowRoot", expected_detail]:
        var child := profile.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Boss cast pattern matrix expected safety child %s for %s." % [child_name, boss_kind])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Boss cast pattern matrix expected mesh content in safety child %s for %s." % [child_name, boss_kind])
            quit(1)
            return false
    var pockets := profile.get_node_or_null("BossCastSafePocketRoot") as Node3D
    if pockets == null or _count_named_children(pockets, "BossCastSafePocket_") != expected_pockets:
        push_error("Boss cast pattern matrix expected named safe pockets for %s." % boss_kind)
        quit(1)
        return false
    var arrows := profile.get_node_or_null("BossCastSafeExitArrowRoot") as Node3D
    if arrows == null or int(arrows.get_meta("safe_exit_arrow_count", 0)) != expected_pockets:
        push_error("Boss cast pattern matrix expected safe exit arrow metadata for %s." % boss_kind)
        quit(1)
        return false
    if int(arrows.get_meta("safe_exit_anchor_count", 0)) != expected_pockets:
        push_error("Boss cast pattern matrix expected safe exit anchor metadata for %s." % boss_kind)
        quit(1)
        return false
    if not bool(arrows.get_meta("safe_exit_layer", false)) or not bool(arrows.get_meta("pickup_confusion_guard", false)):
        push_error("Boss cast pattern matrix expected safe exit layer confusion guard for %s." % boss_kind)
        quit(1)
        return false
    if str(arrows.get_meta("material_grade", "")) != "low_glare_boss_cast_safe_exit_arrows":
        push_error("Boss cast pattern matrix expected low glare safe exit arrow grade for %s." % boss_kind)
        quit(1)
        return false
    if _count_named_children(arrows, "BossCastSafeExitArrow_") != expected_pockets:
        push_error("Boss cast pattern matrix expected named safe exit arrows for %s." % boss_kind)
        quit(1)
        return false
    for i in range(expected_pockets):
        var arrow := arrows.get_node_or_null("BossCastSafeExitArrow_%d" % i) as Node3D
        if arrow == null or not bool(arrow.get_meta("safe_exit_arrow", false)):
            push_error("Boss cast pattern matrix expected safe exit arrow %d for %s." % [i, boss_kind])
            quit(1)
            return false
        if int(arrow.get_meta("safe_exit_anchor_count", 0)) < 3 or not bool(arrow.get_meta("pickup_confusion_guard", false)):
            push_error("Boss cast pattern matrix expected safe exit anchor guard %d for %s." % [i, boss_kind])
            quit(1)
            return false
        for anchor_name in ["BossCastSafeExitAnchorMatte", "BossCastSafeExitEntranceBar", "BossCastSafeExitContrastNotch"]:
            var anchor := arrow.get_node_or_null(anchor_name) as Node3D
            if anchor == null or not bool(anchor.get_meta("safe_exit_anchor", false)):
                push_error("Boss cast pattern matrix expected safe exit anchor %s for %s." % [anchor_name, boss_kind])
                quit(1)
                return false
            if str(anchor.get_meta("combat_visual_channel", "")) != "boss_cast_safety_readability":
                push_error("Boss cast pattern matrix expected safe exit anchor channel %s for %s." % [anchor_name, boss_kind])
                quit(1)
                return false
            if str(anchor.get_meta("material_grade", "")) != "low_glare_boss_cast_safe_exit_anchor":
                push_error("Boss cast pattern matrix expected safe exit anchor low glare grade %s for %s." % [anchor_name, boss_kind])
                quit(1)
                return false
        if _count_mesh_instances(arrow) < 6:
            push_error("Boss cast pattern matrix expected readable safe exit arrow %d for %s." % [i, boss_kind])
            quit(1)
            return false
    if not _require_low_glare_materials(profile, 0.08, 0.30):
        push_error("Boss cast pattern matrix expected low glare materials in safety profile for %s." % boss_kind)
        quit(1)
        return false
    if _count_mesh_instances(profile) < expected_pockets + 4:
        push_error("Boss cast pattern matrix expected richer safety profile for %s." % boss_kind)
        quit(1)
        return false
    return true

func _require_domain_profile(view: Node, boss_kind: String, expected_domain: String, expected_type: String, expected_detail: String) -> Node3D:
    var rig := view.find_child("BossDomainProfileRig", true, false) as Node3D
    if rig == null or not bool(rig.visible):
        push_error("Boss cast pattern matrix expected visible BossDomainProfileRig for %s." % boss_kind)
        quit(1)
        return null
    var domain := rig.get_node_or_null(expected_domain) as Node3D
    if domain == null or not bool(domain.visible):
        push_error("Boss cast pattern matrix expected visible %s for %s." % [expected_domain, boss_kind])
        quit(1)
        return null
    if str(domain.get_meta("boss_kind", "")) != boss_kind:
        push_error("Boss cast pattern matrix expected domain boss metadata for %s." % boss_kind)
        quit(1)
        return null
    if str(domain.get_meta("domain_type", "")) != expected_type:
        push_error("Boss cast pattern matrix expected domain type %s for %s." % [expected_type, boss_kind])
        quit(1)
        return null
    if str(domain.get_meta("detail_node", "")) != expected_detail:
        push_error("Boss cast pattern matrix expected domain detail metadata %s for %s." % [expected_detail, boss_kind])
        quit(1)
        return null
    for child_name in ["BossDomainFrame", "BossDomainPressureCore", "BossDomainThreatMeter", expected_detail]:
        var child := domain.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Boss cast pattern matrix expected %s in domain for %s." % [child_name, boss_kind])
            quit(1)
            return null
        if _count_mesh_instances(child) <= 0:
            push_error("Boss cast pattern matrix expected mesh content in %s for %s." % [child_name, boss_kind])
            quit(1)
            return null
    if _count_mesh_instances(domain) < 9:
        push_error("Boss cast pattern matrix expected richer domain profile for %s." % boss_kind)
        quit(1)
        return null
    for other in CASES:
        var other_domain_name := str(other["domain"])
        if other_domain_name == expected_domain:
            continue
        var other_domain := rig.get_node_or_null(other_domain_name) as Node3D
        if other_domain != null and bool(other_domain.visible):
            push_error("Boss cast pattern matrix: %s domain leaked while testing %s." % [other_domain_name, boss_kind])
            quit(1)
            return null
    return domain

func _require_arena_lockdown(view: Node, boss_kind: String, expected_detail: String) -> Node3D:
    var rig := view.find_child("BossArenaLockdownRig", true, false) as Node3D
    if rig == null or not bool(rig.visible):
        push_error("Boss cast pattern matrix expected visible BossArenaLockdownRig for %s." % boss_kind)
        quit(1)
        return null
    if str(rig.get_meta("combat_visual_channel", "")) != "boss_arena_lockdown":
        push_error("Boss cast pattern matrix expected lockdown combat channel for %s." % boss_kind)
        quit(1)
        return null
    if str(rig.get_meta("material_grade", "")) != "low_glare_boss_arena_lockdown":
        push_error("Boss cast pattern matrix expected low glare lockdown material grade for %s." % boss_kind)
        quit(1)
        return null
    if not bool(rig.get_meta("boss_lockdown_layer", false)):
        push_error("Boss cast pattern matrix expected lockdown metadata for %s." % boss_kind)
        quit(1)
        return null
    if str(rig.get_meta("boss_kind", "")) != boss_kind:
        push_error("Boss cast pattern matrix expected lockdown boss metadata for %s." % boss_kind)
        quit(1)
        return null
    if int(rig.get_meta("anchor_count", 0)) != 4 or int(rig.get_meta("chain_count", 0)) != 4:
        push_error("Boss cast pattern matrix expected four anchors and four chains for %s." % boss_kind)
        quit(1)
        return null
    if float(rig.get_meta("lockdown_pressure", -1.0)) < 0.0:
        push_error("Boss cast pattern matrix expected lockdown pressure metadata for %s." % boss_kind)
        quit(1)
        return null

    var anchors := rig.get_node_or_null("BossArenaLockdownAnchors") as Node3D
    if anchors == null or _count_named_children(anchors, "BossArenaLockdownAnchor_") != 4:
        push_error("Boss cast pattern matrix expected four lockdown anchors for %s." % boss_kind)
        quit(1)
        return null
    var chains := rig.get_node_or_null("BossArenaLockdownChains") as Node3D
    if chains == null or _count_named_children(chains, "BossArenaLockdownChain_") != 4:
        push_error("Boss cast pattern matrix expected four lockdown chains for %s." % boss_kind)
        quit(1)
        return null
    var center := rig.get_node_or_null("BossArenaLockdownCenterSeal") as Node3D
    if center == null or _count_mesh_instances(center) <= 0:
        push_error("Boss cast pattern matrix expected lockdown center seal for %s." % boss_kind)
        quit(1)
        return null
    var signatures := rig.get_node_or_null("BossArenaLockdownBossSignatures") as Node3D
    if signatures == null:
        push_error("Boss cast pattern matrix expected lockdown boss signature root for %s." % boss_kind)
        quit(1)
        return null
    var detail := signatures.get_node_or_null(expected_detail) as Node3D
    if detail == null or not bool(detail.visible):
        push_error("Boss cast pattern matrix expected visible lockdown detail %s for %s." % [expected_detail, boss_kind])
        quit(1)
        return null
    if str(detail.get_meta("boss_kind", "")) != boss_kind:
        push_error("Boss cast pattern matrix expected lockdown detail boss metadata for %s." % boss_kind)
        quit(1)
        return null
    if _count_mesh_instances(detail) < 5:
        push_error("Boss cast pattern matrix expected richer lockdown detail for %s." % boss_kind)
        quit(1)
        return null
    for other in CASES:
        var other_detail_name := str(other["lockdown"])
        if other_detail_name == expected_detail:
            continue
        var other_detail := signatures.get_node_or_null(other_detail_name) as Node3D
        if other_detail != null and bool(other_detail.visible):
            push_error("Boss cast pattern matrix: %s lockdown leaked while testing %s." % [other_detail_name, boss_kind])
            quit(1)
            return null
    if not _require_low_glare_materials(rig, 0.18, 0.32):
        push_error("Boss cast pattern matrix expected low glare materials in lockdown rig for %s." % boss_kind)
        quit(1)
        return null
    if _count_mesh_instances(rig) < 28:
        push_error("Boss cast pattern matrix expected substantial arena lockdown mesh content for %s." % boss_kind)
        quit(1)
        return null
    return rig

func _clear_bosses() -> void:
    for enemy in get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        enemy.remove_from_group("survivor_enemies")
        enemy.queue_free()

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count

func _count_named_children(node: Node, prefix: String) -> int:
    var count := 0
    for child in node.get_children():
        if str(child.name).begins_with(prefix):
            count += 1
    return count

func _require_low_glare_materials(node: Node, max_emission: float, max_alpha: float) -> bool:
    if node is MeshInstance3D:
        var mesh := node as MeshInstance3D
        var mat := mesh.material_override as StandardMaterial3D
        if mat != null:
            if bool(mat.emission_enabled) and mat.emission_energy_multiplier > max_emission:
                return false
            if mat.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and mat.albedo_color.a > max_alpha:
                return false
    for child in node.get_children():
        if not _require_low_glare_materials(child, max_emission, max_alpha):
            return false
    return true
