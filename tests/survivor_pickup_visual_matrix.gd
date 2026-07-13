extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    await process_frame

    var cases := [
        {"label": "small_xp", "kind": "xp", "amount": 3, "color": Color(0.42, 1.0, 0.45), "lite": false, "premium": false, "channel": "pickup_xp"},
        {"label": "big_xp", "kind": "xp", "amount": 12, "color": Color(0.52, 0.95, 1.0), "lite": false, "premium": true, "channel": "pickup_reward"},
        {"label": "gold_cache", "kind": "gold", "amount": 14, "color": Color(1.0, 0.76, 0.20), "lite": false, "premium": true, "channel": "pickup_reward"},
        {"label": "heal_cache", "kind": "heal", "amount": 1, "color": Color(1.0, 0.28, 0.34), "lite": false, "premium": true, "channel": "pickup_reward"},
        {"label": "shield_cache", "kind": "shield", "amount": 2, "color": Color(0.64, 0.94, 1.0), "lite": false, "premium": true, "channel": "pickup_reward"},
        {"label": "dense_lite_xp", "kind": "xp", "amount": 5, "color": Color(0.42, 1.0, 0.45), "lite": true, "premium": false, "channel": "pickup_xp_lite"}
    ]

    var total_meshes := 0
    for case in cases:
        var label := str(case["label"])
        var model: Node3D = view.call(
            "_create_pickup_model",
            str(case["kind"]),
            case["color"],
            int(case["amount"]),
            bool(case["lite"])
        )
        view.add_child(model)
        await process_frame
        if not _require_channel(model, str(case["channel"]), label):
            return
        if not _require_pickup_semantic_stratum(model, label):
            return
        if not _require_node(model, "PickupCollectibleBackplate", label):
            return
        if not _require_child_channel(model, "PickupCollectibleBackplate", str(case["channel"]), label):
            return
        if not _forbid_enemy_hazard_channel(model, label):
            return

        if bool(case["lite"]):
            if not _require_node(model, "LitePickupCore", label):
                return
            if not _require_child_channel(model, "LitePickupCore", "pickup_xp_lite", label):
                return
            if not _require_material_budget(model, label, 0.06, 0.18):
                return
            if not _forbid_node(model, "PickupPremiumIconPlate", label):
                return
            if not _forbid_node(model, "PickupRewardBeacon", label):
                return
            if not _forbid_node(model, "PickupTreasureCrest", label):
                return
            if not _forbid_node(model, "PickupFacetSilhouetteRig", label):
                return
        elif bool(case["premium"]):
            var required := [
                "PickupPremiumIconPlate",
                "PickupRewardBeacon",
                "PickupTreasureCrest",
                "PickupTreasureCrown",
                "PickupTreasureFacet",
                "PickupFacetSilhouetteRig",
                "PickupFacetPrimarySilhouette",
                "PickupFacetRoleInlay",
                "PickupFacetRewardFrame",
                "PickupHoverGlyph",
                "PickupValueHalo"
            ]
            for node_name in required:
                if not _require_node(model, str(node_name), label):
                    return
            for channel_node_name in ["PickupPremiumIconPlate", "PickupRewardBeacon", "PickupTreasureCrest", "PickupValueHalo"]:
                if not _require_child_channel(model, str(channel_node_name), "pickup_reward", label):
                    return
            if not _require_pickup_facet_silhouette(model, str(case["kind"]), int(case["amount"]), str(case["channel"]), label, true):
                return
            if not _require_material_budget(model, label, 0.06, 0.18):
                return
            if _count_mesh_instances(model) < 9:
                push_error("Pickup visual matrix: %s looks underbuilt." % label)
                quit(1)
                return
        else:
            if not _forbid_node(model, "PickupPremiumIconPlate", label):
                return
            if not _forbid_node(model, "PickupRewardBeacon", label):
                return
            if not _forbid_node(model, "PickupTreasureCrest", label):
                return
            if not _forbid_node(model, "LitePickupCore", label):
                return
            if not _forbid_node(model, "PickupFacetSilhouetteRig", label):
                return
            if not _require_material_budget(model, label, 0.06, 0.18):
                return

        total_meshes += _count_mesh_instances(model)
        model.queue_free()
        await process_frame

    if not bool(view.call("_should_use_lite_pickup", "xp", 5, 140)):
        push_error("Pickup visual matrix expected dense low XP to use lite LOD.")
        quit(1)
        return
    if bool(view.call("_should_use_lite_pickup", "xp", 12, 140)):
        push_error("Pickup visual matrix expected high-value XP to keep full visuals.")
        quit(1)
        return
    if bool(view.call("_should_use_lite_pickup", "gold", 14, 140)):
        push_error("Pickup visual matrix expected gold caches to keep full visuals.")
        quit(1)
        return

    print("SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=%d meshes=%d" % [cases.size(), total_meshes])
    quit(0)

func _require_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) == null:
        push_error("Pickup visual matrix: %s missing %s." % [label, node_name])
        quit(1)
        return false
    return true

func _forbid_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) != null:
        push_error("Pickup visual matrix: %s should not include %s." % [label, node_name])
        quit(1)
        return false
    return true

func _require_channel(model: Node3D, expected_channel: String, label: String) -> bool:
    var channel := str(model.get_meta("combat_visual_channel", ""))
    if channel != expected_channel:
        push_error("Pickup visual matrix: %s expected channel %s, got %s." % [label, expected_channel, channel])
        quit(1)
        return false
    return true

func _require_pickup_semantic_stratum(model: Node3D, label: String) -> bool:
    if str(model.get_meta("visual_stratum", "")) != "pickup_collectible":
        push_error("Pickup visual matrix: %s expected pickup_collectible visual stratum." % label)
        quit(1)
        return false
    if not bool(model.get_meta("pickup_confusion_safe", false)):
        push_error("Pickup visual matrix: %s missing pickup confusion safe metadata." % label)
        quit(1)
        return false
    if bool(model.get_meta("enemy_hazard_language", true)):
        push_error("Pickup visual matrix: %s incorrectly uses enemy hazard language." % label)
        quit(1)
        return false
    if float(model.get_meta("readability_priority", -1.0)) < 0.0:
        push_error("Pickup visual matrix: %s missing readability priority." % label)
        quit(1)
        return false
    var backplate := model.find_child("PickupCollectibleBackplate", true, false) as Node3D
    if backplate == null:
        push_error("Pickup visual matrix: %s missing collectible backplate for stratum check." % label)
        quit(1)
        return false
    if str(backplate.get_meta("visual_stratum", "")) != "pickup_collectible_floor":
        push_error("Pickup visual matrix: %s expected collectible floor backplate stratum." % label)
        quit(1)
        return false
    if str(backplate.get_meta("material_grade", "")) != "low_glare_pickup_stratum":
        push_error("Pickup visual matrix: %s expected low glare pickup stratum material grade." % label)
        quit(1)
        return false
    if not bool(backplate.get_meta("pickup_confusion_safe", false)):
        push_error("Pickup visual matrix: %s backplate missing pickup confusion safe metadata." % label)
        quit(1)
        return false
    return true

func _forbid_enemy_hazard_channel(node: Node, label: String) -> bool:
    if node.has_meta("combat_visual_channel") and str(node.get_meta("combat_visual_channel", "")).begins_with("enemy_hazard"):
        push_error("Pickup visual matrix: %s leaked enemy_hazard channel at %s." % [label, node.name])
        quit(1)
        return false
    if node.has_meta("enemy_hazard_language") and bool(node.get_meta("enemy_hazard_language", false)):
        push_error("Pickup visual matrix: %s leaked enemy hazard language at %s." % [label, node.name])
        quit(1)
        return false
    for child in node.get_children():
        if not _forbid_enemy_hazard_channel(child, label):
            return false
    return true

func _require_pickup_facet_silhouette(model: Node3D, kind: String, amount: int, expected_channel: String, label: String, premium: bool) -> bool:
    var rig := model.find_child("PickupFacetSilhouetteRig", true, false) as Node3D
    if rig == null:
        push_error("Pickup visual matrix: %s missing PickupFacetSilhouetteRig." % label)
        quit(1)
        return false
    if str(rig.get_meta("combat_visual_channel", "")) != expected_channel:
        push_error("Pickup visual matrix: %s facet rig expected channel %s, got %s." % [label, expected_channel, str(rig.get_meta("combat_visual_channel", ""))])
        quit(1)
        return false
    if str(rig.get_meta("visual_stratum", "")) != "pickup_collectible_facet":
        push_error("Pickup visual matrix: %s facet rig missing collectible facet stratum." % label)
        quit(1)
        return false
    if str(rig.get_meta("material_grade", "")) != "low_glare_pickup_facet_silhouette":
        push_error("Pickup visual matrix: %s facet rig material grade mismatch." % label)
        quit(1)
        return false
    if not bool(rig.get_meta("pickup_confusion_safe", false)) or bool(rig.get_meta("enemy_hazard_language", true)):
        push_error("Pickup visual matrix: %s facet rig pickup/enemy metadata invalid." % label)
        quit(1)
        return false
    if str(rig.get_meta("reward_facet_language", "")) != _expected_pickup_facet_language(kind, amount):
        push_error("Pickup visual matrix: %s facet language mismatch." % label)
        quit(1)
        return false
    for child_name in [
        "PickupFacetBaseShadow",
        "PickupFacetPrimarySilhouette",
        "PickupFacetSpecularCut",
        "PickupFacetRoleInlay"
    ]:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Pickup visual matrix: %s facet rig missing %s." % [label, child_name])
            quit(1)
            return false
        if str(child.get_meta("combat_visual_channel", "")) != expected_channel:
            push_error("Pickup visual matrix: %s facet child %s channel mismatch." % [label, child_name])
            quit(1)
            return false
        if not bool(child.get_meta("pickup_confusion_safe", false)) or bool(child.get_meta("enemy_hazard_language", true)):
            push_error("Pickup visual matrix: %s facet child %s pickup/enemy metadata invalid." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Pickup visual matrix: %s facet child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    var reward_frame := rig.get_node_or_null("PickupFacetRewardFrame") as Node3D
    if premium and reward_frame == null:
        push_error("Pickup visual matrix: %s premium facet rig missing reward frame." % label)
        quit(1)
        return false
    if not premium and reward_frame != null:
        push_error("Pickup visual matrix: %s non-premium facet rig should not include reward frame." % label)
        quit(1)
        return false
    if premium and _count_named_prefix(rig, "PickupFacetRewardPip") < 3:
        push_error("Pickup visual matrix: %s premium facet rig missing reward pips." % label)
        quit(1)
        return false
    var mesh_count := _count_mesh_instances(rig)
    if mesh_count < (8 if premium else 4):
        push_error("Pickup visual matrix: %s facet rig looks underbuilt: %d." % [label, mesh_count])
        quit(1)
        return false
    if not _require_material_budget(rig, "%s facet rig" % label, 0.06, 0.18):
        return false
    return true

func _expected_pickup_facet_language(kind: String, amount: int) -> String:
    match kind:
        "gold":
            return "hextech_coin_stamp"
        "heal":
            return "red_life_crystal"
        "shield":
            return "blue_hex_shield"
        _:
            return "xp_crystal_facet_reward" if amount >= 12 else "xp_crystal_facet"

func _count_named_prefix(node: Node, prefix: String) -> int:
    var count := 1 if str(node.name).begins_with(prefix) else 0
    for child in node.get_children():
        count += _count_named_prefix(child, prefix)
    return count

func _require_child_channel(model: Node3D, node_name: String, expected_channel: String, label: String) -> bool:
    var node := model.find_child(node_name, true, false)
    if node == null:
        push_error("Pickup visual matrix: %s missing %s for channel check." % [label, node_name])
        quit(1)
        return false
    var channel := str(node.get_meta("combat_visual_channel", ""))
    if channel != expected_channel:
        push_error("Pickup visual matrix: %s expected %s channel %s, got %s." % [label, node_name, expected_channel, channel])
        quit(1)
        return false
    return true

func _require_material_budget(node: Node, label: String, max_emission: float, max_transparent_alpha: float) -> bool:
    if node is MeshInstance3D:
        var mesh_instance := node as MeshInstance3D
        var mat := mesh_instance.material_override as StandardMaterial3D
        if mat != null:
            if mat.emission_enabled and mat.emission_energy_multiplier > max_emission:
                push_error("Pickup visual matrix: %s material %s emission too bright: %.2f." % [label, node.name, mat.emission_energy_multiplier])
                quit(1)
                return false
            if mat.albedo_color.a < 0.99 and mat.albedo_color.a > max_transparent_alpha:
                push_error("Pickup visual matrix: %s material %s transparent alpha too high: %.2f." % [label, node.name, mat.albedo_color.a])
                quit(1)
                return false
    for child in node.get_children():
        if not _require_material_budget(child, label, max_emission, max_transparent_alpha):
            return false
    return true

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count
