extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const PlayerScript := preload("res://scripts/survivor_player.gd")
const ABILITY_EMBLEM_ATLAS := "res://art/textures/champion_ability_emblem_atlas_v1.png"
const MIN_ABILITY_ATLAS_SIZE := Vector2i(1200, 800)

const CHAMPIONS := [
    "jinx",
    "senna",
    "samira",
    "viktor",
    "xayah",
    "mordekaiser",
    "teemo",
    "aurelion_sol"
]

const REQUIRED_VISUAL_NODES := [
    "ChampionIdentityBackplateRig",
    "ChampionIdentityProjection",
    "ChampionFanSignature",
    "ChampionFanReadableSilhouetteRig",
    "ChampionSignatureWeaponRig",
    "ChampionPremiumBodyRig",
    "ChampionPainterlyDepthRig",
    "ChampionKitSilhouette",
    "ChampionCombatStanceRig",
    "ChampionArchetypeSilhouetteRig",
    "ChampionAbilityEmblems",
    "ChampionMechanicMeter",
    "ChampionCombatLoopReadout",
    "ChampionHumanFocusPlate",
    "ChampionLiveAura",
    "ChampionAttackBurst",
    "ChampionSignatureCastRig",
    "GroundedContactShadow",
    "GroundedContactCore",
    "PlayerStatusRings",
    "Recipes",
    "Items",
    "ChampionUpgradeRoutes",
    "RoleRouteRings"
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var atlas_image := Image.new()
    var atlas_err := atlas_image.load(ABILITY_EMBLEM_ATLAS)
    if atlas_err != OK:
        push_error("Champion visual matrix could not load ability emblem atlas.")
        quit(1)
        return
    if atlas_image.get_width() < MIN_ABILITY_ATLAS_SIZE.x or atlas_image.get_height() < MIN_ABILITY_ATLAS_SIZE.y:
        push_error("Champion ability emblem atlas too small: %dx%d." % [atlas_image.get_width(), atlas_image.get_height()])
        quit(1)
        return

    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    var total_meshes := 0
    for champion in CHAMPIONS:
        var model: Node3D = view.call("_create_player_model", champion)
        if model == null:
            push_error("Champion visual matrix could not create model for %s." % champion)
            quit(1)
            return
        model.name = "ChampionMatrix_" + champion
        view.add_child(model)
        await process_frame

        for node_name in REQUIRED_VISUAL_NODES:
            if model.find_child(node_name, true, false) == null:
                push_error("Champion %s missing required visual node %s." % [champion, node_name])
                quit(1)
                return

        var fan_signature := model.find_child("ChampionFanSignature", true, false)
        if fan_signature == null or _count_mesh_instances(fan_signature) <= 0:
            push_error("Champion %s fan signature has no mesh content." % champion)
            quit(1)
            return
        if not _require_identity_backplate(model, champion):
            return
        if not await _require_premium_body_rig(view, model, champion):
            return
        if not _require_painterly_depth_rig(model, champion):
            return
        if not _require_kit_silhouette(model, champion):
            return
        if not _require_fan_readable_silhouette_rig(model, champion):
            return
        if not await _require_signature_weapon_rig(view, model, champion):
            return
        if not await _require_combat_stance_rig(view, model, champion):
            return
        if not await _require_archetype_silhouette_rig(view, model, champion):
            return
        if not _require_ability_emblems(model, champion):
            return
        if not _require_mechanic_meter(model, champion):
            return
        if not await _require_combat_loop_readout(view, model, champion):
            return
        if not await _require_human_focus_plate(view, model, champion):
            return
        if not await _require_signature_cast_rig(view, model, champion):
            return

        var champion_meshes := _count_mesh_instances(model)
        if champion_meshes < 28:
            push_error("Champion %s model looks underbuilt: only %d meshes." % [champion, champion_meshes])
            quit(1)
            return
        if champion == "jinx" and not await _require_recipe_ring(view, model):
            return
        total_meshes += champion_meshes
        model.queue_free()
        await process_frame

    print("SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=%d meshes=%d ability_atlas=%dx%d archetype=role_silhouette" % [CHAMPIONS.size(), total_meshes, atlas_image.get_width(), atlas_image.get_height()])
    quit(0)

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count

func _require_identity_backplate(model: Node3D, champion: String) -> bool:
    var root := model.find_child("ChampionIdentityBackplateRig", true, false) as Node3D
    if root == null:
        push_error("Champion %s missing identity backplate rig." % champion)
        quit(1)
        return false
    if str(root.get_meta("champion", "")) != champion:
        push_error("Champion %s identity backplate champion metadata mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("kit_role", "")) == "" or str(root.get_meta("combat_class", "")) == "":
        push_error("Champion %s identity backplate missing role/class metadata." % champion)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "champion_readability":
        push_error("Champion %s identity backplate has wrong visual channel." % champion)
        quit(1)
        return false
    for child_name in [
        "ChampionIdentityMatteBackplate",
        "ChampionIdentityRoleFrame",
        "ChampionIdentityFacingChevron",
        "ChampionIdentityRangePips",
        "ChampionIdentityChampionMotif"
    ]:
        var child := root.get_node_or_null(child_name)
        if child == null:
            push_error("Champion %s identity backplate missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s identity backplate child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if _count_named_children(root.get_node_or_null("ChampionIdentityRangePips"), "ChampionIdentityRangePip") < 2:
        push_error("Champion %s identity backplate missing range pips." % champion)
        quit(1)
        return false
    if not _require_backplate_low_glare(root, champion):
        return false
    return true

func _count_named_children(node: Node, prefix: String) -> int:
    if node == null:
        return 0
    var count := 0
    for child in node.get_children():
        if str(child.name).begins_with(prefix):
            count += 1
    return count

func _count_named_descendants(node: Node, prefix: String) -> int:
    if node == null:
        return 0
    var count := 0
    for child in node.get_children():
        if str(child.name).begins_with(prefix):
            count += 1
        count += _count_named_descendants(child, prefix)
    return count

func _require_backplate_low_glare(node: Node, champion: String) -> bool:
    if node is MeshInstance3D:
        var mesh_instance := node as MeshInstance3D
        if mesh_instance.material_override is StandardMaterial3D:
            var mat := mesh_instance.material_override as StandardMaterial3D
            if mat.emission_enabled:
                push_error("Champion %s identity backplate should not use emissive material on %s." % [champion, node.name])
                quit(1)
                return false
            if mat.albedo_color.a > 0.36:
                push_error("Champion %s identity backplate alpha too high on %s: %.2f." % [champion, node.name, mat.albedo_color.a])
                quit(1)
                return false
    for child in node.get_children():
        if not _require_backplate_low_glare(child, champion):
            return false
    return true

func _require_ability_emblems(model: Node3D, champion: String) -> bool:
    var root := model.find_child("ChampionAbilityEmblems", true, false) as Node3D
    if root == null:
        push_error("Champion %s missing ability emblem root." % champion)
        quit(1)
        return false
    var emblem_count := 0
    var texture_count := 0
    for child in root.get_children():
        if child.has_meta("ability_emblem"):
            emblem_count += 1
            var icon := child.get_node_or_null("AbilityIconTexture") as MeshInstance3D
            if icon != null and icon.material_override is StandardMaterial3D:
                var mat := icon.material_override as StandardMaterial3D
                if mat.albedo_texture != null:
                    texture_count += 1
    if emblem_count < 3:
        push_error("Champion %s expected 3 ability emblems, got %d." % [champion, emblem_count])
        quit(1)
        return false
    if texture_count < 3:
        push_error("Champion %s expected 3 atlas-backed ability icons, got %d." % [champion, texture_count])
        quit(1)
        return false
    return true

func _require_kit_silhouette(model: Node3D, champion: String) -> bool:
    var root := model.find_child("ChampionKitSilhouette", true, false) as Node3D
    if root == null:
        push_error("Champion %s missing kit silhouette root." % champion)
        quit(1)
        return false
    var role := str(root.get_meta("kit_role", ""))
    if role == "":
        push_error("Champion %s kit silhouette missing role metadata." % champion)
        quit(1)
        return false
    var required_children := [
        "ChampionKitRolePlate",
        "ChampionKitWeaponIcon",
        "ChampionKitPassiveMotif"
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s kit silhouette missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s kit silhouette child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    var weapon := root.get_node_or_null("ChampionKitWeaponIcon") as Node3D
    if weapon == null or str(weapon.get_meta("weapon_signature", "")) != champion:
        push_error("Champion %s kit weapon signature metadata mismatch." % champion)
        quit(1)
        return false
    if _count_mesh_instances(root) < 12:
        push_error("Champion %s kit silhouette looks underbuilt." % champion)
        quit(1)
        return false
    return true

func _require_fan_readable_silhouette_rig(model: Node3D, champion: String) -> bool:
    var root := model.find_child("ChampionFanReadableSilhouetteRig", true, false) as Node3D
    if root == null:
        push_error("Champion %s missing fan readable silhouette rig." % champion)
        quit(1)
        return false
    if str(root.get_meta("champion", "")) != champion:
        push_error("Champion %s fan readable silhouette champion metadata mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "champion_readability":
        push_error("Champion %s fan readable silhouette has wrong visual channel." % champion)
        quit(1)
        return false
    if str(root.get_meta("material_grade", "")) != "low_glare_fan_readable_silhouette":
        push_error("Champion %s fan readable silhouette material grade mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("silhouette_signature", "")) == "":
        push_error("Champion %s fan readable silhouette missing signature metadata." % champion)
        quit(1)
        return false
    for child_name in [
        "ChampionFanReadableShadowPlate",
        "ChampionFanReadableRoleAnchor",
        "ChampionFanReadableFacingShard",
        "ChampionFanReadableSignatureDetail"
    ]:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s fan readable silhouette missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s fan readable silhouette child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    var expected_detail := _expected_fan_readable_detail(champion)
    if root.find_child(expected_detail, true, false) == null:
        push_error("Champion %s fan readable silhouette missing expected detail %s." % [champion, expected_detail])
        quit(1)
        return false
    if _count_mesh_instances(root) < 7:
        push_error("Champion %s fan readable silhouette looks underbuilt." % champion)
        quit(1)
        return false
    if not _require_material_budget(root, "Champion %s fan readable silhouette" % champion, 0.02, 0.36):
        return false
    return true

func _expected_fan_readable_detail(champion: String) -> String:
    match champion:
        "jinx":
            return "FanReadableJinxTwinRockets"
        "senna":
            return "FanReadableSennaRelicCannon"
        "samira":
            return "FanReadableSamiraBladePistolCross"
        "viktor":
            return "FanReadableViktorHexcoreSpine"
        "xayah":
            return "FanReadableXayahFeatherFan"
        "mordekaiser":
            return "FanReadableMordeIronMace"
        "teemo":
            return "FanReadableTeemoScoutMushroom"
        "aurelion_sol":
            return "FanReadableAsolCelestialOrbit"
        _:
            return "FanReadableGenericChampion"

func _require_signature_weapon_rig(view, model: Node3D, champion: String) -> bool:
    var root := model.find_child("ChampionSignatureWeaponRig", true, false) as Node3D
    if root == null:
        push_error("Champion %s missing signature weapon rig." % champion)
        quit(1)
        return false
    if str(root.get_meta("champion", "")) != champion:
        push_error("Champion %s signature weapon rig champion metadata mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "champion_model_identity":
        push_error("Champion %s signature weapon rig has wrong visual channel." % champion)
        quit(1)
        return false
    if str(root.get_meta("material_grade", "")) != "low_glare_signature_weapon":
        push_error("Champion %s signature weapon rig material grade mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("weapon_signature", "")) != champion:
        push_error("Champion %s signature weapon rig weapon metadata mismatch." % champion)
        quit(1)
        return false
    var expected_detail := _expected_signature_weapon_detail(champion)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Champion %s signature weapon detail metadata mismatch." % champion)
        quit(1)
        return false
    for child_name in [
        "ChampionSignatureWeaponAnchor",
        expected_detail
    ]:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s signature weapon rig missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s signature weapon child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 6:
        push_error("Champion %s signature weapon rig looks underbuilt." % champion)
        quit(1)
        return false
    if not _require_material_budget(root, "Champion %s signature weapon rig" % champion, 0.04, 0.36):
        return false
    view.call("_sync_champion_signature_weapon_rig", model)
    await process_frame
    if root.scale.x <= 0.0:
        push_error("Champion %s signature weapon rig sync produced invalid scale." % champion)
        quit(1)
        return false
    return true

func _expected_signature_weapon_detail(champion: String) -> String:
    match champion:
        "jinx":
            return "ChampionSignatureWeaponJinxRocketRack"
        "senna":
            return "ChampionSignatureWeaponSennaRelicCannon"
        "samira":
            return "ChampionSignatureWeaponSamiraBladePistol"
        "viktor":
            return "ChampionSignatureWeaponViktorHexClaw"
        "xayah":
            return "ChampionSignatureWeaponXayahFeatherFan"
        "mordekaiser":
            return "ChampionSignatureWeaponMordeNightfall"
        "teemo":
            return "ChampionSignatureWeaponTeemoScoutKit"
        "aurelion_sol":
            return "ChampionSignatureWeaponAsolStarCrown"
        _:
            return "ChampionSignatureWeaponGeneric"

func _require_premium_body_rig(view, model: Node3D, champion: String) -> bool:
    var root := model.find_child("ChampionPremiumBodyRig", true, false) as Node3D
    if root == null:
        push_error("Champion %s missing premium body rig." % champion)
        quit(1)
        return false
    if str(root.get_meta("champion", "")) != champion:
        push_error("Champion %s premium body rig champion metadata mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("silhouette_family", "")) != _expected_premium_family(champion):
        push_error("Champion %s premium body rig silhouette family mismatch." % champion)
        quit(1)
        return false
    var expected_detail := _expected_premium_detail(champion)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Champion %s premium body rig detail metadata mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("material_grade", "")) != "premium_fan_3d":
        push_error("Champion %s premium body rig missing material grade metadata." % champion)
        quit(1)
        return false
    for child_name in [
        "ChampionPremiumArmorPlating",
        "ChampionPremiumMaterialSwatches",
        expected_detail
    ]:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s premium body rig missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s premium body rig child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if root.find_child("ChampionPremiumChestCore", true, false) == null:
        push_error("Champion %s premium body rig missing chest core." % champion)
        quit(1)
        return false
    var swatch_count := 0
    var swatches := root.get_node_or_null("ChampionPremiumMaterialSwatches") as Node3D
    if swatches != null:
        for child in swatches.get_children():
            if child.name.begins_with("ChampionPremiumMaterialSwatch"):
                swatch_count += 1
    if swatch_count < 3:
        push_error("Champion %s premium body rig expected 3 material swatches, got %d." % [champion, swatch_count])
        quit(1)
        return false
    if _count_mesh_instances(root) < 10:
        push_error("Champion %s premium body rig looks underbuilt." % champion)
        quit(1)
        return false
    view.call("_sync_champion_premium_body_rig", model)
    await process_frame
    if root.scale.x <= 0.0:
        push_error("Champion %s premium body rig sync produced invalid scale." % champion)
        quit(1)
        return false
    return true

func _require_painterly_depth_rig(model: Node3D, champion: String) -> bool:
    var root := model.find_child("ChampionPainterlyDepthRig", true, false) as Node3D
    if root == null:
        push_error("Champion %s missing painterly depth rig." % champion)
        quit(1)
        return false
    if str(root.get_meta("champion", "")) != champion:
        push_error("Champion %s painterly depth rig champion metadata mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("material_grade", "")) != "painted_depth_low_glare":
        push_error("Champion %s painterly depth rig missing material grade." % champion)
        quit(1)
        return false
    var expected_detail := _expected_painterly_depth_detail(champion)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Champion %s painterly depth rig detail metadata mismatch." % champion)
        quit(1)
        return false
    for child_name in [
        "ChampionPainterlyValueShadow",
        "ChampionPainterlyRimStroke",
        "ChampionPainterlyMaterialSteps",
        expected_detail
    ]:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s painterly depth rig missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s painterly depth child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 8:
        push_error("Champion %s painterly depth rig looks underbuilt." % champion)
        quit(1)
        return false
    if not _require_material_budget(root, "Champion %s painterly depth" % champion, 0.34, 0.64):
        return false
    return true

func _expected_painterly_depth_detail(champion: String) -> String:
    match champion:
        "jinx":
            return "ChampionPainterlyJinxRocketDepth"
        "senna":
            return "ChampionPainterlySennaRelicDepth"
        "samira":
            return "ChampionPainterlySamiraSlashDepth"
        "viktor":
            return "ChampionPainterlyViktorHexDepth"
        "xayah":
            return "ChampionPainterlyXayahFeatherDepth"
        "mordekaiser":
            return "ChampionPainterlyMordeIronDepth"
        "teemo":
            return "ChampionPainterlyTeemoScoutDepth"
        "aurelion_sol":
            return "ChampionPainterlyAsolStarDepth"
        _:
            return "ChampionPainterlyGenericDepth"

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

func _expected_premium_family(champion: String) -> String:
    match champion:
        "jinx":
            return "artillery"
        "senna":
            return "relic_marksman"
        "samira":
            return "duelist"
        "viktor":
            return "hexcore"
        "xayah":
            return "feather"
        "mordekaiser":
            return "juggernaut"
        "teemo":
            return "scout_trapper"
        "aurelion_sol":
            return "celestial"
        _:
            return "adventurer"

func _expected_premium_detail(champion: String) -> String:
    match champion:
        "jinx":
            return "ChampionPremiumJinxGraffitiRig"
        "senna":
            return "ChampionPremiumSennaRelicMantle"
        "samira":
            return "ChampionPremiumSamiraDuelistMantle"
        "viktor":
            return "ChampionPremiumViktorHexcoreHarness"
        "xayah":
            return "ChampionPremiumXayahFeatherMantle"
        "mordekaiser":
            return "ChampionPremiumMordeIronCitadelPlate"
        "teemo":
            return "ChampionPremiumTeemoScoutGear"
        "aurelion_sol":
            return "ChampionPremiumAsolCelestialCrown"
        _:
            return "ChampionPremiumGeneric"

func _require_combat_stance_rig(view, model: Node3D, champion: String) -> bool:
    var stance := model.find_child("ChampionCombatStanceRig", true, false) as Node3D
    if stance == null:
        push_error("Champion %s missing combat stance rig." % champion)
        quit(1)
        return false
    if str(stance.get_meta("champion", "")) != champion:
        push_error("Champion %s combat stance champion metadata mismatch." % champion)
        quit(1)
        return false
    if str(stance.get_meta("combat_class", "")) != _expected_combat_class(champion):
        push_error("Champion %s combat stance class mismatch." % champion)
        quit(1)
        return false
    if str(stance.get_meta("range_band", "")) != _expected_range_band(champion):
        push_error("Champion %s combat stance range band mismatch." % champion)
        quit(1)
        return false
    if str(stance.get_meta("detail_node", "")) != _expected_stance_detail(champion):
        push_error("Champion %s combat stance detail metadata mismatch." % champion)
        quit(1)
        return false
    for child_name in [
        "ChampionStanceBase",
        "ChampionStanceFacingMarker",
        "ChampionStanceRangeBand",
        _expected_stance_detail(champion)
    ]:
        var child := stance.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s combat stance missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s combat stance child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if _count_mesh_instances(stance) < 12:
        push_error("Champion %s combat stance rig looks underbuilt." % champion)
        quit(1)
        return false

    var player = PlayerScript.new()
    root.add_child(player)
    await process_frame
    player.reset_run(champion)
    player.set("attack_timer", float(player.get("attack_cooldown")) * 0.20)
    view.call("_sync_champion_combat_stance_rig", model, player)
    await process_frame
    if float(stance.get_meta("attack_readiness", 0.0)) < 0.75:
        push_error("Champion %s combat stance did not record attack readiness." % champion)
        player.queue_free()
        quit(1)
        return false
    player.queue_free()
    await process_frame
    return true

func _require_archetype_silhouette_rig(view, model: Node3D, champion: String) -> bool:
    var rig := model.find_child("ChampionArchetypeSilhouetteRig", true, false) as Node3D
    if rig == null:
        push_error("Champion %s missing archetype silhouette rig." % champion)
        quit(1)
        return false
    if str(rig.get_meta("champion", "")) != champion:
        push_error("Champion %s archetype silhouette champion metadata mismatch." % champion)
        quit(1)
        return false
    if str(rig.get_meta("archetype_family", "")) != _expected_archetype_family(champion):
        push_error("Champion %s archetype family mismatch: %s." % [champion, str(rig.get_meta("archetype_family", ""))])
        quit(1)
        return false
    if str(rig.get_meta("combat_class", "")) != _expected_combat_class(champion):
        push_error("Champion %s archetype combat class mismatch." % champion)
        quit(1)
        return false
    if str(rig.get_meta("range_band", "")) != _expected_range_band(champion):
        push_error("Champion %s archetype range band mismatch." % champion)
        quit(1)
        return false
    if str(rig.get_meta("material_grade", "")) != "low_glare_archetype_silhouette":
        push_error("Champion %s archetype silhouette missing material grade." % champion)
        quit(1)
        return false
    if str(rig.get_meta("combat_visual_channel", "")) != "champion_archetype_readability":
        push_error("Champion %s archetype silhouette has wrong visual channel." % champion)
        quit(1)
        return false
    var expected_detail := _expected_archetype_detail(champion)
    if str(rig.get_meta("detail_node", "")) != expected_detail:
        push_error("Champion %s archetype detail metadata mismatch." % champion)
        quit(1)
        return false
    for child_name in [
        "ChampionArchetypeBasePlate",
        "ChampionArchetypeRoleTotem",
        "ChampionArchetypeRouteGlyphs",
        expected_detail
    ]:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s archetype silhouette missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s archetype silhouette child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if _count_named_children(rig.get_node_or_null("ChampionArchetypeRouteGlyphs"), "ChampionArchetypeRouteGlyph") < 3:
        push_error("Champion %s archetype silhouette missing route glyphs." % champion)
        quit(1)
        return false
    if _count_mesh_instances(rig) < 13:
        push_error("Champion %s archetype silhouette looks underbuilt." % champion)
        quit(1)
        return false
    if not _require_material_budget(rig, "Champion %s archetype silhouette" % champion, 0.11, 0.36):
        return false

    var player = PlayerScript.new()
    root.add_child(player)
    await process_frame
    player.reset_run(champion)
    player.set("attack_timer", float(player.get("attack_cooldown")) * 0.25)
    view.call("_sync_champion_archetype_silhouette_rig", model, player)
    await process_frame
    if float(rig.get_meta("attack_readiness", 0.0)) < 0.70:
        push_error("Champion %s archetype silhouette did not record attack readiness." % champion)
        player.queue_free()
        quit(1)
        return false
    var routes := rig.get_node_or_null("ChampionArchetypeRouteGlyphs") as Node3D
    if routes == null or routes.scale.x <= 0.90:
        push_error("Champion %s archetype route glyph sync produced invalid scale." % champion)
        player.queue_free()
        quit(1)
        return false
    player.queue_free()
    await process_frame
    return true

func _require_mechanic_meter(model: Node3D, champion: String) -> bool:
    var root := model.find_child("ChampionMechanicMeter", true, false) as Node3D
    if root == null:
        push_error("Champion %s missing mechanic meter root." % champion)
        quit(1)
        return false
    if str(root.get_meta("champion", "")) != champion:
        push_error("Champion %s mechanic meter metadata mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("mechanic_type", "")) == "" or str(root.get_meta("mechanic_type", "")) == "generic":
        push_error("Champion %s mechanic meter missing specific mechanic type." % champion)
        quit(1)
        return false
    for child_name in ["MechanicMeterFrame", "MechanicMeterPips", "MechanicMeterHeroMotif"]:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s mechanic meter missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s mechanic meter child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    var pip_count := 0
    for pip in root.find_child("MechanicMeterPips", true, false).get_children():
        if pip.has_meta("pip_index"):
            pip_count += 1
    if pip_count < 3:
        push_error("Champion %s mechanic meter expected at least 3 pips, got %d." % [champion, pip_count])
        quit(1)
        return false
    if _count_mesh_instances(root) < 8:
        push_error("Champion %s mechanic meter looks underbuilt." % champion)
        quit(1)
        return false
    return true

func _expected_combat_loop_type(champion: String) -> String:
    match champion:
        "jinx":
            return "rocket_minigun_swap"
        "senna":
            return "soul_beam_support"
        "samira":
            return "style_melee_ranged"
        "viktor":
            return "laser_zone_control"
        "xayah":
            return "feather_place_recall"
        "mordekaiser":
            return "melee_slam_realm"
        "teemo":
            return "poison_dart_trap"
        "aurelion_sol":
            return "orbit_singularity_comet"
        _:
            return "generic_loop"

func _expected_combat_loop_detail(champion: String) -> String:
    match champion:
        "jinx":
            return "CombatLoopJinxSwapGlyph"
        "senna":
            return "CombatLoopSennaSoulBeamGlyph"
        "samira":
            return "CombatLoopSamiraStyleGlyph"
        "viktor":
            return "CombatLoopViktorControlGlyph"
        "xayah":
            return "CombatLoopXayahRecallGlyph"
        "mordekaiser":
            return "CombatLoopMordeRealmGlyph"
        "teemo":
            return "CombatLoopTeemoTrapGlyph"
        "aurelion_sol":
            return "CombatLoopAsolOrbitGlyph"
        _:
            return "CombatLoopGenericGlyph"

func _require_combat_loop_readout(view, model: Node3D, champion: String) -> bool:
    var root := model.find_child("ChampionCombatLoopReadout", true, false) as Node3D
    if root == null:
        push_error("Champion %s missing combat loop readout." % champion)
        quit(1)
        return false
    if str(root.get_meta("champion", "")) != champion:
        push_error("Champion %s combat loop readout metadata mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("combat_loop_type", "")) != _expected_combat_loop_type(champion):
        push_error("Champion %s combat loop type mismatch: %s." % [champion, str(root.get_meta("combat_loop_type", ""))])
        quit(1)
        return false
    if str(root.get_meta("combat_loop_type", "")) == "generic_loop":
        push_error("Champion %s combat loop readout should be champion-specific." % champion)
        quit(1)
        return false
    var expected_detail := _expected_combat_loop_detail(champion)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Champion %s combat loop detail metadata mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "champion_readability":
        push_error("Champion %s combat loop readout has wrong visual channel." % champion)
        quit(1)
        return false
    if str(root.get_meta("material_grade", "")) != "low_glare_champion_combat_loop_readout":
        push_error("Champion %s combat loop readout missing low-glare material grade." % champion)
        quit(1)
        return false
    if not bool(root.get_meta("loop_readout_layer", false)):
        push_error("Champion %s combat loop readout missing layer flag." % champion)
        quit(1)
        return false
    for child_name in [
        "CombatLoopMatte",
        "CombatLoopPrimaryGlyph",
        "CombatLoopPassiveGlyph",
        "CombatLoopRouteAnchor",
        expected_detail
    ]:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s combat loop readout missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s combat loop readout child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 7:
        push_error("Champion %s combat loop readout looks underbuilt." % champion)
        quit(1)
        return false
    if not _require_material_budget(root, "Champion %s combat loop readout" % champion, 0.03, 0.36):
        return false

    var player = PlayerScript.new()
    root.add_child(player)
    await process_frame
    player.reset_run(champion)
    player.set("attack_timer", float(player.get("attack_cooldown")) * 0.25)
    player.set("attack_counter", 3)
    view.call("_sync_champion_combat_loop_readout", model, player)
    await process_frame
    if float(root.get_meta("attack_readiness", 0.0)) < 0.70:
        push_error("Champion %s combat loop readout did not record attack readiness." % champion)
        player.queue_free()
        quit(1)
        return false
    if int(root.get_meta("attack_counter", -1)) != 3:
        push_error("Champion %s combat loop readout did not record attack counter." % champion)
        player.queue_free()
        quit(1)
        return false
    var detail := root.get_node_or_null(expected_detail) as Node3D
    if detail == null or detail.scale.x <= 1.0:
        push_error("Champion %s combat loop detail did not pulse on sync." % champion)
        player.queue_free()
        quit(1)
        return false
    player.queue_free()
    await process_frame
    return true

func _require_human_focus_plate(view, model: Node3D, champion: String) -> bool:
    var root := model.find_child("ChampionHumanFocusPlate", true, false) as Node3D
    if root == null:
        push_error("Champion %s missing human focus plate." % champion)
        quit(1)
        return false
    if str(root.get_meta("champion", "")) != champion:
        push_error("Champion %s human focus plate metadata mismatch." % champion)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "champion_focus_readability":
        push_error("Champion %s human focus plate has wrong visual channel." % champion)
        quit(1)
        return false
    if str(root.get_meta("material_grade", "")) != "low_glare_human_focus_plate":
        push_error("Champion %s human focus plate missing low-glare material grade." % champion)
        quit(1)
        return false
    if not bool(root.get_meta("human_focus_guard", false)) or not bool(root.get_meta("pickup_confusion_guard", false)):
        push_error("Champion %s human focus plate missing readability guards." % champion)
        quit(1)
        return false
    if str(root.get_meta("combat_class", "")) == "" or str(root.get_meta("range_band", "")) == "":
        push_error("Champion %s human focus plate missing class/range metadata." % champion)
        quit(1)
        return false
    for child_name in [
        "HumanFocusMatteDisc",
        "HumanFocusSafeOrbit",
        "HumanFocusFacingArrow",
        "HumanFocusDodgeLaneRoot",
        "HumanFocusClassGlyph"
    ]:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s human focus plate missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s human focus plate child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if _count_named_children(root.get_node_or_null("HumanFocusDodgeLaneRoot"), "HumanFocusDodgeLane") < 4:
        push_error("Champion %s human focus plate missing dodge lanes." % champion)
        quit(1)
        return false
    if _count_mesh_instances(root) < 10:
        push_error("Champion %s human focus plate looks underbuilt." % champion)
        quit(1)
        return false
    if not _require_material_budget(root, "Champion %s human focus plate" % champion, 0.03, 0.36):
        return false

    var player = PlayerScript.new()
    root.add_child(player)
    await process_frame
    player.reset_run(champion)
    player.set("health", maxf(1.0, float(player.get("max_health")) * 0.42))
    player.set("attack_timer", float(player.get("attack_cooldown")) * 0.30)
    view.call("_sync_champion_human_focus_plate", model, player)
    await process_frame
    if not bool(root.get_meta("human_focus_active", false)):
        push_error("Champion %s human focus plate did not become active on sync." % champion)
        player.queue_free()
        quit(1)
        return false
    if float(root.get_meta("health_ratio", 1.0)) > 0.50:
        push_error("Champion %s human focus plate did not record low health ratio." % champion)
        player.queue_free()
        quit(1)
        return false
    if float(root.get_meta("attack_readiness", 0.0)) < 0.65:
        push_error("Champion %s human focus plate did not record attack readiness." % champion)
        player.queue_free()
        quit(1)
        return false
    if root.scale.x <= 1.03:
        push_error("Champion %s human focus plate did not expand under pressure." % champion)
        player.queue_free()
        quit(1)
        return false
    player.queue_free()
    await process_frame
    return true

func _require_signature_cast_rig(view, model: Node3D, champion: String) -> bool:
    var rig := model.find_child("ChampionSignatureCastRig", true, false) as Node3D
    if rig == null:
        push_error("Champion %s missing signature cast rig." % champion)
        quit(1)
        return false
    if str(rig.get_meta("champion", "")) != champion:
        push_error("Champion %s signature cast rig metadata mismatch." % champion)
        quit(1)
        return false
    var required_children := [
        "ChampionSignatureCastCore",
        "ChampionSignatureCastLane",
        "ChampionSignatureCastMotif",
        "ChampionSignatureCastIdentity",
        "ChampionSignatureCastRoleTelegraph",
        "ChampionSignatureCastPatternFloor"
    ]
    for child_name in required_children:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s signature cast rig missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s signature cast child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if _count_mesh_instances(rig) < 5:
        push_error("Champion %s signature cast rig looks underbuilt." % champion)
        quit(1)
        return false
    if not _require_signature_cast_identity(rig, champion):
        return false
    if not _require_signature_cast_role_telegraph(rig, champion):
        return false
    if not _require_signature_cast_pattern_floor(rig, champion):
        return false

    var player = PlayerScript.new()
    root.add_child(player)
    await process_frame
    player.reset_run(champion)
    player.set("attack_timer", float(player.get("attack_cooldown")) * 0.18)
    view.call("_sync_champion_signature_cast_rig", model, player)
    await process_frame
    if not bool(rig.visible):
        push_error("Champion %s signature cast rig did not become visible near attack readiness." % champion)
        player.queue_free()
        quit(1)
        return false
    var telegraph := rig.get_node_or_null("ChampionSignatureCastRoleTelegraph") as Node3D
    if telegraph == null or not bool(telegraph.visible):
        push_error("Champion %s signature cast role telegraph did not become visible near attack readiness." % champion)
        player.queue_free()
        quit(1)
        return false
    var pattern_floor := rig.get_node_or_null("ChampionSignatureCastPatternFloor") as Node3D
    if pattern_floor == null or not bool(pattern_floor.visible):
        push_error("Champion %s signature cast pattern floor did not become visible near attack readiness." % champion)
        player.queue_free()
        quit(1)
        return false
    if float(pattern_floor.get_meta("cast_readiness", 0.0)) < 0.75:
        push_error("Champion %s signature cast pattern floor did not record readiness." % champion)
        player.queue_free()
        quit(1)
        return false
    player.queue_free()
    await process_frame
    return true

func _require_signature_cast_identity(rig: Node3D, champion: String) -> bool:
    var identity := rig.get_node_or_null("ChampionSignatureCastIdentity") as Node3D
    if identity == null:
        push_error("Champion %s missing signature cast identity node." % champion)
        quit(1)
        return false
    if str(identity.get_meta("champion", "")) != champion:
        push_error("Champion %s signature identity champion metadata mismatch." % champion)
        quit(1)
        return false
    if str(identity.get_meta("identity_signature", "")) == "":
        push_error("Champion %s signature identity missing identity_signature metadata." % champion)
        quit(1)
        return false
    var expected_detail := ""
    match champion:
        "jinx":
            expected_detail = "ChampionSignatureJinxRocketFuse"
        "senna":
            expected_detail = "ChampionSignatureSennaSoulGate"
        "samira":
            expected_detail = "ChampionSignatureSamiraStyleRank"
        "viktor":
            expected_detail = "ChampionSignatureViktorHexcoreBeam"
        "xayah":
            expected_detail = "ChampionSignatureXayahFeatherRecall"
        "mordekaiser":
            expected_detail = "ChampionSignatureMordeRealmSeal"
        "teemo":
            expected_detail = "ChampionSignatureTeemoMushroomTrap"
        "aurelion_sol":
            expected_detail = "ChampionSignatureAsolStarForge"
        _:
            pass
    if expected_detail != "" and identity.find_child(expected_detail, true, false) == null:
        push_error("Champion %s signature identity missing %s." % [champion, expected_detail])
        quit(1)
        return false
    if _count_mesh_instances(identity) < 5:
        push_error("Champion %s signature identity looks underbuilt." % champion)
        quit(1)
        return false
    return true

func _require_signature_cast_role_telegraph(rig: Node3D, champion: String) -> bool:
    var telegraph := rig.get_node_or_null("ChampionSignatureCastRoleTelegraph") as Node3D
    if telegraph == null:
        push_error("Champion %s missing signature cast role telegraph." % champion)
        quit(1)
        return false
    if str(telegraph.get_meta("champion", "")) != champion:
        push_error("Champion %s cast role telegraph champion metadata mismatch." % champion)
        quit(1)
        return false
    if str(telegraph.get_meta("cast_role", "")) != _expected_cast_role(champion):
        push_error("Champion %s cast role telegraph role mismatch." % champion)
        quit(1)
        return false
    if str(telegraph.get_meta("detail_node", "")) != _expected_cast_telegraph_detail(champion):
        push_error("Champion %s cast role telegraph detail metadata mismatch." % champion)
        quit(1)
        return false
    for child_name in [
        "ChampionCastTelegraphFrame",
        "ChampionCastTelegraphMeter",
        _expected_cast_telegraph_detail(champion)
    ]:
        var child := telegraph.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s cast role telegraph missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s cast role telegraph child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if _count_mesh_instances(telegraph) < 5:
        push_error("Champion %s cast role telegraph looks underbuilt." % champion)
        quit(1)
        return false
    return true

func _require_signature_cast_pattern_floor(rig: Node3D, champion: String) -> bool:
    var pattern_floor := rig.get_node_or_null("ChampionSignatureCastPatternFloor") as Node3D
    if pattern_floor == null:
        push_error("Champion %s missing signature cast pattern floor." % champion)
        quit(1)
        return false
    if str(pattern_floor.get_meta("champion", "")) != champion:
        push_error("Champion %s cast pattern floor champion metadata mismatch." % champion)
        quit(1)
        return false
    if str(pattern_floor.get_meta("pattern_type", "")) != _expected_cast_pattern_type(champion):
        push_error("Champion %s cast pattern floor type mismatch." % champion)
        quit(1)
        return false
    if str(pattern_floor.get_meta("detail_node", "")) != _expected_cast_pattern_detail(champion):
        push_error("Champion %s cast pattern floor detail metadata mismatch." % champion)
        quit(1)
        return false
    if int(pattern_floor.get_meta("impact_marker_count", 0)) != _expected_cast_impact_count(champion):
        push_error("Champion %s cast pattern floor impact count metadata mismatch." % champion)
        quit(1)
        return false
    if str(pattern_floor.get_meta("combat_visual_channel", "")) != "champion_cast_pattern_readability":
        push_error("Champion %s cast pattern floor has wrong visual channel." % champion)
        quit(1)
        return false
    if str(pattern_floor.get_meta("material_grade", "")) != "low_glare_champion_cast_pattern_floor":
        push_error("Champion %s cast pattern floor missing material grade." % champion)
        quit(1)
        return false
    if not bool(pattern_floor.get_meta("champion_cast_pattern_floor_layer", false)):
        push_error("Champion %s cast pattern floor missing layer marker." % champion)
        quit(1)
        return false
    for child_name in [
        "ChampionCastPatternShadow",
        "ChampionCastPatternImpactLanes",
        "ChampionCastPatternAnchorPips",
        _expected_cast_pattern_detail(champion)
    ]:
        var child := pattern_floor.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Champion %s cast pattern floor missing %s." % [champion, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Champion %s cast pattern floor child %s has no mesh content." % [champion, child_name])
            quit(1)
            return false
    if _count_named_descendants(pattern_floor, "ChampionCastPatternImpactMarker") < _expected_cast_impact_count(champion):
        push_error("Champion %s cast pattern floor missing impact markers." % champion)
        quit(1)
        return false
    var min_meshes := _expected_cast_impact_count(champion) + 3
    if _count_mesh_instances(pattern_floor) < min_meshes:
        push_error("Champion %s cast pattern floor looks underbuilt." % champion)
        quit(1)
        return false
    if not _require_material_budget(pattern_floor, "Champion %s cast pattern floor" % champion, 0.08, 0.32):
        return false
    return true

func _expected_cast_role(champion: String) -> String:
    match champion:
        "jinx":
            return "artillery_burst"
        "senna":
            return "soul_beam"
        "samira":
            return "duelist_combo"
        "viktor":
            return "hexcore_ray"
        "xayah":
            return "feather_recall"
        "mordekaiser":
            return "realm_crush"
        "teemo":
            return "poison_trap"
        "aurelion_sol":
            return "starfall"
        _:
            return "generic_cast"

func _expected_combat_class(champion: String) -> String:
    match champion:
        "jinx":
            return "ranged_artillery"
        "senna":
            return "ranged_support_artillery"
        "samira":
            return "melee_duelist"
        "viktor":
            return "control_mage"
        "xayah":
            return "ranged_kiting_marksman"
        "mordekaiser":
            return "melee_juggernaut"
        "teemo":
            return "trap_summoner"
        "aurelion_sol":
            return "cosmic_battle_mage"
        _:
            return "adventurer"

func _expected_range_band(champion: String) -> String:
    match champion:
        "samira", "mordekaiser":
            return "melee"
        "viktor", "aurelion_sol":
            return "mage"
        "teemo":
            return "summoner"
        _:
            return "ranged"

func _expected_stance_detail(champion: String) -> String:
    match champion:
        "jinx":
            return "ChampionStanceJinxBacklineRocket"
        "senna":
            return "ChampionStanceSennaAnchoredBeam"
        "samira":
            return "ChampionStanceSamiraMeleeDash"
        "viktor":
            return "ChampionStanceViktorControlGrid"
        "xayah":
            return "ChampionStanceXayahKitingFan"
        "mordekaiser":
            return "ChampionStanceMordeFrontlineSlam"
        "teemo":
            return "ChampionStanceTeemoTrapScout"
        "aurelion_sol":
            return "ChampionStanceAsolOrbitCaster"
        _:
            return "ChampionStanceGeneric"

func _expected_archetype_family(champion: String) -> String:
    match champion:
        "jinx":
            return "physical_artillery_marksman"
        "senna":
            return "support_piercing_marksman"
        "samira":
            return "melee_physical_duelist"
        "viktor":
            return "magic_control_mage"
        "xayah":
            return "physical_feather_marksman"
        "mordekaiser":
            return "magic_melee_tank"
        "teemo":
            return "magic_trap_summoner"
        "aurelion_sol":
            return "cosmic_scaling_mage"
        _:
            return "adventurer"

func _expected_archetype_detail(champion: String) -> String:
    match champion:
        "jinx":
            return "ChampionArchetypeJinxRocketRack"
        "senna":
            return "ChampionArchetypeSennaPiercingCannon"
        "samira":
            return "ChampionArchetypeSamiraBladeDance"
        "viktor":
            return "ChampionArchetypeViktorControlHex"
        "xayah":
            return "ChampionArchetypeXayahFeatherFan"
        "mordekaiser":
            return "ChampionArchetypeMordeWarMace"
        "teemo":
            return "ChampionArchetypeTeemoTrapField"
        "aurelion_sol":
            return "ChampionArchetypeAsolStarOrbit"
        _:
            return "ChampionArchetypeGeneric"

func _expected_cast_telegraph_detail(champion: String) -> String:
    match champion:
        "jinx":
            return "ChampionCastTelegraphJinxArtillery"
        "senna":
            return "ChampionCastTelegraphSennaSoulBeam"
        "samira":
            return "ChampionCastTelegraphSamiraDuelist"
        "viktor":
            return "ChampionCastTelegraphViktorHexRay"
        "xayah":
            return "ChampionCastTelegraphXayahFeathers"
        "mordekaiser":
            return "ChampionCastTelegraphMordeRealm"
        "teemo":
            return "ChampionCastTelegraphTeemoPoison"
        "aurelion_sol":
            return "ChampionCastTelegraphAsolStarfall"
        _:
            return "ChampionCastTelegraphGeneric"

func _expected_cast_pattern_type(champion: String) -> String:
    match champion:
        "jinx":
            return "artillery_line"
        "senna":
            return "piercing_beam"
        "samira":
            return "melee_arc"
        "viktor":
            return "hex_ray_grid"
        "xayah":
            return "feather_fan_recall"
        "mordekaiser":
            return "realm_slam_circle"
        "teemo":
            return "trap_field_radius"
        "aurelion_sol":
            return "star_orbit_fall"
        _:
            return "generic_cast_floor"

func _expected_cast_pattern_detail(champion: String) -> String:
    match champion:
        "jinx":
            return "ChampionCastPatternJinxArtilleryLine"
        "senna":
            return "ChampionCastPatternSennaPiercingBeam"
        "samira":
            return "ChampionCastPatternSamiraMeleeArc"
        "viktor":
            return "ChampionCastPatternViktorHexRayGrid"
        "xayah":
            return "ChampionCastPatternXayahFeatherRecall"
        "mordekaiser":
            return "ChampionCastPatternMordeRealmSlam"
        "teemo":
            return "ChampionCastPatternTeemoTrapField"
        "aurelion_sol":
            return "ChampionCastPatternAsolStarOrbit"
        _:
            return "ChampionCastPatternGeneric"

func _expected_cast_impact_count(champion: String) -> int:
    match champion:
        "jinx":
            return 3
        "senna":
            return 2
        "samira":
            return 5
        "viktor":
            return 4
        "xayah":
            return 7
        "mordekaiser":
            return 4
        "teemo":
            return 5
        "aurelion_sol":
            return 6
        _:
            return 3

func _require_recipe_ring(view, model: Node3D) -> bool:
    var player = PlayerScript.new()
    root.add_child(player)
    await process_frame
    player.reset_run("jinx")
    player.add_upgrade("physical_hex")
    player.add_upgrade("physical_hex")
    player.add_upgrade("marksman_hex")
    player.add_item_purchase("infinity_edge")
    view.call("_sync_player_status_rings", model, player)
    await process_frame

    var recipes := model.find_child("Recipes", true, false) as Node3D
    if recipes == null or not bool(recipes.visible):
        push_error("Champion visual matrix expected recipe synergy ring to become visible.")
        player.queue_free()
        quit(1)
        return false
    var visible_marks := 0
    for child in recipes.get_children():
        if child.has_meta("recipe") and bool(child.visible):
            visible_marks += 1
    if visible_marks <= 0:
        push_error("Champion visual matrix expected at least one recipe star mark.")
        player.queue_free()
        quit(1)
        return false
    var items := model.find_child("Items", true, false) as Node3D
    if items == null or not bool(items.visible):
        push_error("Champion visual matrix expected item trophy ring to become visible.")
        player.queue_free()
        quit(1)
        return false
    var item_marks := 0
    for child in items.get_children():
        if child.has_meta("item") and bool(child.visible):
            item_marks += 1
    if item_marks <= 0:
        push_error("Champion visual matrix expected at least one item trophy mark.")
        player.queue_free()
        quit(1)
        return false
    player.queue_free()
    await process_frame
    return true
