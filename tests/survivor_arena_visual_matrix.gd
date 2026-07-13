extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const EXPECTED_FLOOR := "res://art/textures/hextech_void_arena_floor_painted_v3.png"
const MIN_TEXTURE_SIZE := Vector2i(1280, 720)
const MIN_STATIC_MESHES := 180
const MAX_STATIC_MESHES := 1800

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var image := Image.new()
    var image_err := image.load(EXPECTED_FLOOR)
    if image_err != OK:
        push_error("Arena visual matrix could not load v3 floor texture.")
        quit(1)
        return
    if image.get_width() < MIN_TEXTURE_SIZE.x or image.get_height() < MIN_TEXTURE_SIZE.y:
        push_error("Arena floor texture too small: %dx%d." % [image.get_width(), image.get_height()])
        quit(1)
        return

    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    var active_floor := str(view.call("_arena_floor_texture_path"))
    if active_floor != EXPECTED_FLOOR:
        push_error("Arena visual matrix expected %s, got %s." % [EXPECTED_FLOOR, active_floor])
        quit(1)
        return

    var floor := view.get_node_or_null("ArenaPaintedFloor") as MeshInstance3D
    if floor == null:
        push_error("Arena visual matrix expected named ArenaPaintedFloor node.")
        quit(1)
        return
    var floor_mat := floor.material_override as StandardMaterial3D
    if floor_mat == null or floor_mat.albedo_texture == null:
        push_error("Arena visual matrix expected textured floor material.")
        quit(1)
        return

    for node_name in ["ArenaPremiumSetDressing", "ArenaRitualTowerSet", "ArenaPerimeterCitadelSet", "ArenaMotionRig", "ArenaObjectiveShrineSet", "ArenaDepthPlatformSet", "ArenaReadabilityVignetteSet", "ArenaTacticalHexGridSet", "ArenaCombatReadabilityStrataSet", "ArenaPremiumCompositionFrameSet", "ArenaRelicShowcaseSet"]:
        if view.get_node_or_null(node_name) == null:
            push_error("Arena visual matrix missing %s." % node_name)
            quit(1)
            return
    if view.get_node_or_null("BossPressureRig") != null:
        push_error("Arena visual matrix expected BossPressureRig to be built lazily only when a boss exists.")
        quit(1)
        return
    var citadel_root := view.get_node_or_null("ArenaPerimeterCitadelSet")
    if _count_named_prefix(citadel_root, "PerimeterWallSpan_") < 4:
        push_error("Arena visual matrix expected 4 perimeter wall spans.")
        quit(1)
        return
    if _count_named_prefix(citadel_root, "PerimeterCitadelTower_") < 4:
        push_error("Arena visual matrix expected 4 perimeter citadel towers.")
        quit(1)
        return
    if _count_named_prefix(citadel_root, "PerimeterEnergyNode_") < 8:
        push_error("Arena visual matrix expected 8 perimeter energy nodes.")
        quit(1)
        return
    if _count_named(citadel_root, "PerimeterShieldRail") < 4:
        push_error("Arena visual matrix expected perimeter shield rails.")
        quit(1)
        return
    if _count_named_prefix(citadel_root, "PerimeterDiagonalButtress_") < 4:
        push_error("Arena visual matrix expected 4 diagonal perimeter buttresses.")
        quit(1)
        return
    var tower_root := view.get_node_or_null("ArenaRitualTowerSet")
    if _count_named_prefix(tower_root, "RitualTower_") < 8:
        push_error("Arena visual matrix expected 8 ritual towers.")
        quit(1)
        return
    if _count_named(tower_root, "RitualGlyph") < 8:
        push_error("Arena visual matrix expected atlas-backed ritual tower glyphs.")
        quit(1)
        return
    if _count_named_prefix(tower_root, "RitualEnergyBridge_") < 6:
        push_error("Arena visual matrix expected ritual energy bridges.")
        quit(1)
        return
    var inlay_root := view.get_node_or_null("ArenaFloorInlaySet")
    if inlay_root == null:
        push_error("Arena visual matrix missing ArenaFloorInlaySet.")
        quit(1)
        return
    if _count_named_prefix(inlay_root, "FloorInlayOctagonSpan_") < 8:
        push_error("Arena visual matrix expected 8 octagon floor inlay spans.")
        quit(1)
        return
    if _count_named_prefix(inlay_root, "FloorInlayRadialConduit_") < 8:
        push_error("Arena visual matrix expected 8 radial floor conduits.")
        quit(1)
        return
    if _count_named_prefix(inlay_root, "FloorInlayRunicShard_") < 6:
        push_error("Arena visual matrix expected floor runic shards.")
        quit(1)
        return
    if _count_named_prefix(inlay_root, "FloorInlayCornerAnchor_") < 4:
        push_error("Arena visual matrix expected 4 corner inlay anchors.")
        quit(1)
        return
    if _count_named(inlay_root, "FloorInlayCornerCrystal") < 4:
        push_error("Arena visual matrix expected corner inlay crystals.")
        quit(1)
        return
    var tactical_root := view.get_node_or_null("ArenaTacticalHexGridSet")
    if str(tactical_root.get_meta("combat_visual_channel", "")) != "arena_readability":
        push_error("Arena visual matrix expected tactical hex grid readability metadata.")
        quit(1)
        return
    if str(tactical_root.get_meta("material_grade", "")) != "low_glare_hex_floor_guides":
        push_error("Arena visual matrix expected low-glare tactical hex grid material grade.")
        quit(1)
        return
    if _count_named_prefix(tactical_root, "ArenaTacticalHexCell_") < 25:
        push_error("Arena visual matrix expected at least 25 tactical hex cells.")
        quit(1)
        return
    if _count_named_prefix(tactical_root, "ArenaTacticalHexEdge_") < 150:
        push_error("Arena visual matrix expected tactical hex cell edges.")
        quit(1)
        return
    if _count_named(tactical_root, "ArenaTacticalHexMajorPip") < 5:
        push_error("Arena visual matrix expected tactical major cell pips.")
        quit(1)
        return
    if _count_named(tactical_root, "ArenaTacticalCenterHex") < 1:
        push_error("Arena visual matrix expected tactical center hex.")
        quit(1)
        return
    if _count_named_prefix(tactical_root, "ArenaTacticalCenterSpoke_") < 6:
        push_error("Arena visual matrix expected tactical center spokes.")
        quit(1)
        return
    if not _require_low_glare_mesh(tactical_root, "ArenaTacticalHexEdge_"):
        return
    if not _require_low_glare_mesh(tactical_root, "ArenaTacticalHexMajorPip"):
        return
    var platform_root := view.get_node_or_null("ArenaDepthPlatformSet")
    if str(platform_root.get_meta("combat_visual_channel", "")) != "arena_readability":
        push_error("Arena visual matrix expected depth platform readability metadata.")
        quit(1)
        return
    if str(platform_root.get_meta("material_grade", "")) != "low_glare_layered_platform":
        push_error("Arena visual matrix expected low-glare layered platform material grade.")
        quit(1)
        return
    for platform_node in ["ArenaDepthPlatformOuterDais", "ArenaDepthPlatformInnerDais", "ArenaDepthPlatformCombatFocusCore"]:
        if _count_named(platform_root, platform_node) < 1:
            push_error("Arena visual matrix expected %s." % platform_node)
            quit(1)
            return
    if _count_named_prefix(platform_root, "ArenaDepthPlatformBevel_") < 8:
        push_error("Arena visual matrix expected 8 depth platform bevels.")
        quit(1)
        return
    if _count_named_prefix(platform_root, "ArenaDepthPlatformThreatSeparator_") < 8:
        push_error("Arena visual matrix expected depth platform threat separators.")
        quit(1)
        return
    if _count_named_prefix(platform_root, "ArenaDepthPlatformFactionInlay_") < 6:
        push_error("Arena visual matrix expected faction inlays on the combat dais.")
        quit(1)
        return
    if _count_named_prefix(platform_root, "ArenaDepthPlatformOcclusionPocket_") < 4:
        push_error("Arena visual matrix expected platform occlusion pockets.")
        quit(1)
        return
    if not _require_meta_prefix(platform_root, "ArenaDepthPlatformOuterDais", "readability_role", "combat_dais_shadow"):
        return
    if not _require_low_glare_mesh(platform_root, "ArenaDepthPlatformOuterDais"):
        return
    if not _require_low_glare_mesh(platform_root, "ArenaDepthPlatformBevel_"):
        return
    if not _require_low_glare_mesh(platform_root, "ArenaDepthPlatformThreatSeparator_"):
        return
    var shrine_root := view.get_node_or_null("ArenaObjectiveShrineSet")
    if _count_named_prefix(shrine_root, "ObjectiveShrine_") < 6:
        push_error("Arena visual matrix expected 6 objective shrines.")
        quit(1)
        return
    for shrine_child_name in ["ObjectiveShrineBase", "ObjectiveShrineFrame", "ObjectiveShrineGlowRing", "ObjectiveShrineCrystal", "ObjectiveShrineSigil"]:
        if _count_named(shrine_root, shrine_child_name) < 6:
            push_error("Arena visual matrix expected objective shrine child %s." % shrine_child_name)
            quit(1)
            return
    for shrine_type in ["hextech", "void", "reward"]:
        if _count_meta(shrine_root, "shrine_type", shrine_type) < 2:
            push_error("Arena visual matrix expected 2 %s objective shrines." % shrine_type)
            quit(1)
            return
    var vignette_root := view.get_node_or_null("ArenaReadabilityVignetteSet")
    if str(vignette_root.get_meta("combat_visual_channel", "")) != "arena_readability":
        push_error("Arena visual matrix expected readability vignette metadata.")
        quit(1)
        return
    if _count_named_prefix(vignette_root, "ArenaDepthEdgeShadow_") < 4:
        push_error("Arena visual matrix expected 4 edge shadow strips.")
        quit(1)
        return
    if _count_named_prefix(vignette_root, "ArenaDepthCornerOccluder_") < 4:
        push_error("Arena visual matrix expected 4 corner occluders.")
        quit(1)
        return
    if _count_named_prefix(vignette_root, "ArenaCombatFocusBoundary_") < 4:
        push_error("Arena visual matrix expected combat focus boundaries.")
        quit(1)
        return
    if _count_named_prefix(vignette_root, "ArenaCombatLaneMatte_") < 3:
        push_error("Arena visual matrix expected matte combat lane guides.")
        quit(1)
        return
    if not _require_low_glare_mesh(vignette_root, "ArenaDepthEdgeShadow_"):
        return
    if not _require_low_glare_mesh(vignette_root, "ArenaDepthCornerOccluder_"):
        return
    var strata_root := view.get_node_or_null("ArenaCombatReadabilityStrataSet")
    if str(strata_root.get_meta("combat_visual_channel", "")) != "arena_readability":
        push_error("Arena visual matrix expected combat readability strata metadata.")
        quit(1)
        return
    if str(strata_root.get_meta("material_grade", "")) != "anti_glare_survival_readability":
        push_error("Arena visual matrix expected anti-glare survival readability grade.")
        quit(1)
        return
    if _count_named_prefix(strata_root, "ArenaSafeKitePocket_") < 4:
        push_error("Arena visual matrix expected 4 safe kite pockets.")
        quit(1)
        return
    if _count_named_prefix(strata_root, "ArenaDangerApproachWedge_") < 4:
        push_error("Arena visual matrix expected 4 danger approach wedges.")
        quit(1)
        return
    if _count_named_prefix(strata_root, "ArenaThreatLaneMatte_") < 5:
        push_error("Arena visual matrix expected threat lane mattes.")
        quit(1)
        return
    if _count_named_prefix(strata_root, "ArenaBossSightlineMatte_") < 3:
        push_error("Arena visual matrix expected boss sightline mattes.")
        quit(1)
        return
    if _count_named_prefix(strata_root, "ArenaPickupReservationBand_") < 2:
        push_error("Arena visual matrix expected pickup reservation bands.")
        quit(1)
        return
    if not _require_meta_prefix(strata_root, "ArenaSafeKitePocket_", "readability_role", "safe_kite_pocket"):
        return
    if not _require_meta_prefix(strata_root, "ArenaDangerApproachWedge_", "readability_role", "danger_approach_wedge"):
        return
    if not _require_low_glare_mesh(strata_root, "ArenaSafeKitePocket_"):
        return
    if not _require_low_glare_mesh(strata_root, "ArenaDangerApproachWedge_"):
        return
    if not _require_low_glare_mesh(strata_root, "ArenaThreatLaneMatte_"):
        return
    if not _require_low_glare_mesh(strata_root, "ArenaBossSightlineMatte_"):
        return
    var composition_root := view.get_node_or_null("ArenaPremiumCompositionFrameSet")
    if str(composition_root.get_meta("combat_visual_channel", "")) != "arena_readability":
        push_error("Arena visual matrix expected premium composition frame readability metadata.")
        quit(1)
        return
    if str(composition_root.get_meta("material_grade", "")) != "low_glare_static_composition_frame":
        push_error("Arena visual matrix expected low-glare static composition frame grade.")
        quit(1)
        return
    if str(composition_root.get_meta("performance_profile", "")) != "static_no_lights":
        push_error("Arena visual matrix expected composition frame to be static/no-lights.")
        quit(1)
        return
    if _count_named_prefix(composition_root, "ArenaCompositionHeroGallerySlot_") < 8:
        push_error("Arena visual matrix expected hero gallery slots in the premium composition frame.")
        quit(1)
        return
    if _count_named_prefix(composition_root, "ArenaCompositionVoidGallerySlot_") < 7:
        push_error("Arena visual matrix expected void gallery slots in the premium composition frame.")
        quit(1)
        return
    if _count_named_prefix(composition_root, "ArenaCompositionVfxPanel_") < 6:
        push_error("Arena visual matrix expected VFX panels in the premium composition frame.")
        quit(1)
        return
    if _count_named_prefix(composition_root, "ArenaCompositionMaterialSwatch_") < 5:
        push_error("Arena visual matrix expected material swatches in the premium composition frame.")
        quit(1)
        return
    if _count_named_prefix(composition_root, "ArenaCompositionPanelRail_") < 20:
        push_error("Arena visual matrix expected composition frame panel rails.")
        quit(1)
        return
    if _count_named_prefix(composition_root, "ArenaCompositionCornerBracket_") < 8:
        push_error("Arena visual matrix expected composition corner brackets.")
        quit(1)
        return
    if _count_named_prefix(composition_root, "ArenaCompositionCombatWindow_") < 1:
        push_error("Arena visual matrix expected a clear center combat window frame.")
        quit(1)
        return
    if _count_realtime_lights(composition_root) > 0:
        push_error("Arena visual matrix composition frame should not add realtime lights.")
        quit(1)
        return
    if not _require_meta_prefix(composition_root, "ArenaCompositionCombatWindow_", "composition_role", "clear_center_combat_window"):
        return
    if not _require_meta_prefix(composition_root, "ArenaCompositionHeroGallerySlot_", "composition_role", "hero_identity_asset_slot"):
        return
    if not _require_meta_prefix(composition_root, "ArenaCompositionVoidGallerySlot_", "composition_role", "void_creature_asset_slot"):
        return
    if not _require_meta_prefix(composition_root, "ArenaCompositionVfxPanel_", "composition_role", "spell_effect_asset_slot"):
        return
    if not _require_meta_prefix(composition_root, "ArenaCompositionMaterialSwatch_", "composition_role", "reward_material_swatch"):
        return
    if not _require_low_glare_mesh(composition_root, "ArenaCompositionPanelRail_"):
        return
    if not _require_low_glare_mesh(composition_root, "ArenaCompositionCornerBracket_"):
        return
    if not _require_low_glare_mesh(composition_root, "ArenaCompositionCombatWindow_"):
        return
    var relic_root := view.get_node_or_null("ArenaRelicShowcaseSet")
    if str(relic_root.get_meta("combat_visual_channel", "")) != "arena_readability":
        push_error("Arena visual matrix expected relic showcase readability metadata.")
        quit(1)
        return
    if str(relic_root.get_meta("material_grade", "")) != "low_glare_static_relic_showcase":
        push_error("Arena visual matrix expected low-glare relic showcase material grade.")
        quit(1)
        return
    if str(relic_root.get_meta("performance_profile", "")) != "static_no_lights":
        push_error("Arena visual matrix expected relic showcase to be static/no-lights.")
        quit(1)
        return
    if _count_named_prefix(relic_root, "ArenaRelicShowcaseSlot_") < 6:
        push_error("Arena visual matrix expected 6 relic showcase equipment slots.")
        quit(1)
        return
    if _count_named_prefix(relic_root, "ArenaRelicShowcaseItem_") < 6:
        push_error("Arena visual matrix expected 6 relic showcase item silhouettes.")
        quit(1)
        return
    if _count_named_prefix(relic_root, "ArenaRelicShowcaseBuildRoute_") < 5:
        push_error("Arena visual matrix expected relic showcase build route bridges.")
        quit(1)
        return
    if _count_named_prefix(relic_root, "ArenaRelicShowcaseRewardShard_") < 5:
        push_error("Arena visual matrix expected reward shard swatches in the relic showcase.")
        quit(1)
        return
    if _count_realtime_lights(relic_root) > 0:
        push_error("Arena visual matrix relic showcase should not add realtime lights.")
        quit(1)
        return
    if not _require_meta_prefix(relic_root, "ArenaRelicShowcaseSlot_", "composition_role", "equipment_build_relic_slot"):
        return
    if not _require_meta_prefix(relic_root, "ArenaRelicShowcaseItem_", "composition_role", "equipment_icon_silhouette"):
        return
    if not _require_meta_prefix(relic_root, "ArenaRelicShowcaseBuildRoute_", "composition_role", "shop_build_route"):
        return
    if not _require_meta_prefix(relic_root, "ArenaRelicShowcaseRewardShard_", "composition_role", "reward_pickup_language_reference"):
        return
    if not _require_low_glare_mesh(relic_root, "ArenaRelicShowcaseSlotBackplate_"):
        return
    if not _require_low_glare_mesh(relic_root, "ArenaRelicShowcaseBuildRoute_"):
        return

    var mesh_count := _count_mesh_instances(view)
    if mesh_count < MIN_STATIC_MESHES:
        push_error("Arena visual matrix looks underbuilt: only %d meshes." % mesh_count)
        quit(1)
        return
    if mesh_count > MAX_STATIC_MESHES:
        push_error("Arena visual matrix exceeded static mesh budget: %d > %d." % [mesh_count, MAX_STATIC_MESHES])
        quit(1)
        return

    print("SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=%dx%d meshes=%d citadel_nodes=%d strata=%d" % [
        image.get_width(),
        image.get_height(),
        mesh_count,
        _count_named_prefix(citadel_root, "PerimeterEnergyNode_"),
        _count_named_prefix(strata_root, "ArenaSafeKitePocket_") + _count_named_prefix(strata_root, "ArenaDangerApproachWedge_")
    ])
    quit(0)

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count

func _count_named(node: Node, node_name: String) -> int:
    if node == null:
        return 0
    var count := 1 if node.name == node_name else 0
    for child in node.get_children():
        count += _count_named(child, node_name)
    return count

func _count_named_prefix(node: Node, prefix: String) -> int:
    if node == null:
        return 0
    var count := 1 if node.name.begins_with(prefix) else 0
    for child in node.get_children():
        count += _count_named_prefix(child, prefix)
    return count

func _count_meta(node: Node, meta_name: String, expected_value: String) -> int:
    if node == null:
        return 0
    var count := 1 if str(node.get_meta(meta_name, "")) == expected_value else 0
    for child in node.get_children():
        count += _count_meta(child, meta_name, expected_value)
    return count

func _count_realtime_lights(node: Node) -> int:
    if node == null:
        return 0
    var count := 1 if node is Light3D else 0
    for child in node.get_children():
        count += _count_realtime_lights(child)
    return count

func _require_low_glare_mesh(node: Node, prefix: String) -> bool:
    var mesh := _find_named_prefix(node, prefix) as MeshInstance3D
    if mesh == null:
        push_error("Arena visual matrix missing low-glare probe %s." % prefix)
        quit(1)
        return false
    var mat := mesh.material_override as StandardMaterial3D
    if mat == null:
        push_error("Arena visual matrix low-glare probe %s has no StandardMaterial3D." % prefix)
        quit(1)
        return false
    if mat.emission_enabled:
        push_error("Arena visual matrix low-glare probe %s should not emit light." % prefix)
        quit(1)
        return false
    if mat.albedo_color.a > 0.34:
        push_error("Arena visual matrix low-glare probe %s alpha too high: %.2f." % [prefix, mat.albedo_color.a])
        quit(1)
        return false
    return true

func _require_meta_prefix(node: Node, prefix: String, meta_name: String, expected_value: String) -> bool:
    var found := _find_named_prefix(node, prefix) as Node
    if found == null:
        push_error("Arena visual matrix missing metadata probe %s." % prefix)
        quit(1)
        return false
    if str(found.get_meta(meta_name, "")) != expected_value:
        push_error("Arena visual matrix expected %s metadata %s=%s." % [prefix, meta_name, expected_value])
        quit(1)
        return false
    return true

func _find_named_prefix(node: Node, prefix: String) -> Node:
    if node == null:
        return null
    if node.name.begins_with(prefix):
        return node
    for child in node.get_children():
        var found := _find_named_prefix(child, prefix)
        if found != null:
            return found
    return null
