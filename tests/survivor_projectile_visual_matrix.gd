extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const ProjectileScript := preload("res://scripts/survivor_projectile.gd")

const PLAYER_LABELS := [
    "fishbones",
    "death_rocket",
    "senna",
    "samira",
    "viktor",
    "xayah",
    "teemo",
    "comet",
    "morde"
]

const ENEMY_LABELS := [
    "A",
    "E",
    "C",
    "R",
    "Q",
    "V",
    "X",
    "B",
    "F",
    "U",
    "S",
    "T",
    "void_spit"
]

const THREAT_BADGE_LABELS := ["A", "E", "C", "R", "Q", "V", "X", "B", "F", "U", "S", "T"]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    var total_meshes := 0
    for label in PLAYER_LABELS:
        var projectile = _make_projectile(label, true)
        var model: Node3D = view.call("_create_projectile_model", projectile, false, false)
        view.add_child(model)
        await process_frame
        if not _require_channel(model, "player_skill", "player_" + label):
            return
        if not _require_node(model, "PlayerProjectileSignatureRig", "player_" + label):
            return
        if not _require_node(model, "PlayerProjectileHeroGlyph", "player_" + label):
            return
        if not _require_node(model, "ProjectileVfxDecal", "player_" + label):
            return
        if not _require_player_path_signature(model, "player_" + label):
            return
        if not _require_player_role_profile(model, label, "player_" + label):
            return
        if not _require_player_impact_intent_profile(model, label, "player_" + label):
            return
        if not _require_player_spell_trail_profile(model, label, "player_" + label):
            return
        if not _require_player_premium_fx_rig(model, label, "player_" + label):
            return
        if not _require_champion_projectile_mechanic_silhouette(model, label, "player_" + label):
            return
        if not _forbid_node(model, "EnemyProjectileReadabilityShell", "player_" + label):
            return
        if not _require_material_budget(model, "player_" + label, 0.065, 0.30):
            return
        if _count_mesh_instances(model) < 4:
            push_error("Projectile visual matrix: player %s looks underbuilt." % label)
            quit(1)
            return
        total_meshes += _count_mesh_instances(model)
        model.queue_free()
        await process_frame

        var lite_model: Node3D = view.call("_create_projectile_model", projectile, false, true)
        view.add_child(lite_model)
        await process_frame
        if not _require_channel(lite_model, "player_skill_lite", "player_lite_" + label):
            return
        if not _require_node(lite_model, "PlayerProjectileSignatureRig", "player_lite_" + label):
            return
        if not _forbid_node(lite_model, "PlayerProjectileHeroGlyph", "player_lite_" + label):
            return
        if not _forbid_node(lite_model, "ProjectileVfxDecal", "player_lite_" + label):
            return
        if not _forbid_node(lite_model, "PlayerProjectilePathSignature", "player_lite_" + label):
            return
        if not _forbid_node(lite_model, "PlayerProjectileRoleProfile", "player_lite_" + label):
            return
        if not _forbid_node(lite_model, "PlayerProjectileImpactIntentProfile", "player_lite_" + label):
            return
        if not _forbid_node(lite_model, "PlayerProjectileSpellTrailProfile", "player_lite_" + label):
            return
        if not _forbid_node(lite_model, "PlayerProjectilePremiumFxRig", "player_lite_" + label):
            return
        if not _forbid_node(lite_model, "ChampionProjectileMechanicSilhouetteRig", "player_lite_" + label):
            return
        if not _forbid_node(lite_model, "EnemyProjectileReadabilityShell", "player_lite_" + label):
            return
        if not _require_material_budget(lite_model, "player_lite_" + label, 0.065, 0.30):
            return
        total_meshes += _count_mesh_instances(lite_model)
        lite_model.queue_free()
        await process_frame

    for label in ENEMY_LABELS:
        var enemy_projectile = _make_projectile(label, false)
        var enemy_model: Node3D = view.call("_create_projectile_model", enemy_projectile, false, false)
        view.add_child(enemy_model)
        await process_frame
        if not _require_channel_prefix(enemy_model, "enemy_hazard_", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileLane", "enemy_" + label):
            return
        if not _require_child_channel(enemy_model, "EnemyProjectileLane", "enemy_hazard", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileTrajectoryMarks", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileHeadingArrow", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileRangeNotch0", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileDangerRig", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileVfxDecal", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileReadabilityShell", "enemy_" + label):
            return
        if not _require_child_channel(enemy_model, "EnemyProjectileReadabilityShell", "enemy_hazard", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileBlackCore", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileDarkGroundGap", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectilePickupSeparationRing", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileSilhouetteGuard", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileThreatOutline", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileDangerBackplate", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileDangerNeedle", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileOcclusionMatte", "enemy_" + label):
            return
        if not _require_enemy_pickup_confusion_guard(enemy_model, "enemy_" + label):
            return
        if not _require_enemy_silhouette_guard(enemy_model, "enemy_" + label, false):
            return
        if not _require_enemy_danger_blade_rig(enemy_model, "enemy_" + label, false):
            return
        if not _require_enemy_collision_readability_ring(enemy_model, "enemy_" + label, false):
            return
        if not _require_enemy_hitbox_lock(enemy_model, label, "enemy_" + label, false):
            return
        if not _require_enemy_motion_contrast_rig(enemy_model, "enemy_" + label, false):
            return
        if not _require_enemy_threat_shape_code(enemy_model, label, "enemy_" + label, false):
            return
        if not _require_node(enemy_model, "EnemyProjectileHazardChevron", "enemy_" + label):
            return
        if not _require_node(enemy_model, "EnemyProjectileDangerTick0", "enemy_" + label):
            return
        if THREAT_BADGE_LABELS.has(label) and not _require_node(enemy_model, "EnemyProjectileThreatBadge", "enemy_" + label):
            return
        if not _require_enemy_intent_profile(enemy_model, label, "enemy_" + label):
            return
        if not _require_material_budget(enemy_model, "enemy_" + label, 0.10, 0.37):
            return
        total_meshes += _count_mesh_instances(enemy_model)
        enemy_model.queue_free()
        await process_frame

        var lite_enemy_model: Node3D = view.call("_create_projectile_model", enemy_projectile, true, false)
        view.add_child(lite_enemy_model)
        await process_frame
        if not _require_channel_prefix(lite_enemy_model, "enemy_hazard_lite_", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileLane", "enemy_lite_" + label):
            return
        if not _require_child_channel(lite_enemy_model, "EnemyProjectileLane", "enemy_hazard", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileTrajectoryMarks", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileHeadingArrow", "enemy_lite_" + label):
            return
        if not _forbid_node(lite_enemy_model, "EnemyProjectileRangeNotch0", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileDangerRig", "enemy_lite_" + label):
            return
        if not _forbid_node(lite_enemy_model, "EnemyProjectileVfxDecal", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileReadabilityShell", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileBlackCore", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileDarkGroundGap", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectilePickupSeparationRing", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileSilhouetteGuard", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileThreatOutline", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileDangerBackplate", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileDangerNeedle", "enemy_lite_" + label):
            return
        if not _require_node(lite_enemy_model, "EnemyProjectileOcclusionMatte", "enemy_lite_" + label):
            return
        if not _require_enemy_pickup_confusion_guard(lite_enemy_model, "enemy_lite_" + label):
            return
        if not _require_enemy_silhouette_guard(lite_enemy_model, "enemy_lite_" + label, true):
            return
        if not _require_enemy_danger_blade_rig(lite_enemy_model, "enemy_lite_" + label, true):
            return
        if not _require_enemy_collision_readability_ring(lite_enemy_model, "enemy_lite_" + label, true):
            return
        if not _require_enemy_hitbox_lock(lite_enemy_model, label, "enemy_lite_" + label, true):
            return
        if not _require_enemy_motion_contrast_rig(lite_enemy_model, "enemy_lite_" + label, true):
            return
        if not _require_enemy_threat_shape_code(lite_enemy_model, label, "enemy_lite_" + label, true):
            return
        if not _forbid_node(lite_enemy_model, "EnemyProjectileHazardChevron", "enemy_lite_" + label):
            return
        if not _forbid_node(lite_enemy_model, "EnemyProjectileDangerTick0", "enemy_lite_" + label):
            return
        if not _forbid_node(lite_enemy_model, "EnemyProjectileIntentProfile", "enemy_lite_" + label):
            return
        if THREAT_BADGE_LABELS.has(label) and not _require_node(lite_enemy_model, "EnemyProjectileThreatBadge", "enemy_lite_" + label):
            return
        if not _require_material_budget(lite_enemy_model, "enemy_lite_" + label, 0.10, 0.37):
            return
        total_meshes += _count_mesh_instances(lite_enemy_model)
        lite_enemy_model.queue_free()
        await process_frame

    print("SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=%d enemy=%d meshes=%d" % [PLAYER_LABELS.size(), ENEMY_LABELS.size(), total_meshes])
    quit(0)

func _make_projectile(label: String, from_player: bool):
    var projectile = ProjectileScript.new()
    var color := Color(0.34, 0.84, 1.0) if from_player else Color(1.0, 0.18, 0.48)
    projectile.setup(Vector2.ZERO, Vector2(1, 0) * 220.0, 3, 8.0, color, label, 1, 1.2, from_player)
    return projectile

func _require_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) == null:
        push_error("Projectile visual matrix: %s missing %s." % [label, node_name])
        quit(1)
        return false
    return true

func _forbid_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) != null:
        push_error("Projectile visual matrix: %s should not include heavy %s." % [label, node_name])
        quit(1)
        return false
    return true

func _require_channel(model: Node3D, expected_channel: String, label: String) -> bool:
    if str(model.get_meta("combat_visual_channel", "")) != expected_channel:
        push_error("Projectile visual matrix: %s expected channel %s, got %s." % [label, expected_channel, str(model.get_meta("combat_visual_channel", ""))])
        quit(1)
        return false
    if float(model.get_meta("readability_priority", -1.0)) < 0.0:
        push_error("Projectile visual matrix: %s missing readability priority." % label)
        quit(1)
        return false
    return true

func _require_channel_prefix(model: Node3D, expected_prefix: String, label: String) -> bool:
    var channel := str(model.get_meta("combat_visual_channel", ""))
    if not channel.begins_with(expected_prefix):
        push_error("Projectile visual matrix: %s expected channel prefix %s, got %s." % [label, expected_prefix, channel])
        quit(1)
        return false
    if float(model.get_meta("readability_priority", -1.0)) < 0.0:
        push_error("Projectile visual matrix: %s missing readability priority." % label)
        quit(1)
        return false
    return true

func _require_material_budget(node: Node, label: String, max_emission: float, max_transparent_alpha: float) -> bool:
    if node is MeshInstance3D:
        var mesh_instance := node as MeshInstance3D
        var mat := mesh_instance.material_override as StandardMaterial3D
        if mat != null:
            if mat.emission_enabled and mat.emission_energy_multiplier > max_emission:
                push_error("Projectile visual matrix: %s material %s emission too bright: %.2f." % [label, node.name, mat.emission_energy_multiplier])
                quit(1)
                return false
            if mat.albedo_color.a < 0.99 and mat.albedo_color.a > max_transparent_alpha:
                push_error("Projectile visual matrix: %s material %s transparent alpha too high: %.2f." % [label, node.name, mat.albedo_color.a])
                quit(1)
                return false
    for child in node.get_children():
        if not _require_material_budget(child, label, max_emission, max_transparent_alpha):
            return false
    return true

func _require_child_channel(model: Node3D, node_name: String, expected_channel: String, label: String) -> bool:
    var node := model.find_child(node_name, true, false) as Node
    if node == null:
        push_error("Projectile visual matrix: %s missing %s for channel check." % [label, node_name])
        quit(1)
        return false
    if str(node.get_meta("combat_visual_channel", "")) != expected_channel:
        push_error("Projectile visual matrix: %s expected %s channel %s." % [label, node_name, expected_channel])
        quit(1)
        return false
    return true

func _require_enemy_pickup_confusion_guard(model: Node3D, label: String) -> bool:
    var shell := model.find_child("EnemyProjectileReadabilityShell", true, false) as Node3D
    if shell == null:
        push_error("Projectile visual matrix: %s missing readability shell for pickup confusion guard." % label)
        quit(1)
        return false
    if not bool(shell.get_meta("pickup_confusion_guard", false)):
        push_error("Projectile visual matrix: %s shell missing pickup confusion guard metadata." % label)
        quit(1)
        return false
    if str(shell.get_meta("hazard_shape_language", "")) != "red_black_triangle":
        push_error("Projectile visual matrix: %s expected red/black triangular hazard shape language." % label)
        quit(1)
        return false
    for node_name in ["EnemyProjectileDangerBackplate", "EnemyProjectileDangerNeedle", "EnemyProjectileOcclusionMatte"]:
        var child := shell.get_node_or_null(node_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s missing %s in pickup confusion guard." % [label, node_name])
            quit(1)
            return false
        if str(child.get_meta("combat_visual_channel", "")) != "enemy_hazard" or not bool(child.get_meta("pickup_confusion_guard", false)):
            push_error("Projectile visual matrix: %s %s missing guard metadata." % [label, node_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s %s has no mesh content." % [label, node_name])
            quit(1)
            return false
    return true

func _require_enemy_silhouette_guard(model: Node3D, label: String, expected_lite: bool) -> bool:
    var guard := model.find_child("EnemyProjectileSilhouetteGuard", true, false) as Node3D
    if guard == null:
        push_error("Projectile visual matrix: %s missing EnemyProjectileSilhouetteGuard." % label)
        quit(1)
        return false
    if bool(guard.get_meta("lite", not expected_lite)) != expected_lite:
        push_error("Projectile visual matrix: %s silhouette guard lite metadata mismatch." % label)
        quit(1)
        return false
    if str(guard.get_meta("combat_visual_channel", "")) != "enemy_hazard":
        push_error("Projectile visual matrix: %s silhouette guard missing enemy hazard channel." % label)
        quit(1)
        return false
    if not bool(guard.get_meta("pickup_confusion_guard", false)):
        push_error("Projectile visual matrix: %s silhouette guard missing pickup guard metadata." % label)
        quit(1)
        return false
    if str(guard.get_meta("material_grade", "")) != "low_glare_enemy_projectile_silhouette_guard":
        push_error("Projectile visual matrix: %s silhouette guard material grade mismatch." % label)
        quit(1)
        return false
    if str(guard.get_meta("hazard_shape_language", "")) != "black_matte_outer_silhouette":
        push_error("Projectile visual matrix: %s silhouette guard shape language mismatch." % label)
        quit(1)
        return false
    for child_name in [
        "EnemyProjectileSilhouetteGuardMatte",
        "EnemyProjectileSilhouetteDirectionalCut",
        "EnemyProjectileNoPickupConfusionBand"
    ]:
        var child := guard.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s silhouette guard missing %s." % [label, child_name])
            quit(1)
            return false
        if str(child.get_meta("combat_visual_channel", "")) != "enemy_hazard" or not bool(child.get_meta("pickup_confusion_guard", false)):
            push_error("Projectile visual matrix: %s silhouette guard child %s missing guard metadata." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s silhouette guard child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(guard) != 3:
        push_error("Projectile visual matrix: %s silhouette guard mesh budget invalid." % label)
        quit(1)
        return false
    if not _require_material_budget(guard, "%s silhouette guard" % label, 0.0, 0.35):
        return false
    if _has_pickup_visual_channel(guard):
        push_error("Projectile visual matrix: %s silhouette guard leaked into pickup channel." % label)
        quit(1)
        return false
    return true

func _require_enemy_danger_blade_rig(model: Node3D, label: String, expected_lite: bool) -> bool:
    var blade := model.find_child("EnemyProjectileDangerBladeRig", true, false) as Node3D
    if blade == null:
        push_error("Projectile visual matrix: %s missing EnemyProjectileDangerBladeRig." % label)
        quit(1)
        return false
    if bool(blade.get_meta("lite", not expected_lite)) != expected_lite:
        push_error("Projectile visual matrix: %s danger blade lite metadata mismatch." % label)
        quit(1)
        return false
    if str(blade.get_meta("combat_visual_channel", "")) != "enemy_hazard":
        push_error("Projectile visual matrix: %s danger blade missing enemy hazard channel." % label)
        quit(1)
        return false
    if not bool(blade.get_meta("pickup_confusion_guard", false)):
        push_error("Projectile visual matrix: %s danger blade missing pickup confusion guard metadata." % label)
        quit(1)
        return false
    if str(blade.get_meta("hazard_shape_language", "")) != "red_black_directional_blade":
        push_error("Projectile visual matrix: %s danger blade shape language mismatch." % label)
        quit(1)
        return false
    for child_name in [
        "EnemyProjectileDangerBladeBlackLeft",
        "EnemyProjectileDangerBladeBlackRight",
        "EnemyProjectileDangerBladeRedLeft",
        "EnemyProjectileDangerBladeRedRight"
    ]:
        var child := blade.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s danger blade missing %s." % [label, child_name])
            quit(1)
            return false
        if str(child.get_meta("combat_visual_channel", "")) != "enemy_hazard" or not bool(child.get_meta("pickup_confusion_guard", false)):
            push_error("Projectile visual matrix: %s danger blade child %s missing guard metadata." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s danger blade child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(blade) < 4:
        push_error("Projectile visual matrix: %s danger blade rig looks underbuilt." % label)
        quit(1)
        return false
    return true

func _require_enemy_collision_readability_ring(model: Node3D, label: String, expected_lite: bool) -> bool:
    var marker := model.find_child("EnemyProjectileThreatOutline", true, false) as Node3D
    if marker == null:
        push_error("Projectile visual matrix: %s missing EnemyProjectileThreatOutline collision marker." % label)
        quit(1)
        return false
    if str(marker.get_meta("combat_visual_channel", "")) != "enemy_hazard":
        push_error("Projectile visual matrix: %s collision marker missing enemy hazard channel." % label)
        quit(1)
        return false
    if not bool(marker.get_meta("pickup_confusion_guard", false)) or not bool(marker.get_meta("collision_radius_marker", false)):
        push_error("Projectile visual matrix: %s collision marker missing guard metadata." % label)
        quit(1)
        return false
    if str(marker.get_meta("material_grade", "")) != "low_glare_enemy_collision_radius":
        push_error("Projectile visual matrix: %s collision marker material grade mismatch." % label)
        quit(1)
        return false
    if str(marker.get_meta("hazard_shape_language", "")) != "black_red_collision_radius":
        push_error("Projectile visual matrix: %s collision marker shape language mismatch." % label)
        quit(1)
        return false
    if _count_mesh_instances(marker) <= 0:
        push_error("Projectile visual matrix: %s collision root has no mesh content." % label)
        quit(1)
        return false
    var root_mat := _first_material(marker)
    if root_mat == null or root_mat.emission_enabled:
        push_error("Projectile visual matrix: %s collision root should be non-emissive." % label)
        quit(1)
        return false
    var mesh_count := _count_mesh_instances(marker)
    if mesh_count != 1:
        push_error("Projectile visual matrix: %s collision marker should reuse one existing mesh, got %d." % [label, mesh_count])
        quit(1)
        return false
    return true

func _require_enemy_hitbox_lock(model: Node3D, projectile_label: String, label: String, expected_lite: bool) -> bool:
    var lock := model.find_child("EnemyProjectileHitboxLock", true, false) as Node3D
    if lock == null:
        push_error("Projectile visual matrix: %s missing EnemyProjectileHitboxLock." % label)
        quit(1)
        return false
    if bool(lock.get_meta("lite", not expected_lite)) != expected_lite:
        push_error("Projectile visual matrix: %s hitbox lock lite metadata mismatch." % label)
        quit(1)
        return false
    if str(lock.get_meta("combat_visual_channel", "")) != "enemy_hazard":
        push_error("Projectile visual matrix: %s hitbox lock missing enemy hazard channel." % label)
        quit(1)
        return false
    if not bool(lock.get_meta("pickup_confusion_guard", false)) or not bool(lock.get_meta("collision_radius_marker", false)):
        push_error("Projectile visual matrix: %s hitbox lock missing collision/pickup guard metadata." % label)
        quit(1)
        return false
    if str(lock.get_meta("material_grade", "")) != "low_glare_enemy_projectile_hitbox_lock":
        push_error("Projectile visual matrix: %s hitbox lock material grade mismatch." % label)
        quit(1)
        return false
    if str(lock.get_meta("hazard_shape_language", "")) != "black_red_hitbox_lock":
        push_error("Projectile visual matrix: %s hitbox lock shape language mismatch." % label)
        quit(1)
        return false
    if str(lock.get_meta("threat_tier", "")) != _expected_enemy_threat_tier(projectile_label):
        push_error("Projectile visual matrix: %s hitbox lock threat tier mismatch." % label)
        quit(1)
        return false
    for child_name in [
        "EnemyProjectileHitboxLockShadow",
        "EnemyProjectileHitboxLockRing",
        "EnemyProjectileHitboxLockDirectionTab"
    ]:
        var child := lock.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s hitbox lock missing %s." % [label, child_name])
            quit(1)
            return false
        if str(child.get_meta("combat_visual_channel", "")) != "enemy_hazard":
            push_error("Projectile visual matrix: %s hitbox lock child %s missing channel." % [label, child_name])
            quit(1)
            return false
        if not bool(child.get_meta("pickup_confusion_guard", false)) or not bool(child.get_meta("collision_radius_marker", false)):
            push_error("Projectile visual matrix: %s hitbox lock child %s missing guard metadata." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s hitbox lock child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    var tier_ticks := lock.get_node_or_null("EnemyProjectileHitboxLockTierTicks") as Node3D
    if expected_lite and tier_ticks != null:
        push_error("Projectile visual matrix: %s lite hitbox lock should omit tier ticks." % label)
        quit(1)
        return false
    if not expected_lite:
        if tier_ticks == null:
            push_error("Projectile visual matrix: %s hitbox lock missing tier ticks." % label)
            quit(1)
            return false
        if str(tier_ticks.get_meta("combat_visual_channel", "")) != "enemy_hazard":
            push_error("Projectile visual matrix: %s hitbox lock tier ticks missing channel." % label)
            quit(1)
            return false
        if _count_mesh_instances(tier_ticks) < 3:
            push_error("Projectile visual matrix: %s hitbox lock tier ticks look underbuilt." % label)
            quit(1)
            return false
    var mesh_count := _count_mesh_instances(lock)
    var max_meshes := 3 if expected_lite else 8
    var min_meshes := 3 if expected_lite else 6
    if mesh_count < min_meshes or mesh_count > max_meshes:
        push_error("Projectile visual matrix: %s hitbox lock mesh budget invalid: %d." % [label, mesh_count])
        quit(1)
        return false
    if not _require_material_budget(lock, "%s hitbox lock" % label, 0.0, 0.37):
        return false
    if _has_pickup_visual_channel(lock):
        push_error("Projectile visual matrix: %s hitbox lock leaked into pickup channel." % label)
        quit(1)
        return false
    return true

func _require_enemy_motion_contrast_rig(model: Node3D, label: String, expected_lite: bool) -> bool:
    var rig := model.find_child("EnemyProjectileMotionContrastRig", true, false) as Node3D
    if rig == null:
        push_error("Projectile visual matrix: %s missing EnemyProjectileMotionContrastRig." % label)
        quit(1)
        return false
    if bool(rig.get_meta("lite", not expected_lite)) != expected_lite:
        push_error("Projectile visual matrix: %s motion contrast lite metadata mismatch." % label)
        quit(1)
        return false
    if str(rig.get_meta("combat_visual_channel", "")) != "enemy_hazard":
        push_error("Projectile visual matrix: %s motion contrast missing enemy hazard channel." % label)
        quit(1)
        return false
    if not bool(rig.get_meta("pickup_confusion_guard", false)) or not bool(rig.get_meta("motion_contrast_layer", false)):
        push_error("Projectile visual matrix: %s motion contrast missing guard metadata." % label)
        quit(1)
        return false
    if str(rig.get_meta("material_grade", "")) != "low_glare_enemy_projectile_motion_contrast":
        push_error("Projectile visual matrix: %s motion contrast material grade mismatch." % label)
        quit(1)
        return false
    if str(rig.get_meta("hazard_shape_language", "")) != "black_motion_tail":
        push_error("Projectile visual matrix: %s motion contrast shape language mismatch." % label)
        quit(1)
        return false
    for child_name in ["EnemyProjectileMotionShadowCore", "EnemyProjectileMotionTailSeparator", "EnemyProjectileMotionHeadNotch"]:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s motion contrast missing %s." % [label, child_name])
            quit(1)
            return false
        if str(child.get_meta("combat_visual_channel", "")) != "enemy_hazard":
            push_error("Projectile visual matrix: %s motion contrast child %s missing channel." % [label, child_name])
            quit(1)
            return false
        if not bool(child.get_meta("pickup_confusion_guard", false)) or not bool(child.get_meta("motion_contrast_layer", false)):
            push_error("Projectile visual matrix: %s motion contrast child %s missing guard." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s motion contrast child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(rig) != 3:
        push_error("Projectile visual matrix: %s motion contrast should use exactly 3 meshes." % label)
        quit(1)
        return false
    if not _require_material_budget(rig, "%s motion contrast" % label, 0.0, 0.35):
        return false
    if _has_pickup_visual_channel(rig):
        push_error("Projectile visual matrix: %s motion contrast leaked into pickup channel." % label)
        quit(1)
        return false
    return true

func _first_material(node: Node) -> StandardMaterial3D:
    if node is MeshInstance3D:
        return (node as MeshInstance3D).material_override as StandardMaterial3D
    for child in node.get_children():
        var mat := _first_material(child)
        if mat != null:
            return mat
    return null

func _has_pickup_visual_channel(node: Node) -> bool:
    if node == null:
        return false
    var channel := str(node.get_meta("combat_visual_channel", ""))
    if channel.begins_with("pickup"):
        return true
    for child in node.get_children():
        if _has_pickup_visual_channel(child):
            return true
    return false

func _require_enemy_threat_shape_code(model: Node3D, projectile_label: String, label: String, expected_lite: bool) -> bool:
    var root := model.find_child("EnemyProjectileThreatShapeCode", true, false) as Node3D
    if root == null:
        push_error("Projectile visual matrix: %s missing EnemyProjectileThreatShapeCode." % label)
        quit(1)
        return false
    if bool(root.get_meta("lite", not expected_lite)) != expected_lite:
        push_error("Projectile visual matrix: %s threat shape lite metadata mismatch." % label)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "enemy_hazard":
        push_error("Projectile visual matrix: %s threat shape missing enemy hazard channel." % label)
        quit(1)
        return false
    if not bool(root.get_meta("pickup_confusion_guard", false)):
        push_error("Projectile visual matrix: %s threat shape missing pickup confusion guard." % label)
        quit(1)
        return false
    if str(root.get_meta("material_grade", "")) != "low_glare_enemy_projectile_shape_code":
        push_error("Projectile visual matrix: %s threat shape material grade mismatch." % label)
        quit(1)
        return false
    if str(root.get_meta("hazard_shape_language", "")) != "enemy_projectile_intent_silhouette":
        push_error("Projectile visual matrix: %s threat shape language mismatch." % label)
        quit(1)
        return false
    var expected_shape := _expected_enemy_threat_shape_type(projectile_label)
    if str(root.get_meta("shape_type", "")) != expected_shape:
        push_error("Projectile visual matrix: %s expected shape type %s, got %s." % [label, expected_shape, str(root.get_meta("shape_type", ""))])
        quit(1)
        return false
    var expected_detail := _expected_enemy_threat_shape_detail(projectile_label)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Projectile visual matrix: %s expected threat detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    var anchor := root.get_node_or_null("EnemyProjectileThreatCodeAnchor") as Node3D
    if anchor == null or _count_mesh_instances(anchor) <= 0:
        push_error("Projectile visual matrix: %s threat shape missing anchor mesh." % label)
        quit(1)
        return false
    var detail := root.get_node_or_null(expected_detail) as Node3D
    if detail == null or _count_mesh_instances(detail) <= 0:
        push_error("Projectile visual matrix: %s threat shape missing detail %s." % [label, expected_detail])
        quit(1)
        return false
    var mesh_count := _count_mesh_instances(root)
    if mesh_count < 2 or mesh_count > 7:
        push_error("Projectile visual matrix: %s threat shape mesh budget invalid: %d." % [label, mesh_count])
        quit(1)
        return false
    return true

func _require_enemy_intent_profile(model: Node3D, projectile_label: String, label: String) -> bool:
    var root := model.find_child("EnemyProjectileIntentProfile", true, false) as Node3D
    if root == null:
        push_error("Projectile visual matrix: %s missing EnemyProjectileIntentProfile." % label)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "enemy_hazard":
        push_error("Projectile visual matrix: %s enemy intent missing enemy hazard channel." % label)
        quit(1)
        return false
    if float(root.get_meta("readability_priority", -1.0)) < 0.0:
        push_error("Projectile visual matrix: %s enemy intent missing readability priority." % label)
        quit(1)
        return false
    if str(root.get_meta("intent_type", "")) == "":
        push_error("Projectile visual matrix: %s enemy intent missing intent_type metadata." % label)
        quit(1)
        return false
    var expected_detail := _expected_enemy_intent_detail(projectile_label)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Projectile visual matrix: %s enemy intent expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    var required_children := [
        "EnemyProjectileIntentFrame",
        "EnemyProjectileIntentCore",
        expected_detail
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s enemy intent missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s enemy intent child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 5:
        push_error("Projectile visual matrix: %s enemy intent looks underbuilt." % label)
        quit(1)
        return false
    return true

func _expected_enemy_intent_detail(label: String) -> String:
    match label:
        "A", "void_spit":
            return "EnemyProjectileIntentAcidDrops"
        "E":
            return "EnemyProjectileIntentEyeFocus"
        "C":
            return "EnemyProjectileIntentCrystalArray"
        "R", "X":
            return "EnemyProjectileIntentBurrowLance"
        "Q":
            return "EnemyProjectileIntentRuptureMaw"
        "V":
            return "EnemyProjectileIntentDisintegrationRay"
        "B":
            return "EnemyProjectileIntentRoyalBlade"
        "F":
            return "EnemyProjectileIntentSplitSpore"
        "S":
            return "EnemyProjectileIntentSwarmSeed"
        "T":
            return "EnemyProjectileIntentTrapSpore"
        "U":
            return "EnemyProjectileIntentVoidOrb"
        _:
            return "EnemyProjectileIntentMinorBolt"

func _expected_enemy_threat_tier(label: String) -> String:
    match label:
        "Q", "V", "X", "B":
            return "boss"
        "E", "C", "R", "U", "S":
            return "special"
        "A", "F", "T":
            return "hazard"
        _:
            return ""

func _expected_enemy_threat_shape_type(label: String) -> String:
    match label:
        "A", "void_spit":
            return "acid_spit"
        "E":
            return "void_eye_focus"
        "C":
            return "crystal_shard"
        "R", "X":
            return "burrow_lance"
        "Q":
            return "rupture_maw"
        "V":
            return "disintegration_ray"
        "B":
            return "royal_blade"
        "F":
            return "split_spore"
        "S":
            return "swarm_seed"
        "T":
            return "trap_spore"
        "U":
            return "void_orb"
        _:
            return "minor_bolt"

func _expected_enemy_threat_shape_detail(label: String) -> String:
    match _expected_enemy_threat_shape_type(label):
        "acid_spit":
            return "EnemyProjectileThreatCodeAcidDrops"
        "void_eye_focus":
            return "EnemyProjectileThreatCodeEyeFocus"
        "crystal_shard":
            return "EnemyProjectileThreatCodeCrystalShard"
        "burrow_lance":
            return "EnemyProjectileThreatCodeBurrowLance"
        "rupture_maw":
            return "EnemyProjectileThreatCodeRuptureMaw"
        "disintegration_ray":
            return "EnemyProjectileThreatCodeDisintegrationRay"
        "royal_blade":
            return "EnemyProjectileThreatCodeRoyalBlade"
        "split_spore":
            return "EnemyProjectileThreatCodeSplitSpore"
        "swarm_seed":
            return "EnemyProjectileThreatCodeSwarmSeed"
        "trap_spore":
            return "EnemyProjectileThreatCodeTrapSpore"
        "void_orb":
            return "EnemyProjectileThreatCodeVoidOrb"
        _:
            return "EnemyProjectileThreatCodeMinorBolt"

func _require_player_path_signature(model: Node3D, label: String) -> bool:
    var root := model.find_child("PlayerProjectilePathSignature", true, false) as Node3D
    if root == null:
        push_error("Projectile visual matrix: %s missing PlayerProjectilePathSignature." % label)
        quit(1)
        return false
    if str(root.get_meta("family", "")) == "":
        push_error("Projectile visual matrix: %s path signature missing family metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "player_skill":
        push_error("Projectile visual matrix: %s path signature missing player skill channel." % label)
        quit(1)
        return false
    var required_children := [
        "PlayerProjectileLaneRibbon",
        "PlayerProjectileImpactMark",
        "PlayerProjectileRoleGlyph"
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s path child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 4:
        push_error("Projectile visual matrix: %s path signature looks underbuilt." % label)
        quit(1)
        return false
    return true

func _require_player_role_profile(model: Node3D, projectile_label: String, label: String) -> bool:
    var root := model.find_child("PlayerProjectileRoleProfile", true, false) as Node3D
    if root == null:
        push_error("Projectile visual matrix: %s missing PlayerProjectileRoleProfile." % label)
        quit(1)
        return false
    var family := str(root.get_meta("family", ""))
    if family == "":
        push_error("Projectile visual matrix: %s role profile missing family metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("role", "")) == "":
        push_error("Projectile visual matrix: %s role profile missing role metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("source_champion", "")) == "":
        push_error("Projectile visual matrix: %s role profile missing source champion metadata." % label)
        quit(1)
        return false
    var expected_detail := _expected_role_profile_detail(projectile_label)
    if root.get_node_or_null(expected_detail) == null:
        push_error("Projectile visual matrix: %s role profile missing %s." % [label, expected_detail])
        quit(1)
        return false
    var required_children := [
        "PlayerProjectileRoleProfileRing",
        "PlayerProjectileClassPlate",
        expected_detail
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s role profile missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s role profile child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 5:
        push_error("Projectile visual matrix: %s role profile looks underbuilt." % label)
        quit(1)
        return false
    return true

func _expected_role_profile_detail(label: String) -> String:
    match label:
        "fishbones", "death_rocket":
            return "PlayerProjectileProfileRocketArtillery"
        "senna":
            return "PlayerProjectileProfileSoulPiercer"
        "samira":
            return "PlayerProjectileProfileDuelistBlades"
        "viktor":
            return "PlayerProjectileProfileHexcoreCircuit"
        "xayah":
            return "PlayerProjectileProfileFeatherRecall"
        "teemo":
            return "PlayerProjectileProfilePoisonTrap"
        "comet":
            return "PlayerProjectileProfileStarForge"
        "morde":
            return "PlayerProjectileProfileJuggernautSlam"
        _:
            return "PlayerProjectileProfileGeneric"

func _require_player_impact_intent_profile(model: Node3D, projectile_label: String, label: String) -> bool:
    var root := model.find_child("PlayerProjectileImpactIntentProfile", true, false) as Node3D
    if root == null:
        push_error("Projectile visual matrix: %s missing PlayerProjectileImpactIntentProfile." % label)
        quit(1)
        return false
    var family := str(root.get_meta("family", ""))
    if family == "":
        push_error("Projectile visual matrix: %s impact intent missing family metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("source_champion", "")) == "":
        push_error("Projectile visual matrix: %s impact intent missing source champion metadata." % label)
        quit(1)
        return false
    var expected_detail := _expected_impact_intent_detail(projectile_label)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Projectile visual matrix: %s impact intent expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    var required_children := [
        "PlayerProjectileImpactIntentFrame",
        "PlayerProjectileImpactIntentCore",
        expected_detail
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s impact intent missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s impact intent child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 4:
        push_error("Projectile visual matrix: %s impact intent looks underbuilt." % label)
        quit(1)
        return false
    return true

func _expected_impact_intent_detail(label: String) -> String:
    match label:
        "fishbones", "death_rocket":
            return "PlayerProjectileImpactRocketBurst"
        "senna":
            return "PlayerProjectileImpactSoulPierce"
        "samira":
            return "PlayerProjectileImpactDuelistCut"
        "viktor":
            return "PlayerProjectileImpactHexcoreBurn"
        "xayah":
            return "PlayerProjectileImpactFeatherRecall"
        "teemo":
            return "PlayerProjectileImpactPoisonBloom"
        "comet":
            return "PlayerProjectileImpactStarFall"
        "morde":
            return "PlayerProjectileImpactIronCrush"
        _:
            return "PlayerProjectileImpactGeneric"

func _require_player_spell_trail_profile(model: Node3D, projectile_label: String, label: String) -> bool:
    var root := model.find_child("PlayerProjectileSpellTrailProfile", true, false) as Node3D
    if root == null:
        push_error("Projectile visual matrix: %s missing PlayerProjectileSpellTrailProfile." % label)
        quit(1)
        return false
    var family := str(root.get_meta("family", ""))
    if family == "":
        push_error("Projectile visual matrix: %s spell trail missing family metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("source_champion", "")) == "":
        push_error("Projectile visual matrix: %s spell trail missing source champion metadata." % label)
        quit(1)
        return false
    var expected_detail := _expected_spell_trail_detail(projectile_label)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Projectile visual matrix: %s spell trail expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    var required_children := [
        "PlayerProjectileTrailSpine",
        "PlayerProjectileTrailBloom",
        expected_detail
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s spell trail missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s spell trail child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 3:
        push_error("Projectile visual matrix: %s spell trail looks underbuilt." % label)
        quit(1)
        return false
    return true

func _expected_spell_trail_detail(label: String) -> String:
    match label:
        "fishbones", "death_rocket":
            return "PlayerProjectileTrailRocketExhaust"
        "senna":
            return "PlayerProjectileTrailSoulBeam"
        "samira":
            return "PlayerProjectileTrailDuelistSlice"
        "viktor":
            return "PlayerProjectileTrailHexCircuit"
        "xayah":
            return "PlayerProjectileTrailFeatherReturn"
        "teemo":
            return "PlayerProjectileTrailPoisonSpores"
        "comet":
            return "PlayerProjectileTrailStarWake"
        "morde":
            return "PlayerProjectileTrailIronWake"
        _:
            return "PlayerProjectileTrailGeneric"

func _require_player_premium_fx_rig(model: Node3D, projectile_label: String, label: String) -> bool:
    var root := model.find_child("PlayerProjectilePremiumFxRig", true, false) as Node3D
    if root == null:
        push_error("Projectile visual matrix: %s missing PlayerProjectilePremiumFxRig." % label)
        quit(1)
        return false
    var family := str(root.get_meta("family", ""))
    if family == "":
        push_error("Projectile visual matrix: %s premium FX missing family metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("source_champion", "")) == "":
        push_error("Projectile visual matrix: %s premium FX missing source champion metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("material_grade", "")) != "premium_projectile_fx":
        push_error("Projectile visual matrix: %s premium FX missing material grade." % label)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "player_skill":
        push_error("Projectile visual matrix: %s premium FX missing player skill channel." % label)
        quit(1)
        return false
    var expected_detail := _expected_premium_fx_detail(projectile_label)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Projectile visual matrix: %s premium FX expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    var required_children := [
        "PlayerProjectilePremiumCoreShell",
        "PlayerProjectilePremiumEnergyRim",
        "PlayerProjectilePremiumMaterialBands",
        expected_detail
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s premium FX missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s premium FX child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 8:
        push_error("Projectile visual matrix: %s premium FX looks underbuilt." % label)
        quit(1)
        return false
    return true

func _expected_premium_fx_detail(label: String) -> String:
    match label:
        "fishbones", "death_rocket":
            return "PlayerProjectilePremiumRocketWarhead"
        "senna":
            return "PlayerProjectilePremiumSoulFocusLens"
        "samira":
            return "PlayerProjectilePremiumDuelistEdge"
        "viktor":
            return "PlayerProjectilePremiumHexcorePrism"
        "xayah":
            return "PlayerProjectilePremiumFeatherInlay"
        "teemo":
            return "PlayerProjectilePremiumPoisonVial"
        "comet":
            return "PlayerProjectilePremiumStarCore"
        "morde":
            return "PlayerProjectilePremiumIronHead"
        _:
            return "PlayerProjectilePremiumGenericHead"

func _require_champion_projectile_mechanic_silhouette(model: Node3D, projectile_label: String, label: String) -> bool:
    var root := model.find_child("ChampionProjectileMechanicSilhouetteRig", true, false) as Node3D
    if root == null:
        push_error("Projectile visual matrix: %s missing ChampionProjectileMechanicSilhouetteRig." % label)
        quit(1)
        return false
    var family := str(root.get_meta("family", ""))
    if family == "":
        push_error("Projectile visual matrix: %s mechanic silhouette missing family metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("source_champion", "")) == "":
        push_error("Projectile visual matrix: %s mechanic silhouette missing source champion metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "player_projectile_mechanic_readability":
        push_error("Projectile visual matrix: %s mechanic silhouette has wrong combat channel." % label)
        quit(1)
        return false
    if str(root.get_meta("material_grade", "")) != "low_glare_champion_projectile_mechanic":
        push_error("Projectile visual matrix: %s mechanic silhouette missing low-glare grade." % label)
        quit(1)
        return false
    if str(root.get_meta("role_profile", "")) == "":
        push_error("Projectile visual matrix: %s mechanic silhouette missing role profile." % label)
        quit(1)
        return false
    if not bool(root.get_meta("non_lite_only", false)):
        push_error("Projectile visual matrix: %s mechanic silhouette should be marked non-lite only." % label)
        quit(1)
        return false
    var expected_detail := _expected_mechanic_silhouette_detail(projectile_label)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Projectile visual matrix: %s mechanic silhouette expected detail metadata %s." % [label, expected_detail])
        quit(1)
        return false
    var required_children := [
        "ChampionProjectileMechanicShadowPlate",
        "ChampionProjectileMechanicDirectionRail",
        "ChampionProjectileMechanicImpactAnchor",
        expected_detail
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Projectile visual matrix: %s mechanic silhouette missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Projectile visual matrix: %s mechanic silhouette child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 4:
        push_error("Projectile visual matrix: %s mechanic silhouette looks underbuilt." % label)
        quit(1)
        return false
    return true

func _expected_mechanic_silhouette_detail(label: String) -> String:
    match label:
        "fishbones", "death_rocket":
            return "ChampionProjectileMechanicJinxRocketRack"
        "senna":
            return "ChampionProjectileMechanicSennaRelicBeam"
        "samira":
            return "ChampionProjectileMechanicSamiraBladeArc"
        "viktor":
            return "ChampionProjectileMechanicViktorLaserCircuit"
        "xayah":
            return "ChampionProjectileMechanicXayahFeatherRecall"
        "teemo":
            return "ChampionProjectileMechanicTeemoPoisonDart"
        "comet":
            return "ChampionProjectileMechanicAsolOrbitComet"
        "morde":
            return "ChampionProjectileMechanicMordeIronWake"
        _:
            return "ChampionProjectileMechanicGenericSpell"

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count
