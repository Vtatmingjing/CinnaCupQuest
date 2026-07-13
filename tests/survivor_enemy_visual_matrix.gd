extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const EnemyScript := preload("res://scripts/survivor_enemy.gd")

const ENEMY_KINDS := [
    "voidling",
    "skitter",
    "spitter",
    "burrower",
    "carapace",
    "void_eye",
    "rift_crystal"
]

const BOSS_KINDS := [
    "boss_cho",
    "boss_velkoz",
    "boss_reksai",
    "boss_belveth"
]

const BOSS_EMBLEM_ATLAS := "res://art/textures/void_boss_emblem_atlas_v1.png"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame
    if not _require_texture(BOSS_EMBLEM_ATLAS, 1024, 1024):
        return

    var total_meshes := 0
    for kind in ENEMY_KINDS:
        var model: Node3D = view.call("_create_enemy_model", kind, false, false, _enemy_color(kind), 18.0, false, "")
        view.add_child(model)
        await process_frame
        if not _require_grounding(model, kind):
            return
        if not _require_node(model, "EnemySpeciesRoleBanner", kind):
            return
        if not _require_node(model, "EnemySpeciesDecal", kind):
            return
        if not _require_enemy_tactical_readability_plaque(model, kind, kind, false, false):
            return
        if not _require_node(model, "EnemyReadabilityPlate", kind):
            return
        if not _require_enemy_readability_plate(model, kind, kind, false):
            return
        if not _require_enemy_combat_intent_profile(model, kind, kind):
            return
        if not _require_enemy_damage_state_rig(view, model, kind, kind, false, false):
            return
        if not _require_enemy_ground_silhouette_plate(model, kind, kind, false, false):
            return
        if not _require_no_enemy_footprint_scale_rig(model, kind, kind):
            return
        if model.find_child("EnemyThreatOcclusionPlate", true, false) != null:
            push_error("Normal enemy %s should reserve EnemyThreatOcclusionPlate for elite/boss threats." % kind)
            quit(1)
            return
        if not _require_enemy_threat_rank_silhouette(model, kind, kind, false, false, ""):
            return
        if not _require_enemy_threat_tier_marker(view, model, kind, kind, false, false, ""):
            return
        if not _require_void_creature_premium_body_rig(model, kind, kind, false, false):
            return
        if not _require_void_creature_painterly_depth_rig(model, kind, kind, false, false):
            return
        if model.find_child("PriorityCombatBackplateRig", true, false) != null:
            push_error("Normal enemy %s should not carry PriorityCombatBackplateRig." % kind)
            quit(1)
            return
        if _expects_weakpoint_core(kind):
            if not _require_node(model, "EnemyWeakpointCore", kind):
                return
            if not _require_node(model, "EnemyWeakpointLens", kind):
                return
            if not _require_node(model, "EnemyWeakpointMark", kind):
                return
        if kind == "skitter" or kind == "burrower":
            if not _require_node(model, "ChargeLane", kind):
                return
        if kind == "spitter" or kind == "void_eye" or kind == "rift_crystal" or kind == "burrower":
            if not _require_node(model, "WindupAura", kind):
                return
        if kind == "rift_crystal":
            if not _require_node(model, "SummonAura", kind):
                return
        total_meshes += _count_mesh_instances(model)
        model.queue_free()
        await process_frame

    var traits := ["frenzy", "bulwark", "splitter", "treasure"]
    for i in range(traits.size()):
        var elite_kind := str(ENEMY_KINDS[(i + 1) % ENEMY_KINDS.size()])
        var elite_model: Node3D = view.call("_create_enemy_model", elite_kind, false, true, _enemy_color(elite_kind), 22.0, false, traits[i])
        view.add_child(elite_model)
        await process_frame
        if not _require_grounding(elite_model, elite_kind + "_elite"):
            return
        if not _require_node(elite_model, "EnemySpeciesRoleBanner", elite_kind + "_elite"):
            return
        if not _require_node(elite_model, "EnemySpeciesDecal", elite_kind + "_elite"):
            return
        if not _require_enemy_tactical_readability_plaque(elite_model, elite_kind, elite_kind + "_elite", false, true):
            return
        if not _require_enemy_readability_plate(elite_model, elite_kind, elite_kind + "_elite", true):
            return
        if not _require_enemy_combat_intent_profile(elite_model, elite_kind, elite_kind + "_elite"):
            return
        if not _require_enemy_damage_state_rig(view, elite_model, elite_kind, elite_kind + "_elite", false, true):
            return
        if not _require_enemy_ground_silhouette_plate(elite_model, elite_kind, elite_kind + "_elite", false, true):
            return
        if not _require_enemy_footprint_scale_rig(elite_model, elite_kind, elite_kind + "_elite", false, true):
            return
        if not _require_enemy_threat_occlusion_plate(elite_model, elite_kind, elite_kind + "_elite", false, true, traits[i], false):
            return
        if not _require_enemy_threat_rank_silhouette(elite_model, elite_kind, elite_kind + "_elite", false, true, traits[i]):
            return
        if not _require_enemy_threat_tier_marker(view, elite_model, elite_kind, elite_kind + "_elite", false, true, traits[i]):
            return
        if not _require_void_creature_premium_body_rig(elite_model, elite_kind, elite_kind + "_elite", false, true):
            return
        if not _require_void_creature_painterly_depth_rig(elite_model, elite_kind, elite_kind + "_elite", false, true):
            return
        if not _require_node(elite_model, "EliteTraitMarker", elite_kind + "_elite"):
            return
        if not _require_elite_trait_telegraph(elite_model, elite_kind + "_elite", traits[i]):
            return
        if not _require_node(elite_model, "EliteBossCrest", elite_kind + "_elite"):
            return
        if not _require_node(elite_model, "VoidPriorityEmblem", elite_kind + "_elite"):
            return
        if not _require_node(elite_model, "ElitePriorityIcon", elite_kind + "_elite"):
            return
        if not _require_node(elite_model, "ThreatHalo", elite_kind + "_elite"):
            return
        if not _require_node(elite_model, "HealthBar", elite_kind + "_elite"):
            return
        if not _require_node(elite_model, "EnemyWeakpointCore", elite_kind + "_elite"):
            return
        if not _require_node(elite_model, "EnemyWeakpointMark", elite_kind + "_elite"):
            return
        if not _require_void_threat_silhouette(elite_model, elite_kind + "_elite", false):
            return
        if not _require_priority_backplate(elite_model, elite_kind + "_elite", false, traits[i]):
            return
        total_meshes += _count_mesh_instances(elite_model)
        elite_model.queue_free()
        await process_frame

    for boss_kind in BOSS_KINDS:
        var boss_model: Node3D = view.call("_create_enemy_model", boss_kind, true, true, _enemy_color(boss_kind), 42.0, false, "")
        view.add_child(boss_model)
        await process_frame
        if not _require_grounding(boss_model, boss_kind):
            return
        if not _require_node(boss_model, "EnemySpeciesRoleBanner", boss_kind):
            return
        if not _require_node(boss_model, "EnemySpeciesDecal", boss_kind):
            return
        if not _require_enemy_tactical_readability_plaque(boss_model, boss_kind, boss_kind, true, true):
            return
        if not _require_enemy_combat_intent_profile(boss_model, boss_kind, boss_kind):
            return
        if not _require_enemy_damage_state_rig(view, boss_model, boss_kind, boss_kind, true, true):
            return
        if not _require_enemy_ground_silhouette_plate(boss_model, boss_kind, boss_kind, true, true):
            return
        if not _require_enemy_footprint_scale_rig(boss_model, boss_kind, boss_kind, true, true):
            return
        if not _require_enemy_threat_occlusion_plate(boss_model, boss_kind, boss_kind, true, true, "", false):
            return
        if not _require_enemy_threat_rank_silhouette(boss_model, boss_kind, boss_kind, true, true, ""):
            return
        if not _require_enemy_threat_tier_marker(view, boss_model, boss_kind, boss_kind, true, true, ""):
            return
        if not _require_void_creature_premium_body_rig(boss_model, boss_kind, boss_kind, true, true):
            return
        if not _require_void_creature_painterly_depth_rig(boss_model, boss_kind, boss_kind, true, true):
            return
        if not _require_node(boss_model, "EliteBossCrest", boss_kind):
            return
        if not _require_node(boss_model, "VoidPriorityEmblem", boss_kind):
            return
        if not _require_node(boss_model, "BossIdentityIconTexture", boss_kind):
            return
        if not _require_node(boss_model, "ThreatHalo", boss_kind):
            return
        if not _require_node(boss_model, "HealthBar", boss_kind):
            return
        if not _require_node(boss_model, "EnemyWeakpointCore", boss_kind):
            return
        if not _require_node(boss_model, "EnemyWeakpointLens", boss_kind):
            return
        if not _require_node(boss_model, "EnemyWeakpointMark", boss_kind):
            return
        if not _require_node(boss_model, "EnrageAura", boss_kind):
            return
        if not _require_boss_phase_state_rig(boss_model, boss_kind):
            return
        if not _require_node(boss_model, "WindupAura", boss_kind):
            return
        if boss_kind == "boss_reksai":
            if not _require_node(boss_model, "ChargeLane", boss_kind):
                return
        if boss_kind == "boss_cho" or boss_kind == "boss_belveth":
            if not _require_node(boss_model, "SummonAura", boss_kind):
                return
        if not _require_void_threat_silhouette(boss_model, boss_kind, true):
            return
        if not _require_priority_backplate(boss_model, boss_kind, true, ""):
            return
        total_meshes += _count_mesh_instances(boss_model)
        boss_model.queue_free()
        await process_frame

    var boss_variant_kind := "skitter"
    var boss_variant_model: Node3D = view.call("_create_enemy_model", boss_variant_kind, true, false, _enemy_color(boss_variant_kind), 28.0, false, "")
    view.add_child(boss_variant_model)
    await process_frame
    if not _require_void_creature_premium_body_rig(boss_variant_model, boss_variant_kind, boss_variant_kind + "_boss_variant", true, false):
        return
    if not _require_void_creature_painterly_depth_rig(boss_variant_model, boss_variant_kind, boss_variant_kind + "_boss_variant", true, false):
        return
    if not _require_enemy_damage_state_rig(view, boss_variant_model, boss_variant_kind, boss_variant_kind + "_boss_variant", true, false):
        return
    if not _require_enemy_ground_silhouette_plate(boss_variant_model, boss_variant_kind, boss_variant_kind + "_boss_variant", true, false):
        return
    if not _require_enemy_footprint_scale_rig(boss_variant_model, boss_variant_kind, boss_variant_kind + "_boss_variant", true, false):
        return
    if not _require_enemy_threat_occlusion_plate(boss_variant_model, boss_variant_kind, boss_variant_kind + "_boss_variant", true, false, "", false):
        return
    if not _require_enemy_threat_rank_silhouette(boss_variant_model, boss_variant_kind, boss_variant_kind + "_boss_variant", true, false, ""):
        return
    if not _require_enemy_threat_tier_marker(view, boss_variant_model, boss_variant_kind, boss_variant_kind + "_boss_variant", true, false, ""):
        return
    if not _require_enemy_tactical_readability_plaque(boss_variant_model, boss_variant_kind, boss_variant_kind + "_boss_variant", true, false):
        return
    total_meshes += _count_mesh_instances(boss_variant_model)
    boss_variant_model.queue_free()
    await process_frame

    for kind in ENEMY_KINDS:
        var lite_model: Node3D = view.call("_create_enemy_model", kind, false, false, _enemy_color(kind), 18.0, true, "")
        view.add_child(lite_model)
        await process_frame
        if not _require_grounding(lite_model, kind + "_lite"):
            return
        if lite_model.find_child("EnemySpeciesRoleBanner", true, false) != null:
            push_error("Lite enemy %s should not carry EnemySpeciesRoleBanner." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemySpeciesDecal", true, false) != null:
            push_error("Lite enemy %s should not carry EnemySpeciesDecal." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemyReadabilityPlate", true, false) != null:
            push_error("Lite enemy %s should not carry EnemyReadabilityPlate." % kind)
            quit(1)
            return
        if lite_model.find_child("VoidPriorityEmblem", true, false) != null:
            push_error("Lite enemy %s should not carry VoidPriorityEmblem." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemyWeakpointCore", true, false) != null:
            push_error("Lite enemy %s should not carry EnemyWeakpointCore." % kind)
            quit(1)
            return
        if lite_model.find_child("VoidThreatSilhouetteRig", true, false) != null:
            push_error("Lite enemy %s should not carry VoidThreatSilhouetteRig." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemyCombatIntentProfile", true, false) != null:
            push_error("Lite enemy %s should not carry EnemyCombatIntentProfile." % kind)
            quit(1)
            return
        if lite_model.find_child("VoidCreaturePremiumBodyRig", true, false) != null:
            push_error("Lite enemy %s should not carry VoidCreaturePremiumBodyRig." % kind)
            quit(1)
            return
        if lite_model.find_child("VoidCreaturePainterlyDepthRig", true, false) != null:
            push_error("Lite enemy %s should not carry VoidCreaturePainterlyDepthRig." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemyDamageStateRig", true, false) != null:
            push_error("Lite enemy %s should not carry EnemyDamageStateRig." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemyGroundSilhouettePlate", true, false) != null:
            push_error("Lite enemy %s should not carry EnemyGroundSilhouettePlate." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemyFootprintScaleRig", true, false) != null:
            push_error("Lite enemy %s should not carry EnemyFootprintScaleRig." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemyThreatRankSilhouetteRig", true, false) != null:
            push_error("Lite enemy %s should not carry EnemyThreatRankSilhouetteRig." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemyThreatTierMarker", true, false) != null:
            push_error("Lite enemy %s should not carry EnemyThreatTierMarker." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemyTacticalReadabilityPlaque", true, false) != null:
            push_error("Lite enemy %s should not carry EnemyTacticalReadabilityPlaque." % kind)
            quit(1)
            return
        if lite_model.find_child("EnemyThreatOcclusionPlate", true, false) != null:
            push_error("Lite enemy %s should not carry EnemyThreatOcclusionPlate unless it is elite." % kind)
            quit(1)
            return
        if lite_model.find_child("EliteTraitTelegraphRig", true, false) != null:
            push_error("Lite enemy %s should not carry EliteTraitTelegraphRig." % kind)
            quit(1)
            return
        if lite_model.find_child("PriorityCombatBackplateRig", true, false) != null:
            push_error("Lite enemy %s should not carry PriorityCombatBackplateRig." % kind)
            quit(1)
            return
        if kind == "burrower":
            if not _require_node(lite_model, "ChargeLane", kind + "_lite"):
                return
        if kind == "rift_crystal":
            if not _require_node(lite_model, "SummonAura", kind + "_lite"):
                return
        total_meshes += _count_mesh_instances(lite_model)
        lite_model.queue_free()
        await process_frame

    print("SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=%d bosses=%d boss_emblems=%d meshes=%d" % [ENEMY_KINDS.size(), BOSS_KINDS.size(), BOSS_KINDS.size(), total_meshes])
    quit(0)

func _require_texture(texture_path: String, min_width: int, min_height: int) -> bool:
    if not FileAccess.file_exists(texture_path):
        push_error("Enemy visual matrix: missing texture %s." % texture_path)
        quit(1)
        return false
    var image := Image.new()
    var err := image.load(texture_path)
    if err != OK:
        push_error("Enemy visual matrix: could not load texture %s." % texture_path)
        quit(1)
        return false
    if image.get_width() < min_width or image.get_height() < min_height:
        push_error("Enemy visual matrix: texture %s too small: %dx%d." % [texture_path, image.get_width(), image.get_height()])
        quit(1)
        return false
    return true

func _require_grounding(model: Node3D, label: String) -> bool:
    var shadow := model.find_child("GroundedContactShadow", true, false) as MeshInstance3D
    var core := model.find_child("GroundedContactCore", true, false) as MeshInstance3D
    if label.ends_with("_lite") and (shadow == null or core == null):
        var lite_plate := model.find_child("LiteEnemyReadabilityPlate", true, false) as MeshInstance3D
        if lite_plate == null:
            push_error("Enemy visual matrix: %s missing lite readability grounding plate." % label)
            quit(1)
            return false
        if str(lite_plate.get_meta("combat_visual_channel", "")) != "enemy_lite_readability":
            push_error("Enemy visual matrix: %s lite grounding metadata mismatch." % label)
            quit(1)
            return false
        if not bool(lite_plate.get_meta("lite_enemy_grounding", false)):
            push_error("Enemy visual matrix: %s lite grounding flag missing." % label)
            quit(1)
            return false
        if not bool(lite_plate.get_meta("pickup_confusion_guard", false)) or not bool(lite_plate.get_meta("collision_radius_readability", false)):
            push_error("Enemy visual matrix: %s lite grounding missing pickup/collision readability metadata." % label)
            quit(1)
            return false
        if lite_plate.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
            push_error("Enemy visual matrix: %s lite grounding plate should not cast extra realtime shadows." % label)
            quit(1)
            return false
        var pickup_gap := model.find_child("EnemyGroundSilhouettePickupGap", true, false) as Node3D
        if pickup_gap == null or not bool(pickup_gap.get_meta("pickup_confusion_guard", false)) or not bool(pickup_gap.get_meta("collision_radius_marker", false)):
            push_error("Enemy visual matrix: %s lite grounding pickup gap missing guard metadata." % label)
            quit(1)
            return false
        if model.find_child("EnemyGroundSilhouetteFacingNotch", true, false) == null:
            push_error("Enemy visual matrix: %s lite grounding missing facing notch." % label)
            quit(1)
            return false
        return true
    if shadow == null or core == null:
        push_error("Enemy visual matrix: %s missing grounded contact shadow/core." % label)
        quit(1)
        return false
    if str(shadow.get_meta("combat_visual_channel", "")) != "grounding_shadow" or str(core.get_meta("combat_visual_channel", "")) != "grounding_shadow":
        push_error("Enemy visual matrix: %s grounding metadata mismatch." % label)
        quit(1)
        return false
    if shadow.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF or core.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
        push_error("Enemy visual matrix: %s contact shadows should not cast extra realtime shadows." % label)
        quit(1)
        return false
    return true

func _require_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) == null:
        push_error("Enemy visual matrix: %s missing %s." % [label, node_name])
        quit(1)
        return false
    return true

func _require_priority_backplate(model: Node3D, label: String, boss: bool, elite_trait: String) -> bool:
    var rig := model.find_child("PriorityCombatBackplateRig", true, false) as Node3D
    if rig == null:
        push_error("Enemy visual matrix: %s missing PriorityCombatBackplateRig." % label)
        quit(1)
        return false
    if str(rig.get_meta("combat_visual_channel", "")) != "priority_readability":
        push_error("Enemy visual matrix: %s priority backplate channel mismatch." % label)
        quit(1)
        return false
    var expected_class := "boss" if boss else "elite"
    if str(rig.get_meta("priority_class", "")) != expected_class:
        push_error("Enemy visual matrix: %s priority class mismatch." % label)
        quit(1)
        return false
    if not boss and str(rig.get_meta("elite_trait", "")) != elite_trait:
        push_error("Enemy visual matrix: %s elite trait metadata mismatch." % label)
        quit(1)
        return false
    for node_name in ["PriorityCombatMatteBackplate", "PriorityCombatBodySilhouetteBacker", "PriorityCombatFocusBracket0", "PriorityThreatStateStrip"]:
        var child := rig.get_node_or_null(node_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s priority backplate missing %s." % [label, node_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s priority backplate child %s has no mesh content." % [label, node_name])
            quit(1)
            return false
    if boss:
        if rig.get_node_or_null("BossPriorityThreatBacker") == null or rig.get_node_or_null("BossPriorityPhaseTrim") == null:
            push_error("Enemy visual matrix: %s missing boss priority detail." % label)
            quit(1)
            return false
    else:
        var reward := rig.get_node_or_null("EliteRewardReadabilityPip") as Node3D
        if reward == null or str(reward.get_meta("elite_trait", "")) != elite_trait:
            push_error("Enemy visual matrix: %s missing elite reward readability pip." % label)
            quit(1)
            return false
    var strip := rig.get_node_or_null("PriorityThreatStateStrip") as Node3D
    if strip == null:
        push_error("Enemy visual matrix: %s missing PriorityThreatStateStrip." % label)
        quit(1)
        return false
    if str(strip.get_meta("combat_visual_channel", "")) != "priority_readability":
        push_error("Enemy visual matrix: %s priority state strip channel mismatch." % label)
        quit(1)
        return false
    if strip.get_node_or_null("PriorityThreatStateMeter") == null or strip.get_node_or_null("PriorityThreatStagePips") == null:
        push_error("Enemy visual matrix: %s priority state strip missing meter/pips." % label)
        quit(1)
        return false
    var pips := strip.get_node_or_null("PriorityThreatStagePips") as Node3D
    if pips == null or int(pips.get_meta("pip_count", 0)) < (4 if boss else 3):
        push_error("Enemy visual matrix: %s priority stage pip count too low." % label)
        quit(1)
        return false
    if not _require_low_glare_priority_material(rig, label):
        return false
    return true

func _require_low_glare_priority_material(node: Node, label: String) -> bool:
    if node is MeshInstance3D:
        var mesh := node as MeshInstance3D
        var mat := mesh.material_override as StandardMaterial3D
        if mat != null:
            if mat.emission_enabled:
                push_error("Enemy visual matrix: %s priority backplate should not use emissive material on %s." % [label, node.name])
                quit(1)
                return false
            if mat.albedo_color.a > 0.36:
                push_error("Enemy visual matrix: %s priority backplate alpha too high on %s: %.2f." % [label, node.name, mat.albedo_color.a])
                quit(1)
                return false
    for child in node.get_children():
        if not _require_low_glare_priority_material(child, label):
            return false
    return true

func _require_void_threat_silhouette(model: Node3D, label: String, boss: bool) -> bool:
    var rig := model.find_child("VoidThreatSilhouetteRig", true, false) as Node3D
    if rig == null:
        push_error("Enemy visual matrix: %s missing VoidThreatSilhouetteRig." % label)
        quit(1)
        return false
    if bool(rig.get_meta("boss", false)) != boss:
        push_error("Enemy visual matrix: %s threat silhouette boss metadata mismatch." % label)
        quit(1)
        return false
    if str(rig.get_meta("threat_signature", "")) == "":
        push_error("Enemy visual matrix: %s threat silhouette missing signature metadata." % label)
        quit(1)
        return false
    for child_name in ["VoidThreatGroundSigil", "VoidThreatBackSpines", "VoidThreatAttackTell"]:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s threat silhouette missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s threat silhouette child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if boss:
        var expected := ""
        match label:
            "boss_cho":
                expected = "VoidThreatBossChoMaw"
            "boss_velkoz":
                expected = "VoidThreatBossVelkozFan"
            "boss_reksai":
                expected = "VoidThreatBossReksaiLane"
            "boss_belveth":
                expected = "VoidThreatBossBelvethWings"
        if expected != "" and rig.find_child(expected, true, false) == null:
            push_error("Enemy visual matrix: %s threat silhouette missing %s." % [label, expected])
            quit(1)
            return false
    elif rig.find_child("VoidThreatEliteTraitMotif", true, false) == null:
        push_error("Enemy visual matrix: %s threat silhouette missing elite trait motif." % label)
        quit(1)
        return false
    if _count_mesh_instances(rig) < (9 if boss else 7):
        push_error("Enemy visual matrix: %s threat silhouette looks underbuilt." % label)
        quit(1)
        return false
    return true

func _require_enemy_ground_silhouette_plate(model: Node3D, enemy_kind: String, label: String, boss: bool, elite: bool) -> bool:
    var plate := model.find_child("EnemyGroundSilhouettePlate", true, false) as Node3D
    if plate == null:
        push_error("Enemy visual matrix: %s missing EnemyGroundSilhouettePlate." % label)
        quit(1)
        return false
    if str(plate.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s ground silhouette kind metadata mismatch." % label)
        quit(1)
        return false
    if bool(plate.get_meta("boss", false)) != boss:
        push_error("Enemy visual matrix: %s ground silhouette boss metadata mismatch." % label)
        quit(1)
        return false
    if bool(plate.get_meta("elite", false)) != elite:
        push_error("Enemy visual matrix: %s ground silhouette elite metadata mismatch." % label)
        quit(1)
        return false
    if str(plate.get_meta("combat_visual_channel", "")) != "enemy_readability":
        push_error("Enemy visual matrix: %s ground silhouette channel mismatch." % label)
        quit(1)
        return false
    if str(plate.get_meta("material_grade", "")) != "low_glare_ground_silhouette":
        push_error("Enemy visual matrix: %s ground silhouette material grade mismatch." % label)
        quit(1)
        return false
    if str(plate.get_meta("visual_stratum", "")) != "enemy_floor_readability":
        push_error("Enemy visual matrix: %s ground silhouette stratum mismatch." % label)
        quit(1)
        return false
    if not bool(plate.get_meta("pickup_confusion_guard", false)) or not bool(plate.get_meta("collision_radius_readability", false)):
        push_error("Enemy visual matrix: %s ground silhouette missing pickup/collision readability metadata." % label)
        quit(1)
        return false
    var expected_family := _expected_ground_silhouette_family(enemy_kind)
    var expected_detail := _expected_ground_silhouette_detail(enemy_kind)
    if str(plate.get_meta("silhouette_family", "")) != expected_family:
        push_error("Enemy visual matrix: %s ground silhouette expected family %s." % [label, expected_family])
        quit(1)
        return false
    if str(plate.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s ground silhouette expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    for child_name in ["EnemyGroundSilhouetteBaseMatte", "EnemyGroundSilhouetteEdgeMatte", "EnemyGroundSilhouetteBodyMass", "EnemyGroundSilhouettePickupGap", "EnemyGroundSilhouetteFacingNotch", expected_detail]:
        var child := plate.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s ground silhouette missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s ground silhouette child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    var pickup_gap := plate.get_node_or_null("EnemyGroundSilhouettePickupGap") as Node3D
    if pickup_gap == null or not bool(pickup_gap.get_meta("pickup_confusion_guard", false)) or not bool(pickup_gap.get_meta("collision_radius_marker", false)):
        push_error("Enemy visual matrix: %s ground silhouette pickup gap missing guard metadata." % label)
        quit(1)
        return false
    if _count_mesh_instances(plate) < (8 if boss else 7):
        push_error("Enemy visual matrix: %s ground silhouette looks underbuilt." % label)
        quit(1)
        return false
    if not _require_material_budget(plate, "Enemy visual matrix: %s ground silhouette" % label, 0.04, 0.36):
        return false
    return true

func _require_enemy_threat_rank_silhouette(model: Node3D, enemy_kind: String, label: String, boss: bool, elite: bool, elite_trait: String) -> bool:
    var rig := model.find_child("EnemyThreatRankSilhouetteRig", true, false) as Node3D
    if rig == null:
        push_error("Enemy visual matrix: %s missing EnemyThreatRankSilhouetteRig." % label)
        quit(1)
        return false
    if str(rig.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s threat rank kind metadata mismatch." % label)
        quit(1)
        return false
    if bool(rig.get_meta("boss", false)) != boss:
        push_error("Enemy visual matrix: %s threat rank boss metadata mismatch." % label)
        quit(1)
        return false
    if bool(rig.get_meta("elite", false)) != elite:
        push_error("Enemy visual matrix: %s threat rank elite metadata mismatch." % label)
        quit(1)
        return false
    var expected_rank := _expected_threat_rank(boss, elite)
    var expected_detail := _expected_threat_rank_detail(boss, elite)
    if str(rig.get_meta("rank", "")) != expected_rank:
        push_error("Enemy visual matrix: %s threat rank expected %s." % [label, expected_rank])
        quit(1)
        return false
    if str(rig.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s threat rank expected detail %s." % [label, expected_detail])
        quit(1)
        return false
    if str(rig.get_meta("combat_visual_channel", "")) != "enemy_rank_readability":
        push_error("Enemy visual matrix: %s threat rank channel mismatch." % label)
        quit(1)
        return false
    if str(rig.get_meta("material_grade", "")) != "low_glare_enemy_rank_silhouette":
        push_error("Enemy visual matrix: %s threat rank material grade mismatch." % label)
        quit(1)
        return false
    if not bool(rig.get_meta("pickup_confusion_guard", false)):
        push_error("Enemy visual matrix: %s threat rank missing pickup confusion guard." % label)
        quit(1)
        return false
    if elite and not boss and str(rig.get_meta("elite_trait", "")) != elite_trait:
        push_error("Enemy visual matrix: %s threat rank elite trait metadata mismatch." % label)
        quit(1)
        return false
    for child_name in ["EnemyThreatRankBaseMatte", "EnemyThreatRankOuterFrame", "EnemyThreatRankFacingNeedle", expected_detail]:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s threat rank missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s threat rank child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if boss:
        if rig.find_child("EnemyThreatRankBossDangerBar", true, false) == null:
            push_error("Enemy visual matrix: %s threat rank missing boss danger bar." % label)
            quit(1)
            return false
    elif elite:
        var reward := rig.find_child("EnemyThreatRankEliteRewardPip", true, false) as Node3D
        if reward == null or str(reward.get_meta("elite_trait", "")) != elite_trait:
            push_error("Enemy visual matrix: %s threat rank missing elite reward pip." % label)
            quit(1)
            return false
    else:
        if rig.find_child("EnemyThreatRankNormalChevron", true, false) == null:
            push_error("Enemy visual matrix: %s threat rank missing normal chevron." % label)
            quit(1)
            return false
    if _count_mesh_instances(rig) < (10 if boss else 8 if elite else 7):
        push_error("Enemy visual matrix: %s threat rank rig looks underbuilt." % label)
        quit(1)
        return false
    if not _require_material_budget(rig, "Enemy visual matrix: %s threat rank" % label, 0.02, 0.36):
        return false
    return true

func _expected_threat_tier_detail(boss: bool, elite: bool) -> String:
    match _expected_threat_rank(boss, elite):
        "boss":
            return "EnemyThreatTierBossBanner"
        "elite":
            return "EnemyThreatTierEliteChevron"
        _:
            return "EnemyThreatTierNormalTicks"

func _require_enemy_threat_tier_marker(view, model: Node3D, enemy_kind: String, label: String, boss: bool, elite: bool, elite_trait: String) -> bool:
    var marker := model.find_child("EnemyThreatTierMarker", true, false) as Node3D
    if marker == null:
        push_error("Enemy visual matrix: %s missing EnemyThreatTierMarker." % label)
        quit(1)
        return false
    if str(marker.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s threat tier kind metadata mismatch." % label)
        quit(1)
        return false
    if bool(marker.get_meta("boss", false)) != boss:
        push_error("Enemy visual matrix: %s threat tier boss metadata mismatch." % label)
        quit(1)
        return false
    if bool(marker.get_meta("elite", false)) != elite:
        push_error("Enemy visual matrix: %s threat tier elite metadata mismatch." % label)
        quit(1)
        return false
    var expected_tier := _expected_threat_rank(boss, elite)
    var expected_detail := _expected_threat_tier_detail(boss, elite)
    if str(marker.get_meta("threat_tier", "")) != expected_tier:
        push_error("Enemy visual matrix: %s threat tier expected %s." % [label, expected_tier])
        quit(1)
        return false
    if str(marker.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s threat tier expected detail %s." % [label, expected_detail])
        quit(1)
        return false
    if str(marker.get_meta("combat_visual_channel", "")) != "enemy_tier_readability":
        push_error("Enemy visual matrix: %s threat tier channel mismatch." % label)
        quit(1)
        return false
    if str(marker.get_meta("material_grade", "")) != "low_glare_enemy_tier_marker":
        push_error("Enemy visual matrix: %s threat tier material grade mismatch." % label)
        quit(1)
        return false
    if not bool(marker.get_meta("pickup_confusion_guard", false)) or not bool(marker.get_meta("collision_radius_readability", false)):
        push_error("Enemy visual matrix: %s threat tier missing readability guards." % label)
        quit(1)
        return false
    if elite and not boss and str(marker.get_meta("elite_trait", "")) != elite_trait:
        push_error("Enemy visual matrix: %s threat tier elite trait metadata mismatch." % label)
        quit(1)
        return false
    for child_name in [
        "EnemyThreatTierMatteBase",
        "EnemyThreatTierOuterFrame",
        "EnemyThreatTierFacingTab",
        "EnemyThreatTierRewardPips",
        expected_detail
    ]:
        var child := marker.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s threat tier missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s threat tier child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    var rewards := marker.get_node_or_null("EnemyThreatTierRewardPips") as Node3D
    if rewards == null or int(rewards.get_meta("pip_count", 0)) < (4 if boss else 3 if elite else 2):
        push_error("Enemy visual matrix: %s threat tier reward pip count too low." % label)
        quit(1)
        return false
    if boss and marker.find_child("EnemyThreatTierBossBannerBar", true, false) == null:
        push_error("Enemy visual matrix: %s threat tier missing boss banner bar." % label)
        quit(1)
        return false
    if elite and not boss:
        var trait_gem := marker.find_child("EnemyThreatTierEliteTraitGem", true, false) as Node3D
        if trait_gem == null or str(trait_gem.get_meta("elite_trait", "")) != elite_trait:
            push_error("Enemy visual matrix: %s threat tier missing elite trait gem." % label)
            quit(1)
            return false
    if not boss and not elite and marker.find_child("EnemyThreatTierNormalBaseline", true, false) == null:
        push_error("Enemy visual matrix: %s threat tier missing normal baseline." % label)
        quit(1)
        return false
    var mesh_count := _count_mesh_instances(marker)
    if mesh_count < (12 if boss else 9 if elite else 8):
        push_error("Enemy visual matrix: %s threat tier marker looks underbuilt: %d." % [label, mesh_count])
        quit(1)
        return false
    if not _require_material_budget(marker, "Enemy visual matrix: %s threat tier" % label, 0.02, 0.36):
        return false

    var enemy = EnemyScript.new()
    enemy.setup(enemy_kind, 7, boss)
    enemy.elite = elite
    enemy.set("max_health", 100)
    enemy.set("health", 1)
    enemy.set("attack_timer", 0.0)
    view.call("_sync_enemy_threat_tier_marker", model, enemy, boss, elite, 91, float(model.get_meta("visual_radius", 0.6)))
    if not bool(marker.visible):
        push_error("Enemy visual matrix: %s threat tier marker did not stay visible on sync." % label)
        quit(1)
        return false
    if float(marker.get_meta("health_ratio", 1.0)) > 0.02:
        push_error("Enemy visual matrix: %s threat tier did not record low health ratio." % label)
        quit(1)
        return false
    if float(marker.get_meta("attack_readiness", 0.0)) < 0.95:
        push_error("Enemy visual matrix: %s threat tier did not record attack readiness." % label)
        quit(1)
        return false
    if marker.scale.x <= 1.01:
        push_error("Enemy visual matrix: %s threat tier did not expand under pressure." % label)
        quit(1)
        return false
    return true

func _require_enemy_tactical_readability_plaque(model: Node3D, enemy_kind: String, label: String, boss: bool, elite: bool) -> bool:
    var plaque := model.find_child("EnemyTacticalReadabilityPlaque", true, false) as Node3D
    if plaque == null:
        push_error("Enemy visual matrix: %s missing EnemyTacticalReadabilityPlaque." % label)
        quit(1)
        return false
    if str(plaque.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s tactical plaque kind metadata mismatch." % label)
        quit(1)
        return false
    if bool(plaque.get_meta("boss", false)) != boss:
        push_error("Enemy visual matrix: %s tactical plaque boss metadata mismatch." % label)
        quit(1)
        return false
    if bool(plaque.get_meta("elite", false)) != elite:
        push_error("Enemy visual matrix: %s tactical plaque elite metadata mismatch." % label)
        quit(1)
        return false
    var expected_role := _expected_tactical_role(enemy_kind)
    var expected_detail := _expected_tactical_detail(enemy_kind)
    if str(plaque.get_meta("enemy_role", "")) != expected_role:
        push_error("Enemy visual matrix: %s tactical plaque expected role %s." % [label, expected_role])
        quit(1)
        return false
    if str(plaque.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s tactical plaque expected detail %s." % [label, expected_detail])
        quit(1)
        return false
    if str(plaque.get_meta("combat_visual_channel", "")) != "enemy_role_readability":
        push_error("Enemy visual matrix: %s tactical plaque channel mismatch." % label)
        quit(1)
        return false
    if str(plaque.get_meta("material_grade", "")) != "low_glare_enemy_tactical_plaque":
        push_error("Enemy visual matrix: %s tactical plaque material grade mismatch." % label)
        quit(1)
        return false
    if not bool(plaque.get_meta("pickup_confusion_guard", false)):
        push_error("Enemy visual matrix: %s tactical plaque missing pickup confusion guard." % label)
        quit(1)
        return false
    for child_name in ["EnemyTacticalPlaqueBackplate", "EnemyTacticalPlaqueRoleGlyph", "EnemyTacticalPlaqueFacingTick", expected_detail]:
        var child := plaque.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s tactical plaque missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s tactical plaque child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    var mesh_count := _count_mesh_instances(plaque)
    if mesh_count < 6 or mesh_count > 10:
        push_error("Enemy visual matrix: %s tactical plaque mesh budget invalid: %d." % [label, mesh_count])
        quit(1)
        return false
    if not _require_material_budget(plaque, "Enemy visual matrix: %s tactical plaque" % label, 0.01, 0.31):
        return false
    return true

func _expected_tactical_role(kind: String) -> String:
    match kind:
        "skitter", "burrower", "boss_reksai":
            return "diver"
        "spitter", "void_eye", "boss_velkoz":
            return "artillery"
        "carapace", "boss_cho":
            return "tank"
        "rift_crystal", "boss_belveth":
            return "summoner"
        _:
            return "swarm"

func _expected_tactical_detail(kind: String) -> String:
    match _expected_tactical_role(kind):
        "diver":
            return "EnemyTacticalDiverFangs"
        "artillery":
            return "EnemyTacticalArtillerySight"
        "tank":
            return "EnemyTacticalTankBulwark"
        "summoner":
            return "EnemyTacticalSummonerNode"
        _:
            return "EnemyTacticalSwarmClaw"

func _require_enemy_footprint_scale_rig(model: Node3D, enemy_kind: String, label: String, boss: bool, elite: bool) -> bool:
    var rig := model.find_child("EnemyFootprintScaleRig", true, false) as Node3D
    if rig == null:
        push_error("Enemy visual matrix: %s missing EnemyFootprintScaleRig." % label)
        quit(1)
        return false
    if str(rig.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s footprint kind metadata mismatch." % label)
        quit(1)
        return false
    if bool(rig.get_meta("boss", false)) != boss:
        push_error("Enemy visual matrix: %s footprint boss metadata mismatch." % label)
        quit(1)
        return false
    if bool(rig.get_meta("elite", false)) != elite:
        push_error("Enemy visual matrix: %s footprint elite metadata mismatch." % label)
        quit(1)
        return false
    var expected_class := _expected_footprint_class(boss, elite)
    var expected_detail := _expected_footprint_detail(boss, elite)
    if str(rig.get_meta("footprint_class", "")) != expected_class:
        push_error("Enemy visual matrix: %s footprint expected class %s." % [label, expected_class])
        quit(1)
        return false
    if str(rig.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s footprint expected detail %s." % [label, expected_detail])
        quit(1)
        return false
    if str(rig.get_meta("combat_visual_channel", "")) != "enemy_body_readability":
        push_error("Enemy visual matrix: %s footprint channel mismatch." % label)
        quit(1)
        return false
    if str(rig.get_meta("material_grade", "")) != "low_glare_enemy_footprint_scale":
        push_error("Enemy visual matrix: %s footprint material grade mismatch." % label)
        quit(1)
        return false
    if not bool(rig.get_meta("pickup_confusion_guard", false)) or not bool(rig.get_meta("scale_readability", false)):
        push_error("Enemy visual matrix: %s footprint missing readability metadata." % label)
        quit(1)
        return false
    for child_name in ["EnemyFootprintScaleMatte", "EnemyFootprintBodyBounds", "EnemyFootprintPickupClearanceGap", "EnemyFootprintRankBracket", expected_detail]:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s footprint missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s footprint child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    var mesh_count := _count_mesh_instances(rig)
    if mesh_count < (6 if boss else 7 if elite else 7) or mesh_count > (8 if boss else 8 if elite else 8):
        push_error("Enemy visual matrix: %s footprint mesh budget invalid: %d." % [label, mesh_count])
        quit(1)
        return false
    if not _require_material_budget(rig, "Enemy visual matrix: %s footprint" % label, 0.02, 0.36):
        return false
    return true

func _require_enemy_threat_occlusion_plate(model: Node3D, enemy_kind: String, label: String, boss: bool, elite: bool, elite_trait: String, lite: bool) -> bool:
    var plate := model.find_child("EnemyThreatOcclusionPlate", true, false) as Node3D
    if plate == null:
        push_error("Enemy visual matrix: %s missing EnemyThreatOcclusionPlate." % label)
        quit(1)
        return false
    if str(plate.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s threat occlusion kind metadata mismatch." % label)
        quit(1)
        return false
    if bool(plate.get_meta("boss", false)) != boss:
        push_error("Enemy visual matrix: %s threat occlusion boss metadata mismatch." % label)
        quit(1)
        return false
    if bool(plate.get_meta("elite", false)) != elite:
        push_error("Enemy visual matrix: %s threat occlusion elite metadata mismatch." % label)
        quit(1)
        return false
    if bool(plate.get_meta("lite", false)) != lite:
        push_error("Enemy visual matrix: %s threat occlusion lite metadata mismatch." % label)
        quit(1)
        return false
    var expected_class := "boss" if boss else ("lite_elite" if lite else "elite")
    if str(plate.get_meta("threat_class", "")) != expected_class:
        push_error("Enemy visual matrix: %s threat occlusion expected class %s." % [label, expected_class])
        quit(1)
        return false
    if not boss and str(plate.get_meta("elite_trait", "")) != elite_trait:
        push_error("Enemy visual matrix: %s threat occlusion elite trait metadata mismatch." % label)
        quit(1)
        return false
    var expected_detail := _expected_threat_occlusion_detail(enemy_kind, boss, elite_trait)
    if str(plate.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s threat occlusion expected detail %s." % [label, expected_detail])
        quit(1)
        return false
    if str(plate.get_meta("visual_stratum", "")) != "enemy_floor_occlusion":
        push_error("Enemy visual matrix: %s threat occlusion stratum mismatch." % label)
        quit(1)
        return false
    if str(plate.get_meta("combat_visual_channel", "")) != "enemy_occlusion_readability":
        push_error("Enemy visual matrix: %s threat occlusion channel mismatch." % label)
        quit(1)
        return false
    if str(plate.get_meta("material_grade", "")) != "low_glare_enemy_threat_occlusion":
        push_error("Enemy visual matrix: %s threat occlusion material grade mismatch." % label)
        quit(1)
        return false
    if not bool(plate.get_meta("pickup_confusion_guard", false)) or not bool(plate.get_meta("collision_radius_readability", false)):
        push_error("Enemy visual matrix: %s threat occlusion missing readability metadata." % label)
        quit(1)
        return false
    for child_name in ["EnemyThreatOcclusionMatte", "EnemyThreatOcclusionBodyMass", "EnemyThreatOcclusionCollisionRing", "EnemyThreatOcclusionFacingCut", expected_detail]:
        var child := plate.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s threat occlusion missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s threat occlusion child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(plate) < (8 if boss else 6):
        push_error("Enemy visual matrix: %s threat occlusion looks underbuilt." % label)
        quit(1)
        return false
    if not _require_material_budget(plate, "Enemy visual matrix: %s threat occlusion" % label, 0.01, 0.36):
        return false
    return true

func _require_no_enemy_footprint_scale_rig(model: Node3D, _enemy_kind: String, label: String) -> bool:
    if model.find_child("EnemyFootprintScaleRig", true, false) != null:
        push_error("Enemy visual matrix: %s normal enemy should reserve EnemyFootprintScaleRig budget for elite/boss threats." % label)
        quit(1)
        return false
    return true

func _expected_threat_occlusion_detail(kind: String, boss: bool, elite_trait: String) -> String:
    if boss:
        match kind:
            "boss_cho":
                return "EnemyThreatOcclusionBossMaw"
            "boss_velkoz":
                return "EnemyThreatOcclusionBossEyeFan"
            "boss_reksai":
                return "EnemyThreatOcclusionBossTunnel"
            "boss_belveth":
                return "EnemyThreatOcclusionBossWingSweep"
            _:
                return "EnemyThreatOcclusionBossVoid"
    match elite_trait:
        "frenzy":
            return "EnemyThreatOcclusionEliteFrenzy"
        "bulwark":
            return "EnemyThreatOcclusionEliteBulwark"
        "splitter":
            return "EnemyThreatOcclusionEliteSplitter"
        "treasure":
            return "EnemyThreatOcclusionEliteTreasure"
        _:
            return "EnemyThreatOcclusionEliteVoid"

func _expected_footprint_class(boss: bool, elite: bool) -> String:
    if boss:
        return "boss"
    if elite:
        return "elite"
    return "normal"

func _expected_footprint_detail(boss: bool, elite: bool) -> String:
    match _expected_footprint_class(boss, elite):
        "boss":
            return "EnemyFootprintBossMassFrame"
        "elite":
            return "EnemyFootprintEliteMassSpikes"
        _:
            return "EnemyFootprintNormalMassPips"

func _expected_threat_rank(boss: bool, elite: bool) -> String:
    if boss:
        return "boss"
    if elite:
        return "elite"
    return "normal"

func _expected_threat_rank_detail(boss: bool, elite: bool) -> String:
    match _expected_threat_rank(boss, elite):
        "boss":
            return "EnemyThreatRankBossCrown"
        "elite":
            return "EnemyThreatRankEliteSpikes"
        _:
            return "EnemyThreatRankNormalPips"

func _expected_ground_silhouette_family(kind: String) -> String:
    match _expected_combat_family(kind):
        "pounce":
            return "pounce_claw"
        "acid":
            return "acid_sac"
        "burrow":
            return "burrow_lane"
        "armor":
            return "armor_shell"
        "focus":
            return "focus_eye"
        "summon":
            return "summon_crystal"
        "devour":
            return "devour_maw"
        "wing_swarm":
            return "wing_swarm"
        _:
            return "swarm_bite"

func _expected_ground_silhouette_detail(kind: String) -> String:
    match _expected_ground_silhouette_family(kind):
        "pounce_claw":
            return "EnemyGroundSilhouettePounceClaws"
        "acid_sac":
            return "EnemyGroundSilhouetteAcidSac"
        "burrow_lane":
            return "EnemyGroundSilhouetteBurrowWake"
        "armor_shell":
            return "EnemyGroundSilhouetteArmorShell"
        "focus_eye":
            return "EnemyGroundSilhouetteFocusFan"
        "summon_crystal":
            return "EnemyGroundSilhouetteSummonNode"
        "devour_maw":
            return "EnemyGroundSilhouetteDevourMaw"
        "wing_swarm":
            return "EnemyGroundSilhouetteWingSweep"
        _:
            return "EnemyGroundSilhouetteSwarmBite"

func _require_enemy_readability_plate(model: Node3D, enemy_kind: String, label: String, elite: bool) -> bool:
    var plate := model.find_child("EnemyReadabilityPlate", true, false) as Node3D
    if plate == null:
        push_error("Enemy visual matrix: %s missing EnemyReadabilityPlate." % label)
        quit(1)
        return false
    if str(plate.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s readability kind metadata mismatch." % label)
        quit(1)
        return false
    if bool(plate.get_meta("elite", false)) != elite:
        push_error("Enemy visual matrix: %s readability elite metadata mismatch." % label)
        quit(1)
        return false
    var expected_family := _expected_readability_family(enemy_kind)
    var expected_detail := _expected_readability_detail(enemy_kind)
    if str(plate.get_meta("readability_family", "")) != expected_family:
        push_error("Enemy visual matrix: %s readability expected family %s." % [label, expected_family])
        quit(1)
        return false
    if str(plate.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s readability expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    var detail := plate.get_node_or_null(expected_detail) as Node3D
    if detail == null:
        push_error("Enemy visual matrix: %s readability plate missing %s." % [label, expected_detail])
        quit(1)
        return false
    if _count_mesh_instances(detail) <= 0:
        push_error("Enemy visual matrix: %s readability detail %s has no mesh content." % [label, expected_detail])
        quit(1)
        return false
    if _count_mesh_instances(plate) < (4 if elite else 3):
        push_error("Enemy visual matrix: %s readability plate looks underbuilt." % label)
        quit(1)
        return false
    return true

func _expected_readability_family(kind: String) -> String:
    match kind:
        "skitter":
            return "pounce"
        "spitter":
            return "acid"
        "burrower":
            return "burrow"
        "carapace":
            return "armor"
        "void_eye":
            return "focus"
        "rift_crystal":
            return "summon"
        _:
            return "swarm"

func _expected_readability_detail(kind: String) -> String:
    match _expected_readability_family(kind):
        "pounce":
            return "EnemyReadabilityPounceLegs"
        "acid":
            return "EnemyReadabilityAcidSpit"
        "burrow":
            return "EnemyReadabilityBurrowSpine"
        "armor":
            return "EnemyReadabilityArmorPlates"
        "focus":
            return "EnemyReadabilityFocusEye"
        "summon":
            return "EnemyReadabilityRiftCrystal"
        _:
            return "EnemyReadabilitySwarmBite"

func _require_boss_phase_state_rig(model: Node3D, boss_kind: String) -> bool:
    var rig := model.find_child("BossPhaseStateRig", true, false) as Node3D
    if rig == null:
        push_error("Enemy visual matrix: %s missing BossPhaseStateRig." % boss_kind)
        quit(1)
        return false
    if str(rig.get_meta("boss_kind", "")) != boss_kind:
        push_error("Enemy visual matrix: %s boss phase metadata mismatch." % boss_kind)
        quit(1)
        return false
    var expected_detail := ""
    match boss_kind:
        "boss_cho":
            expected_detail = "BossPhaseChoDevourState"
        "boss_velkoz":
            expected_detail = "BossPhaseVelkozFocusState"
        "boss_reksai":
            expected_detail = "BossPhaseReksaiBurrowState"
        "boss_belveth":
            expected_detail = "BossPhaseBelvethSwarmState"
        _:
            expected_detail = "BossPhaseGenericState"
    if str(rig.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s boss phase expected detail metadata %s." % [boss_kind, expected_detail])
        quit(1)
        return false
    for child_name in ["BossPhaseFrame", "BossPhaseMeter", "BossPhaseCastState", "BossPhaseEnrageState", expected_detail]:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s boss phase missing %s." % [boss_kind, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s boss phase child %s has no mesh content." % [boss_kind, child_name])
            quit(1)
            return false
    if _count_mesh_instances(rig) < 8:
        push_error("Enemy visual matrix: %s boss phase state rig looks underbuilt." % boss_kind)
        quit(1)
        return false
    return true

func _require_enemy_combat_intent_profile(model: Node3D, enemy_kind: String, label: String) -> bool:
    var profile := model.find_child("EnemyCombatIntentProfile", true, false) as Node3D
    if profile == null:
        push_error("Enemy visual matrix: %s missing EnemyCombatIntentProfile." % label)
        quit(1)
        return false
    var expected_family := _expected_combat_family(enemy_kind)
    var expected_detail := _expected_combat_detail(enemy_kind)
    if str(profile.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s combat intent kind metadata mismatch." % label)
        quit(1)
        return false
    if str(profile.get_meta("combat_family", "")) != expected_family:
        push_error("Enemy visual matrix: %s combat intent expected family %s." % [label, expected_family])
        quit(1)
        return false
    if str(profile.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s combat intent expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    for child_name in ["EnemyCombatIntentFrame", "EnemyCombatIntentCore", "EnemyCombatIntentMeter", expected_detail]:
        var child := profile.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s combat intent missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s combat intent child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(profile) < 5:
        push_error("Enemy visual matrix: %s combat intent looks underbuilt." % label)
        quit(1)
        return false
    return true

func _require_enemy_damage_state_rig(view, model: Node3D, enemy_kind: String, label: String, boss: bool, elite: bool) -> bool:
    var rig := model.find_child("EnemyDamageStateRig", true, false) as Node3D
    if rig == null:
        push_error("Enemy visual matrix: %s missing EnemyDamageStateRig." % label)
        quit(1)
        return false
    if str(rig.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s damage state kind metadata mismatch." % label)
        quit(1)
        return false
    if bool(rig.get_meta("boss", false)) != boss:
        push_error("Enemy visual matrix: %s damage state boss metadata mismatch." % label)
        quit(1)
        return false
    if bool(rig.get_meta("elite", false)) != elite:
        push_error("Enemy visual matrix: %s damage state elite metadata mismatch." % label)
        quit(1)
        return false
    if str(rig.get_meta("combat_visual_channel", "")) != "enemy_damage_state":
        push_error("Enemy visual matrix: %s damage state channel mismatch." % label)
        quit(1)
        return false
    if str(rig.get_meta("material_grade", "")) != "low_glare_matte_damage":
        push_error("Enemy visual matrix: %s damage state material grade mismatch." % label)
        quit(1)
        return false
    for child_name in ["EnemyDamageCrackBand", "EnemyDamageWoundCore", "EnemyDamageArmorChips", "EnemyDamagePhasePips"]:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s damage state missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s damage state child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(rig) < 8:
        push_error("Enemy visual matrix: %s damage state rig looks underbuilt." % label)
        quit(1)
        return false
    if not _require_material_budget(rig, "Enemy visual matrix: %s damage state" % label, 0.04, 0.36):
        return false

    var enemy = EnemyScript.new()
    enemy.setup(enemy_kind, 7, boss)
    enemy.elite = elite
    enemy.set("max_health", 100)
    enemy.set("health", 100)
    enemy.set("hurt_flash", 0.0)
    view.call("_sync_enemy_damage_state_rig", model, enemy, enemy_kind, boss, elite, 73, float(model.get_meta("visual_radius", 0.6)))
    if bool(rig.get_meta("visible_damage_state", true)):
        push_error("Enemy visual matrix: %s damage state should hide at full health." % label)
        quit(1)
        return false

    enemy.set("health", 38)
    view.call("_sync_enemy_damage_state_rig", model, enemy, enemy_kind, boss, elite, 73, float(model.get_meta("visual_radius", 0.6)))
    if not bool(rig.get_meta("visible_damage_state", false)) or not rig.visible:
        push_error("Enemy visual matrix: %s damage state did not show when damaged." % label)
        quit(1)
        return false
    if float(rig.get_meta("damage_pressure", 0.0)) < 0.45:
        push_error("Enemy visual matrix: %s damage state pressure too low." % label)
        quit(1)
        return false
    var band := rig.get_node_or_null("EnemyDamageCrackBand") as Node3D
    if band == null or not band.visible or band.scale.x < 0.70:
        push_error("Enemy visual matrix: %s damage crack band did not scale with damage." % label)
        quit(1)
        return false
    var pips := rig.get_node_or_null("EnemyDamagePhasePips") as Node3D
    if pips == null or int(pips.get_meta("lit_phase_count", 0)) < 2:
        push_error("Enemy visual matrix: %s damage phase pips did not light up." % label)
        quit(1)
        return false
    return true

func _require_void_creature_premium_body_rig(model: Node3D, enemy_kind: String, label: String, boss: bool, elite: bool) -> bool:
    var rig := model.find_child("VoidCreaturePremiumBodyRig", true, false) as Node3D
    if rig == null:
        push_error("Enemy visual matrix: %s missing VoidCreaturePremiumBodyRig." % label)
        quit(1)
        return false
    if str(rig.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s premium body kind metadata mismatch." % label)
        quit(1)
        return false
    if bool(rig.get_meta("boss", false)) != boss:
        push_error("Enemy visual matrix: %s premium body boss metadata mismatch." % label)
        quit(1)
        return false
    if bool(rig.get_meta("elite", false)) != elite:
        push_error("Enemy visual matrix: %s premium body elite metadata mismatch." % label)
        quit(1)
        return false
    var expected_light_boss_variant := boss and not elite and not enemy_kind.begins_with("boss_")
    if bool(rig.get_meta("light_boss_variant", false)) != expected_light_boss_variant:
        push_error("Enemy visual matrix: %s premium body light boss variant metadata mismatch." % label)
        quit(1)
        return false
    var expected_family := _expected_premium_body_family(enemy_kind)
    var expected_detail := _expected_premium_body_detail(enemy_kind)
    if str(rig.get_meta("body_family", "")) != expected_family:
        push_error("Enemy visual matrix: %s premium body expected family %s." % [label, expected_family])
        quit(1)
        return false
    if str(rig.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s premium body expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    if str(rig.get_meta("material_grade", "")) != "void_premium_carapace":
        push_error("Enemy visual matrix: %s premium body missing material grade metadata." % label)
        quit(1)
        return false
    var required_children := [
        "VoidCreaturePremiumCarapacePlating",
        "VoidCreaturePremiumGlowCore",
        expected_detail
    ]
    if not expected_light_boss_variant:
        required_children.append("VoidCreaturePremiumMaterialBands")
    for child_name in required_children:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s premium body missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s premium body child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if rig.find_child("VoidCreaturePremiumCoreLens", true, false) == null:
        push_error("Enemy visual matrix: %s premium body missing core lens." % label)
        quit(1)
        return false
    var mesh_count := _count_mesh_instances(rig)
    if mesh_count < (3 if expected_light_boss_variant else (10 if boss or elite else 8)):
        push_error("Enemy visual matrix: %s premium body rig looks underbuilt." % label)
        quit(1)
        return false
    if expected_light_boss_variant and mesh_count > 6:
        push_error("Enemy visual matrix: %s light boss variant premium rig exceeded mesh budget." % label)
        quit(1)
        return false
    return true

func _require_void_creature_painterly_depth_rig(model: Node3D, enemy_kind: String, label: String, boss: bool, elite: bool) -> bool:
    var rig := model.find_child("VoidCreaturePainterlyDepthRig", true, false) as Node3D
    if rig == null:
        push_error("Enemy visual matrix: %s missing VoidCreaturePainterlyDepthRig." % label)
        quit(1)
        return false
    if str(rig.get_meta("kind", "")) != enemy_kind:
        push_error("Enemy visual matrix: %s painterly depth kind metadata mismatch." % label)
        quit(1)
        return false
    if bool(rig.get_meta("boss", false)) != boss:
        push_error("Enemy visual matrix: %s painterly depth boss metadata mismatch." % label)
        quit(1)
        return false
    if bool(rig.get_meta("elite", false)) != elite:
        push_error("Enemy visual matrix: %s painterly depth elite metadata mismatch." % label)
        quit(1)
        return false
    var expected_family := _expected_premium_body_family(enemy_kind)
    var expected_detail := _expected_painterly_depth_detail(enemy_kind)
    if str(rig.get_meta("body_family", "")) != expected_family:
        push_error("Enemy visual matrix: %s painterly depth expected family %s." % [label, expected_family])
        quit(1)
        return false
    if str(rig.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s painterly depth expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    if str(rig.get_meta("material_grade", "")) != "void_painted_depth_low_glare":
        push_error("Enemy visual matrix: %s painterly depth missing material grade metadata." % label)
        quit(1)
        return false
    for child_name in [
        "VoidCreatureAmbientOcclusionPlate",
        "VoidCreatureCarapaceRimStroke",
        "VoidCreatureValueShardSteps",
        expected_detail
    ]:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s painterly depth missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s painterly depth child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(rig) < (9 if boss or elite else 8):
        push_error("Enemy visual matrix: %s painterly depth rig looks underbuilt." % label)
        quit(1)
        return false
    if not _require_material_budget(rig, "Enemy visual matrix: %s painterly depth" % label, 0.46, 0.66):
        return false
    return true

func _expected_painterly_depth_detail(kind: String) -> String:
    match _expected_premium_body_family(kind):
        "pounce":
            return "VoidPainterlySkitterBladeDepth"
        "acid_sac":
            return "VoidPainterlySpitterAcidDepth"
        "burrow_spine":
            return "VoidPainterlyBurrowSpineDepth"
        "armor":
            return "VoidPainterlyCarapaceArmorDepth"
        "focus_eye":
            return "VoidPainterlyEyeFocusDepth"
        "summoner_crystal":
            return "VoidPainterlyRiftCrystalDepth"
        "devour_boss":
            return "VoidPainterlyChoDevourDepth"
        "royal_wing":
            return "VoidPainterlyBelvethWingDepth"
        _:
            return "VoidPainterlySwarmMandibleDepth"

func _require_material_budget(node: Node, label: String, max_emission: float, max_transparent_alpha: float) -> bool:
    if node is MeshInstance3D:
        var mesh_instance := node as MeshInstance3D
        if mesh_instance.material_override is StandardMaterial3D:
            var mat := mesh_instance.material_override as StandardMaterial3D
            if mat.emission_enabled and mat.emission_energy_multiplier > max_emission:
                push_error("%s material %s emission too bright: %.2f." % [label, node.name, mat.emission_energy_multiplier])
                quit(1)
                return false
            if mat.albedo_color.a < 0.99 and mat.albedo_color.a > max_transparent_alpha:
                push_error("%s material %s transparent alpha too high: %.2f." % [label, node.name, mat.albedo_color.a])
                quit(1)
                return false
    for child in node.get_children():
        if not _require_material_budget(child, label, max_emission, max_transparent_alpha):
            return false
    return true

func _expected_premium_body_family(kind: String) -> String:
    match kind:
        "skitter":
            return "pounce"
        "spitter":
            return "acid_sac"
        "burrower", "boss_reksai":
            return "burrow_spine"
        "carapace":
            return "armor"
        "void_eye", "boss_velkoz":
            return "focus_eye"
        "rift_crystal":
            return "summoner_crystal"
        "boss_cho":
            return "devour_boss"
        "boss_belveth":
            return "royal_wing"
        "voidling":
            return "swarm"
        _:
            return "swarm"

func _expected_premium_body_detail(kind: String) -> String:
    match _expected_premium_body_family(kind):
        "pounce":
            return "VoidCreaturePremiumSkitterBladeLegs"
        "acid_sac":
            return "VoidCreaturePremiumSpitterAcidCrown"
        "burrow_spine":
            return "VoidCreaturePremiumBurrowSpineArmor"
        "armor":
            return "VoidCreaturePremiumCarapaceShellStack"
        "focus_eye":
            return "VoidCreaturePremiumEyeCrownLenses"
        "summoner_crystal":
            return "VoidCreaturePremiumRiftCrystalConduit"
        "devour_boss":
            return "VoidCreaturePremiumChoDevourCrown"
        "royal_wing":
            return "VoidCreaturePremiumBelvethRoyalWings"
        _:
            return "VoidCreaturePremiumSwarmMandibles"

func _expected_combat_family(kind: String) -> String:
    match kind:
        "voidling":
            return "swarm"
        "skitter":
            return "pounce"
        "spitter":
            return "acid"
        "burrower", "boss_reksai":
            return "burrow"
        "carapace":
            return "armor"
        "void_eye", "boss_velkoz":
            return "focus"
        "rift_crystal":
            return "summon"
        "boss_cho":
            return "devour"
        "boss_belveth":
            return "wing_swarm"
        _:
            return "generic"

func _expected_combat_detail(kind: String) -> String:
    match _expected_combat_family(kind):
        "swarm":
            return "EnemyCombatIntentSwarmBite"
        "pounce":
            return "EnemyCombatIntentPounceClaws"
        "acid":
            return "EnemyCombatIntentAcidSpit"
        "burrow":
            return "EnemyCombatIntentBurrowCharge"
        "armor":
            return "EnemyCombatIntentArmorGuard"
        "focus":
            return "EnemyCombatIntentVoidFocus"
        "summon":
            return "EnemyCombatIntentRiftSummon"
        "devour":
            return "EnemyCombatIntentDevourRupture"
        "wing_swarm":
            return "EnemyCombatIntentSwarmWings"
        _:
            return "EnemyCombatIntentGeneric"

func _require_elite_trait_telegraph(model: Node3D, label: String, elite_trait: String) -> bool:
    var rig := model.find_child("EliteTraitTelegraphRig", true, false) as Node3D
    if rig == null:
        push_error("Enemy visual matrix: %s missing EliteTraitTelegraphRig." % label)
        quit(1)
        return false
    if str(rig.get_meta("elite_trait", "")) != elite_trait:
        push_error("Enemy visual matrix: %s telegraph trait metadata mismatch." % label)
        quit(1)
        return false
    for child_name in ["EliteTraitTelegraphCore", "EliteTraitTelegraphPattern", "EliteTraitTelegraphPip0"]:
        if rig.find_child(child_name, true, false) == null:
            push_error("Enemy visual matrix: %s telegraph missing %s." % [label, child_name])
            quit(1)
            return false
    var expected_detail := ""
    match elite_trait:
        "frenzy":
            expected_detail = "EliteTraitFrenzyClaws"
        "bulwark":
            expected_detail = "EliteTraitBulwarkShield"
        "splitter":
            expected_detail = "EliteTraitSplitterSeeds"
        "treasure":
            expected_detail = "EliteTraitTreasureCache"
        _:
            pass
    if expected_detail != "" and rig.find_child(expected_detail, true, false) == null:
        push_error("Enemy visual matrix: %s telegraph missing %s." % [label, expected_detail])
        quit(1)
        return false
    if not _require_elite_trait_intent_profile(rig, label, elite_trait):
        return false
    if not _require_elite_trait_behavior_state_rig(rig, label, elite_trait):
        return false
    if not _require_elite_trait_tactical_readout(rig, label, elite_trait):
        return false
    if _count_mesh_instances(rig) < 7:
        push_error("Enemy visual matrix: %s elite telegraph looks underbuilt." % label)
        quit(1)
        return false
    return true

func _require_elite_trait_intent_profile(rig: Node3D, label: String, elite_trait: String) -> bool:
    var profile := rig.get_node_or_null("EliteTraitIntentProfile") as Node3D
    if profile == null:
        push_error("Enemy visual matrix: %s telegraph missing EliteTraitIntentProfile." % label)
        quit(1)
        return false
    if str(profile.get_meta("elite_trait", "")) != elite_trait:
        push_error("Enemy visual matrix: %s intent profile trait metadata mismatch." % label)
        quit(1)
        return false
    var expected_intent := ""
    var expected_detail := ""
    match elite_trait:
        "frenzy":
            expected_intent = "rush_pressure"
            expected_detail = "EliteTraitIntentFrenzyRush"
        "bulwark":
            expected_intent = "shield_breakpoint"
            expected_detail = "EliteTraitIntentBulwarkBreak"
        "splitter":
            expected_intent = "split_after_death"
            expected_detail = "EliteTraitIntentSplitterBloom"
        "treasure":
            expected_intent = "high_value_reward"
            expected_detail = "EliteTraitIntentTreasureReward"
        _:
            expected_intent = "generic"
            expected_detail = "EliteTraitIntentGeneric"
    if str(profile.get_meta("intent_type", "")) != expected_intent:
        push_error("Enemy visual matrix: %s intent profile expected %s." % [label, expected_intent])
        quit(1)
        return false
    if str(profile.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s intent profile expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    for child_name in ["EliteTraitIntentFrame", "EliteTraitIntentPip", expected_detail]:
        var child := profile.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s intent profile missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s intent profile child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(profile) < 4:
        push_error("Enemy visual matrix: %s intent profile looks underbuilt." % label)
        quit(1)
        return false
    return true

func _require_elite_trait_tactical_readout(rig: Node3D, label: String, elite_trait: String) -> bool:
    var readout := rig.get_node_or_null("EliteTraitTacticalReadout") as Node3D
    if readout == null:
        push_error("Enemy visual matrix: %s telegraph missing EliteTraitTacticalReadout." % label)
        quit(1)
        return false
    if str(readout.get_meta("elite_trait", "")) != elite_trait:
        push_error("Enemy visual matrix: %s tactical readout trait metadata mismatch." % label)
        quit(1)
        return false
    var expected_type := ""
    var expected_detail := ""
    var expected_pockets := 0
    match elite_trait:
        "frenzy":
            expected_type = "rush_lane"
            expected_detail = "EliteTraitTacticalFrenzyRushLane"
            expected_pockets = 2
        "bulwark":
            expected_type = "break_window"
            expected_detail = "EliteTraitTacticalBulwarkBreakWindow"
            expected_pockets = 3
        "splitter":
            expected_type = "bloom_radius"
            expected_detail = "EliteTraitTacticalSplitterBloomRadius"
            expected_pockets = 4
        "treasure":
            expected_type = "flee_vector"
            expected_detail = "EliteTraitTacticalTreasureFleeVector"
            expected_pockets = 3
        _:
            expected_type = "generic"
            expected_detail = "EliteTraitTacticalGeneric"
            expected_pockets = 2
    if str(readout.get_meta("tactical_type", "")) != expected_type:
        push_error("Enemy visual matrix: %s tactical readout expected type %s." % [label, expected_type])
        quit(1)
        return false
    if str(readout.get_meta("detail_node", "")) != expected_detail:
        push_error("Enemy visual matrix: %s tactical readout expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    if int(readout.get_meta("safe_pocket_count", 0)) != expected_pockets:
        push_error("Enemy visual matrix: %s tactical readout expected %d safe pockets." % [label, expected_pockets])
        quit(1)
        return false
    if str(readout.get_meta("combat_visual_channel", "")) != "elite_trait_tactical_readability":
        push_error("Enemy visual matrix: %s tactical readout channel mismatch." % label)
        quit(1)
        return false
    if str(readout.get_meta("material_grade", "")) != "low_glare_elite_trait_tactical_readout":
        push_error("Enemy visual matrix: %s tactical readout material grade mismatch." % label)
        quit(1)
        return false
    if not bool(readout.get_meta("elite_tactical_readout_layer", false)):
        push_error("Enemy visual matrix: %s tactical readout missing layer metadata." % label)
        quit(1)
        return false
    for child_name in ["EliteTraitTacticalBase", "EliteTraitTacticalSafePockets", expected_detail]:
        var child := readout.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s tactical readout missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s tactical readout child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    var pockets := readout.get_node_or_null("EliteTraitTacticalSafePockets") as Node3D
    if pockets == null or _count_named_children(pockets, "EliteTraitSafePocket_") != expected_pockets:
        push_error("Enemy visual matrix: %s tactical readout pocket count mismatch." % label)
        quit(1)
        return false
    if not _require_material_budget(readout, "Enemy visual matrix: %s tactical readout" % label, 0.08, 0.30):
        return false
    if _count_mesh_instances(readout) < expected_pockets + 3:
        push_error("Enemy visual matrix: %s tactical readout looks underbuilt." % label)
        quit(1)
        return false
    return true

func _require_elite_trait_behavior_state_rig(rig: Node3D, label: String, elite_trait: String) -> bool:
    var state := rig.get_node_or_null("EliteTraitBehaviorStateRig") as Node3D
    if state == null:
        push_error("Enemy visual matrix: %s telegraph missing EliteTraitBehaviorStateRig." % label)
        quit(1)
        return false
    if str(state.get_meta("elite_trait", "")) != elite_trait:
        push_error("Enemy visual matrix: %s behavior state trait metadata mismatch." % label)
        quit(1)
        return false
    var expected_state := ""
    match elite_trait:
        "frenzy":
            expected_state = "EliteTraitStateFrenzyDash"
        "bulwark":
            expected_state = "EliteTraitStateBulwarkBreak"
        "splitter":
            expected_state = "EliteTraitStateSplitterBloom"
        "treasure":
            expected_state = "EliteTraitStateTreasureFlee"
        _:
            expected_state = "EliteTraitStateGeneric"
    if str(state.get_meta("state_node", "")) != expected_state:
        push_error("Enemy visual matrix: %s behavior state expected metadata %s." % [label, expected_state])
        quit(1)
        return false
    for child_name in ["EliteTraitStateHalo", "EliteTraitStateMeter", expected_state]:
        var child := state.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Enemy visual matrix: %s behavior state missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Enemy visual matrix: %s behavior state child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if elite_trait == "bulwark" and state.get_node_or_null("EliteTraitStateBulwarkGuardPips") == null:
        push_error("Enemy visual matrix: %s behavior state missing bulwark guard pips." % label)
        quit(1)
        return false
    if _count_mesh_instances(state) < 4:
        push_error("Enemy visual matrix: %s behavior state looks underbuilt." % label)
        quit(1)
        return false
    return true

func _expects_weakpoint_core(kind: String) -> bool:
    return kind == "spitter" or kind == "burrower" or kind == "void_eye" or kind == "rift_crystal"

func _enemy_color(kind: String) -> Color:
    match kind:
        "spitter":
            return Color(0.44, 0.78, 0.34)
        "burrower", "boss_reksai":
            return Color(0.86, 0.38, 0.22)
        "carapace", "boss_cho":
            return Color(0.44, 0.22, 0.74)
        "void_eye", "boss_velkoz":
            return Color(0.82, 0.24, 1.0)
        "rift_crystal":
            return Color(0.30, 0.86, 1.0)
        "boss_belveth":
            return Color(0.70, 0.18, 1.0)
        _:
            return Color(0.58, 0.28, 0.86)

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
