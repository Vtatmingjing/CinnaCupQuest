extends Node3D
class_name CinnaSurvivor3DView

const WORLD_SCALE := 0.018
const CAMERA_SIZE := 28.0
const CAMERA_HEIGHT := 26.0
const PROCEDURAL_MODEL_SCALE := 0.72
const ENEMY_MODEL_SCALE := 1.34
const PICKUP_MODEL_SCALE := 0.58
const ENTITY_SPIN_SPEED := 0.0
const PROJECTILE_SPIN_SPEED := 0.0
const PICKUP_SPIN_SPEED := 0.0
const PLAYER_BOB_AMOUNT := 0.0
const MODEL_CONFIG_PATH := "res://art/champions/models/model_config.json"
const ENEMY_SHADOW_LIMIT := 24
const ENEMY_DETAIL_LIMIT := 18
const ENEMY_DETAIL_RECOVER_LIMIT := 10
const ENEMY_LOD_REBUILDS_PER_FRAME := 2
const PROJECTILE_LOD_REBUILDS_PER_FRAME := 4
const ENEMY_PROJECTILE_DETAIL_LIMIT := 6
const PLAYER_PROJECTILE_DETAIL_LIMIT := 1
const PICKUP_DETAIL_LIMIT := 20
const ZONE_DETAIL_LIMIT := 4
const ZONE_DETAIL_RECOVER_LIMIT := 2
const ENEMY_DAMAGE_STATE_THRESHOLD := 0.72
const HEXTECH_GOLD := Color(0.72, 0.48, 0.22)
const HEXTECH_BLUE := Color(0.18, 0.78, 1.0)
const HEXTECH_STONE := Color(0.050, 0.047, 0.076)
const VOID_PURPLE := Color(0.68, 0.18, 1.0)
const DANGER_RED := Color(1.0, 0.12, 0.34)
const HEXTECH_ARENA_PAINTED_TEXTURE_PATH := "res://art/textures/hextech_void_arena_floor_painted_v3.png"
const HEXTECH_ARENA_PAINTED_FALLBACK_TEXTURE_PATH := "res://art/textures/hextech_void_arena_floor_painted_v2.png"
const HEXTECH_ARENA_PAINTED_LEGACY_TEXTURE_PATH := "res://art/textures/hextech_void_arena_floor_painted_v1.png"
const HEXTECH_FLOOR_TEXTURE_PATH := "res://art/textures/hextech_floor_tile_v1.png"
const VOID_FLOOR_TEXTURE_PATH := "res://art/textures/void_corruption_tile_v2.png"
const VOID_FLOOR_FALLBACK_TEXTURE_PATH := "res://art/textures/void_corruption_tile_v1.png"
const VOID_CARAPACE_TEXTURE_PATH := "res://art/textures/void_carapace_tile_v3.png"
const VOID_CARAPACE_FALLBACK_TEXTURE_PATH := "res://art/textures/void_carapace_tile_v2.png"
const HEXTECH_METAL_TEXTURE_PATH := "res://art/textures/hextech_metal_tile_v3.png"
const HEXTECH_METAL_FALLBACK_TEXTURE_PATH := "res://art/textures/hextech_metal_tile_v2.png"
const HEXTECH_WARNING_RUNE_TEXTURE_PATH := "res://art/textures/hextech_warning_rune_tile_v1.png"
const HEXTECH_VOID_VFX_DECAL_TEXTURE_PATH := "res://art/textures/hextech_void_vfx_decal_atlas_v1.png"
const HEXTECH_VOID_VFX_DECAL_FALLBACK_TEXTURE_PATH := "res://art/direction/hextech_void_vfx_atlas_v1.png"
const VOID_BOSS_EMBLEM_ATLAS_TEXTURE_PATH := "res://art/textures/void_boss_emblem_atlas_v1.png"
const VOID_BOSS_EMBLEM_ATLAS_COLS := 2
const VOID_BOSS_EMBLEM_ATLAS_ROWS := 2
const CHAMPION_ABILITY_EMBLEM_ATLAS_TEXTURE_PATH := "res://art/textures/champion_ability_emblem_atlas_v1.png"
const CHAMPION_ABILITY_EMBLEM_ATLAS_COLS := 6
const CHAMPION_ABILITY_EMBLEM_ATLAS_ROWS := 4
const CHAMPION_PORTRAIT_TEXTURE_TEMPLATE := "res://art/champions/portraits/%s_identity_v1.png"

var root_ref: Node = null
var arena := Rect2(-1520, -900, 3040, 1800)
var camera: Camera3D
var player_model: Node3D = null
var enemy_models: Dictionary = {}
var projectile_models: Dictionary = {}
var pickup_models: Dictionary = {}
var zone_models: Dictionary = {}
var pulse_models: Dictionary = {}
var spawn_rift_models: Dictionary = {}
var death_burst_models: Dictionary = {}
var hit_spark_models: Dictionary = {}
var material_cache: Dictionary = {}
var material_property_support_cache: Dictionary = {}
var texture_cache: Dictionary = {}
var camera_target := Vector3.ZERO
var external_model_config: Dictionary = {}
var arena_motion_root: Node3D = null
var boss_pressure_root: Node3D = null
var survival_director_root: Node3D = null
var spawn_gateway_motion_nodes: Array[Node3D] = []

func setup(new_root: Node, arena_rect: Rect2) -> void:
    root_ref = new_root
    arena = arena_rect

func _ready() -> void:
    _load_external_model_config()
    _build_scene()

func _process(delta: float) -> void:
    if root_ref == null:
        return
    _sync_camera(delta)
    _sync_player()
    _sync_enemies()
    _sync_boss_pressure()
    _sync_projectiles()
    _sync_pickups()
    _sync_zones()
    _sync_spawn_rifts()
    _sync_death_bursts()
    _sync_hit_sparks()
    _sync_pulses()
    _sync_survival_director_pressure()
    _sync_arena_motion(delta)

func _arena_floor_texture_path() -> String:
    if _asset_available(HEXTECH_ARENA_PAINTED_TEXTURE_PATH):
        return HEXTECH_ARENA_PAINTED_TEXTURE_PATH
    if _asset_available(HEXTECH_ARENA_PAINTED_FALLBACK_TEXTURE_PATH):
        return HEXTECH_ARENA_PAINTED_FALLBACK_TEXTURE_PATH
    if _asset_available(HEXTECH_ARENA_PAINTED_LEGACY_TEXTURE_PATH):
        return HEXTECH_ARENA_PAINTED_LEGACY_TEXTURE_PATH
    return HEXTECH_FLOOR_TEXTURE_PATH

func _void_carapace_texture_path() -> String:
    if _asset_available(VOID_CARAPACE_TEXTURE_PATH):
        return VOID_CARAPACE_TEXTURE_PATH
    return VOID_CARAPACE_FALLBACK_TEXTURE_PATH

func _hextech_metal_texture_path() -> String:
    if _asset_available(HEXTECH_METAL_TEXTURE_PATH):
        return HEXTECH_METAL_TEXTURE_PATH
    return HEXTECH_METAL_FALLBACK_TEXTURE_PATH

func _void_floor_texture_path() -> String:
    if _asset_available(VOID_FLOOR_TEXTURE_PATH):
        return VOID_FLOOR_TEXTURE_PATH
    return VOID_FLOOR_FALLBACK_TEXTURE_PATH

func _warning_rune_texture_path() -> String:
    if _asset_available(HEXTECH_WARNING_RUNE_TEXTURE_PATH):
        return HEXTECH_WARNING_RUNE_TEXTURE_PATH
    return ""

func _vfx_decal_texture_path() -> String:
    if _asset_available(HEXTECH_VOID_VFX_DECAL_TEXTURE_PATH):
        return HEXTECH_VOID_VFX_DECAL_TEXTURE_PATH
    if _asset_available(HEXTECH_VOID_VFX_DECAL_FALLBACK_TEXTURE_PATH):
        return HEXTECH_VOID_VFX_DECAL_FALLBACK_TEXTURE_PATH
    return _warning_rune_texture_path()

func _champion_portrait_texture_path(champion: String) -> String:
    var path := CHAMPION_PORTRAIT_TEXTURE_TEMPLATE % champion
    if _asset_available(path):
        return path
    return ""

func _build_scene() -> void:
    var env := WorldEnvironment.new()
    env.name = "HextechVoidWorldEnvironment"
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.030, 0.036, 0.060)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.210, 0.240, 0.320)
    environment.ambient_light_energy = 0.240
    environment.tonemap_mode = Environment.TONE_MAPPER_ACES
    environment.tonemap_exposure = 0.820
    environment.tonemap_white = 1.080
    environment.glow_enabled = true
    environment.glow_intensity = 0.0012
    environment.glow_strength = 0.012
    environment.glow_bloom = 0.0002
    _apply_cinematic_environment_grade(environment)
    env.environment = environment
    add_child(env)

    camera = Camera3D.new()
    camera.name = "HextechTopdownCamera"
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = CAMERA_SIZE
    camera.far = 1000.0
    camera.current = true
    add_child(camera)

    var sun := DirectionalLight3D.new()
    sun.name = "HextechKeyLight"
    sun.light_color = Color(0.88, 0.94, 1.0)
    sun.light_energy = 0.760
    sun.rotation_degrees = Vector3(-60, -34, 0)
    sun.set_meta("cinematic_role", "cool_key")
    add_child(sun)

    var fill := OmniLight3D.new()
    fill.name = "HextechFillLight"
    fill.light_color = Color(0.30, 0.58, 1.0)
    fill.light_energy = 0.160
    fill.omni_range = 62.0
    fill.position = Vector3(0, 12, 0)
    fill.set_meta("cinematic_role", "controlled_blue_fill")
    add_child(fill)

    _build_scene_rim_lights()
    _build_arena()

func _build_scene_rim_lights() -> void:
    var void_rim := OmniLight3D.new()
    void_rim.name = "VoidRimLight"
    void_rim.light_color = Color(0.86, 0.24, 1.0)
    void_rim.light_energy = 0.054
    void_rim.omni_range = 44.0
    void_rim.shadow_enabled = false
    void_rim.position = Vector3(-12, 7, -8)
    void_rim.set_meta("cinematic_role", "void_magenta_rim")
    add_child(void_rim)

    var hex_rim := OmniLight3D.new()
    hex_rim.name = "HextechGoldRimLight"
    hex_rim.light_color = Color(1.0, 0.68, 0.25)
    hex_rim.light_energy = 0.052
    hex_rim.omni_range = 36.0
    hex_rim.shadow_enabled = false
    hex_rim.position = Vector3(11, 6, 7)
    hex_rim.set_meta("cinematic_role", "hextech_gold_rim")
    add_child(hex_rim)

func _apply_cinematic_environment_grade(environment: Environment) -> void:
    _set_object_property_if_available(environment, "adjustment_enabled", true)
    _set_object_property_if_available(environment, "adjustment_brightness", 0.92)
    _set_object_property_if_available(environment, "adjustment_contrast", 1.14)
    _set_object_property_if_available(environment, "adjustment_saturation", 0.82)

func _build_arena() -> void:
    var floor_mesh := PlaneMesh.new()
    floor_mesh.size = Vector2(arena.size.x * WORLD_SCALE, arena.size.y * WORLD_SCALE)
    var floor := MeshInstance3D.new()
    floor.name = "ArenaPaintedFloor"
    floor.mesh = floor_mesh
    var floor_texture_path := _arena_floor_texture_path()
    var floor_is_painted := floor_texture_path != HEXTECH_FLOOR_TEXTURE_PATH
    var floor_uv_scale := Vector3.ONE if floor_is_painted else Vector3(2.0, 1.25, 1.0)
    var floor_tint := Color(1.18, 1.16, 1.08) if floor_is_painted else Color(0.68, 0.72, 0.82)
    floor.material_override = _texture_mat("painted_arena_floor", floor_texture_path, floor_tint, 0.04, true, false, floor_uv_scale)
    floor.position = _to3d(arena.get_center(), -0.02)
    add_child(floor)

    _build_arena_depth_platform_set()
    _build_hex_floor()
    _build_arena_tactical_hex_grid_set()
    _build_arena_readability_vignette_set()
    _build_arena_combat_readability_strata_set()
    _build_arena_premium_composition_frame_set()
    _build_arena_relic_showcase_set()
    _build_survival_director_pressure_rig()
    _build_hextech_frame()
    _build_arena_perimeter_citadel_set()
    _build_center_plate()
    _build_arena_path_guides()
    _build_arena_floor_inlay_set()
    _build_arena_side_modules()
    _build_void_cracks()
    _build_void_texture_overlays()
    _build_hextech_pylons()
    _build_arena_relic_clusters()
    _build_arena_objective_shrine_set()
    _build_arena_premium_set_dressing()
    _build_arena_ritual_tower_set()
    _build_spawn_gateways()
    _build_arena_motion_rig()

func _build_arena_depth_platform_set() -> void:
    var root := Node3D.new()
    root.name = "ArenaDepthPlatformSet"
    root.set_meta("art_role", "layered_hextech_void_combat_dais")
    root.set_meta("combat_visual_channel", "arena_readability")
    root.set_meta("material_grade", "low_glare_layered_platform")
    add_child(root)

    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var outer_radius := minf(half_x * 0.47, half_z * 0.70)
    var inner_radius := outer_radius * 0.70
    var core_radius := outer_radius * 0.30
    var base_mat := _mat("arena_depth_platform_base_matte", Color(0.006, 0.008, 0.018, 0.30), 0.0, true, true)
    var inner_mat := _mat("arena_depth_platform_inner_matte", Color(0.018, 0.026, 0.050, 0.26), 0.0, true, true)
    var trim_mat := _mat("arena_depth_platform_gold_matte", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.22), 0.0, true, true)
    var blue_mat := _mat("arena_depth_platform_blue_matte", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.16), 0.0, true, true)
    var void_mat := _mat("arena_depth_platform_void_matte", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.16), 0.0, true, true)
    var seam_mat := _mat("arena_depth_platform_seam_shadow", Color(0.0, 0.0, 0.0, 0.34), 0.0, true, true)

    var outer := _add_cylinder_segments(root, outer_radius, 0.014, 8, base_mat, Vector3(0, 0.018, 0), Vector3(0, 22.5, 0))
    outer.name = "ArenaDepthPlatformOuterDais"
    outer.set_meta("readability_role", "combat_dais_shadow")
    var inner := _add_cylinder_segments(root, inner_radius, 0.012, 8, inner_mat, Vector3(0, 0.034, 0), Vector3(0, 22.5, 0))
    inner.name = "ArenaDepthPlatformInnerDais"
    inner.set_meta("readability_role", "combat_dais_inner_plane")
    var core := _add_cylinder_segments(root, core_radius, 0.012, 6, trim_mat, Vector3(0, 0.052, 0), Vector3(0, 30, 0))
    core.name = "ArenaDepthPlatformCombatFocusCore"
    core.set_meta("readability_role", "combat_focus_core")

    for i in range(8):
        var angle := TAU * float(i) / 8.0
        var bevel := _add_box(root, Vector3(outer_radius * 0.62, 0.012, 0.046), trim_mat, Vector3(cos(angle) * outer_radius * 0.72, 0.066, sin(angle) * outer_radius * 0.72), Vector3(0, -rad_to_deg(angle), 0))
        bevel.name = "ArenaDepthPlatformBevel_%d" % i
        bevel.set_meta("readability_role", "low_glare_beveled_edge")
        var seam := _add_box(root, Vector3(outer_radius * 0.44, 0.010, 0.026), seam_mat, Vector3(cos(angle) * outer_radius * 0.48, 0.074, sin(angle) * outer_radius * 0.48), Vector3(0, -rad_to_deg(angle), 0))
        seam.name = "ArenaDepthPlatformThreatSeparator_%d" % i
        seam.set_meta("readability_role", "enemy_projectile_separator")

    for i in range(6):
        var angle := TAU * float(i) / 6.0 + PI * 0.08
        var mat := blue_mat if i % 3 == 0 else void_mat if i % 3 == 1 else trim_mat
        var inlay := _add_box(root, Vector3(0.052, 0.010, outer_radius * 0.44), mat, Vector3(cos(angle) * inner_radius * 0.58, 0.084, sin(angle) * inner_radius * 0.58), Vector3(0, -rad_to_deg(angle), 0))
        inlay.name = "ArenaDepthPlatformFactionInlay_%d" % i
        inlay.set_meta("readability_role", "hextech_void_faction_inlay")

    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        var pocket := _add_cylinder_segments(root, outer_radius * 0.13, 0.010, 6, seam_mat, Vector3(cos(angle) * inner_radius * 0.94, 0.092, sin(angle) * inner_radius * 0.94), Vector3(0, 30, 0))
        pocket.name = "ArenaDepthPlatformOcclusionPocket_%d" % i
        pocket.set_meta("readability_role", "projectile_pickup_occlusion_pocket")

func _build_arena_readability_vignette_set() -> void:
    var root := Node3D.new()
    root.name = "ArenaReadabilityVignetteSet"
    root.set_meta("art_role", "arena_depth_vignette")
    root.set_meta("combat_visual_channel", "arena_readability")
    add_child(root)

    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var edge_mat := _mat("arena_depth_edge_shadow", Color(0.0, 0.0, 0.0, 0.30), 0.0, true, true)
    var corner_mat := _mat("arena_depth_corner_shadow", Color(0.0, 0.0, 0.0, 0.36), 0.0, true, true)
    var boundary_mat := _mat("arena_combat_focus_boundary", Color(0.82, 0.74, 0.54, 0.16), 0.0, true, true)
    var lane_matte := _mat("arena_combat_lane_matte", Color(0.015, 0.018, 0.030, 0.18), 0.0, true, true)

    var top := _add_box(root, Vector3(half_x * 2.0, 0.012, 1.86), edge_mat, Vector3(0, 0.026, -half_z + 1.28))
    top.name = "ArenaDepthEdgeShadow_North"
    var bottom := _add_box(root, Vector3(half_x * 2.0, 0.012, 1.86), edge_mat, Vector3(0, 0.026, half_z - 1.28))
    bottom.name = "ArenaDepthEdgeShadow_South"
    var left := _add_box(root, Vector3(1.86, 0.012, half_z * 2.0), edge_mat, Vector3(-half_x + 1.28, 0.028, 0))
    left.name = "ArenaDepthEdgeShadow_West"
    var right := _add_box(root, Vector3(1.86, 0.012, half_z * 2.0), edge_mat, Vector3(half_x - 1.28, 0.028, 0))
    right.name = "ArenaDepthEdgeShadow_East"

    for i in range(4):
        var sx := -1.0 if i % 2 == 0 else 1.0
        var sz := -1.0 if i < 2 else 1.0
        var corner := _add_cylinder_segments(root, 2.24, 0.012, 8, corner_mat, Vector3(sx * (half_x - 2.20), 0.034, sz * (half_z - 2.12)), Vector3(0, 22.5, 0))
        corner.name = "ArenaDepthCornerOccluder_%d" % i

    var bounds := [
        [Vector3(0, 0.052, -5.45), Vector3(17.4, 0.010, 0.032), 0.0],
        [Vector3(0, 0.054, 5.45), Vector3(17.4, 0.010, 0.032), 0.0],
        [Vector3(-8.70, 0.056, 0), Vector3(0.032, 0.010, 10.9), 0.0],
        [Vector3(8.70, 0.058, 0), Vector3(0.032, 0.010, 10.9), 0.0]
    ]
    for i in range(bounds.size()):
        var spec: Array = bounds[i]
        var boundary := _add_box(root, spec[1], boundary_mat, spec[0], Vector3(0, float(spec[2]), 0))
        boundary.name = "ArenaCombatFocusBoundary_%d" % i

    for i in range(3):
        var z := -2.70 + float(i) * 2.70
        var lane := _add_box(root, Vector3(14.2, 0.008, 0.030), lane_matte, Vector3(0, 0.044 + float(i) * 0.002, z))
        lane.name = "ArenaCombatLaneMatte_%d" % i

func _build_arena_tactical_hex_grid_set() -> void:
    var root := Node3D.new()
    root.name = "ArenaTacticalHexGridSet"
    root.set_meta("art_role", "tactical_hex_floor_readability")
    root.set_meta("combat_visual_channel", "arena_readability")
    root.set_meta("material_grade", "low_glare_hex_floor_guides")
    add_child(root)

    var groove_mat := _mat("arena_tactical_hex_groove", Color(0.0, 0.0, 0.0, 0.22), 0.0, true, true)
    var gold_mat := _mat("arena_tactical_hex_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.18), 0.0, true, true)
    var blue_mat := _mat("arena_tactical_hex_blue", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.15), 0.0, true, true)
    var void_mat := _mat("arena_tactical_hex_void", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.15), 0.0, true, true)
    var major_mat := _mat("arena_tactical_hex_major", Color(0.86, 0.80, 0.66, 0.20), 0.0, true, true)
    var radius := 1.28
    var x_step := radius * 1.52
    var z_step := radius * 1.32
    var index := 0
    for row in range(-3, 4):
        for col in range(-4, 5):
            var x := float(col) * x_step + (x_step * 0.5 if abs(row) % 2 == 1 else 0.0)
            var z := float(row) * z_step
            if Vector2(x / 8.8, z / 5.9).length() > 1.02:
                continue
            var dist := Vector2(x / 8.8, z / 5.9).length()
            var accent := blue_mat if x < -1.8 else void_mat if x > 1.8 else gold_mat
            var major := index % 5 == 0 or dist < 0.18
            _add_arena_tactical_hex_cell(root, Vector3(x, 0.071 + float(index % 3) * 0.001, z), radius, index, groove_mat, accent, major_mat, major)
            index += 1

    for i in range(6):
        var angle := TAU * float(i) / 6.0
        var spoke := _add_box(root, Vector3(0.070, 0.010, 5.25), major_mat, Vector3(cos(angle) * 1.36, 0.088, sin(angle) * 1.36), Vector3(0, -rad_to_deg(angle), 0))
        spoke.name = "ArenaTacticalCenterSpoke_%d" % i
        spoke.set_meta("combat_visual_channel", "arena_readability")
    var center := _add_cylinder_segments(root, 1.18, 0.012, 6, gold_mat, Vector3(0, 0.104, 0), Vector3(0, 30, 0))
    center.name = "ArenaTacticalCenterHex"
    center.set_meta("combat_visual_channel", "arena_readability")

func _add_arena_tactical_hex_cell(root: Node3D, pos: Vector3, radius: float, index: int, groove_mat: Material, accent_mat: Material, major_mat: Material, major: bool) -> void:
    var cell := Node3D.new()
    cell.name = "ArenaTacticalHexCell_%02d" % index
    cell.position = pos
    cell.set_meta("combat_visual_channel", "arena_readability")
    cell.set_meta("tactical_hex_index", index)
    cell.set_meta("major_tactical_cell", major)
    root.add_child(cell)
    var edge_len := radius * 0.96
    var edge_width := 0.030 if major else 0.022
    for edge_index in range(6):
        var angle := TAU * float(edge_index) / 6.0
        var edge_pos := Vector3(cos(angle) * radius * 0.76, 0.0, sin(angle) * radius * 0.76)
        var mat := accent_mat if edge_index % 3 == index % 3 else groove_mat
        var edge := _add_box(cell, Vector3(edge_len, 0.010, edge_width), mat, edge_pos, Vector3(0, -rad_to_deg(angle) + 90.0, 0))
        edge.name = "ArenaTacticalHexEdge_%02d_%d" % [index, edge_index]
        edge.set_meta("combat_visual_channel", "arena_readability")
        edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    if major:
        var pip := _add_cylinder_segments(cell, radius * 0.19, 0.010, 6, major_mat, Vector3(0, 0.014, 0), Vector3(0, 30, 0))
        pip.name = "ArenaTacticalHexMajorPip"
        pip.set_meta("combat_visual_channel", "arena_readability")
        pip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _build_arena_combat_readability_strata_set() -> void:
    var root := Node3D.new()
    root.name = "ArenaCombatReadabilityStrataSet"
    root.set_meta("art_role", "combat_readability_strata")
    root.set_meta("combat_visual_channel", "arena_readability")
    root.set_meta("material_grade", "anti_glare_survival_readability")
    add_child(root)

    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var safe_mat := _mat("arena_strata_safe_kite_matte", Color(0.020, 0.055, 0.075, 0.18), 0.0, true, true)
    var danger_mat := _mat("arena_strata_void_approach_matte", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.13), 0.0, true, true)
    var lane_mat := _mat("arena_strata_threat_lane_matte", Color(0.0, 0.0, 0.0, 0.20), 0.0, true, true)
    var boss_mat := _mat("arena_strata_boss_sightline_matte", Color(0.40, 0.06, 0.08, 0.16), 0.0, true, true)
    var pickup_mat := _mat("arena_strata_pickup_reservation_matte", Color(0.10, 0.14, 0.10, 0.12), 0.0, true, true)
    var bracket_mat := _mat("arena_strata_focus_bracket_matte", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.14), 0.0, true, true)

    var safe_specs := [
        Vector3(-half_x * 0.48, 0.118, -half_z * 0.50),
        Vector3(half_x * 0.48, 0.120, -half_z * 0.50),
        Vector3(-half_x * 0.48, 0.122, half_z * 0.50),
        Vector3(half_x * 0.48, 0.124, half_z * 0.50)
    ]
    for i in range(safe_specs.size()):
        var pocket := _add_cylinder_segments(root, 1.58, 0.010, 6, safe_mat, safe_specs[i], Vector3(0, 30, 0))
        pocket.name = "ArenaSafeKitePocket_%d" % i
        pocket.set_meta("combat_visual_channel", "arena_readability")
        pocket.set_meta("readability_role", "safe_kite_pocket")
        var bracket := _add_box(root, Vector3(1.16, 0.010, 0.032), bracket_mat, safe_specs[i] + Vector3(0, 0.018, -0.96), Vector3(0, 0, 0))
        bracket.name = "ArenaSafeKitePocketBracket_%d" % i
        bracket.set_meta("combat_visual_channel", "arena_readability")

    var danger_specs := [
        [Vector3(-half_x * 0.22, 0.132, -half_z * 0.16), -32.0],
        [Vector3(half_x * 0.22, 0.134, -half_z * 0.16), 32.0],
        [Vector3(-half_x * 0.22, 0.136, half_z * 0.16), 32.0],
        [Vector3(half_x * 0.22, 0.138, half_z * 0.16), -32.0]
    ]
    for i in range(danger_specs.size()):
        var spec: Array = danger_specs[i]
        var wedge := _add_cylinder_segments(root, 1.18, 0.010, 3, danger_mat, spec[0], Vector3(0, float(spec[1]), 0))
        wedge.name = "ArenaDangerApproachWedge_%d" % i
        wedge.set_meta("combat_visual_channel", "arena_readability")
        wedge.set_meta("readability_role", "danger_approach_wedge")

    for i in range(5):
        var x := -half_x * 0.38 + float(i) * half_x * 0.19
        var lane := _add_box(root, Vector3(0.050, 0.008, half_z * 1.52), lane_mat, Vector3(x, 0.146 + float(i) * 0.002, 0))
        lane.name = "ArenaThreatLaneMatte_%d" % i
        lane.set_meta("combat_visual_channel", "arena_readability")
        lane.set_meta("readability_role", "enemy_flow_separator")

    for i in range(3):
        var angle := -28.0 + float(i) * 28.0
        var sightline := _add_box(root, Vector3(0.080, 0.010, half_z * 1.36), boss_mat, Vector3(0, 0.158 + float(i) * 0.002, 0), Vector3(0, angle, 0))
        sightline.name = "ArenaBossSightlineMatte_%d" % i
        sightline.set_meta("combat_visual_channel", "arena_readability")
        sightline.set_meta("readability_role", "boss_attack_sightline")

    for i in range(2):
        var side := -1.0 if i == 0 else 1.0
        var band := _add_box(root, Vector3(half_x * 1.15, 0.008, 0.075), pickup_mat, Vector3(0, 0.166 + float(i) * 0.002, side * half_z * 0.34))
        band.name = "ArenaPickupReservationBand_%d" % i
        band.set_meta("combat_visual_channel", "arena_readability")
        band.set_meta("readability_role", "pickup_separation_band")

func _build_arena_premium_composition_frame_set() -> void:
    var root := Node3D.new()
    root.name = "ArenaPremiumCompositionFrameSet"
    root.set_meta("art_role", "reference_board_hextech_void_composition")
    root.set_meta("combat_visual_channel", "arena_readability")
    root.set_meta("material_grade", "low_glare_static_composition_frame")
    root.set_meta("performance_profile", "static_no_lights")
    add_child(root)

    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var y := 0.188
    var matte := _mat("arena_composition_matte_panel", Color(0.006, 0.008, 0.020, 0.30), 0.0, true, true)
    var gold := _mat("arena_composition_gold_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24), 0.0, true, true)
    var blue := _mat("arena_composition_blue_lane", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.16), 0.0, true, true)
    var void_mat := _mat("arena_composition_void_lane", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.16), 0.0, true, true)
    var dark := _mat("arena_composition_dark_gap", Color(0.0, 0.0, 0.0, 0.28), 0.0, true, true)
    var reward := _mat("arena_composition_reward_swatch", Color(1.0, 0.72, 0.18, 0.16), 0.0, true, true)

    _add_composition_outer_panel(root, "TopHeroGallery", Vector3(0, y, -half_z + 2.22), Vector3(half_x * 1.60, 0.012, 0.54), gold, matte)
    _add_composition_outer_panel(root, "LeftVoidGallery", Vector3(-half_x + 2.04, y + 0.010, 0), Vector3(0.50, 0.012, half_z * 1.18), void_mat, matte)
    _add_composition_outer_panel(root, "RightVfxGallery", Vector3(half_x - 2.04, y + 0.012, -half_z * 0.15), Vector3(0.50, 0.012, half_z * 0.88), blue, matte)
    _add_composition_outer_panel(root, "RightRewardGallery", Vector3(half_x - 2.04, y + 0.014, half_z * 0.54), Vector3(0.50, 0.012, half_z * 0.30), reward, matte)

    for i in range(8):
        var t := 0.0 if i == 0 else float(i) / 7.0
        var x := lerpf(-half_x * 0.64, half_x * 0.64, t)
        var slot := _add_box(root, Vector3(1.06, 0.010, 0.042), gold if i % 3 == 0 else blue, Vector3(x, y + 0.044, -half_z + 2.05), Vector3(0, 0, 0))
        slot.name = "ArenaCompositionHeroGallerySlot_%02d" % i
        slot.set_meta("combat_visual_channel", "arena_readability")
        slot.set_meta("composition_role", "hero_identity_asset_slot")
        var pip := _add_cylinder_segments(root, 0.080, 0.010, 6, blue if i % 2 == 0 else gold, Vector3(x, y + 0.060, -half_z + 1.72), Vector3(0, 30, 0))
        pip.name = "ArenaCompositionHeroGalleryPip_%02d" % i
        pip.set_meta("combat_visual_channel", "arena_readability")

    for i in range(7):
        var z := lerpf(-half_z * 0.44, half_z * 0.44, float(i) / 6.0)
        var slot := _add_cylinder_segments(root, 0.33 + float(i % 3) * 0.035, 0.010, 5 + int(i % 2), void_mat, Vector3(-half_x + 2.06, y + 0.060, z), Vector3(0, 18 + float(i) * 9.0, 0))
        slot.name = "ArenaCompositionVoidGallerySlot_%02d" % i
        slot.set_meta("combat_visual_channel", "arena_readability")
        slot.set_meta("composition_role", "void_creature_asset_slot")
        var claw := _add_box(root, Vector3(0.038, 0.010, 0.60), dark, Vector3(-half_x + 2.46, y + 0.066, z), Vector3(0, -20.0 + float(i) * 7.0, 0))
        claw.name = "ArenaCompositionVoidGalleryClaw_%02d" % i
        claw.set_meta("combat_visual_channel", "arena_readability")

    for i in range(6):
        var z := lerpf(-half_z * 0.48, half_z * 0.12, float(i) / 5.0)
        var color_mat := blue if i % 2 == 0 else void_mat
        var line := _add_box(root, Vector3(0.56, 0.010, 0.036), color_mat, Vector3(half_x - 2.06, y + 0.058, z), Vector3(0, 22.0 + float(i) * 13.0, 0))
        line.name = "ArenaCompositionVfxPanel_%02d" % i
        line.set_meta("combat_visual_channel", "arena_readability")
        line.set_meta("composition_role", "spell_effect_asset_slot")
        var impact := _add_cylinder_segments(root, 0.20, 0.010, 8, color_mat, Vector3(half_x - 2.43, y + 0.066, z + 0.18), Vector3(0, 22.5, 0))
        impact.name = "ArenaCompositionVfxImpact_%02d" % i
        impact.set_meta("combat_visual_channel", "arena_readability")

    for i in range(5):
        var z := half_z * 0.42 + float(i) * 0.42
        var x := half_x - 2.42 + float(i % 2) * 0.72
        var swatch_mat := reward if i % 2 == 0 else blue
        var swatch := _add_cylinder_segments(root, 0.18, 0.010, 6, swatch_mat, Vector3(x, y + 0.064, z), Vector3(0, 30, 0))
        swatch.name = "ArenaCompositionMaterialSwatch_%02d" % i
        swatch.set_meta("combat_visual_channel", "arena_readability")
        swatch.set_meta("composition_role", "reward_material_swatch")

    var combat_window := _add_cylinder_segments(root, 6.58, 0.010, 8, matte, Vector3(0, y + 0.022, 0), Vector3(0, 22.5, 0))
    combat_window.name = "ArenaCompositionCombatWindow_0"
    combat_window.set_meta("combat_visual_channel", "arena_readability")
    combat_window.set_meta("composition_role", "clear_center_combat_window")
    for i in range(8):
        var angle := TAU * float(i) / 8.0 + PI * 0.125
        var rail := _add_box(root, Vector3(1.42, 0.010, 0.030), gold if i % 2 == 0 else dark, Vector3(cos(angle) * 6.72, y + 0.050, sin(angle) * 6.72), Vector3(0, -rad_to_deg(angle) + 90.0, 0))
        rail.name = "ArenaCompositionPanelRail_%02d" % i
        rail.set_meta("combat_visual_channel", "arena_readability")

    var corners := [
        Vector3(-half_x + 1.64, y + 0.080, -half_z + 1.52),
        Vector3(half_x - 1.64, y + 0.080, -half_z + 1.52),
        Vector3(-half_x + 1.64, y + 0.080, half_z - 1.52),
        Vector3(half_x - 1.64, y + 0.080, half_z - 1.52)
    ]
    for i in range(corners.size()):
        var sx := -1.0 if i % 2 == 0 else 1.0
        var sz := -1.0 if i < 2 else 1.0
        var bracket_a := _add_box(root, Vector3(1.18, 0.010, 0.036), gold, corners[i], Vector3(0, sx * sz * 18.0, 0))
        bracket_a.name = "ArenaCompositionCornerBracket_%02d_A" % i
        bracket_a.set_meta("combat_visual_channel", "arena_readability")
        var bracket_b := _add_box(root, Vector3(0.036, 0.010, 1.18), dark, corners[i] + Vector3(sx * 0.46, 0.006, sz * 0.46), Vector3(0, sx * sz * 18.0, 0))
        bracket_b.name = "ArenaCompositionCornerBracket_%02d_B" % i
        bracket_b.set_meta("combat_visual_channel", "arena_readability")

func _add_composition_outer_panel(root: Node3D, label: String, pos: Vector3, size: Vector3, accent_mat: Material, matte_mat: Material) -> void:
    var panel := _add_box(root, size, matte_mat, pos)
    panel.name = "ArenaCompositionPanelRail_%s_Base" % label
    panel.set_meta("combat_visual_channel", "arena_readability")
    panel.set_meta("composition_role", "static_asset_board_panel")
    var top := _add_box(root, Vector3(size.x, 0.010, 0.030), accent_mat, pos + Vector3(0, 0.026, -size.z * 0.46))
    top.name = "ArenaCompositionPanelRail_%s_Top" % label
    top.set_meta("combat_visual_channel", "arena_readability")
    var bottom := _add_box(root, Vector3(size.x, 0.010, 0.030), accent_mat, pos + Vector3(0, 0.028, size.z * 0.46))
    bottom.name = "ArenaCompositionPanelRail_%s_Bottom" % label
    bottom.set_meta("combat_visual_channel", "arena_readability")

func _build_arena_relic_showcase_set() -> void:
    var root := Node3D.new()
    root.name = "ArenaRelicShowcaseSet"
    root.set_meta("combat_visual_channel", "arena_readability")
    root.set_meta("material_grade", "low_glare_static_relic_showcase")
    root.set_meta("performance_profile", "static_no_lights")
    root.set_meta("composition_role", "shop_equipment_reference_board")
    add_child(root)

    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var y := 0.540
    var base_mat := _mat("relic_showcase_shadow_stone", Color(0.012, 0.011, 0.025, 0.34), 0.0, true, true)
    var socket_mat := _texture_mat("relic_showcase_plated_metal", _hextech_metal_texture_path(), Color(0.155, 0.150, 0.205), 0.0, true, false, Vector3(1.4, 1.0, 1.0))
    var trim_mat := _mat("relic_showcase_burnished_gold_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.30), 0.0, true, true)
    var bridge_mat := _mat("relic_showcase_build_route_matte", Color(0.36, 0.82, 1.0, 0.22), 0.0, true, true)
    var dark_mat := _mat("relic_showcase_dark_detail", Color(0.018, 0.014, 0.034, 0.42), 0.0, true, true)

    var slot_specs := [
        ["blade", Vector3(-7.50, y, half_z - 1.48), 180.0, HEXTECH_GOLD],
        ["blaster", Vector3(-4.50, y, half_z - 1.48), 180.0, HEXTECH_BLUE],
        ["orb", Vector3(-1.50, y, half_z - 1.48), 180.0, VOID_PURPLE],
        ["shield", Vector3(1.50, y, half_z - 1.48), 180.0, Color(0.50, 0.88, 1.0)],
        ["staff", Vector3(4.50, y, half_z - 1.48), 180.0, Color(0.38, 1.0, 0.48)],
        ["mask", Vector3(7.50, y, half_z - 1.48), 180.0, DANGER_RED]
    ]
    for i in range(slot_specs.size()):
        var spec: Array = slot_specs[i]
        var archetype := str(spec[0])
        var pos: Vector3 = spec[1]
        var color: Color = spec[3]
        _add_relic_showcase_slot(root, i, archetype, pos, float(spec[2]), color, base_mat, socket_mat, trim_mat, dark_mat)
        if i < slot_specs.size() - 1:
            var next_spec: Array = slot_specs[i + 1]
            var next_pos: Vector3 = next_spec[1]
            var mid := (pos + next_pos) * 0.5 + Vector3(0, 0.030, 0)
            var bridge := _add_box(root, Vector3(1.06, 0.010, 0.036), bridge_mat, mid)
            bridge.name = "ArenaRelicShowcaseBuildRoute_%02d" % i
            bridge.set_meta("combat_visual_channel", "arena_readability")
            bridge.set_meta("composition_role", "shop_build_route")

    var reward_colors := [
        Color(0.38, 1.0, 0.48),
        Color(0.42, 0.86, 1.0),
        VOID_PURPLE,
        DANGER_RED,
        HEXTECH_GOLD
    ]
    for i in range(reward_colors.size()):
        var color: Color = reward_colors[i]
        var x := half_x - 2.15
        var z := -4.60 + float(i) * 2.22
        _add_relic_showcase_reward_shard(root, i, Vector3(x, 0.300, z), -90.0, color, base_mat, trim_mat, dark_mat)

func _add_relic_showcase_slot(root: Node3D, index: int, archetype: String, pos: Vector3, yaw: float, color: Color, base_mat: Material, socket_mat: Material, trim_mat: Material, dark_mat: Material) -> void:
    var slot := Node3D.new()
    slot.name = "ArenaRelicShowcaseSlot_%02d" % index
    slot.position = pos
    slot.rotation_degrees = Vector3(0, yaw, 0)
    slot.set_meta("combat_visual_channel", "arena_readability")
    slot.set_meta("composition_role", "equipment_build_relic_slot")
    slot.set_meta("item_archetype", archetype)
    root.add_child(slot)

    var accent_mat := _mat("relic_showcase_accent_" + archetype + "_" + color.to_html(false), Color(color.r, color.g, color.b, 0.28), 0.0, true, true)
    var backplate := _add_cylinder_segments(slot, 0.68, 0.014, 6, base_mat, Vector3(0, 0.000, 0), Vector3(0, 30, 0))
    backplate.name = "ArenaRelicShowcaseSlotBackplate_%02d" % index
    backplate.set_meta("combat_visual_channel", "arena_readability")
    var frame := _add_cylinder_segments(slot, 0.54, 0.012, 6, trim_mat, Vector3(0, 0.026, 0), Vector3(0, 30, 0))
    frame.name = "ArenaRelicShowcaseItemFrame_%02d" % index
    frame.set_meta("combat_visual_channel", "arena_readability")
    var socket := _add_box(slot, Vector3(0.74, 0.060, 0.42), socket_mat, Vector3(0, 0.055, 0))
    socket.name = "ArenaRelicShowcaseItemSocket_%02d" % index
    socket.set_meta("combat_visual_channel", "arena_readability")
    var shadow := _add_box(slot, Vector3(0.98, 0.010, 0.075), dark_mat, Vector3(0, 0.090, 0.30))
    shadow.name = "ArenaRelicShowcaseItemShadow_%02d" % index
    shadow.set_meta("combat_visual_channel", "arena_readability")

    var item := Node3D.new()
    item.name = "ArenaRelicShowcaseItem_%02d_%s" % [index, archetype.capitalize()]
    item.set_meta("combat_visual_channel", "arena_readability")
    item.set_meta("composition_role", "equipment_icon_silhouette")
    item.set_meta("item_archetype", archetype)
    slot.add_child(item)
    _add_relic_showcase_item(item, archetype, accent_mat, trim_mat, dark_mat)

func _add_relic_showcase_item(item: Node3D, archetype: String, accent_mat: Material, trim_mat: Material, dark_mat: Material) -> void:
    match archetype:
        "blade":
            var blade := _add_box(item, Vector3(0.110, 0.520, 0.050), trim_mat, Vector3(0, 0.395, 0), Vector3(0, 0, -18))
            blade.name = "ArenaRelicShowcaseBladeEdge"
            _add_box(item, Vector3(0.280, 0.070, 0.060), accent_mat, Vector3(0, 0.170, 0.015))
            _add_box(item, Vector3(0.060, 0.160, 0.050), dark_mat, Vector3(0, 0.095, 0.020))
        "blaster":
            var barrel := _add_cylinder_segments(item, 0.080, 0.520, 8, trim_mat, Vector3(0.050, 0.310, 0), Vector3(90, 0, 0))
            barrel.name = "ArenaRelicShowcaseBlasterBarrel"
            _add_box(item, Vector3(0.440, 0.160, 0.140), accent_mat, Vector3(-0.110, 0.260, 0))
            _add_box(item, Vector3(0.120, 0.240, 0.080), dark_mat, Vector3(-0.250, 0.105, 0.020), Vector3(0, 0, 18))
        "orb":
            var orb := _add_sphere(item, 0.185, accent_mat, Vector3(0, 0.300, 0))
            orb.name = "ArenaRelicShowcaseOrbCore"
            _add_cylinder_segments(item, 0.300, 0.012, 24, trim_mat, Vector3(0, 0.300, 0), Vector3(90, 0, 0))
            _add_cylinder_segments(item, 0.260, 0.010, 8, dark_mat, Vector3(0, 0.302, 0), Vector3(0, 22.5, 0))
        "shield":
            var face := _add_cylinder_segments(item, 0.275, 0.055, 6, accent_mat, Vector3(0, 0.285, 0), Vector3(90, 30, 0))
            face.name = "ArenaRelicShowcaseShieldFace"
            _add_box(item, Vector3(0.460, 0.040, 0.052), trim_mat, Vector3(0, 0.315, 0.030))
            _add_box(item, Vector3(0.055, 0.360, 0.046), dark_mat, Vector3(0, 0.286, 0.040))
        "staff":
            var shaft := _add_box(item, Vector3(0.060, 0.620, 0.050), trim_mat, Vector3(0, 0.280, 0), Vector3(0, 0, -10))
            shaft.name = "ArenaRelicShowcaseStaffShaft"
            _add_tapered_cylinder(item, 0.135, 0.040, 0.230, 6, accent_mat, Vector3(0.070, 0.600, 0), Vector3(0, 30, 0))
            _add_cylinder_segments(item, 0.210, 0.010, 6, dark_mat, Vector3(0.070, 0.485, 0), Vector3(0, 30, 0))
        _:
            var mask := _add_cylinder_segments(item, 0.260, 0.050, 6, accent_mat, Vector3(0, 0.300, 0), Vector3(90, 30, 0))
            mask.name = "ArenaRelicShowcaseMaskFace"
            _add_box(item, Vector3(0.070, 0.250, 0.044), trim_mat, Vector3(-0.100, 0.300, 0.040), Vector3(0, 0, -18))
            _add_box(item, Vector3(0.070, 0.250, 0.044), trim_mat, Vector3(0.100, 0.300, 0.040), Vector3(0, 0, 18))
            _add_cylinder_segments(item, 0.050, 0.032, 8, dark_mat, Vector3(-0.075, 0.345, 0.070), Vector3(90, 0, 0))
            _add_cylinder_segments(item, 0.050, 0.032, 8, dark_mat, Vector3(0.075, 0.345, 0.070), Vector3(90, 0, 0))

func _add_relic_showcase_reward_shard(root: Node3D, index: int, pos: Vector3, yaw: float, color: Color, base_mat: Material, trim_mat: Material, dark_mat: Material) -> void:
    var shard := Node3D.new()
    shard.name = "ArenaRelicShowcaseRewardShard_%02d" % index
    shard.position = pos
    shard.rotation_degrees = Vector3(0, yaw, 0)
    shard.set_meta("combat_visual_channel", "arena_readability")
    shard.set_meta("composition_role", "reward_pickup_language_reference")
    root.add_child(shard)
    var crystal_mat := _mat("relic_showcase_reward_crystal_" + color.to_html(false), Color(color.r, color.g, color.b, 0.70), 0.0, true)
    _add_cylinder_segments(shard, 0.340, 0.012, 6, base_mat, Vector3(0, 0.000, 0), Vector3(0, 30, 0)).name = "ArenaRelicShowcaseRewardShardBackplate"
    _add_cylinder_segments(shard, 0.255, 0.010, 6, trim_mat, Vector3(0, 0.022, 0), Vector3(0, 30, 0)).name = "ArenaRelicShowcaseRewardShardFrame"
    _add_tapered_cylinder(shard, 0.105, 0.030, 0.300, 6, crystal_mat, Vector3(0, 0.210, 0), Vector3(0, 30, 0)).name = "ArenaRelicShowcaseRewardShardCrystal"
    _add_box(shard, Vector3(0.390, 0.010, 0.040), dark_mat, Vector3(0, 0.050, 0.240)).name = "ArenaRelicShowcaseRewardShardMatte"

func _build_hextech_frame() -> void:
    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var frame_mat := _mat("arena_frame_stone", Color(0.038, 0.034, 0.056), 0.02, true)
    var bevel_mat := _mat("arena_frame_bevel", Color(0.090, 0.074, 0.110), 0.04, true)
    var gold_mat := _mat("arena_gold_trim", HEXTECH_GOLD, 0.16, true)
    var blue_mat := _mat("arena_blue_channel", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.72), 0.90, true, true)
    _add_box(self, Vector3(half_x * 2.0, 0.34, 0.62), frame_mat, Vector3(0, 0.16, -half_z + 0.18))
    _add_box(self, Vector3(half_x * 2.0, 0.34, 0.62), frame_mat, Vector3(0, 0.16, half_z - 0.18))
    _add_box(self, Vector3(0.62, 0.34, half_z * 2.0), frame_mat, Vector3(-half_x + 0.18, 0.16, 0))
    _add_box(self, Vector3(0.62, 0.34, half_z * 2.0), frame_mat, Vector3(half_x - 0.18, 0.16, 0))
    _add_box(self, Vector3(half_x * 1.54, 0.065, 0.11), gold_mat, Vector3(0, 0.42, -half_z + 0.86))
    _add_box(self, Vector3(half_x * 1.54, 0.065, 0.11), gold_mat, Vector3(0, 0.42, half_z - 0.86))
    _add_box(self, Vector3(0.11, 0.065, half_z * 1.54), gold_mat, Vector3(-half_x + 0.86, 0.42, 0))
    _add_box(self, Vector3(0.11, 0.065, half_z * 1.54), gold_mat, Vector3(half_x - 0.86, 0.42, 0))
    _add_box(self, Vector3(half_x * 1.10, 0.035, 0.055), blue_mat, Vector3(0, 0.48, -half_z + 1.28))
    _add_box(self, Vector3(half_x * 1.10, 0.035, 0.055), blue_mat, Vector3(0, 0.48, half_z - 1.28))
    _add_box(self, Vector3(0.055, 0.035, half_z * 1.10), blue_mat, Vector3(-half_x + 1.28, 0.48, 0))
    _add_box(self, Vector3(0.055, 0.035, half_z * 1.10), blue_mat, Vector3(half_x - 1.28, 0.48, 0))
    for sx in [-1.0, 1.0]:
        for sz in [-1.0, 1.0]:
            var corner := Vector3(sx * (half_x - 2.0), 0.40, sz * (half_z - 1.55))
            _add_box(self, Vector3(5.8, 0.18, 0.24), gold_mat, corner, Vector3(0, sx * sz * 36.0, 0))
            _add_box(self, Vector3(4.8, 0.24, 0.42), bevel_mat, corner + Vector3(-sx * 0.10, -0.11, -sz * 0.10), Vector3(0, sx * sz * 36.0, 0))
    _build_frame_power_nodes(half_x, half_z, frame_mat, bevel_mat, gold_mat, blue_mat)

func _build_frame_power_nodes(half_x: float, half_z: float, frame_mat: Material, bevel_mat: Material, gold_mat: Material, blue_mat: Material) -> void:
    for sx in [-1.0, 1.0]:
        for sz in [-1.0, 1.0]:
            var yaw: float = float(sx) * float(sz) * 36.0
            var corner := Vector3(sx * (half_x - 3.15), 0.32, sz * (half_z - 2.36))
            _add_box(self, Vector3(8.0, 0.42, 0.66), frame_mat, corner, Vector3(0, yaw, 0))
            _add_box(self, Vector3(7.1, 0.070, 0.13), gold_mat, corner + Vector3(-sx * 0.18, 0.26, -sz * 0.18), Vector3(0, yaw, 0))
            _add_box(self, Vector3(4.4, 0.040, 0.070), blue_mat, corner + Vector3(-sx * 0.42, 0.34, -sz * 0.42), Vector3(0, yaw, 0))

    var node_positions := [
        Vector3(0, 0, -half_z + 1.18),
        Vector3(0, 0, half_z - 1.18),
        Vector3(-half_x + 1.18, 0, 0),
        Vector3(half_x - 1.18, 0, 0),
        Vector3(-half_x * 0.50, 0, -half_z + 1.02),
        Vector3(half_x * 0.50, 0, half_z - 1.02)
    ]
    for i in range(node_positions.size()):
        var p: Vector3 = node_positions[i]
        _add_cylinder_segments(self, 0.62, 0.15, 8, bevel_mat, p + Vector3(0, 0.28, 0), Vector3(0, 22.5, 0))
        _add_cylinder_segments(self, 0.45, 0.045, 24, blue_mat, p + Vector3(0, 0.40, 0))
        _add_cylinder_segments(self, 0.72, 0.020, 24, _mat("frame_node_aura", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.22), 0.70, true, true), p + Vector3(0, 0.46, 0))

    var lane_mat := _mat("floor_energy_lane", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.20), 0.82, true, true)
    _add_box(self, Vector3(half_x * 1.10, 0.016, 0.040), lane_mat, Vector3(0, 0.086, 0))
    _add_box(self, Vector3(0.040, 0.016, half_z * 1.10), lane_mat, Vector3(0, 0.088, 0))
    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        var pos := Vector3(cos(angle) * 7.2, 0.090, sin(angle) * 4.4)
        _add_box(self, Vector3(5.0, 0.014, 0.035), _mat("floor_diagonal_lane", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.18), 0.40, true, true), pos, Vector3(0, -rad_to_deg(angle), 0))

func _build_arena_perimeter_citadel_set() -> void:
    var root := Node3D.new()
    root.name = "ArenaPerimeterCitadelSet"
    add_child(root)

    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var wall_mat := _texture_mat("citadel_wall_metal", _hextech_metal_texture_path(), Color(0.155, 0.158, 0.205), 0.04, true, false, Vector3(1.2, 1.0, 1.0))
    var dark_mat := _mat("citadel_wall_dark", Color(0.026, 0.024, 0.044), 0.03, true)
    var bevel_mat := _mat("citadel_wall_bevel", Color(0.074, 0.064, 0.096), 0.06, true)
    var trim_mat := _mat("citadel_wall_gold_trim", HEXTECH_GOLD, 0.22, true)
    var blue_mat := _mat("citadel_wall_blue_shield", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.40), 0.95, true, true)
    var void_mat := _mat("citadel_wall_void_shield", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.38), 0.98, true, true)

    _add_perimeter_wall_span(root, "north", Vector3(0, 0, -half_z + 0.74), 0.0, half_x * 1.72, HEXTECH_BLUE, wall_mat, dark_mat, bevel_mat, trim_mat, blue_mat)
    _add_perimeter_wall_span(root, "south", Vector3(0, 0, half_z - 0.74), 180.0, half_x * 1.72, VOID_PURPLE, wall_mat, dark_mat, bevel_mat, trim_mat, void_mat)
    _add_perimeter_wall_span(root, "west", Vector3(-half_x + 0.74, 0, 0), 90.0, half_z * 1.56, HEXTECH_BLUE, wall_mat, dark_mat, bevel_mat, trim_mat, blue_mat)
    _add_perimeter_wall_span(root, "east", Vector3(half_x - 0.74, 0, 0), -90.0, half_z * 1.56, VOID_PURPLE, wall_mat, dark_mat, bevel_mat, trim_mat, void_mat)

    var corner_specs := [
        [Vector3(-half_x + 2.18, 0, -half_z + 1.92), 40.0, HEXTECH_BLUE],
        [Vector3(half_x - 2.18, 0, -half_z + 1.92), -40.0, HEXTECH_BLUE],
        [Vector3(-half_x + 2.18, 0, half_z - 1.92), -40.0, VOID_PURPLE],
        [Vector3(half_x - 2.18, 0, half_z - 1.92), 40.0, VOID_PURPLE]
    ]
    for i in range(corner_specs.size()):
        var spec: Array = corner_specs[i]
        _add_perimeter_citadel_tower(root, "corner_%d" % i, spec[0], float(spec[1]), spec[2], wall_mat, bevel_mat, trim_mat)

    var node_specs := [
        [Vector3(-half_x * 0.42, 0, -half_z + 1.04), HEXTECH_BLUE, 0.0],
        [Vector3(half_x * 0.42, 0, -half_z + 1.04), HEXTECH_BLUE, 0.0],
        [Vector3(-half_x * 0.42, 0, half_z - 1.04), VOID_PURPLE, 180.0],
        [Vector3(half_x * 0.42, 0, half_z - 1.04), VOID_PURPLE, 180.0],
        [Vector3(-half_x + 1.04, 0, -half_z * 0.36), HEXTECH_BLUE, 90.0],
        [Vector3(-half_x + 1.04, 0, half_z * 0.36), HEXTECH_BLUE, 90.0],
        [Vector3(half_x - 1.04, 0, -half_z * 0.36), VOID_PURPLE, -90.0],
        [Vector3(half_x - 1.04, 0, half_z * 0.36), VOID_PURPLE, -90.0]
    ]
    for i in range(node_specs.size()):
        var node_spec: Array = node_specs[i]
        _add_perimeter_energy_node(root, i, node_spec[0], float(node_spec[2]), node_spec[1], bevel_mat, trim_mat)

    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        var pos := Vector3(cos(angle) * (half_x - 3.0), 0.0, sin(angle) * (half_z - 2.4))
        _add_perimeter_diagonal_buttress(root, i, pos, -rad_to_deg(angle) + 90.0, wall_mat, trim_mat, blue_mat if i < 2 else void_mat)

func _add_perimeter_wall_span(parent: Node3D, label: String, pos: Vector3, yaw: float, length: float, color: Color, wall_mat: Material, dark_mat: Material, bevel_mat: Material, trim_mat: Material, shield_mat: Material) -> void:
    var span := Node3D.new()
    span.name = "PerimeterWallSpan_" + label
    span.position = pos
    span.rotation_degrees = Vector3(0, yaw, 0)
    parent.add_child(span)

    _add_box(span, Vector3(length, 0.56, 0.68), dark_mat, Vector3(0, 0.250, 0))
    _add_box(span, Vector3(length * 0.98, 0.28, 0.46), wall_mat, Vector3(0, 0.520, -0.03))
    _add_box(span, Vector3(length * 0.92, 0.070, 0.11), trim_mat, Vector3(0, 0.720, -0.02))
    var rail := Node3D.new()
    rail.name = "PerimeterShieldRail"
    rail.set_meta("perimeter_shield_rail", true)
    rail.set_meta("color_phase", color.to_html(false))
    span.add_child(rail)
    _add_box(rail, Vector3(length * 0.78, 0.040, 0.070), shield_mat, Vector3(0, 0.790, -0.12))
    _add_box(rail, Vector3(length * 0.64, 0.024, 0.038), _mat("citadel_wall_inner_shield_" + label, Color(color.lightened(0.16).r, color.lightened(0.16).g, color.lightened(0.16).b, 0.34), 1.04, true, true), Vector3(0, 0.832, -0.16))

    var notch_count := 6
    for i in range(notch_count):
        var t := -0.5 + float(i) / float(notch_count - 1)
        _add_box(span, Vector3(0.24, 0.18, 0.22), bevel_mat, Vector3(t * length * 0.82, 0.855, -0.02))

func _add_perimeter_citadel_tower(parent: Node3D, label: String, pos: Vector3, yaw: float, color: Color, wall_mat: Material, bevel_mat: Material, trim_mat: Material) -> void:
    var tower := Node3D.new()
    tower.name = "PerimeterCitadelTower_" + label
    tower.position = pos
    tower.rotation_degrees = Vector3(0, yaw, 0)
    parent.add_child(tower)

    var glow_mat := _mat("citadel_tower_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.46), 1.04, true, true)
    _add_cylinder_segments(tower, 1.18, 0.24, 8, wall_mat, Vector3(0, 0.140, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(tower, 0.96, 0.070, 8, trim_mat, Vector3(0, 0.310, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(tower, 0.68, 0.86, 8, bevel_mat, Vector3(0, 0.730, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(tower, 0.78, 0.034, 24, glow_mat, Vector3(0, 1.178, 0))
    var crystal := _add_crystal(tower, 0.22, 0.82, color, Vector3(0, 1.54, 0), Vector3(0, 30, 0))
    crystal.name = "PerimeterCitadelCrystal"
    for side in [-1.0, 1.0]:
        _add_box(tower, Vector3(0.14, 0.62, 0.36), trim_mat, Vector3(side * 0.74, 0.68, 0.10), Vector3(0, side * 10.0, side * 18.0))
        _add_box(tower, Vector3(0.080, 0.12, 0.76), glow_mat, Vector3(side * 0.82, 0.98, 0.10), Vector3(0, side * 20.0, 0))

func _add_perimeter_energy_node(parent: Node3D, index: int, pos: Vector3, yaw: float, color: Color, bevel_mat: Material, trim_mat: Material) -> void:
    var node := Node3D.new()
    node.name = "PerimeterEnergyNode_%d" % index
    node.position = pos
    node.rotation_degrees = Vector3(0, yaw, 0)
    node.set_meta("perimeter_energy_node", true)
    node.set_meta("index", index)
    parent.add_child(node)

    var glow_mat := _mat("perimeter_energy_node_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.46), 1.05, true, true)
    var hot_mat := _mat("perimeter_energy_node_hot_" + color.to_html(false), color.lightened(0.18), 1.28, true)
    _add_cylinder_segments(node, 0.48, 0.060, 8, bevel_mat, Vector3(0, 0.760, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(node, 0.36, 0.028, 24, glow_mat, Vector3(0, 0.822, 0))
    var core := _add_sphere(node, 0.082, hot_mat, Vector3(0, 0.930, 0))
    core.name = "PerimeterEnergyCore"
    _add_box(node, Vector3(0.92, 0.018, 0.050), trim_mat, Vector3(0, 0.788, -0.20))
    _add_box(node, Vector3(0.70, 0.014, 0.034), glow_mat, Vector3(0, 0.846, -0.26))

func _add_perimeter_diagonal_buttress(parent: Node3D, index: int, pos: Vector3, yaw: float, wall_mat: Material, trim_mat: Material, shield_mat: Material) -> void:
    var buttress := Node3D.new()
    buttress.name = "PerimeterDiagonalButtress_%d" % index
    buttress.position = pos
    buttress.rotation_degrees = Vector3(0, yaw, 0)
    parent.add_child(buttress)
    _add_box(buttress, Vector3(4.4, 0.34, 0.38), wall_mat, Vector3(0, 0.430, 0))
    _add_box(buttress, Vector3(3.8, 0.044, 0.070), trim_mat, Vector3(0, 0.644, 0))
    _add_box(buttress, Vector3(2.6, 0.026, 0.044), shield_mat, Vector3(0, 0.706, 0))

func _build_center_plate() -> void:
    var base_mat := _mat("center_plate_dark", Color(0.052, 0.052, 0.080), 0.02, true)
    var trim_mat := _mat("center_plate_gold", HEXTECH_GOLD, 0.22, true)
    var core_mat := _mat("center_plate_core", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.54), 1.1, true, true)
    _add_cylinder_segments(self, 3.35, 0.09, 8, base_mat, Vector3(0, 0.075, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(self, 2.62, 0.075, 8, _mat("center_plate_inner", Color(0.072, 0.070, 0.110), 0.04, true), Vector3(0, 0.145, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(self, 2.96, 0.026, 8, trim_mat, Vector3(0, 0.218, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(self, 1.22, 0.034, 32, core_mat, Vector3(0, 0.248, 0))
    for i in range(8):
        var angle := TAU * float(i) / 8.0
        var pos := Vector3(cos(angle) * 2.06, 0.275, sin(angle) * 2.06)
        _add_box(self, Vector3(0.54, 0.035, 0.055), core_mat, pos, Vector3(0, -rad_to_deg(angle), 0))

func _build_arena_path_guides() -> void:
    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var blue_lane := _mat("arena_path_blue_lane", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.24), 0.86, true, true)
    var gold_lane := _mat("arena_path_gold_lane", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24), 0.62, true, true)
    var void_lane := _mat("arena_path_void_lane", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.22), 0.82, true, true)

    var lane_y := 0.118
    _add_box(self, Vector3(half_x * 0.92, 0.012, 0.040), blue_lane, Vector3(-half_x * 0.32, lane_y, 0))
    _add_box(self, Vector3(half_x * 0.92, 0.012, 0.040), void_lane, Vector3(half_x * 0.32, lane_y + 0.004, 0))
    _add_box(self, Vector3(0.040, 0.012, half_z * 0.94), blue_lane, Vector3(0, lane_y + 0.002, -half_z * 0.30))
    _add_box(self, Vector3(0.040, 0.012, half_z * 0.94), void_lane, Vector3(0, lane_y + 0.006, half_z * 0.30))

    for i in range(8):
        var angle := TAU * float(i) / 8.0
        var color_mat := gold_lane if i % 2 == 0 else blue_lane
        var pos := Vector3(cos(angle) * 5.35, lane_y + 0.010, sin(angle) * 3.35)
        _add_box(self, Vector3(1.18, 0.010, 0.040), color_mat, pos, Vector3(0, -rad_to_deg(angle) + 90.0, 0))
        if i % 2 == 0:
            _add_cylinder_segments(self, 0.18, 0.018, 6, color_mat, pos + Vector3(0, 0.018, 0), Vector3(0, 30, 0))

    var oct_points := []
    for i in range(8):
        var angle := TAU * float(i) / 8.0 + PI * 0.125
        oct_points.append(Vector3(cos(angle) * 4.95, lane_y + 0.018, sin(angle) * 3.10))
    for i in range(oct_points.size()):
        var p1: Vector3 = oct_points[i]
        var p2: Vector3 = oct_points[(i + 1) % oct_points.size()]
        var mid := (p1 + p2) * 0.5
        var delta := p2 - p1
        var length := sqrt(delta.x * delta.x + delta.z * delta.z)
        var yaw := -rad_to_deg(atan2(delta.z, delta.x))
        _add_box(self, Vector3(length, 0.010, 0.036), gold_lane if i % 2 == 0 else void_lane, mid, Vector3(0, yaw, 0))

    for side in [-1.0, 1.0]:
        var x: float = float(side) * (half_x - 4.9)
        for z_index in range(3):
            var z: float = -4.8 + float(z_index) * 4.8
            _add_box(self, Vector3(1.55, 0.010, 0.042), void_lane if float(side) > 0.0 else blue_lane, Vector3(x, lane_y + 0.012, z), Vector3(0, float(side) * 32.0, 0))
    for side in [-1.0, 1.0]:
        var z: float = float(side) * (half_z - 3.6)
        for x_index in range(4):
            var x: float = -7.2 + float(x_index) * 4.8
            _add_box(self, Vector3(1.40, 0.010, 0.040), void_lane if float(side) > 0.0 else blue_lane, Vector3(x, lane_y + 0.014, z), Vector3(0, float(side) * -28.0, 0))

func _build_arena_floor_inlay_set() -> void:
    var root := Node3D.new()
    root.name = "ArenaFloorInlaySet"
    add_child(root)

    var gold_mat := _mat("floor_inlay_burnished_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.34), 0.62, true, true)
    var blue_mat := _mat("floor_inlay_hextech_blue", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.34), 0.96, true, true)
    var void_mat := _mat("floor_inlay_void_purple", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.30), 0.92, true, true)
    var dark_mat := _mat("floor_inlay_shadow_groove", Color(0.010, 0.009, 0.020, 0.36), 0.02, true, true)
    var green_mat := _mat("floor_inlay_reward_green", Color(0.34, 1.0, 0.44, 0.32), 0.86, true, true)

    var inner_radius := 4.25
    for i in range(8):
        var angle := TAU * float(i) / 8.0 + PI * 0.125
        var pos := Vector3(cos(angle) * inner_radius, 0.132, sin(angle) * inner_radius)
        var span := _add_box(root, Vector3(1.76, 0.012, 0.046), gold_mat if i % 2 == 0 else blue_mat, pos, Vector3(0, -rad_to_deg(angle) + 90.0, 0))
        span.name = "FloorInlayOctagonSpan_%d" % i

    var radial_specs := [
        [0.0, HEXTECH_BLUE, 6.4],
        [45.0, HEXTECH_GOLD, 5.7],
        [90.0, HEXTECH_BLUE, 6.0],
        [135.0, VOID_PURPLE, 5.7],
        [180.0, VOID_PURPLE, 6.4],
        [225.0, VOID_PURPLE, 5.7],
        [270.0, Color(0.34, 1.0, 0.44), 6.0],
        [315.0, HEXTECH_BLUE, 5.7]
    ]
    for i in range(radial_specs.size()):
        var spec: Array = radial_specs[i]
        var yaw := float(spec[0])
        var color: Color = spec[1]
        var length := float(spec[2])
        var mat := _mat("floor_inlay_radial_" + color.to_html(false), Color(color.r, color.g, color.b, 0.24), 0.74, true, true)
        var angle := deg_to_rad(yaw)
        var pos := Vector3(cos(angle) * (inner_radius + length * 0.42), 0.128 + float(i % 3) * 0.002, sin(angle) * (inner_radius + length * 0.42))
        var conduit := _add_box(root, Vector3(length, 0.010, 0.032), mat, pos, Vector3(0, -yaw, 0))
        conduit.name = "FloorInlayRadialConduit_%d" % i

    var shard_specs := [
        [Vector3(-8.4, 0.142, -4.7), 28.0, blue_mat],
        [Vector3(8.4, 0.144, -4.7), -28.0, blue_mat],
        [Vector3(-8.1, 0.146, 4.9), -32.0, void_mat],
        [Vector3(8.1, 0.148, 4.9), 32.0, void_mat],
        [Vector3(-2.8, 0.150, 6.1), 8.0, green_mat],
        [Vector3(2.8, 0.150, -6.1), -8.0, green_mat]
    ]
    for i in range(shard_specs.size()):
        var shard: Array = shard_specs[i]
        var shard_mesh := _add_box(root, Vector3(0.86, 0.012, 0.050), shard[2], shard[0], Vector3(0, float(shard[1]), 0))
        shard_mesh.name = "FloorInlayRunicShard_%d" % i

    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var corner_specs := [
        [Vector3(-half_x + 4.8, 0.120, -half_z + 4.1), HEXTECH_BLUE, 36.0],
        [Vector3(half_x - 4.8, 0.120, -half_z + 4.1), HEXTECH_BLUE, -36.0],
        [Vector3(-half_x + 4.8, 0.122, half_z - 4.1), VOID_PURPLE, -36.0],
        [Vector3(half_x - 4.8, 0.122, half_z - 4.1), VOID_PURPLE, 36.0]
    ]
    for i in range(corner_specs.size()):
        var spec: Array = corner_specs[i]
        var pos: Vector3 = spec[0]
        var color: Color = spec[1]
        var yaw := float(spec[2])
        var anchor := Node3D.new()
        anchor.name = "FloorInlayCornerAnchor_%d" % i
        anchor.position = pos
        anchor.rotation_degrees = Vector3(0, yaw, 0)
        root.add_child(anchor)
        var glow_mat := _mat("floor_inlay_corner_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.28), 0.86, true, true)
        _add_cylinder_segments(anchor, 0.62, 0.014, 6, dark_mat, Vector3(0, 0.010, 0), Vector3(0, 30, 0))
        _add_cylinder_segments(anchor, 0.42, 0.012, 6, glow_mat, Vector3(0, 0.026, 0), Vector3(0, 30, 0))
        var crystal := _add_crystal(anchor, 0.12, 0.44, color, Vector3(0, 0.310, 0), Vector3(0, 30, 0))
        crystal.name = "FloorInlayCornerCrystal"

func _build_arena_motion_rig() -> void:
    arena_motion_root = Node3D.new()
    arena_motion_root.name = "ArenaMotionRig"
    add_child(arena_motion_root)

    var center := Node3D.new()
    center.name = "Center"
    arena_motion_root.add_child(center)
    var spin_slow := Node3D.new()
    spin_slow.name = "SpinSlow"
    center.add_child(spin_slow)
    var spin_reverse := Node3D.new()
    spin_reverse.name = "SpinReverse"
    center.add_child(spin_reverse)
    var pulse := Node3D.new()
    pulse.name = "Pulse"
    center.add_child(pulse)

    var blue_ring := _mat("arena_motion_blue_ring", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.30), 0.98, true, true)
    var gold_ring := _mat("arena_motion_gold_ring", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.26), 0.72, true, true)
    var void_ring := _mat("arena_motion_void_ring", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.25), 0.92, true, true)
    var decal_path := _vfx_decal_texture_path()
    if decal_path != "":
        var decal_mat := _vfx_decal_mat("arena_center_vfx_decal", decal_path, Color(0.70, 0.94, 1.0, 0.22), 0.88, Vector3(0.25, 0.25, 1.0), Vector3.ZERO)
        var decal := _add_textured_plane(center, Vector2(5.20, 5.20), decal_mat, Vector3(0, 0.302, 0), Vector3(0, 45, 0))
        decal.name = "ArenaCenterVfxDecal"
    _add_cylinder_segments(spin_slow, 2.15, 0.012, 32, blue_ring, Vector3(0, 0.334, 0))
    _add_cylinder_segments(spin_slow, 1.42, 0.010, 6, gold_ring, Vector3(0, 0.350, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(spin_reverse, 1.84, 0.010, 8, void_ring, Vector3(0, 0.360, 0), Vector3(0, 22.5, 0))
    for i in range(8):
        var angle := TAU * float(i) / 8.0
        _add_box(spin_reverse, Vector3(0.16, 0.012, 0.58), _mat("arena_motion_center_tick", Color(0.78, 0.94, 1.0, 0.42), 1.0, true, true), Vector3(cos(angle) * 1.42, 0.370, sin(angle) * 1.42), Vector3(0, -rad_to_deg(angle), 0))
    _add_cylinder_segments(pulse, 0.86, 0.014, 24, _mat("arena_motion_core_pulse", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.32), 1.05, true, true), Vector3(0, 0.390, 0))
    _add_sphere(pulse, 0.11, _mat("arena_motion_core_spark", Color(0.82, 1.0, 1.0), 1.28, true), Vector3(0, 0.510, 0))

    var beacons := Node3D.new()
    beacons.name = "EdgeBeacons"
    arena_motion_root.add_child(beacons)
    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var beacon_positions := [
        Vector3(-half_x + 3.1, 0.0, -half_z + 2.7),
        Vector3(half_x - 3.1, 0.0, -half_z + 2.7),
        Vector3(-half_x + 3.1, 0.0, half_z - 2.7),
        Vector3(half_x - 3.1, 0.0, half_z - 2.7),
        Vector3(-half_x + 6.6, 0.0, 0.0),
        Vector3(half_x - 6.6, 0.0, 0.0),
        Vector3(0.0, 0.0, -half_z + 3.2),
        Vector3(0.0, 0.0, half_z - 3.2)
    ]
    for i in range(beacon_positions.size()):
        var beacon := Node3D.new()
        beacon.name = "Beacon_%d" % i
        beacon.position = beacon_positions[i]
        beacons.add_child(beacon)
        var color := HEXTECH_BLUE if i % 2 == 0 else VOID_PURPLE
        var beacon_mat := _mat("arena_motion_beacon_" + str(i), Color(color.r, color.g, color.b, 0.36), 0.98, true, true)
        var core_mat := _mat("arena_motion_beacon_core_" + str(i), color.lightened(0.18), 1.22, true)
        _add_cylinder_segments(beacon, 0.54, 0.012, 6, beacon_mat, Vector3(0, 0.248, 0), Vector3(0, 30, 0))
        _add_box(beacon, Vector3(0.88, 0.010, 0.048), beacon_mat, Vector3(0, 0.270, 0), Vector3(0, 0, 0))
        _add_box(beacon, Vector3(0.048, 0.010, 0.88), beacon_mat, Vector3(0, 0.272, 0), Vector3(0, 0, 0))
        var core := _add_sphere(beacon, 0.070, core_mat, Vector3(0, 0.392, 0))
        core.name = "Core"

func _sync_arena_motion(delta: float) -> void:
    if arena_motion_root == null:
        return
    var time := Time.get_ticks_msec() / 1000.0
    var center := arena_motion_root.get_node_or_null("Center") as Node3D
    if center != null:
        var slow := center.get_node_or_null("SpinSlow") as Node3D
        if slow != null:
            slow.rotation.y += delta * 0.18
        var reverse := center.get_node_or_null("SpinReverse") as Node3D
        if reverse != null:
            reverse.rotation.y -= delta * 0.30
        var pulse := center.get_node_or_null("Pulse") as Node3D
        if pulse != null:
            pulse.scale = Vector3.ONE * (1.0 + sin(time * 1.8) * 0.060)
        var decal := center.get_node_or_null("ArenaCenterVfxDecal") as Node3D
        if decal != null:
            decal.rotation.y -= delta * 0.075
            var decal_scale := 1.0 + sin(time * 1.25) * 0.030
            decal.scale = Vector3(decal_scale, 1.0, decal_scale)
    _sync_spawn_gateway_motion(delta, time)
    _sync_arena_ritual_towers(delta, time)
    _sync_arena_perimeter_citadel(delta, time)
    _sync_arena_objective_shrines(delta, time)
    var beacons := arena_motion_root.get_node_or_null("EdgeBeacons") as Node3D
    if beacons == null:
        return
    for i in range(beacons.get_child_count()):
        var beacon := beacons.get_child(i) as Node3D
        if beacon == null:
            continue
        beacon.rotation.y += delta * (0.22 + float(i % 3) * 0.045)
        var core := beacon.get_node_or_null("Core") as Node3D
        if core != null:
            core.position.y = 0.392 + sin(time * 1.55 + float(i)) * 0.035

func _build_survival_director_pressure_rig() -> void:
    if survival_director_root != null:
        return
    survival_director_root = Node3D.new()
    survival_director_root.name = "SurvivalDirectorPressureRig"
    survival_director_root.visible = false
    survival_director_root.set_meta("combat_visual_channel", "survival_pressure_warning")
    survival_director_root.set_meta("material_grade", "low_glare_survival_director")
    survival_director_root.set_meta("elite_squad_warning", true)
    survival_director_root.set_meta("boss_escalation_warning", true)
    survival_director_root.set_meta("escort_lane_warning", true)
    survival_director_root.set_meta("composition_readout", true)
    survival_director_root.position = _to3d(arena.get_center(), 0.0)
    add_child(survival_director_root)

    var matte := _mat("survival_director_matte", Color(0.0, 0.0, 0.0, 0.54), 0.0, true, true)
    var danger := _mat("survival_director_danger", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.50), 0.0, true, true)
    var void_mat := _mat("survival_director_void", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.34), 0.08, true, true)
    var gold := _mat("survival_director_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.34), 0.06, true, true)

    var base := _add_cylinder_segments(survival_director_root, 7.70, 0.008, 8, matte, Vector3(0, 0.118, 0), Vector3(0, 22.5, 0))
    base.name = "PressureSurgeArenaMatte"
    base.set_meta("combat_visual_channel", "survival_pressure_warning")
    var ring := _add_cylinder_segments(survival_director_root, 6.92, 0.010, 8, danger, Vector3(0, 0.148, 0), Vector3(0, 22.5, 0))
    ring.name = "PressureSurgeWarningRing"
    ring.set_meta("combat_visual_channel", "survival_pressure_warning")
    var needle := _add_box(survival_director_root, Vector3(0.18, 0.012, 3.15), danger, Vector3(0, 0.172, -3.82))
    needle.name = "PressureSurgeCountdownNeedle"
    needle.set_meta("combat_visual_channel", "survival_pressure_warning")
    var left_marker := _add_cylinder_segments(survival_director_root, 0.46, 0.012, 3, void_mat, Vector3(-1.05, 0.188, -4.72), Vector3(0, 30, 0))
    left_marker.name = "PressureSurgeEliteMarkerLeft"
    left_marker.set_meta("combat_visual_channel", "survival_pressure_warning")
    var right_marker := _add_cylinder_segments(survival_director_root, 0.46, 0.012, 3, void_mat, Vector3(1.05, 0.188, -4.72), Vector3(0, 30, 0))
    right_marker.name = "PressureSurgeEliteMarkerRight"
    right_marker.set_meta("combat_visual_channel", "survival_pressure_warning")
    var boss_marker := _add_box(survival_director_root, Vector3(1.12, 0.012, 0.16), gold, Vector3(0, 0.204, -5.24))
    boss_marker.name = "PressureSurgeBossEscalationBar"
    boss_marker.set_meta("combat_visual_channel", "survival_pressure_warning")

func _ensure_survival_director_composition_routes() -> Node3D:
    if survival_director_root == null:
        return null
    var existing := survival_director_root.get_node_or_null("PressureSurgeCompositionRoutes") as Node3D
    if existing != null:
        return existing

    var routes := Node3D.new()
    routes.name = "PressureSurgeCompositionRoutes"
    routes.visible = false
    routes.set_meta("combat_visual_channel", "survival_pressure_warning")
    routes.set_meta("composition_role", "surge_route_readout")
    routes.set_meta("route_lane_count", 4)
    routes.set_meta("threat_pip_count", 6)
    routes.set_meta("material_grade", "low_glare_survival_director")
    survival_director_root.add_child(routes)

    var lane_mat := _mat("survival_director_route_lane", Color(0.48, 0.18, 0.90, 0.28), 0.03, true, true)
    var melee_mat := _mat("survival_director_melee_pips", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.34), 0.04, true, true)
    var ranged_mat := _mat("survival_director_ranged_pips", Color(0.34, 0.82, 1.0, 0.30), 0.03, true, true)
    var reward_mat := _mat("survival_director_risk_reward_badge", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.30), 0.03, true, true)

    var left_lane := _add_box(routes, Vector3(0.16, 0.010, 5.35), lane_mat, Vector3(-2.92, 0.218, -1.10), Vector3(0, -18, 0))
    left_lane.name = "PressureSurgeEscortLaneLeft"
    left_lane.set_meta("combat_visual_channel", "survival_pressure_warning")
    left_lane.set_meta("composition_role", "escort_lane")
    var right_lane := _add_box(routes, Vector3(0.16, 0.010, 5.35), lane_mat, Vector3(2.92, 0.218, -1.10), Vector3(0, 18, 0))
    right_lane.name = "PressureSurgeEscortLaneRight"
    right_lane.set_meta("combat_visual_channel", "survival_pressure_warning")
    right_lane.set_meta("composition_role", "escort_lane")
    var melee_lane := _add_box(routes, Vector3(1.88, 0.010, 0.18), melee_mat, Vector3(0, 0.224, -4.28))
    melee_lane.name = "PressureSurgeMeleeLaneFront"
    melee_lane.set_meta("combat_visual_channel", "survival_pressure_warning")
    melee_lane.set_meta("composition_role", "front_melee_lane")
    var ranged_lane := _add_box(routes, Vector3(2.64, 0.010, 0.14), ranged_mat, Vector3(0, 0.224, -3.36))
    ranged_lane.name = "PressureSurgeRangedLaneBack"
    ranged_lane.set_meta("combat_visual_channel", "survival_pressure_warning")
    ranged_lane.set_meta("composition_role", "back_ranged_lane")
    var boss_bridge := _add_box(routes, Vector3(0.28, 0.010, 2.46), reward_mat, Vector3(0, 0.232, -4.52))
    boss_bridge.name = "PressureSurgeBossEscortBridge"
    boss_bridge.set_meta("combat_visual_channel", "survival_pressure_warning")
    boss_bridge.set_meta("composition_role", "boss_escort_bridge")
    var reward_badge := _add_cylinder_segments(routes, 0.34, 0.012, 6, reward_mat, Vector3(0, 0.240, -5.78), Vector3(0, 30, 0))
    reward_badge.name = "PressureSurgeRiskRewardBadge"
    reward_badge.set_meta("combat_visual_channel", "survival_pressure_warning")
    reward_badge.set_meta("composition_role", "elite_reward_risk")

    for i in range(3):
        var x := -0.58 + float(i) * 0.58
        var melee_pip := _add_cylinder_segments(routes, 0.18, 0.012, 3, melee_mat, Vector3(x, 0.238, -4.28), Vector3(0, 30, 0))
        melee_pip.name = "PressureSurgeMeleeThreatPip%d" % i
        melee_pip.set_meta("combat_visual_channel", "survival_pressure_warning")
        melee_pip.set_meta("composition_role", "melee_threat_pip")
        var ranged_pip := _add_cylinder_segments(routes, 0.15, 0.012, 4, ranged_mat, Vector3(x, 0.238, -3.36), Vector3(0, 45, 0))
        ranged_pip.name = "PressureSurgeRangedThreatPip%d" % i
        ranged_pip.set_meta("combat_visual_channel", "survival_pressure_warning")
        ranged_pip.set_meta("composition_role", "ranged_threat_pip")
    return routes

func _sync_survival_director_pressure() -> void:
    if survival_director_root == null or root_ref == null:
        return
    var timer_value = root_ref.get("pressure_surge_timer")
    if timer_value == null:
        survival_director_root.visible = false
        return
    var timer := float(timer_value)
    var elapsed := float(root_ref.get("elapsed"))
    var boss_alive := bool(root_ref.get("boss_alive"))
    var warning_window := 10.0 if not boss_alive else 14.0
    var readiness := clampf(1.0 - timer / warning_window, 0.0, 1.0)
    var pressure_level := clampi(1 + int(elapsed / 120.0) + (1 if boss_alive else 0), 1, 6)
    var active := elapsed >= 60.0 and timer <= warning_window
    survival_director_root.visible = active
    survival_director_root.set_meta("surge_readiness", readiness)
    survival_director_root.set_meta("next_surge_timer", timer)
    survival_director_root.set_meta("boss_escalation_active", boss_alive)
    survival_director_root.set_meta("composition_pressure_level", pressure_level)
    survival_director_root.set_meta("escort_pressure_level", pressure_level)
    if not active:
        var inactive_routes := survival_director_root.get_node_or_null("PressureSurgeCompositionRoutes") as Node3D
        if inactive_routes != null:
            inactive_routes.visible = false
        return
    var routes := _ensure_survival_director_composition_routes()
    if routes == null:
        return
    if readiness < 0.12:
        if routes != null:
            routes.visible = false
        return
    var time := Time.get_ticks_msec() / 1000.0
    var pulse := 0.88 + readiness * 0.22 + sin(time * (2.2 + readiness * 2.8)) * (0.012 + readiness * 0.022)
    survival_director_root.scale = Vector3(pulse, 1.0, pulse)
    survival_director_root.rotation.y = -time * (0.08 + readiness * 0.12)

    var ring := survival_director_root.get_node_or_null("PressureSurgeWarningRing") as Node3D
    if ring != null:
        ring.scale = Vector3.ONE * (0.90 + readiness * 0.22 + sin(time * 3.4) * 0.018)
    var needle := survival_director_root.get_node_or_null("PressureSurgeCountdownNeedle") as Node3D
    if needle != null:
        needle.rotation.y = -TAU * readiness
        needle.scale = Vector3(1.0 + readiness * 0.18, 1.0, 0.72 + readiness * 0.42)
    var left_marker := survival_director_root.get_node_or_null("PressureSurgeEliteMarkerLeft") as Node3D
    var right_marker := survival_director_root.get_node_or_null("PressureSurgeEliteMarkerRight") as Node3D
    for marker in [left_marker, right_marker]:
        if marker == null:
            continue
        marker.visible = readiness >= 0.28
        marker.rotation.y += 0.025 + readiness * 0.018
        marker.scale = Vector3.ONE * (0.92 + readiness * 0.28 + sin(time * 4.8) * 0.022)
    var boss_marker := survival_director_root.get_node_or_null("PressureSurgeBossEscalationBar") as Node3D
    if boss_marker != null:
        boss_marker.visible = boss_alive or readiness >= 0.70
        boss_marker.scale = Vector3(0.78 + readiness * 0.42, 1.0, 1.0)
    if routes != null:
        routes.visible = readiness >= 0.12
        routes.set_meta("surge_readiness", readiness)
        routes.set_meta("escort_pressure_level", pressure_level)
        routes.rotation.y = time * (0.018 + readiness * 0.040)
        routes.scale = Vector3.ONE * (0.92 + readiness * 0.12)
        var lane_names := [
            "PressureSurgeEscortLaneLeft",
            "PressureSurgeEscortLaneRight",
            "PressureSurgeMeleeLaneFront",
            "PressureSurgeRangedLaneBack"
        ]
        for lane_name in lane_names:
            var lane := routes.get_node_or_null(lane_name) as Node3D
            if lane == null:
                continue
            var front_lane := str(lane.name).find("Melee") != -1
            var back_lane := str(lane.name).find("Ranged") != -1
            lane.visible = readiness >= (0.22 if front_lane else 0.30 if back_lane else 0.16)
            lane.scale = Vector3(0.74 + readiness * 0.34, 1.0, 0.74 + readiness * 0.28)
        var boss_bridge := routes.get_node_or_null("PressureSurgeBossEscortBridge") as Node3D
        if boss_bridge != null:
            boss_bridge.visible = boss_alive
            boss_bridge.scale = Vector3(0.72 + readiness * 0.36, 1.0, 0.82 + readiness * 0.26)
        var reward_badge := routes.get_node_or_null("PressureSurgeRiskRewardBadge") as Node3D
        if reward_badge != null:
            reward_badge.visible = readiness >= 0.48 or boss_alive
            reward_badge.rotation.y -= 0.030 + readiness * 0.025
            reward_badge.scale = Vector3.ONE * (0.80 + readiness * 0.26 + sin(time * 3.6) * 0.018)
        for child in routes.get_children():
            var marker := child as Node3D
            if marker == null:
                continue
            var marker_name := str(marker.name)
            if not marker_name.begins_with("PressureSurgeMeleeThreatPip") and not marker_name.begins_with("PressureSurgeRangedThreatPip"):
                continue
            var idx := int(marker_name.substr(marker_name.length() - 1, 1))
            marker.visible = readiness >= 0.18 + float(idx) * 0.10
            marker.rotation.y += 0.035 + readiness * 0.028 + float(idx) * 0.004
            marker.scale = Vector3.ONE * (0.82 + readiness * 0.24 + sin(time * 4.0 + float(idx)) * 0.020)

func _sync_arena_ritual_towers(delta: float, time: float) -> void:
    var root := get_node_or_null("ArenaRitualTowerSet") as Node3D
    if root == null:
        return
    for i in range(root.get_child_count()):
        var tower := root.get_child(i) as Node3D
        if tower == null or not bool(tower.get_meta("ritual_tower", false)):
            continue
        var major := bool(tower.get_meta("ritual_major", false))
        var glyph := tower.get_node_or_null("RitualGlyph") as Node3D
        if glyph != null:
            glyph.rotation.y += delta * (0.24 if major else -0.16)
            var glyph_scale := 1.0 + sin(time * (1.05 if major else 1.35) + float(i) * 0.55) * (0.040 if major else 0.028)
            glyph.scale = Vector3(glyph_scale, 1.0, glyph_scale)
        var ring := tower.get_node_or_null("PulseRing") as Node3D
        if ring != null:
            ring.rotation.y -= delta * (0.18 if major else 0.28)
            var ring_scale := 1.0 + sin(time * 1.42 + float(i)) * (0.032 if major else 0.022)
            ring.scale = Vector3(ring_scale, 1.0, ring_scale)
        var crystal := tower.get_node_or_null("RitualCoreCrystal") as Node3D
        if crystal != null:
            crystal.rotation.y += delta * (0.20 if major else 0.12)

func _sync_arena_perimeter_citadel(delta: float, time: float) -> void:
    var root := get_node_or_null("ArenaPerimeterCitadelSet") as Node3D
    if root == null:
        return
    for child in root.get_children():
        var node := child as Node3D
        if node == null:
            continue
        if bool(node.get_meta("perimeter_energy_node", false)):
            var index := int(node.get_meta("index", 0))
            node.rotation.y += delta * (0.11 if index % 2 == 0 else -0.08)
            var core := node.get_node_or_null("PerimeterEnergyCore") as Node3D
            if core != null:
                core.position.y = 0.930 + sin(time * 1.9 + float(index) * 0.55) * 0.035
                core.scale = Vector3.ONE * (1.0 + sin(time * 3.1 + float(index)) * 0.080)
        var rail := node.get_node_or_null("PerimeterShieldRail") as Node3D
        if rail != null:
            var phase := float(node.get_index()) * 0.44
            var pulse := 1.0 + sin(time * 1.55 + phase) * 0.030
            rail.scale = Vector3(pulse, 1.0, 1.0 + (pulse - 1.0) * 0.30)

func _sync_arena_objective_shrines(delta: float, time: float) -> void:
    var root := get_node_or_null("ArenaObjectiveShrineSet") as Node3D
    if root == null:
        return
    for child in root.get_children():
        var shrine := child as Node3D
        if shrine == null or not bool(shrine.get_meta("objective_shrine", false)):
            continue
        var index := int(shrine.get_meta("index", 0))
        var shrine_type := str(shrine.get_meta("shrine_type", ""))
        var crystal := shrine.get_node_or_null("ObjectiveShrineCrystal") as Node3D
        if crystal != null:
            crystal.rotation.y += delta * (0.20 if shrine_type == "hextech" else -0.16 if shrine_type == "void" else 0.12)
            crystal.position.y = 0.440 + sin(time * (1.55 if shrine_type == "reward" else 1.28) + float(index) * 0.52) * 0.032
        var glow := shrine.get_node_or_null("ObjectiveShrineGlowRing") as Node3D
        if glow != null:
            var glow_pulse := 1.0 + sin(time * 1.9 + float(index) * 0.37) * 0.045
            glow.scale = Vector3(glow_pulse, 1.0, glow_pulse)
        var sigil := shrine.get_node_or_null("ObjectiveShrineSigil") as Node3D
        if sigil != null:
            sigil.rotation.y += delta * (0.18 if shrine_type == "hextech" else -0.14 if shrine_type == "void" else 0.10)

func _build_boss_pressure_rig() -> void:
    if boss_pressure_root != null:
        return
    boss_pressure_root = Node3D.new()
    boss_pressure_root.name = "BossPressureRig"
    boss_pressure_root.visible = false
    add_child(boss_pressure_root)

    var arena_ritual := Node3D.new()
    arena_ritual.name = "ArenaRitual"
    arena_ritual.position = _to3d(arena.get_center(), 0.0)
    boss_pressure_root.add_child(arena_ritual)

    var danger := _mat("boss_pressure_danger", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.20), 0.96, true, true)
    var void_mat := _mat("boss_pressure_void", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.18), 0.92, true, true)
    var gold := _mat("boss_pressure_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24), 0.62, true, true)
    _add_cylinder_segments(arena_ritual, 8.6, 0.012, 8, danger, Vector3(0, 0.072, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(arena_ritual, 6.4, 0.010, 8, void_mat, Vector3(0, 0.086, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(arena_ritual, 3.1, 0.010, 6, gold, Vector3(0, 0.100, 0), Vector3(0, 30, 0))
    for i in range(12):
        var angle := TAU * float(i) / 12.0
        var spoke_len := 1.2 if i % 3 == 0 else 0.72
        _add_box(arena_ritual, Vector3(0.11, 0.012, spoke_len), danger, Vector3(cos(angle) * 7.0, 0.112, sin(angle) * 4.2), Vector3(0, -rad_to_deg(angle), 0))
    for i in range(6):
        var crack_angle := TAU * float(i) / 6.0 + PI * 0.08
        _add_box(arena_ritual, Vector3(0.16, 0.010, 2.2), void_mat, Vector3(cos(crack_angle) * 4.4, 0.094, sin(crack_angle) * 2.8), Vector3(0, -rad_to_deg(crack_angle), 0))
    _build_boss_health_sigils(arena_ritual)
    _build_boss_cast_sigils(arena_ritual)
    _build_boss_domain_profiles(arena_ritual)
    _build_boss_arena_lockdown(arena_ritual)

    var boss_focus := Node3D.new()
    boss_focus.name = "BossFocus"
    boss_pressure_root.add_child(boss_focus)
    _add_cylinder_segments(boss_focus, 2.25, 0.014, 8, danger, Vector3(0, 0.128, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(boss_focus, 1.48, 0.012, 24, void_mat, Vector3(0, 0.150, 0))
    for i in range(8):
        var tick_angle := TAU * float(i) / 8.0
        _add_box(boss_focus, Vector3(0.16, 0.014, 0.78), danger, Vector3(cos(tick_angle) * 1.74, 0.166, sin(tick_angle) * 1.74), Vector3(0, -rad_to_deg(tick_angle), 0))

    _build_boss_pressure_signatures(boss_focus)
    _build_boss_cast_focus(boss_focus)
    _build_boss_cast_patterns(boss_focus)

func _build_boss_health_sigils(parent: Node3D) -> void:
    var sigils := Node3D.new()
    sigils.name = "BossHealthSigils"
    parent.add_child(sigils)
    var alive_mat := _mat("boss_health_sigil_alive", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.48), 0.86, true, true)
    var broken_mat := _mat("boss_health_sigil_broken", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.42), 1.05, true, true)
    var void_mat := _mat("boss_health_sigil_void", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.28), 0.92, true, true)
    for i in range(8):
        var angle := TAU * float(i) / 8.0 + PI * 0.125
        var sigil := Node3D.new()
        sigil.name = "BossHealthSigil" + str(i)
        sigil.set_meta("index", i)
        sigil.position = Vector3(cos(angle) * 7.45, 0.132, sin(angle) * 4.55)
        sigil.rotation.y = -angle
        sigils.add_child(sigil)

        var alive := Node3D.new()
        alive.name = "Alive"
        sigil.add_child(alive)
        _add_cylinder_segments(alive, 0.42, 0.012, 6, alive_mat, Vector3.ZERO, Vector3(0, 30, 0))
        _add_box(alive, Vector3(0.075, 0.014, 0.72), alive_mat, Vector3(0, 0.026, 0))
        _add_box(alive, Vector3(0.52, 0.014, 0.065), alive_mat, Vector3(0, 0.030, 0))

        var broken := Node3D.new()
        broken.name = "Broken"
        broken.visible = false
        sigil.add_child(broken)
        _add_cylinder_segments(broken, 0.46, 0.012, 3, void_mat, Vector3.ZERO, Vector3(0, 30, 0))
        _add_box(broken, Vector3(0.090, 0.014, 0.82), broken_mat, Vector3(-0.08, 0.028, 0.02), Vector3(0, -18, 0))
        _add_box(broken, Vector3(0.58, 0.014, 0.070), broken_mat, Vector3(0.08, 0.032, -0.02), Vector3(0, 18, 0))

func _build_boss_cast_sigils(parent: Node3D) -> void:
    var sigils := Node3D.new()
    sigils.name = "BossCastSigils"
    sigils.visible = false
    parent.add_child(sigils)
    var danger := _mat("boss_cast_sigil_danger", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.42), 1.12, true, true)
    var gold := _mat("boss_cast_sigil_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42), 0.86, true, true)
    var void_mat := _mat("boss_cast_sigil_void", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.34), 1.00, true, true)
    for i in range(6):
        var angle := TAU * float(i) / 6.0 + PI * 0.16
        var sigil := Node3D.new()
        sigil.name = "BossCastSigil" + str(i)
        sigil.set_meta("index", i)
        sigil.position = Vector3(cos(angle) * 4.95, 0.154, sin(angle) * 3.08)
        sigil.rotation.y = -angle
        sigils.add_child(sigil)
        _add_cylinder_segments(sigil, 0.44, 0.012, 6, void_mat, Vector3.ZERO, Vector3(0, 30, 0))
        _add_box(sigil, Vector3(0.095, 0.014, 0.86), danger, Vector3(0, 0.028, 0))
        _add_box(sigil, Vector3(0.58, 0.014, 0.070), gold, Vector3(0, 0.032, 0))
        _add_tapered_cylinder(sigil, 0.085, 0.018, 0.56, 6, danger, Vector3(0, 0.075, 0.40), Vector3(74, 0, 0))
    var decal_path := _vfx_decal_texture_path()
    if decal_path != "":
        var decal_mat := _vfx_decal_mat("boss_cast_vfx_decal", decal_path, Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.34), 1.22, Vector3(0.25, 0.25, 1.0), Vector3(0.0, 0.75, 0.0))
        var decal := _add_textured_plane(sigils, Vector2(9.20, 9.20), decal_mat, Vector3(0, 0.126, 0), Vector3(0, 45, 0))
        decal.name = "BossCastVfxDecal"

func _boss_domain_node_name(boss_kind: String) -> String:
    match boss_kind:
        "boss_cho":
            return "BossDomainChoRupture"
        "boss_velkoz":
            return "BossDomainVelkozFocus"
        "boss_reksai":
            return "BossDomainReksaiBurrow"
        "boss_belveth":
            return "BossDomainBelvethSwarm"
        _:
            return "BossDomainGeneric"

func _boss_domain_type(boss_kind: String) -> String:
    match boss_kind:
        "boss_cho":
            return "rupture_devour"
        "boss_velkoz":
            return "focus_laser"
        "boss_reksai":
            return "burrow_tunnel"
        "boss_belveth":
            return "royal_swarm"
        _:
            return "generic"

func _boss_domain_detail_node_name(boss_kind: String) -> String:
    match boss_kind:
        "boss_cho":
            return "BossDomainChoRuptureMaw"
        "boss_velkoz":
            return "BossDomainVelkozFocusFan"
        "boss_reksai":
            return "BossDomainReksaiTunnelLane"
        "boss_belveth":
            return "BossDomainBelvethWingCrown"
        _:
            return "BossDomainGenericMark"

func _build_boss_domain_profiles(parent: Node3D) -> void:
    var rig := Node3D.new()
    rig.name = "BossDomainProfileRig"
    rig.visible = false
    parent.add_child(rig)

    var danger := _mat("boss_domain_danger", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.26), 1.04, true, true)
    var void_mat := _mat("boss_domain_void", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.22), 1.00, true, true)
    var gold := _mat("boss_domain_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.28), 0.76, true, true)
    var hot := _mat("boss_domain_hot", Color(1.0, 0.58, 0.92, 0.40), 1.18, true, true)

    for boss_kind in ["boss_cho", "boss_velkoz", "boss_reksai", "boss_belveth"]:
        var domain := Node3D.new()
        domain.name = _boss_domain_node_name(boss_kind)
        domain.visible = false
        domain.set_meta("boss_kind", boss_kind)
        domain.set_meta("domain_type", _boss_domain_type(boss_kind))
        domain.set_meta("detail_node", _boss_domain_detail_node_name(boss_kind))
        rig.add_child(domain)

        var frame := _add_cylinder_segments(domain, 5.35, 0.010, 8, void_mat, Vector3(0, 0.118, 0), Vector3(0, 22.5, 0))
        frame.name = "BossDomainFrame"
        var core := _add_cylinder_segments(domain, 2.48, 0.010, 6, danger, Vector3(0, 0.134, 0), Vector3(0, 30, 0))
        core.name = "BossDomainPressureCore"
        var meter := _add_box(domain, Vector3(4.40, 0.012, 0.095), gold, Vector3(0, 0.154, -2.88))
        meter.name = "BossDomainThreatMeter"

        var detail := Node3D.new()
        detail.name = _boss_domain_detail_node_name(boss_kind)
        detail.set_meta("base_y", 0.172)
        domain.add_child(detail)
        match boss_kind:
            "boss_cho":
                _add_cylinder_segments(detail, 1.36, 0.014, 5, danger, Vector3(0, 0.172, 0.60), Vector3(0, 18, 0))
                for i in range(10):
                    var angle := TAU * float(i) / 10.0
                    var tooth_radius := 1.08 + float(i % 2) * 0.36
                    _add_tapered_cylinder(detail, 0.10, 0.014, 0.68, 6, hot if i % 2 == 0 else gold, Vector3(cos(angle) * tooth_radius, 0.212, 0.60 + sin(angle) * tooth_radius * 0.72), Vector3(68, -rad_to_deg(angle), 0))
                for crack in range(5):
                    var crack_angle := TAU * float(crack) / 5.0 + PI * 0.12
                    _add_box(detail, Vector3(0.13, 0.010, 2.20), void_mat, Vector3(cos(crack_angle) * 2.32, 0.166, sin(crack_angle) * 1.58), Vector3(0, -rad_to_deg(crack_angle), 0))
            "boss_velkoz":
                for beam in range(7):
                    var offset := float(beam) - 3.0
                    _add_box(detail, Vector3(0.11, 0.012, 4.92 - abs(offset) * 0.36), hot if beam == 3 else void_mat, Vector3(offset * 0.36, 0.184, 0.86 + abs(offset) * 0.10), Vector3(0, offset * 7.0, 0))
                _add_cylinder_segments(detail, 0.92, 0.012, 24, danger, Vector3(0, 0.210, 0.36), Vector3(90, 0, 0))
                _add_sphere(detail, 0.14, hot, Vector3(0, 0.250, 0.36))
                for eye in range(3):
                    var eye_angle := TAU * float(eye) / 3.0 + PI * 0.16
                    _add_sphere(detail, 0.055, gold, Vector3(cos(eye_angle) * 0.66, 0.262, 0.36 + sin(eye_angle) * 0.44))
            "boss_reksai":
                _add_box(detail, Vector3(0.52, 0.014, 5.72), danger, Vector3(0, 0.174, 0.82))
                for rib in range(9):
                    var z := -2.02 + float(rib) * 0.55
                    for side in [-1.0, 1.0]:
                        _add_tapered_cylinder(detail, 0.085, 0.012, 0.70, 6, hot if rib % 2 == 0 else gold, Vector3(side * 0.64, 0.214, z), Vector3(72, side * 10.0, side * 24.0))
                for wake in range(4):
                    var offset := -0.45 + float(wake) * 0.30
                    _add_box(detail, Vector3(0.11, 0.010, 2.10), void_mat, Vector3(offset * 2.2, 0.164, -0.36 + float(wake) * 0.46), Vector3(0, offset * 28.0, offset * 14.0))
            "boss_belveth":
                for side in [-1.0, 1.0]:
                    _add_box(detail, Vector3(0.18, 0.014, 4.18), void_mat, Vector3(side * 1.36, 0.176, 0.24), Vector3(0, side * 16.0, side * 48.0))
                    _add_box(detail, Vector3(0.11, 0.012, 2.42), hot, Vector3(side * 2.02, 0.206, 0.48), Vector3(0, side * -16.0, side * 52.0))
                _add_cylinder_segments(detail, 1.18, 0.012, 5, gold, Vector3(0, 0.200, 0.22), Vector3(0, 18, 0))
                for needle in range(8):
                    var needle_angle := TAU * float(needle) / 8.0
                    _add_tapered_cylinder(detail, 0.062, 0.008, 0.78, 6, gold if needle % 2 == 0 else hot, Vector3(cos(needle_angle) * 1.36, 0.236, sin(needle_angle) * 1.08), Vector3(66, -rad_to_deg(needle_angle), 0))

func _sync_boss_domain_profiles(arena_ritual: Node3D, boss_kind: String, boss_health_ratio: float, cast_t: float, time: float, cinematic_state: String, cinematic_intensity: float) -> void:
    var rig := arena_ritual.get_node_or_null("BossDomainProfileRig") as Node3D
    if rig == null:
        return
    rig.visible = boss_kind != ""
    if not rig.visible:
        return
    var pressure := 1.0 - boss_health_ratio
    rig.set_meta("cinematic_state", cinematic_state)
    rig.set_meta("cinematic_intensity", cinematic_intensity)
    rig.rotation.y = -time * 0.045
    for child in rig.get_children():
        var domain := child as Node3D
        if domain == null:
            continue
        var active := str(domain.get_meta("boss_kind", "")) == boss_kind
        domain.visible = active
        if not active:
            continue
        var domain_type := str(domain.get_meta("domain_type", "generic"))
        domain.set_meta("cinematic_state", cinematic_state)
        domain.set_meta("cinematic_intensity", cinematic_intensity)
        var state_bonus := 0.070 if cinematic_state == "enraged" else 0.050 if cinematic_state == "casting" else 0.024 if cinematic_state == "pressuring" else 0.0
        var pulse := 1.0 + pressure * 0.16 + cast_t * 0.08 + state_bonus + sin(time * (1.6 if domain_type == "focus_laser" else 1.25)) * (0.024 + cinematic_intensity * 0.018)
        domain.scale = Vector3(pulse, 1.0, pulse)
        domain.rotation.y += 0.018 if domain_type == "royal_swarm" or domain_type == "focus_laser" else -0.012
        var frame := domain.get_node_or_null("BossDomainFrame") as Node3D
        if frame != null:
            frame.rotation.y += 0.018 if domain_type == "focus_laser" else -0.012
        var core := domain.get_node_or_null("BossDomainPressureCore") as Node3D
        if core != null:
            core.scale = Vector3.ONE * (0.92 + pressure * 0.20 + cast_t * 0.10 + sin(time * 2.8) * 0.025)
        var meter := domain.get_node_or_null("BossDomainThreatMeter") as Node3D
        if meter != null:
            meter.scale.x = lerpf(0.28, 1.18, maxf(cinematic_intensity, maxf(pressure, cast_t)))
            meter.visible = pressure > 0.08 or cast_t > 0.04 or cinematic_state == "pressuring"
        var detail_name := str(domain.get_meta("detail_node", ""))
        var detail := domain.get_node_or_null(detail_name) as Node3D
        if detail != null:
            detail.position.y = float(detail.get_meta("base_y", detail.position.y)) + sin(time * 2.9 + float(boss_kind.length())) * 0.014
            detail.scale = Vector3.ONE * (0.96 + cast_t * 0.10 + pressure * 0.08 + cinematic_intensity * 0.055)

func _boss_lockdown_detail_node_name(boss_kind: String) -> String:
    match boss_kind:
        "boss_cho":
            return "BossArenaLockdownChoMaw"
        "boss_velkoz":
            return "BossArenaLockdownVelkozEye"
        "boss_reksai":
            return "BossArenaLockdownReksaiTunnel"
        "boss_belveth":
            return "BossArenaLockdownBelvethCrown"
        _:
            return "BossArenaLockdownGeneric"

func _build_boss_arena_lockdown(parent: Node3D) -> void:
    var rig := Node3D.new()
    rig.name = "BossArenaLockdownRig"
    rig.visible = false
    rig.set_meta("combat_visual_channel", "boss_arena_lockdown")
    rig.set_meta("material_grade", "low_glare_boss_arena_lockdown")
    rig.set_meta("boss_lockdown_layer", true)
    rig.set_meta("anchor_count", 4)
    rig.set_meta("chain_count", 4)
    parent.add_child(rig)

    var shadow := _mat("boss_lockdown_shadow", Color(0.020, 0.014, 0.034, 0.30), 0.0, true, true)
    var void_mat := _mat("boss_lockdown_void_low", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.22), 0.08, true, true)
    var danger := _mat("boss_lockdown_danger_low", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.24), 0.10, true, true)
    var gold := _mat("boss_lockdown_gold_low", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24), 0.08, true, true)
    var hot := _mat("boss_lockdown_hot_low", Color(1.0, 0.42, 0.88, 0.26), 0.12, true, true)

    var anchors := Node3D.new()
    anchors.name = "BossArenaLockdownAnchors"
    rig.add_child(anchors)
    var anchor_positions := [
        Vector3(-6.75, 0.160, -4.15),
        Vector3(6.75, 0.160, -4.15),
        Vector3(6.75, 0.160, 4.15),
        Vector3(-6.75, 0.160, 4.15),
    ]
    for i in range(anchor_positions.size()):
        var anchor := Node3D.new()
        anchor.name = "BossArenaLockdownAnchor_" + str(i)
        anchor.position = anchor_positions[i]
        anchor.set_meta("index", i)
        anchor.set_meta("lockdown_anchor", true)
        anchor.set_meta("base_y", anchor.position.y)
        anchors.add_child(anchor)
        var base := _add_cylinder_segments(anchor, 0.46, 0.020, 6, shadow, Vector3.ZERO, Vector3(0, 30, 0))
        base.name = "BossArenaLockdownAnchorBase"
        var obelisk := _add_box(anchor, Vector3(0.22, 0.34, 0.22), void_mat, Vector3(0, 0.212, 0), Vector3(0, 45, 0))
        obelisk.name = "BossArenaLockdownAnchorObelisk"
        var core := _add_cylinder_segments(anchor, 0.24, 0.014, 6, gold, Vector3(0, 0.404, 0), Vector3(0, 30, 0))
        core.name = "BossArenaLockdownAnchorCore"
        var fang_a := _add_tapered_cylinder(anchor, 0.080, 0.012, 0.42, 6, danger, Vector3(-0.22, 0.278, 0.12), Vector3(68, 0, -28))
        fang_a.name = "BossArenaLockdownAnchorFangA"
        var fang_b := _add_tapered_cylinder(anchor, 0.080, 0.012, 0.42, 6, danger, Vector3(0.22, 0.278, 0.12), Vector3(68, 0, 28))
        fang_b.name = "BossArenaLockdownAnchorFangB"

    var chains := Node3D.new()
    chains.name = "BossArenaLockdownChains"
    rig.add_child(chains)
    var chain_specs := [
        {"name": "BossArenaLockdownChain_North", "axis": "x", "pos": Vector3(0.0, 0.146, -3.66), "size": Vector3(8.72, 0.012, 0.120), "rot": Vector3.ZERO, "mat": void_mat},
        {"name": "BossArenaLockdownChain_South", "axis": "x", "pos": Vector3(0.0, 0.146, 3.66), "size": Vector3(8.72, 0.012, 0.120), "rot": Vector3.ZERO, "mat": void_mat},
        {"name": "BossArenaLockdownChain_East", "axis": "z", "pos": Vector3(5.86, 0.146, 0.0), "size": Vector3(0.120, 0.012, 5.42), "rot": Vector3.ZERO, "mat": danger},
        {"name": "BossArenaLockdownChain_West", "axis": "z", "pos": Vector3(-5.86, 0.146, 0.0), "size": Vector3(0.120, 0.012, 5.42), "rot": Vector3.ZERO, "mat": danger},
    ]
    for i in range(chain_specs.size()):
        var spec: Dictionary = chain_specs[i]
        var chain := _add_box(chains, spec["size"], spec["mat"], spec["pos"], spec["rot"])
        chain.name = str(spec["name"])
        chain.set_meta("index", i)
        chain.set_meta("axis", str(spec["axis"]))
        chain.set_meta("lockdown_chain", true)

    var center := _add_cylinder_segments(rig, 1.70, 0.012, 8, shadow, Vector3(0, 0.154, 0), Vector3(0, 22.5, 0))
    center.name = "BossArenaLockdownCenterSeal"
    center.set_meta("lockdown_center_seal", true)
    var center_rune := _add_box(rig, Vector3(2.18, 0.012, 0.105), gold, Vector3(0, 0.176, 0))
    center_rune.name = "BossArenaLockdownCenterRune"
    var center_rune_cross := _add_box(rig, Vector3(0.105, 0.012, 2.18), gold, Vector3(0, 0.180, 0))
    center_rune_cross.name = "BossArenaLockdownCenterRuneCross"

    var signatures := Node3D.new()
    signatures.name = "BossArenaLockdownBossSignatures"
    signatures.set_meta("boss_variant_count", 4)
    rig.add_child(signatures)
    for boss_kind in ["boss_cho", "boss_velkoz", "boss_reksai", "boss_belveth"]:
        var detail := Node3D.new()
        detail.name = _boss_lockdown_detail_node_name(boss_kind)
        detail.visible = false
        detail.set_meta("boss_kind", boss_kind)
        detail.set_meta("base_y", 0.205)
        signatures.add_child(detail)
        match boss_kind:
            "boss_cho":
                _add_cylinder_segments(detail, 1.08, 0.014, 5, danger, Vector3(0, 0.205, 0.48), Vector3(0, 18, 0)).name = "BossArenaLockdownChoMawRing"
                for tooth in range(8):
                    var angle := TAU * float(tooth) / 8.0
                    _add_tapered_cylinder(detail, 0.080, 0.010, 0.48, 6, hot if tooth % 2 == 0 else gold, Vector3(cos(angle) * 0.86, 0.246, 0.48 + sin(angle) * 0.62), Vector3(68, -rad_to_deg(angle), 0)).name = "BossArenaLockdownChoTooth"
            "boss_velkoz":
                for beam in range(5):
                    var offset := float(beam) - 2.0
                    _add_box(detail, Vector3(0.080, 0.012, 3.42 - abs(offset) * 0.34), hot if beam == 2 else void_mat, Vector3(offset * 0.32, 0.212, 0.38 + abs(offset) * 0.06), Vector3(0, offset * 8.0, 0)).name = "BossArenaLockdownVelkozRay"
                _add_cylinder_segments(detail, 0.70, 0.012, 24, danger, Vector3(0, 0.234, 0.12), Vector3(90, 0, 0)).name = "BossArenaLockdownVelkozEyeRing"
                _add_sphere(detail, 0.120, hot, Vector3(0, 0.258, 0.12)).name = "BossArenaLockdownVelkozCore"
            "boss_reksai":
                _add_box(detail, Vector3(0.36, 0.014, 4.26), danger, Vector3(0, 0.210, 0.42)).name = "BossArenaLockdownReksaiBurrowSpine"
                for rib in range(7):
                    var z := -1.40 + float(rib) * 0.48
                    for side in [-1.0, 1.0]:
                        _add_tapered_cylinder(detail, 0.070, 0.010, 0.52, 6, gold if rib % 2 == 0 else hot, Vector3(side * 0.46, 0.244, z), Vector3(70, side * 8.0, side * 25.0)).name = "BossArenaLockdownReksaiRib"
            "boss_belveth":
                for side in [-1.0, 1.0]:
                    _add_box(detail, Vector3(0.130, 0.014, 3.34), void_mat, Vector3(side * 0.92, 0.214, 0.12), Vector3(0, side * 14.0, side * 48.0)).name = "BossArenaLockdownBelvethWing"
                    _add_box(detail, Vector3(0.085, 0.012, 1.86), hot, Vector3(side * 1.38, 0.242, 0.28), Vector3(0, side * -16.0, side * 52.0)).name = "BossArenaLockdownBelvethBlade"
                _add_cylinder_segments(detail, 0.84, 0.012, 5, gold, Vector3(0, 0.235, 0.12), Vector3(0, 18, 0)).name = "BossArenaLockdownBelvethCrownRing"

func _sync_boss_arena_lockdown(arena_ritual: Node3D, boss_kind: String, boss_health_ratio: float, cast_t: float, time: float, cinematic_state: String, cinematic_intensity: float) -> void:
    var rig := arena_ritual.get_node_or_null("BossArenaLockdownRig") as Node3D
    if rig == null:
        return
    rig.visible = boss_kind != ""
    if not rig.visible:
        return
    var pressure := clampf(maxf(1.0 - boss_health_ratio, cast_t) + cinematic_intensity * 0.18, 0.0, 1.0)
    rig.set_meta("boss_kind", boss_kind)
    rig.set_meta("cinematic_state", cinematic_state)
    rig.set_meta("cinematic_intensity", cinematic_intensity)
    rig.set_meta("boss_health_ratio", boss_health_ratio)
    rig.set_meta("boss_cast_t", cast_t)
    rig.set_meta("lockdown_pressure", pressure)
    rig.rotation.y = -time * (0.018 + pressure * 0.030)

    var anchors := rig.get_node_or_null("BossArenaLockdownAnchors") as Node3D
    if anchors != null:
        for child in anchors.get_children():
            var anchor := child as Node3D
            if anchor == null:
                continue
            var index := int(anchor.get_meta("index", 0))
            var pulse := 1.0 + pressure * 0.075 + sin(time * 1.90 + float(index) * 0.78) * 0.020
            anchor.position.y = float(anchor.get_meta("base_y", anchor.position.y)) + pressure * 0.020 + sin(time * 1.45 + float(index)) * 0.010
            anchor.scale = Vector3(pulse, 1.0 + pressure * 0.045, pulse)
            anchor.set_meta("lockdown_pressure", pressure)

    var chain_alpha_state := pressure > 0.05 or cast_t > 0.02 or cinematic_state == "pressuring" or cinematic_state == "enraged"
    var chains := rig.get_node_or_null("BossArenaLockdownChains") as Node3D
    if chains != null:
        for child in chains.get_children():
            var chain := child as Node3D
            if chain == null:
                continue
            var axis := str(chain.get_meta("axis", "x"))
            var length_scale := 0.78 + pressure * 0.32 + cast_t * 0.16
            chain.visible = chain_alpha_state
            if axis == "x":
                chain.scale = Vector3(length_scale, 1.0, 1.0 + pressure * 0.08)
            else:
                chain.scale = Vector3(1.0 + pressure * 0.08, 1.0, length_scale)
            chain.set_meta("lockdown_pressure", pressure)

    var center_seal := rig.get_node_or_null("BossArenaLockdownCenterSeal") as Node3D
    if center_seal != null:
        center_seal.scale = Vector3.ONE * (0.88 + pressure * 0.18 + sin(time * 2.4) * 0.018)
    var center_rune := rig.get_node_or_null("BossArenaLockdownCenterRune") as Node3D
    if center_rune != null:
        center_rune.rotation.y = time * (0.10 + pressure * 0.10)
        center_rune.scale.x = 0.72 + pressure * 0.42
    var center_rune_cross := rig.get_node_or_null("BossArenaLockdownCenterRuneCross") as Node3D
    if center_rune_cross != null:
        center_rune_cross.rotation.y = -time * (0.08 + pressure * 0.08)
        center_rune_cross.scale.z = 0.72 + pressure * 0.42

    var signatures := rig.get_node_or_null("BossArenaLockdownBossSignatures") as Node3D
    if signatures != null:
        for child in signatures.get_children():
            var detail := child as Node3D
            if detail == null:
                continue
            var active := str(detail.get_meta("boss_kind", "")) == boss_kind
            detail.visible = active
            if not active:
                continue
            detail.position.y = float(detail.get_meta("base_y", detail.position.y)) + sin(time * 2.1 + float(boss_kind.length())) * 0.012
            detail.scale = Vector3.ONE * (0.84 + pressure * 0.22 + cast_t * 0.10 + cinematic_intensity * 0.05)
            detail.rotation.y += 0.014 if boss_kind == "boss_velkoz" or boss_kind == "boss_belveth" else -0.010
            detail.set_meta("lockdown_pressure", pressure)

func _build_boss_cast_focus(parent: Node3D) -> void:
    var focus := Node3D.new()
    focus.name = "BossCastFocus"
    focus.visible = false
    parent.add_child(focus)
    var danger := _mat("boss_cast_focus_danger", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.46), 1.16, true, true)
    var gold := _mat("boss_cast_focus_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.38), 0.82, true, true)
    var void_mat := _mat("boss_cast_focus_void", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.34), 1.00, true, true)
    _add_cylinder_segments(focus, 1.92, 0.012, 6, danger, Vector3(0, 0.206, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(focus, 1.10, 0.010, 3, gold, Vector3(0, 0.226, 0), Vector3(0, 30, 0))
    for i in range(6):
        var angle := TAU * float(i) / 6.0
        _add_box(focus, Vector3(0.13, 0.014, 0.76), danger, Vector3(cos(angle) * 1.34, 0.238, sin(angle) * 1.34), Vector3(0, -rad_to_deg(angle), 0))
    var warning_frame := Node3D.new()
    warning_frame.name = "BossCastWarningFrame"
    warning_frame.visible = false
    focus.add_child(warning_frame)
    _add_cylinder_segments(warning_frame, 2.24, 0.010, 8, void_mat, Vector3(0, 0.252, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(warning_frame, 1.58, 0.010, 6, danger, Vector3(0, 0.268, 0), Vector3(0, 30, 0))
    for i in range(4):
        var pip_angle := TAU * float(i) / 4.0 + PI * 0.25
        var pip := Node3D.new()
        pip.name = "BossCastCountdownPip%d" % i
        pip.set_meta("index", i)
        pip.position = Vector3(cos(pip_angle) * 1.86, 0.292, sin(pip_angle) * 1.86)
        pip.rotation.y = -pip_angle
        warning_frame.add_child(pip)
        _add_sphere(pip, 0.055, gold, Vector3.ZERO)
        _add_box(pip, Vector3(0.30, 0.010, 0.052), danger, Vector3(0, 0.024, 0))
    var decal_path := _vfx_decal_texture_path()
    if decal_path != "":
        var decal_mat := _vfx_decal_mat("boss_cast_focus_vfx_decal", decal_path, Color(1.0, 0.32, 0.42, 0.42), 1.32, Vector3(0.25, 0.25, 1.0), Vector3(0.0, 0.75, 0.0))
        var decal := _add_textured_plane(focus, Vector2(3.58, 3.58), decal_mat, Vector3(0, 0.190, 0), Vector3(0, 45, 0))
        decal.name = "BossCastFocusVfxDecal"

func _build_boss_cast_patterns(parent: Node3D) -> void:
    var rig := Node3D.new()
    rig.name = "BossCastPatternRig"
    rig.visible = false
    parent.add_child(rig)

    var danger := _mat("boss_cast_pattern_danger", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.34), 1.12, true, true)
    var void_mat := _mat("boss_cast_pattern_void", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.32), 1.06, true, true)
    var gold := _mat("boss_cast_pattern_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.34), 0.84, true, true)
    var hot := _mat("boss_cast_pattern_hot", Color(1.0, 0.66, 0.94, 0.46), 1.22, true, true)
    var safety := _mat("boss_cast_safety_gap_low", Color(0.020, 0.085, 0.095, 0.22), 0.0, true, true)
    var safety_shadow := _mat("boss_cast_safety_gap_shadow", Color(0.0, 0.0, 0.0, 0.28), 0.0, true, true)
    var safety_tick := _mat("boss_cast_safety_gap_tick", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.22), 0.04, true, true)

    var cho := Node3D.new()
    cho.name = "BossCastPatternCho"
    rig.add_child(cho)
    var cho_ring := _add_cylinder_segments(cho, 2.42, 0.012, 5, danger, Vector3(0, 0.266, 0), Vector3(0, 18, 0))
    cho_ring.name = "BossCastChoRuptureRing"
    for i in range(10):
        var angle := TAU * float(i) / 10.0
        var tooth_radius := 1.58 + float(i % 2) * 0.44
        _add_tapered_cylinder(cho, 0.13, 0.018, 0.82, 6, hot, Vector3(cos(angle) * tooth_radius, 0.304, sin(angle) * tooth_radius), Vector3(72, -rad_to_deg(angle), 0))
    var cho_teeth := Node3D.new()
    cho_teeth.name = "BossCastChoImpactTeeth"
    cho.add_child(cho_teeth)
    for i in range(5):
        var bite_angle := TAU * float(i) / 5.0 + PI * 0.10
        _add_tapered_cylinder(cho_teeth, 0.18, 0.018, 0.96, 6, gold, Vector3(cos(bite_angle) * 1.02, 0.344, sin(bite_angle) * 1.02), Vector3(66, -rad_to_deg(bite_angle), 0))
    _add_cylinder_segments(cho_teeth, 1.18, 0.010, 5, void_mat, Vector3(0, 0.326, 0), Vector3(0, 18, 0))
    _add_boss_cast_intent_profile(cho, "boss_cho", danger, void_mat, gold, hot)
    _add_boss_cast_safety_profile(cho, "boss_cho", safety, safety_shadow, safety_tick)

    var velkoz := Node3D.new()
    velkoz.name = "BossCastPatternVelkoz"
    rig.add_child(velkoz)
    var laser_fan := Node3D.new()
    laser_fan.name = "BossCastVelkozLaserFan"
    velkoz.add_child(laser_fan)
    for i in range(5):
        var offset := float(i) - 2.0
        var beam := _add_box(laser_fan, Vector3(0.13, 0.014, 3.80 - abs(offset) * 0.32), hot if i == 2 else void_mat, Vector3(offset * 0.30, 0.286, 1.18 + abs(offset) * 0.18), Vector3(0, offset * 8.0, 0))
        if i == 2:
            beam.name = "BossCastVelkozPrimaryBeam"
    _add_cylinder_segments(velkoz, 0.62, 0.012, 3, gold, Vector3(0, 0.314, 0.42), Vector3(90, 0, 30))
    var eye_core := Node3D.new()
    eye_core.name = "BossCastVelkozEyeCore"
    velkoz.add_child(eye_core)
    _add_cylinder_segments(eye_core, 0.50, 0.010, 24, void_mat, Vector3(0, 0.334, 0.34), Vector3(90, 0, 0))
    _add_sphere(eye_core, 0.105, hot, Vector3(0, 0.362, 0.34))
    for i in range(3):
        var eye_angle := TAU * float(i) / 3.0 + PI * 0.16
        _add_sphere(eye_core, 0.045, gold, Vector3(cos(eye_angle) * 0.38, 0.376, 0.34 + sin(eye_angle) * 0.22))
    _add_boss_cast_intent_profile(velkoz, "boss_velkoz", danger, void_mat, gold, hot)
    _add_boss_cast_safety_profile(velkoz, "boss_velkoz", safety, safety_shadow, safety_tick)

    var reksai := Node3D.new()
    reksai.name = "BossCastPatternReksai"
    rig.add_child(reksai)
    var burrow_lane := _add_box(reksai, Vector3(0.42, 0.016, 4.20), danger, Vector3(0, 0.282, 1.15))
    burrow_lane.name = "BossCastReksaiBurrowLane"
    for i in range(7):
        var z := -0.48 + float(i) * 0.52
        var side := -1.0 if i % 2 == 0 else 1.0
        _add_tapered_cylinder(reksai, 0.12, 0.014, 0.64, 6, hot, Vector3(side * 0.38, 0.318, z), Vector3(72, side * 10.0, side * 18.0))
    var tremor := Node3D.new()
    tremor.name = "BossCastReksaiTremorWake"
    reksai.add_child(tremor)
    for i in range(4):
        var z := -0.18 + float(i) * 0.72
        for side in [-1.0, 1.0]:
            _add_box(tremor, Vector3(0.10, 0.012, 0.56), void_mat, Vector3(side * (0.54 + float(i % 2) * 0.14), 0.342, z), Vector3(0, side * 18.0, side * 24.0))
    _add_boss_cast_intent_profile(reksai, "boss_reksai", danger, void_mat, gold, hot)
    _add_boss_cast_safety_profile(reksai, "boss_reksai", safety, safety_shadow, safety_tick)

    var belveth := Node3D.new()
    belveth.name = "BossCastPatternBelveth"
    rig.add_child(belveth)
    var wing_sweep := Node3D.new()
    wing_sweep.name = "BossCastBelvethWingSweep"
    belveth.add_child(wing_sweep)
    for side in [-1.0, 1.0]:
        _add_box(wing_sweep, Vector3(0.22, 0.016, 3.46), void_mat, Vector3(side * 0.92, 0.286, 0.72), Vector3(0, side * 20.0, side * 42.0))
        _add_box(wing_sweep, Vector3(0.13, 0.014, 2.10), hot, Vector3(side * 1.42, 0.314, 0.92), Vector3(0, side * -18.0, side * 50.0))
    _add_cylinder_segments(belveth, 1.16, 0.012, 6, gold, Vector3(0, 0.300, 0.34), Vector3(0, 30, 0))
    var royal_needles := Node3D.new()
    royal_needles.name = "BossCastBelvethRoyalNeedles"
    belveth.add_child(royal_needles)
    for i in range(6):
        var needle_angle := TAU * float(i) / 6.0
        _add_tapered_cylinder(royal_needles, 0.070, 0.008, 0.74, 6, gold if i % 2 == 0 else hot, Vector3(cos(needle_angle) * 1.12, 0.348, sin(needle_angle) * 0.82), Vector3(68, -rad_to_deg(needle_angle), 0))
    _add_boss_cast_intent_profile(belveth, "boss_belveth", danger, void_mat, gold, hot)
    _add_boss_cast_safety_profile(belveth, "boss_belveth", safety, safety_shadow, safety_tick)

func _boss_cast_intent_type(boss_kind: String) -> String:
    match boss_kind:
        "boss_cho":
            return "devour_rupture"
        "boss_velkoz":
            return "laser_fan"
        "boss_reksai":
            return "burrow_charge"
        "boss_belveth":
            return "royal_sweep"
        _:
            return "generic"

func _boss_cast_intent_detail_name(boss_kind: String) -> String:
    match boss_kind:
        "boss_cho":
            return "BossCastIntentChoDevour"
        "boss_velkoz":
            return "BossCastIntentVelkozLaser"
        "boss_reksai":
            return "BossCastIntentReksaiBurrow"
        "boss_belveth":
            return "BossCastIntentBelvethSweep"
        _:
            return "BossCastIntentGeneric"

func _boss_cast_safety_type(boss_kind: String) -> String:
    match boss_kind:
        "boss_cho":
            return "ring_gap"
        "boss_velkoz":
            return "laser_between_lanes"
        "boss_reksai":
            return "side_dodge_pocket"
        "boss_belveth":
            return "sweep_center_seam"
        _:
            return "generic"

func _boss_cast_safety_detail_name(boss_kind: String) -> String:
    match boss_kind:
        "boss_cho":
            return "BossCastSafetyChoBiteGaps"
        "boss_velkoz":
            return "BossCastSafetyVelkozLaserGaps"
        "boss_reksai":
            return "BossCastSafetyReksaiSidePockets"
        "boss_belveth":
            return "BossCastSafetyBelvethSweepSeam"
        _:
            return "BossCastSafetyGeneric"

func _boss_cast_safety_pocket_count(boss_kind: String) -> int:
    match boss_kind:
        "boss_cho":
            return 5
        "boss_velkoz":
            return 4
        "boss_reksai":
            return 4
        "boss_belveth":
            return 3
        _:
            return 2

func _add_boss_cast_safe_exit_arrow(parent: Node3D, index: int, pos: Vector3, yaw: float, mat: Material, backplate_mat: Material, anchor_mat: Material, boss_kind: String) -> void:
    var arrow := Node3D.new()
    arrow.name = "BossCastSafeExitArrow_%d" % index
    arrow.set_meta("boss_kind", boss_kind)
    arrow.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    arrow.set_meta("safe_exit_arrow", true)
    arrow.set_meta("safe_exit_anchor_count", 3)
    arrow.set_meta("pickup_confusion_guard", true)
    arrow.set_meta("hazard_confusion_safe", true)
    arrow.position = pos
    arrow.rotation_degrees.y = yaw
    parent.add_child(arrow)

    var matte := _add_box(arrow, Vector3(0.34, 0.006, 0.66), backplate_mat, Vector3(0, -0.006, 0.045))
    matte.name = "BossCastSafeExitAnchorMatte"
    matte.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    matte.set_meta("safe_exit_anchor", true)
    matte.set_meta("pickup_confusion_guard", true)
    matte.set_meta("material_grade", "low_glare_boss_cast_safe_exit_anchor")

    var gate := _add_box(arrow, Vector3(0.30, 0.008, 0.050), anchor_mat, Vector3(0, 0.002, -0.260))
    gate.name = "BossCastSafeExitEntranceBar"
    gate.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    gate.set_meta("safe_exit_anchor", true)
    gate.set_meta("pickup_confusion_guard", true)
    gate.set_meta("material_grade", "low_glare_boss_cast_safe_exit_anchor")

    var notch := _add_box(arrow, Vector3(0.055, 0.008, 0.18), anchor_mat, Vector3(0, 0.004, 0.455))
    notch.name = "BossCastSafeExitContrastNotch"
    notch.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    notch.set_meta("safe_exit_anchor", true)
    notch.set_meta("pickup_confusion_guard", true)
    notch.set_meta("material_grade", "low_glare_boss_cast_safe_exit_anchor")

    var stem := _add_box(arrow, Vector3(0.055, 0.010, 0.46), mat, Vector3(0, 0.0, 0.0))
    stem.name = "BossCastSafeExitArrowStem"
    stem.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    stem.set_meta("safe_exit_arrow", true)
    stem.set_meta("pickup_confusion_guard", true)
    var left := _add_box(arrow, Vector3(0.045, 0.010, 0.25), mat, Vector3(-0.085, 0.004, 0.24), Vector3(0, -28, 0))
    left.name = "BossCastSafeExitArrowWingL"
    left.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    left.set_meta("safe_exit_arrow", true)
    left.set_meta("pickup_confusion_guard", true)
    var right := _add_box(arrow, Vector3(0.045, 0.010, 0.25), mat, Vector3(0.085, 0.004, 0.24), Vector3(0, 28, 0))
    right.name = "BossCastSafeExitArrowWingR"
    right.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    right.set_meta("safe_exit_arrow", true)
    right.set_meta("pickup_confusion_guard", true)

func _add_boss_cast_safety_profile(pattern: Node3D, boss_kind: String, safety: Material, shadow: Material, tick: Material) -> void:
    var profile := Node3D.new()
    profile.name = "BossCastSafetyProfile"
    profile.set_meta("boss_kind", boss_kind)
    profile.set_meta("safety_type", _boss_cast_safety_type(boss_kind))
    profile.set_meta("detail_node", _boss_cast_safety_detail_name(boss_kind))
    profile.set_meta("safe_pocket_count", _boss_cast_safety_pocket_count(boss_kind))
    profile.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    profile.set_meta("material_grade", "low_glare_boss_cast_safety_profile")
    profile.set_meta("boss_cast_safe_gap_layer", true)
    pattern.add_child(profile)

    var base := Node3D.new()
    base.name = "BossCastSafetyBase"
    base.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    profile.add_child(base)
    _add_cylinder_segments(base, 2.82, 0.008, 8, shadow, Vector3(0, 0.248, 0), Vector3(0, 22.5, 0))

    var pockets := Node3D.new()
    pockets.name = "BossCastSafePocketRoot"
    pockets.set_meta("safe_pocket_count", _boss_cast_safety_pocket_count(boss_kind))
    pockets.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    profile.add_child(pockets)

    var margins := Node3D.new()
    margins.name = "BossCastHazardMarginRoot"
    margins.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    profile.add_child(margins)

    var arrows := Node3D.new()
    arrows.name = "BossCastSafeExitArrowRoot"
    arrows.set_meta("safe_exit_arrow_count", _boss_cast_safety_pocket_count(boss_kind))
    arrows.set_meta("safe_exit_anchor_count", _boss_cast_safety_pocket_count(boss_kind))
    arrows.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    arrows.set_meta("material_grade", "low_glare_boss_cast_safe_exit_arrows")
    arrows.set_meta("safe_exit_layer", true)
    arrows.set_meta("pickup_confusion_guard", true)
    profile.add_child(arrows)

    var detail := Node3D.new()
    detail.name = _boss_cast_safety_detail_name(boss_kind)
    detail.set_meta("boss_kind", boss_kind)
    detail.set_meta("base_y", 0.382)
    detail.set_meta("combat_visual_channel", "boss_cast_safety_readability")
    profile.add_child(detail)

    match boss_kind:
        "boss_cho":
            for i in range(5):
                var angle := TAU * float(i) / 5.0 + PI * 0.20
                var pocket := _add_box(pockets, Vector3(0.38, 0.010, 0.92), safety, Vector3(cos(angle) * 1.70, 0.286, sin(angle) * 1.70), Vector3(0, -rad_to_deg(angle), 0))
                pocket.name = "BossCastSafePocket_%d" % i
                var tooth_gap := _add_box(margins, Vector3(0.055, 0.010, 0.70), tick, Vector3(cos(angle) * 2.08, 0.316, sin(angle) * 2.08), Vector3(0, -rad_to_deg(angle), 0))
                tooth_gap.name = "BossCastHazardMargin_%d" % i
                _add_boss_cast_safe_exit_arrow(arrows, i, Vector3(cos(angle) * 1.42, 0.334, sin(angle) * 1.42), -rad_to_deg(angle), tick, shadow, safety, boss_kind)
            _add_cylinder_segments(detail, 1.64, 0.008, 5, safety, Vector3(0, 0.382, 0), Vector3(0, 18, 0))
        "boss_velkoz":
            for i in range(4):
                var offset := -1.5 + float(i)
                var pocket := _add_box(pockets, Vector3(0.16, 0.010, 3.36), safety, Vector3(offset * 0.30, 0.284, 1.02), Vector3(0, offset * 7.0, 0))
                pocket.name = "BossCastSafePocket_%d" % i
                var margin := _add_box(margins, Vector3(0.040, 0.010, 2.60), tick, Vector3(offset * 0.30 + sign(offset) * 0.12, 0.316, 1.06), Vector3(0, offset * 7.0, 0))
                margin.name = "BossCastHazardMargin_%d" % i
                _add_boss_cast_safe_exit_arrow(arrows, i, Vector3(offset * 0.30, 0.334, -0.42), offset * 7.0, tick, shadow, safety, boss_kind)
            _add_box(detail, Vector3(0.56, 0.010, 0.075), safety, Vector3(0, 0.382, -0.44))
        "boss_reksai":
            for i in range(4):
                var side := -1.0 if i < 2 else 1.0
                var z := -0.74 + float(i % 2) * 1.22
                var pocket := _add_box(pockets, Vector3(0.48, 0.010, 0.92), safety, Vector3(side * 0.92, 0.284, z), Vector3(0, side * 8.0, 0))
                pocket.name = "BossCastSafePocket_%d" % i
                var margin := _add_box(margins, Vector3(0.060, 0.010, 0.78), tick, Vector3(side * 0.54, 0.318, z), Vector3(0, side * 8.0, 0))
                margin.name = "BossCastHazardMargin_%d" % i
                _add_boss_cast_safe_exit_arrow(arrows, i, Vector3(side * 1.18, 0.336, z), side * 8.0, tick, shadow, safety, boss_kind)
            _add_box(detail, Vector3(1.72, 0.010, 0.065), safety, Vector3(0, 0.382, -1.16))
        "boss_belveth":
            for i in range(3):
                var x := -0.52 + float(i) * 0.52
                var pocket := _add_box(pockets, Vector3(0.28, 0.010, 1.12), safety, Vector3(x, 0.286, 0.30 + abs(x) * 0.18), Vector3(0, x * 18.0, 0))
                pocket.name = "BossCastSafePocket_%d" % i
                var margin := _add_box(margins, Vector3(0.040, 0.010, 0.94), tick, Vector3(x, 0.318, 0.92), Vector3(0, x * 18.0, 0))
                margin.name = "BossCastHazardMargin_%d" % i
                _add_boss_cast_safe_exit_arrow(arrows, i, Vector3(x, 0.336, -0.52), x * 18.0, tick, shadow, safety, boss_kind)
            _add_cylinder_segments(detail, 0.78, 0.008, 6, safety, Vector3(0, 0.382, -0.26), Vector3(0, 30, 0))
        _:
            for i in range(2):
                var side := -1.0 if i == 0 else 1.0
                var pocket := _add_box(pockets, Vector3(0.42, 0.010, 0.90), safety, Vector3(side * 0.72, 0.286, 0.0))
                pocket.name = "BossCastSafePocket_%d" % i
                _add_boss_cast_safe_exit_arrow(arrows, i, Vector3(side * 0.72, 0.336, -0.46), 0.0, tick, shadow, safety, boss_kind)
            _add_box(detail, Vector3(0.88, 0.010, 0.060), safety, Vector3(0, 0.382, 0))

func _add_boss_cast_intent_profile(pattern: Node3D, boss_kind: String, danger: Material, void_mat: Material, gold: Material, hot: Material) -> void:
    var profile := Node3D.new()
    profile.name = "BossCastIntentProfile"
    profile.set_meta("boss_kind", boss_kind)
    profile.set_meta("intent_type", _boss_cast_intent_type(boss_kind))
    profile.set_meta("detail_node", _boss_cast_intent_detail_name(boss_kind))
    pattern.add_child(profile)

    var frame := _add_cylinder_segments(profile, 0.52, 0.010, 6, gold, Vector3(0, 0.392, -0.86), Vector3(0, 30, 0))
    frame.name = "BossCastIntentFrame"
    var pip := _add_sphere(profile, 0.052, hot, Vector3(0, 0.424, -0.86))
    pip.name = "BossCastIntentPip"

    var detail_name := _boss_cast_intent_detail_name(boss_kind)
    var detail: Node3D = null
    match boss_kind:
        "boss_cho":
            detail = _add_cylinder_segments(profile, 0.29, 0.010, 5, danger, Vector3(0, 0.430, -0.86), Vector3(0, 18, 0))
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(profile, 0.060, 0.010, 0.36, 6, hot, Vector3(side * 0.20, 0.454, -0.66), Vector3(70, 0, side * 18.0))
        "boss_velkoz":
            detail = _add_box(profile, Vector3(0.070, 0.012, 0.86), hot, Vector3(0, 0.436, -0.68), Vector3(0, 0, 0))
            _add_box(profile, Vector3(0.052, 0.010, 0.62), void_mat, Vector3(-0.18, 0.430, -0.76), Vector3(0, -14, 0))
            _add_box(profile, Vector3(0.052, 0.010, 0.62), void_mat, Vector3(0.18, 0.430, -0.76), Vector3(0, 14, 0))
        "boss_reksai":
            detail = _add_box(profile, Vector3(0.18, 0.012, 0.88), danger, Vector3(0, 0.432, -0.72), Vector3(0, 0, 0))
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(profile, 0.052, 0.010, 0.34, 6, hot, Vector3(side * 0.25, 0.452, -0.82), Vector3(72, side * 12.0, side * 24.0))
        "boss_belveth":
            detail = _add_box(profile, Vector3(0.082, 0.012, 0.84), hot, Vector3(-0.16, 0.432, -0.74), Vector3(0, -28, -22))
            _add_box(profile, Vector3(0.082, 0.012, 0.84), hot, Vector3(0.16, 0.432, -0.74), Vector3(0, 28, 22))
            _add_cylinder_segments(profile, 0.24, 0.010, 6, void_mat, Vector3(0, 0.424, -0.92), Vector3(0, 30, 0))
        _:
            detail = _add_cylinder_segments(profile, 0.28, 0.010, 6, danger, Vector3(0, 0.430, -0.86), Vector3(0, 30, 0))
            _add_box(profile, Vector3(0.070, 0.012, 0.62), hot, Vector3(0, 0.450, -0.74))
    if detail != null:
        detail.name = detail_name
        detail.set_meta("base_y", detail.position.y)

func _build_boss_pressure_signatures(parent: Node3D) -> void:
    var danger := _mat("boss_pressure_signature_danger", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.34), 1.05, true, true)
    var void_mat := _mat("boss_pressure_signature_void", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.34), 1.05, true, true)
    var hot := _mat("boss_pressure_signature_hot", Color(1.0, 0.76, 0.92, 0.42), 1.15, true, true)

    var cho := Node3D.new()
    cho.name = "SigCho"
    parent.add_child(cho)
    _add_cylinder_segments(cho, 0.88, 0.012, 5, danger, Vector3(0, 0.192, 0.46), Vector3(90, 0, 18))
    for side in [-1.0, 1.0]:
        _add_tapered_cylinder(cho, 0.11, 0.018, 0.72, 6, hot, Vector3(side * 0.42, 0.222, 0.90), Vector3(70, 0, side * 16.0))

    var velkoz := Node3D.new()
    velkoz.name = "SigVelkoz"
    parent.add_child(velkoz)
    _add_cylinder_segments(velkoz, 1.05, 0.012, 3, void_mat, Vector3(0, 0.194, 0.16), Vector3(90, 0, 30))
    _add_box(velkoz, Vector3(1.40, 0.014, 0.10), hot, Vector3(0, 0.214, 0.16))
    _add_sphere(velkoz, 0.15, hot, Vector3(0, 0.238, 0.16))

    var reksai := Node3D.new()
    reksai.name = "SigReksai"
    parent.add_child(reksai)
    _add_box(reksai, Vector3(0.34, 0.016, 2.10), danger, Vector3(0, 0.194, 0.50))
    for i in range(4):
        var side := -1.0 if i % 2 == 0 else 1.0
        _add_tapered_cylinder(reksai, 0.13, 0.018, 0.78, 6, hot, Vector3(side * 0.34, 0.232, 0.28 + float(i) * 0.30), Vector3(72, 0, side * 18.0))

    var belveth := Node3D.new()
    belveth.name = "SigBelveth"
    parent.add_child(belveth)
    for side in [-1.0, 1.0]:
        _add_box(belveth, Vector3(0.18, 0.016, 2.04), void_mat, Vector3(side * 0.72, 0.196, 0.04), Vector3(0, side * 12.0, side * 42.0))
        _add_box(belveth, Vector3(0.12, 0.014, 1.12), hot, Vector3(side * 1.08, 0.218, 0.28), Vector3(0, side * -18.0, side * 50.0))

func _sync_boss_pressure() -> void:
    var boss_enemy: Node2D = null
    var boss_kind := ""
    var boss_health_ratio := 1.0
    for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        if not bool(enemy.get("boss")):
            continue
        if float(enemy.get("health")) <= 0.0:
            continue
        boss_enemy = enemy
        boss_kind = str(enemy.get("kind"))
        var max_hp := maxf(1.0, float(enemy.get("max_health")))
        boss_health_ratio = clampf(float(enemy.get("health")) / max_hp, 0.0, 1.0)
        break
    if boss_enemy != null and boss_pressure_root == null:
        _build_boss_pressure_rig()
    if boss_pressure_root == null:
        return
    boss_pressure_root.visible = boss_enemy != null
    if boss_enemy == null:
        return

    var time := Time.get_ticks_msec() / 1000.0
    var intensity := lerpf(1.0, 1.18, 1.0 - boss_health_ratio)
    var cast_t := 1.0 - clampf(float(boss_enemy.get("attack_timer")) / 0.68, 0.0, 1.0)
    var cinematic_state := _boss_cinematic_state(boss_health_ratio, cast_t)
    var cinematic_intensity := _boss_cinematic_intensity(boss_health_ratio, cast_t)
    boss_pressure_root.set_meta("boss_kind", boss_kind)
    boss_pressure_root.set_meta("cinematic_state", cinematic_state)
    boss_pressure_root.set_meta("cinematic_intensity", cinematic_intensity)
    boss_pressure_root.set_meta("boss_health_ratio", boss_health_ratio)
    boss_pressure_root.set_meta("boss_cast_t", cast_t)
    var arena_ritual := boss_pressure_root.get_node_or_null("ArenaRitual") as Node3D
    if arena_ritual != null:
        arena_ritual.set_meta("cinematic_state", cinematic_state)
        arena_ritual.set_meta("cinematic_intensity", cinematic_intensity)
        arena_ritual.rotation.y = time * 0.11
        var ritual_scale := intensity + cinematic_intensity * 0.035 + sin(time * (1.35 + cinematic_intensity * 0.55)) * (0.018 + cinematic_intensity * 0.018)
        arena_ritual.scale = Vector3(ritual_scale, 1.0, ritual_scale)
        _sync_boss_health_sigils(arena_ritual, boss_health_ratio, time)
        _sync_boss_cast_sigils(arena_ritual, cast_t, time)
        _sync_boss_domain_profiles(arena_ritual, boss_kind, boss_health_ratio, cast_t, time, cinematic_state, cinematic_intensity)
        _sync_boss_arena_lockdown(arena_ritual, boss_kind, boss_health_ratio, cast_t, time, cinematic_state, cinematic_intensity)
    var boss_focus := boss_pressure_root.get_node_or_null("BossFocus") as Node3D
    if boss_focus != null:
        boss_focus.set_meta("boss_kind", boss_kind)
        boss_focus.set_meta("cinematic_state", cinematic_state)
        boss_focus.set_meta("cinematic_intensity", cinematic_intensity)
        boss_focus.global_position = _to3d(boss_enemy.global_position, 0.0)
        boss_focus.rotation.y = -time * (0.38 + cinematic_intensity * 0.10)
        var focus_scale := intensity + cinematic_intensity * 0.045 + sin(time * (2.8 + cinematic_intensity * 1.2)) * (0.045 + cinematic_intensity * 0.030)
        boss_focus.scale = Vector3(focus_scale, 1.0, focus_scale)
        _set_boss_pressure_signature(boss_focus, boss_kind)
        _sync_boss_focus_cinematic_state(boss_focus, boss_kind, cinematic_state, cinematic_intensity, time)
        _sync_boss_cast_focus(boss_focus, cast_t, time, cinematic_state, cinematic_intensity)
        _sync_boss_cast_patterns(boss_focus, boss_kind, cast_t, time, cinematic_state, cinematic_intensity)

func _boss_cinematic_state(boss_health_ratio: float, cast_t: float) -> String:
    if cast_t >= 0.62:
        return "casting"
    if boss_health_ratio <= 0.33:
        return "enraged"
    if cast_t > 0.04:
        return "windup"
    if boss_health_ratio <= 0.55:
        return "pressuring"
    return "steady"

func _boss_cinematic_intensity(boss_health_ratio: float, cast_t: float) -> float:
    var health_pressure := clampf((0.70 - boss_health_ratio) / 0.70, 0.0, 1.0)
    return clampf(maxf(health_pressure, cast_t), 0.0, 1.0)

func _sync_boss_health_sigils(arena_ritual: Node3D, boss_health_ratio: float, time: float) -> void:
    var sigils := arena_ritual.get_node_or_null("BossHealthSigils") as Node3D
    if sigils == null:
        return
    var alive_count := clampi(ceili(boss_health_ratio * 8.0), 0, 8)
    for child in sigils.get_children():
        var sigil := child as Node3D
        if sigil == null:
            continue
        var index := int(sigil.get_meta("index", 0))
        var alive := sigil.get_node_or_null("Alive") as Node3D
        var broken := sigil.get_node_or_null("Broken") as Node3D
        var is_alive := index < alive_count
        if alive != null:
            alive.visible = is_alive
        if broken != null:
            broken.visible = not is_alive
        var phase_pulse := 1.0 + sin(time * (2.2 + float(index) * 0.08)) * (0.026 if is_alive else 0.052)
        sigil.scale = Vector3.ONE * phase_pulse
        if not is_alive:
            sigil.rotation.y += 0.010

func _sync_boss_cast_sigils(arena_ritual: Node3D, cast_t: float, time: float) -> void:
    var sigils := arena_ritual.get_node_or_null("BossCastSigils") as Node3D
    if sigils == null:
        return
    var active := cast_t > 0.0
    sigils.visible = active
    if not active:
        return
    sigils.rotation.y = -time * 0.18
    sigils.scale = Vector3.ONE * lerpf(0.88, 1.16, cast_t)
    var cast_sigil_nodes := []
    for child in sigils.get_children():
        var sigil := child as Node3D
        if sigil == null:
            continue
        if sigil.name == "BossCastVfxDecal":
            sigil.visible = true
            sigil.rotation.y = time * 0.16
            sigil.scale = Vector3.ONE * (0.90 + cast_t * 0.22 + sin(time * 5.0) * 0.035)
            continue
        cast_sigil_nodes.append(sigil)
    var lit_count := clampi(ceili(cast_t * float(cast_sigil_nodes.size())), 0, cast_sigil_nodes.size())
    for i in range(cast_sigil_nodes.size()):
        var sigil := cast_sigil_nodes[i] as Node3D
        if sigil == null:
            continue
        sigil.visible = i < lit_count
        sigil.scale = Vector3.ONE * (1.0 + sin(time * 5.4 + float(i) * 0.48) * 0.060)

func _sync_boss_cast_focus(boss_focus: Node3D, cast_t: float, time: float, cinematic_state: String, cinematic_intensity: float) -> void:
    var focus := boss_focus.get_node_or_null("BossCastFocus") as Node3D
    if focus == null:
        return
    focus.set_meta("cinematic_state", cinematic_state)
    focus.set_meta("cinematic_intensity", cinematic_intensity)
    focus.visible = cast_t > 0.0
    if not focus.visible:
        return
    focus.rotation.y = time * (0.62 + cinematic_intensity * 0.22)
    var pulse := lerpf(0.70, 1.28, cast_t) + cinematic_intensity * 0.055 + sin(time * (6.0 + cinematic_intensity * 1.4)) * 0.035
    focus.scale = Vector3.ONE * pulse
    var decal := focus.get_node_or_null("BossCastFocusVfxDecal") as Node3D
    if decal != null:
        decal.rotation.y = -time * 0.44
        decal.scale = Vector3.ONE * (0.92 + cast_t * 0.22 + sin(time * 7.2) * 0.040)
    var warning_frame := focus.get_node_or_null("BossCastWarningFrame") as Node3D
    if warning_frame != null:
        warning_frame.visible = true
        warning_frame.rotation.y = -time * 0.82
        warning_frame.scale = Vector3.ONE * (lerpf(0.78, 1.18, cast_t) + sin(time * 8.0) * 0.028)
        var pip_count := 0
        for child in warning_frame.get_children():
            if str(child.name).begins_with("BossCastCountdownPip"):
                pip_count += 1
        var lit_count := clampi(ceili(cast_t * float(pip_count)), 0, pip_count)
        for child in warning_frame.get_children():
            var pip := child as Node3D
            if pip == null or not str(pip.name).begins_with("BossCastCountdownPip"):
                continue
            var index := int(pip.get_meta("index", 0))
            pip.visible = index < lit_count
            pip.scale = Vector3.ONE * (1.0 + sin(time * 9.2 + float(index)) * 0.070)

func _sync_boss_cast_patterns(boss_focus: Node3D, boss_kind: String, cast_t: float, time: float, cinematic_state: String, cinematic_intensity: float) -> void:
    var rig := boss_focus.get_node_or_null("BossCastPatternRig") as Node3D
    if rig == null:
        return
    rig.set_meta("cinematic_state", cinematic_state)
    rig.set_meta("cinematic_intensity", cinematic_intensity)
    rig.visible = cast_t > 0.0
    for child in rig.get_children():
        var pattern := child as Node3D
        if pattern == null:
            continue
        pattern.visible = rig.visible and str(pattern.name).to_lower().contains(boss_kind.replace("boss_", ""))
        if not pattern.visible:
            continue
        pattern.set_meta("cinematic_state", cinematic_state)
        pattern.set_meta("cinematic_intensity", cinematic_intensity)
        var scale_pulse := lerpf(0.74, 1.24, cast_t) + cinematic_intensity * 0.060 + sin(time * (5.6 + cinematic_intensity * 1.2)) * 0.030
        pattern.scale = Vector3(scale_pulse, 1.0, scale_pulse)
        pattern.position.y = sin(time * 6.2) * 0.006
        _sync_boss_cast_intent_profile(pattern, cast_t, time)
        _sync_boss_cast_safety_profile(pattern, boss_kind, cast_t, time, cinematic_intensity)
        match boss_kind:
            "boss_velkoz":
                pattern.rotation.y = sin(time * 1.8) * 0.10
                var eye_core := pattern.get_node_or_null("BossCastVelkozEyeCore") as Node3D
                if eye_core != null:
                    eye_core.rotation.y = -time * 0.92
                    eye_core.scale = Vector3.ONE * (0.92 + cast_t * 0.26 + sin(time * 7.4) * 0.045)
            "boss_reksai":
                pattern.rotation.y = sin(time * 2.2) * 0.05
                var tremor := pattern.get_node_or_null("BossCastReksaiTremorWake") as Node3D
                if tremor != null:
                    tremor.position.y = sin(time * 10.0) * 0.010
                    tremor.scale = Vector3(lerpf(0.86, 1.18, cast_t), 1.0, lerpf(0.92, 1.28, cast_t))
            "boss_belveth":
                pattern.rotation.y = sin(time * 2.8) * 0.12
                var needles := pattern.get_node_or_null("BossCastBelvethRoyalNeedles") as Node3D
                if needles != null:
                    needles.rotation.y = time * 0.54
                    needles.scale = Vector3.ONE * (0.94 + cast_t * 0.20)
            _:
                pattern.rotation.y = time * 0.10
                var cho_teeth := pattern.get_node_or_null("BossCastChoImpactTeeth") as Node3D
                if cho_teeth != null:
                    cho_teeth.rotation.y = -time * 0.44
                    cho_teeth.scale = Vector3.ONE * (0.88 + cast_t * 0.24 + sin(time * 6.8) * 0.036)

func _sync_boss_cast_intent_profile(pattern: Node3D, cast_t: float, time: float) -> void:
    var profile := pattern.get_node_or_null("BossCastIntentProfile") as Node3D
    if profile == null:
        return
    profile.visible = true
    profile.rotation.y = -time * 0.72
    var pulse := lerpf(0.84, 1.18, cast_t) + sin(time * 8.4) * 0.036
    profile.scale = Vector3(pulse, 1.0, pulse)
    var frame := profile.get_node_or_null("BossCastIntentFrame") as Node3D
    if frame != null:
        frame.rotation.y = time * 1.15
    var pip := profile.get_node_or_null("BossCastIntentPip") as Node3D
    if pip != null:
        pip.scale = Vector3.ONE * (0.88 + cast_t * 0.38 + sin(time * 10.0) * 0.055)
    var detail_name := str(profile.get_meta("detail_node", ""))
    var detail := profile.get_node_or_null(detail_name) as Node3D
    if detail != null:
        var base_y := float(detail.get_meta("base_y", detail.position.y))
        detail.position.y = base_y + sin(time * 9.6) * 0.014
        detail.scale = Vector3.ONE * (0.90 + cast_t * 0.24)

func _sync_boss_cast_safety_profile(pattern: Node3D, boss_kind: String, cast_t: float, time: float, cinematic_intensity: float) -> void:
    var profile := pattern.get_node_or_null("BossCastSafetyProfile") as Node3D
    if profile == null:
        return
    profile.visible = true
    profile.set_meta("boss_kind", boss_kind)
    profile.set_meta("boss_cast_t", cast_t)
    profile.set_meta("cinematic_intensity", cinematic_intensity)
    profile.rotation.y = sin(time * 1.65 + float(boss_kind.length())) * 0.030
    var pulse := 0.94 + cast_t * 0.12 + cinematic_intensity * 0.035 + sin(time * 5.8) * 0.012
    profile.scale = Vector3(pulse, 1.0, pulse)

    var pockets := profile.get_node_or_null("BossCastSafePocketRoot") as Node3D
    if pockets != null:
        var pocket_index := 0
        for child in pockets.get_children():
            var pocket := child as Node3D
            if pocket == null:
                continue
            pocket.visible = cast_t < 0.92 or pocket_index % 2 == 0
            var pocket_pulse := 1.0 + sin(time * 4.2 + float(pocket_index) * 0.7) * 0.022 + cast_t * 0.035
            pocket.scale = Vector3(pocket_pulse, 1.0, pocket_pulse)
            pocket.set_meta("boss_cast_t", cast_t)
            pocket_index += 1

    var margins := profile.get_node_or_null("BossCastHazardMarginRoot") as Node3D
    if margins != null:
        var margin_index := 0
        for child in margins.get_children():
            var margin := child as Node3D
            if margin == null:
                continue
            margin.visible = cast_t > 0.18
            margin.scale = Vector3(1.0 + cast_t * 0.10, 1.0, 1.0 + sin(time * 6.0 + float(margin_index)) * 0.030)
            margin.set_meta("boss_cast_t", cast_t)
            margin_index += 1

    var arrows := profile.get_node_or_null("BossCastSafeExitArrowRoot") as Node3D
    if arrows != null:
        arrows.set_meta("boss_cast_t", cast_t)
        var arrow_index := 0
        for child in arrows.get_children():
            var arrow := child as Node3D
            if arrow == null:
                continue
            arrow.visible = cast_t < 0.98
            var arrow_pulse := 1.0 + sin(time * 4.8 + float(arrow_index) * 0.63) * 0.014 + cast_t * 0.018
            arrow.scale = Vector3(arrow_pulse, 1.0, arrow_pulse)
            arrow.set_meta("boss_cast_t", cast_t)
            arrow_index += 1

    var detail_name := str(profile.get_meta("detail_node", ""))
    var detail := profile.get_node_or_null(detail_name) as Node3D
    if detail != null:
        detail.position.y = float(detail.get_meta("base_y", detail.position.y)) + sin(time * 6.4) * 0.008
        detail.scale = Vector3.ONE * (0.92 + cast_t * 0.10 + cinematic_intensity * 0.030)

func _set_boss_pressure_signature(parent: Node3D, boss_kind: String) -> void:
    var cho := parent.get_node_or_null("SigCho") as Node3D
    var velkoz := parent.get_node_or_null("SigVelkoz") as Node3D
    var reksai := parent.get_node_or_null("SigReksai") as Node3D
    var belveth := parent.get_node_or_null("SigBelveth") as Node3D
    if cho != null:
        cho.visible = boss_kind == "boss_cho"
    if velkoz != null:
        velkoz.visible = boss_kind == "boss_velkoz"
    if reksai != null:
        reksai.visible = boss_kind == "boss_reksai"
    if belveth != null:
        belveth.visible = boss_kind == "boss_belveth"

func _boss_pressure_signature_name(boss_kind: String) -> String:
    match boss_kind:
        "boss_cho":
            return "SigCho"
        "boss_velkoz":
            return "SigVelkoz"
        "boss_reksai":
            return "SigReksai"
        "boss_belveth":
            return "SigBelveth"
        _:
            return ""

func _sync_boss_focus_cinematic_state(boss_focus: Node3D, boss_kind: String, cinematic_state: String, cinematic_intensity: float, time: float) -> void:
    var active_name := _boss_pressure_signature_name(boss_kind)
    for signature_name in ["SigCho", "SigVelkoz", "SigReksai", "SigBelveth"]:
        var signature := boss_focus.get_node_or_null(str(signature_name)) as Node3D
        if signature == null:
            continue
        var active: bool = str(signature_name) == active_name
        signature.set_meta("boss_kind", boss_kind if active else "")
        signature.set_meta("cinematic_state", cinematic_state if active else "inactive")
        signature.set_meta("cinematic_intensity", cinematic_intensity if active else 0.0)
        if not active:
            signature.scale = Vector3.ONE
            continue
        var state_scale := 1.0 + cinematic_intensity * 0.16 + sin(time * (3.4 + cinematic_intensity * 1.6)) * (0.020 + cinematic_intensity * 0.030)
        signature.scale = Vector3(state_scale, 1.0, state_scale)
        if cinematic_state == "casting":
            signature.rotation.y += 0.035 + cinematic_intensity * 0.020
        elif cinematic_state == "enraged":
            signature.rotation.y -= 0.028 + cinematic_intensity * 0.025
        elif cinematic_state == "pressuring":
            signature.rotation.y += 0.012

func _sync_spawn_gateway_motion(delta: float, time: float) -> void:
    for i in range(spawn_gateway_motion_nodes.size()):
        var root := spawn_gateway_motion_nodes[i]
        if root == null or not is_instance_valid(root):
            continue
        var void_gate := bool(root.get_meta("void_gate", false))
        var speed := 0.42 if void_gate else -0.32
        var portal := root.get_node_or_null("PortalDisc") as Node3D
        if portal != null:
            portal.rotation.z += delta * speed
            var pulse := 1.0 + sin(time * (2.1 if void_gate else 1.7) + float(i)) * 0.050
            portal.scale = Vector3.ONE * pulse
            var core := portal.get_node_or_null("Core") as Node3D
            if core != null:
                core.scale = Vector3.ONE * (1.0 + sin(time * 4.2 + float(i)) * 0.12)
        var ground := root.get_node_or_null("GroundRunes") as Node3D
        if ground != null:
            ground.rotation.y += delta * (-0.18 if void_gate else 0.14)
            var ground_pulse := 1.0 + sin(time * 1.35 + float(i) * 0.7) * 0.035
            ground.scale = Vector3(ground_pulse, 1.0, ground_pulse)

func _build_arena_side_modules() -> void:
    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    _add_side_module(Vector3(0, 0, -half_z + 3.85), 0.0, HEXTECH_BLUE)
    _add_side_module(Vector3(0, 0, half_z - 3.85), 180.0, VOID_PURPLE)
    _add_side_module(Vector3(-half_x + 4.75, 0, 0), 90.0, HEXTECH_BLUE)
    _add_side_module(Vector3(half_x - 4.75, 0, 0), -90.0, VOID_PURPLE)

    var node_mat := _mat("arena_side_small_node", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42), 0.58, true, true)
    for i in range(8):
        var angle := TAU * float(i) / 8.0
        var outer_pos := Vector3(cos(angle) * 9.8, 0.112, sin(angle) * 5.9)
        _add_cylinder_segments(self, 0.20, 0.026, 6, node_mat, outer_pos, Vector3(0, 30, 0))
        _add_box(self, Vector3(0.78, 0.014, 0.032), node_mat, outer_pos * 0.92 + Vector3(0, 0.012, 0), Vector3(0, -rad_to_deg(angle), 0))

func _add_side_module(pos: Vector3, yaw: float, color: Color) -> void:
    var base_mat := _mat("arena_side_module_base", Color(0.038, 0.036, 0.060), 0.04, true)
    var bevel_mat := _mat("arena_side_module_bevel", Color(0.082, 0.072, 0.106), 0.05, true)
    var trim_mat := _mat("arena_side_module_gold_trim", HEXTECH_GOLD, 0.22, true)
    var glow_mat := _mat("arena_side_module_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.42), 0.88, true, true)
    var rot := Vector3(0, yaw, 0)
    _add_box(self, Vector3(5.8, 0.18, 1.36), base_mat, pos + Vector3(0, 0.080, 0), rot)
    _add_box(self, Vector3(4.9, 0.060, 0.16), trim_mat, pos + Vector3(0, 0.205, 0), rot)
    _add_box(self, Vector3(2.4, 0.042, 0.070), glow_mat, pos + Vector3(0, 0.252, 0), rot)
    _add_cylinder_segments(self, 0.62, 0.090, 8, bevel_mat, pos + Vector3(0, 0.275, 0), Vector3(0, yaw + 22.5, 0))
    _add_cylinder_segments(self, 0.38, 0.032, 24, glow_mat, pos + Vector3(0, 0.340, 0))
    for socket_index in range(3):
        var offset := -1.62 + float(socket_index) * 1.62
        var local := Vector3(offset, 0, 0).rotated(Vector3.UP, deg_to_rad(yaw))
        _add_cylinder_segments(self, 0.18, 0.034, 6, trim_mat, pos + local + Vector3(0, 0.288, 0), Vector3(0, yaw + 30.0, 0))
        _add_sphere(self, 0.075, glow_mat, pos + local + Vector3(0, 0.370, 0))

func _build_void_cracks() -> void:
    var crack_mat := _mat("void_floor_crack", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.52), 0.95, true, true)
    var ember_mat := _mat("void_floor_ember", Color(1.0, 0.20, 0.72, 0.62), 1.10, true, true)
    var cracks := [
        [Vector3(-15.2, 0.075, -8.4), 3.2, -18.0],
        [Vector3(-11.6, 0.078, 7.6), 2.6, 24.0],
        [Vector3(-5.8, 0.080, -11.0), 2.1, 58.0],
        [Vector3(6.4, 0.076, 9.4), 3.0, -34.0],
        [Vector3(13.8, 0.078, -6.4), 2.9, 18.0],
        [Vector3(18.4, 0.080, 5.8), 1.9, 72.0],
        [Vector3(2.6, 0.080, -7.0), 2.4, 38.0],
        [Vector3(-18.2, 0.079, 2.8), 2.1, -62.0]
    ]
    for crack in cracks:
        var pos: Vector3 = crack[0]
        var length := float(crack[1])
        var yaw := float(crack[2])
        _add_box(self, Vector3(length, 0.022, 0.052), crack_mat, pos, Vector3(0, yaw, 0))
        _add_sphere(self, 0.075, ember_mat, pos + Vector3(cos(deg_to_rad(yaw)) * length * 0.46, 0.028, sin(deg_to_rad(yaw)) * length * 0.46))

func _build_void_texture_overlays() -> void:
    var void_floor_path := _void_floor_texture_path()
    if not _asset_available(void_floor_path):
        return
    var mat := _texture_mat("void_corruption_overlay", void_floor_path, Color(0.56, 0.18, 0.86, 0.34), 0.36, true, true, Vector3(1.25, 1.0, 1.0))
    var patches := [
        [Vector3(13.8, 0.074, 4.6), Vector2(15.6, 10.8), -8.0],
        [Vector3(-14.2, 0.073, -8.4), Vector2(9.6, 5.8), 18.0],
        [Vector3(2.6, 0.072, -10.8), Vector2(8.4, 4.6), -22.0]
    ]
    for patch in patches:
        var pos: Vector3 = patch[0]
        var size: Vector2 = patch[1]
        var yaw := float(patch[2])
        _add_textured_plane(self, size, mat, pos, Vector3(0, yaw, 0))

func _build_hextech_pylons() -> void:
    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var corner_positions := [
        Vector3(-half_x + 3.1, 0, -half_z + 2.7),
        Vector3(half_x - 3.1, 0, -half_z + 2.7),
        Vector3(-half_x + 3.1, 0, half_z - 2.7),
        Vector3(half_x - 3.1, 0, half_z - 2.7)
    ]
    for i in range(corner_positions.size()):
        var color := HEXTECH_BLUE if i % 2 == 0 else VOID_PURPLE
        _add_hextech_pillar(corner_positions[i], color, 1.0)
        _add_arena_light(corner_positions[i] + Vector3(0, 3.1, 0), color, 1.7)
    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        _add_crystal(self, 0.22, 0.92, Color(0.38, 1.0, 0.48), Vector3(cos(angle) * 12.8, 0.52, sin(angle) * 7.4), Vector3(0, float(i) * 30.0, 0))

func _build_arena_relic_clusters() -> void:
    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var relics := [
        [Vector3(-half_x + 6.6, 0, -half_z + 5.1), 34.0, HEXTECH_BLUE, false],
        [Vector3(half_x - 6.6, 0, -half_z + 5.1), -34.0, HEXTECH_BLUE, false],
        [Vector3(-half_x + 6.8, 0, half_z - 5.4), -28.0, VOID_PURPLE, true],
        [Vector3(half_x - 6.8, 0, half_z - 5.4), 28.0, VOID_PURPLE, true],
        [Vector3(-half_x + 3.4, 0, -1.8), 90.0, Color(0.38, 1.0, 0.48), false],
        [Vector3(half_x - 3.4, 0, 1.8), -90.0, VOID_PURPLE, true],
        [Vector3(-4.6, 0, half_z - 2.7), 180.0, VOID_PURPLE, true],
        [Vector3(4.6, 0, -half_z + 2.7), 0.0, HEXTECH_BLUE, false]
    ]
    for relic in relics:
        _add_relic_cluster(relic[0], float(relic[1]), relic[2], bool(relic[3]))

func _build_arena_objective_shrine_set() -> void:
    var root := Node3D.new()
    root.name = "ArenaObjectiveShrineSet"
    add_child(root)

    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var shrine_specs := [
        [Vector3(-half_x + 8.3, 0, -half_z + 3.2), 28.0, HEXTECH_BLUE, "hextech"],
        [Vector3(half_x - 8.3, 0, -half_z + 3.2), -28.0, HEXTECH_BLUE, "hextech"],
        [Vector3(-half_x + 8.3, 0, half_z - 3.2), -28.0, VOID_PURPLE, "void"],
        [Vector3(half_x - 8.3, 0, half_z - 3.2), 28.0, VOID_PURPLE, "void"],
        [Vector3(-half_x + 2.8, 0, half_z * 0.34), 86.0, Color(0.34, 1.0, 0.44), "reward"],
        [Vector3(half_x - 2.8, 0, -half_z * 0.34), -86.0, Color(0.34, 1.0, 0.44), "reward"]
    ]
    for i in range(shrine_specs.size()):
        var spec: Array = shrine_specs[i]
        _add_arena_objective_shrine(root, spec[0], float(spec[1]), spec[2], str(spec[3]), i)

func _add_arena_objective_shrine(parent: Node3D, pos: Vector3, yaw: float, color: Color, shrine_type: String, index: int) -> void:
    var shrine := Node3D.new()
    shrine.name = "ObjectiveShrine_%s_%d" % [shrine_type.capitalize(), index]
    shrine.position = pos
    shrine.rotation_degrees = Vector3(0, yaw, 0)
    shrine.set_meta("objective_shrine", true)
    shrine.set_meta("shrine_type", shrine_type)
    shrine.set_meta("index", index)
    parent.add_child(shrine)

    var base_mat := _texture_mat("objective_shrine_metal_" + shrine_type, _hextech_metal_texture_path(), Color(0.18, 0.18, 0.24), 0.06, true, false, Vector3(1.2, 1.0, 1.0))
    var dark_mat := _mat("objective_shrine_dark_" + shrine_type, Color(0.018, 0.014, 0.032, 0.54), 0.06, true, true)
    var glow_mat := _mat("objective_shrine_glow_" + shrine_type, Color(color.r, color.g, color.b, 0.36), 0.94, true, true)
    var hot_mat := _mat("objective_shrine_hot_" + shrine_type, Color(color.lightened(0.18).r, color.lightened(0.18).g, color.lightened(0.18).b, 0.58), 1.18, true, true)
    var gold_mat := _mat("objective_shrine_gold_" + shrine_type, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42), 0.78, true, true)

    var base := _add_cylinder_segments(shrine, 0.76, 0.088, 8, base_mat, Vector3(0, 0.060, 0), Vector3(0, 22.5, 0))
    base.name = "ObjectiveShrineBase"
    var frame := _add_cylinder_segments(shrine, 0.58, 0.018, 6, gold_mat, Vector3(0, 0.126, 0), Vector3(0, 30, 0))
    frame.name = "ObjectiveShrineFrame"
    var glow := _add_cylinder_segments(shrine, 0.44, 0.012, 18, glow_mat, Vector3(0, 0.150, 0))
    glow.name = "ObjectiveShrineGlowRing"

    var crystal_color := color
    if shrine_type == "void":
        crystal_color = VOID_PURPLE
    elif shrine_type == "hextech":
        crystal_color = HEXTECH_BLUE
    var crystal := _add_crystal(shrine, 0.145, 0.58, crystal_color, Vector3(0, 0.440, 0), Vector3(0, 30, 0))
    crystal.name = "ObjectiveShrineCrystal"

    var sigil := Node3D.new()
    sigil.name = "ObjectiveShrineSigil"
    sigil.set_meta("shrine_type", shrine_type)
    shrine.add_child(sigil)
    match shrine_type:
        "hextech":
            _add_cylinder_segments(sigil, 0.31, 0.010, 6, hot_mat, Vector3(0, 0.236, 0), Vector3(0, 30, 0))
            _add_box(sigil, Vector3(0.70, 0.010, 0.038), glow_mat, Vector3(0, 0.254, 0))
            _add_box(sigil, Vector3(0.038, 0.010, 0.70), glow_mat, Vector3(0, 0.256, 0))
        "void":
            _add_cylinder_segments(sigil, 0.34, 0.010, 5, hot_mat, Vector3(0, 0.236, 0), Vector3(0, 18, 0))
            for side in [-1.0, 1.0]:
                _add_box(sigil, Vector3(0.060, 0.012, 0.54), hot_mat, Vector3(side * 0.19, 0.258, 0.02), Vector3(0, side * 18.0, side * 34.0))
        "reward":
            _add_cylinder_segments(sigil, 0.32, 0.010, 6, hot_mat, Vector3(0, 0.236, 0), Vector3(0, 30, 0))
            _add_cylinder_segments(sigil, 0.19, 0.014, 6, gold_mat, Vector3(0, 0.260, 0), Vector3(0, 30, 0))
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_sphere(sigil, 0.040, glow_mat, Vector3(cos(angle) * 0.34, 0.282, sin(angle) * 0.34))
        _:
            _add_cylinder_segments(sigil, 0.30, 0.010, 6, hot_mat, Vector3(0, 0.236, 0), Vector3(0, 30, 0))
            _add_box(sigil, Vector3(0.54, 0.010, 0.038), dark_mat, Vector3(0, 0.254, 0))

func _build_arena_premium_set_dressing() -> void:
    var root := Node3D.new()
    root.name = "ArenaPremiumSetDressing"
    add_child(root)
    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var bastions := [
        [Vector3(-half_x + 8.9, 0, -half_z + 7.1), 28.0, HEXTECH_BLUE],
        [Vector3(half_x - 8.9, 0, -half_z + 7.1), -28.0, HEXTECH_BLUE],
        [Vector3(-half_x + 8.4, 0, half_z - 7.2), -30.0, VOID_PURPLE],
        [Vector3(half_x - 8.4, 0, half_z - 7.2), 30.0, VOID_PURPLE]
    ]
    for item in bastions:
        var item_color: Color = item[2]
        if item_color == VOID_PURPLE:
            _add_void_nest_set_piece(root, item[0], float(item[1]))
        else:
            _add_hextech_bastion_set_piece(root, item[0], float(item[1]), item_color)
    _add_hextech_bastion_set_piece(root, Vector3(-half_x + 3.4, 0, -half_z * 0.46), 88.0, HEXTECH_BLUE)
    _add_void_nest_set_piece(root, Vector3(half_x - 3.4, 0, half_z * 0.46), -88.0)

func _build_arena_ritual_tower_set() -> void:
    var root := Node3D.new()
    root.name = "ArenaRitualTowerSet"
    add_child(root)
    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    var major_specs := [
        [Vector3(-half_x + 5.4, 0, -half_z + 4.7), 36.0, HEXTECH_BLUE],
        [Vector3(half_x - 5.4, 0, -half_z + 4.7), -36.0, HEXTECH_BLUE],
        [Vector3(-half_x + 5.4, 0, half_z - 4.7), -36.0, VOID_PURPLE],
        [Vector3(half_x - 5.4, 0, half_z - 4.7), 36.0, VOID_PURPLE]
    ]
    var major_positions := []
    for i in range(major_specs.size()):
        var spec: Array = major_specs[i]
        var pos: Vector3 = spec[0]
        major_positions.append(pos)
        _add_ritual_tower(root, pos, float(spec[1]), spec[2], true, i)

    var minor_specs := [
        [Vector3(0, 0, -half_z + 3.05), 0.0, HEXTECH_BLUE],
        [Vector3(0, 0, half_z - 3.05), 180.0, VOID_PURPLE],
        [Vector3(-half_x + 3.65, 0, 0), 90.0, HEXTECH_BLUE],
        [Vector3(half_x - 3.65, 0, 0), -90.0, VOID_PURPLE]
    ]
    for i in range(minor_specs.size()):
        var spec: Array = minor_specs[i]
        _add_ritual_tower(root, spec[0], float(spec[1]), spec[2], false, i)

    _add_ritual_energy_bridge(root, major_positions[0], major_positions[1], HEXTECH_BLUE, 0)
    _add_ritual_energy_bridge(root, major_positions[1], major_positions[3], Color(0.55, 0.42, 1.0), 1)
    _add_ritual_energy_bridge(root, major_positions[3], major_positions[2], VOID_PURPLE, 2)
    _add_ritual_energy_bridge(root, major_positions[2], major_positions[0], Color(0.38, 0.90, 1.0), 3)
    _add_ritual_energy_bridge(root, Vector3(0, 0, -half_z + 3.05), Vector3(0, 0, half_z - 3.05), Color(0.50, 0.72, 1.0), 4)
    _add_ritual_energy_bridge(root, Vector3(-half_x + 3.65, 0, 0), Vector3(half_x - 3.65, 0, 0), Color(0.72, 0.30, 1.0), 5)

func _add_ritual_tower(parent: Node3D, pos: Vector3, yaw: float, color: Color, major: bool, index: int) -> void:
    var tower := Node3D.new()
    tower.name = "RitualTower_%s_%d" % ["Major" if major else "Minor", index]
    tower.position = pos
    tower.rotation_degrees = Vector3(0, yaw, 0)
    tower.set_meta("ritual_tower", true)
    tower.set_meta("ritual_major", major)
    parent.add_child(tower)

    var scale := 1.0 if major else 0.66
    var stone_mat := _texture_mat("ritual_tower_metal", _hextech_metal_texture_path(), Color(0.36, 0.38, 0.48), 0.08, true, false, Vector3(1.4, 1.0, 1.0))
    var trim_mat := _mat("ritual_tower_gold_trim", HEXTECH_GOLD, 0.22, true)
    var glow_mat := _mat("ritual_tower_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.44), 1.02, true, true)
    var hot_mat := _mat("ritual_tower_hot_" + color.to_html(false), color.lightened(0.18), 1.24, true)

    _add_cylinder_segments(tower, 1.08 * scale, 0.16 * scale, 8, stone_mat, Vector3(0, 0.080 * scale, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(tower, 0.88 * scale, 0.052 * scale, 8, trim_mat, Vector3(0, 0.190 * scale, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(tower, 0.62 * scale, 0.74 * scale, 8, stone_mat, Vector3(0, 0.545 * scale, 0), Vector3(0, 22.5, 0))
    var pulse_ring := Node3D.new()
    pulse_ring.name = "PulseRing"
    tower.add_child(pulse_ring)
    _add_cylinder_segments(pulse_ring, 0.74 * scale, 0.022 * scale, 24, glow_mat, Vector3(0, 0.940 * scale, 0))
    _add_cylinder_segments(pulse_ring, 0.48 * scale, 0.018 * scale, 8, glow_mat, Vector3(0, 0.984 * scale, 0), Vector3(0, 22.5, 0))
    var crystal := _add_crystal(tower, 0.22 * scale, 0.92 * scale, color, Vector3(0, 1.360 * scale, 0), Vector3(0, 30, 0))
    crystal.name = "RitualCoreCrystal"
    _add_sphere(tower, 0.085 * scale, hot_mat, Vector3(0, 1.820 * scale, 0))

    var fin_count := 4 if major else 3
    for i in range(fin_count):
        var angle := TAU * float(i) / float(fin_count)
        var local := Vector3(cos(angle) * 0.70 * scale, 0, sin(angle) * 0.70 * scale)
        _add_box(tower, Vector3(0.13 * scale, 0.54 * scale, 0.23 * scale), trim_mat, local + Vector3(0, 0.610 * scale, 0), Vector3(0, -rad_to_deg(angle), 14.0))
        _add_box(tower, Vector3(0.055 * scale, 0.13 * scale, 0.52 * scale), glow_mat, local * 0.94 + Vector3(0, 0.840 * scale, 0), Vector3(0, -rad_to_deg(angle), 0))

    if major:
        _add_cylinder_segments(tower, 1.34 * scale, 0.014 * scale, 8, glow_mat, Vector3(0, 0.070 * scale, 0), Vector3(0, 22.5, 0))
        for side in [-1.0, 1.0]:
            _add_box(tower, Vector3(1.66 * scale, 0.016 * scale, 0.050 * scale), glow_mat, Vector3(0, 0.104 * scale, side * 0.46 * scale))
            _add_box(tower, Vector3(0.050 * scale, 0.016 * scale, 1.42 * scale), glow_mat, Vector3(side * 0.46 * scale, 0.108 * scale, 0))

    var decal_path := _vfx_decal_texture_path()
    if decal_path != "":
        var glyph_uv := _ritual_tower_glyph_uv(color, major)
        var glyph_mat := _vfx_decal_mat("ritual_tower_glyph_" + color.to_html(false) + ("_major" if major else "_minor"), decal_path, Color(color.r, color.g, color.b, 0.34 if major else 0.26), 0.92 if major else 0.72, Vector3(0.25, 0.25, 1.0), glyph_uv)
        var glyph := _add_textured_plane(tower, Vector2(1.18 * scale, 1.18 * scale), glyph_mat, Vector3(0, 1.900 * scale, 0), Vector3(0, 45, 0))
        glyph.name = "RitualGlyph"

func _ritual_tower_glyph_uv(color: Color, major: bool) -> Vector3:
    if color == VOID_PURPLE:
        return Vector3(0.75, 0.0, 0.0) if major else Vector3(0.25, 0.75, 0.0)
    return Vector3.ZERO if major else Vector3(0.50, 0.25, 0.0)

func _add_ritual_energy_bridge(parent: Node3D, from_pos: Vector3, to_pos: Vector3, color: Color, index: int) -> void:
    var bridge := Node3D.new()
    bridge.name = "RitualEnergyBridge_%d" % index
    parent.add_child(bridge)
    var delta := to_pos - from_pos
    var length := sqrt(delta.x * delta.x + delta.z * delta.z)
    if length <= 0.01:
        return
    var mid := (from_pos + to_pos) * 0.5
    var yaw := -rad_to_deg(atan2(delta.z, delta.x))
    var glow_mat := _mat("ritual_bridge_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.24), 0.84, true, true)
    var trim_mat := _mat("ritual_bridge_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.18), 0.46, true, true)
    _add_box(bridge, Vector3(length, 0.012, 0.048), glow_mat, mid + Vector3(0, 0.126, 0), Vector3(0, yaw, 0))
    _add_box(bridge, Vector3(length * 0.92, 0.010, 0.020), trim_mat, mid + Vector3(0, 0.144, 0), Vector3(0, yaw, 0))
    for side in [-1.0, 1.0]:
        var offset := Vector3(-sin(deg_to_rad(yaw)) * side * 0.17, 0, cos(deg_to_rad(yaw)) * side * 0.17)
        _add_box(bridge, Vector3(length * 0.78, 0.010, 0.018), glow_mat, mid + offset + Vector3(0, 0.138, 0), Vector3(0, yaw, 0))

func _add_hextech_bastion_set_piece(parent: Node3D, pos: Vector3, yaw: float, color: Color) -> void:
    var rot := Vector3(0, yaw, 0)
    var base_mat := _mat("premium_hextech_metal_base", Color(0.048, 0.044, 0.070), 0.04, true)
    var trim_mat := _mat("premium_hextech_gold_trim", HEXTECH_GOLD, 0.24, true)
    var glow_mat := _mat("premium_hextech_blue_core_" + color.to_html(false), Color(color.r, color.g, color.b, 0.42), 0.92, true, true)
    _add_cylinder_segments(parent, 1.18, 0.16, 8, base_mat, pos + Vector3(0, 0.092, 0), Vector3(0, yaw + 22.5, 0))
    _add_cylinder_segments(parent, 0.86, 0.050, 8, trim_mat, pos + Vector3(0, 0.210, 0), Vector3(0, yaw + 22.5, 0))
    _add_cylinder_segments(parent, 0.54, 0.62, 8, base_mat, pos + Vector3(0, 0.560, 0), Vector3(0, yaw + 22.5, 0))
    _add_cylinder_segments(parent, 0.62, 0.030, 24, glow_mat, pos + Vector3(0, 0.900, 0))
    _add_crystal(parent, 0.22, 0.76, color, pos + Vector3(0, 1.28, 0), Vector3(0, yaw + 30.0, 0))
    for side in [-1.0, 1.0]:
        var local := Vector3(side * 0.78, 0, 0.12).rotated(Vector3.UP, deg_to_rad(yaw))
        _add_box(parent, Vector3(0.14, 0.52, 0.32), trim_mat, pos + local + Vector3(0, 0.48, 0), rot)
        _add_box(parent, Vector3(0.070, 0.12, 0.70), glow_mat, pos + local + Vector3(0, 0.74, 0), Vector3(0, yaw + side * 12.0, 0))
    _add_box(parent, Vector3(1.72, 0.014, 0.052), glow_mat, pos + Vector3(0, 0.078, 0), rot)
    _add_box(parent, Vector3(0.052, 0.014, 1.34), glow_mat, pos + Vector3(0, 0.082, 0), rot)

func _add_void_nest_set_piece(parent: Node3D, pos: Vector3, yaw: float) -> void:
    var rot := Vector3(0, yaw, 0)
    var shell_mat := _mat("premium_void_shell_carapace", Color(0.20, 0.08, 0.32), 0.12, true)
    var glow_mat := _mat("premium_void_nest_core", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.48), 1.0, true, true)
    var hot_mat := _mat("premium_void_nest_hot", Color(1.0, 0.28, 0.86, 0.46), 1.14, true, true)
    _add_cylinder_segments(parent, 1.10, 0.11, 8, shell_mat, pos + Vector3(0, 0.074, 0), Vector3(0, yaw + 22.5, 0))
    _add_cylinder_segments(parent, 0.74, 0.026, 8, glow_mat, pos + Vector3(0, 0.158, 0), Vector3(0, yaw + 22.5, 0))
    _add_crystal(parent, 0.20, 0.66, VOID_PURPLE, pos + Vector3(0, 0.64, 0), Vector3(0, yaw + 24.0, 0))
    for i in range(6):
        var angle := TAU * float(i) / 6.0
        var local := Vector3(cos(angle) * 0.78, 0, sin(angle) * 0.58).rotated(Vector3.UP, deg_to_rad(yaw))
        _add_box(parent, Vector3(0.16, 0.16, 0.72), shell_mat, pos + local + Vector3(0, 0.36, 0), Vector3(0, yaw - rad_to_deg(angle), 38.0))
        if i % 2 == 0:
            _add_tapered_cylinder(parent, 0.070, 0.012, 0.52, 6, hot_mat, pos + local * 0.86 + Vector3(0, 0.43, 0), Vector3(68, yaw - rad_to_deg(angle), 0))
    _add_cylinder_segments(parent, 1.34, 0.012, 8, glow_mat, pos + Vector3(0, 0.070, 0), Vector3(0, yaw + 22.5, 0))
    _add_box(parent, Vector3(1.46, 0.014, 0.050), hot_mat, pos + Vector3(0, 0.092, 0), rot)

func _add_relic_cluster(pos: Vector3, yaw: float, color: Color, void_cluster: bool) -> void:
    var rot := Vector3(0, yaw, 0)
    var stone_mat := _mat("relic_cluster_stone", Color(0.036, 0.034, 0.056), 0.03, true)
    var trim_mat := _mat("relic_cluster_trim", HEXTECH_GOLD, 0.20, true)
    var glow_mat := _mat("relic_cluster_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.38), 0.90, true, true)
    var dark_mat := _mat("relic_cluster_dark_" + color.to_html(false), color.darkened(0.42), 0.16, true)
    _add_cylinder_segments(self, 0.72, 0.10, 8, stone_mat, pos + Vector3(0, 0.070, 0), Vector3(0, yaw + 22.5, 0))
    _add_cylinder_segments(self, 0.54, 0.024, 8, trim_mat, pos + Vector3(0, 0.145, 0), Vector3(0, yaw + 22.5, 0))
    _add_cylinder_segments(self, 0.42, 0.014, 24, glow_mat, pos + Vector3(0, 0.182, 0))
    _add_crystal(self, 0.16 if not void_cluster else 0.18, 0.62 if not void_cluster else 0.78, color, pos + Vector3(0, 0.58, 0), Vector3(0, yaw + 30.0, 0))
    for side in [-1.0, 1.0]:
        var local := Vector3(side * 0.56, 0, 0.10).rotated(Vector3.UP, deg_to_rad(yaw))
        if void_cluster:
            _add_box(self, Vector3(0.10, 0.18, 0.52), dark_mat, pos + local + Vector3(0, 0.38, 0), Vector3(0, yaw + side * 18.0, side * 36.0))
            _add_box(self, Vector3(0.055, 0.052, 0.58), glow_mat, pos + local + Vector3(0, 0.42, 0), Vector3(0, yaw + side * 18.0, side * 48.0))
        else:
            _add_cylinder_segments(self, 0.12, 0.34, 6, dark_mat, pos + local + Vector3(0, 0.30, 0), Vector3(0, yaw + 30.0, 0))
            _add_sphere(self, 0.055, glow_mat, pos + local + Vector3(0, 0.52, 0))
    _add_box(self, Vector3(1.20, 0.012, 0.048), glow_mat, pos + Vector3(0, 0.076, 0), rot)

func _add_hextech_pillar(pos: Vector3, color: Color, scale := 1.0) -> void:
    var base_mat := _mat("hex_pillar_base", Color(0.055, 0.048, 0.074), 0.04, true)
    var trim_mat := _mat("hex_pillar_trim", HEXTECH_GOLD, 0.20, true)
    var glow_mat := _mat("hex_pillar_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.42), 0.9, true, true)
    _add_cylinder_segments(self, 0.92 * scale, 0.30 * scale, 8, base_mat, pos + Vector3(0, 0.15 * scale, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(self, 0.72 * scale, 0.08 * scale, 8, trim_mat, pos + Vector3(0, 0.34 * scale, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(self, 0.46 * scale, 0.62 * scale, 8, base_mat, pos + Vector3(0, 0.68 * scale, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(self, 0.52 * scale, 0.035 * scale, 24, glow_mat, pos + Vector3(0, 1.03 * scale, 0))
    _add_crystal(self, 0.23 * scale, 0.92 * scale, color, pos + Vector3(0, 1.42 * scale, 0), Vector3(0, 30, 0))

func _add_arena_light(pos: Vector3, color: Color, energy: float) -> void:
    var light := OmniLight3D.new()
    light.light_color = color
    light.light_energy = energy
    light.omni_range = 9.0
    light.position = pos
    add_child(light)

func _build_spawn_gateways() -> void:
    var half_x := arena.size.x * WORLD_SCALE * 0.5
    var half_z := arena.size.y * WORLD_SCALE * 0.5
    _add_spawn_gateway(Vector3(0, 0, -half_z + 2.05), 0.0, HEXTECH_BLUE, false)
    _add_spawn_gateway(Vector3(0, 0, half_z - 2.05), 180.0, VOID_PURPLE, true)
    _add_spawn_gateway(Vector3(-half_x + 2.35, 0, 0), 90.0, HEXTECH_BLUE, false)
    _add_spawn_gateway(Vector3(half_x - 2.35, 0, 0), -90.0, VOID_PURPLE, true)

    for sx in [-1.0, 1.0]:
        for sz in [-1.0, 1.0]:
            var color := VOID_PURPLE if sx * sz > 0.0 else HEXTECH_BLUE
            var pos := Vector3(sx * (half_x - 5.35), 0, sz * (half_z - 4.25))
            _add_corner_anchor(pos, sx * sz * 42.0, color)

func _add_spawn_gateway(pos: Vector3, yaw: float, color: Color, void_gate: bool) -> void:
    var rot := Vector3(0, yaw, 0)
    var base_mat := _mat("gateway_base", Color(0.032, 0.030, 0.052), 0.03, true)
    var trim_mat := _mat("gateway_trim", HEXTECH_GOLD, 0.20, true)
    var glow_mat := _mat("gateway_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.48), 1.05, true, true)
    var dark_mat := _mat("gateway_dark_" + color.to_html(false), color.darkened(0.46), 0.12, true)
    _add_box(self, Vector3(5.0, 0.20, 1.02), base_mat, pos + Vector3(0, 0.10, 0), rot)
    _add_box(self, Vector3(4.25, 0.045, 0.10), trim_mat, pos + Vector3(0, 0.232, 0), rot)
    _add_box(self, Vector3(2.85, 0.040, 0.060), glow_mat, pos + Vector3(0, 0.286, 0), rot)
    _add_cylinder_segments(self, 0.86, 0.060, 8, dark_mat, pos + Vector3(0, 0.312, 0), Vector3(0, yaw + 22.5, 0))
    _add_cylinder_segments(self, 0.62, 0.026, 24, glow_mat, pos + Vector3(0, 0.372, 0))
    for side in [-1.0, 1.0]:
        var local := Vector3(side * 2.02, 0, 0).rotated(Vector3.UP, deg_to_rad(yaw))
        _add_box(self, Vector3(0.38, 0.60, 0.44), dark_mat, pos + local + Vector3(0, 0.38, 0), rot)
        _add_box(self, Vector3(0.20, 0.66, 0.13), trim_mat, pos + local + Vector3(0, 0.44, 0), rot)
        _add_sphere(self, 0.13, glow_mat, pos + local + Vector3(0, 0.82, 0))
    if void_gate:
        for side in [-1.0, 1.0]:
            var claw := Vector3(side * 1.28, 0, -0.24).rotated(Vector3.UP, deg_to_rad(yaw))
            _add_box(self, Vector3(0.20, 0.13, 1.22), glow_mat, pos + claw + Vector3(0, 0.48, 0), Vector3(0, yaw + side * 18.0, side * 34.0))
        _add_cylinder_segments(self, 1.18, 0.018, 24, _mat("gateway_void_pool", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.22), 0.88, true, true), pos + Vector3(0, 0.055, 0), Vector3(90, 0, 0))
    else:
        for side in [-1.0, 1.0]:
            var rail := Vector3(side * 1.50, 0, 0.02).rotated(Vector3.UP, deg_to_rad(yaw))
            _add_box(self, Vector3(0.12, 0.052, 1.24), trim_mat, pos + rail + Vector3(0, 0.330, 0), rot)
        _add_cylinder_segments(self, 1.06, 0.018, 6, _mat("gateway_hex_pool", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.20), 0.80, true, true), pos + Vector3(0, 0.055, 0), Vector3(0, 30, 0))
    _add_spawn_gateway_motion(pos, yaw, color, void_gate)

func _add_spawn_gateway_motion(pos: Vector3, yaw: float, color: Color, void_gate: bool) -> void:
    var root := Node3D.new()
    root.name = "SpawnGatewayMotion"
    root.position = pos + Vector3(0, 0.020, 0)
    root.rotation_degrees = Vector3(0, yaw, 0)
    root.set_meta("void_gate", void_gate)
    add_child(root)
    spawn_gateway_motion_nodes.append(root)

    var portal := Node3D.new()
    portal.name = "PortalDisc"
    root.add_child(portal)
    var aura := Color(color.r, color.g, color.b, 0.28)
    var hot := color.lightened(0.16)
    var portal_mat := _mat("spawn_gateway_portal_" + color.to_html(false), aura, 1.05, true, true)
    var hot_mat := _mat("spawn_gateway_core_" + color.to_html(false), hot, 1.28, true)
    _add_cylinder_segments(portal, 1.22, 0.016, 32, portal_mat, Vector3(0, 0.72, -0.16), Vector3(90, 0, 0))
    _add_cylinder_segments(portal, 0.78, 0.014, 8, portal_mat, Vector3(0, 0.72, -0.15), Vector3(90, 0, 22.5))
    _add_box(portal, Vector3(1.54, 0.014, 0.052), portal_mat, Vector3(0, 0.72, -0.13), Vector3(0, 0, 0))
    _add_box(portal, Vector3(0.052, 0.014, 1.54), portal_mat, Vector3(0, 0.72, -0.12), Vector3(90, 0, 0))
    var core := _add_sphere(portal, 0.18, hot_mat, Vector3(0, 0.72, -0.04))
    core.name = "Core"

    var ground := Node3D.new()
    ground.name = "GroundRunes"
    root.add_child(ground)
    var rune_mat := _mat("spawn_gateway_ground_" + color.to_html(false), Color(color.r, color.g, color.b, 0.22), 0.82, true, true)
    _add_cylinder_segments(ground, 1.44, 0.012, 6 if not void_gate else 8, rune_mat, Vector3(0, 0.082, 0.08), Vector3(0, 30 if not void_gate else 22.5, 0))
    _add_cylinder_segments(ground, 0.58, 0.010, 24, rune_mat, Vector3(0, 0.104, 0.08))
    var fang_count := 4 if void_gate else 6
    for i in range(fang_count):
        var angle := TAU * float(i) / float(fang_count)
        var local := Vector3(cos(angle) * 1.00, 0.122, sin(angle) * 0.72 + 0.08)
        _add_tapered_cylinder(ground, 0.052, 0.010, 0.46, 6, rune_mat, local, Vector3(70, -rad_to_deg(angle), 0))

func _add_corner_anchor(pos: Vector3, yaw: float, color: Color) -> void:
    var rot := Vector3(0, yaw, 0)
    var stone_mat := _mat("corner_anchor_stone", Color(0.042, 0.038, 0.064), 0.03, true)
    var trim_mat := _mat("corner_anchor_trim", HEXTECH_GOLD, 0.18, true)
    var glow_mat := _mat("corner_anchor_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.42), 0.96, true, true)
    _add_cylinder_segments(self, 1.08, 0.13, 8, stone_mat, pos + Vector3(0, 0.090, 0), Vector3(0, yaw + 22.5, 0))
    _add_cylinder_segments(self, 0.86, 0.030, 8, trim_mat, pos + Vector3(0, 0.185, 0), Vector3(0, yaw + 22.5, 0))
    _add_cylinder_segments(self, 0.54, 0.024, 24, glow_mat, pos + Vector3(0, 0.222, 0))
    for i in range(4):
        var angle := TAU * float(i) / 4.0 + deg_to_rad(yaw)
        var arm_pos := pos + Vector3(cos(angle) * 0.82, 0.250, sin(angle) * 0.82)
        _add_box(self, Vector3(0.56, 0.032, 0.070), glow_mat, arm_pos, Vector3(0, -rad_to_deg(angle), 0))

func _build_hex_floor() -> void:
    var painted_floor := _arena_floor_texture_path() != HEXTECH_FLOOR_TEXTURE_PATH
    var textured_floor := _asset_available(HEXTECH_FLOOR_TEXTURE_PATH)
    var radius := 1.34 if painted_floor else 1.22
    var x_step := radius * 1.50
    var z_step := radius * 1.30
    var cols := 17 if painted_floor else 25
    var rows := 11 if painted_floor else 15
    var start_x := -float(cols - 1) * x_step * 0.5
    var start_z := -float(rows - 1) * z_step * 0.5
    for row in range(rows):
        for col in range(cols):
            var x := start_x + float(col) * x_step + (0.5 * x_step if row % 2 == 1 else 0.0)
            var z := start_z + float(row) * z_step
            if abs(x) > 22.0 or abs(z) > 13.0:
                continue
            var dist := Vector2(x / 22.0, z / 13.0).length()
            var tile_color := Color(0.045, 0.043, 0.075)
            var emission := 0.04 if (row + col) % 5 != 0 else 0.12
            if painted_floor:
                var decorative_node := (row + col) % 5 == 0
                var edge_node := dist > 0.72 and (row + col) % 3 == 0
                if not decorative_node and not edge_node:
                    continue
                tile_color = Color(0.12, 0.16, 0.24, 0.16 if dist < 0.72 else 0.24)
                emission = 0.08 if decorative_node else 0.04
            if not painted_floor and (row + col) % 3 == 0:
                tile_color = Color(0.055, 0.050, 0.092)
            if dist > 0.82:
                tile_color = tile_color.darkened(0.18)
            if textured_floor and not painted_floor:
                tile_color.a = 0.58
            _add_hex_tile(Vector3(x, 0.012, z), radius, tile_color, emission)
    _add_cylinder(self, 2.4, 0.026, _mat("center_hex_glow", Color(0.20, 0.80, 1.0, 0.18), 0.55, true, true), Vector3(0, 0.040, 0), Vector3(0, 30, 0))

func _add_hex_tile(pos: Vector3, radius: float, color: Color, emission: float) -> void:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = 0.035
    mesh.radial_segments = 6
    var instance := _add_mesh(self, mesh, _mat("hex_tile", color, emission, true), pos, Vector3(0, 30, 0))
    instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    if emission > 0.10:
        var inner := CylinderMesh.new()
        inner.top_radius = radius * 0.72
        inner.bottom_radius = radius * 0.72
        inner.height = 0.018
        inner.radial_segments = 6
        var glow_col := Color(0.18, 0.40, 0.86, 0.075)
        var glow := _add_mesh(self, inner, _mat("hex_tile_inner_glow", glow_col, 0.22, true, true), pos + Vector3(0, 0.028, 0), Vector3(0, 30, 0))
        glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _sync_camera(_delta: float) -> void:
    var player := _get_player()
    var target := _to3d(arena.get_center(), 0.0)
    if player != null and bool(player.visible):
        target = _to3d(player.global_position, 0.0)
    camera_target = target
    camera.global_position = camera_target + Vector3(0.0, CAMERA_HEIGHT, 0.0)
    camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)

func _sync_player() -> void:
    var player := _get_player()
    if player == null or not bool(player.visible):
        if player_model != null:
            player_model.visible = false
        return
    var champion := str(player.get("character_id"))
    if player_model == null or str(player_model.get_meta("champion", "")) != champion:
        if player_model != null:
            player_model.queue_free()
        player_model = _create_player_model(champion)
        add_child(player_model)
    player_model.visible = true
    player_model.global_position = _to3d(player.global_position, 0.0)
    var facing: Vector2 = player.get("facing")
    if facing.length() > 0.05:
        player_model.rotation.y = atan2(facing.x, facing.y)
    player_model.position.y = sin(Time.get_ticks_msec() / 1000.0 * 7.0) * PLAYER_BOB_AMOUNT
    _sync_champion_live_aura(player_model)
    _sync_champion_fan_signature(player_model)
    _sync_champion_fan_readable_silhouette_rig(player_model)
    _sync_champion_signature_weapon_rig(player_model)
    _sync_champion_premium_body_rig(player_model)
    _sync_champion_kit_silhouette(player_model)
    _sync_champion_combat_stance_rig(player_model, player)
    _sync_champion_archetype_silhouette_rig(player_model, player)
    _sync_champion_ability_emblems(player_model)
    _sync_champion_mechanic_meter(player_model)
    _sync_champion_combat_loop_readout(player_model, player)
    _sync_champion_human_focus_plate(player_model, player)
    _sync_champion_attack_burst(player_model, player)
    _sync_champion_signature_cast_rig(player_model, player)
    _sync_champion_upgrade_routes(player_model, player)
    _sync_role_route_rings(player_model, player)
    _sync_player_status_rings(player_model, player)

func _sync_enemies() -> void:
    var alive := {}
    var shadow_budget := ENEMY_SHADOW_LIMIT
    var player := _get_player()
    var enemy_nodes := get_tree().get_nodes_in_group("survivor_enemies")
    var dense_enemy_count := enemy_nodes.size()
    var enemy_lod_rebuilds_left := ENEMY_LOD_REBUILDS_PER_FRAME
    for enemy in enemy_nodes:
        if not is_instance_valid(enemy):
            continue
        var id := enemy.get_instance_id()
        alive[id] = true
        var kind := str(enemy.get("kind"))
        var boss := bool(enemy.get("boss"))
        var elite := bool(enemy.get("elite"))
        var elite_trait := str(enemy.get("elite_trait"))
        var needs_rebuild := not enemy_models.has(id)
        var structural_rebuild := needs_rebuild
        var lod_rebuild := false
        var current_lite_enemy_model := false
        if enemy_models.has(id):
            current_lite_enemy_model = bool(enemy_models[id].get_meta("lite_enemy_model", false))
        var lite_enemy_model := current_lite_enemy_model
        if not boss:
            if dense_enemy_count > ENEMY_DETAIL_LIMIT:
                lite_enemy_model = true
            elif dense_enemy_count <= ENEMY_DETAIL_RECOVER_LIMIT:
                lite_enemy_model = false
        else:
            lite_enemy_model = false
        if enemy_models.has(id):
            structural_rebuild = str(enemy_models[id].get_meta("kind", "")) != kind or bool(enemy_models[id].get_meta("elite", false)) != elite
            if str(enemy_models[id].get_meta("elite_trait", "")) != elite_trait:
                structural_rebuild = true
            lod_rebuild = bool(enemy_models[id].get_meta("lite_enemy_model", false)) != lite_enemy_model
            needs_rebuild = structural_rebuild or lod_rebuild
            if lod_rebuild and not structural_rebuild:
                if enemy_lod_rebuilds_left <= 0:
                    needs_rebuild = false
                    lite_enemy_model = current_lite_enemy_model
                else:
                    enemy_lod_rebuilds_left -= 1
        if needs_rebuild:
            if enemy_models.has(id):
                enemy_models[id].queue_free()
            enemy_models[id] = _create_enemy_model(kind, boss, elite, enemy.get("body_color"), float(enemy.get("hit_radius")), lite_enemy_model, elite_trait)
            enemy_models[id].set_meta("lite_enemy_model", lite_enemy_model)
            add_child(enemy_models[id])
        var model: Node3D = enemy_models[id]
        model.global_position = _to3d(enemy.global_position, 0.0)
        var visual_radius := float(model.get_meta("visual_radius", 0.5))
        if player != null:
            var to_player: Vector2 = player.global_position - enemy.global_position
            if to_player.length() > 1.0:
                model.rotation.y = lerp_angle(model.rotation.y, atan2(to_player.x, to_player.y), 0.10 if boss else 0.18)
        model.rotation.y += ENTITY_SPIN_SPEED
        var scale_from_2d: Vector2 = enemy.scale
        var base_scale := maxf(scale_from_2d.x, scale_from_2d.y)
        if float(enemy.get("hurt_flash")) > 0.0:
            base_scale *= 1.065
        model.scale = Vector3.ONE * base_scale
        if boss:
            var enrage_aura := model.get_node_or_null("EnrageAura") as Node3D
            if enrage_aura != null:
                var max_hp := maxf(1.0, float(enemy.get("max_health")))
                enrage_aura.visible = float(enemy.get("health")) <= max_hp * 0.45
                enrage_aura.rotation.y += 0.014
            _sync_boss_phase_state_rig(model, enemy, kind, id)
        var threat_halo := model.get_node_or_null("ThreatHalo") as Node3D
        if threat_halo != null:
            threat_halo.rotation.y += 0.018 if boss else 0.012
            var threat_pulse := 1.0 + sin(Time.get_ticks_msec() / 1000.0 * (2.6 if boss else 2.0) + float(id % 23)) * (0.040 if boss else 0.026)
            threat_halo.scale = Vector3.ONE * threat_pulse
        var threat_silhouette := model.get_node_or_null("VoidThreatSilhouetteRig") as Node3D
        if threat_silhouette != null:
            var silhouette_time := Time.get_ticks_msec() / 1000.0
            threat_silhouette.rotation.y += 0.010 if boss else -0.008
            threat_silhouette.scale = Vector3.ONE * (1.0 + sin(silhouette_time * (1.8 if boss else 1.4) + float(id % 19)) * (0.035 if boss else 0.024))
            var attack_tell := threat_silhouette.get_node_or_null("VoidThreatAttackTell") as Node3D
            if attack_tell != null:
                attack_tell.position.y = sin(silhouette_time * (3.6 if boss else 2.8) + float(id % 11)) * visual_radius * 0.020
        var crest := model.get_node_or_null("EliteBossCrest") as Node3D
        if crest != null:
            var crest_time := Time.get_ticks_msec() / 1000.0
            crest.rotation.y += 0.026 if boss else -0.018
            var crest_pulse := 1.0 + sin(crest_time * (2.2 if boss else 1.7) + float(id % 17)) * (0.052 if boss else 0.036)
            crest.scale = Vector3.ONE * crest_pulse
        var priority_emblem := model.get_node_or_null("VoidPriorityEmblem") as Node3D
        if priority_emblem != null:
            var emblem_time := Time.get_ticks_msec() / 1000.0
            priority_emblem.rotation.y += 0.020 if boss else -0.014
            var emblem_pulse := 1.0 + sin(emblem_time * (2.8 if boss else 2.2) + float(id % 29)) * (0.045 if boss else 0.032)
            priority_emblem.scale = Vector3.ONE * emblem_pulse
        _sync_priority_combat_backplate(model, enemy, kind, boss, elite_trait, id, visual_radius)
        var trait_marker := model.get_node_or_null("EliteTraitMarker") as Node3D
        if trait_marker != null:
            var trait_time := Time.get_ticks_msec() / 1000.0
            trait_marker.rotation.y += 0.030
            trait_marker.scale = Vector3.ONE * (1.0 + sin(trait_time * 2.8 + float(id % 13)) * 0.040)
        var trait_telegraph := model.get_node_or_null("EliteTraitTelegraphRig") as Node3D
        if trait_telegraph != null:
            _sync_elite_trait_telegraph(trait_telegraph, enemy, kind, elite_trait, id)
        _sync_void_creature_premium_body_rig(model, kind, boss, elite, id, visual_radius)
        var readability_plate := model.get_node_or_null("EnemyReadabilityPlate") as Node3D
        if readability_plate != null:
            _sync_enemy_readability_plate(readability_plate, elite, id)
        var ground_silhouette := model.get_node_or_null("EnemyGroundSilhouettePlate") as Node3D
        if ground_silhouette != null:
            var ground_time := Time.get_ticks_msec() / 1000.0
            var urgency_scale := 0.030 if boss or elite else 0.018
            ground_silhouette.rotation.y += 0.006 if boss else 0.003
            ground_silhouette.scale = Vector3.ONE * (1.0 + sin(ground_time * (1.55 if boss else 1.20) + float(id % 23)) * urgency_scale)
            var detail_name := str(ground_silhouette.get_meta("detail_node", ""))
            var detail := ground_silhouette.get_node_or_null(detail_name) as Node3D
            if detail != null:
                detail.position.y = float(detail.get_meta("base_y", detail.position.y)) + sin(ground_time * (2.4 if boss or elite else 1.8) + float(id % 17)) * visual_radius * 0.010
        var footprint_scale := model.get_node_or_null("EnemyFootprintScaleRig") as Node3D
        if footprint_scale != null:
            var footprint_time := Time.get_ticks_msec() / 1000.0
            var footprint_class := str(footprint_scale.get_meta("footprint_class", "normal"))
            footprint_scale.set_meta("combat_visual_channel", "enemy_body_readability")
            var footprint_pulse := 1.0 + sin(footprint_time * (1.9 if boss else 1.45 if elite else 1.12) + float(id % 41)) * (0.026 if boss else 0.018 if elite else 0.010)
            footprint_scale.scale = Vector3.ONE * footprint_pulse
            footprint_scale.rotation.y += 0.004 if footprint_class == "boss" else 0.003 if footprint_class == "elite" else 0.002
            var footprint_detail := footprint_scale.get_node_or_null(str(footprint_scale.get_meta("detail_node", ""))) as Node3D
            if footprint_detail != null:
                footprint_detail.position.y = float(footprint_detail.get_meta("base_y", footprint_detail.position.y)) + sin(footprint_time * (2.2 if boss or elite else 1.5) + float(id % 17)) * visual_radius * 0.006
        _sync_enemy_threat_occlusion_plate(model, enemy, kind, boss, elite, elite_trait, id, visual_radius)
        _sync_enemy_threat_tier_marker(model, enemy, boss, elite, id, visual_radius)
        var role_banner := model.get_node_or_null("EnemySpeciesRoleBanner") as Node3D
        if role_banner != null:
            var banner_time := Time.get_ticks_msec() / 1000.0
            role_banner.rotation.y += 0.018 if boss or elite else 0.010
            role_banner.scale = Vector3.ONE * (1.0 + sin(banner_time * (2.4 if boss or elite else 1.8) + float(id % 17)) * (0.040 if boss or elite else 0.026))
        var tactical_plaque := model.get_node_or_null("EnemyTacticalReadabilityPlaque") as Node3D
        if tactical_plaque != null:
            var plaque_time := Time.get_ticks_msec() / 1000.0
            tactical_plaque.rotation.y += 0.007 if boss else 0.005 if elite else 0.003
            tactical_plaque.scale = Vector3.ONE * (1.0 + sin(plaque_time * (1.7 if boss or elite else 1.2) + float(id % 31)) * (0.024 if boss or elite else 0.014))
            var plaque_detail := tactical_plaque.get_node_or_null(str(tactical_plaque.get_meta("detail_node", ""))) as Node3D
            if plaque_detail != null:
                plaque_detail.position.y = float(plaque_detail.get_meta("base_y", plaque_detail.position.y)) + sin(plaque_time * (2.8 if boss or elite else 2.0) + float(id % 13)) * visual_radius * 0.006
        _sync_enemy_combat_intent_profile(model, enemy, kind, boss, elite, id, visual_radius)
        _sync_enemy_damage_state_rig(model, enemy, kind, boss, elite, id, visual_radius)
        var weakpoint_core := model.get_node_or_null("EnemyWeakpointCore") as Node3D
        if weakpoint_core != null:
            var weakpoint_time := Time.get_ticks_msec() / 1000.0
            var weakpoint_pulse := 1.0 + sin(weakpoint_time * (3.4 if boss or elite else 2.6) + float(id % 31)) * (0.052 if boss or elite else 0.034)
            weakpoint_core.scale = Vector3.ONE * weakpoint_pulse
            weakpoint_core.position.y = float(weakpoint_core.get_meta("base_y", weakpoint_core.position.y)) + sin(weakpoint_time * 2.1 + float(id % 11)) * visual_radius * 0.030
            var weakpoint_lens := weakpoint_core.get_node_or_null("EnemyWeakpointLens") as Node3D
            if weakpoint_lens != null:
                weakpoint_lens.rotation.y += 0.018 if boss else -0.012
        var health_fill := model.get_node_or_null("HealthBar/Fill") as MeshInstance3D
        if health_fill != null:
            var health_max := maxf(1.0, float(enemy.get("max_health")))
            var health_ratio := clampf(float(enemy.get("health")) / health_max, 0.0, 1.0)
            var health_width := float(health_fill.get_meta("bar_width", 1.0))
            health_fill.scale.x = health_ratio
            health_fill.position.x = -health_width * (1.0 - health_ratio) * 0.5
        var windup_aura := model.get_node_or_null("WindupAura") as Node3D
        if windup_aura != null:
            var windup_window := 0.68 if boss else 0.52
            var windup_t := 1.0 - clampf(float(enemy.get("attack_timer")) / windup_window, 0.0, 1.0)
            windup_aura.visible = windup_t > 0.0 and float(enemy.get("health")) > 0.0
            if windup_aura.visible:
                windup_aura.scale = Vector3.ONE * lerpf(0.84, 1.18, windup_t)
                windup_aura.rotation.y += 0.030 if boss else 0.022
        var charge_lane := model.get_node_or_null("ChargeLane") as Node3D
        if charge_lane != null:
            var dash_time := float(enemy.get("dash_timer"))
            var charge_visible := dash_time > 0.0 and float(enemy.get("health")) > 0.0
            if elite_trait == "frenzy":
                charge_visible = dash_time > 0.0 and float(enemy.get("health")) > 0.0
            elif kind == "boss_reksai":
                charge_visible = dash_time > 2.42 and float(enemy.get("health")) > 0.0
            charge_lane.visible = charge_visible
            if charge_lane.visible:
                var charge_t := clampf(dash_time / (3.0 if kind == "boss_reksai" else 0.70), 0.0, 1.0)
                charge_lane.scale = Vector3(lerpf(0.86, 1.20, charge_t), 1.0, lerpf(0.92, 1.36, charge_t))
                charge_lane.position.y = 0.014 + sin(Time.get_ticks_msec() / 1000.0 * 8.0) * 0.012
        var summon_aura := model.get_node_or_null("SummonAura") as Node3D
        if summon_aura != null:
            var summon_window := 1.35 if not boss else 1.85
            var summon_t := 1.0 - clampf(float(enemy.get("summon_timer")) / summon_window, 0.0, 1.0)
            summon_aura.visible = summon_t > 0.0 and float(enemy.get("health")) > 0.0
            if summon_aura.visible:
                summon_aura.scale = Vector3.ONE * lerpf(0.72, 1.24, summon_t)
                summon_aura.rotation.y += -0.024 if boss else -0.018
        _sync_enemy_status_marks(model, enemy, visual_radius, boss)
        var should_cast_shadows := boss or elite or shadow_budget > 0
        if not boss and not elite:
            shadow_budget -= 1
        if bool(model.get_meta("casts_shadows", true)) != should_cast_shadows:
            _set_model_shadow_casting(model, should_cast_shadows)
            model.set_meta("casts_shadows", should_cast_shadows)
    _remove_missing(enemy_models, alive)

func _sync_projectiles() -> void:
    var alive := {}
    var projectile_nodes := get_tree().get_nodes_in_group("survivor_projectiles")
    var enemy_projectile_count := 0
    for projectile in projectile_nodes:
        if not is_instance_valid(projectile):
            continue
        if not bool(projectile.get("from_player")):
            enemy_projectile_count += 1
    var player_projectile_seen := 0
    var projectile_lod_rebuilds_left := PROJECTILE_LOD_REBUILDS_PER_FRAME
    for projectile in projectile_nodes:
        if not is_instance_valid(projectile):
            continue
        var id := projectile.get_instance_id()
        alive[id] = true
        var from_player := bool(projectile.get("from_player"))
        if from_player:
            player_projectile_seen += 1
        var projectile_label := str(projectile.get("label"))
        var lite_enemy_projectile := (not from_player) and enemy_projectile_count > ENEMY_PROJECTILE_DETAIL_LIMIT
        var lite_player_projectile := from_player and player_projectile_seen > PLAYER_PROJECTILE_DETAIL_LIMIT
        if projectile_models.has(id) and lite_enemy_projectile and not bool(projectile_models[id].get_meta("lite_enemy_projectile", false)):
            if projectile_lod_rebuilds_left > 0:
                projectile_models[id].queue_free()
                projectile_models.erase(id)
                projectile_lod_rebuilds_left -= 1
            else:
                lite_enemy_projectile = false
        if projectile_models.has(id) and lite_player_projectile and not bool(projectile_models[id].get_meta("lite_player_projectile", false)):
            if projectile_lod_rebuilds_left > 0:
                projectile_models[id].queue_free()
                projectile_models.erase(id)
                projectile_lod_rebuilds_left -= 1
            else:
                lite_player_projectile = false
        if not projectile_models.has(id):
            projectile_models[id] = _create_projectile_model(projectile, lite_enemy_projectile, lite_player_projectile)
            projectile_models[id].set_meta("lite_enemy_projectile", lite_enemy_projectile)
            projectile_models[id].set_meta("lite_player_projectile", lite_player_projectile)
            add_child(projectile_models[id])
        var model: Node3D = projectile_models[id]
        model.set_meta("combat_visual_channel", _projectile_visual_channel(from_player, projectile_label, lite_enemy_projectile, lite_player_projectile))
        model.set_meta("readability_priority", _projectile_readability_priority(from_player, projectile_label))
        model.global_position = _to3d(projectile.global_position, 0.44 if from_player else 0.66)
        var vel: Vector2 = projectile.get("velocity")
        if vel.length() > 1.0:
            model.rotation.y = atan2(vel.x, vel.y)
        if from_player:
            model.scale = Vector3.ONE
            var signature_rig := model.get_node_or_null("PlayerProjectileSignatureRig") as Node3D
            if signature_rig != null:
                var sig_time := Time.get_ticks_msec() / 1000.0
                var sig_label := str(signature_rig.get_meta("label", ""))
                signature_rig.rotation.y += _player_projectile_signature_speed(sig_label)
                signature_rig.scale = Vector3.ONE * (1.0 + sin(sig_time * _player_projectile_signature_pulse(sig_label) + float(id % 29)) * 0.045)
            var projectile_decal := model.get_node_or_null("ProjectileVfxDecal") as Node3D
            if projectile_decal != null:
                var decal_time := Time.get_ticks_msec() / 1000.0
                var decal_pulse := 1.0 + sin(decal_time * 5.4 + float(id % 23)) * 0.040
                projectile_decal.scale = Vector3(1.0 + (decal_pulse - 1.0) * 0.45, 1.0, decal_pulse)
            _sync_player_projectile_path_signature(model, id)
        else:
            var time := Time.get_ticks_msec() / 1000.0
            var readability_priority := _enemy_projectile_readability_priority(projectile_label)
            var danger_pulse := 1.0 + readability_priority * 0.035 + sin(time * (3.4 + readability_priority * 0.9) + float(id % 37)) * (0.065 + readability_priority * 0.032)
            model.scale = Vector3.ONE * danger_pulse
            var danger_rig := model.get_node_or_null("EnemyProjectileDangerRig") as Node3D
            if danger_rig != null:
                danger_rig.set_meta("combat_visual_channel", "enemy_hazard")
                danger_rig.set_meta("readability_priority", readability_priority)
                danger_rig.rotation.y += (0.046 if lite_enemy_projectile else 0.068) + readability_priority * 0.010
            var lane := model.get_node_or_null("EnemyProjectileLane") as Node3D
            if lane != null:
                lane.set_meta("combat_visual_channel", "enemy_hazard")
                lane.set_meta("readability_priority", readability_priority)
                var lane_pulse := 1.0 + sin(time * (4.4 + readability_priority * 0.8) + float(id % 41)) * (0.035 if lite_enemy_projectile else 0.055 + readability_priority * 0.016)
                lane.scale = Vector3(1.0 + lane_pulse * (0.040 + readability_priority * 0.012), 1.0, lane_pulse)
                lane.position.y = -0.675 + sin(time * (6.0 + readability_priority) + float(id % 17)) * 0.012
                var trajectory_marks := lane.get_node_or_null("EnemyProjectileTrajectoryMarks") as Node3D
                if trajectory_marks != null:
                    trajectory_marks.set_meta("combat_visual_channel", "enemy_hazard")
                    trajectory_marks.position.z = sin(time * (5.2 + readability_priority) + float(id % 11)) * (0.018 if lite_enemy_projectile else 0.030 + readability_priority * 0.010)
                    var heading_arrow := trajectory_marks.get_node_or_null("EnemyProjectileHeadingArrow") as Node3D
                    if heading_arrow != null:
                        heading_arrow.set_meta("combat_visual_channel", "enemy_hazard")
                        var arrow_pulse := 1.0 + sin(time * (7.0 + readability_priority) + float(id % 23)) * (0.045 if lite_enemy_projectile else 0.070 + readability_priority * 0.018)
                        heading_arrow.scale = Vector3(1.0 + (arrow_pulse - 1.0) * 0.38, 1.0, arrow_pulse)
            var threat_badge := model.get_node_or_null("EnemyProjectileThreatBadge") as Node3D
            if threat_badge != null:
                var tier := str(threat_badge.get_meta("tier", "special"))
                threat_badge.set_meta("combat_visual_channel", "enemy_hazard")
                threat_badge.set_meta("readability_priority", readability_priority)
                var badge_pulse := 1.0 + sin(time * (5.2 if tier == "boss" else 4.2) + float(id % 31)) * (0.060 if tier == "boss" else 0.040)
                threat_badge.scale = Vector3.ONE * badge_pulse
                threat_badge.rotation.y += -0.060 if tier == "boss" else -0.034
            var intent_profile := model.get_node_or_null("EnemyProjectileIntentProfile") as Node3D
            if intent_profile != null:
                var intent_type := str(intent_profile.get_meta("intent_type", "minor_bolt"))
                intent_profile.set_meta("combat_visual_channel", "enemy_hazard")
                intent_profile.set_meta("readability_priority", readability_priority)
                var intent_pulse := 1.0 + sin(time * _enemy_projectile_intent_pulse(intent_type) + float(id % 53)) * (0.042 + readability_priority * 0.014)
                intent_profile.scale = Vector3.ONE * intent_pulse
                intent_profile.rotation.y += _enemy_projectile_intent_spin(intent_type)
                var intent_frame := intent_profile.get_node_or_null("EnemyProjectileIntentFrame") as Node3D
                if intent_frame != null:
                    intent_frame.set_meta("combat_visual_channel", "enemy_hazard")
                    intent_frame.scale = Vector3.ONE * (1.0 + (intent_pulse - 1.0) * 0.62)
                var intent_core := intent_profile.get_node_or_null("EnemyProjectileIntentCore") as Node3D
                if intent_core != null:
                    intent_core.set_meta("combat_visual_channel", "enemy_hazard")
                    intent_core.scale = Vector3.ONE * (1.0 + (intent_pulse - 1.0) * 0.88)
                var intent_detail := intent_profile.get_node_or_null(str(intent_profile.get_meta("detail_node", ""))) as Node3D
                if intent_detail != null:
                    intent_detail.set_meta("combat_visual_channel", "enemy_hazard")
                    intent_detail.rotation.y -= _enemy_projectile_intent_spin(intent_type) * 0.72
            var enemy_decal := model.get_node_or_null("EnemyProjectileVfxDecal") as Node3D
            if enemy_decal != null:
                enemy_decal.set_meta("combat_visual_channel", "enemy_hazard")
                var enemy_decal_pulse := 1.0 + sin(time * (5.8 + readability_priority * 0.8) + float(id % 43)) * (0.050 + readability_priority * 0.018)
                enemy_decal.scale = Vector3(1.0 + (enemy_decal_pulse - 1.0) * 0.55, 1.0, enemy_decal_pulse)
            var readability_shell := model.get_node_or_null("EnemyProjectileReadabilityShell") as Node3D
            if readability_shell != null:
                readability_shell.set_meta("combat_visual_channel", "enemy_hazard")
                readability_shell.set_meta("readability_priority", readability_priority)
                var shell_pulse := 1.0 + sin(time * (5.0 if lite_enemy_projectile else 6.4 + readability_priority) + float(id % 47)) * (0.050 if lite_enemy_projectile else 0.070 + readability_priority * 0.022)
                readability_shell.scale = Vector3.ONE * shell_pulse
                readability_shell.rotation.y += 0.024 if lite_enemy_projectile else 0.038
                var danger_backplate := readability_shell.get_node_or_null("EnemyProjectileDangerBackplate") as Node3D
                if danger_backplate != null:
                    danger_backplate.set_meta("combat_visual_channel", "enemy_hazard")
                    danger_backplate.rotation.y -= 0.028 + readability_priority * 0.010
                    danger_backplate.scale = Vector3(1.0 + (shell_pulse - 1.0) * 0.42, 1.0, 1.0 + (shell_pulse - 1.0) * 0.42)
                var danger_needle := readability_shell.get_node_or_null("EnemyProjectileDangerNeedle") as Node3D
                if danger_needle != null:
                    danger_needle.set_meta("combat_visual_channel", "enemy_hazard")
                    danger_needle.scale = Vector3(1.0 + readability_priority * 0.10, 1.0, 1.0 + (shell_pulse - 1.0) * 0.82)
                var hazard_chevron := readability_shell.get_node_or_null("EnemyProjectileHazardChevron") as Node3D
                if hazard_chevron != null:
                    hazard_chevron.set_meta("combat_visual_channel", "enemy_hazard")
                    hazard_chevron.scale = Vector3(1.0 + (shell_pulse - 1.0) * 0.72, 1.0, 1.0 + (shell_pulse - 1.0) * 0.36)
                var separation_ring := readability_shell.get_node_or_null("EnemyProjectilePickupSeparationRing") as Node3D
                if separation_ring != null:
                    separation_ring.set_meta("combat_visual_channel", "enemy_hazard")
                    separation_ring.rotation.y -= 0.052 if lite_enemy_projectile else 0.074
                var silhouette_guard := readability_shell.get_node_or_null("EnemyProjectileSilhouetteGuard") as Node3D
                if silhouette_guard != null:
                    silhouette_guard.set_meta("combat_visual_channel", "enemy_hazard")
                    silhouette_guard.set_meta("readability_priority", readability_priority)
                    silhouette_guard.rotation.y -= 0.018 if lite_enemy_projectile else 0.026
                    silhouette_guard.scale = Vector3(1.0 + (shell_pulse - 1.0) * 0.26, 1.0, 1.0 + (shell_pulse - 1.0) * 0.34)
                    var directional_cut := silhouette_guard.get_node_or_null("EnemyProjectileSilhouetteDirectionalCut") as Node3D
                    if directional_cut != null:
                        directional_cut.scale = Vector3(1.0 + readability_priority * 0.08, 1.0, 1.0 + (shell_pulse - 1.0) * 0.64)
                var collision_marker := readability_shell.get_node_or_null("EnemyProjectileThreatOutline") as Node3D
                if collision_marker != null:
                    collision_marker.set_meta("combat_visual_channel", "enemy_hazard")
                    collision_marker.set_meta("readability_priority", readability_priority)
                    collision_marker.set_meta("collision_radius_marker", true)
                    var collision_pulse := 1.0 + sin(time * (4.8 + readability_priority * 0.8) + float(id % 61)) * (0.018 if lite_enemy_projectile else 0.030 + readability_priority * 0.008)
                    collision_marker.scale = Vector3.ONE * collision_pulse
                    collision_marker.rotation.y -= 0.030 if lite_enemy_projectile else 0.046
                var hitbox_lock := readability_shell.get_node_or_null("EnemyProjectileHitboxLock") as Node3D
                if hitbox_lock != null:
                    hitbox_lock.set_meta("combat_visual_channel", "enemy_hazard")
                    hitbox_lock.set_meta("readability_priority", readability_priority)
                    hitbox_lock.set_meta("collision_radius_marker", true)
                    var tier := str(hitbox_lock.get_meta("threat_tier", ""))
                    var tier_weight := 1.0 if tier == "boss" else 0.72 if tier == "special" else 0.48 if tier == "hazard" else 0.32
                    var lock_pulse := 1.0 + sin(time * (3.6 + tier_weight) + float(id % 71)) * (0.012 if lite_enemy_projectile else 0.020 + readability_priority * 0.006)
                    hitbox_lock.scale = Vector3(1.0 + (lock_pulse - 1.0) * 0.44, 1.0, lock_pulse)
                    hitbox_lock.rotation.y += (0.018 if lite_enemy_projectile else 0.026) + tier_weight * 0.006
                    var lock_ring := hitbox_lock.get_node_or_null("EnemyProjectileHitboxLockRing") as Node3D
                    if lock_ring != null:
                        lock_ring.set_meta("combat_visual_channel", "enemy_hazard")
                        lock_ring.set_meta("collision_radius_marker", true)
                        lock_ring.rotation.y -= 0.018 + tier_weight * 0.012
                    var lock_tab := hitbox_lock.get_node_or_null("EnemyProjectileHitboxLockDirectionTab") as Node3D
                    if lock_tab != null:
                        lock_tab.set_meta("combat_visual_channel", "enemy_hazard")
                        lock_tab.set_meta("collision_radius_marker", true)
                        lock_tab.scale = Vector3(1.0 + readability_priority * 0.12, 1.0, 1.0 + (lock_pulse - 1.0) * 0.72)
                var motion_contrast := readability_shell.get_node_or_null("EnemyProjectileMotionContrastRig") as Node3D
                if motion_contrast != null:
                    motion_contrast.set_meta("combat_visual_channel", "enemy_hazard")
                    motion_contrast.set_meta("readability_priority", readability_priority)
                    motion_contrast.set_meta("motion_contrast_layer", true)
                    var motion_pulse := 1.0 + sin(time * (4.2 + readability_priority * 0.7) + float(id % 67)) * (0.012 if lite_enemy_projectile else 0.022 + readability_priority * 0.006)
                    motion_contrast.scale = Vector3(1.0 + (motion_pulse - 1.0) * 0.32, 1.0, motion_pulse)
                    var tail_separator := motion_contrast.get_node_or_null("EnemyProjectileMotionTailSeparator") as Node3D
                    if tail_separator != null:
                        tail_separator.scale = Vector3(1.0, 1.0, 1.0 + readability_priority * (0.10 if lite_enemy_projectile else 0.16))
                var threat_shape := readability_shell.get_node_or_null("EnemyProjectileThreatShapeCode") as Node3D
                if threat_shape != null:
                    threat_shape.set_meta("combat_visual_channel", "enemy_hazard")
                    threat_shape.set_meta("readability_priority", readability_priority)
                    var shape_pulse := 1.0 + sin(time * (4.6 + readability_priority * 0.6) + float(id % 59)) * (0.030 if lite_enemy_projectile else 0.046 + readability_priority * 0.012)
                    threat_shape.scale = Vector3.ONE * shape_pulse
                    threat_shape.rotation.y += _enemy_projectile_threat_shape_spin(str(threat_shape.get_meta("shape_type", "minor_bolt")), lite_enemy_projectile)
                    var threat_detail := threat_shape.get_node_or_null(str(threat_shape.get_meta("detail_node", ""))) as Node3D
                    if threat_detail != null:
                        threat_detail.set_meta("combat_visual_channel", "enemy_hazard")
                        threat_detail.position.y = -0.600 + sin(time * (5.0 + readability_priority) + float(id % 23)) * (0.006 if lite_enemy_projectile else 0.010)
        model.rotation.z += PROJECTILE_SPIN_SPEED
    _remove_missing(projectile_models, alive)

func _sync_pickups() -> void:
    var alive := {}
    var pickup_nodes := get_tree().get_nodes_in_group("survivor_pickups")
    var dense_pickup_count := pickup_nodes.size()
    for pickup in pickup_nodes:
        if not is_instance_valid(pickup):
            continue
        var id := pickup.get_instance_id()
        alive[id] = true
        var pickup_kind := str(pickup.get("kind"))
        var pickup_amount := int(pickup.get("amount"))
        var lite_pickup := _should_use_lite_pickup(pickup_kind, pickup_amount, dense_pickup_count)
        var needs_rebuild := not pickup_models.has(id)
        if pickup_models.has(id):
            needs_rebuild = str(pickup_models[id].get_meta("kind", "")) != pickup_kind
            needs_rebuild = needs_rebuild or int(pickup_models[id].get_meta("amount", -1)) != pickup_amount
            needs_rebuild = needs_rebuild or bool(pickup_models[id].get_meta("lite_pickup", false)) != lite_pickup
        if needs_rebuild:
            if pickup_models.has(id):
                pickup_models[id].queue_free()
            pickup_models[id] = _create_pickup_model(pickup_kind, pickup.get("pickup_color"), pickup_amount, lite_pickup)
            add_child(pickup_models[id])
        var model: Node3D = pickup_models[id]
        var time := Time.get_ticks_msec() / 1000.0
        var pickup_channel := _pickup_visual_channel(pickup_kind, pickup_amount, lite_pickup)
        model.set_meta("combat_visual_channel", pickup_channel)
        var pickup_bob := _pickup_bob_amount(pickup_kind, pickup_amount, lite_pickup)
        var pickup_base_height := 0.18 if lite_pickup else (0.25 if not _is_high_value_pickup(pickup_kind, pickup_amount) else 0.30)
        model.global_position = _to3d(pickup.global_position, pickup_base_height + sin(time * (4.2 if lite_pickup else 5.0) + float(id % 100)) * pickup_bob)
        var lite_scale := 0.86 if lite_pickup else 1.0
        model.scale = Vector3.ONE * PICKUP_MODEL_SCALE * _pickup_visual_scale(pickup_kind, pickup_amount) * lite_scale
        model.rotation.y += PICKUP_SPIN_SPEED
        var hover_glyph := model.get_node_or_null("PickupHoverGlyph") as Node3D
        if hover_glyph != null:
            hover_glyph.rotation.y = time * (0.92 if pickup_kind == "gold" else -0.72) + float(id % 31) * 0.04
            hover_glyph.position.y = 0.62 + sin(time * 3.4 + float(id % 19)) * 0.045
        var value_halo := model.get_node_or_null("PickupValueHalo") as Node3D
        if value_halo != null:
            var halo_speed := 1.12
            var halo_pulse_speed := 2.4
            match pickup_kind:
                "gold":
                    halo_speed = 1.34
                    halo_pulse_speed = 2.8
                "heal":
                    halo_speed = -1.02
                    halo_pulse_speed = 3.0
                "shield":
                    halo_speed = 0.82
                    halo_pulse_speed = 2.1
                _:
                    halo_speed = -0.76
                    halo_pulse_speed = 2.5
            value_halo.rotation.y = time * halo_speed + float(id % 23) * 0.07
            value_halo.scale = Vector3.ONE * (1.0 + sin(time * halo_pulse_speed + float(id % 31)) * 0.045)
        var reward_beacon := model.get_node_or_null("PickupRewardBeacon") as Node3D
        if reward_beacon != null:
            reward_beacon.rotation.y = time * (0.72 if pickup_kind == "gold" else -0.58) + float(id % 29) * 0.05
            reward_beacon.scale = Vector3.ONE * (1.0 + sin(time * 2.8 + float(id % 23)) * 0.050)
        var treasure_crest := model.get_node_or_null("PickupTreasureCrest") as Node3D
        if treasure_crest != null:
            treasure_crest.rotation.y = time * (1.04 if pickup_kind == "gold" else -0.86) + float(id % 37) * 0.06
            treasure_crest.position.y = 0.72 + sin(time * 3.0 + float(id % 17)) * 0.045
            var treasure_facet := treasure_crest.get_node_or_null("PickupTreasureFacet") as Node3D
            if treasure_facet != null:
                treasure_facet.scale = Vector3.ONE * (1.0 + sin(time * 4.2 + float(id % 13)) * 0.060)
        var facet_rig := model.get_node_or_null("PickupFacetSilhouetteRig") as Node3D
        if facet_rig != null:
            facet_rig.set_meta("combat_visual_channel", pickup_channel)
            facet_rig.rotation.y = time * (0.54 if pickup_kind == "gold" else -0.46) + float(id % 43) * 0.035
            var facet_pulse := 1.0 + sin(time * (3.1 if pickup_kind == "gold" else 3.6) + float(id % 31)) * (0.022 if _is_high_value_pickup(pickup_kind, pickup_amount) else 0.014)
            facet_rig.scale = Vector3(1.0 + (facet_pulse - 1.0) * 0.38, 1.0, facet_pulse)
            var primary := facet_rig.get_node_or_null("PickupFacetPrimarySilhouette") as Node3D
            if primary != null:
                primary.rotation.y += 0.018 if pickup_kind == "gold" else -0.014
            var inlay := facet_rig.get_node_or_null("PickupFacetRoleInlay") as Node3D
            if inlay != null:
                inlay.scale = Vector3.ONE * (1.0 + (facet_pulse - 1.0) * 0.66)
    _remove_missing(pickup_models, alive)

func _sync_zones() -> void:
    var alive := {}
    var zone_nodes := get_tree().get_nodes_in_group("survivor_zones")
    var dense_zone_count := zone_nodes.size()
    for zone in zone_nodes:
        if not is_instance_valid(zone):
            continue
        var id := zone.get_instance_id()
        alive[id] = true
        var kind := str(zone.get("kind"))
        var from_player := true
        var from_player_value = zone.get("from_player")
        if from_player_value != null:
            from_player = bool(from_player_value)
        var current_lite_zone_model := false
        if zone_models.has(id):
            current_lite_zone_model = bool(zone_models[id].get_meta("lite_zone_model", false))
        var lite_zone_model := current_lite_zone_model
        if from_player:
            if dense_zone_count > ZONE_DETAIL_LIMIT:
                lite_zone_model = true
            elif dense_zone_count <= ZONE_DETAIL_RECOVER_LIMIT:
                lite_zone_model = false
        else:
            lite_zone_model = false
        var needs_rebuild := not zone_models.has(id)
        if zone_models.has(id):
            needs_rebuild = str(zone_models[id].get_meta("kind", "")) != kind
            needs_rebuild = needs_rebuild or bool(zone_models[id].get_meta("from_player", true)) != from_player
            needs_rebuild = needs_rebuild or bool(zone_models[id].get_meta("lite_zone_model", false)) != lite_zone_model
        if needs_rebuild:
            if zone_models.has(id):
                zone_models[id].queue_free()
            zone_models[id] = _create_zone_model(zone, lite_zone_model)
            add_child(zone_models[id])
        var model: Node3D = zone_models[id]
        model.global_position = _to3d(zone.global_position, 0.055)
        var radius := maxf(0.35, float(zone.get("radius")) * WORLD_SCALE)
        var triggered := bool(zone.get("triggered"))
        var life := float(zone.get("life"))
        var max_life := maxf(0.01, float(zone.get("max_life")))
        var life_ratio := clampf(life / max_life, 0.0, 1.0)
        var active_ratio := 1.0 - life_ratio
        var disc := model.get_node_or_null("Disc") as Node3D
        if disc != null:
            disc.visible = kind != "teemo_mushroom" or triggered
            disc.scale = Vector3(radius, 1.0, radius)
        _sync_zone_duration_rig(model, kind, triggered, life_ratio, active_ratio, id)
        var marker := model.get_node_or_null("Marker") as Node3D
        if marker != null:
            marker.visible = kind != "teemo_mushroom" or not triggered
            marker.rotation.y += 0.010
            _sync_zone_marker_motion(marker, kind, id)
    _remove_missing(zone_models, alive)

func _sync_zone_marker_motion(marker: Node3D, kind: String, seed: int) -> void:
    var time := Time.get_ticks_msec() / 1000.0
    var seed_offset := float(seed % 37) * 0.11
    match kind:
        "teemo_mushroom":
            var breathe := sin(time * 2.8 + seed_offset)
            marker.position.y = 0.010 + breathe * 0.018
            marker.scale = Vector3.ONE * (1.0 + breathe * 0.035)
        "viktor_gravity":
            marker.rotation.y += 0.018
            var circuit_pulse := 1.0 + sin(time * 3.1 + seed_offset) * 0.025
            marker.scale = Vector3.ONE * circuit_pulse
        "asol_singularity":
            marker.rotation.y -= 0.034
            var pull_pulse := 1.0 + sin(time * 4.0 + seed_offset) * 0.040
            marker.scale = Vector3(pull_pulse, 1.0, pull_pulse)
        "morde_realm":
            marker.rotation.y += 0.004
            var realm_weight := 1.0 + sin(time * 1.7 + seed_offset) * 0.018
            marker.scale = Vector3(realm_weight, 1.0, realm_weight)
        "boss_cho_rupture":
            marker.rotation.y += 0.012
            var rupture_pulse := 1.0 + sin(time * 2.8 + seed_offset) * 0.032
            marker.scale = Vector3(rupture_pulse, 1.0, rupture_pulse)
        "boss_velkoz_focus":
            marker.rotation.y += 0.038
            var focus_pulse := 1.0 + sin(time * 5.2 + seed_offset) * 0.040
            marker.scale = Vector3(focus_pulse, 1.0, focus_pulse)
        "boss_reksai_tunnel":
            marker.rotation.y += 0.018
            var tremor_pulse := 1.0 + sin(time * 3.9 + seed_offset) * 0.035
            marker.scale = Vector3(tremor_pulse, 1.0, 1.0 + sin(time * 3.1 + seed_offset) * 0.020)
        "boss_belveth_swarm":
            marker.rotation.y -= 0.032
            var swarm_pulse := 1.0 + sin(time * 4.5 + seed_offset) * 0.045
            marker.scale = Vector3(swarm_pulse, 1.0, swarm_pulse)
        _:
            marker.scale = Vector3.ONE

func _sync_zone_duration_rig(model: Node3D, kind: String, triggered: bool, life_ratio: float, active_ratio: float, seed: int) -> void:
    var show_disc_layers := kind != "teemo_mushroom" or triggered
    var time := Time.get_ticks_msec() / 1000.0
    var seed_offset := float(seed % 43) * 0.07
    var plate := model.find_child("ZoneRunePlate", true, false) as Node3D
    if plate != null:
        plate.visible = show_disc_layers
        plate.rotation.y += _zone_layer_spin(kind) * 0.36
    var pulse_core := model.find_child("ZonePulseCore", true, false) as Node3D
    if pulse_core != null:
        pulse_core.visible = show_disc_layers
        var pulse := lerpf(0.48, 1.0, active_ratio) + sin(time * _zone_pulse_speed(kind) + seed_offset) * 0.026
        pulse_core.scale = Vector3(pulse, 1.0, pulse)
        pulse_core.rotation.y += _zone_layer_spin(kind)
    var progress := model.find_child("ZoneProgressSigils", true, false) as Node3D
    if progress != null:
        progress.visible = show_disc_layers
        progress.rotation.y += _zone_layer_spin(kind) * 0.72
        var child_count := progress.get_child_count()
        var lit_count := clampi(ceili(life_ratio * float(child_count)), 0, child_count)
        for i in range(child_count):
            var sigil := progress.get_child(i) as Node3D
            if sigil == null:
                continue
            sigil.visible = i < lit_count
            sigil.scale = Vector3.ONE * (1.0 + sin(time * 3.8 + seed_offset + float(i) * 0.34) * 0.045)
    var armed := model.find_child("ZoneArmedSigils", true, false) as Node3D
    if armed != null:
        armed.visible = kind == "teemo_mushroom" and not triggered
        armed.rotation.y -= 0.030
        var arm_scale := 1.0 + sin(time * 2.6 + seed_offset) * 0.055
        armed.scale = Vector3(arm_scale, 1.0, arm_scale)
    var boss_hazard := model.find_child("BossHazardZoneFrame", true, false) as Node3D
    if boss_hazard != null:
        boss_hazard.visible = show_disc_layers
        boss_hazard.rotation.y -= _zone_layer_spin(kind) * 1.35
        var hazard_pulse := lerpf(0.86, 1.04, active_ratio) + sin(time * (_zone_pulse_speed(kind) + 0.6) + seed_offset) * 0.030
        boss_hazard.scale = Vector3(hazard_pulse, 1.0, hazard_pulse)
    var source_profile := model.find_child("ZoneSourceProfile", true, false) as Node3D
    if source_profile != null:
        source_profile.visible = show_disc_layers
        var profile_family := str(source_profile.get_meta("profile_family", ""))
        var profile_pulse := lerpf(0.78, 1.0, active_ratio) + sin(time * _zone_source_profile_pulse(kind) + seed_offset) * 0.024
        source_profile.scale = Vector3(profile_pulse, 1.0, profile_pulse)
        source_profile.rotation.y += _zone_source_profile_spin(kind)
        var ring := source_profile.get_node_or_null("ZoneSourceProfileRing") as Node3D
        if ring != null:
            ring.rotation.y += 0.030 if profile_family == "comet" or profile_family == "laser" else 0.018
        var detail_name := str(source_profile.get_meta("detail_node", ""))
        var detail := source_profile.get_node_or_null(detail_name) as Node3D
        if detail != null:
            detail.position.y = sin(time * 4.6 + seed_offset) * 0.006
    _sync_zone_resolution_profile(model, kind, show_disc_layers, life_ratio, active_ratio, seed)

func _sync_zone_resolution_profile(model: Node3D, kind: String, show_layers: bool, life_ratio: float, active_ratio: float, seed: int) -> void:
    var profile := model.find_child("ZoneResolutionProfile", true, false) as Node3D
    if profile == null:
        return
    profile.visible = show_layers
    if not show_layers:
        return
    var time := Time.get_ticks_msec() / 1000.0
    var seed_offset := float(seed % 59) * 0.05
    var resolution_type := str(profile.get_meta("resolution_type", ""))
    var pulse := lerpf(0.84, 1.02, active_ratio) + sin(time * 3.2 + seed_offset) * 0.018
    profile.scale = Vector3(pulse, 1.0, pulse)
    profile.rotation.y += _zone_layer_spin(kind) * 0.46
    var edge := profile.get_node_or_null("ZoneResolutionEdge") as Node3D
    if edge != null:
        edge.rotation.y -= _zone_layer_spin(kind) * 0.72
    var frame := profile.get_node_or_null("ZoneResolutionFrame") as Node3D
    if frame != null:
        frame.rotation.y += 0.012 if resolution_type == "containment_lock" else 0.006
    var needle := profile.get_node_or_null("ZoneResolutionTimerNeedle") as Node3D
    if needle != null:
        needle.rotation.y = -TAU * clampf(life_ratio, 0.0, 1.0)
        needle.scale = Vector3(maxf(0.18, life_ratio), 1.0, 1.0)
    var detail_name := str(profile.get_meta("detail_node", ""))
    var detail := profile.get_node_or_null(detail_name) as Node3D
    if detail != null:
        detail.position.y = sin(time * 4.9 + seed_offset) * 0.006
        detail.rotation.y += 0.018 if resolution_type == "gravity_collapse" or resolution_type == "poison_bloom" else 0.009

func _zone_layer_spin(kind: String) -> float:
    match kind:
        "asol_singularity":
            return -0.030
        "viktor_gravity":
            return 0.020
        "morde_realm":
            return 0.008
        "teemo_mushroom":
            return 0.014
        "boss_cho_rupture":
            return 0.010
        "boss_velkoz_focus":
            return 0.026
        "boss_reksai_tunnel":
            return 0.018
        "boss_belveth_swarm":
            return -0.024
        _:
            return 0.012

func _zone_pulse_speed(kind: String) -> float:
    match kind:
        "asol_singularity":
            return 4.6
        "viktor_gravity":
            return 3.5
        "morde_realm":
            return 2.2
        "teemo_mushroom":
            return 3.0
        "boss_cho_rupture":
            return 2.7
        "boss_velkoz_focus":
            return 4.8
        "boss_reksai_tunnel":
            return 3.6
        "boss_belveth_swarm":
            return 4.1
        _:
            return 3.2

func _zone_source_profile_spin(kind: String) -> float:
    match kind:
        "asol_singularity":
            return -0.022
        "viktor_gravity":
            return 0.018
        "morde_realm":
            return 0.008
        "teemo_mushroom":
            return 0.014
        "boss_cho_rupture":
            return 0.010
        "boss_velkoz_focus":
            return 0.030
        "boss_reksai_tunnel":
            return 0.018
        "boss_belveth_swarm":
            return -0.028
        _:
            return 0.010

func _zone_source_profile_pulse(kind: String) -> float:
    match kind:
        "asol_singularity":
            return 3.8
        "viktor_gravity":
            return 4.2
        "morde_realm":
            return 2.4
        "teemo_mushroom":
            return 3.2
        "boss_cho_rupture":
            return 3.0
        "boss_velkoz_focus":
            return 5.0
        "boss_reksai_tunnel":
            return 3.7
        "boss_belveth_swarm":
            return 4.4
        _:
            return 3.0

func _sync_death_bursts() -> void:
    var alive := {}
    for burst in get_tree().get_nodes_in_group("survivor_death_bursts"):
        if not is_instance_valid(burst):
            continue
        var id := burst.get_instance_id()
        alive[id] = true
        var kind := str(burst.get("enemy_kind"))
        var elite := bool(burst.get("elite"))
        var boss := bool(burst.get("boss"))
        if not death_burst_models.has(id):
            death_burst_models[id] = _create_enemy_death_burst_model(kind, elite, boss, burst.get("burst_color"))
            _make_unique_materials(death_burst_models[id])
            add_child(death_burst_models[id])
        var model: Node3D = death_burst_models[id]
        var radius := maxf(0.40, float(burst.get("burst_radius")) * WORLD_SCALE)
        var life := float(burst.get("life"))
        var max_life := maxf(0.01, float(burst.get("max_life")))
        var progress := 1.0 - clampf(life / max_life, 0.0, 1.0)
        var time := Time.get_ticks_msec() / 1000.0
        model.global_position = _to3d(burst.global_position, 0.040)
        model.scale = Vector3.ONE * lerpf(0.18, radius, progress)
        model.rotation.y = time * (0.58 if boss else 0.42 if elite else 0.26)
        var alpha_scale := maxf(0.0, 1.0 - progress)
        var base_color: Color = burst.get("burst_color")
        _sync_death_burst_alpha(model, base_color, alpha_scale)
        var shard_rig := model.get_node_or_null("EnemyDeathShardRig") as Node3D
        if shard_rig != null:
            shard_rig.rotation.y += 0.055 if boss else 0.040 if elite else 0.026
            shard_rig.scale = Vector3.ONE * lerpf(0.72, 1.28, progress)
        var reward_crown := model.get_node_or_null("EnemyDeathRewardCrown") as Node3D
        if reward_crown != null:
            reward_crown.rotation.y -= 0.070 if boss else 0.048
            reward_crown.position.y = 0.170 + sin(time * 4.2 + float(id % 31)) * 0.026
        var reward_relic := model.get_node_or_null("EnemyDeathPremiumRewardRelic") as Node3D
        if reward_relic != null:
            reward_relic.rotation.y += 0.088 if boss else 0.060
            reward_relic.position.y = 0.024 + sin(time * 3.8 + float(id % 29)) * 0.018
            var relic_core := reward_relic.get_node_or_null("EnemyDeathRewardRelicCore") as Node3D
            if relic_core != null:
                relic_core.rotation.y -= 0.115 if boss else 0.082
                relic_core.scale = Vector3.ONE * (1.0 + sin(time * 6.2 + float(id % 19)) * (0.070 if boss else 0.048))
            var relic_signal := reward_relic.get_node_or_null("EnemyDeathRewardRelicSignal") as Node3D
            if relic_signal != null:
                relic_signal.scale = Vector3.ONE * (1.0 + sin(time * 5.4 + float(id % 11)) * (0.082 if boss else 0.056))
        var signature := model.get_node_or_null("EnemyDeathBurstSignature") as Node3D
        if signature != null:
            signature.scale = Vector3.ONE * (1.0 + sin(time * 5.0 + float(id % 23)) * 0.035)
        var afterimage := model.get_node_or_null("EnemyDeathAfterimageRig") as Node3D
        if afterimage != null:
            afterimage.rotation.y -= 0.070 if boss else 0.050 if elite else 0.034
            afterimage.position.y = lerpf(0.006, 0.060, progress)
            afterimage.scale = Vector3.ONE * lerpf(0.82, 1.46 if boss else 1.26 if elite else 1.12, progress)
        var soul_core := model.find_child("EnemyDeathSoulCore", true, false) as Node3D
        if soul_core != null:
            soul_core.position.y = 0.190 + progress * (0.080 if boss else 0.052) + sin(time * 7.0 + float(id % 17)) * 0.010
            soul_core.scale = Vector3.ONE * (1.0 + sin(time * 7.8 + float(id % 13)) * (0.080 if boss else 0.052))
    _remove_missing(death_burst_models, alive)

func _sync_spawn_rifts() -> void:
    var alive := {}
    for rift in get_tree().get_nodes_in_group("survivor_spawn_rifts"):
        if not is_instance_valid(rift):
            continue
        var id := rift.get_instance_id()
        alive[id] = true
        var kind := str(rift.get("enemy_kind"))
        var elite := bool(rift.get("elite"))
        var boss := bool(rift.get("boss"))
        if not spawn_rift_models.has(id):
            spawn_rift_models[id] = _create_enemy_spawn_rift_model(kind, elite, boss, rift.get("rift_color"))
            _make_unique_materials(spawn_rift_models[id])
            add_child(spawn_rift_models[id])
        var model: Node3D = spawn_rift_models[id]
        var radius := maxf(0.34, float(rift.get("rift_radius")) * WORLD_SCALE)
        var life := float(rift.get("life"))
        var max_life := maxf(0.01, float(rift.get("max_life")))
        var progress := 1.0 - clampf(life / max_life, 0.0, 1.0)
        var time := Time.get_ticks_msec() / 1000.0
        model.global_position = _to3d(rift.global_position, 0.030)
        model.scale = Vector3.ONE * lerpf(0.28, radius, progress)
        model.rotation.y = time * (-0.42 if boss else -0.32 if elite else -0.22) + float(id % 31) * 0.04
        var base_color := Color(0.70, 0.20, 1.0, 0.40)
        if rift.get("rift_color") is Color:
            base_color = rift.get("rift_color")
        var alpha_scale := sin(clampf(progress, 0.0, 1.0) * PI) * (1.0 if boss else 0.86 if elite else 0.72)
        _sync_spawn_rift_alpha(model, base_color, alpha_scale)
        var pillar_rig := model.get_node_or_null("EnemySpawnRiftPillarRig") as Node3D
        if pillar_rig != null:
            pillar_rig.rotation.y -= 0.052 if boss else 0.038 if elite else 0.026
            pillar_rig.scale = Vector3.ONE * lerpf(0.76, 1.22, progress)
        var species_mark := model.get_node_or_null("EnemySpawnRiftSpeciesMark") as Node3D
        if species_mark != null:
            species_mark.rotation.y += 0.044 if boss else 0.030
            species_mark.position.y = 0.116 + sin(time * 5.8 + float(id % 13)) * 0.016
        var crown := model.get_node_or_null("EnemySpawnRiftPriorityCrown") as Node3D
        if crown != null:
            crown.rotation.y += 0.068 if boss else 0.048
            crown.scale = Vector3.ONE * (1.0 + sin(time * 5.2 + float(id % 17)) * 0.045)
    _remove_missing(spawn_rift_models, alive)

func _create_enemy_spawn_rift_model(kind: String, elite: bool, boss: bool, color_value) -> Node3D:
    var model := Node3D.new()
    model.set_meta("kind", kind)
    model.set_meta("elite", elite)
    model.set_meta("boss", boss)
    var color := Color(0.70, 0.20, 1.0, 0.40)
    if color_value is Color:
        color = color_value
    var hot := color.lightened(0.22)
    var dark := Color(0.020, 0.010, 0.038, 0.54)
    var ring_segments := 8 if elite or boss or kind == "rift_crystal" else 6
    if kind == "void_eye" or kind == "boss_velkoz":
        ring_segments = 24
    var portal_mat := _mat("spawn_rift_portal_" + kind, Color(color.r, color.g, color.b, 0.42), 1.08, true, true)
    var hot_mat := _mat("spawn_rift_hot_" + kind, Color(hot.r, hot.g, hot.b, 0.58), 1.26, true, true)
    var dark_mat := _mat("spawn_rift_dark_" + kind, dark, 0.10, true, true)
    var gold_mat := _mat("spawn_rift_gold_" + kind, Color(1.0, 0.76, 0.24, 0.42), 0.82, true, true)

    var signature := Node3D.new()
    signature.name = "EnemySpawnRiftSignature"
    model.add_child(signature)
    _add_cylinder_segments(signature, 1.08, 0.014, ring_segments, portal_mat, Vector3(0, 0.070, 0), Vector3(0, 22.5 if ring_segments == 8 else 30, 0))
    _add_cylinder_segments(signature, 0.62, 0.012, 6, dark_mat, Vector3(0, 0.092, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(signature, 0.32, 0.010, 24, hot_mat, Vector3(0, 0.116, 0))
    var decal_path := _vfx_decal_texture_path()
    if decal_path != "":
        var decal_mat := _vfx_decal_mat("enemy_spawn_rift_decal_" + kind, decal_path, Color(color.r, color.g, color.b, 0.40 if not boss else 0.52), 1.18, Vector3(0.25, 0.25, 1.0), _enemy_spawn_rift_vfx_offset(kind))
        var decal := _add_textured_plane(signature, Vector2(2.06 if not boss else 2.88, 2.06 if not boss else 2.88), decal_mat, Vector3(0, 0.082, 0), Vector3(0, 45, 0))
        decal.name = "EnemySpawnRiftPortalDecal"

    var species := Node3D.new()
    species.name = "EnemySpawnRiftSpeciesMark"
    species.set_meta("kind", kind)
    model.add_child(species)
    match kind:
        "spitter":
            _add_box(species, Vector3(0.82, 0.014, 0.078), hot_mat, Vector3(0, 0.146, 0))
            _add_tapered_cylinder(species, 0.060, 0.014, 0.48, 6, hot_mat, Vector3(0, 0.168, 0.38), Vector3(74, 0, 0))
        "burrower", "boss_reksai":
            for side in [-1.0, 1.0]:
                _add_box(species, Vector3(0.14, 0.016, 1.12), hot_mat, Vector3(side * 0.28, 0.150, 0), Vector3(0, side * 22.0, side * 38.0))
        "carapace", "boss_cho":
            _add_cylinder_segments(species, 0.58, 0.014, 5, hot_mat, Vector3(0, 0.148, 0), Vector3(0, 18, 0))
            for side in [-1.0, 1.0]:
                _add_box(species, Vector3(0.56, 0.014, 0.072), hot_mat, Vector3(side * 0.32, 0.166, 0.22), Vector3(0, side * 30.0, 0))
        "void_eye", "boss_velkoz":
            _add_cylinder_segments(species, 0.72, 0.012, 24, hot_mat, Vector3(0, 0.150, 0), Vector3(90, 0, 0))
            _add_box(species, Vector3(1.02, 0.014, 0.076), dark_mat, Vector3(0, 0.170, 0))
            _add_sphere(species, 0.074, hot_mat, Vector3(0, 0.194, 0))
        "rift_crystal":
            var crystal := _add_crystal(species, 0.090, 0.48, hot, Vector3(0, 0.320, 0), Vector3(0, 30, 0))
            crystal.name = "EnemySpawnRiftCrystalMark"
        "boss_belveth":
            for side in [-1.0, 1.0]:
                _add_box(species, Vector3(0.18, 0.016, 1.26), hot_mat, Vector3(side * 0.46, 0.162, -0.06), Vector3(0, side * 18.0, side * 42.0))
            _add_sphere(species, 0.086, hot_mat, Vector3(0, 0.202, 0))
        _:
            _add_tapered_cylinder(species, 0.065, 0.014, 0.46, 6, hot_mat, Vector3(0, 0.174, 0.32), Vector3(72, 0, 0))
            _add_tapered_cylinder(species, 0.065, 0.014, 0.46, 6, hot_mat, Vector3(0, 0.174, -0.32), Vector3(72, 180, 0))

    var pillar_rig := Node3D.new()
    pillar_rig.name = "EnemySpawnRiftPillarRig"
    model.add_child(pillar_rig)
    var pillar_count := 10 if boss else 7 if elite else 5
    for i in range(pillar_count):
        var angle := TAU * float(i) / float(pillar_count)
        var radial := 0.52 + float(i % 2) * 0.10
        var pillar_pos := Vector3(cos(angle) * radial, 0.182 + float(i % 3) * 0.018, sin(angle) * radial)
        _add_tapered_cylinder(pillar_rig, 0.044 if not boss else 0.064, 0.006, 0.48 if not boss else 0.72, 6, hot_mat if i % 2 == 0 else portal_mat, pillar_pos, Vector3(68, -rad_to_deg(angle), 0))

    if elite or boss:
        var crown := Node3D.new()
        crown.name = "EnemySpawnRiftPriorityCrown"
        model.add_child(crown)
        _add_cylinder_segments(crown, 0.92 if not boss else 1.24, 0.014, 8, gold_mat, Vector3(0, 0.190, 0), Vector3(0, 22.5, 0))
        _add_cylinder_segments(crown, 0.60 if not boss else 0.82, 0.010, 24, portal_mat, Vector3(0, 0.214, 0))
        var pip_count := 8 if boss else 6
        for i in range(pip_count):
            var pip_angle := TAU * float(i) / float(pip_count)
            _add_sphere(crown, 0.038 if not boss else 0.052, gold_mat, Vector3(cos(pip_angle) * (0.62 if not boss else 0.84), 0.260, sin(pip_angle) * (0.62 if not boss else 0.84)))
    return model

func _enemy_spawn_rift_vfx_offset(kind: String) -> Vector3:
    match kind:
        "spitter":
            return Vector3(0.50, 0.25, 0.0)
        "burrower", "boss_reksai":
            return Vector3(0.50, 0.50, 0.0)
        "void_eye", "boss_velkoz":
            return Vector3(0.0, 0.50, 0.0)
        "rift_crystal":
            return Vector3(0.25, 0.75, 0.0)
        "boss_cho", "boss_belveth":
            return Vector3(0.75, 0.50, 0.0)
        _:
            return Vector3(0.25, 0.50, 0.0)

func _sync_spawn_rift_alpha(node: Node, base_color: Color, alpha_scale: float) -> void:
    for child in node.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.material_override is StandardMaterial3D:
                var mat := mesh_instance.material_override as StandardMaterial3D
                var color := mat.albedo_color
                color.a = maxf(0.0, minf(color.a, base_color.a + 0.34) * alpha_scale)
                mat.albedo_color = color
                if mat.emission_enabled:
                    mat.emission = Color(color.r, color.g, color.b)
        _sync_spawn_rift_alpha(child, base_color, alpha_scale)

func _sync_hit_sparks() -> void:
    var alive := {}
    for spark in get_tree().get_nodes_in_group("survivor_hit_sparks"):
        if not is_instance_valid(spark):
            continue
        var id := spark.get_instance_id()
        alive[id] = true
        var label := str(spark.get("spark_label"))
        var family := str(spark.get("spark_family"))
        var priority := bool(spark.get("priority"))
        if not hit_spark_models.has(id):
            var dense_spark_lod := hit_spark_models.size() >= 3 and not priority
            hit_spark_models[id] = _create_hit_spark_model(label, family, spark.get("spark_color"), priority, dense_spark_lod)
            _make_unique_materials(hit_spark_models[id])
            add_child(hit_spark_models[id])
        var model: Node3D = hit_spark_models[id]
        var radius := maxf(0.30, float(spark.get("spark_radius")) * WORLD_SCALE)
        var life := float(spark.get("life"))
        var max_life := maxf(0.01, float(spark.get("max_life")))
        var progress := 1.0 - clampf(life / max_life, 0.0, 1.0)
        var time := Time.get_ticks_msec() / 1000.0
        model.global_position = _to3d(spark.global_position, 0.086)
        model.scale = Vector3.ONE * lerpf(0.24, radius, minf(1.0, progress * 1.25))
        model.rotation.y = float(id % 360) * 0.0174533 + time * (0.38 if priority else 0.26)
        var base_color := Color(1.0, 0.66, 0.22, 0.48)
        if spark.get("spark_color") is Color:
            base_color = spark.get("spark_color")
        var alpha_scale := pow(maxf(0.0, 1.0 - progress), 0.62) * (1.0 if priority else 0.78)
        _sync_hit_spark_alpha(model, base_color, alpha_scale)
        var slash_rig := model.get_node_or_null("HitSparkSlashRig") as Node3D
        if slash_rig != null:
            slash_rig.rotation.y += 0.100 if priority else 0.072
            slash_rig.scale = Vector3.ONE * lerpf(0.82, 1.22, progress)
        var glyph := model.get_node_or_null("HitSparkFamilyGlyph") as Node3D
        if glyph != null:
            glyph.rotation.y -= 0.082 if priority else 0.052
            glyph.position.y = 0.165 + sin(time * 8.0 + float(id % 19)) * 0.012
        var shard_rig := model.get_node_or_null("HitSparkMaterialShardRig") as Node3D
        if shard_rig != null:
            shard_rig.rotation.y -= 0.128 if priority else 0.086
            shard_rig.position.y = lerpf(0.006, 0.052, progress)
            shard_rig.scale = Vector3.ONE * lerpf(0.70, 1.34 if priority else 1.18, progress)
        var directional_shock := model.get_node_or_null("HitSparkDirectionalShock") as Node3D
        if directional_shock != null:
            var shock_scale := lerpf(0.72, 1.48 if priority else 1.24, progress)
            directional_shock.scale = Vector3(shock_scale, 1.0, lerpf(0.72, 1.12, progress))
            directional_shock.position.y = 0.014 + sin(time * 9.0 + float(id % 11)) * 0.006
        var source_profile := model.get_node_or_null("HitSparkSourceProfile") as Node3D
        if source_profile != null:
            var profile_family := str(source_profile.get_meta("profile_family", ""))
            var profile_pulse := 1.0 + sin(time * (5.4 if profile_family == "rocket" or profile_family == "duelist" else 3.6) + float(id % 23)) * 0.036
            source_profile.scale = Vector3.ONE * lerpf(0.76, profile_pulse, progress)
            source_profile.rotation.y += 0.048 if profile_family == "rocket" or profile_family == "poison" else -0.032
            var profile_ring := source_profile.get_node_or_null("HitSparkSourceProfileRing") as Node3D
            if profile_ring != null:
                profile_ring.rotation.y += 0.060 if priority else 0.038
            var detail_name := str(source_profile.get_meta("detail_node", ""))
            var detail := source_profile.get_node_or_null(detail_name) as Node3D
            if detail != null:
                detail.position.y = sin(time * 7.2 + float(id % 17)) * 0.010
        var resolution_profile := model.get_node_or_null("HitSparkResolutionProfile") as Node3D
        if resolution_profile != null:
            var resolution_family := str(resolution_profile.get_meta("resolution_family", ""))
            var resolution_pulse := 1.0 + sin(time * _hit_spark_resolution_pulse(resolution_family) + float(id % 31)) * 0.032
            resolution_profile.scale = Vector3.ONE * lerpf(0.72, resolution_pulse, progress)
            resolution_profile.rotation.y -= _hit_spark_resolution_spin(resolution_family)
            var floor_seal := resolution_profile.get_node_or_null("HitSparkResolutionFloorSeal") as Node3D
            if floor_seal != null:
                floor_seal.scale = Vector3(0.82 + progress * 0.34, 1.0, 0.82 + progress * 0.34)
            var detail_name := str(resolution_profile.get_meta("detail_node", ""))
            var detail := resolution_profile.get_node_or_null(detail_name) as Node3D
            if detail != null:
                detail.position.y = sin(time * (_hit_spark_resolution_pulse(resolution_family) + 1.4) + float(id % 13)) * 0.008
        _sync_hit_spark_severity_rig(model, int(spark.get("spark_amount")), priority, progress, time, id)
    _remove_missing(hit_spark_models, alive)

func _create_hit_spark_model(label: String, family: String, color_value, priority: bool, dense_lod := false) -> Node3D:
    var model := Node3D.new()
    model.set_meta("label", label)
    model.set_meta("family", family)
    model.set_meta("dense_lod", dense_lod)
    var color := Color(1.0, 0.66, 0.22, 0.48)
    if color_value is Color:
        color = color_value
    var hot := color.lightened(0.24)
    var dark := Color(0.030, 0.018, 0.045, 0.52)
    var spark_mat := _mat("hit_spark_" + family + "_" + label, Color(color.r, color.g, color.b, 0.46), 1.12, true, true)
    var hot_mat := _mat("hit_spark_hot_" + family + "_" + label, Color(hot.r, hot.g, hot.b, 0.62), 1.34, true, true)
    var dark_mat := _mat("hit_spark_dark_" + family + "_" + label, dark, 0.08, true, true)
    var gold_mat := _mat("hit_spark_gold_" + family + "_" + label, Color(1.0, 0.76, 0.24, 0.38), 0.78, true, true)

    var signature := Node3D.new()
    signature.name = "HitSparkImpactSignature"
    model.add_child(signature)
    _add_cylinder_segments(signature, 0.58 if not priority else 0.78, 0.010, 8, spark_mat, Vector3(0, 0.082, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(signature, 0.30 if not priority else 0.42, 0.009, 24, hot_mat, Vector3(0, 0.102, 0))
    if priority:
        var priority_ring := _add_cylinder_segments(signature, 0.96, 0.010, 12, gold_mat, Vector3(0, 0.094, 0), Vector3(0, 15, 0))
        priority_ring.name = "HitSparkPriorityRing"
    var core := _add_sphere(signature, 0.072 if not priority else 0.096, hot_mat, Vector3(0, 0.165, 0))
    core.name = "HitSparkCore"
    var decal_path := _vfx_decal_texture_path()
    if decal_path != "":
        var decal_mat := _vfx_decal_mat("hit_spark_decal_" + family + "_" + label, decal_path, Color(color.r, color.g, color.b, 0.36 if not priority else 0.48), 1.16, Vector3(0.25, 0.25, 1.0), _hit_spark_vfx_offset(family, label))
        var decal := _add_textured_plane(signature, Vector2(1.18 if not priority else 1.52, 1.18 if not priority else 1.52), decal_mat, Vector3(0, 0.074, 0), Vector3(0, 45, 0))
        decal.name = "HitSparkVfxDecal"

    var slash_rig := Node3D.new()
    slash_rig.name = "HitSparkSlashRig"
    model.add_child(slash_rig)
    var slash_count := 2 if dense_lod else 7 if priority else 5
    if not dense_lod:
        match family:
            "magic":
                slash_count += 1
            "explosive":
                slash_count += 2
            _:
                pass
    for i in range(slash_count):
        var angle := TAU * float(i) / float(slash_count)
        var len := 0.48 if not priority else 0.66
        if family == "explosive":
            len += 0.12
        var pos := Vector3(cos(angle) * 0.28, 0.148 + float(i % 2) * 0.014, sin(angle) * 0.28)
        _add_box(slash_rig, Vector3(0.060 if not priority else 0.080, 0.014, len), hot_mat if i % 2 == 0 else spark_mat, pos, Vector3(0, -rad_to_deg(angle), 0))

    var glyph := Node3D.new()
    glyph.name = "HitSparkFamilyGlyph"
    model.add_child(glyph)
    if dense_lod:
        _add_box(glyph, Vector3(0.54, 0.010, 0.044), hot_mat, Vector3(0, 0.156, 0), Vector3(0, 28, 0))
        _add_sphere(glyph, 0.034, spark_mat, Vector3(0, 0.182, 0))
    else:
        match family:
            "magic":
                _add_cylinder_segments(glyph, 0.46, 0.010, 6, spark_mat, Vector3(0, 0.154, 0), Vector3(0, 30, 0))
                _add_box(glyph, Vector3(0.78, 0.012, 0.044), hot_mat, Vector3(0, 0.176, 0))
                _add_box(glyph, Vector3(0.044, 0.012, 0.78), hot_mat, Vector3(0, 0.178, 0))
                for side in [-1.0, 1.0]:
                    _add_sphere(glyph, 0.032, hot_mat, Vector3(side * 0.34, 0.204, side * 0.12))
                    _add_box(glyph, Vector3(0.20, 0.010, 0.030), spark_mat, Vector3(side * 0.42, 0.188, -side * 0.22), Vector3(0, side * 34.0, 0))
            "poison":
                _add_cylinder_segments(glyph, 0.42, 0.010, 5, spark_mat, Vector3(0, 0.154, 0), Vector3(0, 18, 0))
                for i in range(5):
                    var spore_angle := TAU * float(i) / 5.0
                    _add_sphere(glyph, 0.038, hot_mat, Vector3(cos(spore_angle) * 0.34, 0.188, sin(spore_angle) * 0.34))
            "void":
                _add_cylinder_segments(glyph, 0.46, 0.010, 8, spark_mat, Vector3(0, 0.154, 0), Vector3(0, 22.5, 0))
                _add_box(glyph, Vector3(0.90, 0.012, 0.052), dark_mat, Vector3(0, 0.178, 0))
                _add_sphere(glyph, 0.060, hot_mat, Vector3(0, 0.205, 0))
                for side in [-1.0, 1.0]:
                    _add_box(glyph, Vector3(0.36, 0.012, 0.046), spark_mat, Vector3(side * 0.34, 0.196, side * 0.22), Vector3(0, side * 44.0, 0))
                    _add_sphere(glyph, 0.030, hot_mat, Vector3(side * 0.48, 0.218, -side * 0.14))
            "explosive":
                _add_cylinder_segments(glyph, 0.56, 0.012, 8, spark_mat, Vector3(0, 0.154, 0), Vector3(0, 22.5, 0))
                _add_cylinder_segments(glyph, 0.34, 0.010, 24, gold_mat, Vector3(0, 0.178, 0))
                for i in range(4):
                    var blast_angle := TAU * float(i) / 4.0 + PI * 0.25
                    _add_box(glyph, Vector3(0.070, 0.014, 0.46), hot_mat, Vector3(cos(blast_angle) * 0.42, 0.192, sin(blast_angle) * 0.42), Vector3(0, -rad_to_deg(blast_angle), 0))
            _:
                _add_box(glyph, Vector3(0.84, 0.012, 0.052), hot_mat, Vector3(0, 0.160, 0), Vector3(0, 28, 0))
                _add_box(glyph, Vector3(0.52, 0.012, 0.044), spark_mat, Vector3(0, 0.182, 0), Vector3(0, -34, 0))
    _add_hit_spark_material_shards(model, family, label, priority, dense_lod, spark_mat, hot_mat, dark_mat, gold_mat, hot)
    if not dense_lod:
        _add_hit_spark_source_profile(model, family, label, priority, spark_mat, hot_mat, dark_mat, gold_mat)
        _add_hit_spark_resolution_profile(model, family, label, priority, spark_mat, hot_mat, dark_mat, gold_mat)
        _add_hit_spark_severity_rig(model, family, label, priority, color)
    return model

func _add_hit_spark_severity_rig(model: Node3D, impact_family: String, label: String, priority: bool, color: Color) -> void:
    if model.get_node_or_null("HitSparkSeverityRig") != null:
        return
    var severity_family := _hit_spark_profile_family(label, impact_family)
    var family_color := _player_projectile_family_color(label, color)
    var rig := Node3D.new()
    rig.name = "HitSparkSeverityRig"
    rig.visible = false
    rig.set_meta("label", label)
    rig.set_meta("impact_family", impact_family)
    rig.set_meta("severity_family", severity_family)
    rig.set_meta("source_champion", _player_projectile_source_champion(label))
    rig.set_meta("combat_visual_channel", "hit_spark_severity")
    rig.set_meta("dynamic_severity", true)
    rig.set_meta("priority", priority)
    model.add_child(rig)

    var dark_mat := _mat("hit_spark_severity_dark_" + label, Color(0.0, 0.0, 0.0, 0.30), 0.0, true, true)
    var meter_mat := _mat("hit_spark_severity_meter_" + label, Color(family_color.r, family_color.g, family_color.b, 0.26), 0.0, true, true)
    var gold_mat := _mat("hit_spark_severity_gold_" + label, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.22), 0.0, true, true)
    var stamp_mat := _mat("hit_spark_severity_stamp_" + label, Color(family_color.lightened(0.14).r, family_color.lightened(0.14).g, family_color.lightened(0.14).b, 0.28), 0.0, true, true)

    var matte := _add_cylinder_segments(rig, 0.78 if priority else 0.64, 0.008, 8, dark_mat, Vector3(0, 0.060, 0), Vector3(0, 22.5, 0))
    matte.name = "HitSparkSeverityMatte"
    var meter := _add_box(rig, Vector3(0.82 if priority else 0.66, 0.010, 0.052), meter_mat, Vector3(0, 0.082, -0.58 if priority else -0.48))
    meter.name = "HitSparkSeverityMeter"
    meter.set_meta("bar_width", 0.82 if priority else 0.66)
    var trim := _add_box(rig, Vector3(0.90 if priority else 0.72, 0.008, 0.024), gold_mat, Vector3(0, 0.098, -0.66 if priority else -0.55))
    trim.name = "HitSparkSeverityTrim"

    var pips := Node3D.new()
    pips.name = "HitSparkSeverityPips"
    pips.set_meta("pip_count", 4)
    rig.add_child(pips)
    for i in range(4):
        var offset := -0.5 + float(i) / 3.0
        var pip := _add_box(pips, Vector3(0.052 if priority else 0.044, 0.008, 0.140 if priority else 0.112), stamp_mat, Vector3(offset * (0.62 if priority else 0.50), 0.112, 0.48 if priority else 0.40), Vector3(0, offset * 12.0, 0))
        pip.name = "HitSparkSeverityPip%d" % i
        pip.visible = false
        pip.set_meta("pip_index", i)

    var stamp := Node3D.new()
    stamp.name = "HitSparkSeverityChampionStamp"
    stamp.visible = false
    stamp.set_meta("severity_family", severity_family)
    rig.add_child(stamp)
    match severity_family:
        "rocket":
            _add_cylinder_segments(stamp, 0.24 if priority else 0.19, 0.008, 8, stamp_mat, Vector3(0, 0.126, 0), Vector3(0, 22.5, 0))
            for i in range(4):
                var angle := TAU * float(i) / 4.0 + PI * 0.25
                _add_box(stamp, Vector3(0.038, 0.008, 0.260 if priority else 0.210), gold_mat, Vector3(cos(angle) * 0.25, 0.142, sin(angle) * 0.25), Vector3(0, -rad_to_deg(angle), 0))
        "artillery", "laser":
            _add_box(stamp, Vector3(0.060, 0.008, 0.620 if priority else 0.500), stamp_mat, Vector3(0, 0.132, 0.08))
            _add_cylinder_segments(stamp, 0.250 if priority else 0.200, 0.008, 24, gold_mat, Vector3(0, 0.148, 0.26), Vector3(90, 0, 0))
        "duelist":
            for side in [-1.0, 1.0]:
                _add_box(stamp, Vector3(0.042, 0.008, 0.520 if priority else 0.420), stamp_mat, Vector3(side * 0.09, 0.134, 0), Vector3(0, side * 34.0, side * 18.0))
        "feather":
            for i in range(5):
                var offset := float(i) - 2.0
                _add_box(stamp, Vector3(0.034, 0.008, 0.360 - abs(offset) * 0.026), stamp_mat, Vector3(offset * 0.070, 0.134, -0.02 + abs(offset) * 0.030), Vector3(0, offset * 12.0, offset * 10.0))
        "poison":
            _add_sphere(stamp, 0.130 if priority else 0.105, stamp_mat, Vector3(0, 0.150, 0))
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(stamp, 0.028, meter_mat, Vector3(cos(angle) * 0.22, 0.132, sin(angle) * 0.20))
        "comet":
            _add_cylinder_segments(stamp, 0.310 if priority else 0.250, 0.008, 32, stamp_mat, Vector3(0, 0.132, 0), Vector3(90, 0, 0))
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_sphere(stamp, 0.030 if priority else 0.024, gold_mat, Vector3(cos(angle) * 0.24, 0.150, sin(angle) * 0.18))
        "juggernaut":
            _add_cylinder_segments(stamp, 0.290 if priority else 0.230, 0.008, 8, dark_mat, Vector3(0, 0.130, 0), Vector3(0, 22.5, 0))
            _add_box(stamp, Vector3(0.115, 0.010, 0.520 if priority else 0.420), stamp_mat, Vector3(0.05, 0.148, 0), Vector3(0, -24, 0))
            _add_box(stamp, Vector3(0.420 if priority else 0.340, 0.010, 0.115), gold_mat, Vector3(0.24, 0.164, 0.18), Vector3(0, -24, 0))
        _:
            _add_box(stamp, Vector3(0.460 if priority else 0.360, 0.008, 0.044), stamp_mat, Vector3(0, 0.134, 0), Vector3(0, 28, 0))
            _add_box(stamp, Vector3(0.044, 0.008, 0.460 if priority else 0.360), stamp_mat, Vector3(0, 0.146, 0), Vector3(0, -28, 0))

func _sync_hit_spark_severity_rig(model: Node3D, amount: int, priority: bool, progress: float, time: float, id: int) -> void:
    var rig := model.get_node_or_null("HitSparkSeverityRig") as Node3D
    if rig == null:
        return
    var severity := clampf(float(amount) / (11.0 if priority else 16.0), 0.0, 1.0)
    if priority:
        severity = maxf(severity, 0.62)
    rig.set_meta("severity", severity)
    rig.visible = severity >= 0.34
    if not rig.visible:
        return
    var pulse := 1.0 + sin(time * (4.0 + severity * 3.0) + float(id % 29)) * (0.018 + severity * 0.028)
    rig.scale = Vector3(pulse + severity * 0.050, 1.0, pulse + severity * 0.032)
    rig.rotation.y -= 0.026 + severity * 0.040
    rig.position.y = sin(time * 6.0 + float(id % 17)) * 0.010

    var meter := rig.get_node_or_null("HitSparkSeverityMeter") as MeshInstance3D
    if meter != null:
        meter.visible = true
        var bar_width := float(meter.get_meta("bar_width", 1.0))
        meter.scale.x = lerpf(0.20, 1.0, severity)
        meter.position.x = -bar_width * (1.0 - meter.scale.x) * 0.5
    var pips := rig.get_node_or_null("HitSparkSeverityPips") as Node3D
    if pips != null:
        var active_pips: int = clampi(ceili(severity * 4.0), 0, 4)
        for child in pips.get_children():
            if not child.has_meta("pip_index"):
                continue
            var pip := child as Node3D
            if pip == null:
                continue
            var pip_index := int(pip.get_meta("pip_index"))
            pip.visible = pip_index < active_pips
            if pip.visible:
                pip.scale = Vector3.ONE * (1.0 + sin(time * 7.2 + float(pip_index) * 0.8 + float(id % 5)) * 0.045)
    var stamp := rig.get_node_or_null("HitSparkSeverityChampionStamp") as Node3D
    if stamp != null:
        stamp.visible = severity >= 0.55
        if stamp.visible:
            stamp.rotation.y += 0.040 + severity * 0.060
            stamp.scale = Vector3.ONE * (0.82 + severity * 0.32 + sin(time * 5.4 + float(id % 11)) * 0.024)

func _hit_spark_profile_family(label: String, impact_family: String) -> String:
    var projectile_family := _player_projectile_family(label)
    if projectile_family != "generic":
        return projectile_family
    match impact_family:
        "explosive":
            return "rocket"
        "magic":
            return "laser"
        "poison":
            return "poison"
        "void":
            return "juggernaut"
        "physical":
            return "duelist"
        _:
            return "generic"

func _hit_spark_source_profile_node_name(profile_family: String) -> String:
    match profile_family:
        "rocket":
            return "HitSparkProfileRocketBurst"
        "artillery":
            return "HitSparkProfileSoulPierce"
        "duelist":
            return "HitSparkProfileDuelistCut"
        "laser":
            return "HitSparkProfileHexcoreBurn"
        "feather":
            return "HitSparkProfileFeatherPin"
        "poison":
            return "HitSparkProfilePoisonBloom"
        "comet":
            return "HitSparkProfileStarCollapse"
        "juggernaut":
            return "HitSparkProfileRealmCrush"
        _:
            return "HitSparkProfileGeneric"

func _hit_spark_resolution_node_name(resolution_family: String) -> String:
    match resolution_family:
        "rocket":
            return "HitSparkResolutionRocketCrater"
        "artillery":
            return "HitSparkResolutionSoulPierceLine"
        "duelist":
            return "HitSparkResolutionDuelistCutMark"
        "laser":
            return "HitSparkResolutionHexcoreBurnSeal"
        "feather":
            return "HitSparkResolutionFeatherPinFan"
        "poison":
            return "HitSparkResolutionPoisonBloomPool"
        "comet":
            return "HitSparkResolutionStarCollapseWell"
        "juggernaut":
            return "HitSparkResolutionRealmCrushSeal"
        _:
            return "HitSparkResolutionGeneric"

func _add_hit_spark_source_profile(
        model: Node3D,
        impact_family: String,
        label: String,
        priority: bool,
        spark_mat: Material,
        hot_mat: Material,
        dark_mat: Material,
        gold_mat: Material
) -> void:
    if model.get_node_or_null("HitSparkSourceProfile") != null:
        return
    var profile_family := _hit_spark_profile_family(label, impact_family)
    var detail_name := _hit_spark_source_profile_node_name(profile_family)
    var profile := Node3D.new()
    profile.name = "HitSparkSourceProfile"
    profile.set_meta("label", label)
    profile.set_meta("impact_family", impact_family)
    profile.set_meta("profile_family", profile_family)
    profile.set_meta("profile_role", _player_projectile_role(profile_family))
    profile.set_meta("source_champion", _player_projectile_source_champion(label))
    profile.set_meta("detail_node", detail_name)
    model.add_child(profile)

    var y := 0.118
    var outer := _add_cylinder_segments(profile, 0.72 if not priority else 0.94, 0.010, 8, spark_mat, Vector3(0, y, 0), Vector3(0, 22.5, 0))
    outer.name = "HitSparkSourceProfileRing"
    var class_mark := _add_box(profile, Vector3(0.66 if not priority else 0.82, 0.012, 0.052), gold_mat, Vector3(0, y + 0.030, -0.42), Vector3(0, 18, 0))
    class_mark.name = "HitSparkSourceClassMark"

    var detail := Node3D.new()
    detail.name = detail_name
    profile.add_child(detail)
    match profile_family:
        "rocket":
            _add_cylinder_segments(detail, 0.40 if not priority else 0.54, 0.010, 8, gold_mat, Vector3(0, y + 0.052, 0), Vector3(0, 22.5, 0))
            for i in range(5 if priority else 4):
                var angle := TAU * float(i) / float(5 if priority else 4)
                _add_tapered_cylinder(detail, 0.040 if not priority else 0.052, 0.006, 0.36 if not priority else 0.48, 6, hot_mat, Vector3(cos(angle) * 0.34, y + 0.080, sin(angle) * 0.34), Vector3(70, -rad_to_deg(angle), 0))
        "artillery":
            _add_box(detail, Vector3(0.070, 0.012, 0.92 if not priority else 1.12), hot_mat, Vector3(0, y + 0.070, 0.18))
            _add_cylinder_segments(detail, 0.34 if not priority else 0.44, 0.010, 24, spark_mat, Vector3(0, y + 0.090, 0.54), Vector3(90, 0, 0))
            _add_sphere(detail, 0.040 if not priority else 0.054, hot_mat, Vector3(0, y + 0.112, 0.54))
        "duelist":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(0.052, 0.012, 0.76 if not priority else 0.94), hot_mat, Vector3(side * 0.12, y + 0.072, 0), Vector3(0, side * 32.0, side * 18.0))
            _add_box(detail, Vector3(0.72, 0.010, 0.044), spark_mat, Vector3(0, y + 0.094, -0.30), Vector3(0, -18, 0))
        "laser":
            _add_cylinder_segments(detail, 0.38 if not priority else 0.48, 0.010, 6, hot_mat, Vector3(0, y + 0.070, 0), Vector3(0, 30, 0))
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_box(detail, Vector3(0.034, 0.010, 0.52 if not priority else 0.68), spark_mat, Vector3(cos(angle) * 0.28, y + 0.092, sin(angle) * 0.28), Vector3(0, -rad_to_deg(angle), 0))
            _add_sphere(detail, 0.042 if not priority else 0.058, hot_mat, Vector3(0, y + 0.116, 0))
        "feather":
            for i in range(5):
                var offset := float(i) - 2.0
                _add_box(detail, Vector3(0.040, 0.012, 0.58 - abs(offset) * 0.045), hot_mat, Vector3(offset * 0.088, y + 0.074, -0.04 + abs(offset) * 0.034), Vector3(0, offset * 12.0, offset * 10.0))
            _add_box(detail, Vector3(0.62, 0.010, 0.040), gold_mat, Vector3(0, y + 0.096, 0.32))
        "poison":
            _add_sphere(detail, 0.20 if not priority else 0.26, hot_mat, Vector3(0, y + 0.112, 0))
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_sphere(detail, 0.032 if not priority else 0.040, spark_mat, Vector3(cos(angle) * 0.34, y + 0.078, sin(angle) * 0.34))
            _add_cylinder_segments(detail, 0.34 if not priority else 0.44, 0.010, 5, spark_mat, Vector3(0, y + 0.066, 0), Vector3(0, 18, 0))
        "comet":
            _add_cylinder_segments(detail, 0.42 if not priority else 0.54, 0.010, 32, spark_mat, Vector3(0, y + 0.070, 0), Vector3(90, 0, 0))
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_sphere(detail, 0.038 if not priority else 0.052, hot_mat, Vector3(cos(angle) * 0.32, y + 0.098, sin(angle) * 0.32))
            _add_box(detail, Vector3(0.046, 0.010, 0.74 if not priority else 0.96), gold_mat, Vector3(0, y + 0.090, 0), Vector3(0, 36, 0))
        "juggernaut":
            _add_cylinder_segments(detail, 0.44 if not priority else 0.58, 0.010, 8, dark_mat, Vector3(0, y + 0.060, 0), Vector3(0, 22.5, 0))
            _add_box(detail, Vector3(0.16, 0.014, 0.76 if not priority else 0.98), hot_mat, Vector3(0.04, y + 0.088, -0.04), Vector3(0, -24, 0))
            _add_box(detail, Vector3(0.64 if not priority else 0.82, 0.016, 0.16), gold_mat, Vector3(0.34, y + 0.112, 0.28), Vector3(0, -24, 0))
        _:
            _add_cylinder_segments(detail, 0.34 if not priority else 0.44, 0.010, 6, hot_mat, Vector3(0, y + 0.074, 0), Vector3(0, 30, 0))

func _add_hit_spark_resolution_profile(
        model: Node3D,
        impact_family: String,
        label: String,
        priority: bool,
        spark_mat: Material,
        hot_mat: Material,
        dark_mat: Material,
        gold_mat: Material
) -> void:
    if model.get_node_or_null("HitSparkResolutionProfile") != null:
        return
    var resolution_family := _hit_spark_profile_family(label, impact_family)
    var detail_name := _hit_spark_resolution_node_name(resolution_family)
    var profile := Node3D.new()
    profile.name = "HitSparkResolutionProfile"
    profile.set_meta("label", label)
    profile.set_meta("impact_family", impact_family)
    profile.set_meta("resolution_family", resolution_family)
    profile.set_meta("source_champion", _player_projectile_source_champion(label))
    profile.set_meta("detail_node", detail_name)
    model.add_child(profile)

    var y := 0.106
    var floor_seal := Node3D.new()
    floor_seal.name = "HitSparkResolutionFloorSeal"
    profile.add_child(floor_seal)
    _add_cylinder_segments(floor_seal, 0.82 if not priority else 1.02, 0.008, 8, dark_mat, Vector3(0, y, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(floor_seal, 0.58 if not priority else 0.74, 0.008, 24, spark_mat, Vector3(0, y + 0.014, 0))
    for tick in range(8):
        var tick_angle := TAU * float(tick) / 8.0
        _add_box(floor_seal, Vector3(0.050 if not priority else 0.066, 0.008, 0.30 if not priority else 0.38), gold_mat, Vector3(cos(tick_angle) * (0.68 if not priority else 0.86), y + 0.032, sin(tick_angle) * (0.68 if not priority else 0.86)), Vector3(0, -rad_to_deg(tick_angle), 0))

    var core := _add_sphere(profile, 0.050 if not priority else 0.070, hot_mat, Vector3(0, y + 0.072, 0))
    core.name = "HitSparkResolutionCore"

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("resolution_family", resolution_family)
    profile.add_child(detail)
    match resolution_family:
        "rocket":
            _add_cylinder_segments(detail, 0.42 if not priority else 0.58, 0.010, 8, gold_mat, Vector3(0, y + 0.056, 0), Vector3(0, 22.5, 0))
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_tapered_cylinder(detail, 0.042 if not priority else 0.052, 0.006, 0.42 if not priority else 0.54, 6, hot_mat, Vector3(cos(angle) * 0.36, y + 0.088, sin(angle) * 0.36), Vector3(68, -rad_to_deg(angle), 0))
        "artillery":
            _add_box(detail, Vector3(0.100 if not priority else 0.130, 0.010, 1.12 if not priority else 1.36), hot_mat, Vector3(0, y + 0.076, 0.34))
            _add_box(detail, Vector3(0.84 if not priority else 1.04, 0.010, 0.052), gold_mat, Vector3(0, y + 0.096, -0.22))
            _add_cylinder_segments(detail, 0.34 if not priority else 0.44, 0.008, 24, spark_mat, Vector3(0, y + 0.092, 0.62), Vector3(90, 0, 0))
        "duelist":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(0.064 if not priority else 0.080, 0.012, 0.98 if not priority else 1.20), hot_mat, Vector3(side * 0.13, y + 0.076, 0.02), Vector3(0, side * 34.0, side * 18.0))
            _add_box(detail, Vector3(0.74 if not priority else 0.94, 0.010, 0.050), spark_mat, Vector3(0, y + 0.098, -0.34), Vector3(0, -18, 0))
        "laser":
            _add_cylinder_segments(detail, 0.46 if not priority else 0.58, 0.010, 6, hot_mat, Vector3(0, y + 0.070, 0), Vector3(0, 30, 0))
            for spoke in range(6):
                var spoke_angle := TAU * float(spoke) / 6.0
                _add_box(detail, Vector3(0.038, 0.010, 0.58 if not priority else 0.74), spark_mat, Vector3(cos(spoke_angle) * 0.30, y + 0.094, sin(spoke_angle) * 0.30), Vector3(0, -rad_to_deg(spoke_angle), 0))
        "feather":
            for i in range(7):
                var offset := float(i) - 3.0
                _add_box(detail, Vector3(0.046, 0.012, 0.70 - abs(offset) * 0.050), hot_mat, Vector3(offset * 0.094, y + 0.076, -0.08 + abs(offset) * 0.038), Vector3(0, offset * 11.0, offset * 10.0))
            _add_cylinder_segments(detail, 0.40 if not priority else 0.52, 0.008, 5, spark_mat, Vector3(0, y + 0.092, -0.08), Vector3(0, 18, 0))
        "poison":
            _add_cylinder_segments(detail, 0.50 if not priority else 0.66, 0.008, 18, spark_mat, Vector3(0, y + 0.064, 0))
            for spore in range(7):
                var spore_angle := TAU * float(spore) / 7.0
                _add_sphere(detail, 0.034 if not priority else 0.044, hot_mat, Vector3(cos(spore_angle) * 0.42, y + 0.100, sin(spore_angle) * 0.32))
            _add_sphere(detail, 0.105 if not priority else 0.140, hot_mat, Vector3(0, y + 0.126, 0))
        "comet":
            _add_cylinder_segments(detail, 0.62 if not priority else 0.82, 0.008, 40, spark_mat, Vector3(0, y + 0.062, 0), Vector3(0, 9, 0))
            for star in range(6):
                var star_angle := TAU * float(star) / 6.0
                _add_sphere(detail, 0.040 if not priority else 0.052, hot_mat, Vector3(cos(star_angle) * 0.48, y + 0.100, sin(star_angle) * 0.36))
            _add_box(detail, Vector3(0.052, 0.010, 1.04 if not priority else 1.34), gold_mat, Vector3(0, y + 0.090, 0), Vector3(0, 36, 0))
        "juggernaut":
            _add_cylinder_segments(detail, 0.52 if not priority else 0.68, 0.010, 8, dark_mat, Vector3(0, y + 0.064, 0), Vector3(0, 22.5, 0))
            _add_box(detail, Vector3(0.20, 0.014, 0.94 if not priority else 1.20), hot_mat, Vector3(0.10, y + 0.092, -0.04), Vector3(0, -24, 0))
            _add_box(detail, Vector3(0.76 if not priority else 0.98, 0.016, 0.20), gold_mat, Vector3(0.42, y + 0.118, 0.34), Vector3(0, -24, 0))
            for chain in range(4):
                var chain_angle := TAU * float(chain) / 4.0 + PI * 0.25
                _add_box(detail, Vector3(0.24, 0.010, 0.050), dark_mat, Vector3(cos(chain_angle) * 0.46, y + 0.100, sin(chain_angle) * 0.34), Vector3(0, -rad_to_deg(chain_angle), 0))
        _:
            _add_box(detail, Vector3(0.72 if not priority else 0.92, 0.010, 0.056), hot_mat, Vector3(0, y + 0.078, 0), Vector3(0, 28, 0))
            _add_box(detail, Vector3(0.056, 0.010, 0.72 if not priority else 0.92), spark_mat, Vector3(0, y + 0.092, 0), Vector3(0, -28, 0))

func _hit_spark_resolution_spin(resolution_family: String) -> float:
    match resolution_family:
        "rocket", "duelist", "poison":
            return 0.052
        "comet", "feather":
            return -0.042
        "juggernaut":
            return 0.018
        "laser", "artillery":
            return -0.026
        _:
            return 0.030

func _hit_spark_resolution_pulse(resolution_family: String) -> float:
    match resolution_family:
        "rocket", "duelist":
            return 6.4
        "poison":
            return 4.6
        "juggernaut":
            return 2.6
        "comet":
            return 3.2
        _:
            return 4.0

func _add_hit_spark_material_shards(model: Node3D, family: String, label: String, priority: bool, dense_lod: bool, spark_mat: Material, hot_mat: Material, dark_mat: Material, gold_mat: Material, hot: Color) -> void:
    var shock := Node3D.new()
    shock.name = "HitSparkDirectionalShock"
    shock.set_meta("family", family)
    shock.set_meta("label", label)
    model.add_child(shock)
    var shock_len := 1.02 if not priority else 1.34
    if family == "explosive":
        shock_len += 0.18
    elif family == "magic":
        shock_len += 0.08
    var nose := _add_box(shock, Vector3(0.150 if not priority else 0.190, 0.010, shock_len), hot_mat, Vector3(0, 0.122, 0.28))
    nose.name = "HitSparkDirectionalShockCore"
    if not dense_lod:
        for side in [-1.0, 1.0]:
            var wing := _add_box(shock, Vector3(0.090 if not priority else 0.120, 0.010, shock_len * 0.58), spark_mat, Vector3(side * 0.22, 0.116, 0.08), Vector3(0, side * 24.0, 0))
            wing.name = "HitSparkDirectionalShockWing"

    var shard_rig := Node3D.new()
    shard_rig.name = "HitSparkMaterialShardRig"
    shard_rig.set_meta("family", family)
    shard_rig.set_meta("label", label)
    model.add_child(shard_rig)
    var shard_count := 2 if dense_lod else 5 if not priority else 7
    if not dense_lod:
        match family:
            "explosive":
                shard_count += 2
            "magic", "void":
                shard_count += 1
            "poison":
                shard_count += 1
            _:
                pass
    for i in range(shard_count):
        var angle := TAU * float(i) / float(shard_count) + (0.16 if i % 2 == 0 else -0.10)
        var radial := 0.34 + float(i % 3) * 0.055
        var shard_pos := Vector3(cos(angle) * radial, 0.140 + float(i % 2) * 0.026, sin(angle) * radial)
        var shard_rot := Vector3(58.0 + float(i % 3) * 9.0, -rad_to_deg(angle), -18.0 + float(i % 5) * 9.0)
        var shard: MeshInstance3D = null
        match family:
            "explosive":
                shard = _add_tapered_cylinder(shard_rig, 0.052 if not priority else 0.066, 0.006, 0.34 if not priority else 0.44, 6, hot_mat if i % 2 == 0 else gold_mat, shard_pos, shard_rot)
                if not dense_lod and i % 3 == 0:
                    var ember := _add_sphere(shard_rig, 0.030 if not priority else 0.040, gold_mat, shard_pos + Vector3(0, 0.034, 0))
                    ember.name = "HitSparkGoldEmber%d" % i
            "magic":
                shard = _add_box(shard_rig, Vector3(0.100, 0.016, 0.300 if not priority else 0.390), hot_mat if i % 2 == 0 else spark_mat, shard_pos, shard_rot)
                if not dense_lod and i % 2 == 0:
                    var facet := _add_cylinder_segments(shard_rig, 0.060, 0.008, 6, spark_mat, shard_pos + Vector3(0, 0.032, 0), Vector3(0, 30, 0))
                    facet.name = "HitSparkHexFacet%d" % i
            "poison":
                shard = _add_sphere(shard_rig, 0.038 if not priority else 0.046, hot_mat, shard_pos)
                if not dense_lod and i % 2 == 1:
                    var trail := _add_tapered_cylinder(shard_rig, 0.032, 0.004, 0.260, 6, spark_mat, shard_pos + Vector3(0, -0.004, 0), shard_rot)
                    trail.name = "HitSparkPoisonTrail%d" % i
            "void":
                shard = _add_box(shard_rig, Vector3(0.080, 0.016, 0.360 if not priority else 0.480), dark_mat if i % 2 == 0 else spark_mat, shard_pos, shard_rot)
                if not dense_lod and i % 3 == 1:
                    var crack := _add_box(shard_rig, Vector3(0.046, 0.012, 0.260), hot_mat, shard_pos + Vector3(0, 0.026, 0), Vector3(0, -rad_to_deg(angle) + 42.0, 0))
                    crack.name = "HitSparkVoidCrack%d" % i
            _:
                shard = _add_box(shard_rig, Vector3(0.086, 0.014, 0.320), hot_mat, shard_pos, shard_rot)
        if shard != null:
            shard.name = "HitSparkMaterialShard%d" % i
    if family == "magic" and not dense_lod:
        var magic_core := _add_crystal(shard_rig, 0.050, 0.240, hot, Vector3(0, 0.180, 0), Vector3(0, 30, 0))
        magic_core.name = "HitSparkMagicCoreShard"

func _hit_spark_vfx_offset(family: String, label: String) -> Vector3:
    match family:
        "magic":
            return Vector3(0.0, 0.75, 0.0)
        "poison":
            return Vector3(0.50, 0.75, 0.0)
        "void":
            return Vector3(0.75, 0.50, 0.0)
        "explosive":
            return Vector3(0.75, 0.75, 0.0) if label == "death_rocket" else Vector3(0.50, 0.50, 0.0)
        _:
            return Vector3(0.25, 0.25, 0.0)

func _sync_hit_spark_alpha(node: Node, base_color: Color, alpha_scale: float) -> void:
    for child in node.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.material_override is StandardMaterial3D:
                var mat := mesh_instance.material_override as StandardMaterial3D
                var color := mat.albedo_color
                color.a = maxf(0.0, minf(color.a, base_color.a + 0.30) * alpha_scale)
                mat.albedo_color = color
                if mat.emission_enabled:
                    mat.emission = Color(color.r, color.g, color.b)
        _sync_hit_spark_alpha(child, base_color, alpha_scale)

func _create_enemy_death_burst_model(kind: String, elite: bool, boss: bool, color_value) -> Node3D:
    var model := Node3D.new()
    model.set_meta("kind", kind)
    model.set_meta("elite", elite)
    model.set_meta("boss", boss)
    var color := Color(0.72, 0.20, 1.0, 0.42)
    if color_value is Color:
        color = color_value
    var hot := color.lightened(0.20)
    var dark := Color(0.018, 0.010, 0.035, 0.50)
    var ring_segments := 8 if kind == "rift_crystal" or kind == "boss_cho" else 5
    if kind == "void_eye" or kind == "boss_velkoz":
        ring_segments = 24
    elif boss:
        ring_segments = 10
    var glow_mat := _mat("death_burst_glow_" + kind, Color(color.r, color.g, color.b, 0.40), 1.05, true, true)
    var hot_mat := _mat("death_burst_hot_" + kind, Color(hot.r, hot.g, hot.b, 0.62), 1.24, true, true)
    var dark_mat := _mat("death_burst_dark_" + kind, dark, 0.10, true, true)
    var gold_mat := _mat("death_burst_gold_" + kind, Color(1.0, 0.78, 0.24, 0.46), 0.86, true, true)

    var signature := Node3D.new()
    signature.name = "EnemyDeathBurstSignature"
    signature.set_meta("kind", kind)
    model.add_child(signature)
    _add_cylinder_segments(signature, 1.04, 0.014, ring_segments, glow_mat, Vector3(0, 0.076, 0), Vector3(0, 22.5 if ring_segments == 8 else 30, 0))
    _add_cylinder_segments(signature, 0.58, 0.012, 6, dark_mat, Vector3(0, 0.090, 0), Vector3(0, 30, 0))
    var core := _add_sphere(signature, 0.110 if not boss else 0.150, hot_mat, Vector3(0, 0.170, 0))
    core.name = "EnemyDeathBurstCore"
    var decal_path := _vfx_decal_texture_path()
    if decal_path != "":
        var decal_tint := Color(color.r, color.g, color.b, 0.42 if not boss else 0.52)
        var decal_mat := _vfx_decal_mat("enemy_death_burst_decal_" + kind, decal_path, decal_tint, 1.12, Vector3(0.25, 0.25, 1.0), _enemy_death_burst_vfx_offset(kind))
        var decal := _add_textured_plane(signature, Vector2(1.86 if not boss else 2.26, 1.86 if not boss else 2.26), decal_mat, Vector3(0, 0.106, 0))
        decal.name = "EnemyDeathBurstVfxDecal"

    var shard_rig := Node3D.new()
    shard_rig.name = "EnemyDeathShardRig"
    shard_rig.set_meta("kind", kind)
    model.add_child(shard_rig)
    var shard_count := 14 if boss else 10 if elite else 7
    var shard_len := 0.46 if not boss else 0.68
    for i in range(shard_count):
        var angle := TAU * float(i) / float(shard_count)
        var radial := 0.44 + float(i % 3) * 0.10
        var shard_pos := Vector3(cos(angle) * radial, 0.152 + float(i % 2) * 0.024, sin(angle) * radial)
        var shard := _add_tapered_cylinder(shard_rig, 0.050 if not boss else 0.066, 0.006, shard_len, 6, hot_mat if i % 3 == 0 else glow_mat, shard_pos, Vector3(70, -rad_to_deg(angle), 0))
        shard.name = "EnemyDeathShard%d" % i
    match kind:
        "rift_crystal":
            for crystal in range(4):
                var crystal_angle := TAU * float(crystal) / 4.0 + PI * 0.25
                _add_crystal(shard_rig, 0.070, 0.34, hot, Vector3(cos(crystal_angle) * 0.34, 0.150, sin(crystal_angle) * 0.34), Vector3(0, -rad_to_deg(crystal_angle), 0))
        "void_eye", "boss_velkoz":
            _add_cylinder_segments(shard_rig, 0.72, 0.012, 24, hot_mat, Vector3(0, 0.182, 0), Vector3(90, 0, 0))
            _add_box(shard_rig, Vector3(1.00, 0.016, 0.070), dark_mat, Vector3(0, 0.194, 0))
        "burrower", "boss_reksai":
            for spike in range(4):
                var spike_angle := TAU * float(spike) / 4.0 + PI * 0.12
                _add_box(shard_rig, Vector3(0.12, 0.040, 0.82), hot_mat, Vector3(cos(spike_angle) * 0.42, 0.160, sin(spike_angle) * 0.42), Vector3(0, -rad_to_deg(spike_angle), 38))
        "boss_belveth":
            for side in [-1.0, 1.0]:
                _add_box(shard_rig, Vector3(0.16, 0.035, 1.08), glow_mat, Vector3(side * 0.54, 0.172, -0.08), Vector3(0, side * 12.0, side * 40.0))
        _:
            pass

    if elite or boss:
        var crown := Node3D.new()
        crown.name = "EnemyDeathRewardCrown"
        crown.set_meta("boss", boss)
        model.add_child(crown)
        _add_cylinder_segments(crown, 0.84 if not boss else 1.08, 0.014, 6, gold_mat, Vector3(0, 0.170, 0), Vector3(0, 30, 0))
        _add_cylinder_segments(crown, 0.54 if not boss else 0.72, 0.010, 24, glow_mat, Vector3(0, 0.192, 0))
        var pip_count := 8 if boss else 6
        for i in range(pip_count):
            var pip_angle := TAU * float(i) / float(pip_count)
            _add_sphere(crown, 0.040 if not boss else 0.052, gold_mat, Vector3(cos(pip_angle) * (0.72 if boss else 0.58), 0.230 + float(i % 2) * 0.030, sin(pip_angle) * (0.72 if boss else 0.58)))
        _add_enemy_death_premium_reward_relic(model, kind, elite, boss, hot, glow_mat, hot_mat, dark_mat, gold_mat)
    _add_enemy_death_afterimage(model, kind, elite, boss, glow_mat, hot_mat, dark_mat, gold_mat, hot)
    return model

func _add_enemy_death_premium_reward_relic(model: Node3D, kind: String, elite: bool, boss: bool, hot: Color, glow_mat: Material, hot_mat: Material, dark_mat: Material, gold_mat: Material) -> void:
    if not elite and not boss:
        return
    if model.get_node_or_null("EnemyDeathPremiumRewardRelic") != null:
        return

    var relic := Node3D.new()
    relic.name = "EnemyDeathPremiumRewardRelic"
    relic.set_meta("kind", kind)
    relic.set_meta("elite", elite)
    relic.set_meta("boss", boss)
    relic.set_meta("reward_grade", "boss_reward_relic" if boss else "elite_reward_relic")
    var detail_name := _enemy_death_reward_relic_detail_name(kind, boss)
    relic.set_meta("detail_node", detail_name)
    relic.set_meta("combat_visual_channel", "high_value_death_reward")
    model.add_child(relic)

    var scale_bonus := 1.18 if boss else 1.0
    var base_y := 0.236 if not boss else 0.276
    var ring_segments := 10 if boss else 8
    var relic_signal_node := Node3D.new()
    relic_signal_node.name = "EnemyDeathRewardRelicSignal"
    relic.add_child(relic_signal_node)
    _add_cylinder_segments(relic_signal_node, 0.42 * scale_bonus, 0.010, ring_segments, gold_mat, Vector3(0, base_y, 0), Vector3(0, 18 if boss else 22.5, 0))
    _add_cylinder_segments(relic_signal_node, 0.28 * scale_bonus, 0.008, 24, glow_mat, Vector3(0, base_y + 0.018, 0))

    var core := _add_crystal(relic, 0.070 * scale_bonus, 0.330 * scale_bonus, hot.lightened(0.08), Vector3(0, base_y + 0.102 * scale_bonus, 0), Vector3(0, 45, 0))
    core.name = "EnemyDeathRewardRelicCore"
    var ring := _add_cylinder_segments(relic, 0.30 * scale_bonus, 0.012, ring_segments, gold_mat, Vector3(0, base_y + 0.120 * scale_bonus, 0), Vector3(90, 0, 0))
    ring.name = "EnemyDeathRewardRelicRing"

    var pips := Node3D.new()
    pips.name = "EnemyDeathRewardRelicPips"
    relic.add_child(pips)
    var pip_count := 8 if boss else 6
    for i in range(pip_count):
        var pip_angle := TAU * float(i) / float(pip_count)
        var pip_radius := 0.36 * scale_bonus
        var pip_pos := Vector3(cos(pip_angle) * pip_radius, base_y + 0.092 * scale_bonus + float(i % 2) * 0.020, sin(pip_angle) * pip_radius)
        var pip := _add_sphere(pips, 0.026 * scale_bonus, gold_mat if i % 2 == 0 else hot_mat, pip_pos)
        pip.name = "EnemyDeathRewardRelicPip%d" % i

    var detail: Node3D = null
    match kind:
        "void_eye", "boss_velkoz":
            detail = _add_cylinder_segments(relic, 0.205 * scale_bonus, 0.010, 24, hot_mat, Vector3(0, base_y + 0.172 * scale_bonus, 0), Vector3(90, 0, 0))
            detail.name = detail_name
            _add_box(relic, Vector3(0.56 * scale_bonus, 0.010, 0.042 * scale_bonus), glow_mat, Vector3(0, base_y + 0.188 * scale_bonus, 0), Vector3(0, -18, 0))
            _add_box(relic, Vector3(0.42 * scale_bonus, 0.012, 0.034 * scale_bonus), dark_mat, Vector3(0, base_y + 0.206 * scale_bonus, -0.020 * scale_bonus), Vector3(0, 18, 0))
            _add_sphere(relic, 0.046 * scale_bonus, dark_mat, Vector3(0, base_y + 0.192 * scale_bonus, 0))
        "carapace", "boss_cho":
            detail = _add_cylinder_segments(relic, 0.230 * scale_bonus, 0.012, 5, dark_mat, Vector3(0, base_y + 0.168 * scale_bonus, 0), Vector3(0, 18, 0))
            detail.name = detail_name
            for tooth_index in range(5):
                var tooth_angle := TAU * float(tooth_index) / 5.0 + PI * 0.10
                var tooth := _add_tapered_cylinder(relic, 0.032 * scale_bonus, 0.008 * scale_bonus, 0.220 * scale_bonus, 5, hot_mat, Vector3(cos(tooth_angle) * 0.210 * scale_bonus, base_y + 0.200 * scale_bonus, sin(tooth_angle) * 0.210 * scale_bonus), Vector3(70, 0, -rad_to_deg(tooth_angle)))
                tooth.name = "EnemyDeathRewardMawTooth%d" % tooth_index
        "burrower", "boss_reksai":
            detail = Node3D.new()
            detail.name = detail_name
            relic.add_child(detail)
            for spike_index in range(4):
                var spike_angle := TAU * float(spike_index) / 4.0 + PI * 0.125
                var spike := _add_box(detail, Vector3(0.055 * scale_bonus, 0.016, 0.360 * scale_bonus), hot_mat, Vector3(cos(spike_angle) * 0.230 * scale_bonus, base_y + 0.178 * scale_bonus, sin(spike_angle) * 0.230 * scale_bonus), Vector3(0, -rad_to_deg(spike_angle), 28))
                spike.name = "EnemyDeathRewardBurrowSpike%d" % spike_index
        "boss_belveth":
            detail = Node3D.new()
            detail.name = detail_name
            relic.add_child(detail)
            _add_box(detail, Vector3(0.120 * scale_bonus, 0.016, 0.540 * scale_bonus), glow_mat, Vector3(-0.160 * scale_bonus, base_y + 0.186 * scale_bonus, -0.020), Vector3(0, 20, 42))
            _add_box(detail, Vector3(0.120 * scale_bonus, 0.016, 0.540 * scale_bonus), glow_mat, Vector3(0.160 * scale_bonus, base_y + 0.186 * scale_bonus, -0.020), Vector3(0, -20, -42))
            _add_sphere(detail, 0.060 * scale_bonus, hot_mat, Vector3(0, base_y + 0.210 * scale_bonus, 0.110 * scale_bonus))
        "rift_crystal":
            detail = _add_crystal(relic, 0.058 * scale_bonus, 0.260 * scale_bonus, hot.lightened(0.16), Vector3(0, base_y + 0.188 * scale_bonus, 0), Vector3(0, 0, 0))
            detail.name = detail_name
            _add_cylinder_segments(relic, 0.220 * scale_bonus, 0.010, 6, gold_mat, Vector3(0, base_y + 0.166 * scale_bonus, 0), Vector3(0, 30, 0))
        _:
            detail = _add_cylinder_segments(relic, 0.210 * scale_bonus, 0.010, 6, glow_mat, Vector3(0, base_y + 0.166 * scale_bonus, 0), Vector3(0, 30, 0))
            detail.name = detail_name
            for claw_index in range(3):
                var claw_angle := TAU * float(claw_index) / 3.0 + PI * 0.16
                var claw := _add_tapered_cylinder(relic, 0.026 * scale_bonus, 0.006 * scale_bonus, 0.190 * scale_bonus, 5, hot_mat, Vector3(cos(claw_angle) * 0.170 * scale_bonus, base_y + 0.195 * scale_bonus, sin(claw_angle) * 0.170 * scale_bonus), Vector3(68, 0, -rad_to_deg(claw_angle)))
                claw.name = "EnemyDeathRewardVoidClaw%d" % claw_index

func _enemy_death_reward_relic_detail_name(kind: String, boss: bool) -> String:
    match kind:
        "void_eye", "boss_velkoz":
            return "EnemyDeathRewardEyeRelic"
        "carapace", "boss_cho":
            return "EnemyDeathRewardMawRelic"
        "burrower", "boss_reksai":
            return "EnemyDeathRewardBurrowRelic"
        "boss_belveth":
            return "EnemyDeathRewardRoyalRelic"
        "rift_crystal":
            return "EnemyDeathRewardCrystalRelic"
        _:
            return "EnemyDeathRewardBossRelic" if boss else "EnemyDeathRewardVoidRelic"

func _add_enemy_death_afterimage(model: Node3D, kind: String, elite: bool, boss: bool, glow_mat: Material, hot_mat: Material, dark_mat: Material, gold_mat: Material, hot: Color) -> void:
    var afterimage := Node3D.new()
    afterimage.name = "EnemyDeathAfterimageRig"
    afterimage.set_meta("kind", kind)
    afterimage.set_meta("elite", elite)
    afterimage.set_meta("boss", boss)
    model.add_child(afterimage)

    var ring_segments := 8 if elite or boss or kind == "rift_crystal" else 6
    if kind == "void_eye" or kind == "boss_velkoz":
        ring_segments = 24
    var outer := _add_cylinder_segments(afterimage, 0.72 if not boss else 0.96, 0.010, ring_segments, glow_mat, Vector3(0, 0.116, 0), Vector3(0, 22.5 if ring_segments == 8 else 30, 0))
    outer.name = "EnemyDeathAfterimageRing"
    _add_cylinder_segments(afterimage, 0.38 if not boss else 0.54, 0.008, 6, dark_mat, Vector3(0, 0.136, 0), Vector3(0, 30, 0))
    var soul := _add_sphere(afterimage, 0.076 if not boss else 0.105, hot_mat, Vector3(0, 0.190, 0))
    soul.name = "EnemyDeathSoulCore"

    var ember_count := 4 if not elite and not boss else 6 if elite and not boss else 8
    for i in range(ember_count):
        var angle := TAU * float(i) / float(ember_count) + float(i % 2) * 0.17
        var radial := 0.28 + float(i % 3) * 0.082
        var ember_pos := Vector3(cos(angle) * radial, 0.150 + float(i % 2) * 0.034, sin(angle) * radial)
        var ember_rot := Vector3(70.0, -rad_to_deg(angle), -16.0 + float(i % 4) * 10.0)
        var mat := hot_mat if i % 2 == 0 else glow_mat
        if elite and i % 3 == 0:
            mat = gold_mat
        var ember: MeshInstance3D
        if kind == "rift_crystal":
            var crystal := _add_crystal(afterimage, 0.040 if not boss else 0.054, 0.220 if not boss else 0.300, hot, ember_pos, Vector3(0, -rad_to_deg(angle), 0))
            crystal.name = "EnemyDeathEmber%d" % i
            continue
        elif kind == "void_eye" or kind == "boss_velkoz":
            ember = _add_sphere(afterimage, 0.034 if not boss else 0.044, mat, ember_pos)
            if i % 2 == 0:
                var ray := _add_box(afterimage, Vector3(0.048, 0.010, 0.420 if not boss else 0.560), dark_mat, ember_pos + Vector3(0, 0.026, 0), Vector3(0, -rad_to_deg(angle), 0))
                ray.name = "EnemyDeathEyeAfterRay%d" % i
        else:
            ember = _add_tapered_cylinder(afterimage, 0.036 if not boss else 0.050, 0.004, 0.280 if not boss else 0.390, 6, mat, ember_pos, ember_rot)
        ember.name = "EnemyDeathEmber%d" % i

    if boss:
        var boss_echo := Node3D.new()
        boss_echo.name = "EnemyDeathBossEcho"
        afterimage.add_child(boss_echo)
        _add_cylinder_segments(boss_echo, 1.08, 0.012, 10, gold_mat, Vector3(0, 0.172, 0), Vector3(0, 18, 0))
        for i in range(5):
            var spike_angle := TAU * float(i) / 5.0 + PI * 0.10
            var spike := _add_box(boss_echo, Vector3(0.078, 0.014, 0.620), hot_mat, Vector3(cos(spike_angle) * 0.58, 0.210, sin(spike_angle) * 0.58), Vector3(0, -rad_to_deg(spike_angle), 0))
            spike.name = "EnemyDeathBossEchoSpike%d" % i

func _enemy_death_burst_vfx_offset(kind: String) -> Vector3:
    match kind:
        "rift_crystal", "void_eye", "boss_velkoz":
            return Vector3(0.0, 0.50, 0.0)
        "burrower", "boss_reksai":
            return Vector3(0.50, 0.50, 0.0)
        "boss_belveth", "boss_cho":
            return Vector3(0.75, 0.50, 0.0)
        _:
            return Vector3(0.25, 0.50, 0.0)

func _sync_death_burst_alpha(node: Node, base_color: Color, alpha_scale: float) -> void:
    for child in node.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.material_override is StandardMaterial3D:
                var mat := mesh_instance.material_override as StandardMaterial3D
                var color := mat.albedo_color
                color.a = maxf(0.0, minf(color.a, base_color.a + 0.34) * alpha_scale)
                mat.albedo_color = color
                if mat.emission_enabled:
                    mat.emission = Color(color.r, color.g, color.b)
        _sync_death_burst_alpha(child, base_color, alpha_scale)

func _sync_pulses() -> void:
    var alive := {}
    for pulse in get_tree().get_nodes_in_group("survivor_pulses"):
        if not is_instance_valid(pulse):
            continue
        var id := pulse.get_instance_id()
        alive[id] = true
        if not pulse_models.has(id):
            pulse_models[id] = _create_pulse_model(pulse.get("pulse_color"))
            _make_unique_materials(pulse_models[id])
            add_child(pulse_models[id])
        var model: Node3D = pulse_models[id]
        var radius := float(pulse.get("pulse_radius")) * WORLD_SCALE
        var life := float(pulse.get("life"))
        var max_life := maxf(0.01, float(pulse.get("max_life")))
        var t := 1.0 - life / max_life
        model.global_position = _to3d(pulse.global_position, 0.035)
        model.scale = Vector3.ONE * lerpf(0.20, radius, t)
        var family := str(model.get_meta("pulse_family", "generic"))
        var time := Time.get_ticks_msec() / 1000.0
        model.rotation.y = time * _pulse_rotation_speed(family)
        _sync_pulse_impact_signature(model, family, t, time, id)
        _sync_pulse_survival_pressure_silhouette(model, family, t, time, id)
        var color: Color = pulse.get("pulse_color")
        _sync_pulse_material_alpha(model, color, maxf(0.0, 1.0 - t))
    _remove_missing(pulse_models, alive)

func _sync_pulse_impact_signature(model: Node3D, family: String, progress: float, time: float, seed: int) -> void:
    var signature := model.get_node_or_null("PulseImpactSignature") as Node3D
    if signature == null:
        return
    var pulse := 1.0 + sin(time * (4.8 if family == "danger" or family == "rocket" else 3.2) + float(seed % 37)) * 0.030
    var spread := lerpf(0.72, 1.18, progress) * pulse
    signature.scale = Vector3(spread, 1.0, spread)
    signature.rotation.y += 0.030 if family == "rocket" or family == "danger" else -0.018
    var shock_ring := signature.get_node_or_null("PulseImpactShockRing") as Node3D
    if shock_ring != null:
        var ring_scale := lerpf(0.78, 1.32, progress)
        shock_ring.scale = Vector3(ring_scale, 1.0, ring_scale)
        shock_ring.rotation.y -= 0.052
    var core := signature.get_node_or_null("PulseImpactCore") as Node3D
    if core != null:
        core.scale = Vector3.ONE * (1.0 + sin(time * 6.0 + float(seed % 19)) * 0.090)
    var facets := signature.get_node_or_null("PulseImpactFacetRig") as Node3D
    if facets != null:
        facets.rotation.y += 0.046 if family == "danger" or family == "rocket" else -0.030
        var facet_scale := lerpf(0.84, 1.22, progress)
        facets.scale = Vector3(facet_scale, 1.0, facet_scale)

func _sync_pulse_survival_pressure_silhouette(model: Node3D, family: String, progress: float, time: float, seed: int) -> void:
    var silhouette := model.get_node_or_null("PulseSurvivalPressureSilhouette") as Node3D
    if silhouette == null:
        return
    var urgency := 0.0
    match family:
        "danger":
            urgency = 1.0
        "void":
            urgency = 0.72
        "hextech":
            urgency = 0.48
        _:
            urgency = 0.35
    var pulse := 1.0 + sin(time * (3.0 + urgency * 1.4) + float(seed % 29)) * 0.026
    var spread := lerpf(0.92, 1.16 + urgency * 0.08, progress) * pulse
    silhouette.scale = Vector3(spread, 1.0, spread)
    silhouette.rotation.y += (0.034 + urgency * 0.018) if family == "danger" else (-0.020 - urgency * 0.010)
    var needle := silhouette.get_node_or_null("PulsePressureDirectionNeedle") as Node3D
    if needle != null:
        needle.scale = Vector3(1.0, 1.0, lerpf(0.82, 1.20, progress))
    var detail := silhouette.get_node_or_null(str(silhouette.get_meta("detail_node", ""))) as Node3D
    if detail != null:
        detail.position.y = 0.106 + sin(time * (4.2 + urgency) + float(seed % 17)) * 0.010
        detail.scale = Vector3.ONE * (1.0 + sin(time * (3.6 + urgency) + float(seed % 13)) * 0.020)

func _sync_pulse_material_alpha(node: Node, base_color: Color, alpha_scale: float) -> void:
    for child in node.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.material_override is StandardMaterial3D:
                var mat := mesh_instance.material_override as StandardMaterial3D
                var color := base_color
                if mesh_instance.has_meta("pulse_alpha_color") and mesh_instance.get_meta("pulse_alpha_color") is Color:
                    color = mesh_instance.get_meta("pulse_alpha_color")
                var alpha_multiplier := float(mesh_instance.get_meta("pulse_alpha_multiplier", 1.0))
                color.a = maxf(0.0, color.a * alpha_scale * alpha_multiplier)
                mat.albedo_color = color
                if mat.emission_enabled:
                    mat.emission = Color(color.r, color.g, color.b)
        _sync_pulse_material_alpha(child, base_color, alpha_scale)

func _create_player_model(champion: String) -> Node3D:
    var external_model := _create_external_champion_model(champion)
    if external_model != null:
        return external_model

    var model := Node3D.new()
    model.set_meta("champion", champion)
    var style := _champion_style(champion)
    var body: Color = style["body"]
    var accent: Color = style["accent"]
    var hair: Color = style["hair"]
    var scale := float(style.get("scale", 1.0)) * PROCEDURAL_MODEL_SCALE

    _build_humanoid_base(model, champion, body, accent, hair, scale)

    match champion:
        "jinx":
            _add_pigtails(model, hair, scale, 1.35)
            _add_box(model, Vector3(0.28, 0.24, 1.45) * scale, _mat("jinx_rocket_body", Color(0.16, 0.64, 1.0), 0.28, true), Vector3(0.48, 0.95, 0.78) * scale)
            _add_sphere(model, 0.21 * scale, _mat("jinx_rocket_nose", Color(1.0, 0.28, 0.64), 0.70, true), Vector3(0.48, 0.95, 1.56) * scale)
            _add_box(model, Vector3(0.72, 0.06, 0.26) * scale, _mat("jinx_fin", Color(1.0, 0.72, 0.20), 0.20, true), Vector3(0.48, 0.98, 0.18) * scale)
            _add_sphere(model, 0.11 * scale, _mat("jinx_muzzle_glow", Color(1.0, 0.90, 0.24), 1.0, true), Vector3(0.48, 0.95, 1.76) * scale)
            for i in range(3):
                _add_cylinder(model, 0.055 * scale, 1.04 * scale, _mat("jinx_minigun_barrel", Color(0.12, 0.18, 0.22), 0.08, true), Vector3(-0.38 + float(i) * 0.08, 0.82 + float(i % 2) * 0.04, 0.84) * scale, Vector3(90, 0, 0))
            _add_cylinder_segments(model, 0.18 * scale, 0.10 * scale, 16, _mat("jinx_rotary_muzzle", Color(0.24, 0.82, 1.0), 0.65, true), Vector3(-0.30, 0.84, 1.40) * scale, Vector3(90, 0, 0))
        "senna":
            _add_cape(model, Color(0.86, 0.92, 0.86), scale, 1.15)
            _add_box(model, Vector3(0.46, 0.34, 1.90) * scale, _mat("senna_cannon", Color(0.06, 0.14, 0.13), 0.05), Vector3(0.0, 0.92, 0.92) * scale)
            _add_cylinder(model, 0.27 * scale, 0.32 * scale, _mat("senna_muzzle", accent, 0.95, true), Vector3(0.0, 0.92, 1.92) * scale, Vector3(90, 0, 0))
            _add_sphere(model, 0.18 * scale, _mat("senna_soul_orb", accent, 0.95, true), Vector3(-0.55, 1.10, 0.18) * scale)
            _add_box(model, Vector3(0.74, 0.12, 0.26) * scale, _mat("senna_cannon_wing_l", Color(0.78, 0.94, 0.86), 0.22, true), Vector3(-0.44, 0.92, 1.22) * scale, Vector3(0, 0, -12))
            _add_box(model, Vector3(0.74, 0.12, 0.26) * scale, _mat("senna_cannon_wing_r", Color(0.78, 0.94, 0.86), 0.22, true), Vector3(0.44, 0.92, 1.22) * scale, Vector3(0, 0, 12))
            _add_cylinder_segments(model, 0.30 * scale, 0.026 * scale, 24, _mat("senna_soul_gate", Color(accent.r, accent.g, accent.b, 0.46), 1.0, true, true), Vector3(-0.55, 1.10, 0.18) * scale, Vector3(90, 0, 0))
        "samira":
            _add_cape(model, Color(0.58, 0.04, 0.04), scale, 0.96)
            _add_box(model, Vector3(0.16, 0.14, 1.10) * scale, _mat("samira_blade", Color(1.0, 0.76, 0.24), 0.36, true), Vector3(-0.42, 0.88, 0.60) * scale, Vector3(0, 18, -8))
            _add_box(model, Vector3(0.22, 0.16, 0.88) * scale, _mat("samira_gun", Color(0.18, 0.08, 0.05), 0.10), Vector3(0.44, 0.86, 0.54) * scale, Vector3(0, -8, 8))
            _add_box(model, Vector3(0.12, 0.28, 0.42) * scale, _mat("samira_gold_guard", Color(1.0, 0.72, 0.20), 0.28, true), Vector3(-0.42, 0.88, 0.05) * scale)
            _add_cylinder_segments(model, 0.72 * scale, 0.022 * scale, 32, _mat("samira_style_orbit", Color(1.0, 0.34, 0.16, 0.36), 0.92, true, true), Vector3(0, 1.10, 0.04) * scale, Vector3(90, 0, 0))
            _add_box(model, Vector3(0.14, 0.12, 0.92) * scale, _mat("samira_back_blade", Color(0.86, 0.10, 0.10), 0.24, true), Vector3(0.0, 1.08, -0.42) * scale, Vector3(22, 0, 0))
        "viktor":
            _add_box(model, Vector3(0.44, 0.58, 0.20) * scale, _mat("viktor_backpack", Color(0.17, 0.14, 0.28), 0.15), Vector3(0, 1.10, -0.34) * scale)
            _add_cylinder(model, 0.07 * scale, 1.55 * scale, _mat("viktor_staff", accent, 0.95, true), Vector3(0.58, 1.22, 0.32) * scale, Vector3(24, 0, 0))
            _add_sphere(model, 0.20 * scale, _mat("viktor_core", Color(0.92, 0.72, 1.0), 1.25, true), Vector3(0, 1.08, 0.20) * scale)
            _add_claw_arm(model, accent, scale)
            _add_cylinder(model, 0.055 * scale, 1.24 * scale, _mat("viktor_hex_spine", Color(0.58, 0.76, 1.0), 0.80, true), Vector3(0.0, 1.72, -0.26) * scale, Vector3(10, 0, 0))
            for i in range(3):
                _add_sphere(model, 0.075 * scale, _mat("viktor_probe" + str(i), Color(0.72, 0.94, 1.0), 1.10, true), Vector3(-0.34 + float(i) * 0.34, 1.70 + sin(float(i)) * 0.08, -0.42) * scale)
        "xayah":
            _add_feather_wings(model, Color(0.44, 0.06, 0.58), accent, scale)
            for i in range(3):
                var offset := float(i) - 1.0
                _add_box(model, Vector3(0.08, 0.08, 0.72) * scale, _mat("xayah_feather", accent, 0.42, true), Vector3(offset * 0.24, 0.52, 0.86 + abs(offset) * 0.08) * scale, Vector3(0, offset * 12.0, offset * 18.0))
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(0.12, 0.14, 1.28) * scale, _mat("xayah_long_plume" + str(side), Color(1.0, 0.24, 0.70), 0.36, true), Vector3(side * 0.74, 1.02, -0.50) * scale, Vector3(0, side * -18.0, side * 42.0))
        "mordekaiser":
            _add_armor_plates(model, Color(0.08, 0.16, 0.13), accent, scale)
            _add_box(model, Vector3(0.70, 0.45, 0.78) * scale, _mat("morde_hammer_head", Color(0.32, 0.62, 0.44), 0.35, true), Vector3(0.56, 1.02, 1.08) * scale)
            _add_cylinder(model, 0.08 * scale, 1.35 * scale, _mat("morde_hammer", Color(0.10, 0.20, 0.16)), Vector3(0.42, 0.88, 0.56) * scale, Vector3(64, 0, 0))
            _add_sphere(model, 0.18 * scale, _mat("morde_green_soul", accent, 1.0, true), Vector3(0, 1.28, 0.24) * scale)
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(0.18, 0.24, 0.70) * scale, _mat("morde_back_spike" + str(side), Color(0.16, 0.42, 0.30), 0.24, true), Vector3(side * 0.34, 1.62, -0.34) * scale, Vector3(0, side * 14.0, side * 28.0))
            _add_cylinder_segments(model, 0.36 * scale, 0.035 * scale, 8, _mat("morde_hammer_rune", Color(accent.r, accent.g, accent.b, 0.54), 0.95, true, true), Vector3(0.56, 1.02, 1.48) * scale, Vector3(90, 0, 0))
        "teemo":
            _add_sphere(model, 0.13 * scale, _mat("teemo_ear_l", hair), Vector3(-0.32, 1.70, 0.02) * scale)
            _add_sphere(model, 0.13 * scale, _mat("teemo_ear_r", hair), Vector3(0.32, 1.70, 0.02) * scale)
            _add_cylinder(model, 0.43 * scale, 0.18 * scale, _mat("teemo_hat", Color(0.72, 0.48, 0.25), 0.10), Vector3(0, 1.76, 0) * scale)
            _add_box(model, Vector3(0.74, 0.06, 0.10) * scale, _mat("teemo_goggles", Color(0.92, 0.82, 0.48), 0.40, true), Vector3(0, 1.54, 0.25) * scale)
            _add_cylinder(model, 0.05 * scale, 1.02 * scale, _mat("teemo_blowgun", Color(0.46, 0.30, 0.12)), Vector3(0.34, 0.92, 0.68) * scale, Vector3(78, 0, 0))
            _add_mushroom_cluster(model, scale)
            _add_box(model, Vector3(0.48, 0.36, 0.18) * scale, _mat("teemo_backpack", Color(0.32, 0.22, 0.12), 0.06, true), Vector3(0.0, 1.02, -0.48) * scale)
            _add_sphere(model, 0.10 * scale, _mat("teemo_poison_vial", Color(0.58, 1.0, 0.22), 0.90, true), Vector3(-0.28, 1.08, -0.62) * scale)
        "aurelion_sol":
            _add_asol_body(model, accent, scale)
        _:
            _add_box(model, Vector3(0.18, 0.16, 0.90) * scale, _mat("default_weapon", accent, 0.25, true), Vector3(0, 0.90, 0.70) * scale)

    _add_champion_silhouette_polish(model, champion, accent, scale)
    _add_champion_role_readability(model, champion, accent, scale)
    _add_champion_identity_backplate(model, champion, accent, scale)
    _add_champion_presentation(model, champion, accent, scale)
    _add_champion_identity_projection(model, champion, accent, scale)
    _add_champion_fan_signature(model, champion, accent, scale)
    _add_champion_fan_readable_silhouette_rig(model, champion, accent, scale)
    _add_champion_signature_weapon_rig(model, champion, accent, scale)
    _add_champion_premium_body_rig(model, champion, accent, scale)
    _add_champion_painterly_depth_rig(model, champion, accent, scale)
    _add_champion_kit_silhouette(model, champion, accent, scale)
    _add_champion_combat_stance_rig(model, champion, accent, scale)
    _add_champion_archetype_silhouette_rig(model, champion, accent, scale)
    _add_champion_ability_emblems(model, champion, accent, scale)
    _add_champion_mechanic_meter(model, champion, accent, scale)
    _add_champion_combat_loop_readout(model, champion, accent, scale)
    _add_champion_human_focus_plate(model, champion, accent, scale)
    _add_champion_combat_crest(model, champion, accent, scale)
    _add_champion_live_aura(model, champion, accent, scale)
    _add_champion_attack_burst(model, champion, accent, scale)
    _add_champion_signature_cast_rig(model, champion, accent, scale)
    _add_champion_upgrade_routes(model, champion, accent, scale)
    _add_role_route_rings(model, accent, scale)
    _add_player_status_rings(model, champion, accent, scale)
    _add_shadow(model, 0.82 * scale)
    _add_topdown_model_outline(model, champion, 1.085)
    return model

func _create_external_champion_model(champion: String) -> Node3D:
    var packed := _load_external_champion_scene(champion)
    if packed == null:
        return null
    var instance := packed.instantiate()
    if not (instance is Node3D):
        instance.queue_free()
        return null

    var wrapper := Node3D.new()
    wrapper.set_meta("champion", champion)
    wrapper.set_meta("external_model", true)
    instance.name = "ExternalModel"
    var settings := _external_model_settings(champion)
    instance.position = Vector3(
        float(settings.get("x", 0.0)),
        float(settings.get("y", 0.0)),
        float(settings.get("z", 0.0))
    )
    instance.rotation_degrees = Vector3(
        float(settings.get("pitch", 0.0)),
        float(settings.get("yaw", 180.0)),
        float(settings.get("roll", 0.0))
    )
    instance.scale = Vector3.ONE * float(settings.get("scale", _external_model_scale(champion)))
    wrapper.add_child(instance)
    var style := _champion_style(champion)
    var accent: Color = style["accent"]
    _add_champion_identity_backplate(wrapper, champion, accent, 0.95)
    _add_champion_presentation(wrapper, champion, accent, 0.95)
    _add_champion_identity_projection(wrapper, champion, accent, 0.95)
    _add_champion_fan_signature(wrapper, champion, accent, 0.95)
    _add_champion_fan_readable_silhouette_rig(wrapper, champion, accent, 0.95)
    _add_champion_signature_weapon_rig(wrapper, champion, accent, 0.95)
    _add_champion_premium_body_rig(wrapper, champion, accent, 0.95)
    _add_champion_painterly_depth_rig(wrapper, champion, accent, 0.95)
    _add_champion_kit_silhouette(wrapper, champion, accent, 0.95)
    _add_champion_combat_stance_rig(wrapper, champion, accent, 0.95)
    _add_champion_archetype_silhouette_rig(wrapper, champion, accent, 0.95)
    _add_champion_ability_emblems(wrapper, champion, accent, 0.95)
    _add_champion_mechanic_meter(wrapper, champion, accent, 0.95)
    _add_champion_combat_loop_readout(wrapper, champion, accent, 0.95)
    _add_champion_human_focus_plate(wrapper, champion, accent, 0.95)
    _add_champion_combat_crest(wrapper, champion, accent, 0.95)
    _add_champion_live_aura(wrapper, champion, accent, 0.95)
    _add_champion_attack_burst(wrapper, champion, accent, 0.95)
    _add_champion_signature_cast_rig(wrapper, champion, accent, 0.95)
    _add_champion_upgrade_routes(wrapper, champion, accent, 0.95)
    _add_role_route_rings(wrapper, accent, 0.95)
    _add_player_status_rings(wrapper, champion, accent, 0.95)
    _add_cylinder(wrapper, 0.88, 0.035, _mat("external_model_ring_" + champion, Color(accent.r, accent.g, accent.b, 0.20), 0.58, true, true), Vector3(0, 0.045, 0))
    _add_shadow(wrapper, 0.85)
    return wrapper

func _load_external_champion_scene(champion: String) -> PackedScene:
    var candidates := [
        "res://art/champions/models/%s.tscn" % champion,
        "res://art/champions/models/%s.glb" % champion,
        "res://art/champions/models/%s.gltf" % champion
    ]
    for path in candidates:
        if not ResourceLoader.exists(path):
            continue
        var resource := load(path)
        if resource is PackedScene:
            return resource
    return null

func _external_model_scale(champion: String) -> float:
    match champion:
        "teemo":
            return 0.82
        "mordekaiser":
            return 0.72
        "aurelion_sol":
            return 0.58
        _:
            return 0.72

func _load_external_model_config() -> void:
    external_model_config.clear()
    if not FileAccess.file_exists(MODEL_CONFIG_PATH):
        return
    var file := FileAccess.open(MODEL_CONFIG_PATH, FileAccess.READ)
    if file == null:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        external_model_config = parsed

func _external_model_settings(champion: String) -> Dictionary:
    var defaults := {
        "scale": _external_model_scale(champion),
        "yaw": 180.0,
        "pitch": 0.0,
        "roll": 0.0,
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    }
    if external_model_config.has(champion) and external_model_config[champion] is Dictionary:
        for key in external_model_config[champion].keys():
            defaults[key] = external_model_config[champion][key]
    return defaults

func _build_humanoid_base(model: Node3D, key: String, body: Color, accent: Color, hair: Color, scale: float) -> void:
    var skin := Color(0.84, 0.64, 0.50)
    var dark := body.darkened(0.32)
    _add_box(model, Vector3(0.26, 0.62, 0.20) * scale, _mat(key + "_leg_l", dark), Vector3(-0.18, 0.34, 0.00) * scale)
    _add_box(model, Vector3(0.26, 0.62, 0.20) * scale, _mat(key + "_leg_r", dark.lightened(0.08)), Vector3(0.18, 0.34, 0.00) * scale)
    _add_box(model, Vector3(0.32, 0.14, 0.40) * scale, _mat(key + "_boot_l", Color(0.05, 0.04, 0.06)), Vector3(-0.20, 0.07, 0.12) * scale)
    _add_box(model, Vector3(0.32, 0.14, 0.40) * scale, _mat(key + "_boot_r", Color(0.05, 0.04, 0.06)), Vector3(0.20, 0.07, 0.12) * scale)
    _add_capsule(model, 0.36 * scale, 1.18 * scale, _mat(key + "_torso", body, 0.08), Vector3(0, 0.92, 0))
    _add_box(model, Vector3(0.82, 0.20, 0.24) * scale, _mat(key + "_shoulders", body.lightened(0.05)), Vector3(0, 1.28, 0.03) * scale)
    _add_box(model, Vector3(0.70, 0.11, 0.20) * scale, _mat(key + "_chest_trim", accent, 0.45, true), Vector3(0, 1.04, 0.20) * scale)
    _add_box(model, Vector3(0.15, 0.58, 0.16) * scale, _mat(key + "_arm_l", body.darkened(0.18)), Vector3(-0.48, 0.93, 0.10) * scale, Vector3(0, 0, -10))
    _add_box(model, Vector3(0.15, 0.58, 0.16) * scale, _mat(key + "_arm_r", body.lightened(0.06)), Vector3(0.48, 0.93, 0.10) * scale, Vector3(0, 0, 10))
    _add_sphere(model, 0.11 * scale, _mat(key + "_hand_l", skin), Vector3(-0.53, 0.64, 0.18) * scale)
    _add_sphere(model, 0.11 * scale, _mat(key + "_hand_r", skin), Vector3(0.53, 0.64, 0.18) * scale)
    _add_sphere(model, 0.32 * scale, _mat(key + "_head", skin), Vector3(0, 1.58, 0.03) * scale)
    _add_sphere(model, 0.24 * scale, _mat(key + "_hair", hair, 0.06), Vector3(0, 1.74, -0.05) * scale)
    _add_box(model, Vector3(0.10, 0.035, 0.035) * scale, _mat(key + "_eye_l", Color(0.02, 0.02, 0.03)), Vector3(-0.10, 1.58, 0.32) * scale)
    _add_box(model, Vector3(0.10, 0.035, 0.035) * scale, _mat(key + "_eye_r", Color(0.02, 0.02, 0.03)), Vector3(0.10, 1.58, 0.32) * scale)
    _add_cylinder(model, 0.52 * scale, 0.035 * scale, _mat(key + "_base_glow", Color(accent.r, accent.g, accent.b, 0.28), 0.65, true, true), Vector3(0, 0.045, 0))

func _add_champion_identity_backplate(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionIdentityBackplateRig") != null:
        return
    var rig := Node3D.new()
    rig.name = "ChampionIdentityBackplateRig"
    rig.set_meta("champion", champion)
    rig.set_meta("kit_role", _champion_kit_role(champion))
    rig.set_meta("combat_class", _champion_combat_class(champion))
    rig.set_meta("range_band", _champion_range_band(champion))
    rig.set_meta("combat_visual_channel", "champion_readability")
    model.add_child(rig)

    var role_color := _champion_kit_role_color(champion, accent)
    var dark_mat := _mat(champion + "_identity_backplate_dark", Color(0.004, 0.006, 0.014, 0.34), 0.0, true, true)
    var role_mat := _mat(champion + "_identity_backplate_role", Color(role_color.r, role_color.g, role_color.b, 0.26), 0.0, true, true)
    var gold_mat := _mat(champion + "_identity_backplate_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24), 0.0, true, true)
    var motif_mat := _mat(champion + "_identity_backplate_motif", Color(accent.r, accent.g, accent.b, 0.30), 0.0, true, true)
    var y := 0.082 * scale

    var base := _add_cylinder_segments(rig, 1.02 * scale, 0.010 * scale, 8, dark_mat, Vector3(0, y, 0), Vector3(0, 22.5, 0))
    base.name = "ChampionIdentityMatteBackplate"
    var frame := _add_cylinder_segments(rig, 0.82 * scale, 0.008 * scale, 6, role_mat, Vector3(0, y + 0.014 * scale, 0), Vector3(0, 30, 0))
    frame.name = "ChampionIdentityRoleFrame"
    var chevron := _add_box(rig, Vector3(0.120, 0.008, 0.640) * scale, gold_mat, Vector3(0, y + 0.030 * scale, 0.560 * scale))
    chevron.name = "ChampionIdentityFacingChevron"
    for side in [-1.0, 1.0]:
        var wing := _add_box(rig, Vector3(0.090, 0.008, 0.300) * scale, gold_mat, Vector3(side * 0.120 * scale, y + 0.032 * scale, 0.830 * scale), Vector3(0, side * 28.0, 0))
        wing.name = "ChampionIdentityFacingChevronWing"

    var pips := Node3D.new()
    pips.name = "ChampionIdentityRangePips"
    pips.set_meta("range_band", _champion_range_band(champion))
    rig.add_child(pips)
    var pip_count := 2 if _champion_range_band(champion) == "melee" else 4 if _champion_range_band(champion) == "mage" or _champion_range_band(champion) == "summoner" else 3
    for i in range(pip_count):
        var angle := -0.46 + float(i) * (0.92 / maxf(1.0, float(pip_count - 1)))
        var pip := _add_box(pips, Vector3(0.064, 0.007, 0.170) * scale, role_mat, Vector3(sin(angle) * 0.72 * scale, y + 0.044 * scale, -0.720 * scale + cos(angle) * 0.08 * scale), Vector3(0, -rad_to_deg(angle), 0))
        pip.name = "ChampionIdentityRangePip%d" % i

    var motif := Node3D.new()
    motif.name = "ChampionIdentityChampionMotif"
    motif.set_meta("champion", champion)
    rig.add_child(motif)
    var my := y + 0.056 * scale
    match champion:
        "jinx":
            _add_box(motif, Vector3(0.090, 0.007, 0.700) * scale, motif_mat, Vector3(-0.180 * scale, my, 0.020 * scale), Vector3(0, -25, 0))
            _add_box(motif, Vector3(0.090, 0.007, 0.700) * scale, role_mat, Vector3(0.180 * scale, my, 0.020 * scale), Vector3(0, 25, 0))
            _add_cylinder_segments(motif, 0.150 * scale, 0.007 * scale, 12, gold_mat, Vector3(0, my + 0.010 * scale, 0.300 * scale))
        "senna":
            _add_box(motif, Vector3(0.130, 0.007, 0.980) * scale, motif_mat, Vector3(0, my, 0.120 * scale))
            _add_cylinder_segments(motif, 0.350 * scale, 0.007 * scale, 28, role_mat, Vector3(0, my + 0.012 * scale, 0.220 * scale), Vector3(0, 0, 0))
        "samira":
            for i in range(4):
                var offset := float(i) - 1.5
                _add_box(motif, Vector3(0.070, 0.007, 0.540) * scale, motif_mat, Vector3(offset * 0.105 * scale, my, 0.080 * scale), Vector3(0, -42.0 + float(i) * 28.0, 0))
        "viktor":
            _add_cylinder_segments(motif, 0.300 * scale, 0.007 * scale, 6, role_mat, Vector3(0, my, 0.080 * scale), Vector3(0, 30, 0))
            _add_box(motif, Vector3(0.060, 0.007, 0.720) * scale, motif_mat, Vector3(0.280 * scale, my + 0.010 * scale, 0.270 * scale), Vector3(0, 18, 0))
        "xayah":
            for i in range(5):
                var offset := float(i) - 2.0
                _add_box(motif, Vector3(0.052, 0.007, 0.540 - abs(offset) * 0.045) * scale, motif_mat, Vector3(offset * 0.115 * scale, my, -0.020 * scale + abs(offset) * 0.050 * scale), Vector3(0, offset * 13.0, 0))
        "mordekaiser":
            _add_box(motif, Vector3(0.140, 0.007, 0.780) * scale, motif_mat, Vector3(0.130 * scale, my, 0.120 * scale), Vector3(0, -24, 0))
            _add_box(motif, Vector3(0.520, 0.007, 0.180) * scale, role_mat, Vector3(0.330 * scale, my + 0.010 * scale, 0.390 * scale), Vector3(0, -24, 0))
        "teemo":
            _add_cylinder(motif, 0.070 * scale, 0.140 * scale, gold_mat, Vector3(0, my, -0.040 * scale))
            _add_sphere(motif, 0.160 * scale, motif_mat, Vector3(0, my + 0.040 * scale, 0.080 * scale))
            _add_box(motif, Vector3(0.070, 0.007, 0.640) * scale, role_mat, Vector3(0.280 * scale, my, 0.160 * scale), Vector3(0, 18, 0))
        "aurelion_sol":
            _add_cylinder_segments(motif, 0.520 * scale, 0.007 * scale, 32, role_mat, Vector3(0, my, 0), Vector3(0, 0, 0))
            for i in range(4):
                var star_angle := TAU * float(i) / 4.0
                _add_sphere(motif, 0.042 * scale, gold_mat, Vector3(cos(star_angle) * 0.390 * scale, my + 0.012 * scale, sin(star_angle) * 0.260 * scale))
        _:
            _add_cylinder_segments(motif, 0.360 * scale, 0.007 * scale, 6, motif_mat, Vector3(0, my, 0), Vector3(0, 30, 0))

func _add_champion_presentation(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    var base_glow := _mat("champion_floor_glow_" + champion, Color(accent.r, accent.g, accent.b, 0.14), 0.28, true, true)
    var trim := _mat("champion_gold_trim", HEXTECH_GOLD, 0.10, true)
    _add_cylinder_segments(model, 0.78 * scale, 0.026 * scale, 6, base_glow, Vector3(0, 0.026, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(model, 0.58 * scale, 0.020 * scale, 6, trim, Vector3(0, 0.062, 0), Vector3(0, 30, 0))

    match champion:
        "jinx":
            _add_box(model, Vector3(0.16, 0.035, 1.05) * scale, _mat("jinx_blue_floor_mark", Color(0.24, 0.82, 1.0, 0.32), 0.36, true, true), Vector3(-0.34, 0.086, 0.20) * scale, Vector3(0, -18, 0))
            _add_box(model, Vector3(0.16, 0.035, 1.05) * scale, _mat("jinx_pink_floor_mark", Color(1.0, 0.28, 0.66, 0.32), 0.36, true, true), Vector3(0.34, 0.086, 0.20) * scale, Vector3(0, 18, 0))
        "senna":
            _add_cylinder_segments(model, 0.88 * scale, 0.018 * scale, 32, _mat("senna_soul_halo", Color(0.58, 1.0, 0.78, 0.24), 0.34, true, true), Vector3(0, 1.10, -0.58) * scale, Vector3(90, 0, 0))
            _add_sphere(model, 0.10 * scale, _mat("senna_soul_wisp", Color(0.78, 1.0, 0.88), 0.54, true), Vector3(-0.72, 1.30, -0.26) * scale)
        "samira":
            for i in range(3):
                var side := -1.0 + float(i)
                _add_box(model, Vector3(0.11, 0.040, 0.58) * scale, _mat("samira_style_slash", Color(1.0, 0.36, 0.18, 0.34), 0.38, true, true), Vector3(side * 0.24, 0.088, 0.18) * scale, Vector3(0, side * 22.0, 0))
        "viktor":
            _add_box(model, Vector3(0.86, 0.035, 0.10) * scale, _mat("viktor_hex_line", Color(0.72, 0.94, 1.0, 0.30), 0.36, true, true), Vector3(0, 0.090, 0.42) * scale)
            _add_box(model, Vector3(0.10, 0.035, 0.86) * scale, _mat("viktor_hex_line", Color(0.72, 0.94, 1.0, 0.30), 0.36, true, true), Vector3(0, 0.092, 0.42) * scale)
        "xayah":
            for i in range(5):
                var offset := float(i) - 2.0
                _add_box(model, Vector3(0.07, 0.035, 0.66) * scale, _mat("xayah_floor_feather", Color(1.0, 0.34, 0.72, 0.30), 0.34, true, true), Vector3(offset * 0.16, 0.088, -0.18 + abs(offset) * 0.04) * scale, Vector3(0, offset * 9.0, 0))
        "mordekaiser":
            _add_cylinder_segments(model, 0.92 * scale, 0.030 * scale, 8, _mat("morde_realm_base", Color(0.42, 1.0, 0.46, 0.22), 0.32, true, true), Vector3(0, 0.094, 0), Vector3(0, 22.5, 0))
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(0.12, 0.16, 0.52) * scale, _mat("morde_floor_spike", Color(0.16, 0.42, 0.28), 0.16, true), Vector3(side * 0.62, 0.16, -0.22) * scale, Vector3(0, side * 18.0, side * 18.0))
        "teemo":
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_sphere(model, 0.055 * scale, _mat("teemo_floor_spore", Color(0.58, 1.0, 0.22), 0.38, true), Vector3(cos(angle) * 0.66, 0.14, sin(angle) * 0.42) * scale)
        "aurelion_sol":
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(model, 0.075 * scale, _mat("asol_orbit_marker", Color(0.92, 0.74, 1.0), 0.46, true), Vector3(cos(angle) * 0.88, 0.18, sin(angle) * 0.62) * scale)
        _:
            pass

func _add_champion_identity_projection(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    var portrait_path := _champion_portrait_texture_path(champion)
    if portrait_path == "":
        return
    var root := Node3D.new()
    root.name = "ChampionIdentityProjection"
    model.add_child(root)

    var portrait_mat := _texture_mat("champion_identity_projection_" + champion, portrait_path, Color(1.0, 1.0, 1.0, 0.40), 0.10, true, true)
    var shadow_mat := _mat("champion_identity_shadow_" + champion, Color(0.0, 0.0, 0.02, 0.26), 0.0, true, true)
    var frame_mat := _mat("champion_identity_frame_" + champion, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.36), 0.48, true, true)
    var glow_mat := _mat("champion_identity_glow_" + champion, Color(accent.r, accent.g, accent.b, 0.22), 0.70, true, true)
    var center := Vector3(0, 0, -0.35) * scale

    _add_textured_plane(root, Vector2(1.46, 1.46) * scale, shadow_mat, center + Vector3(0, 0.085 * scale, 0))
    var portrait := _add_textured_plane(root, Vector2(1.34, 1.34) * scale, portrait_mat, center + Vector3(0, 0.112 * scale, 0))
    portrait.name = "PortraitTexture"
    _add_cylinder_segments(root, 0.88 * scale, 0.010 * scale, 6, frame_mat, center + Vector3(0, 0.138 * scale, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(root, 0.68 * scale, 0.008 * scale, 24, glow_mat, center + Vector3(0, 0.154 * scale, 0))
    for i in range(6):
        var a := TAU * float(i) / 6.0
        _add_box(root, Vector3(0.058, 0.010, 0.28) * scale, frame_mat, center + Vector3(cos(a) * 0.78 * scale, 0.166 * scale, sin(a) * 0.78 * scale), Vector3(0, -rad_to_deg(a), 0))

func _add_champion_fan_signature(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionFanSignature") != null:
        return
    var sig := Node3D.new()
    sig.name = "ChampionFanSignature"
    sig.set_meta("champion", champion)
    model.add_child(sig)
    var soft := _mat(champion + "_fan_signature_soft", Color(accent.r, accent.g, accent.b, 0.34), 0.96, true, true)
    var hot := _mat(champion + "_fan_signature_hot", accent.lightened(0.18), 1.16, true)
    var gold := _mat(champion + "_fan_signature_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.46), 0.82, true, true)
    var y := 1.92 * scale
    match champion:
        "jinx":
            _add_box(sig, Vector3(0.16, 0.040, 1.28) * scale, _mat("jinx_fan_blue_rocket", Color(0.22, 0.78, 1.0), 0.92, true), Vector3(-0.22, y, 0.04) * scale, Vector3(0, -24, 34))
            _add_box(sig, Vector3(0.16, 0.040, 1.28) * scale, _mat("jinx_fan_pink_rocket", Color(1.0, 0.28, 0.64), 0.92, true), Vector3(0.22, y, 0.04) * scale, Vector3(0, 24, -34))
            _add_sphere(sig, 0.085 * scale, gold, Vector3(0, y + 0.060 * scale, 0.48) * scale)
        "senna":
            _add_cylinder_segments(sig, 0.58 * scale, 0.014 * scale, 32, soft, Vector3(0, y, 0.06) * scale, Vector3(90, 0, 0))
            _add_box(sig, Vector3(0.20, 0.038, 1.42) * scale, hot, Vector3(0, y, 0.48) * scale)
            _add_sphere(sig, 0.095 * scale, hot, Vector3(0, y + 0.120 * scale, -0.18) * scale)
        "samira":
            _add_cylinder_segments(sig, 0.62 * scale, 0.014 * scale, 24, _mat("samira_fan_style_ring", Color(1.0, 0.26, 0.12, 0.40), 1.04, true, true), Vector3(0, y, 0) * scale, Vector3(90, 0, 0))
            for slash in range(5):
                var offset := float(slash) - 2.0
                _add_box(sig, Vector3(0.075, 0.026, 0.86 - abs(offset) * 0.05) * scale, hot, Vector3(offset * 0.14, y + 0.030 * scale, 0.04) * scale, Vector3(0, offset * 14.0, offset * 22.0))
        "viktor":
            _add_cylinder_segments(sig, 0.58 * scale, 0.014 * scale, 6, soft, Vector3(0, y, 0.02) * scale, Vector3(90, 0, 30))
            _add_sphere(sig, 0.13 * scale, _mat("viktor_fan_hexcore", Color(0.76, 0.94, 1.0), 1.28, true), Vector3(0, y + 0.075 * scale, 0.02) * scale)
            _add_box(sig, Vector3(0.085, 0.022, 1.16) * scale, hot, Vector3(0.40, y, 0.42) * scale, Vector3(0, 18, 0))
        "xayah":
            for feather in range(7):
                var offset := float(feather) - 3.0
                _add_box(sig, Vector3(0.070, 0.026, 1.08 - abs(offset) * 0.075) * scale, _mat("xayah_fan_feather_" + str(feather), Color(1.0, 0.28, 0.70), 1.04, true), Vector3(offset * 0.13, y, -0.04 + abs(offset) * 0.050) * scale, Vector3(0, offset * 11.0, offset * 18.0))
        "mordekaiser":
            _add_box(sig, Vector3(0.28, 0.030, 1.34) * scale, _mat("morde_fan_hammer_handle", Color(0.10, 0.24, 0.16), 0.42, true), Vector3(0.18, y, 0.20) * scale, Vector3(0, -28, 0))
            _add_box(sig, Vector3(0.78, 0.042, 0.36) * scale, hot, Vector3(0.50, y + 0.060 * scale, 0.60) * scale, Vector3(0, -28, 0))
            _add_cylinder_segments(sig, 0.62 * scale, 0.014 * scale, 8, soft, Vector3(0, y - 0.040 * scale, 0) * scale, Vector3(90, 0, 22.5))
        "teemo":
            _add_cylinder(sig, 0.16 * scale, 0.22 * scale, _mat("teemo_fan_mushroom_stem", Color(0.86, 0.76, 0.54), 0.10, true), Vector3(0, y - 0.020 * scale, 0) * scale)
            _add_sphere(sig, 0.28 * scale, _mat("teemo_fan_mushroom_cap", Color(0.82, 0.18, 0.16), 0.58, true), Vector3(0, y + 0.180 * scale, 0) * scale)
            _add_cylinder_segments(sig, 0.54 * scale, 0.012 * scale, 12, _mat("teemo_fan_poison_ring", Color(0.62, 1.0, 0.22, 0.36), 0.94, true, true), Vector3(0, y - 0.080 * scale, 0) * scale, Vector3(90, 0, 0))
        "aurelion_sol":
            _add_cylinder_segments(sig, 0.74 * scale, 0.012 * scale, 36, soft, Vector3(0, y, 0) * scale, Vector3(90, 0, 0))
            for star in range(5):
                var angle := TAU * float(star) / 5.0
                _add_sphere(sig, 0.060 * scale, _mat("asol_fan_star_" + str(star), Color(1.0, 0.86, 0.50), 1.32, true), Vector3(cos(angle) * 0.62, y + 0.040 * scale, sin(angle) * 0.42) * scale)
            _add_tapered_cylinder(sig, 0.070 * scale, 0.012 * scale, 1.08 * scale, 8, hot, Vector3(0.34, y + 0.030 * scale, 0.34) * scale, Vector3(74, -30, 0))
        _:
            _add_cylinder_segments(sig, 0.56 * scale, 0.012 * scale, 6, soft, Vector3(0, y, 0) * scale, Vector3(90, 0, 30))

func _sync_champion_fan_signature(model: Node3D) -> void:
    var sig := model.get_node_or_null("ChampionFanSignature") as Node3D
    if sig == null:
        return
    var champion := str(sig.get_meta("champion", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var spin := 0.18
    match champion:
        "jinx", "samira", "teemo":
            spin = 0.32
        "aurelion_sol", "xayah":
            spin = -0.24
        "mordekaiser":
            spin = 0.10
        _:
            spin = 0.18
    sig.rotation.y = time * spin
    sig.scale = Vector3.ONE * (1.0 + sin(time * (2.8 if champion == "jinx" or champion == "samira" else 2.1)) * 0.045)

func _champion_fan_readable_signature(champion: String) -> String:
    match champion:
        "jinx":
            return "twin_rocket_minigun"
        "senna":
            return "relic_cannon_soul_gate"
        "samira":
            return "blade_pistol_style_cross"
        "viktor":
            return "hexcore_spine_claw"
        "xayah":
            return "feather_fan_recall"
        "mordekaiser":
            return "iron_mace_citadel"
        "teemo":
            return "scout_mushroom_poison"
        "aurelion_sol":
            return "celestial_orbit_starforge"
        _:
            return "generic_champion_silhouette"

func _champion_fan_readable_detail_name(champion: String) -> String:
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

func _add_champion_fan_readable_silhouette_rig(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionFanReadableSilhouetteRig") != null:
        return
    var rig := Node3D.new()
    rig.name = "ChampionFanReadableSilhouetteRig"
    rig.set_meta("champion", champion)
    rig.set_meta("combat_visual_channel", "champion_readability")
    rig.set_meta("material_grade", "low_glare_fan_readable_silhouette")
    rig.set_meta("silhouette_signature", _champion_fan_readable_signature(champion))
    model.add_child(rig)

    var role_color := _champion_kit_role_color(champion, accent)
    var dark := _mat(champion + "_fan_readable_dark_matte", Color(0.0, 0.0, 0.0, 0.38), 0.0, true, true)
    var role_mat := _mat(champion + "_fan_readable_role_matte", Color(role_color.r, role_color.g, role_color.b, 0.26), 0.0, true, true)
    var gold := _mat(champion + "_fan_readable_gold_matte", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24), 0.0, true, true)
    var accent_mat := _mat(champion + "_fan_readable_accent_matte", Color(accent.r, accent.g, accent.b, 0.28), 0.0, true, true)
    var danger_mat := _mat(champion + "_fan_readable_danger_matte", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.24), 0.0, true, true)

    var shadow := _add_cylinder_segments(rig, 0.94 * scale, 0.010 * scale, 8, dark, Vector3(0, 0.118 * scale, -0.10 * scale), Vector3(0, 22.5, 0))
    shadow.name = "ChampionFanReadableShadowPlate"
    var anchor := _add_cylinder_segments(rig, 0.72 * scale, 0.008 * scale, 6, role_mat, Vector3(0, 0.136 * scale, -0.10 * scale), Vector3(0, 30, 0))
    anchor.name = "ChampionFanReadableRoleAnchor"
    var facing := _add_box(rig, Vector3(0.10, 0.008, 0.78) * scale, gold, Vector3(0, 0.158 * scale, 0.52 * scale))
    facing.name = "ChampionFanReadableFacingShard"

    var detail := Node3D.new()
    detail.name = "ChampionFanReadableSignatureDetail"
    detail.set_meta("champion", champion)
    detail.set_meta("signature_detail", _champion_fan_readable_signature(champion))
    rig.add_child(detail)

    var detail_root := Node3D.new()
    detail_root.name = _champion_fan_readable_detail_name(champion)
    detail_root.set_meta("champion", champion)
    detail.add_child(detail_root)

    match champion:
        "jinx":
            for side in [-1.0, 1.0]:
                _add_box(detail_root, Vector3(0.115, 0.012, 0.92) * scale, accent_mat, Vector3(side * 0.27, 0.184, 0.02) * scale, Vector3(0, side * 22.0, side * 24.0))
                _add_sphere(detail_root, 0.056 * scale, gold, Vector3(side * 0.34, 0.198, 0.42) * scale)
            for barrel in range(3):
                _add_box(detail_root, Vector3(0.044, 0.010, 0.54) * scale, dark, Vector3((-0.10 + float(barrel) * 0.10) * scale, 0.176 * scale, -0.28 * scale), Vector3(0, -12, 0))
        "senna":
            _add_box(detail_root, Vector3(1.04, 0.014, 0.16) * scale, dark, Vector3(0, 0.184, 0.05) * scale)
            _add_box(detail_root, Vector3(0.22, 0.012, 1.05) * scale, accent_mat, Vector3(0, 0.194, 0.34) * scale)
            _add_cylinder_segments(detail_root, 0.45 * scale, 0.010 * scale, 24, role_mat, Vector3(0, 0.204, -0.24) * scale, Vector3(90, 0, 0))
            for mote in range(4):
                var mote_angle := TAU * float(mote) / 4.0
                _add_sphere(detail_root, 0.040 * scale, gold, Vector3(cos(mote_angle) * 0.38 * scale, 0.218 * scale, -0.24 * scale + sin(mote_angle) * 0.16 * scale))
        "samira":
            _add_box(detail_root, Vector3(0.100, 0.012, 1.04) * scale, accent_mat, Vector3(-0.26, 0.190, 0.04) * scale, Vector3(0, -26, 28))
            _add_box(detail_root, Vector3(0.100, 0.012, 0.82) * scale, dark, Vector3(0.28, 0.186, 0.02) * scale, Vector3(0, 22, -24))
            _add_box(detail_root, Vector3(0.70, 0.010, 0.060) * scale, gold, Vector3(0, 0.206, -0.18) * scale, Vector3(0, 0, 0))
            for mark in range(5):
                var offset := float(mark) - 2.0
                _add_box(detail_root, Vector3(0.048, 0.008, 0.34) * scale, danger_mat, Vector3(offset * 0.12 * scale, 0.216 * scale, 0.34 * scale), Vector3(0, offset * 10.0, offset * 18.0))
        "viktor":
            _add_box(detail_root, Vector3(0.070, 0.014, 0.92) * scale, dark, Vector3(0.30, 0.186, 0.12) * scale, Vector3(0, 18, 0))
            _add_cylinder_segments(detail_root, 0.28 * scale, 0.010 * scale, 6, accent_mat, Vector3(0, 0.198, 0.04) * scale, Vector3(90, 0, 30))
            _add_sphere(detail_root, 0.075 * scale, role_mat, Vector3(0, 0.212, 0.04) * scale)
            for spine in range(4):
                _add_box(detail_root, Vector3(0.060, 0.010, 0.22) * scale, gold, Vector3(0, 0.190 * scale, (-0.38 + float(spine) * 0.18) * scale), Vector3(0, 0, 0))
            _add_box(detail_root, Vector3(0.38, 0.010, 0.070) * scale, accent_mat, Vector3(0.46, 0.204, -0.24) * scale, Vector3(0, 24, 0))
        "xayah":
            for feather in range(7):
                var offset := float(feather) - 3.0
                _add_box(detail_root, Vector3(0.058, 0.010, 0.76 - abs(offset) * 0.050) * scale, accent_mat if feather % 2 == 0 else role_mat, Vector3(offset * 0.11 * scale, 0.192 * scale, -0.08 * scale + abs(offset) * 0.045 * scale), Vector3(0, offset * 10.0, offset * 20.0))
            _add_cylinder_segments(detail_root, 0.48 * scale, 0.008 * scale, 5, dark, Vector3(0, 0.178, -0.12) * scale, Vector3(90, 0, 18))
        "mordekaiser":
            _add_box(detail_root, Vector3(0.105, 0.014, 1.08) * scale, dark, Vector3(0.20, 0.188, 0.06) * scale, Vector3(0, -20, 0))
            _add_box(detail_root, Vector3(0.62, 0.018, 0.28) * scale, accent_mat, Vector3(0.42, 0.206, 0.46) * scale, Vector3(0, -20, 0))
            _add_box(detail_root, Vector3(0.42, 0.012, 0.10) * scale, gold, Vector3(-0.24, 0.202, -0.36) * scale)
            for spike in range(4):
                _add_tapered_cylinder(detail_root, 0.040 * scale, 0.010 * scale, 0.42 * scale, 5, role_mat, Vector3((-0.36 + float(spike) * 0.24) * scale, 0.216 * scale, -0.24 * scale), Vector3(70, 0, -20 + float(spike) * 14.0))
        "teemo":
            _add_cylinder(detail_root, 0.085 * scale, 0.14 * scale, gold, Vector3(0, 0.190, 0.02) * scale)
            _add_sphere(detail_root, 0.190 * scale, danger_mat, Vector3(0, 0.242, 0.02) * scale)
            for spot in range(4):
                var spot_angle := TAU * float(spot) / 4.0
                _add_sphere(detail_root, 0.026 * scale, role_mat, Vector3(cos(spot_angle) * 0.10 * scale, 0.282 * scale, sin(spot_angle) * 0.06 * scale))
            _add_box(detail_root, Vector3(0.055, 0.010, 0.86) * scale, dark, Vector3(0.34, 0.190, 0.16) * scale, Vector3(0, 20, 0))
            _add_box(detail_root, Vector3(0.52, 0.010, 0.12) * scale, accent_mat, Vector3(-0.26, 0.196, -0.30) * scale)
        "aurelion_sol":
            _add_cylinder_segments(detail_root, 0.58 * scale, 0.008 * scale, 36, role_mat, Vector3(0, 0.190, 0) * scale, Vector3(90, 0, 0))
            _add_cylinder_segments(detail_root, 0.36 * scale, 0.008 * scale, 28, accent_mat, Vector3(0, 0.205, 0) * scale, Vector3(78, 0, 0))
            for star in range(5):
                var star_angle := TAU * float(star) / 5.0
                _add_sphere(detail_root, 0.044 * scale, gold, Vector3(cos(star_angle) * 0.48 * scale, 0.220 * scale, sin(star_angle) * 0.30 * scale))
            _add_tapered_cylinder(detail_root, 0.050 * scale, 0.012 * scale, 0.72 * scale, 6, accent_mat, Vector3(0.32, 0.212, 0.30) * scale, Vector3(72, -28, 0))
        _:
            _add_cylinder_segments(detail_root, 0.42 * scale, 0.008 * scale, 6, role_mat, Vector3(0, 0.190, 0) * scale, Vector3(90, 0, 30))
            _add_box(detail_root, Vector3(0.56, 0.010, 0.10) * scale, gold, Vector3(0, 0.202, 0.20) * scale)

func _sync_champion_fan_readable_silhouette_rig(model: Node3D) -> void:
    var rig := model.get_node_or_null("ChampionFanReadableSilhouetteRig") as Node3D
    if rig == null:
        return
    var champion := str(rig.get_meta("champion", ""))
    var detail := rig.get_node_or_null("ChampionFanReadableSignatureDetail") as Node3D
    if detail == null:
        return
    var time := Time.get_ticks_msec() / 1000.0
    var sway := sin(time * 1.15) * 0.035
    if champion == "aurelion_sol":
        detail.rotation.y = time * 0.10
    elif champion == "xayah":
        detail.rotation.y = -sway
    else:
        detail.rotation.y = sway
    detail.scale = Vector3.ONE * (1.0 + sin(time * 1.8) * 0.018)

func _add_champion_signature_weapon_rig(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionSignatureWeaponRig") != null:
        return
    var detail_name := _champion_signature_weapon_detail_name(champion)
    var rig := Node3D.new()
    rig.name = "ChampionSignatureWeaponRig"
    rig.set_meta("champion", champion)
    rig.set_meta("combat_visual_channel", "champion_model_identity")
    rig.set_meta("material_grade", "low_glare_signature_weapon")
    rig.set_meta("weapon_signature", champion)
    rig.set_meta("detail_node", detail_name)
    model.add_child(rig)

    var role_color := _champion_kit_role_color(champion, accent)
    var dark := _mat(champion + "_signature_weapon_dark_matte", Color(0.010, 0.010, 0.024, 0.58), 0.0, true, true)
    var metal := _mat(champion + "_signature_weapon_plated_metal", Color(0.180, 0.170, 0.230), 0.0, true)
    var trim := _mat(champion + "_signature_weapon_gold_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.32), 0.0, true, true)
    var accent_mat := _mat(champion + "_signature_weapon_accent", Color(role_color.r, role_color.g, role_color.b, 0.30), 0.18, true, true)
    var hot := _mat(champion + "_signature_weapon_hot_core", Color(role_color.lightened(0.16).r, role_color.lightened(0.16).g, role_color.lightened(0.16).b, 0.42), 0.28, true, true)

    var anchor := Node3D.new()
    anchor.name = "ChampionSignatureWeaponAnchor"
    anchor.set_meta("champion", champion)
    anchor.set_meta("combat_visual_channel", "champion_model_identity")
    rig.add_child(anchor)
    var y := 1.84
    _add_box(anchor, Vector3(0.82, 0.018, 0.18) * scale, dark, Vector3(0, y - 0.08, -0.30) * scale)
    _add_box(anchor, Vector3(0.58, 0.014, 0.052) * scale, trim, Vector3(0, y - 0.04, -0.16) * scale)

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("champion", champion)
    detail.set_meta("weapon_signature", champion)
    detail.set_meta("combat_visual_channel", "champion_model_identity")
    rig.add_child(detail)

    match champion:
        "jinx":
            _add_box(detail, Vector3(0.210, 0.120, 1.42) * scale, metal, Vector3(0.46, y, 0.24) * scale, Vector3(0, 8, -8))
            _add_tapered_cylinder(detail, 0.190 * scale, 0.050 * scale, 0.48 * scale, 8, accent_mat, Vector3(0.46, y + 0.010, 0.98) * scale, Vector3(90, 0, 0))
            _add_box(detail, Vector3(0.72, 0.030, 0.180) * scale, trim, Vector3(0.46, y + 0.080, -0.42) * scale, Vector3(0, 8, 0))
            for barrel in range(3):
                _add_cylinder(detail, 0.034 * scale, 0.78 * scale, hot, Vector3(-0.34 + float(barrel) * 0.10, y - 0.04, 0.38) * scale, Vector3(90, 0, 0))
        "senna":
            _add_box(detail, Vector3(0.480, 0.150, 1.72) * scale, metal, Vector3(0, y, 0.36) * scale)
            _add_cylinder_segments(detail, 0.250 * scale, 0.070 * scale, 24, accent_mat, Vector3(0, y + 0.020, 1.26) * scale, Vector3(90, 0, 0))
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(0.520, 0.028, 0.170) * scale, trim, Vector3(side * 0.34, y + 0.070, 0.58) * scale, Vector3(0, side * 8, side * 12))
            _add_cylinder_segments(detail, 0.520 * scale, 0.010 * scale, 32, hot, Vector3(-0.44, y + 0.090, -0.26) * scale, Vector3(90, 0, 0))
        "samira":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(0.094, 0.050, 1.02) * scale, trim, Vector3(side * 0.30, y, 0.18) * scale, Vector3(0, side * 20, side * 24))
                _add_box(detail, Vector3(0.260, 0.070, 0.620) * scale, metal, Vector3(side * 0.48, y - 0.10, -0.12) * scale, Vector3(0, side * -18, side * 12))
            _add_cylinder_segments(detail, 0.560 * scale, 0.010 * scale, 24, accent_mat, Vector3(0, y + 0.100, 0.02) * scale, Vector3(90, 0, 0))
        "viktor":
            _add_box(detail, Vector3(0.120, 0.070, 1.10) * scale, metal, Vector3(0.42, y, -0.02) * scale, Vector3(18, 0, -12))
            _add_cylinder_segments(detail, 0.300 * scale, 0.012 * scale, 6, accent_mat, Vector3(0, y + 0.040, 0.16) * scale, Vector3(90, 0, 30))
            _add_sphere(detail, 0.095 * scale, hot, Vector3(0, y + 0.060, 0.16) * scale)
            for claw in range(3):
                var offset := float(claw) - 1.0
                _add_tapered_cylinder(detail, 0.030 * scale, 0.006 * scale, 0.440 * scale, 5, trim, Vector3(0.58 + offset * 0.10, y + 0.12, 0.46) * scale, Vector3(62, offset * 12.0, -20))
        "xayah":
            for feather in range(7):
                var offset := float(feather) - 3.0
                _add_box(detail, Vector3(0.060, 0.026, 0.88 - abs(offset) * 0.050) * scale, accent_mat if feather % 2 == 0 else hot, Vector3(offset * 0.115, y, -0.14 + abs(offset) * 0.055) * scale, Vector3(0, offset * 12.0, offset * 22.0))
            _add_cylinder_segments(detail, 0.520 * scale, 0.010 * scale, 5, trim, Vector3(0, y - 0.065, -0.12) * scale, Vector3(90, 0, 18))
        "mordekaiser":
            _add_cylinder(detail, 0.060 * scale, 1.42 * scale, metal, Vector3(0.42, y - 0.06, 0.18) * scale, Vector3(62, 0, 0))
            _add_box(detail, Vector3(0.740, 0.210, 0.420) * scale, accent_mat, Vector3(0.64, y + 0.180, 0.84) * scale, Vector3(0, -16, 10))
            _add_box(detail, Vector3(0.520, 0.045, 0.130) * scale, trim, Vector3(0.64, y + 0.320, 1.02) * scale, Vector3(0, -16, 0))
            for spike in range(3):
                _add_tapered_cylinder(detail, 0.040 * scale, 0.006 * scale, 0.340 * scale, 5, hot, Vector3(0.34 + float(spike) * 0.15, y + 0.280, 0.60) * scale, Vector3(70, 0, -20 + float(spike) * 20.0))
        "teemo":
            _add_box(detail, Vector3(0.460, 0.200, 0.270) * scale, metal, Vector3(0, y - 0.18, -0.44) * scale)
            _add_cylinder(detail, 0.040 * scale, 1.06 * scale, trim, Vector3(0.38, y - 0.18, 0.38) * scale, Vector3(78, 0, 0))
            for mushroom in range(3):
                var x := -0.22 + float(mushroom) * 0.22
                _add_cylinder(detail, 0.044 * scale, 0.100 * scale, dark, Vector3(x, y - 0.02, -0.64) * scale)
                _add_sphere(detail, 0.090 * scale, accent_mat if mushroom % 2 == 0 else hot, Vector3(x, y + 0.060, -0.64) * scale)
        "aurelion_sol":
            _add_cylinder_segments(detail, 0.780 * scale, 0.010 * scale, 42, accent_mat, Vector3(0, y, 0.00) * scale, Vector3(90, 0, 0))
            _add_cylinder_segments(detail, 0.510 * scale, 0.008 * scale, 32, hot, Vector3(0, y + 0.020, 0.00) * scale, Vector3(70, 0, 0))
            for star in range(6):
                var angle := TAU * float(star) / 6.0
                _add_sphere(detail, 0.052 * scale, trim, Vector3(cos(angle) * 0.66, y + 0.040, sin(angle) * 0.38) * scale)
            _add_tapered_cylinder(detail, 0.055 * scale, 0.014 * scale, 0.900 * scale, 8, accent_mat, Vector3(0.34, y + 0.060, 0.32) * scale, Vector3(68, -24, 0))
        _:
            _add_box(detail, Vector3(0.640, 0.055, 0.200) * scale, accent_mat, Vector3(0, y, 0.20) * scale)

func _champion_signature_weapon_detail_name(champion: String) -> String:
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

func _sync_champion_signature_weapon_rig(model: Node3D) -> void:
    var rig := model.get_node_or_null("ChampionSignatureWeaponRig") as Node3D
    if rig == null:
        return
    var champion := str(rig.get_meta("champion", ""))
    var time := Time.get_ticks_msec() / 1000.0
    rig.scale = Vector3.ONE * (1.0 + sin(time * 1.45) * 0.010)
    var detail := rig.get_node_or_null(str(rig.get_meta("detail_node", ""))) as Node3D
    if detail == null:
        return
    match champion:
        "aurelion_sol":
            detail.rotation.y += 0.010
        "xayah":
            detail.rotation.y = sin(time * 1.2) * 0.035
        "samira":
            detail.rotation.y = sin(time * 1.8) * 0.045
        "viktor":
            detail.position.y = sin(time * 1.7) * 0.006
        _:
            detail.rotation.y = sin(time * 1.0) * 0.018

func _add_champion_premium_body_rig(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionPremiumBodyRig") != null:
        return
    var family := _champion_premium_silhouette_family(champion)
    var detail_name := _champion_premium_detail_name(champion)
    var rig := Node3D.new()
    rig.name = "ChampionPremiumBodyRig"
    rig.set_meta("champion", champion)
    rig.set_meta("silhouette_family", family)
    rig.set_meta("detail_node", detail_name)
    rig.set_meta("material_grade", "premium_fan_3d")
    model.add_child(rig)

    var role_color := _champion_kit_role_color(champion, accent)
    var dark := _mat(champion + "_premium_body_dark", Color(0.012, 0.014, 0.024, 0.78), 0.04, true, true)
    var trim := _mat(champion + "_premium_body_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.64), 0.88, true, true)
    var soft := _mat(champion + "_premium_body_soft", Color(role_color.r, role_color.g, role_color.b, 0.50), 0.94, true, true)
    var hot := _mat(champion + "_premium_body_hot", role_color.lightened(0.16), 1.18, true)

    var plating := Node3D.new()
    plating.name = "ChampionPremiumArmorPlating"
    plating.set_meta("silhouette_family", family)
    rig.add_child(plating)
    _add_box(plating, Vector3(0.86, 0.052, 0.22) * scale, dark, Vector3(0, 1.34, 0.045) * scale)
    _add_box(plating, Vector3(0.66, 0.046, 0.13) * scale, trim, Vector3(0, 1.18, 0.252) * scale)
    for side in [-1.0, 1.0]:
        _add_box(plating, Vector3(0.24, 0.070, 0.42) * scale, soft, Vector3(side * 0.52, 1.32, 0.03) * scale, Vector3(0, side * 10.0, side * 10.0))
        _add_box(plating, Vector3(0.090, 0.040, 0.46) * scale, trim, Vector3(side * 0.64, 1.22, 0.12) * scale, Vector3(0, side * 18.0, side * 16.0))
    var core := _add_sphere(plating, 0.115 * scale, hot, Vector3(0, 1.245, 0.310) * scale)
    core.name = "ChampionPremiumChestCore"

    var swatches := Node3D.new()
    swatches.name = "ChampionPremiumMaterialSwatches"
    swatches.set_meta("material_grade", "premium_fan_3d")
    rig.add_child(swatches)
    for i in range(3):
        var swatch_color := trim if i == 0 else soft if i == 1 else hot
        var swatch := _add_box(swatches, Vector3(0.110, 0.026, 0.135) * scale, swatch_color, Vector3((-0.18 + float(i) * 0.18) * scale, 1.050 * scale, 0.340 * scale))
        swatch.name = "ChampionPremiumMaterialSwatch%d" % i

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("champion", champion)
    detail.set_meta("silhouette_family", family)
    rig.add_child(detail)

    match champion:
        "jinx":
            _add_box(detail, Vector3(0.15, 0.040, 1.10) * scale, _mat("jinx_premium_blue_rocket_strap", Color(0.22, 0.82, 1.0), 0.98, true), Vector3(-0.38, 1.42, -0.16) * scale, Vector3(0, -26, 18))
            _add_box(detail, Vector3(0.15, 0.040, 1.10) * scale, _mat("jinx_premium_pink_rocket_strap", Color(1.0, 0.24, 0.64), 0.98, true), Vector3(0.38, 1.42, -0.16) * scale, Vector3(0, 26, -18))
            for spark in range(5):
                _add_sphere(detail, 0.036 * scale, trim, Vector3((-0.42 + float(spark) * 0.21) * scale, 1.56 * scale, (0.18 + sin(float(spark)) * 0.08) * scale))
        "senna":
            _add_cylinder_segments(detail, 0.62 * scale, 0.014 * scale, 32, soft, Vector3(0, 1.42, -0.36) * scale, Vector3(90, 0, 0))
            _add_box(detail, Vector3(1.10, 0.036, 0.16) * scale, trim, Vector3(0, 1.36, 0.16) * scale)
            for mote in range(4):
                var mote_angle := TAU * float(mote) / 4.0
                _add_sphere(detail, 0.052 * scale, hot, Vector3(cos(mote_angle) * 0.52 * scale, 1.48 * scale, -0.36 * scale + sin(mote_angle) * 0.18 * scale))
        "samira":
            _add_box(detail, Vector3(0.18, 0.040, 1.28) * scale, _mat("samira_premium_scarf_left", Color(0.90, 0.04, 0.04), 0.72, true), Vector3(-0.42, 1.22, -0.32) * scale, Vector3(0, -18, 38))
            _add_box(detail, Vector3(0.18, 0.040, 1.28) * scale, _mat("samira_premium_scarf_right", Color(0.90, 0.04, 0.04), 0.72, true), Vector3(0.42, 1.22, -0.32) * scale, Vector3(0, 18, -38))
            for slash in range(4):
                var offset := float(slash) - 1.5
                _add_box(detail, Vector3(0.070, 0.026, 0.78) * scale, hot, Vector3(offset * 0.14 * scale, 1.58 * scale, 0.24 * scale), Vector3(0, offset * 16.0, offset * 20.0))
        "viktor":
            _add_cylinder_segments(detail, 0.42 * scale, 0.014 * scale, 6, soft, Vector3(0, 1.36, 0.28) * scale, Vector3(90, 0, 30))
            _add_sphere(detail, 0.150 * scale, hot, Vector3(0, 1.37, 0.30) * scale)
            for spine in range(4):
                _add_box(detail, Vector3(0.070, 0.032, 0.30) * scale, trim, Vector3(0, (1.16 + float(spine) * 0.14) * scale, -0.30 * scale), Vector3(16, 0, 0))
        "xayah":
            for plume in range(7):
                var plume_offset := float(plume) - 3.0
                _add_box(detail, Vector3(0.080, 0.030, 1.00 - abs(plume_offset) * 0.055) * scale, hot, Vector3(plume_offset * 0.12 * scale, 1.42 * scale, -0.32 * scale + abs(plume_offset) * 0.04 * scale), Vector3(0, plume_offset * 10.0, plume_offset * 18.0))
            _add_cylinder_segments(detail, 0.56 * scale, 0.010 * scale, 5, soft, Vector3(0, 1.26, -0.10) * scale, Vector3(90, 0, 18))
        "mordekaiser":
            _add_box(detail, Vector3(0.92, 0.060, 0.34) * scale, dark, Vector3(0, 1.46, -0.20) * scale)
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(detail, 0.115 * scale, 0.030 * scale, 0.72 * scale, 6, hot, Vector3(side * 0.44, 1.72, -0.18) * scale, Vector3(38, side * 16.0, side * 24.0))
                _add_box(detail, Vector3(0.16, 0.040, 0.74) * scale, trim, Vector3(side * 0.56, 1.24, 0.06) * scale, Vector3(0, side * 24.0, side * 12.0))
        "teemo":
            _add_box(detail, Vector3(0.58, 0.15, 0.32) * scale, _mat("teemo_premium_scout_pack", Color(0.30, 0.20, 0.10), 0.12, true), Vector3(0, 1.13, -0.46) * scale)
            for vial in range(3):
                _add_sphere(detail, 0.054 * scale, hot, Vector3((-0.20 + float(vial) * 0.20) * scale, 1.26 * scale, -0.62 * scale))
            _add_box(detail, Vector3(0.72, 0.038, 0.10) * scale, trim, Vector3(0, 1.54, 0.34) * scale)
        "aurelion_sol":
            _add_cylinder_segments(detail, 0.78 * scale, 0.010 * scale, 40, soft, Vector3(0, 1.52, 0.02) * scale, Vector3(90, 0, 0))
            for star in range(6):
                var star_angle := TAU * float(star) / 6.0
                _add_sphere(detail, 0.052 * scale, _mat("asol_premium_body_star_" + str(star), Color(1.0, 0.86, 0.50), 1.24, true), Vector3(cos(star_angle) * 0.58 * scale, 1.54 * scale, sin(star_angle) * 0.34 * scale))
            _add_tapered_cylinder(detail, 0.060 * scale, 0.014 * scale, 0.92 * scale, 8, hot, Vector3(0.32, 1.46, 0.34) * scale, Vector3(68, -24, 0))
        _:
            _add_box(detail, Vector3(0.68, 0.040, 0.18) * scale, soft, Vector3(0, 1.40, 0.10) * scale)

func _sync_champion_premium_body_rig(model: Node3D) -> void:
    var rig := model.get_node_or_null("ChampionPremiumBodyRig") as Node3D
    if rig == null:
        return
    var champion := str(rig.get_meta("champion", ""))
    var family := str(rig.get_meta("silhouette_family", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var pulse_speed := 2.0
    match family:
        "duelist", "artillery":
            pulse_speed = 2.8
        "celestial", "hexcore":
            pulse_speed = 2.3
        "juggernaut":
            pulse_speed = 1.5
        _:
            pulse_speed = 2.0
    rig.scale = Vector3.ONE * (1.0 + sin(time * pulse_speed) * 0.018)
    var detail := rig.get_node_or_null(str(rig.get_meta("detail_node", ""))) as Node3D
    if detail != null:
        var detail_spin := 0.0
        match champion:
            "jinx", "samira", "teemo":
                detail_spin = 0.010
            "aurelion_sol", "viktor":
                detail_spin = -0.012
            _:
                detail_spin = 0.006
        detail.rotation.y += detail_spin
        detail.position.y = sin(time * (pulse_speed + 0.7)) * 0.006
    var plating := rig.get_node_or_null("ChampionPremiumArmorPlating") as Node3D
    if plating != null:
        plating.scale = Vector3.ONE * (1.0 + sin(time * (pulse_speed + 0.4)) * 0.010)

func _add_champion_painterly_depth_rig(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionPainterlyDepthRig") != null:
        return
    var rig := Node3D.new()
    rig.name = "ChampionPainterlyDepthRig"
    rig.set_meta("champion", champion)
    rig.set_meta("silhouette_family", _champion_premium_silhouette_family(champion))
    rig.set_meta("detail_node", _champion_painterly_depth_detail_name(champion))
    rig.set_meta("material_grade", "painted_depth_low_glare")
    rig.set_meta("combat_visual_channel", "champion_model_depth")
    model.add_child(rig)

    var role_color := _champion_kit_role_color(champion, accent)
    var shadow_mat := _mat(champion + "_painterly_depth_shadow", Color(0.002, 0.004, 0.012, 0.30), 0.0, true, true)
    var body_mat := _mat(champion + "_painterly_depth_body_step", Color(role_color.darkened(0.42).r, role_color.darkened(0.42).g, role_color.darkened(0.42).b, 0.32), 0.08, true, true)
    var rim_mat := _mat(champion + "_painterly_depth_rim", Color(role_color.r, role_color.g, role_color.b, 0.24), 0.38, true, true)
    var gold_mat := _mat(champion + "_painterly_depth_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.22), 0.24, true, true)

    var value_shadow := Node3D.new()
    value_shadow.name = "ChampionPainterlyValueShadow"
    rig.add_child(value_shadow)
    _add_cylinder_segments(value_shadow, 0.74 * scale, 0.008 * scale, 8, shadow_mat, Vector3(0, 0.104, -0.08) * scale, Vector3(0, 22.5, 0))
    _add_box(value_shadow, Vector3(0.52, 0.010, 0.20) * scale, shadow_mat, Vector3(0, 1.08, -0.145) * scale)

    var rim := Node3D.new()
    rim.name = "ChampionPainterlyRimStroke"
    rig.add_child(rim)
    for side in [-1.0, 1.0]:
        _add_box(rim, Vector3(0.055, 0.018, 0.92) * scale, rim_mat, Vector3(side * 0.43, 1.02, 0.20) * scale, Vector3(0, side * 10.0, side * 9.0))
        _add_box(rim, Vector3(0.22, 0.016, 0.050) * scale, gold_mat, Vector3(side * 0.32, 1.44, 0.235) * scale, Vector3(0, side * 12.0, 0))

    var steps := Node3D.new()
    steps.name = "ChampionPainterlyMaterialSteps"
    steps.set_meta("material_grade", "painted_depth_low_glare")
    rig.add_child(steps)
    for step in range(3):
        var step_x := (-0.19 + float(step) * 0.19) * scale
        var step_y := (0.82 + float(step) * 0.13) * scale
        var step_mat := body_mat if step == 0 else rim_mat if step == 1 else gold_mat
        var mark := _add_box(steps, Vector3(0.115, 0.012, 0.060) * scale, step_mat, Vector3(step_x, step_y, 0.335 * scale), Vector3(0, 0, -10.0 + float(step) * 10.0))
        mark.name = "ChampionPainterlyMaterialStep%d" % step

    var detail := Node3D.new()
    detail.name = _champion_painterly_depth_detail_name(champion)
    detail.set_meta("champion", champion)
    detail.set_meta("material_grade", "painted_depth_low_glare")
    rig.add_child(detail)
    match champion:
        "jinx":
            _add_box(detail, Vector3(0.13, 0.016, 0.90) * scale, rim_mat, Vector3(-0.42, 1.52, -0.20) * scale, Vector3(0, -24, 15))
            _add_box(detail, Vector3(0.13, 0.016, 0.90) * scale, rim_mat, Vector3(0.42, 1.52, -0.20) * scale, Vector3(0, 24, -15))
            _add_sphere(detail, 0.042 * scale, gold_mat, Vector3(0.0, 1.68, 0.22) * scale)
        "senna":
            _add_box(detail, Vector3(1.02, 0.014, 0.055) * scale, gold_mat, Vector3(0, 1.50, 0.22) * scale)
            _add_cylinder_segments(detail, 0.46 * scale, 0.008 * scale, 28, rim_mat, Vector3(0, 1.43, -0.30) * scale, Vector3(90, 0, 0))
        "samira":
            for slash in range(3):
                var offset := float(slash) - 1.0
                _add_box(detail, Vector3(0.052, 0.014, 0.70) * scale, rim_mat, Vector3(offset * 0.18 * scale, 1.47 * scale, 0.18 * scale), Vector3(0, offset * 22.0, offset * 24.0))
        "viktor":
            _add_cylinder_segments(detail, 0.34 * scale, 0.008 * scale, 6, rim_mat, Vector3(0, 1.44, 0.30) * scale, Vector3(90, 0, 30))
            _add_box(detail, Vector3(0.060, 0.014, 0.76) * scale, gold_mat, Vector3(0.34, 1.56, -0.12) * scale, Vector3(14, 0, 0))
        "xayah":
            for plume in range(5):
                var offset := float(plume) - 2.0
                _add_box(detail, Vector3(0.052, 0.012, 0.70 - abs(offset) * 0.045) * scale, rim_mat, Vector3(offset * 0.11 * scale, 1.48 * scale, -0.24 * scale), Vector3(0, offset * 13.0, offset * 20.0))
        "mordekaiser":
            _add_box(detail, Vector3(0.74, 0.020, 0.18) * scale, shadow_mat, Vector3(0, 1.50, -0.18) * scale)
            _add_box(detail, Vector3(0.18, 0.016, 0.78) * scale, rim_mat, Vector3(0.50, 1.26, 0.16) * scale, Vector3(0, 28, 14))
        "teemo":
            _add_cylinder_segments(detail, 0.32 * scale, 0.014 * scale, 12, body_mat, Vector3(0, 1.74, 0.02) * scale)
            _add_box(detail, Vector3(0.56, 0.012, 0.060) * scale, gold_mat, Vector3(0, 1.54, 0.34) * scale)
        "aurelion_sol":
            _add_cylinder_segments(detail, 0.60 * scale, 0.008 * scale, 36, rim_mat, Vector3(0, 1.54, 0.02) * scale, Vector3(90, 0, 0))
            for star in range(3):
                var angle := TAU * float(star) / 3.0
                _add_sphere(detail, 0.040 * scale, gold_mat, Vector3(cos(angle) * 0.46 * scale, 1.55 * scale, sin(angle) * 0.24 * scale))
        _:
            _add_box(detail, Vector3(0.50, 0.014, 0.16) * scale, rim_mat, Vector3(0, 1.46, 0.18) * scale)

func _champion_painterly_depth_detail_name(champion: String) -> String:
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

func _champion_premium_silhouette_family(champion: String) -> String:
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

func _champion_premium_detail_name(champion: String) -> String:
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

func _add_champion_kit_silhouette(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionKitSilhouette") != null:
        return
    var role := _champion_kit_role(champion)
    var role_color := _champion_kit_role_color(champion, accent)
    var kit := Node3D.new()
    kit.name = "ChampionKitSilhouette"
    kit.set_meta("champion", champion)
    kit.set_meta("kit_role", role)
    model.add_child(kit)

    var dark := _mat(champion + "_kit_dark", Color(0.010, 0.012, 0.020, 0.58), 0.02, true, true)
    var role_soft := _mat(champion + "_kit_role_soft", Color(role_color.r, role_color.g, role_color.b, 0.28), 0.88, true, true)
    var role_hot := _mat(champion + "_kit_role_hot", Color(role_color.r, role_color.g, role_color.b, 0.62), 1.12, true, true)
    var gold := _mat(champion + "_kit_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.50), 0.78, true, true)

    var role_plate := Node3D.new()
    role_plate.name = "ChampionKitRolePlate"
    role_plate.set_meta("kit_role", role)
    kit.add_child(role_plate)
    _add_cylinder_segments(role_plate, 0.72 * scale, 0.014 * scale, 6, dark, Vector3(0, 0.196, -1.02) * scale, Vector3(0, 30, 0))
    _add_cylinder_segments(role_plate, 0.61 * scale, 0.010 * scale, 6, role_soft, Vector3(0, 0.212, -1.02) * scale, Vector3(0, 30, 0))
    _add_cylinder_segments(role_plate, 0.42 * scale, 0.008 * scale, 6, gold, Vector3(0, 0.228, -1.02) * scale, Vector3(0, 30, 0))
    if role.contains("marksman") or role == "trapper":
        for lane in range(3):
            var lane_offset := float(lane) - 1.0
            _add_box(role_plate, Vector3(0.060, 0.008, 0.72) * scale, role_hot, Vector3(lane_offset * 0.20, 0.242, -1.02) * scale, Vector3(0, lane_offset * 10.0, 0))
    elif role == "duelist":
        for slash in range(4):
            var slash_offset := float(slash) - 1.5
            _add_box(role_plate, Vector3(0.078, 0.008, 0.78) * scale, role_hot, Vector3(slash_offset * 0.10, 0.242, -1.02) * scale, Vector3(0, -36.0 + float(slash) * 24.0, 0))
    elif role == "juggernaut":
        _add_cylinder_segments(role_plate, 0.50 * scale, 0.010 * scale, 8, role_hot, Vector3(0, 0.246, -1.02) * scale, Vector3(0, 22.5, 0))
        for chain in range(6):
            var chain_angle := TAU * float(chain) / 6.0
            _add_box(role_plate, Vector3(0.18, 0.008, 0.060) * scale, dark, Vector3(cos(chain_angle) * 0.48, 0.262, -1.02 + sin(chain_angle) * 0.34) * scale, Vector3(0, -rad_to_deg(chain_angle), 0))
    else:
        _add_cylinder_segments(role_plate, 0.46 * scale, 0.010 * scale, 12, role_hot, Vector3(0, 0.246, -1.02) * scale, Vector3(0, 15, 0))
        for spoke in range(6):
            var spoke_angle := TAU * float(spoke) / 6.0
            _add_box(role_plate, Vector3(0.038, 0.008, 0.42) * scale, role_soft, Vector3(cos(spoke_angle) * 0.28, 0.260, -1.02 + sin(spoke_angle) * 0.28) * scale, Vector3(0, -rad_to_deg(spoke_angle), 0))

    var weapon := Node3D.new()
    weapon.name = "ChampionKitWeaponIcon"
    weapon.set_meta("weapon_signature", champion)
    weapon.set_meta("kit_role", role)
    kit.add_child(weapon)

    var passive := Node3D.new()
    passive.name = "ChampionKitPassiveMotif"
    passive.set_meta("champion", champion)
    kit.add_child(passive)

    match champion:
        "jinx":
            var blue := Color(0.22, 0.80, 1.0)
            var pink := Color(1.0, 0.24, 0.64)
            _add_box(weapon, Vector3(0.22, 0.040, 1.58) * scale, _mat("jinx_kit_fishbones_body", blue, 0.78, true), Vector3(0.40, 2.03, 0.72) * scale, Vector3(0, 22, 0))
            _add_tapered_cylinder(weapon, 0.18 * scale, 0.040 * scale, 0.40 * scale, 12, _mat("jinx_kit_fishbones_nose", pink, 1.04, true), Vector3(0.66, 2.04, 1.38) * scale, Vector3(90, 22, 0))
            _add_box(weapon, Vector3(0.72, 0.030, 0.16) * scale, _mat("jinx_kit_rocket_fins", Color(1.0, 0.74, 0.20), 0.44, true), Vector3(0.10, 2.06, 0.22) * scale, Vector3(0, 22, 0))
            for barrel in range(3):
                _add_cylinder(weapon, 0.040 * scale, 1.05 * scale, _mat("jinx_kit_powpow_barrel_" + str(barrel), Color(0.05, 0.08, 0.12), 0.10, true), Vector3(-0.42 + float(barrel) * 0.085, 1.98 + float(barrel % 2) * 0.045, 0.74) * scale, Vector3(90, -18, 0))
            for bead in range(6):
                var bead_color := blue if bead % 2 == 0 else pink
                _add_sphere(passive, 0.046 * scale, _mat("jinx_kit_ammo_bead_" + str(bead), bead_color, 1.05, true), Vector3(-0.58 + float(bead) * 0.23, 0.330, -0.34 + sin(float(bead)) * 0.05) * scale)
        "senna":
            var soul := Color(0.58, 1.0, 0.78)
            _add_box(weapon, Vector3(0.34, 0.045, 2.10) * scale, _mat("senna_kit_relic_cannon", Color(0.06, 0.13, 0.12), 0.06, true), Vector3(0, 2.02, 0.82) * scale)
            _add_box(weapon, Vector3(1.02, 0.036, 0.20) * scale, gold, Vector3(0, 2.05, 0.16) * scale)
            _add_cylinder_segments(weapon, 0.42 * scale, 0.030 * scale, 28, _mat("senna_kit_soul_muzzle", soul, 1.18, true), Vector3(0, 2.07, 1.86) * scale, Vector3(90, 0, 0))
            _add_cylinder_segments(passive, 0.58 * scale, 0.012 * scale, 32, _mat("senna_kit_absolution_gate", Color(soul.r, soul.g, soul.b, 0.36), 1.04, true, true), Vector3(0, 1.36, -0.50) * scale, Vector3(90, 0, 0))
            for mote in range(5):
                var mote_angle := TAU * float(mote) / 5.0
                _add_sphere(passive, 0.050 * scale, _mat("senna_kit_soul_mote_" + str(mote), soul, 1.18, true), Vector3(cos(mote_angle) * 0.72, 1.38 + sin(mote_angle * 2.0) * 0.08, -0.50 + sin(mote_angle) * 0.20) * scale)
        "samira":
            var red := Color(1.0, 0.28, 0.12)
            for side in [-1.0, 1.0]:
                _add_box(weapon, Vector3(0.12, 0.036, 1.20) * scale, _mat("samira_kit_blade_" + str(side), red, 1.02, true), Vector3(side * 0.26, 2.03, 0.58) * scale, Vector3(0, side * 32.0, side * 22.0))
                _add_box(weapon, Vector3(0.20, 0.034, 0.78) * scale, _mat("samira_kit_pistol_" + str(side), Color(0.16, 0.06, 0.04), 0.14, true), Vector3(side * 0.52, 1.98, 0.12) * scale, Vector3(0, side * -18.0, side * 10.0))
            _add_cylinder_segments(passive, 0.76 * scale, 0.012 * scale, 30, _mat("samira_kit_style_meter", Color(red.r, red.g, red.b, 0.34), 1.0, true, true), Vector3(0, 0.314, 0.08) * scale)
            for slash in range(5):
                var slash_offset := float(slash) - 2.0
                _add_box(passive, Vector3(0.070, 0.010, 0.88) * scale, _mat("samira_kit_combo_slash_" + str(slash), Color(1.0, 0.68, 0.22, 0.52), 1.04, true, true), Vector3(slash_offset * 0.16, 0.336, 0.08) * scale, Vector3(0, slash_offset * 14.0, 0))
        "viktor":
            var arc := Color(0.72, 0.94, 1.0)
            _add_cylinder(weapon, 0.050 * scale, 1.42 * scale, _mat("viktor_kit_staff", arc, 1.05, true), Vector3(0.42, 2.05, 0.56) * scale, Vector3(26, 0, 0))
            _add_sphere(weapon, 0.18 * scale, _mat("viktor_kit_hexcore", Color(0.84, 0.74, 1.0), 1.30, true), Vector3(0.0, 2.05, 0.26) * scale)
            _add_cylinder_segments(weapon, 0.32 * scale, 0.020 * scale, 6, _mat("viktor_kit_hexcore_frame", Color(arc.r, arc.g, arc.b, 0.48), 1.05, true, true), Vector3(0.0, 2.07, 0.26) * scale, Vector3(90, 0, 30))
            for arm in range(3):
                var arm_angle := TAU * float(arm) / 3.0
                _add_box(passive, Vector3(0.046, 0.010, 0.74) * scale, _mat("viktor_kit_circuit_" + str(arm), Color(arc.r, arc.g, arc.b, 0.44), 1.0, true, true), Vector3(cos(arm_angle) * 0.42, 0.322, 0.28 + sin(arm_angle) * 0.42) * scale, Vector3(0, -rad_to_deg(arm_angle), 0))
            _add_cylinder_segments(passive, 0.58 * scale, 0.010 * scale, 6, _mat("viktor_kit_evolution_hex", Color(arc.r, arc.g, arc.b, 0.30), 0.96, true, true), Vector3(0, 0.304, 0.28) * scale, Vector3(0, 30, 0))
        "xayah":
            var feather := Color(1.0, 0.30, 0.68)
            for plume in range(7):
                var plume_offset := float(plume) - 3.0
                _add_box(weapon, Vector3(0.075, 0.034, 1.20 - abs(plume_offset) * 0.075) * scale, _mat("xayah_kit_feather_fan_" + str(plume), feather, 0.94, true), Vector3(plume_offset * 0.16, 2.03, 0.35 + abs(plume_offset) * 0.06) * scale, Vector3(0, plume_offset * 11.0, plume_offset * 12.0))
            _add_cylinder_segments(passive, 0.68 * scale, 0.010 * scale, 5, _mat("xayah_kit_recall_star", Color(feather.r, feather.g, feather.b, 0.34), 1.0, true, true), Vector3(0, 0.314, -0.08) * scale, Vector3(0, 18, 0))
            for pin in range(5):
                var pin_offset := float(pin) - 2.0
                _add_box(passive, Vector3(0.054, 0.010, 0.70) * scale, _mat("xayah_kit_recall_feather_" + str(pin), feather, 1.0, true), Vector3(pin_offset * 0.17, 0.340, -0.16 + abs(pin_offset) * 0.035) * scale, Vector3(0, pin_offset * 9.0, 0))
        "mordekaiser":
            var realm := Color(0.42, 1.0, 0.46)
            _add_box(weapon, Vector3(0.34, 0.045, 1.56) * scale, _mat("morde_kit_nightfall_handle", Color(0.08, 0.18, 0.12), 0.22, true), Vector3(0.18, 2.02, 0.54) * scale, Vector3(0, -30, 0))
            _add_box(weapon, Vector3(0.98, 0.052, 0.44) * scale, _mat("morde_kit_nightfall_head", realm, 0.82, true), Vector3(0.66, 2.06, 1.02) * scale, Vector3(0, -30, 0))
            _add_cylinder_segments(weapon, 0.36 * scale, 0.018 * scale, 8, _mat("morde_kit_hammer_rune", Color(realm.r, realm.g, realm.b, 0.50), 1.0, true, true), Vector3(0.66, 2.10, 1.26) * scale, Vector3(90, 0, 22.5))
            _add_cylinder_segments(passive, 0.86 * scale, 0.012 * scale, 8, _mat("morde_kit_death_realm", Color(realm.r, realm.g, realm.b, 0.28), 0.98, true, true), Vector3(0, 0.314, 0) * scale, Vector3(0, 22.5, 0))
            for link in range(8):
                var link_angle := TAU * float(link) / 8.0
                _add_box(passive, Vector3(0.18, 0.012, 0.066) * scale, dark, Vector3(cos(link_angle) * 0.72, 0.340, sin(link_angle) * 0.54) * scale, Vector3(0, -rad_to_deg(link_angle), 0))
        "teemo":
            var poison := Color(0.62, 1.0, 0.22)
            _add_cylinder(weapon, 0.044 * scale, 1.10 * scale, _mat("teemo_kit_blowgun", Color(0.44, 0.28, 0.12), 0.10, true), Vector3(0.42, 2.00, 0.62) * scale, Vector3(78, 0, 0))
            _add_cylinder(weapon, 0.18 * scale, 0.20 * scale, _mat("teemo_kit_mushroom_stem", Color(0.86, 0.76, 0.54), 0.10, true), Vector3(-0.18, 1.92, 0.34) * scale)
            _add_sphere(weapon, 0.30 * scale, _mat("teemo_kit_mushroom_cap", Color(0.82, 0.16, 0.14), 0.64, true), Vector3(-0.18, 2.10, 0.34) * scale)
            for dot in range(3):
                _add_sphere(weapon, 0.040 * scale, _mat("teemo_kit_mushroom_dot_" + str(dot), Color(1.0, 0.90, 0.72), 0.40, true), Vector3(-0.30 + float(dot) * 0.12, 2.20, 0.55 - abs(float(dot) - 1.0) * 0.05) * scale)
            for trap in range(4):
                var trap_angle := TAU * float(trap) / 4.0
                _add_cylinder_segments(passive, 0.16 * scale, 0.010 * scale, 12, _mat("teemo_kit_trap_pad_" + str(trap), Color(poison.r, poison.g, poison.b, 0.32), 0.92, true, true), Vector3(cos(trap_angle) * 0.58, 0.320, sin(trap_angle) * 0.42) * scale)
                _add_sphere(passive, 0.040 * scale, _mat("teemo_kit_trap_spore_" + str(trap), poison, 1.02, true), Vector3(cos(trap_angle) * 0.58, 0.362, sin(trap_angle) * 0.42) * scale)
        "aurelion_sol":
            var star := Color(0.92, 0.72, 1.0)
            _add_tapered_cylinder(weapon, 0.060 * scale, 0.018 * scale, 1.44 * scale, 8, _mat("asol_kit_comet_body", Color(0.68, 0.86, 1.0), 1.18, true), Vector3(0.34, 2.06, 0.80) * scale, Vector3(74, -28, 0))
            _add_sphere(weapon, 0.20 * scale, _mat("asol_kit_star_core", Color(1.0, 0.86, 0.50), 1.35, true), Vector3(-0.24, 2.08, 0.36) * scale)
            _add_cylinder_segments(weapon, 0.68 * scale, 0.012 * scale, 36, _mat("asol_kit_celestial_orbit", Color(star.r, star.g, star.b, 0.34), 1.0, true, true), Vector3(0, 2.08, 0.30) * scale, Vector3(90, 0, 0))
            _add_cylinder_segments(passive, 1.02 * scale, 0.010 * scale, 48, _mat("asol_kit_starfield_orbit", Color(star.r, star.g, star.b, 0.24), 1.0, true, true), Vector3(0, 0.314, 0) * scale)
            for star_index in range(6):
                var star_angle := TAU * float(star_index) / 6.0
                _add_sphere(passive, 0.050 * scale, _mat("asol_kit_orbit_star_" + str(star_index), Color(1.0, 0.86, 0.50), 1.28, true), Vector3(cos(star_angle) * 0.86, 0.350, sin(star_angle) * 0.58) * scale)
        _:
            _add_box(weapon, Vector3(0.18, 0.030, 1.10) * scale, role_hot, Vector3(0, 2.02, 0.62) * scale)
            _add_cylinder_segments(passive, 0.72 * scale, 0.010 * scale, 6, role_soft, Vector3(0, 0.314, 0) * scale, Vector3(0, 30, 0))

func _sync_champion_kit_silhouette(model: Node3D) -> void:
    var kit := model.get_node_or_null("ChampionKitSilhouette") as Node3D
    if kit == null:
        return
    var champion := str(kit.get_meta("champion", ""))
    var time := Time.get_ticks_msec() / 1000.0
    kit.position.y = sin(time * 1.40) * 0.006
    var weapon := kit.get_node_or_null("ChampionKitWeaponIcon") as Node3D
    if weapon != null:
        var weapon_sway := 0.030
        match champion:
            "jinx", "samira", "teemo":
                weapon_sway = 0.060
            "mordekaiser":
                weapon_sway = 0.022
            "aurelion_sol":
                weapon_sway = -0.040
            _:
                weapon_sway = 0.035
        weapon.rotation.y = sin(time * (1.8 if champion == "jinx" or champion == "samira" else 1.15)) * weapon_sway
        weapon.position.y = sin(time * 2.0) * 0.012
    var passive := kit.get_node_or_null("ChampionKitPassiveMotif") as Node3D
    if passive != null:
        var spin := 0.22
        match champion:
            "aurelion_sol":
                spin = 0.58
            "jinx", "samira", "teemo":
                spin = 0.36
            "mordekaiser":
                spin = 0.12
            _:
                spin = 0.22
        passive.rotation.y = time * spin
    var role_plate := kit.get_node_or_null("ChampionKitRolePlate") as Node3D
    if role_plate != null:
        role_plate.scale = Vector3.ONE * (1.0 + sin(time * 1.9) * 0.018)

func _champion_kit_role(champion: String) -> String:
    match champion:
        "jinx":
            return "marksman"
        "senna":
            return "artillery_marksman"
        "samira":
            return "duelist"
        "viktor":
            return "control_mage"
        "xayah":
            return "feather_marksman"
        "mordekaiser":
            return "juggernaut"
        "teemo":
            return "trapper"
        "aurelion_sol":
            return "cosmic_mage"
        _:
            return "adventurer"

func _champion_kit_role_color(champion: String, accent: Color) -> Color:
    match _champion_kit_role(champion):
        "marksman":
            return Color(0.28, 0.82, 1.0)
        "artillery_marksman":
            return Color(0.58, 1.0, 0.78)
        "duelist":
            return Color(1.0, 0.32, 0.14)
        "control_mage":
            return Color(0.72, 0.94, 1.0)
        "feather_marksman":
            return Color(1.0, 0.30, 0.68)
        "juggernaut":
            return Color(0.42, 1.0, 0.46)
        "trapper":
            return Color(0.62, 1.0, 0.22)
        "cosmic_mage":
            return Color(0.92, 0.72, 1.0)
        _:
            return accent

func _add_champion_combat_stance_rig(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionCombatStanceRig") != null:
        return
    var stance := Node3D.new()
    stance.name = "ChampionCombatStanceRig"
    stance.set_meta("champion", champion)
    stance.set_meta("combat_class", _champion_combat_class(champion))
    stance.set_meta("range_band", _champion_range_band(champion))
    stance.set_meta("detail_node", _champion_combat_stance_detail_name(champion))
    model.add_child(stance)

    var class_color := _champion_kit_role_color(champion, accent)
    var dark := _mat(champion + "_stance_dark", Color(0.006, 0.008, 0.018, 0.44), 0.02, true, true)
    var soft := _mat(champion + "_stance_soft", Color(class_color.r, class_color.g, class_color.b, 0.24), 0.86, true, true)
    var hot := _mat(champion + "_stance_hot", Color(class_color.lightened(0.12).r, class_color.lightened(0.12).g, class_color.lightened(0.12).b, 0.54), 1.12, true, true)
    var gold := _mat(champion + "_stance_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.40), 0.78, true, true)
    var y := 0.170 * scale

    var base := Node3D.new()
    base.name = "ChampionStanceBase"
    stance.add_child(base)
    _add_cylinder_segments(base, 1.08 * scale, 0.010 * scale, 6, dark, Vector3(0, y, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(base, 0.88 * scale, 0.008 * scale, 6, soft, Vector3(0, y + 0.016 * scale, 0), Vector3(0, 30, 0))
    for tick in range(6):
        var tick_angle := TAU * float(tick) / 6.0
        _add_box(base, Vector3(0.065, 0.008, 0.30) * scale, gold, Vector3(cos(tick_angle) * 0.86 * scale, y + 0.030 * scale, sin(tick_angle) * 0.86 * scale), Vector3(0, -rad_to_deg(tick_angle), 0))

    var facing := Node3D.new()
    facing.name = "ChampionStanceFacingMarker"
    stance.add_child(facing)
    _add_box(facing, Vector3(0.12, 0.010, 1.08) * scale, hot, Vector3(0, y + 0.048 * scale, 0.56 * scale))
    _add_tapered_cylinder(facing, 0.090 * scale, 0.018 * scale, 0.34 * scale, 6, hot, Vector3(0, y + 0.060 * scale, 1.10 * scale), Vector3(90, 0, 0))

    var range_band := Node3D.new()
    range_band.name = "ChampionStanceRangeBand"
    range_band.set_meta("range_band", _champion_range_band(champion))
    stance.add_child(range_band)
    match _champion_range_band(champion):
        "melee":
            _add_cylinder_segments(range_band, 0.72 * scale, 0.010 * scale, 18, soft, Vector3(0, y + 0.040 * scale, 0))
            for arc in range(4):
                var arc_angle := -48.0 + float(arc) * 32.0
                _add_box(range_band, Vector3(0.095, 0.010, 0.72) * scale, hot, Vector3((float(arc) - 1.5) * 0.11 * scale, y + 0.058 * scale, 0.18 * scale), Vector3(0, arc_angle, 0))
        "summoner":
            _add_cylinder_segments(range_band, 1.00 * scale, 0.008 * scale, 12, soft, Vector3(0, y + 0.040 * scale, 0), Vector3(0, 15, 0))
            for pad in range(4):
                var pad_angle := TAU * float(pad) / 4.0
                _add_sphere(range_band, 0.042 * scale, hot, Vector3(cos(pad_angle) * 0.74 * scale, y + 0.076 * scale, sin(pad_angle) * 0.54 * scale))
        "mage":
            _add_cylinder_segments(range_band, 1.02 * scale, 0.008 * scale, 6, soft, Vector3(0, y + 0.040 * scale, 0), Vector3(0, 30, 0))
            for spoke in range(6):
                var spoke_angle := TAU * float(spoke) / 6.0
                _add_box(range_band, Vector3(0.040, 0.008, 0.55) * scale, hot, Vector3(cos(spoke_angle) * 0.38 * scale, y + 0.060 * scale, sin(spoke_angle) * 0.38 * scale), Vector3(0, -rad_to_deg(spoke_angle), 0))
        _:
            _add_box(range_band, Vector3(0.060, 0.008, 1.18) * scale, soft, Vector3(-0.22 * scale, y + 0.044 * scale, 0.42 * scale), Vector3(0, -8, 0))
            _add_box(range_band, Vector3(0.060, 0.008, 1.18) * scale, hot, Vector3(0.22 * scale, y + 0.052 * scale, 0.42 * scale), Vector3(0, 8, 0))
            _add_box(range_band, Vector3(0.050, 0.008, 0.92) * scale, gold, Vector3(0, y + 0.060 * scale, 0.56 * scale))

    var detail := Node3D.new()
    detail.name = _champion_combat_stance_detail_name(champion)
    detail.set_meta("champion", champion)
    detail.set_meta("combat_class", _champion_combat_class(champion))
    stance.add_child(detail)

    match champion:
        "jinx":
            _add_box(detail, Vector3(0.20, 0.014, 1.36) * scale, _mat("jinx_stance_rocket", Color(0.22, 0.82, 1.0, 0.56), 1.12, true, true), Vector3(0.42 * scale, y + 0.088 * scale, 0.74 * scale), Vector3(0, 20, 0))
            _add_box(detail, Vector3(0.15, 0.012, 0.88) * scale, _mat("jinx_stance_minigun", Color(1.0, 0.28, 0.64, 0.52), 1.08, true, true), Vector3(-0.34 * scale, y + 0.082 * scale, 0.52 * scale), Vector3(0, -14, 0))
            for spark in range(4):
                _add_sphere(detail, 0.034 * scale, hot, Vector3((-0.36 + float(spark) * 0.24) * scale, y + 0.116 * scale, (-0.20 + abs(float(spark) - 1.5) * 0.12) * scale))
        "senna":
            _add_box(detail, Vector3(0.18, 0.014, 1.84) * scale, hot, Vector3(0, y + 0.090 * scale, 0.84 * scale))
            _add_cylinder_segments(detail, 0.58 * scale, 0.010 * scale, 28, soft, Vector3(0, y + 0.114 * scale, 0.72 * scale), Vector3(90, 0, 0))
            _add_box(detail, Vector3(1.02, 0.010, 0.070) * scale, gold, Vector3(0, y + 0.130 * scale, 0.22 * scale))
        "samira":
            _add_cylinder_segments(detail, 0.76 * scale, 0.010 * scale, 24, soft, Vector3(0, y + 0.074 * scale, 0))
            for slash in range(5):
                var slash_offset := float(slash) - 2.0
                _add_box(detail, Vector3(0.080, 0.014, 0.90) * scale, hot, Vector3(slash_offset * 0.10 * scale, y + 0.100 * scale, 0.18 * scale), Vector3(0, -48.0 + float(slash) * 24.0, 0))
        "viktor":
            _add_cylinder_segments(detail, 0.62 * scale, 0.010 * scale, 6, hot, Vector3(0, y + 0.084 * scale, 0.12 * scale), Vector3(0, 30, 0))
            _add_box(detail, Vector3(0.110, 0.014, 1.64) * scale, _mat("viktor_stance_laser", Color(0.72, 0.94, 1.0, 0.58), 1.24, true, true), Vector3(0.44 * scale, y + 0.108 * scale, 0.78 * scale), Vector3(0, 14, 0))
            for node in range(3):
                var node_angle := TAU * float(node) / 3.0
                _add_sphere(detail, 0.040 * scale, gold, Vector3(cos(node_angle) * 0.42 * scale, y + 0.128 * scale, sin(node_angle) * 0.30 * scale + 0.14 * scale))
        "xayah":
            for feather in range(7):
                var offset := float(feather) - 3.0
                _add_box(detail, Vector3(0.060, 0.014, 0.86 - abs(offset) * 0.050) * scale, hot, Vector3(offset * 0.14 * scale, y + 0.096 * scale, -0.06 * scale + abs(offset) * 0.045 * scale), Vector3(0, offset * -11.0, 0))
            _add_cylinder_segments(detail, 0.50 * scale, 0.008 * scale, 5, soft, Vector3(0, y + 0.118 * scale, -0.05 * scale), Vector3(0, 18, 0))
        "mordekaiser":
            _add_cylinder_segments(detail, 0.86 * scale, 0.010 * scale, 8, soft, Vector3(0, y + 0.074 * scale, 0), Vector3(0, 22.5, 0))
            _add_box(detail, Vector3(0.32, 0.016, 1.28) * scale, hot, Vector3(0.20 * scale, y + 0.104 * scale, 0.32 * scale), Vector3(0, -28, 0))
            _add_box(detail, Vector3(0.86, 0.016, 0.32) * scale, hot, Vector3(0.54 * scale, y + 0.126 * scale, 0.64 * scale), Vector3(0, -28, 0))
        "teemo":
            _add_box(detail, Vector3(0.12, 0.010, 1.16) * scale, hot, Vector3(0.38 * scale, y + 0.090 * scale, 0.58 * scale), Vector3(0, 18, 0))
            _add_cylinder_segments(detail, 0.62 * scale, 0.008 * scale, 16, soft, Vector3(0, y + 0.082 * scale, 0.04 * scale))
            for spore in range(5):
                var spore_angle := TAU * float(spore) / 5.0
                _add_sphere(detail, 0.034 * scale, hot, Vector3(cos(spore_angle) * 0.44 * scale, y + 0.116 * scale, sin(spore_angle) * 0.30 * scale + 0.04 * scale))
        "aurelion_sol":
            _add_cylinder_segments(detail, 0.98 * scale, 0.008 * scale, 40, soft, Vector3(0, y + 0.076 * scale, 0), Vector3(0, 12, 0))
            _add_tapered_cylinder(detail, 0.056 * scale, 0.010 * scale, 1.16 * scale, 8, hot, Vector3(0.34 * scale, y + 0.110 * scale, 0.46 * scale), Vector3(74, -30, 0))
            for star in range(5):
                var star_angle := TAU * float(star) / 5.0
                _add_sphere(detail, 0.042 * scale, _mat("asol_stance_star_" + str(star), Color(1.0, 0.86, 0.50), 1.25, true), Vector3(cos(star_angle) * 0.72 * scale, y + 0.128 * scale, sin(star_angle) * 0.48 * scale))
        _:
            _add_box(detail, Vector3(0.68, 0.010, 0.070) * scale, hot, Vector3(0, y + 0.092 * scale, 0))
            _add_box(detail, Vector3(0.070, 0.010, 0.68) * scale, hot, Vector3(0, y + 0.094 * scale, 0))

func _sync_champion_combat_stance_rig(model: Node3D, player: Node2D) -> void:
    var stance := model.get_node_or_null("ChampionCombatStanceRig") as Node3D
    if stance == null:
        return
    var champion := str(stance.get_meta("champion", ""))
    var attack_timer := maxf(0.0, float(player.get("attack_timer")))
    var attack_cooldown := maxf(0.16, float(player.get("attack_cooldown")))
    var readiness := 1.0 - clampf(attack_timer / attack_cooldown, 0.0, 1.0)
    var time := Time.get_ticks_msec() / 1000.0
    stance.set_meta("attack_readiness", readiness)
    stance.position.y = sin(time * 1.55) * 0.004

    var facing := stance.get_node_or_null("ChampionStanceFacingMarker") as Node3D
    if facing != null:
        facing.scale = Vector3(0.92 + readiness * 0.18, 1.0, 0.92 + readiness * 0.32)
        facing.position.z = readiness * 0.035

    var range_band := stance.get_node_or_null("ChampionStanceRangeBand") as Node3D
    if range_band != null:
        var band_pulse := 1.0 + readiness * 0.060 + sin(time * _champion_combat_stance_pulse(champion)) * 0.018
        range_band.scale = Vector3(band_pulse, 1.0, band_pulse)
        range_band.rotation.y += _champion_combat_stance_spin(champion)

    var detail := stance.get_node_or_null(_champion_combat_stance_detail_name(champion)) as Node3D
    if detail != null:
        detail.scale = Vector3.ONE * (0.94 + readiness * 0.14)
        detail.position.y = sin(time * (_champion_combat_stance_pulse(champion) + 0.7)) * 0.006
        match _champion_range_band(champion):
            "melee":
                detail.rotation.y += 0.034 + readiness * 0.018
            "mage", "summoner":
                detail.rotation.y -= 0.020 + readiness * 0.010
            _:
                detail.rotation.y += 0.012 + readiness * 0.008

func _champion_combat_class(champion: String) -> String:
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

func _champion_range_band(champion: String) -> String:
    match champion:
        "samira", "mordekaiser":
            return "melee"
        "viktor", "aurelion_sol":
            return "mage"
        "teemo":
            return "summoner"
        _:
            return "ranged"

func _champion_combat_stance_detail_name(champion: String) -> String:
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

func _champion_combat_stance_spin(champion: String) -> float:
    match champion:
        "samira":
            return 0.030
        "mordekaiser":
            return 0.014
        "viktor":
            return -0.016
        "aurelion_sol":
            return -0.028
        "teemo":
            return 0.022
        _:
            return 0.012

func _champion_combat_stance_pulse(champion: String) -> float:
    match champion:
        "jinx", "samira":
            return 4.2
        "teemo":
            return 3.2
        "mordekaiser":
            return 2.0
        "aurelion_sol":
            return 2.6
        _:
            return 3.0

func _add_champion_archetype_silhouette_rig(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionArchetypeSilhouetteRig") != null:
        return
    var archetype := _champion_archetype_family(champion)
    var detail_name := _champion_archetype_detail_name(champion)
    var rig := Node3D.new()
    rig.name = "ChampionArchetypeSilhouetteRig"
    rig.set_meta("champion", champion)
    rig.set_meta("archetype_family", archetype)
    rig.set_meta("combat_class", _champion_combat_class(champion))
    rig.set_meta("range_band", _champion_range_band(champion))
    rig.set_meta("detail_node", detail_name)
    rig.set_meta("material_grade", "low_glare_archetype_silhouette")
    rig.set_meta("combat_visual_channel", "champion_archetype_readability")
    model.add_child(rig)

    var role_color := _champion_kit_role_color(champion, accent)
    var dark := _mat(champion + "_archetype_dark_matte", Color(0.004, 0.006, 0.014, 0.44), 0.0, true, true)
    var shadow := _mat(champion + "_archetype_shadow", Color(0.0, 0.0, 0.0, 0.30), 0.0, true, true)
    var role_soft := _mat(champion + "_archetype_role_soft", Color(role_color.r, role_color.g, role_color.b, 0.30), 0.42, true, true)
    var role_hot := _mat(champion + "_archetype_role_hot", Color(role_color.lightened(0.12).r, role_color.lightened(0.12).g, role_color.lightened(0.12).b, 0.44), 0.66, true, true)
    var trim := _mat(champion + "_archetype_trim_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.30), 0.32, true, true)
    var y := 0.258 * scale
    var z := -1.34 * scale

    var base := Node3D.new()
    base.name = "ChampionArchetypeBasePlate"
    base.set_meta("archetype_family", archetype)
    rig.add_child(base)
    _add_cylinder_segments(base, 0.92 * scale, 0.010 * scale, 8, shadow, Vector3(0, y - 0.020 * scale, z), Vector3(0, 22.5, 0))
    _add_cylinder_segments(base, 0.78 * scale, 0.010 * scale, 6, dark, Vector3(0, y, z), Vector3(0, 30, 0))
    _add_cylinder_segments(base, 0.56 * scale, 0.008 * scale, 6, role_soft, Vector3(0, y + 0.018 * scale, z), Vector3(0, 30, 0))
    for tick in range(6):
        var tick_angle := TAU * float(tick) / 6.0
        _add_box(base, Vector3(0.050, 0.008, 0.24) * scale, trim, Vector3(cos(tick_angle) * 0.66 * scale, y + 0.034 * scale, z + sin(tick_angle) * 0.48 * scale), Vector3(0, -rad_to_deg(tick_angle), 0))

    var totem := Node3D.new()
    totem.name = "ChampionArchetypeRoleTotem"
    totem.set_meta("archetype_family", archetype)
    rig.add_child(totem)

    var routes := Node3D.new()
    routes.name = "ChampionArchetypeRouteGlyphs"
    routes.set_meta("archetype_family", archetype)
    rig.add_child(routes)
    for pip in range(3):
        var pip_angle := -0.70 + float(pip) * 0.70
        var pip_mesh := _add_sphere(routes, 0.042 * scale, role_hot if pip == 1 else trim, Vector3(cos(pip_angle) * 0.46 * scale, y + 0.072 * scale, z + 0.30 * scale + sin(pip_angle) * 0.16 * scale))
        pip_mesh.name = "ChampionArchetypeRouteGlyph%d" % pip

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("champion", champion)
    detail.set_meta("archetype_family", archetype)
    rig.add_child(detail)

    match champion:
        "jinx":
            _add_box(totem, Vector3(0.13, 0.012, 1.25) * scale, role_hot, Vector3(0.32 * scale, y + 0.062 * scale, z + 0.44 * scale), Vector3(0, 18, 0))
            _add_box(totem, Vector3(0.11, 0.012, 0.92) * scale, role_soft, Vector3(-0.30 * scale, y + 0.058 * scale, z + 0.34 * scale), Vector3(0, -14, 0))
            _add_tapered_cylinder(detail, 0.105 * scale, 0.018 * scale, 0.42 * scale, 8, role_hot, Vector3(0.48 * scale, y + 0.086 * scale, z + 1.03 * scale), Vector3(90, 18, 0))
            for spark in range(5):
                _add_sphere(detail, 0.030 * scale, trim, Vector3((-0.42 + float(spark) * 0.21) * scale, y + 0.100 * scale, z - 0.14 * scale + sin(float(spark)) * 0.08 * scale))
        "senna":
            _add_box(totem, Vector3(0.16, 0.012, 1.54) * scale, role_hot, Vector3(0, y + 0.062 * scale, z + 0.58 * scale))
            _add_box(totem, Vector3(0.92, 0.010, 0.070) * scale, trim, Vector3(0, y + 0.078 * scale, z + 0.18 * scale))
            _add_cylinder_segments(detail, 0.46 * scale, 0.008 * scale, 28, role_soft, Vector3(0, y + 0.096 * scale, z + 0.76 * scale), Vector3(90, 0, 0))
            for mote in range(4):
                var mote_angle := TAU * float(mote) / 4.0
                _add_sphere(detail, 0.034 * scale, role_hot, Vector3(cos(mote_angle) * 0.46 * scale, y + 0.118 * scale, z + 0.76 * scale + sin(mote_angle) * 0.18 * scale))
        "samira":
            _add_cylinder_segments(totem, 0.54 * scale, 0.008 * scale, 20, role_soft, Vector3(0, y + 0.052 * scale, z + 0.08 * scale))
            for slash in range(5):
                var slash_offset := float(slash) - 2.0
                _add_box(detail, Vector3(0.060, 0.012, 0.78) * scale, role_hot, Vector3(slash_offset * 0.10 * scale, y + 0.084 * scale, z + 0.20 * scale), Vector3(0, -52.0 + float(slash) * 26.0, 0))
            _add_box(totem, Vector3(0.58, 0.010, 0.058) * scale, trim, Vector3(0, y + 0.102 * scale, z - 0.22 * scale))
        "viktor":
            _add_cylinder_segments(totem, 0.52 * scale, 0.008 * scale, 6, role_hot, Vector3(0, y + 0.060 * scale, z + 0.16 * scale), Vector3(0, 30, 0))
            for spoke in range(6):
                var spoke_angle := TAU * float(spoke) / 6.0
                _add_box(totem, Vector3(0.032, 0.008, 0.50) * scale, role_soft, Vector3(cos(spoke_angle) * 0.25 * scale, y + 0.086 * scale, z + 0.16 * scale + sin(spoke_angle) * 0.25 * scale), Vector3(0, -rad_to_deg(spoke_angle), 0))
            _add_box(detail, Vector3(0.070, 0.014, 1.22) * scale, role_hot, Vector3(0.40 * scale, y + 0.114 * scale, z + 0.58 * scale), Vector3(0, 14, 0))
            _add_sphere(detail, 0.052 * scale, trim, Vector3(0, y + 0.128 * scale, z + 0.16 * scale))
        "xayah":
            for feather in range(7):
                var offset := float(feather) - 3.0
                _add_box(detail, Vector3(0.048, 0.010, 0.72 - abs(offset) * 0.045) * scale, role_hot if feather % 2 == 0 else role_soft, Vector3(offset * 0.13 * scale, y + 0.080 * scale, z + abs(offset) * 0.040 * scale), Vector3(0, offset * -12.0, 0))
            _add_cylinder_segments(totem, 0.44 * scale, 0.008 * scale, 5, trim, Vector3(0, y + 0.102 * scale, z), Vector3(0, 18, 0))
        "mordekaiser":
            _add_cylinder_segments(totem, 0.62 * scale, 0.010 * scale, 8, role_soft, Vector3(0, y + 0.052 * scale, z), Vector3(0, 22.5, 0))
            _add_box(detail, Vector3(0.24, 0.014, 1.05) * scale, role_hot, Vector3(0.26 * scale, y + 0.088 * scale, z + 0.24 * scale), Vector3(0, -28, 0))
            _add_box(detail, Vector3(0.76, 0.014, 0.28) * scale, role_hot, Vector3(0.58 * scale, y + 0.108 * scale, z + 0.52 * scale), Vector3(0, -28, 0))
            for side in [-1.0, 1.0]:
                _add_box(totem, Vector3(0.18, 0.010, 0.58) * scale, trim, Vector3(side * 0.42 * scale, y + 0.086 * scale, z - 0.08 * scale), Vector3(0, side * 18.0, 0))
        "teemo":
            _add_cylinder_segments(totem, 0.50 * scale, 0.008 * scale, 16, role_soft, Vector3(0, y + 0.052 * scale, z + 0.05 * scale))
            for trap in range(5):
                var trap_angle := TAU * float(trap) / 5.0
                _add_cylinder_segments(detail, 0.082 * scale, 0.010 * scale, 10, role_hot, Vector3(cos(trap_angle) * 0.44 * scale, y + 0.088 * scale, z + 0.05 * scale + sin(trap_angle) * 0.30 * scale))
            _add_box(totem, Vector3(0.090, 0.010, 0.96) * scale, trim, Vector3(0.35 * scale, y + 0.104 * scale, z + 0.44 * scale), Vector3(0, 18, 0))
        "aurelion_sol":
            _add_cylinder_segments(totem, 0.76 * scale, 0.008 * scale, 40, role_soft, Vector3(0, y + 0.054 * scale, z), Vector3(0, 12, 0))
            _add_cylinder_segments(totem, 0.48 * scale, 0.008 * scale, 24, trim, Vector3(0, y + 0.070 * scale, z), Vector3(0, 30, 0))
            for star in range(6):
                var star_angle := TAU * float(star) / 6.0
                _add_sphere(detail, 0.038 * scale, role_hot if star % 2 == 0 else trim, Vector3(cos(star_angle) * 0.58 * scale, y + 0.104 * scale, z + sin(star_angle) * 0.38 * scale))
            _add_tapered_cylinder(detail, 0.046 * scale, 0.010 * scale, 0.92 * scale, 8, role_hot, Vector3(0.30 * scale, y + 0.126 * scale, z + 0.38 * scale), Vector3(72, -30, 0))
        _:
            _add_box(totem, Vector3(0.58, 0.010, 0.070) * scale, role_hot, Vector3(0, y + 0.078 * scale, z))
            _add_box(detail, Vector3(0.070, 0.010, 0.58) * scale, role_hot, Vector3(0, y + 0.080 * scale, z))

func _sync_champion_archetype_silhouette_rig(model: Node3D, player: Node2D) -> void:
    var rig := model.get_node_or_null("ChampionArchetypeSilhouetteRig") as Node3D
    if rig == null:
        return
    var champion := str(rig.get_meta("champion", ""))
    var attack_timer := maxf(0.0, float(player.get("attack_timer")))
    var attack_cooldown := maxf(0.16, float(player.get("attack_cooldown")))
    var readiness := 1.0 - clampf(attack_timer / attack_cooldown, 0.0, 1.0)
    var time := Time.get_ticks_msec() / 1000.0
    rig.set_meta("attack_readiness", readiness)
    rig.scale = Vector3.ONE * (0.98 + readiness * 0.040 + sin(time * _champion_combat_stance_pulse(champion)) * 0.010)
    var totem := rig.get_node_or_null("ChampionArchetypeRoleTotem") as Node3D
    if totem != null:
        totem.rotation.y += _champion_archetype_spin(champion) * (0.55 + readiness * 0.45)
    var routes := rig.get_node_or_null("ChampionArchetypeRouteGlyphs") as Node3D
    if routes != null:
        routes.scale = Vector3.ONE * (0.94 + readiness * 0.10)
    var detail := rig.get_node_or_null(str(rig.get_meta("detail_node", ""))) as Node3D
    if detail != null:
        detail.position.y = sin(time * (_champion_combat_stance_pulse(champion) + 0.45)) * 0.006
        detail.rotation.y += _champion_archetype_spin(champion) * (0.80 + readiness * 0.60)
        detail.scale = Vector3.ONE * (0.96 + readiness * 0.10)

func _champion_archetype_spin(champion: String) -> float:
    match champion:
        "samira":
            return 0.034
        "aurelion_sol":
            return -0.030
        "viktor":
            return -0.018
        "teemo":
            return 0.020
        "mordekaiser":
            return 0.010
        _:
            return 0.014

func _champion_archetype_family(champion: String) -> String:
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

func _champion_archetype_detail_name(champion: String) -> String:
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

func _add_champion_ability_emblems(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionAbilityEmblems") != null:
        return
    var ids := _champion_upgrade_ids(champion)
    if ids.is_empty():
        return
    var root := Node3D.new()
    root.name = "ChampionAbilityEmblems"
    root.set_meta("champion", champion)
    model.add_child(root)

    var frame_mat := _mat(champion + "_ability_emblem_frame", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.38), 0.74, true, true)
    var back_mat := _mat(champion + "_ability_emblem_back", Color(0.0, 0.0, 0.012, 0.50), 0.04, true, true)
    var glow_mat := _mat(champion + "_ability_emblem_glow", Color(accent.r, accent.g, accent.b, 0.26), 0.90, true, true)
    var atlas_available := _asset_available(CHAMPION_ABILITY_EMBLEM_ATLAS_TEXTURE_PATH)
    for i in range(mini(3, ids.size())):
        var upgrade_id := str(ids[i])
        var emblem := Node3D.new()
        emblem.name = "AbilityEmblem%d" % i
        emblem.set_meta("ability_emblem", true)
        emblem.set_meta("upgrade_id", upgrade_id)
        emblem.set_meta("emblem_index", i)
        emblem.position = Vector3((-0.62 + float(i) * 0.62) * scale, 0.0, -1.18 * scale)
        root.add_child(emblem)

        var route_color := _upgrade_route_color(upgrade_id, accent)
        _add_cylinder_segments(emblem, 0.330 * scale, 0.010 * scale, 6, back_mat, Vector3(0, 0.214 * scale, 0), Vector3(0, 30, 0))
        _add_cylinder_segments(emblem, 0.292 * scale, 0.008 * scale, 6, frame_mat, Vector3(0, 0.228 * scale, 0), Vector3(0, 30, 0))
        _add_cylinder_segments(emblem, 0.248 * scale, 0.006 * scale, 24, _mat(champion + "_ability_emblem_inner_" + str(i), Color(route_color.r, route_color.g, route_color.b, 0.24), 0.84, true, true), Vector3(0, 0.238 * scale, 0))
        if atlas_available:
            var grid := _champion_ability_emblem_grid(champion, i)
            var uv_scale := Vector3(1.0 / float(CHAMPION_ABILITY_EMBLEM_ATLAS_COLS), 1.0 / float(CHAMPION_ABILITY_EMBLEM_ATLAS_ROWS), 1.0)
            var uv_offset := Vector3(float(grid.x) / float(CHAMPION_ABILITY_EMBLEM_ATLAS_COLS), float(grid.y) / float(CHAMPION_ABILITY_EMBLEM_ATLAS_ROWS), 0.0)
            var icon_mat := _vfx_decal_mat(champion + "_ability_emblem_icon_" + str(i), CHAMPION_ABILITY_EMBLEM_ATLAS_TEXTURE_PATH, Color(1.0, 1.0, 1.0, 0.78), 0.96, uv_scale, uv_offset)
            var icon := _add_textured_plane(emblem, Vector2(0.460, 0.460) * scale, icon_mat, Vector3(0, 0.256 * scale, 0))
            icon.name = "AbilityIconTexture"
        else:
            _add_upgrade_route_symbol(emblem, upgrade_id, route_color, scale * 1.28)
        _add_box(emblem, Vector3(0.030, 0.006, 0.240) * scale, glow_mat, Vector3(0, 0.266 * scale, -0.264 * scale))

func _sync_champion_ability_emblems(model: Node3D) -> void:
    var root := model.get_node_or_null("ChampionAbilityEmblems") as Node3D
    if root == null:
        return
    var time := Time.get_ticks_msec() / 1000.0
    var champion := str(root.get_meta("champion", ""))
    for child in root.get_children():
        var emblem := child as Node3D
        if emblem == null:
            continue
        var index := int(emblem.get_meta("emblem_index", 0))
        emblem.position.y = sin(time * (1.45 + float(index) * 0.18)) * 0.012
        emblem.rotation.y = sin(time * 0.72 + float(index)) * 0.035
        var icon := emblem.get_node_or_null("AbilityIconTexture") as Node3D
        if icon != null:
            var pulse := 1.0 + sin(time * (2.0 if champion == "jinx" or champion == "samira" else 1.55) + float(index) * 0.7) * 0.035
            icon.scale = Vector3(pulse, 1.0, pulse)

func _add_champion_mechanic_meter(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionMechanicMeter") != null:
        return
    var root := Node3D.new()
    root.name = "ChampionMechanicMeter"
    root.set_meta("champion", champion)
    root.set_meta("mechanic_type", _champion_mechanic_type(champion))
    model.add_child(root)

    var frame := Node3D.new()
    frame.name = "MechanicMeterFrame"
    root.add_child(frame)
    var pips := Node3D.new()
    pips.name = "MechanicMeterPips"
    root.add_child(pips)
    var motif := Node3D.new()
    motif.name = "MechanicMeterHeroMotif"
    motif.set_meta("champion", champion)
    root.add_child(motif)

    var soft := _mat(champion + "_mechanic_soft", Color(accent.r, accent.g, accent.b, 0.26), 0.88, true, true)
    var hot := _mat(champion + "_mechanic_hot", Color(accent.lightened(0.18).r, accent.lightened(0.18).g, accent.lightened(0.18).b, 0.58), 1.14, true, true)
    var gold := _mat(champion + "_mechanic_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42), 0.78, true, true)
    var dark := _mat(champion + "_mechanic_dark", Color(0.010, 0.010, 0.020, 0.46), 0.02, true, true)
    var y := 0.198 * scale

    _add_cylinder_segments(frame, 1.06 * scale, 0.010 * scale, 8, dark, Vector3(0, y, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(frame, 0.92 * scale, 0.008 * scale, 8, soft, Vector3(0, y + 0.014 * scale, 0), Vector3(0, 22.5, 0))

    match champion:
        "jinx":
            var pink := _mat("jinx_mechanic_pink_ammo", Color(1.0, 0.26, 0.64, 0.62), 1.16, true, true)
            var blue := _mat("jinx_mechanic_blue_ammo", Color(0.22, 0.82, 1.0, 0.62), 1.16, true, true)
            _add_mechanic_meter_pips(pips, 6, 0.72 * scale, y + 0.048 * scale, scale, [blue, pink])
            _add_tapered_cylinder(motif, 0.070 * scale, 0.016 * scale, 0.62 * scale, 8, hot, Vector3(0.32, y + 0.084 * scale, 0.18) * scale, Vector3(90, 0, 0))
            _add_box(motif, Vector3(0.48, 0.012, 0.070) * scale, gold, Vector3(0.32, y + 0.094 * scale, -0.16) * scale)
        "senna":
            _add_mechanic_meter_pips(pips, 5, 0.76 * scale, y + 0.052 * scale, scale, [hot])
            _add_cylinder_segments(motif, 0.46 * scale, 0.010 * scale, 28, soft, Vector3(0, y + 0.080 * scale, 0.22) * scale, Vector3(90, 0, 0))
            _add_box(motif, Vector3(0.14, 0.010, 1.02) * scale, hot, Vector3(0, y + 0.094 * scale, 0.48) * scale)
        "samira":
            var style_mats := [
                _mat("samira_style_d", Color(0.72, 0.20, 0.12, 0.46), 0.88, true, true),
                _mat("samira_style_c", Color(0.88, 0.30, 0.12, 0.50), 0.96, true, true),
                _mat("samira_style_b", Color(1.0, 0.42, 0.16, 0.54), 1.02, true, true),
                _mat("samira_style_a", Color(1.0, 0.62, 0.22, 0.58), 1.08, true, true),
                _mat("samira_style_s", Color(1.0, 0.88, 0.34, 0.64), 1.20, true, true)
            ]
            _add_mechanic_meter_pips(pips, 5, 0.78 * scale, y + 0.052 * scale, scale, style_mats)
            for slash in range(3):
                var offset := float(slash) - 1.0
                _add_box(motif, Vector3(0.075, 0.012, 0.78) * scale, hot, Vector3(offset * 0.12, y + 0.088 * scale, 0.18) * scale, Vector3(0, offset * 22.0, 0))
        "viktor":
            _add_mechanic_meter_pips(pips, 3, 0.62 * scale, y + 0.054 * scale, scale, [hot])
            _add_cylinder_segments(motif, 0.48 * scale, 0.010 * scale, 6, hot, Vector3(0, y + 0.084 * scale, 0.06) * scale, Vector3(0, 30, 0))
            for spoke in range(6):
                var angle := TAU * float(spoke) / 6.0
                _add_box(motif, Vector3(0.036, 0.008, 0.36) * scale, soft, Vector3(cos(angle) * 0.34, y + 0.100 * scale, sin(angle) * 0.34) * scale, Vector3(0, -rad_to_deg(angle), 0))
        "xayah":
            for i in range(5):
                var offset := float(i) - 2.0
                var feather := _add_box(pips, Vector3(0.060, 0.012, 0.54 - abs(offset) * 0.040) * scale, hot, Vector3(offset * 0.18, y + 0.052 * scale, -0.10 + abs(offset) * 0.06) * scale, Vector3(0, offset * 14.0, 0))
                feather.name = "MechanicMeterPip%d" % i
                feather.set_meta("pip_index", i)
            _add_cylinder_segments(motif, 0.54 * scale, 0.010 * scale, 5, soft, Vector3(0, y + 0.080 * scale, -0.04) * scale, Vector3(0, 18, 0))
        "mordekaiser":
            _add_mechanic_meter_pips(pips, 4, 0.76 * scale, y + 0.052 * scale, scale, [hot])
            _add_box(motif, Vector3(0.24, 0.012, 1.10) * scale, hot, Vector3(0.16, y + 0.086 * scale, 0.24) * scale, Vector3(0, -28, 0))
            _add_box(motif, Vector3(0.72, 0.014, 0.26) * scale, hot, Vector3(0.46, y + 0.102 * scale, 0.56) * scale, Vector3(0, -28, 0))
            _add_cylinder_segments(motif, 0.72 * scale, 0.010 * scale, 8, _mat("morde_mechanic_realm", Color(0.42, 1.0, 0.46, 0.28), 0.94, true, true), Vector3(0, y + 0.062 * scale, 0) * scale, Vector3(0, 22.5, 0))
        "teemo":
            _add_mechanic_meter_pips(pips, 4, 0.72 * scale, y + 0.052 * scale, scale, [hot])
            for i in range(3):
                var x := -0.24 + float(i) * 0.24
                _add_sphere(motif, 0.070 * scale, hot, Vector3(x, y + 0.092 * scale, 0.12 + abs(float(i) - 1.0) * 0.06) * scale)
                _add_cylinder_segments(motif, 0.080 * scale, 0.020 * scale, 12, _mat("teemo_mechanic_cap_" + str(i), Color(0.78, 0.22, 0.12), 0.55, true), Vector3(x, y + 0.122 * scale, 0.12 + abs(float(i) - 1.0) * 0.06) * scale)
        "aurelion_sol":
            _add_cylinder_segments(frame, 1.22 * scale, 0.008 * scale, 40, _mat("asol_mechanic_outer_orbit", Color(0.92, 0.72, 1.0, 0.24), 0.92, true, true), Vector3(0, y + 0.034 * scale, 0), Vector3(0, 12, 0))
            _add_mechanic_meter_pips(pips, 5, 0.86 * scale, y + 0.062 * scale, scale, [_mat("asol_mechanic_star", Color(1.0, 0.86, 0.50), 1.26, true)])
            _add_sphere(motif, 0.110 * scale, _mat("asol_mechanic_singularity", Color(0.76, 0.38, 1.0), 1.22, true), Vector3(0, y + 0.100 * scale, 0.20) * scale)
            _add_tapered_cylinder(motif, 0.052 * scale, 0.010 * scale, 0.86 * scale, 8, hot, Vector3(0.34, y + 0.090 * scale, 0.46) * scale, Vector3(74, -30, 0))
        _:
            _add_mechanic_meter_pips(pips, 3, 0.68 * scale, y + 0.052 * scale, scale, [hot])
            _add_cylinder_segments(motif, 0.42 * scale, 0.010 * scale, 6, soft, Vector3(0, y + 0.080 * scale, 0), Vector3(0, 30, 0))

func _add_mechanic_meter_pips(parent: Node3D, count: int, radius: float, y: float, scale: float, mats: Array) -> void:
    for i in range(count):
        var angle := TAU * float(i) / float(maxi(1, count)) - PI * 0.50
        var mat: Material = mats[i % mats.size()]
        var pip := _add_sphere(parent, 0.050 * scale, mat, Vector3(cos(angle) * radius, y + float(i % 2) * 0.010 * scale, sin(angle) * radius))
        pip.name = "MechanicMeterPip%d" % i
        pip.set_meta("pip_index", i)

func _sync_champion_mechanic_meter(model: Node3D) -> void:
    var root := model.get_node_or_null("ChampionMechanicMeter") as Node3D
    if root == null:
        return
    var champion := str(root.get_meta("champion", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var pips := root.get_node_or_null("MechanicMeterPips") as Node3D
    if pips != null:
        pips.rotation.y = time * _champion_mechanic_meter_speed(champion)
    var motif := root.get_node_or_null("MechanicMeterHeroMotif") as Node3D
    if motif != null:
        var pulse := 1.0 + sin(time * _champion_mechanic_meter_pulse(champion)) * 0.045
        motif.scale = Vector3.ONE * pulse
        motif.position.y = sin(time * (_champion_mechanic_meter_pulse(champion) * 0.62)) * 0.010
    var frame := root.get_node_or_null("MechanicMeterFrame") as Node3D
    if frame != null:
        frame.rotation.y = -time * _champion_mechanic_meter_speed(champion) * 0.35

func _champion_mechanic_type(champion: String) -> String:
    match champion:
        "jinx":
            return "ammo_swap"
        "senna":
            return "soul_stack"
        "samira":
            return "style_rank"
        "viktor":
            return "hexcore_evolution"
        "xayah":
            return "feather_recall"
        "mordekaiser":
            return "death_realm"
        "teemo":
            return "shroom_charges"
        "aurelion_sol":
            return "star_orbit"
        _:
            return "generic"

func _champion_combat_loop_type(champion: String) -> String:
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

func _champion_combat_loop_detail_node(champion: String) -> String:
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

func _add_champion_combat_loop_readout(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionCombatLoopReadout") != null:
        return
    var root := Node3D.new()
    root.name = "ChampionCombatLoopReadout"
    root.set_meta("champion", champion)
    root.set_meta("combat_loop_type", _champion_combat_loop_type(champion))
    root.set_meta("detail_node", _champion_combat_loop_detail_node(champion))
    root.set_meta("combat_visual_channel", "champion_readability")
    root.set_meta("material_grade", "low_glare_champion_combat_loop_readout")
    root.set_meta("loop_readout_layer", true)
    model.add_child(root)

    var y := 0.164 * scale
    var dark := _mat(champion + "_combat_loop_dark", Color(0.0, 0.0, 0.014, 0.30), 0.0, true, true)
    var signal_mat := _mat(champion + "_combat_loop_signal", Color(accent.r, accent.g, accent.b, 0.24), 0.0, true, true)
    var trim := _mat(champion + "_combat_loop_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.18), 0.0, true, true)
    var role := _mat(champion + "_combat_loop_role", Color(_champion_kit_role_color(champion, accent).r, _champion_kit_role_color(champion, accent).g, _champion_kit_role_color(champion, accent).b, 0.20), 0.0, true, true)

    var matte := _add_box(root, Vector3(1.84, 0.010, 0.42) * scale, dark, Vector3(0, y, 1.18) * scale)
    matte.name = "CombatLoopMatte"
    matte.set_meta("combat_visual_channel", "champion_readability")
    matte.set_meta("loop_readout_layer", true)

    var primary := _add_box(root, Vector3(0.86, 0.010, 0.070) * scale, signal_mat, Vector3(-0.36, y + 0.018 * scale, 1.18) * scale)
    primary.name = "CombatLoopPrimaryGlyph"
    primary.set_meta("combat_visual_channel", "champion_readability")
    primary.set_meta("loop_role", "primary_attack")

    var passive := _add_box(root, Vector3(0.42, 0.010, 0.070) * scale, trim, Vector3(0.62, y + 0.026 * scale, 1.18) * scale, Vector3(0, 26, 0))
    passive.name = "CombatLoopPassiveGlyph"
    passive.set_meta("combat_visual_channel", "champion_readability")
    passive.set_meta("loop_role", "passive_or_skill")

    var route := _add_cylinder_segments(root, 0.24 * scale, 0.008 * scale, 6, role, Vector3(0.98, y + 0.032 * scale, 1.18) * scale, Vector3(0, 30, 0))
    route.name = "CombatLoopRouteAnchor"
    route.set_meta("combat_visual_channel", "champion_readability")
    route.set_meta("loop_role", "build_route")

    var detail := Node3D.new()
    detail.name = _champion_combat_loop_detail_node(champion)
    detail.set_meta("champion", champion)
    detail.set_meta("combat_loop_type", _champion_combat_loop_type(champion))
    detail.set_meta("combat_visual_channel", "champion_readability")
    detail.set_meta("loop_readout_layer", true)
    root.add_child(detail)

    match champion:
        "jinx":
            _add_box(detail, Vector3(0.13, 0.012, 0.60) * scale, signal_mat, Vector3(-0.72, y + 0.056 * scale, 1.18) * scale, Vector3(0, 18, 0))
            _add_box(detail, Vector3(0.11, 0.012, 0.46) * scale, trim, Vector3(-0.16, y + 0.058 * scale, 1.18) * scale, Vector3(0, -18, 0))
            _add_sphere(detail, 0.046 * scale, signal_mat, Vector3(0.18, y + 0.078 * scale, 1.18) * scale)
        "senna":
            _add_box(detail, Vector3(1.08, 0.012, 0.060) * scale, signal_mat, Vector3(-0.20, y + 0.060 * scale, 1.18) * scale)
            _add_cylinder_segments(detail, 0.28 * scale, 0.008 * scale, 24, trim, Vector3(0.52, y + 0.072 * scale, 1.18) * scale, Vector3(90, 0, 0))
            _add_sphere(detail, 0.052 * scale, trim, Vector3(0.82, y + 0.084 * scale, 1.18) * scale)
        "samira":
            for i in range(4):
                var offset := -0.45 + float(i) * 0.30
                _add_box(detail, Vector3(0.060, 0.012, 0.48) * scale, signal_mat if i % 2 == 0 else trim, Vector3(offset, y + 0.062 * scale, 1.18) * scale, Vector3(0, offset * 42.0, 0))
        "viktor":
            _add_cylinder_segments(detail, 0.34 * scale, 0.008 * scale, 6, signal_mat, Vector3(-0.36, y + 0.064 * scale, 1.18) * scale, Vector3(0, 30, 0))
            _add_box(detail, Vector3(0.070, 0.012, 0.86) * scale, signal_mat, Vector3(0.24, y + 0.072 * scale, 1.18) * scale, Vector3(0, 12, 0))
            _add_box(detail, Vector3(0.54, 0.010, 0.050) * scale, trim, Vector3(0.68, y + 0.070 * scale, 1.18) * scale)
        "xayah":
            for i in range(5):
                var offset := -0.48 + float(i) * 0.24
                _add_box(detail, Vector3(0.046, 0.012, 0.42 - abs(offset) * 0.080) * scale, signal_mat, Vector3(offset, y + 0.064 * scale, 1.18 + abs(offset) * 0.08) * scale, Vector3(0, offset * -36.0, 0))
            _add_box(detail, Vector3(0.68, 0.010, 0.050) * scale, trim, Vector3(0.02, y + 0.078 * scale, 0.94) * scale)
        "mordekaiser":
            _add_box(detail, Vector3(0.18, 0.012, 0.78) * scale, signal_mat, Vector3(-0.20, y + 0.066 * scale, 1.18) * scale, Vector3(0, -28, 0))
            _add_box(detail, Vector3(0.48, 0.012, 0.18) * scale, signal_mat, Vector3(0.08, y + 0.078 * scale, 1.46) * scale, Vector3(0, -28, 0))
            _add_cylinder_segments(detail, 0.40 * scale, 0.008 * scale, 8, trim, Vector3(0.42, y + 0.066 * scale, 1.18) * scale, Vector3(0, 22.5, 0))
        "teemo":
            _add_box(detail, Vector3(0.070, 0.012, 0.74) * scale, signal_mat, Vector3(-0.46, y + 0.064 * scale, 1.18) * scale, Vector3(0, 18, 0))
            for i in range(3):
                var x := -0.05 + float(i) * 0.22
                _add_sphere(detail, 0.048 * scale, signal_mat, Vector3(x, y + 0.078 * scale, 1.18 + abs(float(i) - 1.0) * 0.06) * scale)
            _add_cylinder_segments(detail, 0.26 * scale, 0.008 * scale, 12, trim, Vector3(0.55, y + 0.066 * scale, 1.18) * scale)
        "aurelion_sol":
            _add_cylinder_segments(detail, 0.58 * scale, 0.008 * scale, 28, signal_mat, Vector3(0.0, y + 0.060 * scale, 1.18) * scale, Vector3(0, 12, 0))
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_sphere(detail, 0.040 * scale, trim, Vector3(cos(angle) * 0.42, y + 0.080 * scale, 1.18 + sin(angle) * 0.26) * scale)
        _:
            _add_cylinder_segments(detail, 0.36 * scale, 0.008 * scale, 6, signal_mat, Vector3(0, y + 0.060 * scale, 1.18) * scale, Vector3(0, 30, 0))

func _sync_champion_combat_loop_readout(model: Node3D, player: Node2D) -> void:
    var root := model.get_node_or_null("ChampionCombatLoopReadout") as Node3D
    if root == null:
        return
    var attack_timer := maxf(0.0, float(player.get("attack_timer")))
    var attack_cooldown := maxf(0.16, float(player.get("attack_cooldown")))
    var readiness := 1.0 - clampf(attack_timer / attack_cooldown, 0.0, 1.0)
    var champion := str(root.get_meta("champion", ""))
    var time := Time.get_ticks_msec() / 1000.0
    root.set_meta("attack_readiness", readiness)
    root.set_meta("attack_counter", int(player.get("attack_counter")))
    var pulse := 1.0 + readiness * 0.055 + sin(time * (1.8 + readiness)) * 0.012
    root.scale = Vector3(pulse, 1.0, pulse)
    root.rotation.y = sin(time * 0.55 + float(champion.length())) * 0.020
    var detail := root.get_node_or_null(str(root.get_meta("detail_node", ""))) as Node3D
    if detail != null:
        detail.position.y = sin(time * (2.2 + readiness)) * 0.006
        detail.scale = Vector3.ONE * (1.0 + readiness * 0.065)

func _add_champion_human_focus_plate(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionHumanFocusPlate") != null:
        return
    var root := Node3D.new()
    root.name = "ChampionHumanFocusPlate"
    root.set_meta("champion", champion)
    root.set_meta("combat_class", _champion_combat_class(champion))
    root.set_meta("range_band", _champion_range_band(champion))
    root.set_meta("combat_visual_channel", "champion_focus_readability")
    root.set_meta("material_grade", "low_glare_human_focus_plate")
    root.set_meta("human_focus_guard", true)
    root.set_meta("pickup_confusion_guard", true)
    model.add_child(root)

    var role_color := _champion_kit_role_color(champion, accent)
    var matte := _mat(champion + "_human_focus_matte", Color(0.0, 0.0, 0.012, 0.28), 0.0, true, true)
    var role_mat := _mat(champion + "_human_focus_role", Color(role_color.r, role_color.g, role_color.b, 0.22), 0.0, true, true)
    var trim := _mat(champion + "_human_focus_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.18), 0.0, true, true)
    var cutout := _mat(champion + "_human_focus_cutout", Color(0.0, 0.0, 0.0, 0.20), 0.0, true, true)
    var y := 0.052 * scale

    var matte_disc := _add_cylinder_segments(root, 1.30 * scale, 0.008 * scale, 10, matte, Vector3(0, y, 0), Vector3(0, 18, 0))
    matte_disc.name = "HumanFocusMatteDisc"
    matte_disc.set_meta("focus_role", "player_location")
    var orbit := _add_cylinder_segments(root, 1.04 * scale, 0.008 * scale, 8, role_mat, Vector3(0, y + 0.012 * scale, 0), Vector3(0, 22.5, 0))
    orbit.name = "HumanFocusSafeOrbit"
    orbit.set_meta("focus_role", "safe_spacing")

    var arrow := Node3D.new()
    arrow.name = "HumanFocusFacingArrow"
    arrow.set_meta("focus_role", "facing")
    root.add_child(arrow)
    var stem := _add_box(arrow, Vector3(0.080, 0.010, 0.620) * scale, trim, Vector3(0, y + 0.028 * scale, 0.710 * scale))
    stem.name = "HumanFocusFacingStem"
    for side in [-1.0, 1.0]:
        var wing := _add_box(arrow, Vector3(0.070, 0.010, 0.280) * scale, trim, Vector3(side * 0.120 * scale, y + 0.030 * scale, 0.980 * scale), Vector3(0, side * 30.0, 0))
        wing.name = "HumanFocusFacingWing" + ("L" if side < 0.0 else "R")

    var lanes := Node3D.new()
    lanes.name = "HumanFocusDodgeLaneRoot"
    lanes.set_meta("focus_role", "dodge_lanes")
    root.add_child(lanes)
    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        var lane := _add_box(lanes, Vector3(0.360, 0.008, 0.052) * scale, role_mat, Vector3(cos(angle) * 0.86 * scale, y + 0.024 * scale, sin(angle) * 0.86 * scale), Vector3(0, -rad_to_deg(angle), 0))
        lane.name = "HumanFocusDodgeLane%d" % i

    var glyph := Node3D.new()
    glyph.name = "HumanFocusClassGlyph"
    glyph.set_meta("combat_class", _champion_combat_class(champion))
    glyph.set_meta("range_band", _champion_range_band(champion))
    root.add_child(glyph)
    match _champion_range_band(champion):
        "melee":
            _add_box(glyph, Vector3(0.120, 0.010, 0.560) * scale, role_mat, Vector3(-0.180 * scale, y + 0.044 * scale, -0.220 * scale), Vector3(0, -28, 0)).name = "HumanFocusMeleeSlashA"
            _add_box(glyph, Vector3(0.120, 0.010, 0.560) * scale, trim, Vector3(0.180 * scale, y + 0.046 * scale, -0.220 * scale), Vector3(0, 28, 0)).name = "HumanFocusMeleeSlashB"
        "summoner":
            for i in range(3):
                var angle := TAU * float(i) / 3.0 - PI * 0.50
                var node := _add_sphere(glyph, 0.060 * scale, role_mat, Vector3(cos(angle) * 0.360 * scale, y + 0.050 * scale, -0.160 * scale + sin(angle) * 0.240 * scale))
                node.name = "HumanFocusSummonNode%d" % i
            _add_cylinder_segments(glyph, 0.420 * scale, 0.007 * scale, 12, cutout, Vector3(0, y + 0.038 * scale, -0.160 * scale)).name = "HumanFocusSummonOrbit"
        "mage":
            _add_cylinder_segments(glyph, 0.360 * scale, 0.008 * scale, 6, role_mat, Vector3(0, y + 0.044 * scale, -0.180 * scale), Vector3(0, 30, 0)).name = "HumanFocusMageHex"
            _add_box(glyph, Vector3(0.540, 0.008, 0.050) * scale, trim, Vector3(0, y + 0.052 * scale, -0.180 * scale)).name = "HumanFocusMageBeam"
        _:
            for i in range(3):
                var x := -0.220 + float(i) * 0.220
                var pip := _add_box(glyph, Vector3(0.070, 0.008, 0.280) * scale, role_mat, Vector3(x * scale, y + 0.044 * scale, -0.240 * scale), Vector3(0, float(i - 1) * 12.0, 0))
                pip.name = "HumanFocusRangedPip%d" % i

func _sync_champion_human_focus_plate(model: Node3D, player: Node2D) -> void:
    var root := model.get_node_or_null("ChampionHumanFocusPlate") as Node3D
    if root == null:
        return
    var max_health := maxf(1.0, float(player.get("max_health")))
    var health_ratio := clampf(float(player.get("health")) / max_health, 0.0, 1.0)
    var attack_timer := maxf(0.0, float(player.get("attack_timer")))
    var attack_cooldown := maxf(0.16, float(player.get("attack_cooldown")))
    var readiness := 1.0 - clampf(attack_timer / attack_cooldown, 0.0, 1.0)
    var time := Time.get_ticks_msec() / 1000.0
    root.set_meta("health_ratio", health_ratio)
    root.set_meta("attack_readiness", readiness)
    root.set_meta("human_focus_active", true)
    var urgency := 1.0 - health_ratio
    root.scale = Vector3.ONE * (1.0 + urgency * 0.080 + readiness * 0.020)
    root.rotation.y = sin(time * 0.38 + float(str(root.get_meta("champion", "")).length())) * 0.014
    var lanes := root.get_node_or_null("HumanFocusDodgeLaneRoot") as Node3D
    if lanes != null:
        lanes.scale = Vector3.ONE * (1.0 + urgency * 0.12)
        lanes.rotation.y -= 0.010 + urgency * 0.008
    var arrow := root.get_node_or_null("HumanFocusFacingArrow") as Node3D
    if arrow != null:
        arrow.scale = Vector3.ONE * (1.0 + readiness * 0.050)
    var glyph := root.get_node_or_null("HumanFocusClassGlyph") as Node3D
    if glyph != null:
        glyph.position.y = sin(time * (1.6 + readiness)) * 0.004

func _champion_mechanic_meter_speed(champion: String) -> float:
    match champion:
        "jinx", "samira", "teemo":
            return 0.68
        "xayah", "aurelion_sol":
            return -0.48
        "mordekaiser":
            return 0.18
        "senna", "viktor":
            return 0.26
        _:
            return 0.32

func _champion_mechanic_meter_pulse(champion: String) -> float:
    match champion:
        "jinx", "samira":
            return 4.8
        "teemo":
            return 3.8
        "mordekaiser":
            return 2.2
        "aurelion_sol":
            return 2.8
        _:
            return 3.2

func _champion_ability_emblem_grid(champion: String, index: int) -> Vector2i:
    var clamped_index := clampi(index, 0, 2)
    match champion:
        "jinx":
            return Vector2i(clamped_index, 0)
        "senna":
            return Vector2i(3 + clamped_index, 0)
        "samira":
            return Vector2i(clamped_index, 1)
        "viktor":
            return Vector2i(3 + clamped_index, 1)
        "xayah":
            return Vector2i(clamped_index, 2)
        "mordekaiser":
            return Vector2i(3 + clamped_index, 2)
        "teemo":
            return Vector2i(clamped_index, 3)
        "aurelion_sol":
            return Vector2i(3 + clamped_index, 3)
        _:
            return Vector2i(clamped_index, 0)

func _add_champion_silhouette_polish(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    var accent_soft := Color(accent.r, accent.g, accent.b, 0.24)
    var accent_mid := Color(accent.r, accent.g, accent.b, 0.42)
    var gold_soft := Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.34)
    _add_cylinder_segments(model, 1.02 * scale, 0.014 * scale, 6, _mat(champion + "_silhouette_hex", accent_soft, 0.86, true, true), Vector3(0, 0.108, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(model, 0.42 * scale, 0.012 * scale, 6, _mat(champion + "_inner_hex_trim", gold_soft, 0.62, true, true), Vector3(0, 0.122, 0), Vector3(0, 30, 0))

    match champion:
        "jinx", "senna", "xayah", "teemo":
            for lane in range(3):
                var lane_offset := float(lane) - 1.0
                _add_box(model, Vector3(0.055, 0.010, 1.20) * scale, _mat(champion + "_ranged_lane_" + str(lane), accent_mid, 0.86, true, true), Vector3(lane_offset * 0.24, 0.136, 0.42) * scale, Vector3(0, lane_offset * 8.0, 0))
        "samira", "mordekaiser":
            for slash in range(4):
                var slash_angle := -34.0 + float(slash) * 22.0
                _add_box(model, Vector3(0.105, 0.012, 1.18) * scale, _mat(champion + "_melee_arc_" + str(slash), accent_mid, 0.88, true, true), Vector3((float(slash) - 1.5) * 0.13, 0.138, 0.18) * scale, Vector3(0, slash_angle, 0))
        "viktor", "aurelion_sol":
            _add_cylinder_segments(model, 1.14 * scale, 0.012 * scale, 12, _mat(champion + "_caster_circuit", accent_mid, 0.95, true, true), Vector3(0, 0.138, 0), Vector3(0, 15, 0))
            for spoke in range(6):
                var spoke_angle := TAU * float(spoke) / 6.0
                _add_box(model, Vector3(0.048, 0.010, 0.58) * scale, _mat(champion + "_caster_spoke_" + str(spoke), accent_soft, 0.72, true, true), Vector3(cos(spoke_angle) * 0.42, 0.150, sin(spoke_angle) * 0.42) * scale, Vector3(0, -rad_to_deg(spoke_angle), 0))
        _:
            pass

    match champion:
        "jinx":
            var pink := Color(1.0, 0.24, 0.62)
            var blue := Color(0.24, 0.82, 1.0)
            for i in range(6):
                var t := -0.5 + float(i) / 5.0
                var orb_col := blue if i % 2 == 0 else pink
                _add_sphere(model, 0.045 * scale, _mat("jinx_ammo_bead_" + str(i), orb_col, 0.90, true), Vector3(t * 0.72, 0.70 + abs(t) * 0.20, -0.52) * scale)
            _add_box(model, Vector3(0.38, 0.040, 0.16) * scale, _mat("jinx_rocket_warning_blue", Color(blue.r, blue.g, blue.b, 0.52), 1.0, true, true), Vector3(-0.44, 0.130, 0.78) * scale, Vector3(0, -20, 0))
            _add_box(model, Vector3(0.38, 0.040, 0.16) * scale, _mat("jinx_rocket_warning_pink", Color(pink.r, pink.g, pink.b, 0.52), 1.0, true, true), Vector3(0.44, 0.130, 0.78) * scale, Vector3(0, 20, 0))
        "senna":
            var soul := Color(0.58, 1.0, 0.78)
            _add_cylinder_segments(model, 0.36 * scale, 0.014 * scale, 24, _mat("senna_back_soul_gate_outer", Color(soul.r, soul.g, soul.b, 0.34), 1.0, true, true), Vector3(0, 1.36, -0.60) * scale, Vector3(90, 0, 0))
            _add_cylinder_segments(model, 0.20 * scale, 0.012 * scale, 24, _mat("senna_back_soul_gate_inner", Color(soul.r, soul.g, soul.b, 0.48), 1.1, true, true), Vector3(0, 1.36, -0.60) * scale, Vector3(90, 0, 0))
            for mote in range(4):
                var mote_angle := TAU * float(mote) / 4.0
                _add_sphere(model, 0.040 * scale, _mat("senna_soul_mote_" + str(mote), soul, 1.20, true), Vector3(cos(mote_angle) * 0.62, 1.22 + sin(mote_angle) * 0.16, -0.48) * scale)
        "samira":
            var hot := Color(1.0, 0.40, 0.16)
            _add_cylinder_segments(model, 0.92 * scale, 0.016 * scale, 32, _mat("samira_close_range_warning", Color(hot.r, hot.g, hot.b, 0.28), 0.92, true, true), Vector3(0, 0.152, 0), Vector3(0, 0, 0))
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(0.10, 0.08, 0.56) * scale, _mat("samira_pistol_flash_" + str(side), Color(1.0, 0.72, 0.24, 0.58), 1.05, true, true), Vector3(side * 0.56, 0.86, 0.90) * scale, Vector3(0, side * 18.0, side * 22.0))
            _add_box(model, Vector3(0.18, 0.020, 1.34) * scale, _mat("samira_execution_slash", Color(hot.r, hot.g, hot.b, 0.40), 1.0, true, true), Vector3(0, 1.36, 0.04) * scale, Vector3(58, 0, -28))
        "viktor":
            var arc := Color(0.72, 0.94, 1.0)
            for cable in range(3):
                var cable_x := -0.18 + float(cable) * 0.18
                _add_box(model, Vector3(0.035, 0.050, 0.72) * scale, _mat("viktor_power_cable_" + str(cable), Color(arc.r, arc.g, arc.b, 0.42), 0.88, true, true), Vector3(cable_x, 1.24, -0.54) * scale, Vector3(24, 0, 0))
            _add_cylinder_segments(model, 0.32 * scale, 0.018 * scale, 6, _mat("viktor_hexcore_face", Color(arc.r, arc.g, arc.b, 0.50), 1.05, true, true), Vector3(0, 1.08, 0.35) * scale, Vector3(90, 0, 30))
            _add_box(model, Vector3(0.42, 0.040, 0.060) * scale, _mat("viktor_mask_slit", Color(0.90, 1.0, 1.0), 1.15, true), Vector3(0, 1.60, 0.36) * scale)
        "xayah":
            var feather := Color(1.0, 0.30, 0.68)
            for plume in range(7):
                var offset := float(plume) - 3.0
                _add_box(model, Vector3(0.06, 0.045, 0.78) * scale, _mat("xayah_back_fan_" + str(plume), feather, 0.46, true), Vector3(offset * 0.15, 1.34 - abs(offset) * 0.035, -0.76 + abs(offset) * 0.035) * scale, Vector3(0, offset * 8.0, offset * 7.0))
            _add_cylinder_segments(model, 0.68 * scale, 0.012 * scale, 5, _mat("xayah_recall_star", Color(feather.r, feather.g, feather.b, 0.34), 0.95, true, true), Vector3(0, 0.150, -0.12) * scale, Vector3(0, 18, 0))
        "mordekaiser":
            var realm := Color(0.42, 1.0, 0.46)
            _add_cylinder_segments(model, 1.18 * scale, 0.020 * scale, 8, _mat("morde_death_realm_floor", Color(realm.r, realm.g, realm.b, 0.26), 0.92, true, true), Vector3(0, 0.154, 0), Vector3(0, 22.5, 0))
            for hook in range(6):
                var hook_angle := TAU * float(hook) / 6.0
                _add_box(model, Vector3(0.22, 0.030, 0.075) * scale, _mat("morde_chain_hook_" + str(hook), Color(0.10, 0.18, 0.14), 0.24, true), Vector3(cos(hook_angle) * 0.78, 0.176, sin(hook_angle) * 0.78) * scale, Vector3(0, -rad_to_deg(hook_angle) + 16.0, 0))
            _add_box(model, Vector3(0.64, 0.020, 0.18) * scale, _mat("morde_hammer_impact_mark", Color(realm.r, realm.g, realm.b, 0.48), 1.0, true, true), Vector3(0.40, 0.188, 0.78) * scale, Vector3(0, -22, 0))
        "teemo":
            var poison := Color(0.62, 1.0, 0.22)
            for spore in range(7):
                var spore_angle := TAU * float(spore) / 7.0
                var spore_r := 0.34 + float(spore % 3) * 0.13
                _add_sphere(model, 0.038 * scale, _mat("teemo_poison_spore_" + str(spore), poison, 1.0, true), Vector3(cos(spore_angle) * spore_r, 0.34 + float(spore % 2) * 0.08, sin(spore_angle) * spore_r) * scale)
            _add_cylinder_segments(model, 0.72 * scale, 0.012 * scale, 24, _mat("teemo_poison_radius", Color(poison.r, poison.g, poison.b, 0.26), 0.82, true, true), Vector3(0, 0.150, 0), Vector3.ZERO)
            _add_box(model, Vector3(0.42, 0.035, 0.11) * scale, _mat("teemo_goggle_glass", Color(0.84, 1.0, 0.58, 0.42), 0.85, true, true), Vector3(0, 1.55, 0.31) * scale)
        "aurelion_sol":
            var star := Color(0.92, 0.72, 1.0)
            _add_cylinder_segments(model, 1.26 * scale, 0.012 * scale, 48, _mat("asol_outer_star_orbit", Color(star.r, star.g, star.b, 0.26), 1.0, true, true), Vector3(0, 1.22, 0) * scale, Vector3(90, 0, 0))
            _add_cylinder_segments(model, 0.68 * scale, 0.010 * scale, 36, _mat("asol_inner_star_orbit", Color(0.62, 0.86, 1.0, 0.24), 0.92, true, true), Vector3(0.06, 1.34, 0.02) * scale, Vector3(90, 0, 28))
            for star_index in range(6):
                var star_angle := TAU * float(star_index) / 6.0
                _add_sphere(model, 0.052 * scale, _mat("asol_constellation_" + str(star_index), Color(1.0, 0.88, 0.56), 1.35, true), Vector3(cos(star_angle) * 1.08, 1.22 + sin(star_angle * 2.0) * 0.12, sin(star_angle) * 0.70) * scale)
        _:
            pass

func _add_champion_role_readability(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    var accent_soft := Color(accent.r, accent.g, accent.b, 0.30)
    var accent_hot := Color(accent.r, accent.g, accent.b, 0.58)
    var gold := _mat(champion + "_role_gold", HEXTECH_GOLD, 0.24, true)
    var glow := _mat(champion + "_role_glow", accent_hot, 0.96, true, true)
    var dark := _mat(champion + "_role_dark", Color(0.030, 0.030, 0.045), 0.04, true)

    match champion:
        "jinx":
            for i in range(5):
                _add_sphere(model, 0.045 * scale, _mat("jinx_bullet_chain_" + str(i), Color(1.0, 0.70, 0.22), 0.42, true), Vector3(-0.58 + float(i) * 0.12, 1.10 + sin(float(i)) * 0.04, -0.34) * scale)
            _add_box(model, Vector3(0.78, 0.026, 0.070) * scale, glow, Vector3(0.36, 0.150, 0.98) * scale, Vector3(0, 20, 0))
        "senna":
            _add_box(model, Vector3(0.22, 0.78, 0.12) * scale, gold, Vector3(-0.50, 1.03, 0.86) * scale, Vector3(0, -8, 0))
            _add_box(model, Vector3(0.22, 0.78, 0.12) * scale, gold, Vector3(0.50, 1.03, 0.86) * scale, Vector3(0, 8, 0))
            _add_cylinder_segments(model, 0.46 * scale, 0.014 * scale, 24, glow, Vector3(0, 0.154, 0.96) * scale, Vector3(90, 0, 0))
        "samira":
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(0.32, 0.020, 0.12) * scale, glow, Vector3(side * 0.34, 0.154, 0.54) * scale, Vector3(0, side * 24.0, 0))
                _add_box(model, Vector3(0.11, 0.38, 0.10) * scale, gold, Vector3(side * 0.55, 1.12, 0.20) * scale, Vector3(0, side * 18.0, side * 12.0))
            _add_cylinder_segments(model, 0.48 * scale, 0.012 * scale, 24, _mat("samira_combo_meter", Color(1.0, 0.30, 0.12, 0.34), 1.0, true, true), Vector3(0, 1.34, 0.30) * scale, Vector3(90, 0, 0))
        "viktor":
            _add_box(model, Vector3(0.92, 0.18, 0.12) * scale, dark, Vector3(0, 1.48, -0.18) * scale)
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(0.10, 0.42, 0.08) * scale, glow, Vector3(side * 0.42, 1.52, -0.22) * scale, Vector3(0, side * 14.0, side * 20.0))
            _add_cylinder_segments(model, 0.58 * scale, 0.012 * scale, 6, _mat("viktor_role_hexgrid", accent_soft, 0.92, true, true), Vector3(0, 0.158, 0.62) * scale, Vector3(0, 30, 0))
        "xayah":
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(0.10, 0.038, 0.96) * scale, glow, Vector3(side * 0.50, 0.158, -0.22) * scale, Vector3(0, side * -18.0, 0))
            for i in range(4):
                _add_sphere(model, 0.042 * scale, _mat("xayah_feather_pin_" + str(i), Color(1.0, 0.42, 0.70), 0.82, true), Vector3(-0.30 + float(i) * 0.20, 1.16, -0.58) * scale)
        "mordekaiser":
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(0.22, 0.64, 0.22) * scale, dark, Vector3(side * 0.76, 1.10, 0.02) * scale, Vector3(0, side * 10.0, side * 8.0))
                _add_cylinder(model, 0.034 * scale, 0.92 * scale, glow, Vector3(side * 0.82, 0.84, -0.30) * scale, Vector3(42, 0, side * 10.0))
            _add_cylinder_segments(model, 0.64 * scale, 0.012 * scale, 12, _mat("morde_tank_weight_ring", accent_soft, 0.82, true, true), Vector3(0, 0.160, 0.16) * scale, Vector3(0, 15, 0))
        "teemo":
            for i in range(4):
                var side := -1.0 if i % 2 == 0 else 1.0
                _add_sphere(model, 0.042 * scale, _mat("teemo_satchel_seed_" + str(i), Color(0.62, 1.0, 0.22), 0.86, true), Vector3(side * (0.24 + float(i) * 0.035), 0.84 + float(i) * 0.035, -0.72) * scale)
            _add_box(model, Vector3(0.64, 0.018, 0.12) * scale, _mat("teemo_trap_lane", Color(0.62, 1.0, 0.22, 0.30), 0.78, true, true), Vector3(0, 0.152, 0.72) * scale)
        "aurelion_sol":
            _add_cylinder_segments(model, 1.42 * scale, 0.010 * scale, 36, _mat("asol_role_constellation_ring", Color(0.92, 0.72, 1.0, 0.22), 0.96, true, true), Vector3(0, 0.162, 0) * scale, Vector3(0, 10, 0))
            for i in range(5):
                var angle := TAU * float(i) / 5.0 + PI * 0.10
                _add_box(model, Vector3(0.050, 0.010, 0.42) * scale, glow, Vector3(cos(angle) * 0.80, 0.170, sin(angle) * 0.52) * scale, Vector3(0, -rad_to_deg(angle), 0))
        _:
            pass

func _add_champion_combat_crest(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    var soft := _mat(champion + "_combat_crest_soft", Color(accent.r, accent.g, accent.b, 0.18), 0.78, true, true)
    var hot := _mat(champion + "_combat_crest_hot", Color(accent.r, accent.g, accent.b, 0.46), 1.05, true, true)
    var gold := _mat(champion + "_combat_crest_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42), 0.70, true, true)
    var dark := _mat(champion + "_combat_crest_dark", Color(0.018, 0.018, 0.028, 0.42), 0.02, true, true)
    var y := 0.205 * scale

    match champion:
        "jinx":
            _add_box(model, Vector3(0.24, 0.016, 1.86) * scale, hot, Vector3(0.48, y, 0.52) * scale, Vector3(0, 22, 0))
            _add_box(model, Vector3(0.18, 0.014, 1.42) * scale, _mat("jinx_crest_pink", Color(1.0, 0.24, 0.64, 0.50), 1.0, true, true), Vector3(-0.48, y + 0.010 * scale, 0.38) * scale, Vector3(0, -24, 0))
            for bead in range(6):
                var bead_x := -0.56 + float(bead) * 0.22
                var bead_col := Color(0.22, 0.82, 1.0) if bead % 2 == 0 else Color(1.0, 0.28, 0.62)
                _add_sphere(model, 0.045 * scale, _mat("jinx_crest_ammo_" + str(bead), bead_col, 0.95, true), Vector3(bead_x, y + 0.055 * scale, -0.55) * scale)
        "senna":
            _add_box(model, Vector3(0.26, 0.016, 2.14) * scale, hot, Vector3(0, y, 0.80) * scale)
            _add_box(model, Vector3(1.04, 0.014, 0.11) * scale, gold, Vector3(0, y + 0.010 * scale, 0.18) * scale)
            _add_cylinder_segments(model, 0.74 * scale, 0.014 * scale, 32, soft, Vector3(0, y + 0.026 * scale, 0.30) * scale, Vector3(90, 0, 0))
            for mote in range(4):
                var mote_angle := TAU * float(mote) / 4.0
                _add_sphere(model, 0.044 * scale, hot, Vector3(cos(mote_angle) * 0.58, y + 0.060 * scale, sin(mote_angle) * 0.38 + 0.30) * scale)
        "samira":
            _add_cylinder_segments(model, 0.96 * scale, 0.014 * scale, 32, _mat("samira_crest_combo_ring", Color(1.0, 0.22, 0.12, 0.32), 1.0, true, true), Vector3(0, y, 0) * scale)
            for slash in range(6):
                var slash_angle := -58.0 + float(slash) * 23.0
                var slash_pos := Vector3((float(slash) - 2.5) * 0.10, y + 0.018 * scale, 0.28 - abs(float(slash) - 2.5) * 0.035) * scale
                _add_box(model, Vector3(0.10, 0.014, 1.18) * scale, hot, slash_pos, Vector3(0, slash_angle, 0))
            _add_box(model, Vector3(0.70, 0.014, 0.11) * scale, gold, Vector3(0, y + 0.034 * scale, -0.54) * scale)
        "viktor":
            _add_cylinder_segments(model, 1.00 * scale, 0.014 * scale, 6, hot, Vector3(0, y, 0.20) * scale, Vector3(0, 30, 0))
            _add_cylinder_segments(model, 0.52 * scale, 0.012 * scale, 6, soft, Vector3(0, y + 0.018 * scale, 0.20) * scale, Vector3(0, 30, 0))
            for circuit in range(6):
                var circuit_angle := TAU * float(circuit) / 6.0
                _add_box(model, Vector3(0.050, 0.012, 0.78) * scale, hot, Vector3(cos(circuit_angle) * 0.42, y + 0.032 * scale, sin(circuit_angle) * 0.42 + 0.20) * scale, Vector3(0, -rad_to_deg(circuit_angle), 0))
            _add_box(model, Vector3(0.16, 0.014, 1.76) * scale, _mat("viktor_crest_laser_lane", Color(0.72, 0.94, 1.0, 0.46), 1.12, true, true), Vector3(0.58, y + 0.048 * scale, 0.66) * scale, Vector3(0, 14, 0))
        "xayah":
            for feather in range(7):
                var offset := float(feather) - 3.0
                var feather_color := Color(1.0, 0.30, 0.68, 0.46)
                _add_box(model, Vector3(0.080, 0.014, 1.18 - abs(offset) * 0.07) * scale, _mat("xayah_crest_feather_" + str(feather), feather_color, 1.0, true, true), Vector3(offset * 0.14, y + 0.012 * scale, -0.18 + abs(offset) * 0.055) * scale, Vector3(0, offset * 10.0, 0))
            _add_cylinder_segments(model, 0.70 * scale, 0.012 * scale, 5, soft, Vector3(0, y + 0.026 * scale, -0.12) * scale, Vector3(0, 18, 0))
        "mordekaiser":
            _add_box(model, Vector3(0.32, 0.018, 1.74) * scale, _mat("morde_crest_hammer_handle", Color(0.18, 0.42, 0.30, 0.48), 0.95, true, true), Vector3(0.24, y, 0.34) * scale, Vector3(0, -28, 0))
            _add_box(model, Vector3(0.92, 0.018, 0.38) * scale, hot, Vector3(0.64, y + 0.018 * scale, 0.88) * scale, Vector3(0, -28, 0))
            _add_cylinder_segments(model, 1.06 * scale, 0.014 * scale, 8, soft, Vector3(0, y + 0.032 * scale, 0) * scale, Vector3(0, 22.5, 0))
            for chain in range(8):
                var chain_angle := TAU * float(chain) / 8.0
                _add_box(model, Vector3(0.22, 0.012, 0.070) * scale, dark, Vector3(cos(chain_angle) * 0.88, y + 0.050 * scale, sin(chain_angle) * 0.62) * scale, Vector3(0, -rad_to_deg(chain_angle) + 18, 0))
        "teemo":
            for trap in range(3):
                var trap_angle := TAU * float(trap) / 3.0 + PI * 0.18
                var trap_pos := Vector3(cos(trap_angle) * 0.62, y, sin(trap_angle) * 0.42 + 0.18) * scale
                _add_cylinder_segments(model, 0.18 * scale, 0.014 * scale, 12, _mat("teemo_crest_mushroom_pad", Color(0.58, 1.0, 0.22, 0.34), 0.92, true, true), trap_pos)
                _add_sphere(model, 0.050 * scale, _mat("teemo_crest_spore", Color(0.70, 1.0, 0.22), 1.08, true), trap_pos + Vector3(0, 0.055 * scale, 0))
            _add_cylinder_segments(model, 0.88 * scale, 0.012 * scale, 3, soft, Vector3(0, y + 0.026 * scale, 0.10) * scale, Vector3(0, 30, 0))
            _add_box(model, Vector3(0.16, 0.012, 1.28) * scale, hot, Vector3(0.46, y + 0.038 * scale, 0.54) * scale, Vector3(0, 18, 0))
        "aurelion_sol":
            _add_cylinder_segments(model, 1.18 * scale, 0.012 * scale, 48, soft, Vector3(0, y, 0) * scale, Vector3(0, 12, 0))
            for star in range(7):
                var star_angle := TAU * float(star) / 7.0
                _add_sphere(model, 0.050 * scale, _mat("asol_crest_star_" + str(star), Color(1.0, 0.86, 0.50), 1.25, true), Vector3(cos(star_angle) * 0.92, y + 0.052 * scale, sin(star_angle) * 0.62) * scale)
            _add_tapered_cylinder(model, 0.065 * scale, 0.012 * scale, 1.44 * scale, 8, hot, Vector3(-0.26, y + 0.034 * scale, 0.18) * scale, Vector3(74, -34, 0))
            _add_box(model, Vector3(0.11, 0.012, 1.20) * scale, _mat("asol_crest_comet_lane", Color(0.92, 0.72, 1.0, 0.40), 1.0, true, true), Vector3(0.54, y + 0.046 * scale, 0.48) * scale, Vector3(0, 28, 0))
        _:
            _add_cylinder_segments(model, 0.82 * scale, 0.012 * scale, 6, soft, Vector3(0, y, 0) * scale, Vector3(0, 30, 0))

func _add_champion_live_aura(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    var aura := Node3D.new()
    aura.name = "ChampionLiveAura"
    aura.set_meta("champion", champion)
    model.add_child(aura)
    var spin_slow := Node3D.new()
    spin_slow.name = "SpinSlow"
    aura.add_child(spin_slow)
    var spin_fast := Node3D.new()
    spin_fast.name = "SpinFast"
    aura.add_child(spin_fast)
    var pulse := Node3D.new()
    pulse.name = "Pulse"
    aura.add_child(pulse)
    var accent_mat := _mat(champion + "_live_accent", Color(accent.r, accent.g, accent.b, 0.46), 1.0, true, true)
    var hot_mat := _mat(champion + "_live_hot", accent.lightened(0.22), 1.18, true)
    var gold_mat := _mat(champion + "_live_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.46), 0.86, true, true)

    match champion:
        "jinx":
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                var bead_col := Color(0.24, 0.82, 1.0) if i % 2 == 0 else Color(1.0, 0.26, 0.64)
                _add_sphere(spin_fast, 0.050 * scale, _mat("jinx_live_ammo_" + str(i), bead_col, 1.08, true), Vector3(cos(angle) * 0.86, 0.28 + float(i % 2) * 0.05, sin(angle) * 0.56) * scale)
            _add_box(pulse, Vector3(0.46, 0.022, 1.10) * scale, _mat("jinx_live_rocket_flash", Color(1.0, 0.48, 0.18, 0.34), 1.02, true, true), Vector3(0.48, 0.125, 0.66) * scale, Vector3(0, 22, 0))
        "senna":
            _add_cylinder_segments(spin_slow, 0.84 * scale, 0.014 * scale, 28, accent_mat, Vector3(0, 1.22, -0.48) * scale, Vector3(90, 0, 0))
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(spin_slow, 0.058 * scale, hot_mat, Vector3(cos(angle) * 0.72, 1.22 + sin(angle * 2.0) * 0.10, -0.48 + sin(angle) * 0.18) * scale)
            _add_box(pulse, Vector3(0.14, 0.018, 1.52) * scale, accent_mat, Vector3(0, 0.142, 0.78) * scale)
        "samira":
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_box(spin_fast, Vector3(0.08, 0.018, 0.68) * scale, _mat("samira_live_blade_" + str(i), Color(1.0, 0.36, 0.16, 0.50), 1.05, true, true), Vector3(cos(angle) * 0.70, 0.150, sin(angle) * 0.50) * scale, Vector3(0, -rad_to_deg(angle), 0))
            _add_cylinder_segments(pulse, 0.86 * scale, 0.014 * scale, 24, _mat("samira_live_combo_ring", Color(1.0, 0.22, 0.12, 0.28), 0.96, true, true), Vector3(0, 0.132, 0), Vector3.ZERO)
        "viktor":
            _add_cylinder_segments(spin_slow, 0.92 * scale, 0.012 * scale, 6, accent_mat, Vector3(0, 1.28, 0) * scale, Vector3(90, 0, 30))
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_sphere(spin_slow, 0.070 * scale, _mat("viktor_live_probe_" + str(i), Color(0.74, 0.94, 1.0), 1.18, true), Vector3(cos(angle) * 0.72, 1.30 + float(i % 2) * 0.06, sin(angle) * 0.42) * scale)
            _add_cylinder_segments(pulse, 0.58 * scale, 0.012 * scale, 6, _mat("viktor_live_hexcore_floor", Color(0.72, 0.94, 1.0, 0.36), 0.98, true, true), Vector3(0, 0.144, 0.40) * scale, Vector3(0, 30, 0))
        "xayah":
            for i in range(7):
                var offset := float(i) - 3.0
                _add_box(spin_slow, Vector3(0.060, 0.016, 0.62) * scale, _mat("xayah_live_feather_" + str(i), Color(1.0, 0.30, 0.68, 0.48), 1.0, true, true), Vector3(offset * 0.15, 0.152, -0.22 + abs(offset) * 0.06) * scale, Vector3(0, offset * 10.0, 0))
            _add_cylinder_segments(pulse, 0.78 * scale, 0.012 * scale, 5, accent_mat, Vector3(0, 0.130, -0.12) * scale, Vector3(0, 18, 0))
        "mordekaiser":
            for i in range(8):
                var angle := TAU * float(i) / 8.0
                _add_box(spin_slow, Vector3(0.20, 0.024, 0.068) * scale, _mat("morde_live_chain_" + str(i), Color(0.08, 0.18, 0.12), 0.28, true), Vector3(cos(angle) * 0.88, 0.162, sin(angle) * 0.64) * scale, Vector3(0, -rad_to_deg(angle) + 18.0, 0))
            _add_cylinder_segments(pulse, 1.02 * scale, 0.016 * scale, 8, _mat("morde_live_realm_pulse", Color(0.42, 1.0, 0.46, 0.24), 0.90, true, true), Vector3(0, 0.134, 0), Vector3(0, 22.5, 0))
        "teemo":
            for i in range(8):
                var angle := TAU * float(i) / 8.0
                var spore_radius := 0.42 + float(i % 3) * 0.10
                _add_sphere(spin_fast, 0.040 * scale, _mat("teemo_live_spore_" + str(i), Color(0.62, 1.0, 0.22), 1.02, true), Vector3(cos(angle) * spore_radius, 0.34 + float(i % 2) * 0.06, sin(angle) * spore_radius) * scale)
            _add_cylinder_segments(pulse, 0.74 * scale, 0.012 * scale, 24, _mat("teemo_live_poison_pool", Color(0.62, 1.0, 0.22, 0.24), 0.82, true, true), Vector3(0, 0.130, 0), Vector3.ZERO)
        "aurelion_sol":
            _add_cylinder_segments(spin_slow, 1.18 * scale, 0.011 * scale, 40, _mat("asol_live_outer_orbit", Color(0.92, 0.72, 1.0, 0.26), 1.0, true, true), Vector3(0, 1.22, 0) * scale, Vector3(90, 0, 0))
            _add_cylinder_segments(spin_fast, 0.72 * scale, 0.010 * scale, 32, _mat("asol_live_inner_orbit", Color(0.62, 0.86, 1.0, 0.26), 0.98, true, true), Vector3(0, 1.32, 0) * scale, Vector3(90, 0, 28))
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(spin_slow, 0.060 * scale, _mat("asol_live_star_" + str(i), Color(1.0, 0.86, 0.50), 1.30, true), Vector3(cos(angle) * 1.00, 1.24 + sin(angle * 2.0) * 0.10, sin(angle) * 0.68) * scale)
            _add_sphere(pulse, 0.13 * scale, _mat("asol_live_singularity_seed", Color(0.76, 0.38, 1.0), 1.20, true), Vector3(0, 0.160, 0.55) * scale)
        _:
            _add_cylinder_segments(pulse, 0.78 * scale, 0.012 * scale, 6, gold_mat, Vector3(0, 0.120, 0), Vector3(0, 30, 0))

func _sync_champion_live_aura(model: Node3D) -> void:
    var aura := model.get_node_or_null("ChampionLiveAura") as Node3D
    if aura == null:
        return
    var champion := str(aura.get_meta("champion", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var slow := aura.get_node_or_null("SpinSlow") as Node3D
    if slow != null:
        slow.rotation.y = time * _champion_aura_speed(champion, false)
    var fast := aura.get_node_or_null("SpinFast") as Node3D
    if fast != null:
        fast.rotation.y = -time * _champion_aura_speed(champion, true)
    var pulse := aura.get_node_or_null("Pulse") as Node3D
    if pulse != null:
        var pulse_scale := 1.0 + sin(time * (4.0 if champion == "jinx" or champion == "samira" else 2.6)) * 0.055
        pulse.scale = Vector3.ONE * pulse_scale

func _add_champion_attack_burst(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionAttackBurst") != null:
        return
    var burst := Node3D.new()
    burst.name = "ChampionAttackBurst"
    burst.visible = false
    burst.set_meta("champion", champion)
    model.add_child(burst)

    var hot := _mat(champion + "_attack_burst_hot", Color(accent.r, accent.g, accent.b, 0.54), 1.18, true, true)
    var soft := _mat(champion + "_attack_burst_soft", Color(accent.r, accent.g, accent.b, 0.26), 0.92, true, true)
    var gold := _mat(champion + "_attack_burst_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42), 0.82, true, true)
    match champion:
        "jinx":
            _add_box(burst, Vector3(0.28, 0.016, 1.64) * scale, _mat("jinx_attack_rocket_lane", Color(1.0, 0.42, 0.16, 0.42), 1.05, true, true), Vector3(0.48, 0.245, 0.96) * scale, Vector3(0, 22, 0))
            _add_cylinder_segments(burst, 0.52 * scale, 0.014 * scale, 10, gold, Vector3(0.48, 0.262, 1.62) * scale, Vector3(0, 18, 0))
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                var bead_col := Color(0.22, 0.82, 1.0) if i % 2 == 0 else Color(1.0, 0.26, 0.64)
                _add_sphere(burst, 0.045 * scale, _mat("jinx_attack_spark_" + str(i), bead_col, 1.15, true), Vector3(cos(angle) * 0.72, 0.310, sin(angle) * 0.46 + 0.56) * scale)
        "senna":
            _add_box(burst, Vector3(0.22, 0.016, 2.35) * scale, hot, Vector3(0, 0.250, 1.16) * scale)
            _add_cylinder_segments(burst, 0.82 * scale, 0.014 * scale, 28, soft, Vector3(0, 0.272, 1.04) * scale, Vector3(90, 0, 0))
            _add_box(burst, Vector3(1.16, 0.014, 0.090) * scale, gold, Vector3(0, 0.294, 0.46) * scale)
        "samira":
            _add_cylinder_segments(burst, 1.05 * scale, 0.014 * scale, 32, _mat("samira_attack_round", Color(1.0, 0.28, 0.12, 0.34), 1.05, true, true), Vector3(0, 0.235, 0), Vector3.ZERO)
            for i in range(7):
                var slash_angle := -70.0 + float(i) * 23.0
                _add_box(burst, Vector3(0.10, 0.016, 1.18) * scale, hot, Vector3((float(i) - 3.0) * 0.10, 0.260, 0.26 - abs(float(i) - 3.0) * 0.030) * scale, Vector3(0, slash_angle, 0))
        "viktor":
            _add_cylinder_segments(burst, 1.06 * scale, 0.014 * scale, 6, hot, Vector3(0, 0.242, 0.24) * scale, Vector3(0, 30, 0))
            _add_box(burst, Vector3(0.16, 0.014, 2.06) * scale, _mat("viktor_attack_laser_lane", Color(0.72, 0.94, 1.0, 0.50), 1.18, true, true), Vector3(0.56, 0.266, 0.90) * scale, Vector3(0, 14, 0))
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_sphere(burst, 0.046 * scale, hot, Vector3(cos(angle) * 0.72, 0.310, sin(angle) * 0.52 + 0.24) * scale)
        "xayah":
            for i in range(9):
                var offset := float(i) - 4.0
                _add_box(burst, Vector3(0.075, 0.016, 1.10 - abs(offset) * 0.055) * scale, hot, Vector3(offset * 0.12, 0.248, -0.04 + abs(offset) * 0.050) * scale, Vector3(0, offset * 9.0, 0))
            _add_cylinder_segments(burst, 0.78 * scale, 0.012 * scale, 5, soft, Vector3(0, 0.270, -0.10) * scale, Vector3(0, 18, 0))
        "mordekaiser":
            _add_box(burst, Vector3(0.42, 0.018, 1.92) * scale, hot, Vector3(0.26, 0.252, 0.46) * scale, Vector3(0, -28, 0))
            _add_box(burst, Vector3(1.05, 0.018, 0.42) * scale, hot, Vector3(0.72, 0.276, 0.96) * scale, Vector3(0, -28, 0))
            _add_cylinder_segments(burst, 1.14 * scale, 0.014 * scale, 8, soft, Vector3(0, 0.236, 0), Vector3(0, 22.5, 0))
        "teemo":
            _add_box(burst, Vector3(0.16, 0.012, 1.44) * scale, hot, Vector3(0.44, 0.246, 0.72) * scale, Vector3(0, 18, 0))
            _add_cylinder_segments(burst, 0.90 * scale, 0.012 * scale, 18, _mat("teemo_attack_spore_ring", Color(0.62, 1.0, 0.22, 0.28), 0.88, true, true), Vector3(0, 0.232, 0), Vector3.ZERO)
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_sphere(burst, 0.042 * scale, hot, Vector3(cos(angle) * 0.66, 0.292, sin(angle) * 0.48) * scale)
        "aurelion_sol":
            _add_cylinder_segments(burst, 1.28 * scale, 0.012 * scale, 40, soft, Vector3(0, 0.240, 0), Vector3(0, 12, 0))
            _add_tapered_cylinder(burst, 0.078 * scale, 0.014 * scale, 1.64 * scale, 8, hot, Vector3(0.42, 0.280, 0.66) * scale, Vector3(74, -30, 0))
            for i in range(7):
                var angle := TAU * float(i) / 7.0
                _add_sphere(burst, 0.050 * scale, _mat("asol_attack_star_" + str(i), Color(1.0, 0.86, 0.50), 1.26, true), Vector3(cos(angle) * 0.94, 0.310, sin(angle) * 0.64) * scale)
        _:
            _add_cylinder_segments(burst, 0.88 * scale, 0.012 * scale, 6, hot, Vector3(0, 0.235, 0), Vector3(0, 30, 0))

func _sync_champion_attack_burst(model: Node3D, player: Node2D) -> void:
    var burst := model.get_node_or_null("ChampionAttackBurst") as Node3D
    if burst == null:
        return
    var attack_timer := maxf(0.0, float(player.get("attack_timer")))
    var attack_cooldown := maxf(0.16, float(player.get("attack_cooldown")))
    var ratio := clampf(attack_timer / attack_cooldown, 0.0, 1.0)
    var visible_ratio := clampf((ratio - 0.36) / 0.64, 0.0, 1.0)
    burst.visible = visible_ratio > 0.02
    if not burst.visible:
        return
    var champion := str(burst.get_meta("champion", ""))
    var time := Time.get_ticks_msec() / 1000.0
    burst.rotation.y += _champion_attack_burst_spin(champion)
    var pulse := 1.0 + visible_ratio * 0.30 + sin(time * _champion_attack_burst_pulse(champion)) * 0.045
    burst.scale = Vector3.ONE * pulse

func _champion_attack_burst_spin(champion: String) -> float:
    match champion:
        "samira", "jinx", "teemo":
            return 0.075
        "xayah", "aurelion_sol":
            return -0.052
        "mordekaiser":
            return 0.026
        "senna", "viktor":
            return 0.018
        _:
            return 0.030

func _champion_attack_burst_pulse(champion: String) -> float:
    match champion:
        "samira", "jinx":
            return 7.0
        "teemo":
            return 4.4
        "mordekaiser":
            return 2.2
        "aurelion_sol":
            return 3.0
        _:
            return 3.8

func _add_champion_signature_cast_rig(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionSignatureCastRig") != null:
        return
    var rig := Node3D.new()
    rig.name = "ChampionSignatureCastRig"
    rig.visible = false
    rig.set_meta("champion", champion)
    model.add_child(rig)

    var core := Node3D.new()
    core.name = "ChampionSignatureCastCore"
    rig.add_child(core)
    var lane := Node3D.new()
    lane.name = "ChampionSignatureCastLane"
    rig.add_child(lane)
    var motif := Node3D.new()
    motif.name = "ChampionSignatureCastMotif"
    motif.set_meta("champion", champion)
    rig.add_child(motif)

    var soft := _mat(champion + "_signature_cast_soft", Color(accent.r, accent.g, accent.b, 0.24), 0.88, true, true)
    var hot := _mat(champion + "_signature_cast_hot", Color(accent.lightened(0.16).r, accent.lightened(0.16).g, accent.lightened(0.16).b, 0.52), 1.16, true, true)
    var gold := _mat(champion + "_signature_cast_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.40), 0.80, true, true)
    var dark := _mat(champion + "_signature_cast_dark", Color(0.012, 0.012, 0.022, 0.38), 0.04, true, true)
    var y := 0.325 * scale

    _add_cylinder_segments(core, 0.72 * scale, 0.010 * scale, 6, soft, Vector3(0, y, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(core, 0.42 * scale, 0.008 * scale, 24, gold, Vector3(0, y + 0.016 * scale, 0))

    match champion:
        "jinx":
            var pink := _mat("jinx_signature_cast_pink", Color(1.0, 0.24, 0.64, 0.52), 1.12, true, true)
            var blue := _mat("jinx_signature_cast_blue", Color(0.22, 0.82, 1.0, 0.52), 1.12, true, true)
            _add_box(lane, Vector3(0.18, 0.010, 1.62) * scale, hot, Vector3(0.42, y + 0.020 * scale, 0.82) * scale, Vector3(0, 22, 0))
            for i in range(5):
                var t := -0.42 + float(i) * 0.21
                _add_sphere(motif, 0.040 * scale, blue if i % 2 == 0 else pink, Vector3(t, y + 0.062 * scale, -0.44) * scale)
        "senna":
            _add_box(lane, Vector3(0.16, 0.010, 2.10) * scale, hot, Vector3(0, y + 0.020 * scale, 0.96) * scale)
            _add_cylinder_segments(motif, 0.56 * scale, 0.010 * scale, 24, soft, Vector3(0, y + 0.050 * scale, 0.76) * scale, Vector3(90, 0, 0))
            _add_box(motif, Vector3(0.92, 0.010, 0.070) * scale, gold, Vector3(0, y + 0.064 * scale, 0.30) * scale)
        "samira":
            _add_cylinder_segments(lane, 0.86 * scale, 0.010 * scale, 24, hot, Vector3(0, y + 0.018 * scale, 0) * scale)
            for i in range(5):
                var slash_angle := -48.0 + float(i) * 24.0
                _add_box(motif, Vector3(0.080, 0.012, 0.92) * scale, hot, Vector3((float(i) - 2.0) * 0.10, y + 0.052 * scale, 0.16) * scale, Vector3(0, slash_angle, 0))
        "viktor":
            _add_cylinder_segments(lane, 0.82 * scale, 0.010 * scale, 6, hot, Vector3(0, y + 0.018 * scale, 0.18) * scale, Vector3(0, 30, 0))
            _add_box(lane, Vector3(0.12, 0.010, 1.66) * scale, hot, Vector3(0.48, y + 0.040 * scale, 0.76) * scale, Vector3(0, 14, 0))
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_sphere(motif, 0.048 * scale, hot, Vector3(cos(angle) * 0.56, y + 0.070 * scale, sin(angle) * 0.42 + 0.18) * scale)
        "xayah":
            for i in range(7):
                var offset := float(i) - 3.0
                _add_box(lane, Vector3(0.060, 0.012, 0.96 - abs(offset) * 0.052) * scale, hot, Vector3(offset * 0.12, y + 0.026 * scale, -0.06 + abs(offset) * 0.045) * scale, Vector3(0, offset * 10.0, 0))
            _add_cylinder_segments(motif, 0.58 * scale, 0.010 * scale, 5, soft, Vector3(0, y + 0.060 * scale, -0.08) * scale, Vector3(0, 18, 0))
        "mordekaiser":
            _add_cylinder_segments(lane, 0.94 * scale, 0.012 * scale, 8, soft, Vector3(0, y + 0.018 * scale, 0) * scale, Vector3(0, 22.5, 0))
            _add_box(motif, Vector3(0.28, 0.012, 1.44) * scale, hot, Vector3(0.20, y + 0.054 * scale, 0.34) * scale, Vector3(0, -28, 0))
            _add_box(motif, Vector3(0.76, 0.012, 0.28) * scale, hot, Vector3(0.56, y + 0.070 * scale, 0.72) * scale, Vector3(0, -28, 0))
            _add_box(motif, Vector3(0.24, 0.010, 0.060) * scale, dark, Vector3(-0.58, y + 0.064 * scale, -0.30) * scale, Vector3(0, 20, 0))
        "teemo":
            _add_box(lane, Vector3(0.12, 0.010, 1.18) * scale, hot, Vector3(0.38, y + 0.026 * scale, 0.58) * scale, Vector3(0, 18, 0))
            _add_cylinder_segments(motif, 0.68 * scale, 0.010 * scale, 16, soft, Vector3(0, y + 0.050 * scale, 0) * scale)
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_sphere(motif, 0.038 * scale, hot, Vector3(cos(angle) * 0.48, y + 0.080 * scale, sin(angle) * 0.34) * scale)
        "aurelion_sol":
            _add_cylinder_segments(lane, 1.02 * scale, 0.010 * scale, 40, soft, Vector3(0, y + 0.018 * scale, 0) * scale, Vector3(0, 12, 0))
            _add_tapered_cylinder(motif, 0.058 * scale, 0.010 * scale, 1.26 * scale, 8, hot, Vector3(0.34, y + 0.062 * scale, 0.48) * scale, Vector3(74, -30, 0))
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(motif, 0.042 * scale, _mat("asol_signature_cast_star_" + str(i), Color(1.0, 0.86, 0.50), 1.22, true), Vector3(cos(angle) * 0.72, y + 0.086 * scale, sin(angle) * 0.48) * scale)
        _:
            _add_box(lane, Vector3(0.12, 0.010, 1.20) * scale, hot, Vector3(0, y + 0.024 * scale, 0.50) * scale)
            _add_cylinder_segments(motif, 0.52 * scale, 0.010 * scale, 6, soft, Vector3(0, y + 0.050 * scale, 0) * scale, Vector3(0, 30, 0))
    _add_champion_signature_cast_identity(rig, champion, accent, scale, y, hot, soft, gold, dark)
    _add_champion_signature_cast_role_telegraph(rig, champion, accent, scale, y, hot, soft, gold, dark)
    _add_champion_signature_cast_pattern_floor(rig, champion, accent, scale, y)

func _add_champion_signature_cast_identity(rig: Node3D, champion: String, accent: Color, scale: float, y: float, hot: Material, soft: Material, gold: Material, dark: Material) -> void:
    var identity := Node3D.new()
    identity.name = "ChampionSignatureCastIdentity"
    identity.set_meta("champion", champion)
    identity.set_meta("identity_signature", _champion_signature_identity_name(champion))
    rig.add_child(identity)

    var accent_hot := _mat(champion + "_signature_identity_accent", Color(accent.lightened(0.20).r, accent.lightened(0.20).g, accent.lightened(0.20).b, 0.58), 1.22, true, true)
    var void_soft := _mat(champion + "_signature_identity_void", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.24), 0.88, true, true)
    _add_cylinder_segments(identity, 0.92 * scale, 0.008 * scale, 6, soft, Vector3(0, y + 0.086 * scale, 0.08) * scale, Vector3(0, 30, 0))
    _add_cylinder_segments(identity, 0.54 * scale, 0.008 * scale, 24, void_soft, Vector3(0, y + 0.102 * scale, 0.08) * scale)

    match champion:
        "jinx":
            var rocket := Node3D.new()
            rocket.name = "ChampionSignatureJinxRocketFuse"
            identity.add_child(rocket)
            _add_box(rocket, Vector3(0.22, 0.014, 0.84) * scale, accent_hot, Vector3(0.34, y + 0.142 * scale, 0.46) * scale, Vector3(0, 24, 0))
            _add_sphere(rocket, 0.080 * scale, _mat("jinx_signature_identity_pop", Color(1.0, 0.28, 0.64), 1.26, true), Vector3(0.48, y + 0.170 * scale, 0.88) * scale)
            for i in range(3):
                var spark_x := -0.20 + float(i) * 0.20
                _add_sphere(rocket, 0.038 * scale, gold, Vector3(spark_x, y + 0.170 * scale, 0.18 + abs(spark_x) * 0.16) * scale)
        "senna":
            var gate := Node3D.new()
            gate.name = "ChampionSignatureSennaSoulGate"
            identity.add_child(gate)
            _add_cylinder_segments(gate, 0.72 * scale, 0.010 * scale, 28, soft, Vector3(0, y + 0.150 * scale, 0.42) * scale, Vector3(90, 0, 0))
            _add_box(gate, Vector3(1.02, 0.012, 0.070) * scale, gold, Vector3(0, y + 0.172 * scale, 0.10) * scale)
            _add_sphere(gate, 0.074 * scale, accent_hot, Vector3(-0.42, y + 0.190 * scale, 0.42) * scale)
            _add_sphere(gate, 0.074 * scale, accent_hot, Vector3(0.42, y + 0.190 * scale, 0.42) * scale)
        "samira":
            var style := Node3D.new()
            style.name = "ChampionSignatureSamiraStyleRank"
            identity.add_child(style)
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_box(style, Vector3(0.070, 0.012, 0.44) * scale, accent_hot, Vector3(cos(angle) * 0.54, y + 0.150 * scale, sin(angle) * 0.36 + 0.10) * scale, Vector3(0, -rad_to_deg(angle), 0))
            _add_sphere(style, 0.070 * scale, gold, Vector3(0, y + 0.188 * scale, 0.10) * scale)
        "viktor":
            var hexcore := Node3D.new()
            hexcore.name = "ChampionSignatureViktorHexcoreBeam"
            identity.add_child(hexcore)
            _add_cylinder_segments(hexcore, 0.58 * scale, 0.010 * scale, 6, accent_hot, Vector3(0, y + 0.150 * scale, 0.20) * scale, Vector3(0, 30, 0))
            _add_box(hexcore, Vector3(0.100, 0.012, 1.08) * scale, accent_hot, Vector3(0.44, y + 0.170 * scale, 0.56) * scale, Vector3(0, 14, 0))
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_sphere(hexcore, 0.046 * scale, gold, Vector3(cos(angle) * 0.42, y + 0.190 * scale, sin(angle) * 0.30 + 0.20) * scale)
        "xayah":
            var recall := Node3D.new()
            recall.name = "ChampionSignatureXayahFeatherRecall"
            identity.add_child(recall)
            for i in range(5):
                var offset := float(i) - 2.0
                _add_box(recall, Vector3(0.060, 0.012, 0.72 - abs(offset) * 0.060) * scale, accent_hot, Vector3(offset * 0.18, y + 0.152 * scale, -0.10 + abs(offset) * 0.070) * scale, Vector3(0, offset * -12.0, 0))
            _add_cylinder_segments(recall, 0.52 * scale, 0.008 * scale, 5, soft, Vector3(0, y + 0.174 * scale, -0.08) * scale, Vector3(0, 18, 0))
        "mordekaiser":
            var seal := Node3D.new()
            seal.name = "ChampionSignatureMordeRealmSeal"
            identity.add_child(seal)
            _add_cylinder_segments(seal, 0.70 * scale, 0.010 * scale, 8, soft, Vector3(0, y + 0.148 * scale, 0.06) * scale, Vector3(0, 22.5, 0))
            _add_box(seal, Vector3(0.28, 0.012, 0.88) * scale, accent_hot, Vector3(0.20, y + 0.170 * scale, 0.26) * scale, Vector3(0, -28, 0))
            _add_box(seal, Vector3(0.66, 0.012, 0.24) * scale, accent_hot, Vector3(0.48, y + 0.188 * scale, 0.56) * scale, Vector3(0, -28, 0))
            _add_box(seal, Vector3(0.46, 0.010, 0.054) * scale, dark, Vector3(-0.38, y + 0.176 * scale, -0.24) * scale, Vector3(0, 24, 0))
        "teemo":
            var trap := Node3D.new()
            trap.name = "ChampionSignatureTeemoMushroomTrap"
            identity.add_child(trap)
            _add_cylinder_segments(trap, 0.62 * scale, 0.008 * scale, 16, soft, Vector3(0, y + 0.146 * scale, 0.06) * scale)
            _add_sphere(trap, 0.090 * scale, accent_hot, Vector3(0, y + 0.190 * scale, 0.06) * scale)
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(trap, 0.036 * scale, hot, Vector3(cos(angle) * 0.46, y + 0.174 * scale, sin(angle) * 0.30 + 0.06) * scale)
        "aurelion_sol":
            var forge := Node3D.new()
            forge.name = "ChampionSignatureAsolStarForge"
            identity.add_child(forge)
            _add_cylinder_segments(forge, 0.82 * scale, 0.008 * scale, 40, soft, Vector3(0, y + 0.146 * scale, 0.04) * scale, Vector3(0, 12, 0))
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_sphere(forge, 0.046 * scale, _mat("asol_signature_identity_star_" + str(i), Color(1.0, 0.86, 0.50), 1.24, true), Vector3(cos(angle) * 0.62, y + 0.184 * scale, sin(angle) * 0.44 + 0.04) * scale)
            _add_tapered_cylinder(forge, 0.052 * scale, 0.010 * scale, 0.94 * scale, 8, accent_hot, Vector3(0.34, y + 0.182 * scale, 0.42) * scale, Vector3(74, -30, 0))
        _:
            _add_box(identity, Vector3(0.64, 0.010, 0.068) * scale, accent_hot, Vector3(0, y + 0.150 * scale, 0) * scale)
            _add_box(identity, Vector3(0.068, 0.010, 0.64) * scale, accent_hot, Vector3(0, y + 0.152 * scale, 0) * scale)

func _add_champion_signature_cast_role_telegraph(rig: Node3D, champion: String, accent: Color, scale: float, y: float, hot: Material, soft: Material, gold: Material, dark: Material) -> void:
    if rig.get_node_or_null("ChampionSignatureCastRoleTelegraph") != null:
        return
    var telegraph := Node3D.new()
    telegraph.name = "ChampionSignatureCastRoleTelegraph"
    telegraph.visible = false
    telegraph.set_meta("champion", champion)
    telegraph.set_meta("cast_role", _champion_signature_cast_role(champion))
    telegraph.set_meta("detail_node", _champion_signature_cast_telegraph_detail_name(champion))
    rig.add_child(telegraph)

    var frame := Node3D.new()
    frame.name = "ChampionCastTelegraphFrame"
    telegraph.add_child(frame)
    var meter := Node3D.new()
    meter.name = "ChampionCastTelegraphMeter"
    telegraph.add_child(meter)
    var detail := Node3D.new()
    detail.name = _champion_signature_cast_telegraph_detail_name(champion)
    detail.set_meta("cast_role", _champion_signature_cast_role(champion))
    telegraph.add_child(detail)

    var accent_hot := _mat(champion + "_cast_role_hot", Color(accent.lightened(0.24).r, accent.lightened(0.24).g, accent.lightened(0.24).b, 0.58), 1.24, true, true)
    var accent_soft := _mat(champion + "_cast_role_soft", Color(accent.r, accent.g, accent.b, 0.22), 0.84, true, true)
    _add_cylinder_segments(frame, 1.04 * scale, 0.008 * scale, 6, soft, Vector3(0, y + 0.120 * scale, 0.12 * scale), Vector3(0, 30, 0))
    _add_box(meter, Vector3(0.86, 0.010, 0.060) * scale, gold, Vector3(0, y + 0.156 * scale, -0.48 * scale))

    match champion:
        "jinx":
            _add_box(detail, Vector3(0.16, 0.014, 1.28) * scale, accent_hot, Vector3(0.38 * scale, y + 0.184 * scale, 0.48 * scale), Vector3(0, 22, 0))
            _add_sphere(detail, 0.072 * scale, hot, Vector3(0.54 * scale, y + 0.210 * scale, 1.10 * scale))
            for i in range(3):
                var spark_x := -0.18 + float(i) * 0.18
                _add_sphere(detail, 0.034 * scale, _mat("jinx_cast_role_spark_" + str(i), Color(0.24, 0.86, 1.0), 1.18, true), Vector3(spark_x * scale, y + 0.206 * scale, 0.02 * scale + abs(spark_x) * 0.18 * scale))
        "senna":
            _add_box(detail, Vector3(0.20, 0.014, 1.84) * scale, accent_hot, Vector3(0, y + 0.188 * scale, 0.72 * scale))
            _add_cylinder_segments(detail, 0.66 * scale, 0.010 * scale, 28, soft, Vector3(0, y + 0.210 * scale, 0.62 * scale), Vector3(90, 0, 0))
            _add_box(detail, Vector3(1.10, 0.012, 0.070) * scale, gold, Vector3(0, y + 0.232 * scale, 0.16 * scale))
        "samira":
            for i in range(5):
                var slash_angle := -54.0 + float(i) * 27.0
                _add_box(detail, Vector3(0.086, 0.014, 0.92) * scale, accent_hot, Vector3((float(i) - 2.0) * 0.10 * scale, y + 0.192 * scale, 0.16 * scale), Vector3(0, slash_angle, 0))
            _add_cylinder_segments(detail, 0.66 * scale, 0.009 * scale, 24, accent_soft, Vector3(0, y + 0.176 * scale, 0), Vector3.ZERO)
        "viktor":
            _add_cylinder_segments(detail, 0.62 * scale, 0.010 * scale, 6, accent_hot, Vector3(0, y + 0.188 * scale, 0.12 * scale), Vector3(0, 30, 0))
            _add_box(detail, Vector3(0.115, 0.014, 1.72) * scale, _mat("viktor_cast_role_ray", Color(0.72, 0.94, 1.0, 0.58), 1.28, true, true), Vector3(0.42 * scale, y + 0.214 * scale, 0.76 * scale), Vector3(0, 14, 0))
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_sphere(detail, 0.040 * scale, gold, Vector3(cos(angle) * 0.42 * scale, y + 0.234 * scale, sin(angle) * 0.30 * scale + 0.14 * scale))
        "xayah":
            for i in range(7):
                var offset := float(i) - 3.0
                _add_box(detail, Vector3(0.056, 0.014, 0.84 - abs(offset) * 0.050) * scale, accent_hot, Vector3(offset * 0.14 * scale, y + 0.190 * scale, -0.04 * scale + abs(offset) * 0.048 * scale), Vector3(0, offset * -12.0, 0))
            _add_cylinder_segments(detail, 0.50 * scale, 0.008 * scale, 5, soft, Vector3(0, y + 0.216 * scale, -0.04 * scale), Vector3(0, 18, 0))
        "mordekaiser":
            _add_cylinder_segments(detail, 0.78 * scale, 0.010 * scale, 8, soft, Vector3(0, y + 0.178 * scale, 0.02 * scale), Vector3(0, 22.5, 0))
            _add_box(detail, Vector3(0.32, 0.016, 1.26) * scale, accent_hot, Vector3(0.20 * scale, y + 0.206 * scale, 0.26 * scale), Vector3(0, -28, 0))
            _add_box(detail, Vector3(0.84, 0.016, 0.32) * scale, accent_hot, Vector3(0.54 * scale, y + 0.228 * scale, 0.58 * scale), Vector3(0, -28, 0))
            _add_box(detail, Vector3(0.42, 0.010, 0.054) * scale, dark, Vector3(-0.42 * scale, y + 0.212 * scale, -0.28 * scale), Vector3(0, 24, 0))
        "teemo":
            _add_cylinder_segments(detail, 0.58 * scale, 0.008 * scale, 16, accent_soft, Vector3(0, y + 0.176 * scale, 0.06 * scale))
            _add_sphere(detail, 0.088 * scale, accent_hot, Vector3(0, y + 0.220 * scale, 0.06 * scale))
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(detail, 0.032 * scale, hot, Vector3(cos(angle) * 0.42 * scale, y + 0.204 * scale, sin(angle) * 0.28 * scale + 0.06 * scale))
        "aurelion_sol":
            _add_cylinder_segments(detail, 0.92 * scale, 0.008 * scale, 40, accent_soft, Vector3(0, y + 0.176 * scale, 0.02 * scale), Vector3(0, 12, 0))
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(detail, 0.046 * scale, _mat("asol_cast_role_star_" + str(i), Color(1.0, 0.86, 0.50), 1.26, true), Vector3(cos(angle) * 0.70 * scale, y + 0.218 * scale, sin(angle) * 0.48 * scale + 0.02 * scale))
            _add_tapered_cylinder(detail, 0.052 * scale, 0.010 * scale, 1.10 * scale, 8, accent_hot, Vector3(0.34 * scale, y + 0.212 * scale, 0.42 * scale), Vector3(74, -30, 0))
        _:
            _add_box(detail, Vector3(0.70, 0.012, 0.080) * scale, accent_hot, Vector3(0, y + 0.188 * scale, 0))
            _add_box(detail, Vector3(0.080, 0.012, 0.70) * scale, accent_hot, Vector3(0, y + 0.190 * scale, 0))

func _champion_signature_cast_pattern_type(champion: String) -> String:
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

func _champion_signature_cast_pattern_detail_name(champion: String) -> String:
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

func _champion_signature_cast_impact_count(champion: String) -> int:
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

func _add_champion_signature_cast_pattern_floor(rig: Node3D, champion: String, accent: Color, scale: float, y: float) -> void:
    if rig.get_node_or_null("ChampionSignatureCastPatternFloor") != null:
        return
    var floor := Node3D.new()
    floor.name = "ChampionSignatureCastPatternFloor"
    floor.visible = false
    floor.set_meta("champion", champion)
    floor.set_meta("pattern_type", _champion_signature_cast_pattern_type(champion))
    floor.set_meta("detail_node", _champion_signature_cast_pattern_detail_name(champion))
    floor.set_meta("impact_marker_count", _champion_signature_cast_impact_count(champion))
    floor.set_meta("combat_visual_channel", "champion_cast_pattern_readability")
    floor.set_meta("material_grade", "low_glare_champion_cast_pattern_floor")
    floor.set_meta("champion_cast_pattern_floor_layer", true)
    rig.add_child(floor)

    var role_color := _champion_kit_role_color(champion, accent)
    var shadow := _mat(champion + "_cast_pattern_shadow", Color(0.0, 0.0, 0.0, 0.28), 0.0, true, true)
    var lane_mat := _mat(champion + "_cast_pattern_lane", Color(role_color.r, role_color.g, role_color.b, 0.22), 0.05, true, true)
    var tick_mat := _mat(champion + "_cast_pattern_tick", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24), 0.04, true, true)
    var accent_mat := _mat(champion + "_cast_pattern_accent", Color(accent.r, accent.g, accent.b, 0.24), 0.06, true, true)

    var base := Node3D.new()
    base.name = "ChampionCastPatternShadow"
    base.set_meta("combat_visual_channel", "champion_cast_pattern_readability")
    floor.add_child(base)
    _add_cylinder_segments(base, 1.22 * scale, 0.006 * scale, 8, shadow, Vector3(0, y - 0.082 * scale, 0), Vector3(0, 22.5, 0))

    var lanes := Node3D.new()
    lanes.name = "ChampionCastPatternImpactLanes"
    lanes.set_meta("impact_marker_count", _champion_signature_cast_impact_count(champion))
    lanes.set_meta("combat_visual_channel", "champion_cast_pattern_readability")
    floor.add_child(lanes)

    var pips := Node3D.new()
    pips.name = "ChampionCastPatternAnchorPips"
    pips.set_meta("impact_marker_count", _champion_signature_cast_impact_count(champion))
    pips.set_meta("combat_visual_channel", "champion_cast_pattern_readability")
    floor.add_child(pips)

    var detail := Node3D.new()
    detail.name = _champion_signature_cast_pattern_detail_name(champion)
    detail.set_meta("champion", champion)
    detail.set_meta("base_y", y + 0.014 * scale)
    detail.set_meta("combat_visual_channel", "champion_cast_pattern_readability")
    floor.add_child(detail)

    match champion:
        "jinx":
            _add_box(lanes, Vector3(0.22, 0.008, 2.35) * scale, lane_mat, Vector3(0.34, y - 0.058 * scale, 0.92) * scale, Vector3(0, 18, 0)).name = "ChampionCastPatternLanePrimary"
            for i in range(3):
                var z := (0.18 + float(i) * 0.52) * scale
                _add_cylinder_segments(pips, 0.105 * scale, 0.008 * scale, 8, tick_mat, Vector3(0.34 * scale, y - 0.036 * scale, z), Vector3(0, 22.5, 0)).name = "ChampionCastPatternImpactMarker%d" % i
            _add_tapered_cylinder(detail, 0.060 * scale, 0.012 * scale, 0.72 * scale, 8, accent_mat, Vector3(0.34 * scale, y + 0.014 * scale, 1.40 * scale), Vector3(72, 18, 0))
        "senna":
            _add_box(lanes, Vector3(0.18, 0.008, 2.72) * scale, lane_mat, Vector3(0, y - 0.058 * scale, 1.06) * scale).name = "ChampionCastPatternLanePrimary"
            for side in [-1.0, 1.0]:
                _add_box(lanes, Vector3(0.040, 0.008, 2.42) * scale, tick_mat, Vector3(side * 0.26 * scale, y - 0.036 * scale, 0.98 * scale)).name = "ChampionCastPatternImpactMarker" + ("L" if side < 0.0 else "R")
                _add_sphere(pips, 0.036 * scale, tick_mat, Vector3(side * 0.34 * scale, y - 0.018 * scale, 0.30 * scale)).name = "ChampionCastPatternAnchorPip" + ("L" if side < 0.0 else "R")
            _add_cylinder_segments(detail, 0.54 * scale, 0.008 * scale, 28, accent_mat, Vector3(0, y + 0.014 * scale, 0.72 * scale), Vector3(90, 0, 0))
        "samira":
            _add_cylinder_segments(lanes, 0.88 * scale, 0.008 * scale, 24, lane_mat, Vector3(0, y - 0.058 * scale, 0)).name = "ChampionCastPatternLanePrimary"
            for i in range(5):
                var angle := -54.0 + float(i) * 27.0
                _add_box(pips, Vector3(0.064, 0.008, 0.64) * scale, tick_mat, Vector3((float(i) - 2.0) * 0.10 * scale, y - 0.034 * scale, 0.18 * scale), Vector3(0, angle, 0)).name = "ChampionCastPatternImpactMarker%d" % i
            _add_cylinder_segments(detail, 0.58 * scale, 0.008 * scale, 16, accent_mat, Vector3(0, y + 0.014 * scale, 0))
        "viktor":
            _add_cylinder_segments(lanes, 0.66 * scale, 0.008 * scale, 6, lane_mat, Vector3(0, y - 0.058 * scale, 0.10 * scale), Vector3(0, 30, 0)).name = "ChampionCastPatternLanePrimary"
            _add_box(lanes, Vector3(0.105, 0.008, 2.04) * scale, lane_mat, Vector3(0.40 * scale, y - 0.036 * scale, 0.82 * scale), Vector3(0, 14, 0)).name = "ChampionCastPatternImpactMarker0"
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_sphere(pips, 0.044 * scale, tick_mat, Vector3(cos(angle) * 0.44 * scale, y - 0.018 * scale, sin(angle) * 0.32 * scale + 0.10 * scale)).name = "ChampionCastPatternImpactMarker%d" % (i + 1)
            _add_box(detail, Vector3(0.080, 0.008, 1.42) * scale, accent_mat, Vector3(0.40 * scale, y + 0.014 * scale, 0.74 * scale), Vector3(0, 14, 0))
        "xayah":
            for i in range(7):
                var offset := float(i) - 3.0
                _add_box(lanes, Vector3(0.052, 0.008, 1.05 - abs(offset) * 0.060) * scale, lane_mat, Vector3(offset * 0.14 * scale, y - 0.048 * scale, -0.02 * scale + abs(offset) * 0.052 * scale), Vector3(0, offset * -11.0, 0)).name = "ChampionCastPatternImpactMarker%d" % i
                if i % 2 == 0:
                    _add_sphere(pips, 0.034 * scale, tick_mat, Vector3(offset * 0.14 * scale, y - 0.018 * scale, -0.10 * scale + abs(offset) * 0.048 * scale)).name = "ChampionCastPatternAnchorPip%d" % i
            _add_cylinder_segments(detail, 0.48 * scale, 0.008 * scale, 5, accent_mat, Vector3(0, y + 0.014 * scale, -0.04 * scale), Vector3(0, 18, 0))
        "mordekaiser":
            _add_cylinder_segments(lanes, 0.92 * scale, 0.008 * scale, 8, lane_mat, Vector3(0, y - 0.058 * scale, 0), Vector3(0, 22.5, 0)).name = "ChampionCastPatternLanePrimary"
            for i in range(4):
                var angle := TAU * float(i) / 4.0 + PI * 0.25
                _add_box(pips, Vector3(0.070, 0.008, 0.58) * scale, tick_mat, Vector3(cos(angle) * 0.54 * scale, y - 0.030 * scale, sin(angle) * 0.42 * scale), Vector3(0, -rad_to_deg(angle), 0)).name = "ChampionCastPatternImpactMarker%d" % i
            _add_box(detail, Vector3(0.76, 0.008, 0.24) * scale, accent_mat, Vector3(0.42 * scale, y + 0.014 * scale, 0.42 * scale), Vector3(0, -28, 0))
        "teemo":
            _add_cylinder_segments(lanes, 0.70 * scale, 0.008 * scale, 16, lane_mat, Vector3(0, y - 0.058 * scale, 0.04 * scale)).name = "ChampionCastPatternLanePrimary"
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(pips, 0.044 * scale, tick_mat, Vector3(cos(angle) * 0.46 * scale, y - 0.018 * scale, sin(angle) * 0.32 * scale + 0.04 * scale)).name = "ChampionCastPatternImpactMarker%d" % i
            _add_sphere(detail, 0.090 * scale, accent_mat, Vector3(0, y + 0.014 * scale, 0.04 * scale))
        "aurelion_sol":
            _add_cylinder_segments(lanes, 1.02 * scale, 0.008 * scale, 40, lane_mat, Vector3(0, y - 0.058 * scale, 0), Vector3(0, 12, 0)).name = "ChampionCastPatternLanePrimary"
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_sphere(pips, 0.044 * scale, tick_mat, Vector3(cos(angle) * 0.76 * scale, y - 0.018 * scale, sin(angle) * 0.52 * scale)).name = "ChampionCastPatternImpactMarker%d" % i
            _add_tapered_cylinder(detail, 0.050 * scale, 0.010 * scale, 1.00 * scale, 8, accent_mat, Vector3(0.34 * scale, y + 0.014 * scale, 0.44 * scale), Vector3(74, -30, 0))
        _:
            _add_box(lanes, Vector3(0.12, 0.008, 1.30) * scale, lane_mat, Vector3(0, y - 0.058 * scale, 0.48 * scale)).name = "ChampionCastPatternLanePrimary"
            for i in range(3):
                _add_sphere(pips, 0.040 * scale, tick_mat, Vector3((float(i) - 1.0) * 0.24 * scale, y - 0.018 * scale, 0.44 * scale)).name = "ChampionCastPatternImpactMarker%d" % i
            _add_box(detail, Vector3(0.66, 0.008, 0.060) * scale, accent_mat, Vector3(0, y + 0.014 * scale, 0))

func _champion_signature_cast_role(champion: String) -> String:
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

func _champion_signature_cast_telegraph_detail_name(champion: String) -> String:
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

func _champion_signature_identity_name(champion: String) -> String:
    match champion:
        "jinx":
            return "rocket_fuse"
        "senna":
            return "soul_gate"
        "samira":
            return "style_rank"
        "viktor":
            return "hexcore_beam"
        "xayah":
            return "feather_recall"
        "mordekaiser":
            return "realm_seal"
        "teemo":
            return "mushroom_trap"
        "aurelion_sol":
            return "star_forge"
        _:
            return "generic_cast"

func _sync_champion_signature_cast_rig(model: Node3D, player: Node2D) -> void:
    var rig := model.get_node_or_null("ChampionSignatureCastRig") as Node3D
    if rig == null:
        return
    var attack_timer := maxf(0.0, float(player.get("attack_timer")))
    var attack_cooldown := maxf(0.16, float(player.get("attack_cooldown")))
    var readiness := 1.0 - clampf(attack_timer / attack_cooldown, 0.0, 1.0)
    rig.visible = readiness > 0.42
    if not rig.visible:
        return
    var champion := str(rig.get_meta("champion", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var readiness_pulse := lerpf(0.80, 1.18, readiness) + sin(time * _champion_signature_cast_pulse(champion)) * 0.030
    rig.scale = Vector3(readiness_pulse, 1.0, readiness_pulse)
    rig.rotation.y += _champion_signature_cast_spin(champion)
    var motif := rig.get_node_or_null("ChampionSignatureCastMotif") as Node3D
    if motif != null:
        motif.position.y = sin(time * 5.6) * 0.010
        motif.scale = Vector3.ONE * (1.0 + readiness * 0.12)
    var lane := rig.get_node_or_null("ChampionSignatureCastLane") as Node3D
    if lane != null:
        lane.scale = Vector3(1.0 + readiness * 0.06, 1.0, 1.0 + readiness * 0.14)
    var identity := rig.get_node_or_null("ChampionSignatureCastIdentity") as Node3D
    if identity != null:
        identity.rotation.y -= _champion_signature_cast_spin(champion) * 0.82
        identity.scale = Vector3.ONE * (0.88 + readiness * 0.30 + sin(time * _champion_signature_cast_pulse(champion) * 1.18) * 0.024)
        identity.position.y = sin(time * 6.4) * 0.008
    var telegraph := rig.get_node_or_null("ChampionSignatureCastRoleTelegraph") as Node3D
    if telegraph != null:
        telegraph.visible = true
        var role := str(telegraph.get_meta("cast_role", ""))
        telegraph.position.y = sin(time * 4.2) * 0.006
        telegraph.scale = Vector3(0.84 + readiness * 0.26, 1.0, 0.84 + readiness * 0.34)
        telegraph.rotation.y += _champion_signature_cast_telegraph_spin(champion)
        var frame := telegraph.get_node_or_null("ChampionCastTelegraphFrame") as Node3D
        if frame != null:
            frame.rotation.y -= _champion_signature_cast_telegraph_spin(champion) * 0.72
        var meter := telegraph.get_node_or_null("ChampionCastTelegraphMeter") as Node3D
        if meter != null:
            meter.scale = Vector3(0.54 + readiness * 0.72, 1.0, 1.0)
        var detail_name := str(telegraph.get_meta("detail_node", ""))
        var detail := telegraph.get_node_or_null(detail_name) as Node3D
        if detail != null:
            detail.visible = true
            _sync_champion_signature_cast_telegraph_detail(detail, role, readiness, time)
    var pattern_floor := rig.get_node_or_null("ChampionSignatureCastPatternFloor") as Node3D
    if pattern_floor != null:
        _sync_champion_signature_cast_pattern_floor(pattern_floor, champion, readiness, time)

func _champion_signature_cast_spin(champion: String) -> float:
    match champion:
        "samira", "jinx":
            return 0.060
        "xayah", "aurelion_sol":
            return -0.042
        "mordekaiser":
            return 0.018
        "senna", "viktor":
            return 0.012
        _:
            return 0.030

func _champion_signature_cast_pulse(champion: String) -> float:
    match champion:
        "jinx", "samira":
            return 6.4
        "teemo":
            return 4.4
        "mordekaiser":
            return 2.4
        "aurelion_sol":
            return 3.2
        _:
            return 3.8

func _champion_signature_cast_telegraph_spin(champion: String) -> float:
    match champion:
        "samira", "jinx":
            return 0.046
        "xayah", "aurelion_sol":
            return -0.034
        "mordekaiser":
            return 0.012
        "senna", "viktor":
            return 0.008
        _:
            return 0.022

func _sync_champion_signature_cast_telegraph_detail(detail: Node3D, role: String, readiness: float, time: float) -> void:
    match role:
        "artillery_burst":
            detail.position.z = readiness * 0.08
            detail.scale = Vector3.ONE * (0.92 + readiness * 0.22)
        "soul_beam", "hexcore_ray":
            detail.scale = Vector3(0.94 + readiness * 0.10, 1.0, 0.86 + readiness * 0.34)
            detail.position.z = readiness * 0.10
        "duelist_combo":
            detail.rotation.y += 0.058
            detail.scale = Vector3.ONE * (0.88 + readiness * 0.28)
        "feather_recall":
            detail.rotation.y -= 0.034
            detail.scale = Vector3(0.96 + readiness * 0.14, 1.0, 0.90 + readiness * 0.22)
        "realm_crush":
            detail.scale = Vector3(0.90 + readiness * 0.28, 1.0, 0.90 + readiness * 0.20)
            detail.position.y = sin(time * 2.2) * 0.008
        "poison_trap":
            detail.scale = Vector3.ONE * (0.94 + readiness * 0.16 + sin(time * 4.8) * 0.018)
        "starfall":
            detail.rotation.y -= 0.026
            detail.position.y = sin(time * 2.8) * 0.010
        _:
            detail.scale = Vector3.ONE * (0.94 + readiness * 0.18)

func _sync_champion_signature_cast_pattern_floor(pattern_floor: Node3D, champion: String, readiness: float, time: float) -> void:
    pattern_floor.visible = true
    pattern_floor.set_meta("cast_readiness", readiness)
    var pattern_type := str(pattern_floor.get_meta("pattern_type", _champion_signature_cast_pattern_type(champion)))
    pattern_floor.scale = Vector3(0.88 + readiness * 0.18, 1.0, 0.88 + readiness * 0.26)
    pattern_floor.rotation.y += _champion_signature_cast_telegraph_spin(champion) * 0.52

    var lanes := pattern_floor.get_node_or_null("ChampionCastPatternImpactLanes") as Node3D
    if lanes != null:
        var lane_push := 0.16
        match pattern_type:
            "artillery_line", "piercing_beam":
                lane_push = 0.26
            "melee_arc", "realm_slam_circle":
                lane_push = 0.10
            "star_orbit_fall":
                lane_push = 0.18
            _:
                lane_push = 0.14
        lanes.scale = Vector3(1.0 + readiness * 0.05, 1.0, 1.0 + readiness * lane_push)

    var pips := pattern_floor.get_node_or_null("ChampionCastPatternAnchorPips") as Node3D
    if pips != null:
        pips.position.y = sin(time * 4.8) * 0.005
        pips.scale = Vector3.ONE * (0.94 + readiness * 0.14)

    var detail_name := str(pattern_floor.get_meta("detail_node", ""))
    var detail := pattern_floor.get_node_or_null(detail_name) as Node3D
    if detail == null:
        return
    detail.visible = true
    detail.position.y = sin(time * 5.2) * 0.006
    match pattern_type:
        "artillery_line":
            detail.position.z = readiness * 0.12
            detail.rotation.y += 0.014
            detail.scale = Vector3(0.95 + readiness * 0.18, 1.0, 0.95 + readiness * 0.26)
        "piercing_beam":
            detail.position.z = readiness * 0.10
            detail.scale = Vector3(0.90 + readiness * 0.10, 1.0, 0.90 + readiness * 0.34)
        "melee_arc":
            detail.rotation.y += 0.050
            detail.scale = Vector3.ONE * (0.90 + readiness * 0.26)
        "hex_ray_grid":
            detail.rotation.y += 0.010
            detail.scale = Vector3(0.94 + readiness * 0.12, 1.0, 0.94 + readiness * 0.30)
        "feather_fan_recall":
            detail.rotation.y -= 0.030
            detail.scale = Vector3(0.98 + readiness * 0.10, 1.0, 0.92 + readiness * 0.22)
        "realm_slam_circle":
            detail.scale = Vector3.ONE * (0.88 + readiness * 0.28)
        "trap_field_radius":
            detail.scale = Vector3.ONE * (0.92 + readiness * 0.18 + sin(time * 4.4) * 0.016)
        "star_orbit_fall":
            detail.rotation.y -= 0.024
            detail.position.z = readiness * 0.05
            detail.scale = Vector3.ONE * (0.94 + readiness * 0.20)
        _:
            detail.scale = Vector3.ONE * (0.94 + readiness * 0.18)

func _add_player_status_rings(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("PlayerStatusRings") != null:
        return
    var root := Node3D.new()
    root.name = "PlayerStatusRings"
    root.set_meta("champion", champion)
    model.add_child(root)

    var shield := Node3D.new()
    shield.name = "Shield"
    shield.visible = false
    root.add_child(shield)
    _add_cylinder_segments(shield, 1.04 * scale, 0.014 * scale, 48, _mat("player_status_shield_outer", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.34), 1.05, true, true), Vector3(0, 0.178 * scale, 0))
    _add_cylinder_segments(shield, 0.76 * scale, 0.012 * scale, 6, _mat("player_status_shield_hex", Color(0.62, 0.90, 1.0, 0.24), 0.92, true, true), Vector3(0, 0.202 * scale, 0), Vector3(0, 30, 0))
    for i in range(6):
        var angle := TAU * float(i) / 6.0
        var pip := _add_sphere(shield, 0.040 * scale, _mat("player_status_shield_pip", Color(0.62, 0.92, 1.0), 1.15, true), Vector3(cos(angle) * 0.90 * scale, 0.242 * scale, sin(angle) * 0.90 * scale))
        pip.name = "ShieldPip" + str(i)
        pip.set_meta("pip", i)

    var danger := Node3D.new()
    danger.name = "LowHealth"
    danger.visible = false
    root.add_child(danger)
    _add_cylinder_segments(danger, 1.12 * scale, 0.016 * scale, 8, _mat("player_status_low_health", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.34), 1.15, true, true), Vector3(0, 0.210 * scale, 0), Vector3(0, 22.5, 0))
    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        _add_box(danger, Vector3(0.13, 0.018, 0.46) * scale, _mat("player_status_low_health_spike", Color(1.0, 0.24, 0.12, 0.42), 1.05, true, true), Vector3(cos(angle) * 0.98 * scale, 0.236 * scale, sin(angle) * 0.98 * scale), Vector3(0, -rad_to_deg(angle), 0))

    var hextech := Node3D.new()
    hextech.name = "Hextech"
    hextech.visible = false
    root.add_child(hextech)
    _add_cylinder_segments(hextech, 1.22 * scale, 0.012 * scale, 6, _mat("player_status_hextech_outer", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.28), 1.0, true, true), Vector3(0, 0.230 * scale, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(hextech, 0.98 * scale, 0.010 * scale, 6, _mat("player_status_hextech_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.34), 0.88, true, true), Vector3(0, 0.256 * scale, 0), Vector3(0, 30, 0))
    for i in range(6):
        var angle := TAU * float(i) / 6.0
        var shard := _add_tapered_cylinder(hextech, 0.046 * scale, 0.018 * scale, 0.22 * scale, 6, _mat("player_status_hextech_shard", Color(accent.r, accent.g, accent.b, 0.94), 1.18, true), Vector3(cos(angle) * 1.10 * scale, 0.350 * scale, sin(angle) * 1.10 * scale), Vector3(0, 30, 0))
        shard.name = "HexShard" + str(i)
        shard.set_meta("shard", i)

    var level_ring := Node3D.new()
    level_ring.name = "Level"
    level_ring.visible = false
    root.add_child(level_ring)
    _add_cylinder_segments(level_ring, 0.92 * scale, 0.010 * scale, 24, _mat("player_status_level_base", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.18), 0.66, true, true), Vector3(0, 0.264 * scale, 0))
    for i in range(10):
        var angle := TAU * float(i) / 10.0
        var tick := _add_box(level_ring, Vector3(0.11, 0.018, 0.26) * scale, _mat("player_status_level_tick", Color(1.0, 0.78, 0.28, 0.76), 0.92, true, true), Vector3(cos(angle) * 0.82 * scale, 0.290 * scale, sin(angle) * 0.82 * scale), Vector3(0, -rad_to_deg(angle), 0))
        tick.name = "LevelTick" + str(i)
        tick.set_meta("tick", i)
        tick.visible = false

    var recipes := Node3D.new()
    recipes.name = "Recipes"
    recipes.visible = false
    root.add_child(recipes)
    _add_cylinder_segments(recipes, 1.36 * scale, 0.012 * scale, 12, _mat("player_status_recipe_outer", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.30), 0.92, true, true), Vector3(0, 0.312 * scale, 0), Vector3(0, 15, 0))
    _add_cylinder_segments(recipes, 1.08 * scale, 0.010 * scale, 6, _mat("player_status_recipe_inner", Color(accent.r, accent.g, accent.b, 0.24), 1.0, true, true), Vector3(0, 0.338 * scale, 0), Vector3(0, 30, 0))
    for i in range(6):
        var recipe_angle := TAU * float(i) / 6.0 + PI * 0.16
        var star := _add_tapered_cylinder(recipes, 0.060 * scale, 0.020 * scale, 0.24 * scale, 5, _mat("player_status_recipe_star", Color(1.0, 0.78, 0.28), 1.22, true), Vector3(cos(recipe_angle) * 1.22 * scale, 0.438 * scale, sin(recipe_angle) * 1.22 * scale), Vector3(0, 18, 0))
        star.name = "RecipeStar" + str(i)
        star.set_meta("recipe", i)
        star.visible = false

    var items := Node3D.new()
    items.name = "Items"
    items.visible = false
    root.add_child(items)
    _add_cylinder_segments(items, 1.52 * scale, 0.010 * scale, 8, _mat("player_status_items_outer", Color(HEXTECH_BLUE.r, HEXTECH_BLUE.g, HEXTECH_BLUE.b, 0.24), 0.80, true, true), Vector3(0, 0.296 * scale, 0), Vector3(0, 22.5, 0))
    for i in range(6):
        var item_angle := TAU * float(i) / 6.0 - PI * 0.10
        var trophy := Node3D.new()
        trophy.name = "ItemTrophy" + str(i)
        trophy.set_meta("item", i)
        trophy.position = Vector3(cos(item_angle) * 1.42 * scale, 0.384 * scale, sin(item_angle) * 1.42 * scale)
        trophy.rotation.y = -item_angle
        trophy.visible = false
        items.add_child(trophy)
        _add_box(trophy, Vector3(0.18, 0.030, 0.13) * scale, _mat("player_status_item_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.78), 0.72, true, true), Vector3.ZERO)
        _add_sphere(trophy, 0.040 * scale, _mat("player_status_item_gem", Color(accent.r, accent.g, accent.b, 0.98), 1.20, true), Vector3(0, 0.048 * scale, 0))

func _sync_player_status_rings(model: Node3D, player: Node2D) -> void:
    var root := model.get_node_or_null("PlayerStatusRings") as Node3D
    if root == null:
        return
    var time := Time.get_ticks_msec() / 1000.0

    var shield_amount := maxi(0, int(player.get("shield")))
    var shield := root.get_node_or_null("Shield") as Node3D
    if shield != null:
        shield.visible = shield_amount > 0
        if shield.visible:
            shield.rotation.y = time * 1.14
            shield.scale = Vector3.ONE * (1.0 + minf(float(shield_amount), 10.0) * 0.026 + sin(time * 4.3) * 0.025)
            var shield_pips := mini(6, maxi(1, shield_amount))
            for child in shield.get_children():
                if child.has_meta("pip"):
                    child.visible = int(child.get_meta("pip")) < shield_pips

    var health := maxf(0.0, float(player.get("health")))
    var max_health := maxf(1.0, float(player.get("max_health")))
    var health_ratio := health / max_health
    var low_health := root.get_node_or_null("LowHealth") as Node3D
    if low_health != null:
        low_health.visible = health_ratio <= 0.35
        if low_health.visible:
            low_health.rotation.y = -time * 1.75
            low_health.scale = Vector3.ONE * (1.0 + (0.35 - health_ratio) * 0.24 + sin(time * 7.5) * 0.052)

    var augment_count := 0
    if player.has_method("get_hextech_augment_ids"):
        var augment_ids = player.call("get_hextech_augment_ids")
        if augment_ids is Array:
            augment_count = augment_ids.size()
    var hextech := root.get_node_or_null("Hextech") as Node3D
    if hextech != null:
        hextech.visible = augment_count > 0
        if hextech.visible:
            hextech.rotation.y = -time * 0.58
            hextech.scale = Vector3.ONE * (1.0 + minf(float(augment_count), 6.0) * 0.035)
            var shown_shards := mini(6, augment_count)
            for child in hextech.get_children():
                if child.has_meta("shard"):
                    child.visible = int(child.get_meta("shard")) < shown_shards

    var level := maxi(1, int(player.get("level")))
    var level_marks := mini(10, maxi(0, level - 1))
    var level_ring := root.get_node_or_null("Level") as Node3D
    if level_ring != null:
        level_ring.visible = level_marks > 0
        if level_ring.visible:
            level_ring.rotation.y = time * 0.32
            level_ring.scale = Vector3.ONE * (1.0 + minf(float(level), 20.0) * 0.006)
            for child in level_ring.get_children():
                if child.has_meta("tick"):
                    child.visible = int(child.get_meta("tick")) < level_marks

    var recipe_count := 0
    var recipe_value = player.get("recipe_synergies")
    if recipe_value is Dictionary:
        recipe_count = recipe_value.size()
    var recipes := root.get_node_or_null("Recipes") as Node3D
    if recipes != null:
        recipes.visible = recipe_count > 0
        if recipes.visible:
            recipes.rotation.y = -time * 0.38
            recipes.scale = Vector3.ONE * (1.0 + minf(float(recipe_count), 6.0) * 0.045 + sin(time * 2.2) * 0.018)
            var recipe_marks := mini(6, recipe_count)
            for child in recipes.get_children():
                if child.has_meta("recipe"):
                    child.visible = int(child.get_meta("recipe")) < recipe_marks

    var item_count := 0
    var item_value = player.get("league_items")
    if item_value is Dictionary:
        for key in item_value.keys():
            item_count += maxi(1, int(item_value[key]))
    var items := root.get_node_or_null("Items") as Node3D
    if items != null:
        items.visible = item_count > 0
        if items.visible:
            items.rotation.y = time * 0.26
            items.scale = Vector3.ONE * (1.0 + minf(float(item_count), 6.0) * 0.028)
            var item_marks := mini(6, item_count)
            for child in items.get_children():
                if child.has_meta("item"):
                    child.visible = int(child.get_meta("item")) < item_marks

func _champion_aura_speed(champion: String, fast: bool) -> float:
    if fast:
        match champion:
            "jinx", "samira", "teemo":
                return 2.20
            "aurelion_sol":
                return 0.92
            _:
                return 1.45
    match champion:
        "mordekaiser":
            return 0.34
        "senna", "viktor", "xayah":
            return 0.58
        "aurelion_sol":
            return 0.42
        _:
            return 0.66

func _add_champion_upgrade_routes(model: Node3D, champion: String, accent: Color, scale: float) -> void:
    if model.get_node_or_null("ChampionUpgradeRoutes") != null:
        return
    var ids := _champion_upgrade_ids(champion)
    if ids.is_empty():
        return
    var root := Node3D.new()
    root.name = "ChampionUpgradeRoutes"
    root.visible = false
    model.add_child(root)
    for i in range(ids.size()):
        var upgrade_id := str(ids[i])
        var route := Node3D.new()
        route.name = "UpgradeRoute" + str(i)
        route.visible = false
        route.set_meta("upgrade_id", upgrade_id)
        route.set_meta("route_index", i)
        var angle := TAU * float(i) / float(ids.size()) - PI * 0.50
        route.position = Vector3(cos(angle) * 1.22 * scale, 0.02, sin(angle) * 1.22 * scale)
        route.rotation.y = -angle
        root.add_child(route)

        var route_color := _upgrade_route_color(upgrade_id, accent)
        var route_glow := _mat("upgrade_route_glow_" + upgrade_id, Color(route_color.r, route_color.g, route_color.b, 0.32), 1.0, true, true)
        var route_gold := _mat("upgrade_route_gold_" + upgrade_id, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.34), 0.78, true, true)
        var pulse := Node3D.new()
        pulse.name = "RoutePulse"
        route.add_child(pulse)
        _add_cylinder_segments(pulse, 0.24 * scale, 0.010 * scale, 6, route_glow, Vector3(0, 0.150 * scale, 0), Vector3(0, 30, 0))
        _add_cylinder_segments(pulse, 0.18 * scale, 0.008 * scale, 6, route_gold, Vector3(0, 0.168 * scale, 0), Vector3(0, 30, 0))
        _add_box(route, Vector3(0.052, 0.008, 0.46) * scale, route_glow, Vector3(0, 0.132 * scale, -0.24 * scale))
        _add_upgrade_route_symbol(route, upgrade_id, route_color, scale)

func _sync_champion_upgrade_routes(model: Node3D, player: Node2D) -> void:
    var root := model.get_node_or_null("ChampionUpgradeRoutes") as Node3D
    if root == null:
        return
    var inventory: Dictionary = {}
    var inventory_value = player.get("inventory")
    if inventory_value is Dictionary:
        inventory = inventory_value
    var time := Time.get_ticks_msec() / 1000.0
    var active_count := 0
    for route in root.get_children():
        var upgrade_id := str(route.get_meta("upgrade_id", ""))
        var route_count := int(inventory.get(upgrade_id, 0))
        route.visible = route_count > 0
        if not route.visible:
            continue
        active_count += 1
        var route_index := int(route.get_meta("route_index", 0))
        route.position.y = 0.02 + sin(time * (2.4 + float(route_index) * 0.3)) * 0.018
        route.scale = Vector3.ONE * (1.0 + minf(float(route_count), 4.0) * 0.12 + sin(time * (2.2 + float(route_index) * 0.5)) * 0.030)
        var pulse := route.get_node_or_null("RoutePulse") as Node3D
        if pulse != null:
            pulse.rotation.y = time * (0.58 + float(route_index) * 0.16)
    root.visible = active_count > 0

func _champion_upgrade_ids(champion: String) -> Array:
    match champion:
        "jinx":
            return ["jinx_rockets", "jinx_fireworks", "jinx_zoomies"]
        "senna":
            return ["senna_souls", "senna_absolution", "senna_laser"]
        "samira":
            return ["samira_combo", "samira_inferno", "samira_daredevil"]
        "viktor":
            return ["viktor_laser", "viktor_storm", "viktor_hexcore"]
        "xayah":
            return ["xayah_feathers", "xayah_recall", "xayah_root"]
        "mordekaiser":
            return ["morde_darkness", "morde_realm", "morde_iron"]
        "teemo":
            return ["teemo_poison", "teemo_shrooms", "teemo_blind"]
        "aurelion_sol":
            return ["asol_stars", "asol_singularity", "asol_comet"]
        _:
            return []

func _upgrade_route_color(upgrade_id: String, accent: Color) -> Color:
    if upgrade_id.contains("rocket") or upgrade_id.contains("firework") or upgrade_id.contains("inferno") or upgrade_id.contains("comet"):
        return Color(1.0, 0.44, 0.16)
    if upgrade_id.contains("soul") or upgrade_id.contains("absolution"):
        return Color(0.62, 1.0, 0.78)
    if upgrade_id.contains("laser") or upgrade_id.contains("storm") or upgrade_id.contains("hexcore"):
        return Color(0.70, 0.94, 1.0)
    if upgrade_id.contains("feather") or upgrade_id.contains("recall") or upgrade_id.contains("root"):
        return Color(1.0, 0.34, 0.68)
    if upgrade_id.contains("morde") or upgrade_id.contains("darkness") or upgrade_id.contains("realm") or upgrade_id.contains("iron"):
        return Color(0.46, 1.0, 0.46)
    if upgrade_id.contains("teemo") or upgrade_id.contains("poison") or upgrade_id.contains("shroom") or upgrade_id.contains("blind"):
        return Color(0.62, 1.0, 0.22)
    if upgrade_id.contains("asol") or upgrade_id.contains("singularity") or upgrade_id.contains("stars"):
        return Color(0.92, 0.72, 1.0)
    return accent.lightened(0.10)

func _add_upgrade_route_symbol(parent: Node3D, upgrade_id: String, color: Color, scale: float) -> void:
    var hot := _mat("upgrade_symbol_hot_" + upgrade_id, color.lightened(0.10), 1.15, true)
    var soft := _mat("upgrade_symbol_soft_" + upgrade_id, Color(color.r, color.g, color.b, 0.36), 1.0, true, true)
    if upgrade_id.contains("rocket") or upgrade_id.contains("laser") or upgrade_id.contains("comet"):
        _add_tapered_cylinder(parent, 0.054 * scale, 0.012 * scale, 0.46 * scale, 8, hot, Vector3(0, 0.225 * scale, 0.025 * scale), Vector3(90, 0, 0))
        _add_projectile_tail_lite(parent, 0.026 * scale, 0.30 * scale, color, -0.22 * scale)
    elif upgrade_id.contains("firework") or upgrade_id.contains("inferno") or upgrade_id.contains("storm"):
        _add_cylinder_segments(parent, 0.22 * scale, 0.010 * scale, 5, soft, Vector3(0, 0.220 * scale, 0), Vector3(0, 18, 0))
        for i in range(5):
            var angle := TAU * float(i) / 5.0
            _add_sphere(parent, 0.030 * scale, hot, Vector3(cos(angle) * 0.20 * scale, 0.248 * scale, sin(angle) * 0.20 * scale))
    elif upgrade_id.contains("zoomies") or upgrade_id.contains("daredevil") or upgrade_id.contains("recall"):
        for i in range(3):
            var offset := float(i) - 1.0
            _add_box(parent, Vector3(0.050, 0.012, 0.44) * scale, soft, Vector3(offset * 0.090 * scale, 0.218 * scale, 0), Vector3(0, offset * 13.0, offset * 20.0))
    elif upgrade_id.contains("soul") or upgrade_id.contains("absolution"):
        _add_sphere(parent, 0.090 * scale, hot, Vector3(0, 0.230 * scale, 0))
        _add_cylinder_segments(parent, 0.22 * scale, 0.010 * scale, 24, soft, Vector3(0, 0.230 * scale, 0), Vector3(90, 0, 0))
    elif upgrade_id.contains("combo"):
        _add_box(parent, Vector3(0.045, 0.012, 0.42) * scale, hot, Vector3(-0.050 * scale, 0.220 * scale, 0), Vector3(0, 24, 34))
        _add_box(parent, Vector3(0.045, 0.012, 0.42) * scale, hot, Vector3(0.050 * scale, 0.220 * scale, 0), Vector3(0, -24, -34))
    elif upgrade_id.contains("hexcore"):
        _add_cylinder_segments(parent, 0.22 * scale, 0.012 * scale, 6, soft, Vector3(0, 0.220 * scale, 0), Vector3(0, 30, 0))
        _add_sphere(parent, 0.058 * scale, hot, Vector3(0, 0.246 * scale, 0))
    elif upgrade_id.contains("feather") or upgrade_id.contains("root"):
        for i in range(3):
            var offset := float(i) - 1.0
            _add_box(parent, Vector3(0.042, 0.012, 0.38 - abs(offset) * 0.05) * scale, hot, Vector3(offset * 0.070 * scale, 0.220 * scale, 0), Vector3(0, offset * 11.0, offset * 16.0))
    elif upgrade_id.contains("darkness") or upgrade_id.contains("realm"):
        _add_cylinder_segments(parent, 0.23 * scale, 0.012 * scale, 8, soft, Vector3(0, 0.218 * scale, 0), Vector3(0, 22.5, 0))
        for i in range(4):
            var angle := TAU * float(i) / 4.0
            _add_box(parent, Vector3(0.080, 0.012, 0.030) * scale, hot, Vector3(cos(angle) * 0.20 * scale, 0.246 * scale, sin(angle) * 0.20 * scale), Vector3(0, -rad_to_deg(angle), 0))
    elif upgrade_id.contains("iron"):
        _add_cylinder_segments(parent, 0.20 * scale, 0.018 * scale, 6, hot, Vector3(0, 0.220 * scale, 0), Vector3(0, 30, 0))
        _add_box(parent, Vector3(0.27, 0.012, 0.050) * scale, soft, Vector3(0, 0.248 * scale, 0))
    elif upgrade_id.contains("shroom"):
        _add_cylinder(parent, 0.036 * scale, 0.16 * scale, _mat("upgrade_symbol_shroom_stem", Color(0.88, 0.76, 0.52), 0.06, true), Vector3(0, 0.178 * scale, 0))
        _add_sphere(parent, 0.094 * scale, hot, Vector3(0, 0.274 * scale, 0))
    elif upgrade_id.contains("poison") or upgrade_id.contains("blind"):
        _add_sphere(parent, 0.080 * scale, hot, Vector3(0, 0.222 * scale, 0))
        _add_box(parent, Vector3(0.30, 0.012, 0.052) * scale, soft, Vector3(0, 0.250 * scale, 0), Vector3(0, 0, -18))
    elif upgrade_id.contains("stars") or upgrade_id.contains("singularity"):
        _add_cylinder_segments(parent, 0.23 * scale, 0.010 * scale, 32, soft, Vector3(0, 0.222 * scale, 0), Vector3(90, 0, 0))
        _add_sphere(parent, 0.055 * scale, hot, Vector3(0.17 * scale, 0.226 * scale, 0))
    else:
        _add_sphere(parent, 0.070 * scale, hot, Vector3(0, 0.225 * scale, 0))

func _add_role_route_rings(model: Node3D, accent: Color, scale: float) -> void:
    if model.get_node_or_null("RoleRouteRings") != null:
        return
    var root := Node3D.new()
    root.name = "RoleRouteRings"
    root.visible = false
    model.add_child(root)
    var routes := ["physical_hex", "magic_hex", "tank_hex", "summon_hex", "melee_hex", "marksman_hex", "support_hex"]
    for i in range(routes.size()):
        var route_id := str(routes[i])
        var route := Node3D.new()
        route.name = "RoleRoute" + str(i)
        route.visible = false
        route.set_meta("route_id", route_id)
        route.set_meta("route_index", i)
        var angle := TAU * float(i) / float(routes.size()) + PI * 0.08
        route.position = Vector3(cos(angle) * 1.62 * scale, 0.018, sin(angle) * 1.62 * scale)
        route.rotation.y = -angle
        root.add_child(route)
        var route_color := _role_route_color(route_id, accent)
        var route_mat := _mat("role_route_ring_" + route_id, Color(route_color.r, route_color.g, route_color.b, 0.30), 0.98, true, true)
        var hot_mat := _mat("role_route_hot_" + route_id, route_color.lightened(0.10), 1.05, true)
        var pulse := Node3D.new()
        pulse.name = "RoutePulse"
        route.add_child(pulse)
        _add_cylinder_segments(pulse, 0.20 * scale, 0.010 * scale, 6, route_mat, Vector3(0, 0.186 * scale, 0), Vector3(0, 30, 0))
        _add_role_route_symbol(route, route_id, route_color, route_mat, hot_mat, scale)

func _sync_role_route_rings(model: Node3D, player: Node2D) -> void:
    var root := model.get_node_or_null("RoleRouteRings") as Node3D
    if root == null:
        return
    var inventory: Dictionary = {}
    var inventory_value = player.get("inventory")
    if inventory_value is Dictionary:
        inventory = inventory_value
    var time := Time.get_ticks_msec() / 1000.0
    var active_count := 0
    for route in root.get_children():
        var route_id := str(route.get_meta("route_id", ""))
        var route_count := int(inventory.get(route_id, 0))
        route.visible = route_count > 0
        if not route.visible:
            continue
        active_count += 1
        var route_index := int(route.get_meta("route_index", 0))
        route.position.y = 0.018 + sin(time * (1.8 + float(route_index) * 0.18)) * 0.014
        route.scale = Vector3.ONE * (1.0 + minf(float(route_count), 4.0) * 0.10)
        var pulse := route.get_node_or_null("RoutePulse") as Node3D
        if pulse != null:
            pulse.rotation.y = -time * (0.42 + float(route_index) * 0.08)
    root.visible = active_count > 0

func _role_route_color(route_id: String, accent: Color) -> Color:
    match route_id:
        "physical_hex":
            return Color(1.0, 0.50, 0.18)
        "magic_hex":
            return Color(0.64, 0.78, 1.0)
        "tank_hex":
            return Color(0.54, 0.94, 1.0)
        "summon_hex":
            return Color(0.50, 1.0, 0.34)
        "melee_hex":
            return Color(1.0, 0.24, 0.22)
        "marksman_hex":
            return Color(1.0, 0.82, 0.28)
        "support_hex":
            return Color(0.66, 1.0, 0.82)
        _:
            return accent

func _add_role_route_symbol(parent: Node3D, route_id: String, route_color: Color, route_mat: Material, hot_mat: Material, scale: float) -> void:
    match route_id:
        "physical_hex":
            _add_box(parent, Vector3(0.050, 0.012, 0.46) * scale, hot_mat, Vector3(0, 0.238 * scale, 0), Vector3(0, 18, 32))
            _add_box(parent, Vector3(0.25, 0.010, 0.052) * scale, route_mat, Vector3(0, 0.258 * scale, 0.11 * scale), Vector3(0, 18, 0))
        "magic_hex":
            _add_cylinder_segments(parent, 0.22 * scale, 0.010 * scale, 6, route_mat, Vector3(0, 0.238 * scale, 0), Vector3(0, 30, 0))
            _add_sphere(parent, 0.062 * scale, hot_mat, Vector3(0, 0.264 * scale, 0))
        "tank_hex":
            _add_cylinder_segments(parent, 0.21 * scale, 0.016 * scale, 6, hot_mat, Vector3(0, 0.236 * scale, 0), Vector3(0, 30, 0))
            _add_box(parent, Vector3(0.28, 0.010, 0.050) * scale, route_mat, Vector3(0, 0.262 * scale, 0))
        "summon_hex":
            _add_cylinder_segments(parent, 0.23 * scale, 0.010 * scale, 8, route_mat, Vector3(0, 0.236 * scale, 0))
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_sphere(parent, 0.034 * scale, hot_mat, Vector3(cos(angle) * 0.17 * scale, 0.260 * scale, sin(angle) * 0.17 * scale))
        "melee_hex":
            _add_box(parent, Vector3(0.050, 0.012, 0.46) * scale, hot_mat, Vector3(-0.035 * scale, 0.236 * scale, 0), Vector3(0, 28, 38))
            _add_box(parent, Vector3(0.050, 0.012, 0.46) * scale, hot_mat, Vector3(0.035 * scale, 0.236 * scale, 0), Vector3(0, -28, -38))
        "marksman_hex":
            for i in range(3):
                var offset := float(i) - 1.0
                _add_tapered_cylinder(parent, 0.032 * scale, 0.010 * scale, 0.34 * scale, 6, hot_mat, Vector3(offset * 0.070 * scale, 0.238 * scale, 0), Vector3(90, 0, 0))
        "support_hex":
            _add_box(parent, Vector3(0.060, 0.010, 0.32) * scale, hot_mat, Vector3(0, 0.238 * scale, 0))
            _add_box(parent, Vector3(0.32, 0.010, 0.060) * scale, hot_mat, Vector3(0, 0.238 * scale, 0))
            _add_cylinder_segments(parent, 0.22 * scale, 0.008 * scale, 24, route_mat, Vector3(0, 0.226 * scale, 0))
        _:
            _add_sphere(parent, 0.070 * scale, hot_mat, Vector3(0, 0.238 * scale, 0))

func _add_pigtails(model: Node3D, hair: Color, scale: float, length: float) -> void:
    _add_cylinder(model, 0.08 * scale, length * scale, _mat("pigtail_l", hair, 0.12, true), Vector3(-0.36, 1.35, -0.12) * scale, Vector3(18, 0, -20))
    _add_cylinder(model, 0.08 * scale, length * scale, _mat("pigtail_r", hair, 0.12, true), Vector3(0.36, 1.35, -0.12) * scale, Vector3(18, 0, 20))
    _add_sphere(model, 0.11 * scale, _mat("pigtail_tip_l", hair.lightened(0.15), 0.25, true), Vector3(-0.62, 0.78, -0.08) * scale)
    _add_sphere(model, 0.11 * scale, _mat("pigtail_tip_r", hair.lightened(0.15), 0.25, true), Vector3(0.62, 0.78, -0.08) * scale)

func _add_cape(model: Node3D, color: Color, scale: float, width: float) -> void:
    _add_box(model, Vector3(width, 1.18, 0.08) * scale, _mat("cape_main", color, 0.05, true), Vector3(0, 0.88, -0.45) * scale, Vector3(-8, 0, 0))
    _add_box(model, Vector3(width * 0.72, 0.12, 0.10) * scale, _mat("cape_collar", color.lightened(0.10), 0.12, true), Vector3(0, 1.42, -0.30) * scale)

func _add_claw_arm(model: Node3D, accent: Color, scale: float) -> void:
    _add_cylinder(model, 0.055 * scale, 0.82 * scale, _mat("viktor_claw_arm", accent, 0.82, true), Vector3(0.56, 1.42, -0.18) * scale, Vector3(42, 0, -18))
    var base := Vector3(0.72, 1.72, 0.16) * scale
    _add_box(model, Vector3(0.10, 0.34, 0.08) * scale, _mat("viktor_claw_1", accent, 0.85, true), base + Vector3(0.00, 0.00, 0.14) * scale, Vector3(32, 0, 0))
    _add_box(model, Vector3(0.10, 0.34, 0.08) * scale, _mat("viktor_claw_2", accent, 0.85, true), base + Vector3(-0.13, -0.04, 0.06) * scale, Vector3(22, 0, 24))
    _add_box(model, Vector3(0.10, 0.34, 0.08) * scale, _mat("viktor_claw_3", accent, 0.85, true), base + Vector3(0.13, -0.04, 0.06) * scale, Vector3(22, 0, -24))

func _add_feather_wings(model: Node3D, base: Color, accent: Color, scale: float) -> void:
    for side in [-1, 1]:
        var sx := float(side)
        _add_box(model, Vector3(0.20, 0.78, 1.06) * scale, _mat("xayah_wing_base" + str(side), base, 0.20, true), Vector3(sx * 0.55, 1.00, -0.28) * scale, Vector3(0, sx * -8.0, sx * 28.0))
        for i in range(4):
            var z := -0.08 + float(i) * 0.18
            _add_box(model, Vector3(0.08, 0.58 - float(i) * 0.06, 0.16) * scale, _mat("xayah_wing_feather" + str(side) + "_" + str(i), accent, 0.36, true), Vector3(sx * (0.66 + float(i) * 0.08), 0.86 - float(i) * 0.05, z) * scale, Vector3(0, sx * -20.0, sx * (40.0 + i * 4.0)))

func _add_armor_plates(model: Node3D, metal: Color, glow: Color, scale: float) -> void:
    _add_box(model, Vector3(0.98, 0.26, 0.26) * scale, _mat("morde_pauldrons", metal, 0.12), Vector3(0, 1.36, 0.02) * scale)
    _add_box(model, Vector3(0.24, 0.42, 0.24) * scale, _mat("morde_shoulder_l", metal.lightened(0.08), 0.16), Vector3(-0.62, 1.30, 0.05) * scale)
    _add_box(model, Vector3(0.24, 0.42, 0.24) * scale, _mat("morde_shoulder_r", metal.lightened(0.08), 0.16), Vector3(0.62, 1.30, 0.05) * scale)
    _add_box(model, Vector3(0.16, 0.10, 0.44) * scale, _mat("morde_horn_l", glow, 0.55, true), Vector3(-0.20, 1.88, 0.04) * scale, Vector3(0, 0, 22))
    _add_box(model, Vector3(0.16, 0.10, 0.44) * scale, _mat("morde_horn_r", glow, 0.55, true), Vector3(0.20, 1.88, 0.04) * scale, Vector3(0, 0, -22))
    _add_cylinder(model, 0.66 * scale, 0.035 * scale, _mat("morde_realm_ring", Color(glow.r, glow.g, glow.b, 0.26), 0.80, true, true), Vector3(0, 0.07, 0))

func _add_mushroom_cluster(model: Node3D, scale: float) -> void:
    for i in range(3):
        var offset := Vector3(-0.46 + float(i) * 0.22, 0.22 + float(i % 2) * 0.04, -0.36) * scale
        _add_cylinder(model, 0.045 * scale, 0.20 * scale, _mat("mushroom_stem" + str(i), Color(0.94, 0.84, 0.66)), offset)
        _add_sphere(model, 0.12 * scale, _mat("mushroom_cap" + str(i), Color(0.86, 0.20, 0.18), 0.22, true), offset + Vector3(0, 0.12, 0))

func _add_asol_body(model: Node3D, accent: Color, scale: float) -> void:
    var body_mat := _mat("asol_segment", Color(0.16, 0.30, 0.88), 0.32, true)
    var glow_mat := _mat("asol_glow", accent, 0.95, true)
    for i in range(7):
        var t := float(i) / 6.0
        var x := -0.92 + t * 1.62
        var y := 1.05 + sin(t * TAU) * 0.14
        var z := -0.26 + cos(t * PI) * 0.30
        _add_sphere(model, (0.23 - t * 0.06) * scale, body_mat, Vector3(x, y, z) * scale)
    _add_sphere(model, 0.32 * scale, _mat("asol_head", Color(0.24, 0.42, 0.96), 0.35, true), Vector3(0.92, 1.12, 0.20) * scale)
    _add_box(model, Vector3(0.08, 0.10, 0.44) * scale, glow_mat, Vector3(0.72, 1.36, 0.12) * scale, Vector3(0, 24, 28))
    _add_box(model, Vector3(0.08, 0.10, 0.44) * scale, glow_mat, Vector3(1.03, 1.36, 0.12) * scale, Vector3(0, -24, -28))
    _add_box(model, Vector3(0.12, 0.46, 0.92) * scale, _mat("asol_wing_l", Color(0.30, 0.54, 1.0, 0.68), 0.45, true, true), Vector3(-0.10, 1.22, -0.34) * scale, Vector3(0, 0, -26))
    _add_box(model, Vector3(0.12, 0.46, 0.92) * scale, _mat("asol_wing_r", Color(0.30, 0.54, 1.0, 0.68), 0.45, true, true), Vector3(0.34, 1.20, -0.26) * scale, Vector3(0, 0, 28))
    for i in range(3):
        var angle := TAU * float(i) / 3.0
        _add_sphere(model, 0.12 * scale, _mat("asol_star" + str(i), Color(0.82, 0.92, 1.0), 1.25, true), Vector3(cos(angle) * 0.82, 1.46, sin(angle) * 0.82) * scale)
    _add_cylinder_segments(model, 0.92 * scale, 0.020 * scale, 48, _mat("asol_star_orbit_ring", Color(0.82, 0.92, 1.0, 0.28), 0.92, true, true), Vector3(0.05, 1.44, 0.02) * scale, Vector3(90, 0, 0))
    _add_tapered_cylinder(model, 0.11 * scale, 0.02 * scale, 0.86 * scale, 8, glow_mat, Vector3(-1.02, 1.00, -0.32) * scale, Vector3(76, 0, -18))
    _add_sphere(model, 0.16 * scale, _mat("asol_tail_star", Color(0.92, 0.72, 1.0), 1.35, true), Vector3(-1.24, 0.82, -0.50) * scale)

func _create_enemy_model(kind: String, boss: bool, elite: bool, body_color, hit_radius: float, lite := false, elite_trait := "") -> Node3D:
    var model := Node3D.new()
    model.set_meta("kind", kind)
    model.set_meta("elite", elite)
    model.set_meta("elite_trait", elite_trait)
    var color: Color = Color(0.54, 0.30, 0.82)
    if body_color is Color:
        color = body_color
    var radius := maxf(0.28, hit_radius * WORLD_SCALE * 1.05) * ENEMY_MODEL_SCALE
    if boss:
        radius *= 1.78
    model.set_meta("visual_radius", radius)
    var height := radius * (2.7 if boss else 1.95)
    var mat_body := _mat(kind + "_body", color, 0.22 if elite or boss else 0.08, true)
    var mat_glow := _mat(kind + "_glow", color.lightened(0.25), 0.75 if elite or boss else 0.45, true)
    var eye_mat := _mat(kind + "_eye", Color(1.0, 0.72, 1.0), 1.0, true)

    if lite and not boss:
        model.set_meta("lite_elite_model", elite)
        _add_lite_enemy_body(model, kind, radius, height, color, mat_body, mat_glow, eye_mat)
        _add_lite_enemy_readability_plate(model, kind, radius, color)
        if elite:
            _add_lite_elite_readability_package(model, kind, radius, height, color, elite_trait)
        if _enemy_has_windup_warning(kind, boss):
            _add_enemy_windup_aura(model, kind, radius, boss)
        if kind == "burrower":
            _add_enemy_charge_lane(model, kind, radius, boss, true)
        if kind == "rift_crystal":
            _add_enemy_summon_aura(model, kind, radius, boss, true)
        return model

    match kind:
        "skitter":
            _add_sphere(model, radius * 0.82, mat_body, Vector3(0, height * 0.42, 0))
            _add_bug_legs(model, radius, height, color.darkened(0.30), 3)
            _add_sphere(model, radius * 0.20, eye_mat, Vector3(-radius * 0.35, height * 0.58, radius * 0.70))
            _add_sphere(model, radius * 0.20, eye_mat, Vector3(radius * 0.35, height * 0.58, radius * 0.70))
        "spitter":
            _add_sphere(model, radius * 0.86, mat_body, Vector3(0, height * 0.42, 0))
            _add_sphere(model, radius * 0.42, _mat(kind + "_acid_sac", Color(0.42, 1.0, 0.34), 0.85, true), Vector3(0, height * 0.66, -radius * 0.28))
            _add_cylinder(model, radius * 0.24, radius * 1.00, _mat(kind + "_mouth", Color(0.10, 0.04, 0.12)), Vector3(0, height * 0.46, radius * 0.78), Vector3(90, 0, 0))
            _add_sphere(model, radius * 0.15, eye_mat, Vector3(-radius * 0.30, height * 0.60, radius * 0.62))
            _add_sphere(model, radius * 0.15, eye_mat, Vector3(radius * 0.30, height * 0.60, radius * 0.62))
        "burrower", "boss_reksai":
            _add_box(model, Vector3(radius * 2.75, height * 0.58, radius * 1.10), mat_body, Vector3(0, height * 0.36, 0))
            _add_box(model, Vector3(radius * 0.78, height * 0.32, radius * 0.92), mat_glow, Vector3(radius * 1.25, height * 0.42, radius * 0.36), Vector3(0, 0, -14))
            _add_box(model, Vector3(radius * 0.78, height * 0.32, radius * 0.92), mat_glow, Vector3(-radius * 1.25, height * 0.42, radius * 0.36), Vector3(0, 0, 14))
            for i in range(4):
                var side := -1.0 if i < 2 else 1.0
                var z := -0.30 + float(i % 2) * 0.60
                _add_box(model, Vector3(radius * 0.80, radius * 0.11, radius * 0.16), _mat(kind + "_claw" + str(i), color.darkened(0.26)), Vector3(side * radius * 1.35, height * 0.22, z * radius) , Vector3(0, 0, side * 22.0))
        "carapace":
            _add_sphere(model, radius * 0.96, mat_body, Vector3(0, height * 0.44, 0))
            for i in range(4):
                _add_box(model, Vector3(radius * 1.15, radius * 0.16, radius * 0.22), _mat(kind + "_shell" + str(i), color.darkened(0.24), 0.10), Vector3(0, height * (0.28 + i * 0.09), -radius * 0.04), Vector3(0, 0, i * 9.0 - 12.0))
            _add_bug_legs(model, radius, height, color.darkened(0.34), 2)
            _add_sphere(model, radius * 0.18, eye_mat, Vector3(0, height * 0.62, radius * 0.76))
        "void_eye", "boss_velkoz":
            _add_sphere(model, radius * 0.92, mat_body, Vector3(0, height * 0.58, 0))
            _add_sphere(model, radius * 0.46, _mat(kind + "_single_eye", Color(1.0, 0.82, 1.0), 1.2, true), Vector3(0, height * 0.60, radius * 0.72))
            _add_sphere(model, radius * 0.18, _mat(kind + "_pupil", Color(0.10, 0.02, 0.16), 0.2), Vector3(0, height * 0.60, radius * 1.08))
            _add_tentacles(model, radius, height, color.lightened(0.08), 6 if boss else 4)
        "rift_crystal":
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                var pos := Vector3(cos(angle) * radius * 0.34, height * (0.35 + 0.05 * i), sin(angle) * radius * 0.34)
                _add_cylinder(model, radius * (0.32 + 0.05 * i), height * (0.86 - 0.05 * i), _mat(kind + "_crystal" + str(i), color.lightened(0.08 * i), 0.90, true), pos, Vector3(0, float(i) * 28.0, 12.0 - i * 5.0))
        "boss_cho":
            _add_sphere(model, radius * 1.05, mat_body, Vector3(0, height * 0.45, 0))
            _add_sphere(model, radius * 0.62, mat_body, Vector3(0, height * 0.87, 0.05))
            _add_box(model, Vector3(radius * 0.22, radius * 0.26, radius * 1.20), mat_glow, Vector3(-radius * 0.42, height * 1.15, 0.10), Vector3(0, 16, -20))
            _add_box(model, Vector3(radius * 0.22, radius * 0.26, radius * 1.20), mat_glow, Vector3(radius * 0.42, height * 1.15, 0.10), Vector3(0, -16, 20))
            _add_bug_legs(model, radius, height, color.darkened(0.35), 3)
            _add_sphere(model, radius * 0.16, eye_mat, Vector3(-radius * 0.24, height * 0.92, radius * 0.62))
            _add_sphere(model, radius * 0.16, eye_mat, Vector3(radius * 0.24, height * 0.92, radius * 0.62))
        "boss_belveth":
            _add_sphere(model, radius * 0.74, mat_body, Vector3(0, height * 0.56, 0))
            _add_box(model, Vector3(radius * 0.25, height * 0.82, radius * 1.70), mat_glow, Vector3(-radius * 0.86, height * 0.62, 0), Vector3(0, 0, -30))
            _add_box(model, Vector3(radius * 0.25, height * 0.82, radius * 1.70), mat_glow, Vector3(radius * 0.86, height * 0.62, 0), Vector3(0, 0, 30))
            _add_sphere(model, radius * 0.30, eye_mat, Vector3(0, height * 0.70, radius * 0.64))
            _add_tentacles(model, radius, height, color.lightened(0.10), 8)
        _:
            _add_sphere(model, radius * 0.86, mat_body, Vector3(0, height * 0.44, 0))
            _add_bug_legs(model, radius, height, color.darkened(0.34), 2)
            _add_sphere(model, radius * 0.18, eye_mat, Vector3(-radius * 0.34, height * 0.58, radius * 0.70))
            _add_sphere(model, radius * 0.18, eye_mat, Vector3(radius * 0.34, height * 0.58, radius * 0.70))

    _add_void_creature_polish(model, kind, radius, height, color, boss, elite)
    _add_void_creature_premium_body_rig(model, kind, radius, height, color, boss, elite)
    _add_void_creature_painterly_depth_rig(model, kind, radius, height, color, boss, elite)
    _add_enemy_combat_intent_profile(model, kind, radius, height, color, boss, elite)
    _add_enemy_damage_state_rig(model, kind, radius, height, color, boss, elite)
    _add_enemy_ground_silhouette_plate(model, kind, radius, color, boss, elite)
    _add_enemy_tactical_readability_plaque(model, kind, radius, height, color, boss, elite)
    if boss or elite:
        _add_enemy_footprint_scale_rig(model, kind, radius, color, boss, elite)
        _add_enemy_threat_occlusion_plate(model, kind, radius, color, boss, elite, elite_trait, false)
    _add_enemy_threat_rank_silhouette_rig(model, kind, radius, color, boss, elite, elite_trait)
    _add_enemy_threat_tier_marker(model, kind, radius, color, boss, elite, elite_trait)
    if not boss:
        _add_enemy_readability_plate(model, kind, radius, elite)
    if elite:
        _add_cylinder(model, radius * 1.35, 0.04, _mat("elite_ring", Color(0.92, 0.54, 1.0), 0.55, true), Vector3(0, 0.055, 0))
        _add_enemy_threat_halo(model, kind, radius, false)
    if boss:
        _add_cylinder(model, radius * 1.55, 0.05, _mat("boss_ring", Color(1.0, 0.20, 0.54), 0.75, true), Vector3(0, 0.065, 0))
        _add_boss_enrage_aura(model, radius)
        _add_boss_phase_state_rig(model, kind, radius, height, color)
        _add_enemy_threat_halo(model, kind, radius, true)
    if elite or boss:
        _add_elite_boss_crest(model, kind, radius, height, boss)
        _add_void_priority_emblem(model, kind, radius, height, color, boss, elite_trait)
        _add_void_threat_silhouette(model, kind, radius, height, color, boss, elite_trait)
        _add_priority_combat_backplate(model, kind, radius, color, boss, elite_trait)
    if elite and not boss and elite_trait != "":
        _add_elite_trait_marker(model, elite_trait, radius, height)
        _add_elite_trait_telegraph(model, elite_trait, kind, radius)
    if elite or boss:
        _add_enemy_health_bar(model, radius, boss)
    if not elite and not boss:
        _add_cylinder(model, radius * 1.08, 0.022, _mat("enemy_threat_ring", Color(1.0, 0.10, 0.42, 0.32), 0.45, true, true), Vector3(0, 0.038, 0))
    if _enemy_has_windup_warning(kind, boss):
        _add_enemy_windup_aura(model, kind, radius, boss)
    if kind == "skitter" or kind == "burrower" or kind == "boss_reksai" or elite_trait == "frenzy":
        _add_enemy_charge_lane(model, kind, radius, boss)
    if kind == "rift_crystal" or kind == "boss_belveth" or kind == "boss_cho":
        _add_enemy_summon_aura(model, kind, radius, boss)
    _add_shadow(model, radius * 1.35)
    if elite or boss:
        _add_topdown_model_outline(model, kind, 1.065 if boss else 1.045)
    return model

func _add_lite_elite_readability_package(model: Node3D, kind: String, radius: float, height: float, color: Color, elite_trait: String) -> void:
    var trait_id := elite_trait
    if trait_id == "":
        trait_id = "frenzy"
    model.set_meta("elite_trait", trait_id)
    model.set_meta("dense_elite_lod", true)
    _add_enemy_combat_intent_profile(model, kind, radius, height, color, false, true)
    _add_elite_trait_marker(model, trait_id, radius, height)
    _add_elite_trait_telegraph(model, trait_id, kind, radius)
    _add_enemy_health_bar(model, radius, false)
    _add_enemy_threat_occlusion_plate(model, kind, radius, color, false, true, trait_id, true)

    var badge := Node3D.new()
    badge.name = "LiteEliteReadabilityBadge"
    badge.set_meta("elite_trait", trait_id)
    badge.set_meta("dense_elite_lod", true)
    badge.set_meta("combat_visual_channel", "enemy_lite_elite_readability")
    model.add_child(badge)
    var trait_color := _elite_trait_color(trait_id)
    var dark := _mat("lite_elite_badge_dark_" + trait_id, Color(0.0, 0.0, 0.0, 0.38), 0.0, true, true)
    var accent := _mat("lite_elite_badge_accent_" + trait_id, Color(trait_color.r, trait_color.g, trait_color.b, 0.24), 0.0, true, true)
    var reward := _mat("lite_elite_badge_reward_" + trait_id, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.22), 0.0, true, true)
    var base := _add_cylinder_segments(badge, radius * 1.34, 0.010, 6, dark, Vector3(0, 0.082, 0), Vector3(0, 30, 0))
    base.name = "LiteEliteMatteFootprint"
    var pointer := _add_box(badge, Vector3(radius * 0.12, 0.010, radius * 0.72), accent, Vector3(0, 0.104, radius * 0.78))
    pointer.name = "LiteEliteTraitPointer"
    var pip := _add_cylinder_segments(badge, radius * 0.18, 0.014, 6, reward, Vector3(0, 0.122, -radius * 0.72), Vector3(0, 30, 0))
    pip.name = "LiteEliteRewardPip"

func _add_lite_enemy_body(model: Node3D, kind: String, radius: float, height: float, color: Color, mat_body: Material, mat_glow: Material, eye_mat: Material) -> void:
    match kind:
        "skitter":
            _add_sphere(model, radius * 0.76, mat_body, Vector3(0, height * 0.42, 0))
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(radius * 0.86, radius * 0.09, radius * 0.12), _mat(kind + "_lite_leg", color.darkened(0.32), 0.04, true), Vector3(side * radius * 0.82, height * 0.20, radius * 0.12), Vector3(0, 0, side * 22.0))
            _add_sphere(model, radius * 0.16, eye_mat, Vector3(0, height * 0.58, radius * 0.64))
        "spitter":
            _add_sphere(model, radius * 0.82, mat_body, Vector3(0, height * 0.42, 0))
            _add_sphere(model, radius * 0.32, _mat(kind + "_lite_acid_sac", Color(0.42, 1.0, 0.34), 0.80, true), Vector3(0, height * 0.66, -radius * 0.24))
            _add_cylinder_segments(model, radius * 0.48, 0.012, 3, mat_glow, Vector3(0, 0.058, radius * 0.54), Vector3(0, 30, 0))
        "burrower":
            _add_box(model, Vector3(radius * 2.10, height * 0.46, radius * 0.82), mat_body, Vector3(0, height * 0.34, 0), Vector3(0, 0, 0))
            _add_box(model, Vector3(radius * 0.20, 0.016, radius * 1.10), mat_glow, Vector3(0, 0.060, radius * 0.26))
        "carapace":
            _add_sphere(model, radius * 0.88, mat_body, Vector3(0, height * 0.42, 0))
            _add_box(model, Vector3(radius * 1.08, radius * 0.15, radius * 0.20), _mat(kind + "_lite_shell", color.darkened(0.24), 0.10, true), Vector3(0, height * 0.56, -radius * 0.12))
        "void_eye":
            _add_sphere(model, radius * 0.84, mat_body, Vector3(0, height * 0.52, 0))
            _add_sphere(model, radius * 0.34, _mat(kind + "_lite_eye", Color(1.0, 0.82, 1.0), 1.15, true), Vector3(0, height * 0.54, radius * 0.62))
            _add_sphere(model, radius * 0.12, _mat(kind + "_lite_pupil", Color(0.10, 0.02, 0.16), 0.2), Vector3(0, height * 0.54, radius * 0.88))
        "rift_crystal":
            _add_crystal(model, radius * 0.48, height * 0.90, color.lightened(0.08), Vector3(0, height * 0.40, 0), Vector3(0, 30, 0))
        _:
            _add_sphere(model, radius * 0.78, mat_body, Vector3(0, height * 0.42, 0))
            _add_sphere(model, radius * 0.14, eye_mat, Vector3(-radius * 0.24, height * 0.58, radius * 0.62))
            _add_sphere(model, radius * 0.14, eye_mat, Vector3(radius * 0.24, height * 0.58, radius * 0.62))

func _add_lite_enemy_readability_plate(model: Node3D, kind: String, radius: float, color: Color) -> void:
    var plate_color := Color(1.0, 0.10, 0.42, 0.22)
    if kind == "spitter":
        plate_color = Color(0.44, 1.0, 0.34, 0.20)
    elif kind == "void_eye":
        plate_color = Color(0.72, 0.34, 1.0, 0.22)
    elif kind == "rift_crystal":
        plate_color = Color(0.42, 0.78, 1.0, 0.22)
    elif kind == "carapace":
        plate_color = Color(0.82, 0.58, 1.0, 0.20)
    elif kind == "burrower":
        plate_color = Color(1.0, 0.24, 0.54, 0.22)
    var plate := _add_cylinder_segments(model, radius * 1.12, 0.014, 8, _mat("lite_enemy_readability_plate_" + kind, plate_color, 0.36, true, true), Vector3(0, 0.024, 0), Vector3(0, 22.5, 0))
    plate.name = "LiteEnemyReadabilityPlate"
    plate.set_meta("combat_visual_channel", "enemy_lite_readability")
    plate.set_meta("art_role", "lite_enemy_grounding_readability")
    plate.set_meta("lite_enemy_grounding", true)
    plate.set_meta("kind", kind)
    plate.set_meta("body_color", color.to_html(false))
    plate.set_meta("pickup_confusion_guard", true)
    plate.set_meta("collision_radius_readability", true)
    plate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    var pickup_gap := _add_cylinder_segments(model, radius * 1.36, 0.006, 8, _mat("lite_enemy_pickup_gap_" + kind, Color(0.0, 0.0, 0.0, 0.20), 0.0, true, true), Vector3(0, 0.036, 0), Vector3(0, 22.5, 0))
    pickup_gap.name = "EnemyGroundSilhouettePickupGap"
    pickup_gap.set_meta("combat_visual_channel", "enemy_lite_readability")
    pickup_gap.set_meta("material_grade", "low_glare_lite_enemy_pickup_gap")
    pickup_gap.set_meta("pickup_confusion_guard", true)
    pickup_gap.set_meta("collision_radius_marker", true)
    pickup_gap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    var facing := _add_box(model, Vector3(radius * 0.085, 0.006, radius * 0.56), _mat("lite_enemy_facing_notch_" + kind, Color(1.0, 0.10, 0.34, 0.16), 0.0, true, true), Vector3(0, 0.050, radius * 0.66))
    facing.name = "EnemyGroundSilhouetteFacingNotch"
    facing.set_meta("combat_visual_channel", "enemy_lite_readability")
    facing.set_meta("material_grade", "low_glare_lite_enemy_facing_notch")
    facing.set_meta("pickup_confusion_guard", true)
    facing.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _add_void_creature_polish(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite: bool) -> void:
    var glow := color.lightened(0.28)
    var shell := color.darkened(0.32)
    var core_mat := _mat(kind + "_void_core", Color(glow.r, glow.g, glow.b, 0.70), 1.05 if elite or boss else 0.72, true, true)
    var shell_mat := _mat(kind + "_void_shell_edge", shell, 0.12, true)
    var spike_count := 5 if boss else (4 if elite else 2)
    for i in range(spike_count):
        var t := -0.5 + float(i) / maxf(1.0, float(spike_count - 1))
        var side := -1.0 if i % 2 == 0 else 1.0
        var spike_pos := Vector3(side * radius * (0.48 + abs(t) * 0.38), height * (0.66 + abs(t) * 0.12), -radius * (0.18 + abs(t) * 0.42))
        _add_box(model, Vector3(radius * 0.14, radius * 0.18, radius * (0.54 if boss else 0.38)), shell_mat, spike_pos, Vector3(0, side * (28.0 + abs(t) * 16.0), side * 24.0))

    match kind:
        "spitter":
            _add_cylinder_segments(model, radius * 0.42, 0.026, 24, _mat(kind + "_acid_warning", Color(0.42, 1.0, 0.34, 0.42), 0.95, true, true), Vector3(0, height * 0.70, -radius * 0.28), Vector3(90, 0, 0))
        "void_eye", "boss_velkoz":
            for i in range(4 if boss else 2):
                var angle := TAU * float(i) / float(4 if boss else 2)
                _add_sphere(model, radius * 0.10, core_mat, Vector3(cos(angle) * radius * 0.62, height * 0.68, sin(angle) * radius * 0.62))
        "rift_crystal":
            _add_cylinder_segments(model, radius * 1.08, 0.025, 6, _mat(kind + "_rift_base", Color(glow.r, glow.g, glow.b, 0.36), 0.95, true, true), Vector3(0, 0.07, 0), Vector3(0, 30, 0))
        "burrower", "boss_reksai":
            _add_box(model, Vector3(radius * 0.26, radius * 0.18, radius * 1.45), core_mat, Vector3(0, height * 0.60, radius * 0.48), Vector3(0, 0, 0))
        _:
            _add_sphere(model, radius * 0.16, core_mat, Vector3(0, height * 0.64, radius * 0.70))

    _add_void_species_marker(model, kind, radius, height, color, boss, elite)
    _add_enemy_species_role_banner(model, kind, radius, height, color, boss, elite)
    if _enemy_should_show_weakpoint_core(kind, boss, elite):
        _add_enemy_weakpoint_core(model, kind, radius, height, color, boss, elite)

    if elite or boss:
        var crown_mat := _mat(kind + "_elite_crown", Color(1.0, 0.36, 0.92), 0.95, true)
        var crown_count := 6 if boss else 4
        for i in range(crown_count):
            var angle := TAU * float(i) / float(crown_count)
            var pos := Vector3(cos(angle) * radius * 0.58, height * (1.02 if boss else 0.88), sin(angle) * radius * 0.58)
            _add_box(model, Vector3(radius * 0.10, radius * 0.16, radius * 0.50), crown_mat, pos, Vector3(0, -rad_to_deg(angle), 24.0))
    if boss:
        _add_boss_signature(model, kind, radius, height, color)

func _add_void_creature_premium_body_rig(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite: bool) -> void:
    if model.get_node_or_null("VoidCreaturePremiumBodyRig") != null:
        return
    var family := _void_creature_premium_family(kind)
    var detail_name := _void_creature_premium_detail_name(kind)
    var light_boss_variant := boss and not elite and not kind.begins_with("boss_")
    var rig := Node3D.new()
    rig.name = "VoidCreaturePremiumBodyRig"
    rig.set_meta("kind", kind)
    rig.set_meta("body_family", family)
    rig.set_meta("detail_node", detail_name)
    rig.set_meta("boss", boss)
    rig.set_meta("elite", elite)
    rig.set_meta("light_boss_variant", light_boss_variant)
    rig.set_meta("material_grade", "void_premium_carapace")
    model.add_child(rig)

    var hot_color := _enemy_combat_color(kind, color)
    var shell := _mat(kind + "_premium_shell", Color(color.darkened(0.38).r, color.darkened(0.38).g, color.darkened(0.38).b, 0.78), 0.14, true, true)
    var edge := _mat(kind + "_premium_edge", Color(hot_color.r, hot_color.g, hot_color.b, 0.46 if boss or elite else 0.34), 0.92, true, true)
    var hot := _mat(kind + "_premium_hot", Color(hot_color.lightened(0.16).r, hot_color.lightened(0.16).g, hot_color.lightened(0.16).b, 0.68 if boss or elite else 0.52), 1.18, true, true)
    var gold := _mat(kind + "_premium_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42 if boss else 0.30), 0.80, true, true)
    var dark := _mat(kind + "_premium_dark", Color(0.014, 0.000, 0.030, 0.64), 0.08, true, true)

    var plating := Node3D.new()
    plating.name = "VoidCreaturePremiumCarapacePlating"
    plating.set_meta("body_family", family)
    rig.add_child(plating)
    var plate_count := 1 if light_boss_variant else (3 if boss or elite else 2)
    for i in range(plate_count):
        var t := -0.5 + float(i) / maxf(1.0, float(plate_count - 1))
        var y: float = height * (0.50 + abs(t) * 0.24)
        var z: float = -radius * (0.14 + abs(t) * 0.22)
        var width: float = radius * (1.18 - abs(t) * 0.28)
        var plate := _add_box(plating, Vector3(width, radius * 0.080, radius * 0.22), shell, Vector3(0, y, z), Vector3(0, 0, t * 18.0))
        plate.name = "VoidCreaturePremiumCarapacePlate%d" % i
        if (boss or elite) and not light_boss_variant:
            _add_box(plating, Vector3(width * 0.58, radius * 0.042, radius * 0.080), edge, Vector3(0, y + radius * 0.048, z + radius * 0.12), Vector3(0, 0, t * 12.0))

    var core := Node3D.new()
    core.name = "VoidCreaturePremiumGlowCore"
    core.set_meta("body_family", family)
    rig.add_child(core)
    var core_y := height * (0.68 if boss else 0.60)
    var core_z := radius * (0.72 if boss else 0.62)
    if not light_boss_variant:
        _add_cylinder_segments(core, radius * (0.42 if boss else 0.30), 0.016, 6 if family == "summoner_crystal" or family == "focus_eye" else 5, edge, Vector3(0, core_y, core_z), Vector3(90, 0, 30))
    var glow_core := _add_sphere(core, radius * (0.16 if boss else 0.11), hot, Vector3(0, core_y + radius * 0.020, core_z + radius * 0.040))
    glow_core.name = "VoidCreaturePremiumCoreLens"

    if not light_boss_variant:
        var bands := Node3D.new()
        bands.name = "VoidCreaturePremiumMaterialBands"
        bands.set_meta("material_grade", "void_premium_carapace")
        rig.add_child(bands)
        for band in range(1):
            var band_y := height * (0.32 + float(band) * 0.16)
            var band_radius := radius * (0.90 - float(band) * 0.08)
            var band_mat := edge if band != 1 else gold
            var band_node := _add_cylinder_segments(bands, band_radius, 0.010, 8 if boss else 6, band_mat, Vector3(0, band_y, 0), Vector3(0, 22.5 if boss else 30.0, 0))
            band_node.name = "VoidCreaturePremiumMaterialBand%d" % band

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("kind", kind)
    detail.set_meta("body_family", family)
    rig.add_child(detail)
    if light_boss_variant:
        _add_box(detail, Vector3(radius * 0.92, radius * 0.052, radius * 0.18), hot, Vector3(0, height * 0.70, radius * 0.58))
        return

    match family:
        "swarm":
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(detail, radius * 0.080, radius * 0.014, radius * 0.62, 6, hot, Vector3(side * radius * 0.32, height * 0.72, radius * 0.72), Vector3(62, 0, side * 20.0))
            _add_box(detail, Vector3(radius * 0.76, radius * 0.050, radius * 0.12), dark, Vector3(0, height * 0.66, radius * 0.76))
        "pounce":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.16, radius * 0.060, radius * 0.98), hot, Vector3(side * radius * 0.82, height * 0.44, radius * 0.30), Vector3(0, side * 18.0, side * 36.0))
                _add_tapered_cylinder(detail, radius * 0.070, radius * 0.010, radius * 0.52, 6, gold, Vector3(side * radius * 1.02, height * 0.36, radius * 0.68), Vector3(68, 0, side * 22.0))
        "acid_sac":
            _add_cylinder_segments(detail, radius * 0.48, 0.018, 24, hot, Vector3(0, height * 0.76, -radius * 0.28), Vector3(90, 0, 0))
            for drop in range(4):
                var angle := TAU * float(drop) / 4.0
                _add_sphere(detail, radius * 0.070, hot, Vector3(cos(angle) * radius * 0.34, height * 0.80, -radius * 0.28 + sin(angle) * radius * 0.18))
        "burrow_spine":
            _add_box(detail, Vector3(radius * 0.20, radius * 0.080, radius * 1.62), hot, Vector3(0, height * 0.68, radius * 0.20))
            for tooth in range(4):
                var offset := -0.45 + float(tooth) * 0.30
                _add_tapered_cylinder(detail, radius * 0.095, radius * 0.014, radius * 0.58, 6, gold, Vector3(offset * radius, height * 0.74, radius * (0.36 + float(tooth) * 0.18)), Vector3(68, 0, offset * 18.0))
        "armor":
            for row in range(4):
                _add_box(detail, Vector3(radius * (1.22 - float(row) * 0.16), radius * 0.070, radius * 0.18), shell if row % 2 == 0 else edge, Vector3(0, height * (0.46 + float(row) * 0.10), radius * (-0.18 + float(row) * 0.08)), Vector3(0, 0, -10.0 + float(row) * 7.0))
            _add_cylinder_segments(detail, radius * 0.52, 0.012, 8, hot, Vector3(0, height * 0.68, radius * 0.34), Vector3(90, 0, 22.5))
        "focus_eye":
            _add_cylinder_segments(detail, radius * 0.64, 0.018, 32, hot, Vector3(0, height * 0.66, radius * 0.72), Vector3(90, 0, 0))
            _add_box(detail, Vector3(radius * 1.34, radius * 0.040, radius * 0.10), gold, Vector3(0, height * 0.66, radius * 0.92))
            for lash in range(4 if boss else 2):
                var angle := TAU * float(lash) / float(4 if boss else 2)
                _add_box(detail, Vector3(radius * 0.070, radius * 0.046, radius * 0.66), edge, Vector3(cos(angle) * radius * 0.64, height * 0.58, sin(angle) * radius * 0.32), Vector3(20, -rad_to_deg(angle), 0))
        "summoner_crystal":
            _add_crystal(detail, radius * 0.24, height * 0.46, hot_color, Vector3(0, height * 0.76, 0), Vector3(0, 30, 0))
            for spoke in range(6):
                var angle := TAU * float(spoke) / 6.0
                _add_box(detail, Vector3(radius * 0.060, radius * 0.040, radius * 0.60), edge, Vector3(cos(angle) * radius * 0.44, height * 0.58, sin(angle) * radius * 0.44), Vector3(0, -rad_to_deg(angle), 0))
        "devour_boss":
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(detail, radius * 0.130, radius * 0.020, radius * 0.90, 8, gold, Vector3(side * radius * 0.38, height * 1.04, radius * 0.62), Vector3(58, 0, side * 26.0))
                _add_box(detail, Vector3(radius * 0.18, radius * 0.080, radius * 0.92), hot, Vector3(side * radius * 0.62, height * 0.88, radius * 0.20), Vector3(0, side * 20.0, side * 24.0))
            _add_cylinder_segments(detail, radius * 0.82, 0.016, 8, edge, Vector3(0, height * 0.88, radius * 0.44), Vector3(90, 0, 22.5))
        "royal_wing":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.18, radius * 0.060, radius * 1.82), hot, Vector3(side * radius * 0.92, height * 0.76, -radius * 0.02), Vector3(0, side * 18.0, side * 44.0))
                _add_box(detail, Vector3(radius * 0.11, radius * 0.045, radius * 1.20), gold, Vector3(side * radius * 1.24, height * 0.72, -radius * 0.22), Vector3(0, side * -16.0, side * 38.0))
            _add_cylinder_segments(detail, radius * 0.60, 0.014, 5, edge, Vector3(0, height * 0.72, radius * 0.32), Vector3(90, 0, 18))
        _:
            _add_box(detail, Vector3(radius * 0.80, radius * 0.050, radius * 0.14), hot, Vector3(0, height * 0.68, radius * 0.46))

func _sync_void_creature_premium_body_rig(model: Node3D, kind: String, boss: bool, elite: bool, id: int, visual_radius: float) -> void:
    var rig := model.get_node_or_null("VoidCreaturePremiumBodyRig") as Node3D
    if rig == null:
        return
    var family := str(rig.get_meta("body_family", "swarm"))
    var time := Time.get_ticks_msec() / 1000.0
    var pulse_speed := 1.9 if boss or elite else 1.35
    match family:
        "focus_eye", "summoner_crystal":
            pulse_speed += 0.55
        "pounce", "burrow_spine":
            pulse_speed += 0.35
        _:
            pass
    var pulse := 1.0 + sin(time * pulse_speed + float(id % 31)) * (0.030 if boss or elite else 0.018)
    rig.scale = Vector3.ONE * pulse
    var core := rig.get_node_or_null("VoidCreaturePremiumGlowCore") as Node3D
    if core != null:
        core.rotation.y += -0.018 if family == "focus_eye" or family == "summoner_crystal" else 0.012
        core.position.y = sin(time * (pulse_speed + 0.8) + float(id % 13)) * visual_radius * 0.012
    var bands := rig.get_node_or_null("VoidCreaturePremiumMaterialBands") as Node3D
    if bands != null:
        bands.rotation.y += 0.008 if boss or elite else 0.004
    var detail := rig.get_node_or_null(str(rig.get_meta("detail_node", ""))) as Node3D
    if detail != null:
        detail.position.y = sin(time * (pulse_speed + 1.2) + float(id % 17)) * visual_radius * 0.016
        if family == "focus_eye" or family == "summoner_crystal" or family == "royal_wing":
            detail.rotation.y += -0.010 if boss else -0.006
        else:
            detail.rotation.y += 0.010 if boss or elite else 0.005

func _add_void_creature_painterly_depth_rig(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite: bool) -> void:
    if model.get_node_or_null("VoidCreaturePainterlyDepthRig") != null:
        return
    var family := _void_creature_premium_family(kind)
    var detail_name := _void_creature_painterly_depth_detail_name(kind)
    var rig := Node3D.new()
    rig.name = "VoidCreaturePainterlyDepthRig"
    rig.set_meta("kind", kind)
    rig.set_meta("body_family", family)
    rig.set_meta("detail_node", detail_name)
    rig.set_meta("boss", boss)
    rig.set_meta("elite", elite)
    rig.set_meta("material_grade", "void_painted_depth_low_glare")
    rig.set_meta("combat_visual_channel", "enemy_model_depth")
    model.add_child(rig)

    var combat_color := _enemy_combat_color(kind, color)
    var shadow_mat := _mat(kind + "_void_painterly_shadow", Color(0.004, 0.000, 0.016, 0.34 if boss or elite else 0.26), 0.0, true, true)
    var shell_mat := _mat(kind + "_void_painterly_shell_step", Color(color.darkened(0.46).r, color.darkened(0.46).g, color.darkened(0.46).b, 0.36), 0.06, true, true)
    var rim_mat := _mat(kind + "_void_painterly_rim", Color(combat_color.r, combat_color.g, combat_color.b, 0.24 if boss or elite else 0.18), 0.34, true, true)
    var hot_mat := _mat(kind + "_void_painterly_value_hot", Color(combat_color.lightened(0.12).r, combat_color.lightened(0.12).g, combat_color.lightened(0.12).b, 0.30), 0.42, true, true)

    var occlusion := Node3D.new()
    occlusion.name = "VoidCreatureAmbientOcclusionPlate"
    rig.add_child(occlusion)
    _add_cylinder_segments(occlusion, radius * (1.18 if boss else 1.04), 0.008, 8, shadow_mat, Vector3(0, 0.072, -radius * 0.06), Vector3(0, 22.5, 0))
    _add_box(occlusion, Vector3(radius * 0.82, 0.010, radius * 0.20), shadow_mat, Vector3(0, height * 0.52, -radius * 0.36))

    var rim := Node3D.new()
    rim.name = "VoidCreatureCarapaceRimStroke"
    rim.set_meta("body_family", family)
    rig.add_child(rim)
    for side in [-1.0, 1.0]:
        _add_box(rim, Vector3(radius * 0.10, radius * 0.028, radius * (1.00 if boss else 0.70)), rim_mat, Vector3(side * radius * 0.52, height * 0.58, radius * 0.30), Vector3(0, side * 16.0, side * 22.0))
    _add_box(rim, Vector3(radius * 0.84, radius * 0.024, radius * 0.10), shell_mat, Vector3(0, height * 0.73, radius * 0.26))

    var steps := Node3D.new()
    steps.name = "VoidCreatureValueShardSteps"
    steps.set_meta("material_grade", "void_painted_depth_low_glare")
    rig.add_child(steps)
    var shard_count := 4 if boss or elite else 3
    for shard in range(shard_count):
        var t := -0.5 + float(shard) / maxf(1.0, float(shard_count - 1))
        var shard_mat := hot_mat if shard % 2 == 0 else rim_mat
        var shard_node := _add_box(steps, Vector3(radius * 0.14, radius * 0.018, radius * 0.22), shard_mat, Vector3(t * radius * 0.72, height * (0.42 + abs(t) * 0.22), radius * 0.62), Vector3(0, t * 22.0, t * 18.0))
        shard_node.name = "VoidCreatureValueShard%d" % shard

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("kind", kind)
    detail.set_meta("body_family", family)
    detail.set_meta("material_grade", "void_painted_depth_low_glare")
    rig.add_child(detail)
    match family:
        "pounce":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.12, radius * 0.018, radius * 0.88), hot_mat, Vector3(side * radius * 0.82, height * 0.38, radius * 0.58), Vector3(0, side * 22.0, side * 34.0))
        "acid_sac":
            _add_cylinder_segments(detail, radius * 0.42, 0.010, 18, hot_mat, Vector3(0, height * 0.74, -radius * 0.28), Vector3(90, 0, 0))
            _add_sphere(detail, radius * 0.055, rim_mat, Vector3(0, height * 0.84, -radius * 0.08))
        "burrow_spine":
            _add_box(detail, Vector3(radius * 0.16, radius * 0.020, radius * 1.36), hot_mat, Vector3(0, height * 0.64, radius * 0.42))
            _add_box(detail, Vector3(radius * 1.10, radius * 0.014, radius * 0.12), shell_mat, Vector3(0, height * 0.44, radius * 0.76))
        "armor":
            for row in range(3):
                _add_box(detail, Vector3(radius * (1.04 - float(row) * 0.16), radius * 0.018, radius * 0.14), shell_mat if row % 2 == 0 else rim_mat, Vector3(0, height * (0.48 + float(row) * 0.10), radius * (0.18 + float(row) * 0.08)), Vector3(0, 0, -8.0 + float(row) * 8.0))
        "focus_eye":
            _add_cylinder_segments(detail, radius * 0.52, 0.010, 24, hot_mat, Vector3(0, height * 0.66, radius * 0.74), Vector3(90, 0, 0))
            _add_box(detail, Vector3(radius * 1.02, radius * 0.014, radius * 0.08), rim_mat, Vector3(0, height * 0.66, radius * 0.92))
        "summoner_crystal":
            _add_crystal(detail, radius * 0.18, height * 0.34, combat_color, Vector3(0, height * 0.76, 0), Vector3(0, 30, 0), kind + "_void_painterly_crystal")
            _add_cylinder_segments(detail, radius * 0.52, 0.008, 6, rim_mat, Vector3(0, height * 0.56, 0), Vector3(0, 30, 0))
        "devour_boss":
            _add_cylinder_segments(detail, radius * 0.72, 0.010, 8, hot_mat, Vector3(0, height * 0.92, radius * 0.46), Vector3(90, 0, 22.5))
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(detail, radius * 0.10, radius * 0.016, radius * 0.72, 6, rim_mat, Vector3(side * radius * 0.44, height * 1.06, radius * 0.64), Vector3(58, 0, side * 22.0))
        "royal_wing":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.11, radius * 0.016, radius * 1.44), hot_mat, Vector3(side * radius * 1.02, height * 0.76, -radius * 0.05), Vector3(0, side * 18.0, side * 42.0))
            _add_cylinder_segments(detail, radius * 0.50, 0.008, 5, rim_mat, Vector3(0, height * 0.72, radius * 0.32), Vector3(90, 0, 18))
        _:
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(detail, radius * 0.070, radius * 0.012, radius * 0.46, 6, hot_mat, Vector3(side * radius * 0.28, height * 0.70, radius * 0.70), Vector3(62, 0, side * 18.0))

func _void_creature_painterly_depth_detail_name(kind: String) -> String:
    match _void_creature_premium_family(kind):
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

func _void_creature_premium_family(kind: String) -> String:
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

func _void_creature_premium_detail_name(kind: String) -> String:
    match _void_creature_premium_family(kind):
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

func _enemy_should_show_weakpoint_core(kind: String, boss: bool, elite: bool) -> bool:
    if boss or elite:
        return true
    return kind == "spitter" or kind == "burrower" or kind == "void_eye" or kind == "rift_crystal"

func _enemy_readability_family(kind: String) -> String:
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

func _enemy_readability_detail_name(kind: String) -> String:
    match _enemy_readability_family(kind):
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

func _enemy_combat_family(kind: String) -> String:
    match kind:
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
        "voidling":
            return "swarm"
        _:
            return "generic"

func _enemy_combat_detail_node_name(family: String) -> String:
    match family:
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

func _enemy_combat_color(kind: String, fallback: Color) -> Color:
    match _enemy_combat_family(kind):
        "swarm":
            return Color(0.92, 0.22, 1.0)
        "pounce":
            return Color(1.0, 0.30, 0.64)
        "acid":
            return Color(0.54, 1.0, 0.28)
        "burrow":
            return Color(1.0, 0.52, 0.18)
        "armor", "devour":
            return Color(0.76, 0.48, 1.0)
        "focus":
            return Color(1.0, 0.34, 1.0)
        "summon":
            return Color(0.34, 0.88, 1.0)
        "wing_swarm":
            return Color(0.92, 0.36, 1.0)
        _:
            return fallback.lightened(0.20)

func _add_enemy_combat_intent_profile(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite: bool) -> void:
    if model.get_node_or_null("EnemyCombatIntentProfile") != null:
        return
    var family := _enemy_combat_family(kind)
    var detail_name := _enemy_combat_detail_node_name(family)
    var intent_color := _enemy_combat_color(kind, color)
    var root := Node3D.new()
    root.name = "EnemyCombatIntentProfile"
    root.set_meta("kind", kind)
    root.set_meta("boss", boss)
    root.set_meta("elite", elite)
    root.set_meta("combat_family", family)
    root.set_meta("detail_node", detail_name)
    model.add_child(root)

    var alpha := 0.30 if not boss and not elite else 0.42
    var soft := _mat(kind + "_combat_intent_soft", Color(intent_color.r, intent_color.g, intent_color.b, alpha), 0.94, true, true)
    var hot := _mat(kind + "_combat_intent_hot", Color(intent_color.lightened(0.16).r, intent_color.lightened(0.16).g, intent_color.lightened(0.16).b, 0.58 if boss or elite else 0.44), 1.16, true, true)
    var gold := _mat(kind + "_combat_intent_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.40 if boss or elite else 0.30), 0.80, true, true)
    var dark := _mat(kind + "_combat_intent_dark", Color(0.018, 0.004, 0.038, 0.48), 0.08, true, true)
    var y := 0.128
    var front_z := radius * (1.24 if boss else 0.88)
    var frame_radius := radius * (1.12 if boss else (0.92 if elite else 0.74))

    var frame := _add_cylinder_segments(root, frame_radius, 0.012, 6 if family == "summon" or family == "focus" else 4, soft, Vector3(0, y, front_z), Vector3(0, 30, 0))
    frame.name = "EnemyCombatIntentFrame"
    var core := _add_sphere(root, radius * (0.105 if boss else 0.078), hot, Vector3(0, y + radius * 0.070, front_z))
    core.name = "EnemyCombatIntentCore"
    var meter := _add_box(root, Vector3(frame_radius * 0.88, 0.012, radius * 0.080), gold, Vector3(0, y + 0.030, front_z - radius * 0.62))
    meter.name = "EnemyCombatIntentMeter"

    var detail := Node3D.new()
    detail.name = detail_name
    root.add_child(detail)
    match family:
        "swarm":
            for tooth in range(3):
                var offset := -0.32 + float(tooth) * 0.32
                _add_tapered_cylinder(detail, radius * 0.070, radius * 0.012, radius * 0.44, 6, hot, Vector3(offset * radius, y + radius * 0.110, front_z + radius * 0.20), Vector3(66, 0, offset * 20.0))
            _add_box(detail, Vector3(radius * 0.86, 0.012, radius * 0.070), dark, Vector3(0, y + radius * 0.086, front_z + radius * 0.04))
        "pounce":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.090, 0.014, radius * 1.06), hot, Vector3(side * radius * 0.24, y + radius * 0.085, front_z + radius * 0.12), Vector3(0, side * 24.0, side * 28.0))
                _add_box(detail, Vector3(radius * 0.070, 0.012, radius * 0.70), gold, Vector3(side * radius * 0.48, y + radius * 0.104, front_z - radius * 0.16), Vector3(0, side * -18.0, side * 18.0))
        "acid":
            _add_cylinder_segments(detail, radius * 0.56, 0.012, 3, hot, Vector3(0, y + radius * 0.086, front_z + radius * 0.12), Vector3(0, 30, 0))
            for drop in range(4):
                var angle := TAU * float(drop) / 4.0
                _add_sphere(detail, radius * 0.070, hot if drop % 2 == 0 else soft, Vector3(cos(angle) * radius * 0.38, y + radius * 0.112, front_z + sin(angle) * radius * 0.26 + radius * 0.12))
        "burrow":
            _add_box(detail, Vector3(radius * 0.22, 0.014, radius * 1.62), hot, Vector3(0, y + radius * 0.082, front_z + radius * 0.20))
            for tooth in range(4):
                var offset := -0.45 + float(tooth) * 0.30
                _add_tapered_cylinder(detail, radius * 0.082, radius * 0.014, radius * 0.50, 6, gold, Vector3(offset * radius, y + radius * 0.116, front_z + radius * (0.02 + float(tooth) * 0.20)), Vector3(70, 0, offset * 18.0))
        "armor":
            _add_cylinder_segments(detail, radius * 0.62, 0.014, 6, dark, Vector3(0, y + radius * 0.080, front_z), Vector3(0, 30, 0))
            for plate in range(3):
                _add_box(detail, Vector3(radius * (0.92 - float(plate) * 0.14), 0.014, radius * 0.100), hot, Vector3(0, y + radius * (0.106 + float(plate) * 0.028), front_z + radius * (-0.26 + float(plate) * 0.24)), Vector3(0, 0, -8.0 + float(plate) * 8.0))
        "focus":
            _add_cylinder_segments(detail, radius * 0.58, 0.014, 24, hot, Vector3(0, y + radius * 0.084, front_z), Vector3(90, 0, 0))
            _add_box(detail, Vector3(radius * 1.22, 0.012, radius * 0.068), gold, Vector3(0, y + radius * 0.112, front_z))
            _add_sphere(detail, radius * 0.082, dark, Vector3(0, y + radius * 0.132, front_z + radius * 0.045))
        "summon":
            _add_crystal(detail, radius * 0.145, radius * 0.48, intent_color, Vector3(0, y + radius * 0.145, front_z), Vector3(0, 30, 0))
            for pip in range(6):
                var angle := TAU * float(pip) / 6.0
                _add_sphere(detail, radius * 0.050, hot, Vector3(cos(angle) * radius * 0.52, y + radius * 0.104, front_z + sin(angle) * radius * 0.44))
        "devour":
            _add_cylinder_segments(detail, radius * 0.70, 0.014, 8, hot, Vector3(0, y + radius * 0.084, front_z + radius * 0.16), Vector3(0, 22.5, 0))
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(detail, radius * 0.100, radius * 0.016, radius * 0.70, 8, gold, Vector3(side * radius * 0.34, y + radius * 0.122, front_z + radius * 0.42), Vector3(64, 0, side * 24.0))
            _add_box(detail, Vector3(radius * 1.10, 0.012, radius * 0.080), dark, Vector3(0, y + radius * 0.106, front_z + radius * 0.16))
        "wing_swarm":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.110, 0.014, radius * 1.20), hot, Vector3(side * radius * 0.48, y + radius * 0.092, front_z), Vector3(0, side * 18.0, side * 42.0))
                _add_sphere(detail, radius * 0.055, gold, Vector3(side * radius * 0.78, y + radius * 0.124, front_z + radius * 0.34))
            _add_cylinder_segments(detail, radius * 0.46, 0.012, 5, soft, Vector3(0, y + radius * 0.080, front_z), Vector3(0, 18, 0))
        _:
            _add_box(detail, Vector3(radius * 0.88, 0.014, radius * 0.086), hot, Vector3(0, y + radius * 0.090, front_z), Vector3(0, 30, 0))
            _add_box(detail, Vector3(radius * 0.086, 0.014, radius * 0.88), hot, Vector3(0, y + radius * 0.092, front_z), Vector3(0, 30, 0))

func _sync_enemy_combat_intent_profile(model: Node3D, enemy: Node, kind: String, boss: bool, elite: bool, id: int, visual_radius: float) -> void:
    var profile := model.get_node_or_null("EnemyCombatIntentProfile") as Node3D
    if profile == null:
        return
    var family := str(profile.get_meta("combat_family", "generic"))
    var time := Time.get_ticks_msec() / 1000.0
    var attack_timer := maxf(0.0, float(enemy.get("attack_timer")))
    var dash_timer := maxf(0.0, float(enemy.get("dash_timer")))
    var summon_timer := maxf(0.0, float(enemy.get("summon_timer")))
    var readiness := 0.0
    match family:
        "pounce", "burrow":
            readiness = clampf(dash_timer / (3.0 if boss else 0.70), 0.0, 1.0)
            if readiness <= 0.01:
                readiness = 1.0 - clampf(attack_timer / (0.70 if boss else 0.52), 0.0, 1.0)
        "summon", "wing_swarm":
            readiness = 1.0 - clampf(summon_timer / (1.85 if boss else 1.35), 0.0, 1.0)
        _:
            readiness = 1.0 - clampf(attack_timer / (0.68 if boss else 0.52), 0.0, 1.0)
    readiness = clampf(readiness, 0.0, 1.0)
    var pulse_speed := 2.4 if boss or elite else 1.8
    var pulse := 1.0 + sin(time * pulse_speed + float(id % 23)) * (0.030 if boss or elite else 0.020) + readiness * 0.050
    profile.scale = Vector3(1.0 + (pulse - 1.0) * 0.55, 1.0, pulse)
    profile.rotation.y += 0.014 if boss or elite else 0.008
    profile.position.y = sin(time * 2.2 + float(id % 17)) * visual_radius * 0.010
    var frame := profile.get_node_or_null("EnemyCombatIntentFrame") as Node3D
    if frame != null:
        frame.rotation.y += 0.030 if family == "focus" or family == "summon" else -0.020
    var meter := profile.get_node_or_null("EnemyCombatIntentMeter") as Node3D
    if meter != null:
        meter.scale.x = lerpf(0.28, 1.0, readiness)
        meter.visible = readiness > 0.04
    var detail_name := str(profile.get_meta("detail_node", ""))
    var detail := profile.get_node_or_null(detail_name) as Node3D
    if detail != null:
        detail.position.y = sin(time * (3.2 if family == "pounce" or family == "acid" else 2.4) + float(id % 19)) * visual_radius * 0.014

func _sync_enemy_readability_plate(plate: Node3D, elite: bool, id: int) -> void:
    var plate_time := Time.get_ticks_msec() / 1000.0
    var family := str(plate.get_meta("readability_family", ""))
    plate.rotation.y += 0.010 if elite else 0.006
    var plate_pulse := 1.0 + sin(plate_time * (1.9 if elite else 1.4) + float(id % 19)) * (0.032 if elite else 0.020)
    plate.scale = Vector3.ONE * plate_pulse
    var detail_name := str(plate.get_meta("detail_node", ""))
    var detail := plate.get_node_or_null(detail_name) as Node3D
    if detail == null:
        return
    var detail_pulse := 1.0 + sin(plate_time * (3.4 if family == "pounce" or family == "acid" else 2.6) + float(id % 13)) * (0.045 if elite else 0.030)
    detail.scale = Vector3.ONE * detail_pulse
    detail.position.y = float(detail.get_meta("base_y", detail.position.y)) + sin(plate_time * 4.2 + float(id % 17)) * (0.008 if elite else 0.005)
    if family == "focus" or family == "summon":
        detail.rotation.y += 0.018 if elite else 0.012
    elif family == "burrow" or family == "pounce":
        detail.rotation.y -= 0.014 if elite else 0.009

func _sync_enemy_damage_state_rig(model: Node3D, enemy: Node, kind: String, boss: bool, elite: bool, id: int, visual_radius: float) -> void:
    var rig := model.get_node_or_null("EnemyDamageStateRig") as Node3D
    if rig == null:
        return
    var health_max := maxf(1.0, float(enemy.get("max_health")))
    var health_ratio := clampf(float(enemy.get("health")) / health_max, 0.0, 1.0)
    var threshold := float(rig.get_meta("damage_state_threshold", ENEMY_DAMAGE_STATE_THRESHOLD))
    var hurt_flash := clampf(float(enemy.get("hurt_flash")), 0.0, 1.0)
    var pressure := clampf((threshold - health_ratio) / maxf(0.01, threshold), 0.0, 1.0)
    pressure = maxf(pressure, hurt_flash * 0.62)
    rig.visible = health_ratio < threshold or hurt_flash > 0.02
    rig.set_meta("health_ratio", health_ratio)
    rig.set_meta("damage_pressure", pressure)
    rig.set_meta("visible_damage_state", rig.visible)
    if not rig.visible:
        return

    var time := Time.get_ticks_msec() / 1000.0
    var pulse := 1.0 + sin(time * (2.0 if boss or elite else 1.45) + float(id % 29)) * (0.018 if boss or elite else 0.012) + pressure * 0.035
    rig.scale = Vector3(pulse, 1.0, pulse)
    rig.rotation.y += 0.007 if boss or elite else 0.004
    rig.position.y = sin(time * 2.4 + float(id % 17)) * visual_radius * 0.010

    var band := rig.get_node_or_null("EnemyDamageCrackBand") as Node3D
    if band != null:
        band.visible = pressure > 0.03
        band.scale = Vector3(lerpf(0.42, 1.10, pressure), 1.0, lerpf(0.82, 1.05, pressure))
    var wound_core := rig.get_node_or_null("EnemyDamageWoundCore") as Node3D
    if wound_core != null:
        wound_core.visible = pressure > 0.20 or hurt_flash > 0.02
        wound_core.scale = Vector3.ONE * lerpf(0.74, 1.18, pressure)
    var chips := rig.get_node_or_null("EnemyDamageArmorChips") as Node3D
    if chips != null:
        for child in chips.get_children():
            var chip := child as Node3D
            if chip == null:
                continue
            chip.visible = pressure >= float(chip.get_meta("pressure_threshold", 0.25))
    var pips := rig.get_node_or_null("EnemyDamagePhasePips") as Node3D
    if pips != null:
        var lit_count := clampi(ceili(pressure * 3.0), 0, 3)
        if boss or elite:
            lit_count = maxi(1, lit_count)
        pips.set_meta("lit_phase_count", lit_count)
        for child in pips.get_children():
            var pip := child as Node3D
            if pip == null:
                continue
            var index := int(pip.get_meta("phase_index", 0))
            pip.visible = index < lit_count
            if pip.visible:
                pip.scale = Vector3.ONE * lerpf(0.82, 1.16, pressure)

func _add_enemy_damage_state_rig(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite: bool) -> void:
    if model.get_node_or_null("EnemyDamageStateRig") != null:
        return
    var rig := Node3D.new()
    rig.name = "EnemyDamageStateRig"
    rig.visible = false
    rig.set_meta("kind", kind)
    rig.set_meta("boss", boss)
    rig.set_meta("elite", elite)
    rig.set_meta("combat_visual_channel", "enemy_damage_state")
    rig.set_meta("material_grade", "low_glare_matte_damage")
    rig.set_meta("stateful_health_readability", true)
    rig.set_meta("damage_state_threshold", 0.86 if boss or elite else ENEMY_DAMAGE_STATE_THRESHOLD)
    rig.set_meta("damage_pressure", 0.0)
    model.add_child(rig)

    var role_color := _enemy_combat_color(kind, color).darkened(0.08)
    var dark_mat := _mat(kind + "_damage_state_matte_shadow", Color(0.014, 0.006, 0.024, 0.38 if boss or elite else 0.30), 0.0, true, true)
    var crack_mat := _mat(kind + "_damage_state_crack_matte", Color(DANGER_RED.r, DANGER_RED.g * 0.72, DANGER_RED.b, 0.30 if boss or elite else 0.22), 0.0, true, true)
    var role_mat := _mat(kind + "_damage_state_role_matte", Color(role_color.r, role_color.g, role_color.b, 0.28 if boss or elite else 0.20), 0.0, true, true)
    var trim_mat := _mat(kind + "_damage_state_trim_matte", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.26 if boss or elite else 0.18), 0.0, true, true)

    var band := Node3D.new()
    band.name = "EnemyDamageCrackBand"
    rig.add_child(band)
    _add_box(band, Vector3(radius * 0.92, 0.012, radius * 0.085), dark_mat, Vector3(0, height * 0.66, radius * 0.74), Vector3(0, 18, 0))
    _add_box(band, Vector3(radius * 0.58, 0.014, radius * 0.060), crack_mat, Vector3(-radius * 0.10, height * 0.69, radius * 0.82), Vector3(0, -18, 0))
    _add_box(band, Vector3(radius * 0.44, 0.012, radius * 0.050), role_mat, Vector3(radius * 0.22, height * 0.71, radius * 0.70), Vector3(0, 32, 0))
    band.visible = false

    var wound_core := _add_cylinder_segments(rig, radius * (0.32 if boss or elite else 0.24), 0.012, 6, role_mat, Vector3(0, height * 0.76, radius * 0.92), Vector3(90, 0, 30))
    wound_core.name = "EnemyDamageWoundCore"
    wound_core.visible = false

    var chips := Node3D.new()
    chips.name = "EnemyDamageArmorChips"
    rig.add_child(chips)
    for i in range(3):
        var chip_angle := -0.38 + float(i) * 0.38
        var chip := _add_box(chips, Vector3(radius * (0.18 + float(i) * 0.035), 0.012, radius * 0.070), trim_mat if i == 1 else dark_mat, Vector3(sin(chip_angle) * radius * 0.52, height * (0.58 + float(i) * 0.035), radius * (0.56 + float(i) * 0.10)), Vector3(0, rad_to_deg(chip_angle) * 0.60, 0))
        chip.name = "EnemyDamageArmorChip%d" % i
        chip.visible = false
        chip.set_meta("pressure_threshold", 0.22 + float(i) * 0.22)

    var pips := Node3D.new()
    pips.name = "EnemyDamagePhasePips"
    pips.set_meta("lit_phase_count", 0)
    rig.add_child(pips)
    for i in range(3):
        var pip_x := (-0.30 + float(i) * 0.30) * radius
        var pip := _add_box(pips, Vector3(radius * 0.13, 0.012, radius * 0.10), crack_mat if i == 2 else role_mat, Vector3(pip_x, height * 0.54, radius * 1.02), Vector3(0, -12.0 + float(i) * 12.0, 0))
        pip.name = "EnemyDamagePhasePip%d" % i
        pip.visible = false
        pip.set_meta("phase_index", i)

func _add_enemy_weakpoint_core(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite: bool) -> void:
    var core := Node3D.new()
    core.name = "EnemyWeakpointCore"
    core.set_meta("kind", kind)
    core.set_meta("boss", boss)
    core.set_meta("elite", elite)
    core.position = Vector3(0, height * (0.76 if boss else (0.66 if elite else 0.62)), radius * (0.84 if boss else 0.72))
    core.set_meta("base_y", core.position.y)
    model.add_child(core)

    var role_color := color.lightened(0.26)
    match kind:
        "spitter":
            role_color = Color(0.54, 1.0, 0.28)
        "burrower", "boss_reksai":
            role_color = Color(1.0, 0.52, 0.18)
        "carapace", "boss_cho":
            role_color = Color(0.76, 0.48, 1.0)
        "void_eye", "boss_velkoz":
            role_color = Color(1.0, 0.34, 1.0)
        "rift_crystal":
            role_color = Color(0.34, 0.88, 1.0)
        "boss_belveth":
            role_color = Color(0.92, 0.36, 1.0)
        _:
            pass

    var alpha := 0.72 if boss or elite else 0.52
    var hot := _mat(kind + "_weakpoint_hot", Color(role_color.lightened(0.12).r, role_color.lightened(0.12).g, role_color.lightened(0.12).b, alpha), 1.22 if boss or elite else 1.04, true, true)
    var soft := _mat(kind + "_weakpoint_soft", Color(role_color.r, role_color.g, role_color.b, 0.34 if boss or elite else 0.24), 0.92, true, true)
    var dark := _mat(kind + "_weakpoint_dark", Color(0.018, 0.006, 0.035, 0.54), 0.08, true, true)
    var gold := _mat(kind + "_weakpoint_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42 if boss or elite else 0.30), 0.74, true, true)
    var ring_radius := radius * (0.52 if boss else (0.40 if elite else 0.30))

    var lens := _add_cylinder_segments(core, ring_radius, 0.014, 6, soft, Vector3.ZERO, Vector3(90, 0, 30))
    lens.name = "EnemyWeakpointLens"
    if boss:
        _add_cylinder_segments(core, ring_radius * 0.58, 0.012, 24, dark, Vector3(0, 0.018, 0), Vector3(90, 0, 0))
    elif elite:
        var elite_mark := _add_cylinder_segments(core, ring_radius * 0.42, 0.018, 6, hot, Vector3(0, 0.050, 0), Vector3(90, 0, 30))
        elite_mark.name = "EnemyWeakpointMark"
        return

    match kind:
        "spitter":
            var acid := _add_cylinder_segments(core, ring_radius * 0.58, 0.012, 3, hot, Vector3(0, 0.040, radius * 0.06), Vector3(90, 0, 30))
            acid.name = "EnemyWeakpointMark"
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_sphere(core, radius * 0.055, hot, Vector3(cos(angle) * ring_radius * 0.42, 0.064, sin(angle) * ring_radius * 0.36 + radius * 0.08))
        "burrower", "boss_reksai":
            var blade := _add_box(core, Vector3(radius * 0.11, 0.014, ring_radius * 1.55), hot, Vector3(0, 0.054, radius * 0.06))
            blade.name = "EnemyWeakpointMark"
            for side in [-1.0, 1.0]:
                _add_box(core, Vector3(radius * 0.070, 0.012, ring_radius * 0.92), gold, Vector3(side * radius * 0.20, 0.072, radius * 0.02), Vector3(0, side * 18.0, 0))
        "carapace", "boss_cho":
            var crack := _add_box(core, Vector3(ring_radius * 1.35, 0.014, radius * 0.070), hot, Vector3(0, 0.054, radius * 0.02), Vector3(0, 18, 0))
            crack.name = "EnemyWeakpointMark"
            _add_box(core, Vector3(radius * 0.070, 0.014, ring_radius * 1.12), hot, Vector3(0, 0.072, radius * 0.02), Vector3(0, -18, 0))
        "void_eye", "boss_velkoz":
            var pupil := _add_sphere(core, radius * (0.095 if boss else 0.070), hot, Vector3(0, 0.070, radius * 0.04))
            pupil.name = "EnemyWeakpointMark"
            _add_box(core, Vector3(ring_radius * 1.48, 0.012, radius * 0.050), gold, Vector3(0, 0.088, radius * 0.04))
        "rift_crystal":
            var crystal := _add_cylinder_segments(core, ring_radius * 0.44, 0.050, 6, hot, Vector3(0, 0.060, 0), Vector3(0, 30, 0))
            crystal.name = "EnemyWeakpointMark"
            var shard_count := 6 if boss else (4 if elite else 3)
            for i in range(shard_count):
                var crystal_angle := TAU * float(i) / float(shard_count)
                _add_box(core, Vector3(radius * 0.044, 0.012, radius * 0.30), soft, Vector3(cos(crystal_angle) * ring_radius * 0.58, 0.078, sin(crystal_angle) * ring_radius * 0.58), Vector3(0, -rad_to_deg(crystal_angle), 0))
        "boss_belveth":
            var crown := _add_cylinder_segments(core, ring_radius * 0.72, 0.012, 5, hot, Vector3(0, 0.050, 0), Vector3(90, 0, 18))
            crown.name = "EnemyWeakpointMark"
            for side in [-1.0, 1.0]:
                _add_box(core, Vector3(radius * 0.072, 0.012, ring_radius * 1.16), hot, Vector3(side * radius * 0.26, 0.074, radius * 0.02), Vector3(0, side * 16.0, side * 38.0))
        _:
            var mark := _add_box(core, Vector3(radius * 0.080, 0.014, ring_radius * 1.18), hot, Vector3(0, 0.052, 0), Vector3(0, 45, 0))
            mark.name = "EnemyWeakpointMark"
            _add_box(core, Vector3(ring_radius * 1.18, 0.014, radius * 0.080), hot, Vector3(0, 0.070, 0), Vector3(0, 45, 0))

func _add_enemy_readability_plate(model: Node3D, kind: String, radius: float, elite: bool) -> void:
    var plate := Node3D.new()
    plate.name = "EnemyReadabilityPlate"
    plate.set_meta("kind", kind)
    plate.set_meta("readability_family", _enemy_readability_family(kind))
    plate.set_meta("detail_node", _enemy_readability_detail_name(kind))
    plate.set_meta("elite", elite)
    model.add_child(plate)
    var role_color := Color(1.0, 0.24, 0.72)
    match kind:
        "skitter":
            role_color = Color(1.0, 0.30, 0.64)
        "spitter":
            role_color = Color(0.54, 1.0, 0.28)
        "burrower":
            role_color = Color(1.0, 0.52, 0.18)
        "carapace":
            role_color = Color(0.76, 0.48, 1.0)
        "void_eye":
            role_color = Color(1.0, 0.34, 1.0)
        "rift_crystal":
            role_color = Color(0.34, 0.88, 1.0)
    var outer_radius := radius * (1.34 if elite else 1.08)
    var inner_radius := radius * (0.86 if elite else 0.68)
    var alpha := 0.34 if elite else 0.22
    var base_mat := _mat(kind + "_readability_plate", Color(role_color.r, role_color.g, role_color.b, alpha), 0.82, true, true)
    var hot_mat := _mat(kind + "_readability_hot", Color(role_color.lightened(0.18).r, role_color.lightened(0.18).g, role_color.lightened(0.18).b, 0.46 if elite else 0.34), 1.02, true, true)
    var dark_mat := _mat(kind + "_readability_dark", Color(0.02, 0.00, 0.05, 0.32), 0.08, true, true)
    _add_cylinder_segments(plate, outer_radius, 0.010, 6, base_mat, Vector3(0, 0.046, 0), Vector3(0, 30, 0))
    if elite:
        _add_cylinder_segments(plate, outer_radius * 1.16, 0.010, 6, hot_mat, Vector3(0, 0.058, 0), Vector3(0, 30, 0))
    var detail: Node3D = null
    match kind:
        "skitter":
            for side in [-1.0, 1.0]:
                var foreleg := _add_box(plate, Vector3(radius * 0.10, 0.012, radius * 0.82), hot_mat, Vector3(side * radius * 0.34, 0.072, radius * 0.30), Vector3(0, side * 24.0, 0))
                if side < 0.0:
                    detail = foreleg
                _add_box(plate, Vector3(radius * 0.10, 0.012, radius * 0.62), hot_mat, Vector3(side * radius * 0.64, 0.074, -radius * 0.12), Vector3(0, side * -22.0, 0))
        "spitter":
            detail = _add_cylinder_segments(plate, inner_radius, 0.010, 3, hot_mat, Vector3(0, 0.072, radius * 0.16), Vector3(0, 30, 0))
            for i in range(3):
                var spit_angle := -0.38 + float(i) * 0.38
                _add_sphere(plate, radius * 0.080, hot_mat, Vector3(sin(spit_angle) * radius * 0.56, 0.090, radius * (0.58 + abs(spit_angle) * 0.20)))
        "burrower":
            detail = _add_box(plate, Vector3(radius * 0.20, 0.014, radius * 1.42), hot_mat, Vector3(0, 0.074, radius * 0.16))
            for i in range(3):
                var offset := -0.42 + float(i) * 0.42
                _add_tapered_cylinder(plate, radius * 0.105, radius * 0.018, radius * 0.48, 6, hot_mat, Vector3(offset * radius, 0.106, radius * (0.52 + float(i) * 0.12)), Vector3(72, 0, offset * 18.0))
        "carapace":
            detail = _add_cylinder_segments(plate, inner_radius, 0.012, 6, dark_mat, Vector3(0, 0.070, 0), Vector3(0, 30, 0))
            for i in range(3):
                _add_box(plate, Vector3(radius * (1.18 - float(i) * 0.18), 0.014, radius * 0.12), hot_mat, Vector3(0, 0.092, radius * (-0.28 + float(i) * 0.28)), Vector3(0, 0, -8.0 + float(i) * 8.0))
        "void_eye":
            detail = _add_cylinder_segments(plate, inner_radius * 0.86, 0.012, 24, hot_mat, Vector3(0, 0.074, radius * 0.06), Vector3(90, 0, 0))
            _add_box(plate, Vector3(radius * 1.34, 0.012, radius * 0.075), hot_mat, Vector3(0, 0.096, radius * 0.06))
            _add_sphere(plate, radius * 0.090, dark_mat, Vector3(0, 0.116, radius * 0.06))
        "rift_crystal":
            detail = _add_cylinder_segments(plate, inner_radius, 0.012, 6, hot_mat, Vector3(0, 0.072, 0), Vector3(0, 30, 0))
            for i in range(6):
                var crystal_angle := TAU * float(i) / 6.0
                _add_box(plate, Vector3(radius * 0.074, 0.012, radius * 0.52), hot_mat, Vector3(cos(crystal_angle) * radius * 0.22, 0.094, sin(crystal_angle) * radius * 0.22), Vector3(0, -rad_to_deg(crystal_angle), 0))
        _:
            detail = _add_box(plate, Vector3(radius * 1.22, 0.012, radius * 0.10), hot_mat, Vector3(0, 0.074, radius * 0.12))
            _add_box(plate, Vector3(radius * 0.10, 0.012, radius * 1.22), hot_mat, Vector3(0, 0.076, radius * 0.12))
    if detail != null:
        detail.name = _enemy_readability_detail_name(kind)
        detail.set_meta("base_y", detail.position.y)

func _add_enemy_threat_halo(model: Node3D, kind: String, radius: float, boss: bool) -> void:
    var halo := Node3D.new()
    halo.name = "ThreatHalo"
    model.add_child(halo)
    var danger := DANGER_RED if boss else Color(0.92, 0.44, 1.0)
    var hot := Color(1.0, 0.58, 0.94) if not boss else Color(1.0, 0.24, 0.46)
    var outer_radius := radius * (2.18 if boss else 1.62)
    var inner_radius := radius * (1.54 if boss else 1.18)
    var outer_mat := _mat(kind + "_threat_outer", Color(danger.r, danger.g, danger.b, 0.30), 1.05, true, true)
    var inner_mat := _mat(kind + "_threat_inner", Color(hot.r, hot.g, hot.b, 0.38), 1.10, true, true)
    _add_cylinder_segments(halo, outer_radius, 0.016, 8 if boss else 6, outer_mat, Vector3(0, 0.078, 0), Vector3(0, 22.5 if boss else 30.0, 0))
    _add_cylinder_segments(halo, inner_radius, 0.012, 24, inner_mat, Vector3(0, 0.104, 0))
    var tick_count := 12 if boss else 8
    for i in range(tick_count):
        var angle := TAU * float(i) / float(tick_count)
        var long_tick := boss or i % 2 == 0
        var tick_len := radius * (0.70 if long_tick else 0.42)
        var tick_width := radius * (0.12 if boss else 0.10)
        var tick := _add_box(halo, Vector3(tick_width, 0.014, tick_len), inner_mat, Vector3(cos(angle) * outer_radius * 0.82, 0.124, sin(angle) * outer_radius * 0.82), Vector3(0, -rad_to_deg(angle), 0))
        tick.name = "ThreatTick" + str(i)

func _enemy_ground_silhouette_family(kind: String) -> String:
    match _enemy_combat_family(kind):
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

func _enemy_ground_silhouette_detail_name(kind: String) -> String:
    match _enemy_ground_silhouette_family(kind):
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

func _add_enemy_ground_silhouette_plate(model: Node3D, kind: String, radius: float, color: Color, boss: bool, elite: bool) -> void:
    if model.get_node_or_null("EnemyGroundSilhouettePlate") != null:
        return
    var plate := Node3D.new()
    plate.name = "EnemyGroundSilhouettePlate"
    plate.set_meta("kind", kind)
    plate.set_meta("boss", boss)
    plate.set_meta("elite", elite)
    plate.set_meta("silhouette_family", _enemy_ground_silhouette_family(kind))
    plate.set_meta("detail_node", _enemy_ground_silhouette_detail_name(kind))
    plate.set_meta("combat_visual_channel", "enemy_readability")
    plate.set_meta("material_grade", "low_glare_ground_silhouette")
    plate.set_meta("visual_stratum", "enemy_floor_readability")
    plate.set_meta("pickup_confusion_guard", true)
    plate.set_meta("collision_radius_readability", true)
    model.add_child(plate)

    var family := str(plate.get_meta("silhouette_family", ""))
    var detail_name := str(plate.get_meta("detail_node", ""))
    var accent := _enemy_combat_color(kind, color)
    var outer_radius := radius * (2.18 if boss else 1.58 if elite else 1.22)
    var inner_radius := radius * (1.46 if boss else 1.06 if elite else 0.82)
    var base_mat := _mat(kind + "_ground_silhouette_base", Color(0.0, 0.0, 0.0, 0.34 if boss else 0.28), 0.0, true, true)
    var edge_mat := _mat(kind + "_ground_silhouette_edge", Color(accent.r, accent.g, accent.b, 0.24 if boss or elite else 0.18), 0.0, true, true)
    var trim_mat := _mat(kind + "_ground_silhouette_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.18 if boss else 0.13), 0.0, true, true)
    var dark_body_mat := _mat(kind + "_ground_silhouette_body_shadow", Color(color.darkened(0.50).r, color.darkened(0.50).g, color.darkened(0.50).b, 0.30), 0.0, true, true)
    var gap_mat := _mat(kind + "_ground_silhouette_pickup_gap", Color(0.0, 0.0, 0.0, 0.30 if boss else 0.24 if elite else 0.20), 0.0, true, true)
    var facing_mat := _mat(kind + "_ground_silhouette_facing_notch", Color(accent.r, accent.g, accent.b, 0.22 if boss or elite else 0.16), 0.0, true, true)

    var base := _add_cylinder_segments(plate, outer_radius, 0.010, 8 if boss else 6, base_mat, Vector3(0, 0.046, 0), Vector3(0, 22.5 if boss else 30.0, 0))
    base.name = "EnemyGroundSilhouetteBaseMatte"
    base.set_meta("readability_role", "enemy_body_shadow")
    base.set_meta("pickup_confusion_guard", true)
    var edge := _add_cylinder_segments(plate, inner_radius, 0.010, 6, edge_mat, Vector3(0, 0.060, 0), Vector3(0, 30, 0))
    edge.name = "EnemyGroundSilhouetteEdgeMatte"
    edge.set_meta("readability_role", "enemy_role_outline")
    edge.set_meta("pickup_confusion_guard", true)
    var body_shadow := _add_cylinder_segments(plate, inner_radius * 0.58, 0.008, 6, dark_body_mat, Vector3(0, 0.074, 0), Vector3(0, 30, 0))
    body_shadow.name = "EnemyGroundSilhouetteBodyMass"
    body_shadow.set_meta("readability_role", "enemy_body_mass")
    body_shadow.set_meta("pickup_confusion_guard", true)
    var pickup_gap := _add_cylinder_segments(plate, outer_radius * 0.78, 0.006, 8 if boss else 6, gap_mat, Vector3(0, 0.083, 0), Vector3(0, 22.5 if boss else 30.0, 0))
    pickup_gap.name = "EnemyGroundSilhouettePickupGap"
    pickup_gap.set_meta("readability_role", "pickup_separation_gap")
    pickup_gap.set_meta("combat_visual_channel", "enemy_readability")
    pickup_gap.set_meta("pickup_confusion_guard", true)
    pickup_gap.set_meta("collision_radius_marker", true)
    var facing_notch := _add_box(plate, Vector3(radius * (0.14 if boss else 0.10), 0.008, radius * (0.94 if boss else 0.64)), facing_mat, Vector3(0, 0.096, radius * (1.04 if boss else 0.72)))
    facing_notch.name = "EnemyGroundSilhouetteFacingNotch"
    facing_notch.set_meta("readability_role", "enemy_facing_notch")
    facing_notch.set_meta("combat_visual_channel", "enemy_readability")
    facing_notch.set_meta("pickup_confusion_guard", true)

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("silhouette_family", family)
    detail.set_meta("base_y", 0.090)
    detail.set_meta("combat_visual_channel", "enemy_readability")
    detail.set_meta("pickup_confusion_guard", true)
    plate.add_child(detail)
    match family:
        "pounce_claw":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.12, 0.010, radius * 0.86), edge_mat, Vector3(side * radius * 0.38, 0.090, radius * 0.18), Vector3(0, side * 16.0, side * 34.0))
            _add_box(detail, Vector3(radius * 0.54, 0.010, radius * 0.080), trim_mat, Vector3(0, 0.102, -radius * 0.44))
        "acid_sac":
            _add_cylinder_segments(detail, radius * 0.42, 0.010, 16, edge_mat, Vector3(0, 0.090, -radius * 0.32))
            _add_box(detail, Vector3(radius * 0.18, 0.010, radius * 0.74), trim_mat, Vector3(0, 0.104, radius * 0.30))
        "burrow_lane":
            _add_box(detail, Vector3(radius * 0.28, 0.010, radius * (2.12 if boss else 1.42)), edge_mat, Vector3(0, 0.092, radius * 0.36))
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.12, 0.010, radius * 0.64), trim_mat, Vector3(side * radius * 0.36, 0.104, radius * 0.12), Vector3(0, side * 14.0, 0))
        "armor_shell":
            _add_box(detail, Vector3(radius * 0.92, 0.010, radius * 0.18), edge_mat, Vector3(0, 0.090, -radius * 0.08))
            _add_box(detail, Vector3(radius * 0.72, 0.010, radius * 0.14), trim_mat, Vector3(0, 0.104, radius * 0.20))
        "focus_eye":
            _add_cylinder_segments(detail, radius * 0.54, 0.010, 24, edge_mat, Vector3(0, 0.090, radius * 0.12), Vector3(90, 0, 0))
            for beam in range(3 if not boss else 5):
                var offset := float(beam) - float((3 if not boss else 5) - 1) * 0.5
                _add_box(detail, Vector3(radius * 0.060, 0.010, radius * 0.96), trim_mat, Vector3(offset * radius * 0.16, 0.104, radius * 0.52), Vector3(0, offset * 8.0, 0))
        "summon_crystal":
            _add_cylinder_segments(detail, radius * 0.44, 0.010, 6, edge_mat, Vector3(0, 0.090, 0), Vector3(0, 30, 0))
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_box(detail, Vector3(radius * 0.060, 0.010, radius * 0.26), trim_mat, Vector3(cos(angle) * radius * 0.46, 0.104, sin(angle) * radius * 0.46), Vector3(0, -rad_to_deg(angle), 0))
        "devour_maw":
            _add_cylinder_segments(detail, radius * 0.72, 0.010, 5, edge_mat, Vector3(0, 0.090, radius * 0.42), Vector3(0, 18, 0))
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(detail, radius * 0.075, radius * 0.010, radius * 0.58, 5, trim_mat, Vector3(side * radius * 0.28, 0.108, radius * 0.74), Vector3(72, 0, side * 18.0))
        "wing_swarm":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.10, 0.010, radius * 1.24), edge_mat, Vector3(side * radius * 0.50, 0.092, radius * 0.16), Vector3(0, side * 18.0, side * 46.0))
                _add_box(detail, Vector3(radius * 0.070, 0.010, radius * 0.74), trim_mat, Vector3(side * radius * 0.80, 0.106, -radius * 0.14), Vector3(0, side * -18.0, side * 36.0))
        _:
            _add_cylinder_segments(detail, radius * 0.38, 0.010, 5, edge_mat, Vector3(0, 0.090, radius * 0.18), Vector3(0, 18, 0))
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.08, 0.010, radius * 0.46), trim_mat, Vector3(side * radius * 0.28, 0.104, radius * 0.34), Vector3(0, side * 18.0, side * 22.0))

func _enemy_footprint_class(boss: bool, elite: bool) -> String:
    if boss:
        return "boss"
    if elite:
        return "elite"
    return "normal"

func _enemy_footprint_detail_name(boss: bool, elite: bool) -> String:
    match _enemy_footprint_class(boss, elite):
        "boss":
            return "EnemyFootprintBossMassFrame"
        "elite":
            return "EnemyFootprintEliteMassSpikes"
        _:
            return "EnemyFootprintNormalMassPips"

func _add_enemy_footprint_scale_rig(model: Node3D, kind: String, radius: float, color: Color, boss: bool, elite: bool) -> void:
    if model.get_node_or_null("EnemyFootprintScaleRig") != null:
        return
    var footprint_class := _enemy_footprint_class(boss, elite)
    var detail_name := _enemy_footprint_detail_name(boss, elite)
    var rig := Node3D.new()
    rig.name = "EnemyFootprintScaleRig"
    rig.set_meta("kind", kind)
    rig.set_meta("boss", boss)
    rig.set_meta("elite", elite)
    rig.set_meta("footprint_class", footprint_class)
    rig.set_meta("detail_node", detail_name)
    rig.set_meta("combat_visual_channel", "enemy_body_readability")
    rig.set_meta("material_grade", "low_glare_enemy_footprint_scale")
    rig.set_meta("pickup_confusion_guard", true)
    rig.set_meta("scale_readability", true)
    model.add_child(rig)

    var accent := _enemy_combat_color(kind, color)
    var outer_radius := radius * (2.44 if boss else 1.78 if elite else 1.18)
    var body_radius := radius * (1.50 if boss else 1.06 if elite else 0.68)
    var detail_radius := radius * (1.06 if boss else 0.76 if elite else 0.44)
    var side_count := 8 if boss else 6 if elite else 5
    var matte_mat := _mat(kind + "_footprint_scale_matte", Color(0.0, 0.0, 0.0, 0.34 if boss else 0.28 if elite else 0.22), 0.0, true, true)
    var body_mat := _mat(kind + "_footprint_body_bounds", Color(color.darkened(0.55).r, color.darkened(0.55).g, color.darkened(0.55).b, 0.28 if boss else 0.22 if elite else 0.16), 0.0, true, true)
    var edge_mat := _mat(kind + "_footprint_edge_bounds", Color(accent.r, accent.g, accent.b, 0.18 if boss else 0.15 if elite else 0.10), 0.0, true, true)
    var gap_mat := _mat(kind + "_footprint_pickup_gap", Color(0.0, 0.0, 0.0, 0.26 if boss else 0.21 if elite else 0.16), 0.0, true, true)
    var trim_mat := _mat(kind + "_footprint_rank_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.16 if boss else 0.12 if elite else 0.08), 0.0, true, true)

    var matte := _add_cylinder_segments(rig, outer_radius, 0.008, side_count, matte_mat, Vector3(0, 0.020, 0), Vector3(0, 22.5 if boss else 30.0, 0))
    matte.name = "EnemyFootprintScaleMatte"
    matte.set_meta("combat_visual_channel", "enemy_body_readability")
    matte.set_meta("pickup_confusion_guard", true)
    var bounds := _add_cylinder_segments(rig, body_radius, 0.008, side_count, body_mat, Vector3(0, 0.034, 0), Vector3(0, 22.5 if boss else 30.0, 0))
    bounds.name = "EnemyFootprintBodyBounds"
    bounds.set_meta("combat_visual_channel", "enemy_body_readability")
    bounds.set_meta("pickup_confusion_guard", true)
    var gap := _add_cylinder_segments(rig, outer_radius * 0.78, 0.006, side_count, gap_mat, Vector3(0, 0.048, 0), Vector3(0, 22.5 if boss else 30.0, 0))
    gap.name = "EnemyFootprintPickupClearanceGap"
    gap.set_meta("combat_visual_channel", "enemy_body_readability")
    gap.set_meta("pickup_confusion_guard", true)
    var bracket := _add_box(rig, Vector3(radius * (0.16 if boss else 0.12 if elite else 0.085), 0.008, radius * (1.02 if boss else 0.70 if elite else 0.42)), edge_mat, Vector3(0, 0.064, radius * (1.18 if boss else 0.84 if elite else 0.54)))
    bracket.name = "EnemyFootprintRankBracket"
    bracket.set_meta("combat_visual_channel", "enemy_body_readability")
    bracket.set_meta("pickup_confusion_guard", true)

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("footprint_class", footprint_class)
    detail.set_meta("base_y", 0.080)
    detail.set_meta("combat_visual_channel", "enemy_body_readability")
    detail.set_meta("pickup_confusion_guard", true)
    rig.add_child(detail)
    if boss:
        _add_cylinder_segments(detail, detail_radius, 0.008, 6, trim_mat, Vector3(0, 0.080, 0), Vector3(0, 30, 0))
        _add_box(detail, Vector3(radius * 1.18, 0.008, radius * 0.10), edge_mat, Vector3(0, 0.102, -radius * 0.90))
    elif elite:
        for i in range(2):
            var offset := -0.5 + float(i)
            _add_box(detail, Vector3(radius * 0.09, 0.008, radius * 0.48), edge_mat, Vector3(offset * radius * 0.22, 0.080, radius * 0.42), Vector3(0, offset * 10.0, offset * 20.0))
        _add_cylinder_segments(detail, detail_radius * 0.44, 0.008, 6, trim_mat, Vector3(0, 0.094, -radius * 0.48), Vector3(0, 30, 0))
    else:
        for i in range(2):
            var offset := -0.5 + float(i)
            _add_cylinder_segments(detail, radius * 0.070, 0.006, 5, edge_mat, Vector3(offset * radius * 0.20, 0.080, -radius * 0.34), Vector3(0, 18, 0))
        _add_box(detail, Vector3(radius * 0.42, 0.006, radius * 0.045), trim_mat, Vector3(0, 0.092, radius * 0.38))

func _enemy_threat_occlusion_detail_name(kind: String, boss: bool, elite_trait: String) -> String:
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

func _add_enemy_threat_occlusion_plate(model: Node3D, kind: String, radius: float, color: Color, boss: bool, elite: bool, elite_trait: String, lite: bool) -> void:
    if not boss and not elite:
        return
    if model.get_node_or_null("EnemyThreatOcclusionPlate") != null:
        return
    var threat_class := "boss" if boss else ("lite_elite" if lite else "elite")
    var detail_name := _enemy_threat_occlusion_detail_name(kind, boss, elite_trait)
    var plate := Node3D.new()
    plate.name = "EnemyThreatOcclusionPlate"
    plate.set_meta("kind", kind)
    plate.set_meta("boss", boss)
    plate.set_meta("elite", elite)
    plate.set_meta("elite_trait", elite_trait)
    plate.set_meta("lite", lite)
    plate.set_meta("threat_class", threat_class)
    plate.set_meta("detail_node", detail_name)
    plate.set_meta("visual_stratum", "enemy_floor_occlusion")
    plate.set_meta("combat_visual_channel", "enemy_occlusion_readability")
    plate.set_meta("material_grade", "low_glare_enemy_threat_occlusion")
    plate.set_meta("pickup_confusion_guard", true)
    plate.set_meta("collision_radius_readability", true)
    model.add_child(plate)

    var accent := DANGER_RED if boss else _elite_trait_color(elite_trait)
    if not boss and elite_trait == "":
        accent = _enemy_combat_color(kind, color)
    var outer_radius := radius * (2.72 if boss else 1.88 if lite else 2.06)
    var body_radius := radius * (1.66 if boss else 1.08 if lite else 1.20)
    var collision_radius := radius * (2.10 if boss else 1.46 if lite else 1.58)
    var base_mat := _mat(kind + "_threat_occlusion_matte_" + threat_class, Color(0.0, 0.0, 0.0, 0.34 if boss else 0.24 if lite else 0.28), 0.0, true, true)
    var darkened_color := color.darkened(0.62)
    var body_mat := _mat(kind + "_threat_occlusion_body_" + threat_class, Color(darkened_color.r, darkened_color.g, darkened_color.b, 0.30 if boss else 0.20 if lite else 0.24), 0.0, true, true)
    var rim_mat := _mat(kind + "_threat_occlusion_rim_" + threat_class, Color(accent.r, accent.g, accent.b, 0.34 if boss else 0.26), 0.0, true, true)
    var cut_mat := _mat(kind + "_threat_occlusion_cut_" + threat_class, Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.34 if boss else 0.28), 0.0, true, true)
    var gold_mat := _mat(kind + "_threat_occlusion_gold_" + threat_class, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.30 if boss else 0.24), 0.0, true, true)

    var base := _add_cylinder_segments(plate, outer_radius, 0.008, 8 if boss else 6, base_mat, Vector3(0, 0.012, 0), Vector3(0, 22.5 if boss else 30.0, 0))
    base.name = "EnemyThreatOcclusionMatte"
    base.set_meta("combat_visual_channel", "enemy_occlusion_readability")
    base.set_meta("pickup_confusion_guard", true)
    var body := _add_cylinder_segments(plate, body_radius, 0.008, 6, body_mat, Vector3(0, 0.026, 0), Vector3(0, 30, 0))
    body.name = "EnemyThreatOcclusionBodyMass"
    body.set_meta("combat_visual_channel", "enemy_occlusion_readability")
    body.set_meta("pickup_confusion_guard", true)
    var collision := _add_cylinder_segments(plate, collision_radius, 0.008, 8 if boss else 6, rim_mat, Vector3(0, 0.040, 0), Vector3(0, 22.5 if boss else 30.0, 0))
    collision.name = "EnemyThreatOcclusionCollisionRing"
    collision.set_meta("combat_visual_channel", "enemy_occlusion_readability")
    collision.set_meta("collision_radius_marker", true)
    collision.set_meta("pickup_confusion_guard", true)
    var facing := _add_box(plate, Vector3(radius * (0.22 if boss else 0.16), 0.010, radius * (1.22 if boss else 0.82)), cut_mat, Vector3(0, 0.058, radius * (1.28 if boss else 0.90)))
    facing.name = "EnemyThreatOcclusionFacingCut"
    facing.set_meta("combat_visual_channel", "enemy_occlusion_readability")
    facing.set_meta("pickup_confusion_guard", true)

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("threat_class", threat_class)
    detail.set_meta("elite_trait", elite_trait)
    detail.set_meta("combat_visual_channel", "enemy_occlusion_readability")
    detail.set_meta("base_y", 0.070)
    plate.add_child(detail)
    if boss:
        for anchor in range(3):
            var anchor_angle := TAU * float(anchor) / 3.0 + PI / 6.0
            _add_box(detail, Vector3(radius * 0.13, 0.008, radius * 0.42), gold_mat, Vector3(cos(anchor_angle) * radius * 0.62, 0.088, sin(anchor_angle) * radius * 0.52), Vector3(0, rad_to_deg(anchor_angle), 0))
        match kind:
            "boss_cho":
                _add_cylinder_segments(detail, radius * 0.58, 0.008, 5, cut_mat, Vector3(0, 0.070, radius * 0.48), Vector3(0, 18, 0))
                for side in [-1.0, 1.0]:
                    _add_tapered_cylinder(detail, radius * 0.070, radius * 0.010, radius * 0.54, 5, gold_mat, Vector3(side * radius * 0.28, 0.084, radius * 0.76), Vector3(72, 0, side * 18.0))
            "boss_velkoz":
                for beam in range(5):
                    var offset := float(beam) - 2.0
                    _add_box(detail, Vector3(radius * 0.060, 0.008, radius * 1.24), rim_mat, Vector3(offset * radius * 0.20, 0.070, radius * 0.58), Vector3(0, offset * 8.0, 0))
            "boss_reksai":
                _add_box(detail, Vector3(radius * 0.24, 0.010, radius * 1.72), cut_mat, Vector3(0, 0.070, radius * 0.66))
                for side in [-1.0, 1.0]:
                    _add_box(detail, Vector3(radius * 0.090, 0.008, radius * 0.78), gold_mat, Vector3(side * radius * 0.36, 0.086, radius * 0.40), Vector3(0, side * 16.0, 0))
            "boss_belveth":
                for side in [-1.0, 1.0]:
                    _add_box(detail, Vector3(radius * 0.10, 0.008, radius * 1.36), cut_mat, Vector3(side * radius * 0.58, 0.070, radius * 0.24), Vector3(0, side * 16.0, side * 44.0))
                    _add_box(detail, Vector3(radius * 0.070, 0.008, radius * 0.82), gold_mat, Vector3(side * radius * 0.86, 0.084, -radius * 0.14), Vector3(0, side * -14.0, side * 34.0))
            _:
                _add_cylinder_segments(detail, radius * 0.52, 0.008, 6, cut_mat, Vector3(0, 0.070, radius * 0.24), Vector3(0, 30, 0))
    else:
        match elite_trait:
            "frenzy":
                for slash in range(3):
                    var offset := float(slash) - 1.0
                    _add_box(detail, Vector3(radius * 0.070, 0.008, radius * (0.66 if lite else 0.82)), cut_mat, Vector3(offset * radius * 0.18, 0.070, radius * 0.22), Vector3(0, offset * 16.0, offset * 20.0))
            "bulwark":
                _add_cylinder_segments(detail, radius * (0.42 if lite else 0.54), 0.008, 6, rim_mat, Vector3(0, 0.070, radius * 0.08), Vector3(0, 30, 0))
                _add_box(detail, Vector3(radius * (0.74 if lite else 0.96), 0.008, radius * 0.080), gold_mat, Vector3(0, 0.086, radius * 0.08))
            "splitter":
                for shard in range(4):
                    var angle := TAU * float(shard) / 4.0
                    _add_sphere(detail, radius * 0.060, rim_mat, Vector3(cos(angle) * radius * 0.34, 0.070, sin(angle) * radius * 0.28 + radius * 0.12))
            "treasure":
                _add_cylinder_segments(detail, radius * (0.30 if lite else 0.40), 0.014, 6, gold_mat, Vector3(0, 0.070, radius * 0.04), Vector3(0, 30, 0))
                _add_box(detail, Vector3(radius * (0.56 if lite else 0.72), 0.008, radius * 0.060), rim_mat, Vector3(0, 0.090, radius * 0.04))
            _:
                _add_box(detail, Vector3(radius * (0.68 if lite else 0.82), 0.008, radius * 0.070), rim_mat, Vector3(0, 0.070, radius * 0.10))
                _add_box(detail, Vector3(radius * 0.070, 0.008, radius * (0.68 if lite else 0.82)), rim_mat, Vector3(0, 0.072, radius * 0.10))

func _sync_enemy_threat_occlusion_plate(model: Node3D, enemy: Node, kind: String, boss: bool, elite: bool, elite_trait: String, id: int, visual_radius: float) -> void:
    var plate := model.get_node_or_null("EnemyThreatOcclusionPlate") as Node3D
    if plate == null:
        return
    var health_max := maxf(1.0, float(enemy.get("max_health")))
    var health_ratio := clampf(float(enemy.get("health")) / health_max, 0.0, 1.0)
    var attack_t := 1.0 - clampf(float(enemy.get("attack_timer")) / (0.68 if boss else 0.52), 0.0, 1.0)
    var dash_t := clampf(float(enemy.get("dash_timer")) / (3.0 if kind == "boss_reksai" else 0.72), 0.0, 1.0)
    var pressure := maxf(1.0 - health_ratio, attack_t)
    if boss:
        pressure = maxf(pressure, clampf((0.45 - health_ratio) / 0.45, 0.0, 1.0))
        if kind == "boss_reksai":
            pressure = maxf(pressure, dash_t if float(enemy.get("dash_timer")) > 2.42 else 0.0)
    elif elite_trait == "frenzy":
        pressure = maxf(pressure, dash_t)
    elif elite_trait == "treasure":
        pressure = maxf(pressure, clampf(float(enemy.get("treasure_flee_timer")) / 1.55, 0.0, 1.0))
    pressure = clampf(pressure, 0.0, 1.0)
    plate.visible = elite or boss
    plate.set_meta("threat_pressure", pressure)
    plate.set_meta("health_ratio", health_ratio)
    if not plate.visible:
        return
    var time := Time.get_ticks_msec() / 1000.0
    var pulse := 1.0 + sin(time * (1.25 if boss else 1.05) + float(id % 37)) * (0.008 + pressure * 0.016)
    plate.scale = Vector3(pulse + pressure * (0.030 if boss else 0.018), 1.0, pulse + pressure * (0.040 if boss else 0.024))
    plate.position.y = sin(time * 1.7 + float(id % 19)) * visual_radius * 0.004
    var detail := plate.get_node_or_null(str(plate.get_meta("detail_node", ""))) as Node3D
    if detail != null:
        detail.position.y = float(detail.get_meta("base_y", detail.position.y)) + pressure * visual_radius * 0.012
    var facing := plate.get_node_or_null("EnemyThreatOcclusionFacingCut") as Node3D
    if facing != null:
        facing.visible = boss or attack_t > 0.04 or pressure > 0.26

func _enemy_threat_rank(boss: bool, elite: bool) -> String:
    if boss:
        return "boss"
    if elite:
        return "elite"
    return "normal"

func _enemy_threat_rank_detail_name(boss: bool, elite: bool) -> String:
    match _enemy_threat_rank(boss, elite):
        "boss":
            return "EnemyThreatRankBossCrown"
        "elite":
            return "EnemyThreatRankEliteSpikes"
        _:
            return "EnemyThreatRankNormalPips"

func _add_enemy_threat_rank_silhouette_rig(model: Node3D, kind: String, radius: float, color: Color, boss: bool, elite: bool, elite_trait: String) -> void:
    if model.get_node_or_null("EnemyThreatRankSilhouetteRig") != null:
        return
    var rank := _enemy_threat_rank(boss, elite)
    var detail_name := _enemy_threat_rank_detail_name(boss, elite)
    var rig := Node3D.new()
    rig.name = "EnemyThreatRankSilhouetteRig"
    rig.set_meta("kind", kind)
    rig.set_meta("boss", boss)
    rig.set_meta("elite", elite)
    rig.set_meta("elite_trait", elite_trait)
    rig.set_meta("rank", rank)
    rig.set_meta("detail_node", detail_name)
    rig.set_meta("combat_visual_channel", "enemy_rank_readability")
    rig.set_meta("material_grade", "low_glare_enemy_rank_silhouette")
    rig.set_meta("pickup_confusion_guard", true)
    model.add_child(rig)

    var accent := _enemy_combat_color(kind, color)
    var base_radius := radius * (2.26 if boss else 1.74 if elite else 1.20)
    var frame_radius := radius * (1.84 if boss else 1.36 if elite else 0.92)
    var front_z := radius * (1.32 if boss else 1.02 if elite else 0.70)
    var side_count := 6 if boss else 5 if elite else 4
    var dark_mat := _mat(kind + "_rank_shadow_matte", Color(0.0, 0.0, 0.0, 0.50 if boss else 0.42 if elite else 0.30), 0.0, true, true)
    var rim_mat := _mat(kind + "_rank_rim_matte", Color(accent.r, accent.g, accent.b, 0.28 if boss else 0.23 if elite else 0.16), 0.0, true, true)
    var gold_mat := _mat(kind + "_rank_gold_matte", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24 if boss else 0.18 if elite else 0.12), 0.0, true, true)
    var danger_mat := _mat(kind + "_rank_danger_matte", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.30 if boss else 0.25 if elite else 0.16), 0.0, true, true)

    var base := _add_cylinder_segments(rig, base_radius, 0.008, side_count, dark_mat, Vector3(0, 0.114, 0), Vector3(0, 30 if boss else 18 if elite else 45, 0))
    base.name = "EnemyThreatRankBaseMatte"
    base.set_meta("rank", rank)
    var frame := _add_cylinder_segments(rig, frame_radius, 0.008, side_count, rim_mat, Vector3(0, 0.128, 0), Vector3(0, 30 if boss else 18 if elite else 45, 0))
    frame.name = "EnemyThreatRankOuterFrame"
    frame.set_meta("rank", rank)
    var facing := _add_box(rig, Vector3(radius * (0.18 if boss else 0.14 if elite else 0.10), 0.010, radius * (0.94 if boss else 0.68 if elite else 0.44)), danger_mat if boss or elite else rim_mat, Vector3(0, 0.146, front_z))
    facing.name = "EnemyThreatRankFacingNeedle"
    facing.set_meta("rank", rank)

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("rank", rank)
    detail.set_meta("elite_trait", elite_trait)
    rig.add_child(detail)

    if boss:
        for i in range(6):
            var angle := TAU * float(i) / 6.0
            var tooth := _add_box(detail, Vector3(radius * 0.11, 0.010, radius * 0.44), gold_mat if i % 2 == 0 else danger_mat, Vector3(cos(angle) * radius * 1.12, 0.166, sin(angle) * radius * 1.12), Vector3(0, -rad_to_deg(angle), 0))
            tooth.name = "EnemyThreatRankBossCrownTooth%d" % i
        var boss_bar := _add_box(detail, Vector3(radius * 1.20, 0.012, radius * 0.12), danger_mat, Vector3(0, 0.184, -radius * 1.08))
        boss_bar.name = "EnemyThreatRankBossDangerBar"
    elif elite:
        for i in range(4):
            var offset := float(i) - 1.5
            var spike := _add_box(detail, Vector3(radius * 0.10, 0.010, radius * 0.50), rim_mat if i % 2 == 0 else danger_mat, Vector3(offset * radius * 0.30, 0.164, front_z * 0.64), Vector3(0, offset * 11.0, offset * 22.0))
            spike.name = "EnemyThreatRankEliteSpike%d" % i
        var reward := _add_cylinder_segments(detail, radius * 0.18, 0.014, 6, gold_mat, Vector3(0, 0.182, -radius * 0.82), Vector3(0, 30, 0))
        reward.name = "EnemyThreatRankEliteRewardPip"
        reward.set_meta("elite_trait", elite_trait)
    else:
        for i in range(3):
            var offset := float(i) - 1.0
            var pip := _add_cylinder_segments(detail, radius * 0.095, 0.010, 6, rim_mat, Vector3(offset * radius * 0.24, 0.160, -radius * 0.52), Vector3(0, 30, 0))
            pip.name = "EnemyThreatRankNormalPip%d" % i
        var normal_chevron := _add_box(detail, Vector3(radius * 0.48, 0.008, radius * 0.055), gold_mat, Vector3(0, 0.174, front_z * 0.44))
        normal_chevron.name = "EnemyThreatRankNormalChevron"

func _enemy_threat_tier_detail_name(boss: bool, elite: bool) -> String:
    match _enemy_threat_rank(boss, elite):
        "boss":
            return "EnemyThreatTierBossBanner"
        "elite":
            return "EnemyThreatTierEliteChevron"
        _:
            return "EnemyThreatTierNormalTicks"

func _add_enemy_threat_tier_marker(model: Node3D, kind: String, radius: float, color: Color, boss: bool, elite: bool, elite_trait: String) -> void:
    if model.get_node_or_null("EnemyThreatTierMarker") != null:
        return
    var tier := _enemy_threat_rank(boss, elite)
    var detail_name := _enemy_threat_tier_detail_name(boss, elite)
    var root := Node3D.new()
    root.name = "EnemyThreatTierMarker"
    root.set_meta("kind", kind)
    root.set_meta("boss", boss)
    root.set_meta("elite", elite)
    root.set_meta("elite_trait", elite_trait)
    root.set_meta("threat_tier", tier)
    root.set_meta("detail_node", detail_name)
    root.set_meta("combat_visual_channel", "enemy_tier_readability")
    root.set_meta("material_grade", "low_glare_enemy_tier_marker")
    root.set_meta("pickup_confusion_guard", true)
    root.set_meta("collision_radius_readability", true)
    model.add_child(root)

    var accent := DANGER_RED if boss else _elite_trait_color(elite_trait) if elite else _enemy_combat_color(kind, color)
    var matte_alpha := 0.34 if boss else 0.28 if elite else 0.18
    var signal_alpha := 0.28 if boss else 0.23 if elite else 0.16
    var base_radius := radius * (2.48 if boss else 1.72 if elite else 1.04)
    var frame_radius := radius * (2.06 if boss else 1.36 if elite else 0.78)
    var front_z := radius * (1.58 if boss else 1.04 if elite else 0.62)
    var dark_mat := _mat(kind + "_tier_marker_matte", Color(0.0, 0.0, 0.0, matte_alpha), 0.0, true, true)
    var signal_mat := _mat(kind + "_tier_marker_signal", Color(accent.r, accent.g, accent.b, signal_alpha), 0.0, true, true)
    var gold_mat := _mat(kind + "_tier_marker_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.20 if boss else 0.16 if elite else 0.10), 0.0, true, true)
    var cut_mat := _mat(kind + "_tier_marker_cutout", Color(0.0, 0.0, 0.0, 0.22 if boss else 0.18), 0.0, true, true)

    var base := _add_cylinder_segments(root, base_radius, 0.008, 8 if boss else 6 if elite else 4, dark_mat, Vector3(0, 0.092, 0), Vector3(0, 22.5 if boss else 30.0 if elite else 45.0, 0))
    base.name = "EnemyThreatTierMatteBase"
    base.set_meta("threat_tier", tier)
    var frame := _add_cylinder_segments(root, frame_radius, 0.008, 8 if boss else 6 if elite else 4, signal_mat, Vector3(0, 0.108, 0), Vector3(0, 22.5 if boss else 30.0 if elite else 45.0, 0))
    frame.name = "EnemyThreatTierOuterFrame"
    frame.set_meta("threat_tier", tier)
    var facing := _add_box(root, Vector3(radius * (0.22 if boss else 0.16 if elite else 0.10), 0.010, radius * (0.88 if boss else 0.60 if elite else 0.36)), gold_mat if boss or elite else signal_mat, Vector3(0, 0.126, front_z))
    facing.name = "EnemyThreatTierFacingTab"
    facing.set_meta("threat_tier", tier)

    var rewards := Node3D.new()
    rewards.name = "EnemyThreatTierRewardPips"
    rewards.set_meta("threat_tier", tier)
    rewards.set_meta("pip_count", 4 if boss else 3 if elite else 2)
    root.add_child(rewards)
    var pip_count := int(rewards.get_meta("pip_count"))
    for i in range(pip_count):
        var offset := 0.0 if pip_count <= 1 else -0.5 + float(i) / float(pip_count - 1)
        var pip := _add_cylinder_segments(rewards, radius * (0.095 if boss else 0.075 if elite else 0.052), 0.010, 6, gold_mat if i % 2 == 0 else signal_mat, Vector3(offset * radius * (1.08 if boss else 0.72 if elite else 0.44), 0.140, -radius * (1.22 if boss else 0.82 if elite else 0.46)), Vector3(0, 30, 0))
        pip.name = "EnemyThreatTierRewardPip%d" % i
        pip.set_meta("pip_index", i)

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("threat_tier", tier)
    detail.set_meta("elite_trait", elite_trait)
    root.add_child(detail)
    if boss:
        var banner := _add_box(detail, Vector3(radius * 1.28, 0.012, radius * 0.130), signal_mat, Vector3(0, 0.160, front_z * 0.56))
        banner.name = "EnemyThreatTierBossBannerBar"
        for i in range(5):
            var offset := -0.5 + float(i) / 4.0
            var spike := _add_tapered_cylinder(detail, radius * 0.080, radius * 0.014, radius * 0.42, 5, gold_mat if i % 2 == 0 else signal_mat, Vector3(offset * radius * 1.04, 0.182, front_z * 0.72), Vector3(68, 0, offset * 24.0))
            spike.name = "EnemyThreatTierBossBannerSpike%d" % i
        _add_box(detail, Vector3(radius * 0.84, 0.010, radius * 0.080), cut_mat, Vector3(0, 0.174, front_z * 0.38)).name = "EnemyThreatTierBossReadGap"
    elif elite:
        for side in [-1.0, 1.0]:
            var chevron := _add_box(detail, Vector3(radius * 0.130, 0.012, radius * 0.62), signal_mat, Vector3(side * radius * 0.30, 0.156, front_z * 0.56), Vector3(0, side * 28.0, side * 18.0))
            chevron.name = "EnemyThreatTierEliteChevron" + ("L" if side < 0.0 else "R")
        var trait_gem := _add_cylinder_segments(detail, radius * 0.18, 0.012, 6, gold_mat, Vector3(0, 0.176, -radius * 0.58), Vector3(0, 30, 0))
        trait_gem.name = "EnemyThreatTierEliteTraitGem"
        trait_gem.set_meta("elite_trait", elite_trait)
    else:
        for i in range(3):
            var offset := float(i) - 1.0
            var tick := _add_box(detail, Vector3(radius * 0.060, 0.008, radius * 0.34), signal_mat, Vector3(offset * radius * 0.20, 0.148, front_z * 0.46), Vector3(0, offset * 12.0, 0))
            tick.name = "EnemyThreatTierNormalTick%d" % i
        _add_box(detail, Vector3(radius * 0.42, 0.008, radius * 0.050), gold_mat, Vector3(0, 0.160, -radius * 0.42)).name = "EnemyThreatTierNormalBaseline"

func _sync_enemy_threat_tier_marker(model: Node3D, enemy: Node, boss: bool, elite: bool, id: int, visual_radius: float) -> void:
    var root := model.get_node_or_null("EnemyThreatTierMarker") as Node3D
    if root == null:
        return
    var health_max := maxf(1.0, float(enemy.get("max_health")))
    var health_ratio := clampf(float(enemy.get("health")) / health_max, 0.0, 1.0)
    var attack_timer := maxf(0.0, float(enemy.get("attack_timer")))
    var readiness := 1.0 - clampf(attack_timer / (0.68 if boss else 0.52), 0.0, 1.0)
    var pressure := 1.0 - health_ratio
    var tier_weight := 1.0 if boss else 0.62 if elite else 0.28
    var time := Time.get_ticks_msec() / 1000.0
    root.visible = float(enemy.get("health")) > 0.0
    root.set_meta("health_ratio", health_ratio)
    root.set_meta("attack_readiness", readiness)
    root.set_meta("tier_pressure", pressure)
    if not root.visible:
        return
    var pulse := 1.0 + sin(time * (1.35 + tier_weight) + float(id % 31)) * (0.010 + tier_weight * 0.014)
    root.scale = Vector3.ONE * (pulse + pressure * 0.035 + readiness * 0.020 * tier_weight)
    root.rotation.y += 0.006 + tier_weight * 0.006
    root.position.y = sin(time * (1.8 + tier_weight) + float(id % 17)) * visual_radius * 0.004
    var rewards := root.get_node_or_null("EnemyThreatTierRewardPips") as Node3D
    if rewards != null:
        rewards.rotation.y -= 0.010 + tier_weight * 0.006
    var detail := root.get_node_or_null(str(root.get_meta("detail_node", ""))) as Node3D
    if detail != null:
        detail.scale = Vector3.ONE * (1.0 + maxf(pressure, readiness * tier_weight) * 0.045)

func _add_priority_combat_backplate(model: Node3D, kind: String, radius: float, color: Color, boss: bool, elite_trait: String) -> void:
    var rig := Node3D.new()
    rig.name = "PriorityCombatBackplateRig"
    rig.set_meta("priority_class", "boss" if boss else "elite")
    rig.set_meta("elite_trait", elite_trait)
    rig.set_meta("combat_visual_channel", "priority_readability")
    rig.set_meta("stateful_priority_readability", true)
    model.add_child(rig)

    var priority_color := DANGER_RED if boss else _elite_trait_color(elite_trait)
    var back_radius := radius * (2.72 if boss else 1.86)
    var inner_radius := radius * (1.78 if boss else 1.16)
    var dark_mat := _mat(kind + "_priority_matte_backplate", Color(0.0, 0.0, 0.0, 0.36 if boss else 0.30), 0.0, true, true)
    var edge_mat := _mat(kind + "_priority_edge_matte", Color(priority_color.r, priority_color.g, priority_color.b, 0.22 if boss else 0.18), 0.0, true, true)
    var trim_mat := _mat(kind + "_priority_gold_matte", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24), 0.0, true, true)
    var body_shadow := _mat(kind + "_priority_body_shadow", Color(color.darkened(0.46).r, color.darkened(0.46).g, color.darkened(0.46).b, 0.26), 0.0, true, true)

    var backplate := _add_cylinder_segments(rig, back_radius, 0.012, 8 if boss else 6, dark_mat, Vector3(0, 0.030, 0), Vector3(0, 22.5 if boss else 30.0, 0))
    backplate.name = "PriorityCombatMatteBackplate"
    backplate.set_meta("priority_class", "boss" if boss else "elite")
    var inner := _add_cylinder_segments(rig, inner_radius, 0.010, 6, body_shadow, Vector3(0, 0.044, 0), Vector3(0, 30.0, 0))
    inner.name = "PriorityCombatBodySilhouetteBacker"

    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        var bracket_len := radius * (0.94 if boss else 0.62)
        var bracket := _add_box(rig, Vector3(radius * 0.11, 0.010, bracket_len), edge_mat, Vector3(cos(angle) * back_radius * 0.74, 0.058, sin(angle) * back_radius * 0.74), Vector3(0, -rad_to_deg(angle), 0))
        bracket.name = "PriorityCombatFocusBracket%d" % i

    if boss:
        var threat := _add_box(rig, Vector3(radius * 1.26, 0.012, radius * 0.13), edge_mat, Vector3(0, 0.072, radius * 1.38))
        threat.name = "BossPriorityThreatBacker"
        threat.set_meta("boss_kind", kind)
        var phase_trim := _add_box(rig, Vector3(radius * 0.90, 0.010, radius * 0.080), trim_mat, Vector3(0, 0.088, -radius * 1.34))
        phase_trim.name = "BossPriorityPhaseTrim"
    else:
        var reward := _add_cylinder_segments(rig, radius * 0.24, 0.020, 6, trim_mat, Vector3(0, 0.078, -radius * 1.04), Vector3(0, 30, 0))
        reward.name = "EliteRewardReadabilityPip"
        reward.set_meta("elite_trait", elite_trait)
        var trait_hint := _add_box(rig, Vector3(radius * 0.64, 0.010, radius * 0.070), edge_mat, Vector3(0, 0.092, -radius * 1.04))
        trait_hint.name = "ElitePriorityTraitHint"

    _add_priority_threat_state_strip(rig, kind, radius, priority_color, boss, elite_trait)

func _add_priority_threat_state_strip(rig: Node3D, kind: String, radius: float, priority_color: Color, boss: bool, elite_trait: String) -> void:
    var strip := Node3D.new()
    strip.name = "PriorityThreatStateStrip"
    strip.visible = false
    strip.set_meta("priority_class", "boss" if boss else "elite")
    strip.set_meta("elite_trait", elite_trait)
    strip.set_meta("combat_visual_channel", "priority_readability")
    rig.add_child(strip)

    var strip_width := radius * (1.52 if boss else 1.06)
    var z_offset := radius * (1.78 if boss else 1.20)
    var dark_mat := _mat(kind + "_priority_state_dark", Color(0.0, 0.0, 0.0, 0.34 if boss else 0.30), 0.0, true, true)
    var meter_mat := _mat(kind + "_priority_state_meter", Color(priority_color.r, priority_color.g, priority_color.b, 0.30 if boss else 0.26), 0.0, true, true)
    var gold_mat := _mat(kind + "_priority_state_gold", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24), 0.0, true, true)
    var tick_mat := _mat(kind + "_priority_state_tick", Color(priority_color.lightened(0.12).r, priority_color.lightened(0.12).g, priority_color.lightened(0.12).b, 0.28), 0.0, true, true)

    var matte := _add_box(strip, Vector3(strip_width * 1.14, 0.010, radius * 0.120), dark_mat, Vector3(0, 0.106, z_offset))
    matte.name = "PriorityThreatStateMatte"
    var meter := _add_box(strip, Vector3(strip_width, 0.012, radius * 0.064), meter_mat, Vector3(0, 0.122, z_offset))
    meter.name = "PriorityThreatStateMeter"
    meter.set_meta("bar_width", strip_width)
    var cap := _add_box(strip, Vector3(strip_width * 1.05, 0.008, radius * 0.025), gold_mat, Vector3(0, 0.138, z_offset - radius * 0.080))
    cap.name = "PriorityThreatStateTrim"

    var pips := Node3D.new()
    pips.name = "PriorityThreatStagePips"
    pips.set_meta("pip_count", 4 if boss else 3)
    strip.add_child(pips)
    var pip_count := int(pips.get_meta("pip_count"))
    for i in range(pip_count):
        var offset := 0.0 if pip_count <= 1 else -0.5 + float(i) / float(pip_count - 1)
        var pip := _add_box(pips, Vector3(radius * (0.090 if boss else 0.070), 0.010, radius * 0.150), tick_mat, Vector3(offset * strip_width * 0.78, 0.154, z_offset + radius * 0.105), Vector3(0, offset * 10.0, 0))
        pip.name = "PriorityThreatStagePip%d" % i
        pip.visible = false
        pip.set_meta("pip_index", i)

func _sync_priority_combat_backplate(model: Node3D, enemy: Node, kind: String, boss: bool, elite_trait: String, id: int, visual_radius: float) -> void:
    var rig := model.get_node_or_null("PriorityCombatBackplateRig") as Node3D
    if rig == null:
        return
    var health_max := maxf(1.0, float(enemy.get("max_health")))
    var health_ratio := clampf(float(enemy.get("health")) / health_max, 0.0, 1.0)
    var cast_t := 1.0 - clampf(float(enemy.get("attack_timer")) / (0.68 if boss else 0.52), 0.0, 1.0)
    var dash_t := clampf(float(enemy.get("dash_timer")) / (3.0 if kind == "boss_reksai" else 0.72), 0.0, 1.0)
    var summon_window := 1.85 if boss else 1.35
    var summon_t := 1.0 - clampf(float(enemy.get("summon_timer")) / summon_window, 0.0, 1.0)
    if not (kind == "rift_crystal" or kind == "boss_belveth" or kind == "boss_cho"):
        summon_t = 0.0
    var pressure := 1.0 - health_ratio
    var urgency := maxf(cast_t, pressure * (0.88 if boss else 0.72))
    if boss:
        urgency = maxf(urgency, clampf((0.45 - health_ratio) / 0.45, 0.0, 1.0))
        if kind == "boss_reksai":
            urgency = maxf(urgency, dash_t if float(enemy.get("dash_timer")) > 2.42 else 0.0)
        if kind == "boss_cho" or kind == "boss_belveth":
            urgency = maxf(urgency, summon_t)
    else:
        match elite_trait:
            "frenzy":
                urgency = maxf(urgency, dash_t)
            "bulwark":
                urgency = maxf(urgency, clampf(float(enemy.get("bulwark_break_timer")) / 2.60, 0.0, 1.0))
            "splitter":
                if bool(enemy.get("splitter_spawned")) or health_ratio <= 0.52:
                    urgency = maxf(urgency, 0.72)
            "treasure":
                urgency = maxf(urgency, maxf(0.32, clampf(float(enemy.get("treasure_flee_timer")) / 1.55, 0.0, 1.0)))
            _:
                pass
    urgency = clampf(urgency, 0.0, 1.0)
    rig.visible = float(enemy.get("health")) > 0.0
    rig.set_meta("priority_urgency", urgency)
    rig.set_meta("priority_health_ratio", health_ratio)
    rig.set_meta("priority_cast_t", cast_t)
    if not rig.visible:
        return
    var time := Time.get_ticks_msec() / 1000.0
    var pulse := 1.0 + sin(time * (2.2 + urgency * 2.4) + float(id % 31)) * (0.010 + urgency * 0.024)
    rig.scale = Vector3(pulse + urgency * 0.024, 1.0, pulse + urgency * 0.040)
    rig.rotation.y += 0.004 + urgency * (0.012 if boss else 0.009)
    rig.position.y = sin(time * 2.0 + float(id % 17)) * visual_radius * 0.006

    var strip := rig.get_node_or_null("PriorityThreatStateStrip") as Node3D
    if strip == null:
        return
    strip.visible = boss or urgency > 0.08
    strip.set_meta("priority_urgency", urgency)
    strip.set_meta("priority_health_ratio", health_ratio)
    if not strip.visible:
        return
    strip.scale = Vector3(1.0 + urgency * 0.055, 1.0, 1.0 + urgency * 0.035)
    strip.position.y = sin(time * (3.0 + urgency * 2.0) + float(id % 13)) * visual_radius * 0.008
    var meter := strip.get_node_or_null("PriorityThreatStateMeter") as MeshInstance3D
    if meter != null:
        var bar_width := float(meter.get_meta("bar_width", 1.0))
        meter.visible = true
        meter.scale.x = lerpf(0.18, 1.0, urgency)
        meter.position.x = -bar_width * (1.0 - meter.scale.x) * 0.5
    var pips := strip.get_node_or_null("PriorityThreatStagePips") as Node3D
    if pips != null:
        var pip_count: int = maxi(1, int(pips.get_meta("pip_count", 1)))
        var active_pips: int = clampi(ceili(maxf(urgency, pressure) * float(pip_count)), 0, pip_count)
        if boss and health_ratio <= 0.66:
            active_pips = maxi(active_pips, 2)
        if boss and health_ratio <= 0.33:
            active_pips = maxi(active_pips, 3)
        for child in pips.get_children():
            if not child.has_meta("pip_index"):
                continue
            var pip := child as Node3D
            if pip == null:
                continue
            var pip_index := int(pip.get_meta("pip_index"))
            pip.visible = pip_index < active_pips
            if pip.visible:
                pip.scale = Vector3.ONE * (1.0 + sin(time * 5.6 + float(pip_index) * 0.7 + float(id % 7)) * 0.045)

func _add_void_threat_silhouette(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite_trait: String) -> void:
    if model.get_node_or_null("VoidThreatSilhouetteRig") != null:
        return
    var rig := Node3D.new()
    rig.name = "VoidThreatSilhouetteRig"
    rig.set_meta("kind", kind)
    rig.set_meta("boss", boss)
    rig.set_meta("elite_trait", elite_trait)
    rig.set_meta("threat_signature", _void_threat_signature(kind, boss, elite_trait))
    model.add_child(rig)

    var threat_color := DANGER_RED if boss else _elite_trait_color(elite_trait)
    if not boss and elite_trait == "":
        threat_color = color.lightened(0.24)
    var hot := _mat(kind + "_void_threat_hot_" + elite_trait, Color(threat_color.lightened(0.12).r, threat_color.lightened(0.12).g, threat_color.lightened(0.12).b, 0.52 if boss else 0.42), 1.12, true, true)
    var soft := _mat(kind + "_void_threat_soft_" + elite_trait, Color(threat_color.r, threat_color.g, threat_color.b, 0.26 if boss else 0.22), 0.88, true, true)
    var gold := _mat(kind + "_void_threat_gold_" + elite_trait, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.36), 0.76, true, true)
    var shell := _mat(kind + "_void_threat_shell_" + elite_trait, Color(color.darkened(0.34).r, color.darkened(0.34).g, color.darkened(0.34).b, 0.46), 0.12, true, true)

    var ground := Node3D.new()
    ground.name = "VoidThreatGroundSigil"
    rig.add_child(ground)
    var ground_radius := radius * (2.42 if boss else 1.72)
    _add_cylinder_segments(ground, ground_radius, 0.012, 8 if boss else 6, soft, Vector3(0, 0.062, 0), Vector3(0, 22.5 if boss else 30.0, 0))
    _add_cylinder_segments(ground, ground_radius * 0.62, 0.010, 6, gold, Vector3(0, 0.078, 0), Vector3(0, 30, 0))

    var spines := Node3D.new()
    spines.name = "VoidThreatBackSpines"
    rig.add_child(spines)
    var spine_count := 5 if boss else 3
    for i in range(spine_count):
        var t := -0.5 + float(i) / maxf(1.0, float(spine_count - 1))
        var side := -1.0 if i % 2 == 0 else 1.0
        var spine_pos := Vector3(side * radius * (0.64 + abs(t) * 0.36), height * (0.90 + abs(t) * 0.16), -radius * (0.30 + abs(t) * 0.38))
        _add_box(spines, Vector3(radius * 0.12, radius * 0.20, radius * (0.78 if boss else 0.50)), shell, spine_pos, Vector3(0, side * (28.0 + abs(t) * 18.0), side * 30.0))

    var tell := Node3D.new()
    tell.name = "VoidThreatAttackTell"
    rig.add_child(tell)
    var y := 0.110
    if boss:
        match kind:
            "boss_cho":
                var maw := _add_cylinder_segments(tell, radius * 1.20, 0.014, 8, hot, Vector3(0, y, radius * 0.72), Vector3(0, 22.5, 0))
                maw.name = "VoidThreatBossChoMaw"
                for side in [-1.0, 1.0]:
                    _add_tapered_cylinder(tell, radius * 0.14, radius * 0.022, radius * 0.84, 8, gold, Vector3(side * radius * 0.42, y + 0.040, radius * 1.04), Vector3(62, 0, side * 20.0))
            "boss_velkoz":
                var fan := Node3D.new()
                fan.name = "VoidThreatBossVelkozFan"
                tell.add_child(fan)
                for beam in range(5):
                    var offset := float(beam) - 2.0
                    _add_box(fan, Vector3(radius * 0.12, 0.014, radius * 2.34), hot, Vector3(offset * radius * 0.22, y + 0.032, radius * 0.86), Vector3(0, offset * 9.0, 0))
            "boss_reksai":
                var lane := _add_box(tell, Vector3(radius * 0.34, 0.016, radius * 3.16), hot, Vector3(0, y + 0.026, radius * 1.18))
                lane.name = "VoidThreatBossReksaiLane"
                for tooth in range(4):
                    var offset := -0.5 + float(tooth) / 3.0
                    _add_tapered_cylinder(tell, radius * 0.12, radius * 0.018, radius * 0.62, 6, gold, Vector3(offset * radius * 0.82, y + 0.060, radius * (0.42 + float(tooth) * 0.38)), Vector3(72, 0, offset * 18.0))
            "boss_belveth":
                var wings := Node3D.new()
                wings.name = "VoidThreatBossBelvethWings"
                tell.add_child(wings)
                for side in [-1.0, 1.0]:
                    _add_box(wings, Vector3(radius * 0.16, 0.014, radius * 1.92), hot, Vector3(side * radius * 0.72, y + 0.034, radius * 0.30), Vector3(0, side * 16.0, side * 46.0))
                    _add_box(wings, Vector3(radius * 0.10, 0.012, radius * 1.20), gold, Vector3(side * radius * 1.08, y + 0.054, -radius * 0.10), Vector3(0, side * -18.0, side * 38.0))
            _:
                var boss_mark := _add_cylinder_segments(tell, radius * 0.92, 0.014, 6, hot, Vector3(0, y + 0.030, radius * 0.20), Vector3(0, 30, 0))
                boss_mark.name = "VoidThreatBossGeneric"
    else:
        var trait_node := Node3D.new()
        trait_node.name = "VoidThreatEliteTraitMotif"
        trait_node.set_meta("elite_trait", elite_trait)
        tell.add_child(trait_node)
        match elite_trait:
            "frenzy":
                for slash in range(3):
                    var offset := float(slash) - 1.0
                    _add_box(trait_node, Vector3(radius * 0.10, 0.014, radius * 0.96), hot, Vector3(offset * radius * 0.20, y + 0.034, radius * 0.28), Vector3(0, offset * 18.0, offset * 20.0))
            "bulwark":
                _add_cylinder_segments(trait_node, radius * 0.72, 0.014, 6, hot, Vector3(0, y + 0.030, radius * 0.10), Vector3(0, 30, 0))
                _add_box(trait_node, Vector3(radius * 1.02, 0.014, radius * 0.12), gold, Vector3(0, y + 0.052, radius * 0.10))
            "splitter":
                for shard in range(4):
                    var angle := TAU * float(shard) / 4.0
                    _add_sphere(trait_node, radius * 0.095, hot, Vector3(cos(angle) * radius * 0.46, y + 0.048, sin(angle) * radius * 0.38 + radius * 0.12))
                _add_sphere(trait_node, radius * 0.080, gold, Vector3(0, y + 0.070, radius * 0.12))
            "treasure":
                _add_cylinder_segments(trait_node, radius * 0.44, 0.036, 6, hot, Vector3(0, y + 0.030, radius * 0.10), Vector3(0, 30, 0))
                _add_cylinder_segments(trait_node, radius * 0.24, 0.014, 6, _mat("void_threat_treasure_core", Color(1.0, 0.92, 0.42, 0.78), 1.08, true, true), Vector3(0, y + 0.072, radius * 0.10), Vector3(0, 30, 0))
            _:
                _add_box(trait_node, Vector3(radius * 0.82, 0.014, radius * 0.10), hot, Vector3(0, y + 0.034, radius * 0.12))
                _add_box(trait_node, Vector3(radius * 0.10, 0.014, radius * 0.82), hot, Vector3(0, y + 0.036, radius * 0.12))

func _void_threat_signature(kind: String, boss: bool, elite_trait: String) -> String:
    if not boss:
        return "elite_" + (elite_trait if elite_trait != "" else "void")
    match kind:
        "boss_cho":
            return "rupture_maw"
        "boss_velkoz":
            return "laser_fan"
        "boss_reksai":
            return "burrow_lane"
        "boss_belveth":
            return "wing_sweep"
        _:
            return "boss_void"

func _add_elite_boss_crest(model: Node3D, kind: String, radius: float, height: float, boss: bool) -> void:
    var crest := Node3D.new()
    crest.name = "EliteBossCrest"
    crest.position = Vector3(0, height * (1.18 if boss else 0.98), 0)
    model.add_child(crest)
    var danger := DANGER_RED if boss else Color(0.92, 0.54, 1.0)
    var core := Color(1.0, 0.76, 0.24) if boss else Color(0.96, 0.76, 1.0)
    var ring_mat := _mat(kind + "_crest_ring", Color(danger.r, danger.g, danger.b, 0.42), 1.10, true, true)
    var core_mat := _mat(kind + "_crest_core", Color(core.r, core.g, core.b, 0.58), 1.20, true, true)
    var dark_mat := _mat(kind + "_crest_dark", Color(0.03, 0.00, 0.05, 0.50), 0.18, true, true)
    var outer_radius := radius * (1.00 if boss else 0.76)
    var inner_radius := radius * (0.54 if boss else 0.42)
    _add_cylinder_segments(crest, outer_radius, 0.018, 8 if boss else 6, ring_mat, Vector3.ZERO, Vector3(0, 22.5 if boss else 30.0, 0))
    _add_cylinder_segments(crest, inner_radius, 0.014, 24, core_mat, Vector3(0, 0.030, 0))
    _add_cylinder_segments(crest, radius * (0.24 if boss else 0.18), 0.020, 6, dark_mat, Vector3(0, 0.055, 0), Vector3(0, 30, 0))
    var spoke_count := 8 if boss else 6
    for i in range(spoke_count):
        var angle := TAU * float(i) / float(spoke_count)
        var long_spoke := boss or i % 2 == 0
        var spoke_len := radius * (0.58 if long_spoke else 0.34)
        var pos := Vector3(cos(angle) * outer_radius * 0.72, 0.070, sin(angle) * outer_radius * 0.72)
        _add_box(crest, Vector3(radius * 0.090, 0.014, spoke_len), core_mat, pos, Vector3(0, -rad_to_deg(angle), 0))

func _add_void_priority_emblem(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite_trait: String) -> void:
    var emblem := Node3D.new()
    emblem.name = "VoidPriorityEmblem"
    emblem.set_meta("kind", kind)
    emblem.set_meta("boss", boss)
    emblem.set_meta("elite_trait", elite_trait)
    emblem.position = Vector3(0, height * (1.34 if boss else 1.16), radius * (0.04 if boss else 0.12))
    model.add_child(emblem)

    var base_color := DANGER_RED if boss else _elite_trait_color(elite_trait)
    if not boss and elite_trait == "":
        base_color = color.lightened(0.24)
    var hot_color := base_color.lightened(0.16)
    var dark_mat := _mat(kind + "_priority_emblem_dark", Color(0.02, 0.00, 0.05, 0.58), 0.08, true, true)
    var ring_mat := _mat(kind + "_priority_emblem_ring", Color(base_color.r, base_color.g, base_color.b, 0.48 if boss else 0.36), 1.10 if boss else 0.88, true, true)
    var trim_mat := _mat(kind + "_priority_emblem_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.58 if boss else 0.38), 0.92, true, true)
    var outer_radius := radius * (0.92 if boss else 0.62)
    var inner_radius := radius * (0.64 if boss else 0.42)
    _add_cylinder_segments(emblem, outer_radius, 0.014, 8 if boss else 6, ring_mat, Vector3.ZERO, Vector3(0, 22.5 if boss else 30.0, 0))
    _add_cylinder_segments(emblem, inner_radius, 0.012, 24, dark_mat, Vector3(0, 0.022, 0))
    _add_cylinder_segments(emblem, radius * (0.74 if boss else 0.48), 0.010, 6, trim_mat, Vector3(0, 0.040, 0), Vector3(0, 30, 0))

    if boss and _asset_available(VOID_BOSS_EMBLEM_ATLAS_TEXTURE_PATH):
        var uv_scale := Vector3(1.0 / float(VOID_BOSS_EMBLEM_ATLAS_COLS), 1.0 / float(VOID_BOSS_EMBLEM_ATLAS_ROWS), 1.0)
        var icon_mat := _vfx_decal_mat(kind + "_boss_identity_icon", VOID_BOSS_EMBLEM_ATLAS_TEXTURE_PATH, Color(1.0, 1.0, 1.0, 0.78), 1.18, uv_scale, _void_boss_emblem_atlas_offset(kind))
        var icon := _add_textured_plane(emblem, Vector2(radius * 1.42, radius * 1.42), icon_mat, Vector3(0, 0.060, 0))
        icon.name = "BossIdentityIconTexture"
    elif boss:
        var fallback_mat := _mat(kind + "_boss_identity_fallback", Color(hot_color.r, hot_color.g, hot_color.b, 0.62), 1.12, true, true)
        _add_cylinder_segments(emblem, radius * 0.34, 0.020, 5, fallback_mat, Vector3(0, 0.074, 0), Vector3(0, 18, 0))
        for side in [-1.0, 1.0]:
            _add_box(emblem, Vector3(radius * 0.090, 0.014, radius * 0.52), fallback_mat, Vector3(side * radius * 0.28, 0.092, radius * 0.16), Vector3(0, side * 24.0, side * 18.0))
    else:
        _add_elite_priority_symbol(emblem, elite_trait, radius, hot_color)

func _add_elite_priority_symbol(parent: Node3D, elite_trait: String, radius: float, color: Color) -> void:
    var symbol := Node3D.new()
    symbol.name = "ElitePriorityIcon"
    parent.add_child(symbol)
    var hot := _mat("elite_priority_hot_" + elite_trait, Color(color.r, color.g, color.b, 0.72), 1.12, true, true)
    match elite_trait:
        "frenzy":
            for i in range(3):
                var offset := float(i) - 1.0
                _add_box(symbol, Vector3(radius * 0.080, 0.014, radius * 0.52), hot, Vector3(offset * radius * 0.14, 0.074, 0), Vector3(0, offset * 20.0, offset * 18.0))
        "bulwark":
            _add_cylinder_segments(symbol, radius * 0.24, 0.014, 6, hot, Vector3(0, 0.074, 0), Vector3(0, 30, 0))
            _add_box(symbol, Vector3(radius * 0.46, 0.014, radius * 0.080), hot, Vector3(0, 0.094, radius * 0.02))
        "splitter":
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_sphere(symbol, radius * 0.072, hot, Vector3(cos(angle) * radius * 0.26, 0.084, sin(angle) * radius * 0.26))
            _add_sphere(symbol, radius * 0.066, hot, Vector3(0, 0.102, 0))
        "treasure":
            _add_cylinder_segments(symbol, radius * 0.21, 0.028, 6, hot, Vector3(0, 0.078, 0), Vector3(0, 30, 0))
            _add_cylinder_segments(symbol, radius * 0.12, 0.012, 6, _mat("elite_priority_treasure_core", Color(1.0, 0.92, 0.42, 0.86), 1.08, true, true), Vector3(0, 0.108, 0), Vector3(0, 30, 0))
        _:
            _add_box(symbol, Vector3(radius * 0.46, 0.014, radius * 0.080), hot, Vector3(0, 0.080, 0))
            _add_box(symbol, Vector3(radius * 0.080, 0.014, radius * 0.46), hot, Vector3(0, 0.082, 0))

func _add_elite_trait_marker(model: Node3D, elite_trait: String, radius: float, height: float) -> void:
    var marker := Node3D.new()
    marker.name = "EliteTraitMarker"
    marker.position = Vector3(0, height * 1.10, radius * 0.20)
    model.add_child(marker)
    var color := _elite_trait_color(elite_trait)
    var hot := _mat("elite_trait_hot_" + elite_trait, Color(color.r, color.g, color.b, 0.72), 1.16, true, true)
    var soft := _mat("elite_trait_soft_" + elite_trait, Color(color.r, color.g, color.b, 0.30), 0.88, true, true)
    var dark := _mat("elite_trait_dark_" + elite_trait, Color(0.02, 0.00, 0.04, 0.44), 0.06, true, true)
    _add_cylinder_segments(marker, radius * 0.48, 0.012, 6, soft, Vector3.ZERO, Vector3(0, 30, 0))
    _add_cylinder_segments(marker, radius * 0.30, 0.010, 24, dark, Vector3(0, 0.026, 0))
    match elite_trait:
        "frenzy":
            for i in range(3):
                var offset := float(i) - 1.0
                _add_box(marker, Vector3(radius * 0.075, 0.014, radius * 0.54), hot, Vector3(offset * radius * 0.13, 0.048, 0), Vector3(0, offset * 18.0, offset * 18.0))
        "bulwark":
            _add_cylinder_segments(marker, radius * 0.24, 0.014, 6, hot, Vector3(0, 0.050, 0), Vector3(0, 30, 0))
            _add_box(marker, Vector3(radius * 0.44, 0.014, radius * 0.075), hot, Vector3(0, 0.072, radius * 0.02))
        "splitter":
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_sphere(marker, radius * 0.080, hot, Vector3(cos(angle) * radius * 0.27, 0.066, sin(angle) * radius * 0.27))
            _add_sphere(marker, radius * 0.070, hot, Vector3(0, 0.082, 0))
        "treasure":
            _add_cylinder_segments(marker, radius * 0.22, 0.030, 6, hot, Vector3(0, 0.054, 0), Vector3(0, 30, 0))
            _add_cylinder_segments(marker, radius * 0.13, 0.012, 6, _mat("elite_trait_treasure_stamp", Color(1.0, 0.92, 0.42, 0.82), 1.0, true, true), Vector3(0, 0.082, 0), Vector3(0, 30, 0))
        _:
            _add_box(marker, Vector3(radius * 0.50, 0.012, radius * 0.080), hot, Vector3(0, 0.050, 0))
            _add_box(marker, Vector3(radius * 0.080, 0.012, radius * 0.50), hot, Vector3(0, 0.052, 0))

func _add_elite_trait_telegraph(model: Node3D, elite_trait: String, kind: String, radius: float) -> void:
    var telegraph := Node3D.new()
    telegraph.name = "EliteTraitTelegraphRig"
    telegraph.set_meta("elite_trait", elite_trait)
    telegraph.set_meta("kind", kind)
    model.add_child(telegraph)

    var color := _elite_trait_color(elite_trait)
    var soft := _mat("elite_trait_telegraph_soft_" + elite_trait, Color(color.r, color.g, color.b, 0.26), 0.82, true, true)
    var hot := _mat("elite_trait_telegraph_hot_" + elite_trait, Color(color.lightened(0.12).r, color.lightened(0.12).g, color.lightened(0.12).b, 0.48), 1.10, true, true)
    var dark := _mat("elite_trait_telegraph_dark_" + elite_trait, Color(0.020, 0.006, 0.040, 0.40), 0.08, true, true)
    var gold := _mat("elite_trait_telegraph_gold_" + elite_trait, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42), 0.78, true, true)
    var outer_radius := radius * 1.82
    var inner_radius := radius * 1.02

    var core := Node3D.new()
    core.name = "EliteTraitTelegraphCore"
    telegraph.add_child(core)
    _add_cylinder_segments(core, outer_radius, 0.010, 6, soft, Vector3(0, 0.070, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(core, inner_radius, 0.008, 24, dark, Vector3(0, 0.086, 0))
    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        var pip := _add_sphere(core, radius * 0.070, hot if i % 2 == 0 else gold, Vector3(cos(angle) * outer_radius * 0.68, 0.112, sin(angle) * outer_radius * 0.68))
        pip.name = "EliteTraitTelegraphPip%d" % i

    var pattern := Node3D.new()
    pattern.name = "EliteTraitTelegraphPattern"
    pattern.set_meta("elite_trait", elite_trait)
    telegraph.add_child(pattern)
    match elite_trait:
        "frenzy":
            var claws := Node3D.new()
            claws.name = "EliteTraitFrenzyClaws"
            pattern.add_child(claws)
            for i in range(3):
                var offset := float(i) - 1.0
                _add_box(claws, Vector3(radius * 0.10, 0.012, radius * 0.92), hot, Vector3(offset * radius * 0.18, 0.126, radius * 0.18), Vector3(0, offset * 18.0, offset * 18.0))
        "bulwark":
            var shield := Node3D.new()
            shield.name = "EliteTraitBulwarkShield"
            pattern.add_child(shield)
            _add_cylinder_segments(shield, radius * 0.66, 0.012, 6, hot, Vector3(0, 0.128, 0), Vector3(0, 30, 0))
            _add_box(shield, Vector3(radius * 1.04, 0.012, radius * 0.11), gold, Vector3(0, 0.150, radius * 0.04))
        "splitter":
            var seeds := Node3D.new()
            seeds.name = "EliteTraitSplitterSeeds"
            pattern.add_child(seeds)
            for i in range(4):
                var seed_angle := TAU * float(i) / 4.0
                _add_sphere(seeds, radius * 0.105, hot, Vector3(cos(seed_angle) * radius * 0.48, 0.136, sin(seed_angle) * radius * 0.48))
            _add_sphere(seeds, radius * 0.078, gold, Vector3(0, 0.164, 0))
        "treasure":
            var cache := Node3D.new()
            cache.name = "EliteTraitTreasureCache"
            pattern.add_child(cache)
            _add_cylinder_segments(cache, radius * 0.46, 0.032, 6, gold, Vector3(0, 0.128, 0), Vector3(0, 30, 0))
            _add_cylinder_segments(cache, radius * 0.25, 0.012, 6, hot, Vector3(0, 0.168, 0), Vector3(0, 30, 0))
            _add_box(cache, Vector3(radius * 0.82, 0.012, radius * 0.080), hot, Vector3(0, 0.190, 0))
        _:
            _add_box(pattern, Vector3(radius * 0.92, 0.012, radius * 0.090), hot, Vector3(0, 0.126, 0))
            _add_box(pattern, Vector3(radius * 0.090, 0.012, radius * 0.92), hot, Vector3(0, 0.128, 0))
    _add_elite_trait_intent_profile(telegraph, elite_trait, radius, soft, hot, dark, gold)
    _add_elite_trait_behavior_state_rig(telegraph, elite_trait, radius, soft, hot, dark, gold)
    _add_elite_trait_tactical_readout(telegraph, elite_trait, radius)

func _elite_trait_intent_type(elite_trait: String) -> String:
    match elite_trait:
        "frenzy":
            return "rush_pressure"
        "bulwark":
            return "shield_breakpoint"
        "splitter":
            return "split_after_death"
        "treasure":
            return "high_value_reward"
        _:
            return "generic"

func _elite_trait_intent_detail_name(elite_trait: String) -> String:
    match elite_trait:
        "frenzy":
            return "EliteTraitIntentFrenzyRush"
        "bulwark":
            return "EliteTraitIntentBulwarkBreak"
        "splitter":
            return "EliteTraitIntentSplitterBloom"
        "treasure":
            return "EliteTraitIntentTreasureReward"
        _:
            return "EliteTraitIntentGeneric"

func _elite_trait_behavior_state_name(elite_trait: String) -> String:
    match elite_trait:
        "frenzy":
            return "EliteTraitStateFrenzyDash"
        "bulwark":
            return "EliteTraitStateBulwarkBreak"
        "splitter":
            return "EliteTraitStateSplitterBloom"
        "treasure":
            return "EliteTraitStateTreasureFlee"
        _:
            return "EliteTraitStateGeneric"

func _elite_trait_tactical_type(elite_trait: String) -> String:
    match elite_trait:
        "frenzy":
            return "rush_lane"
        "bulwark":
            return "break_window"
        "splitter":
            return "bloom_radius"
        "treasure":
            return "flee_vector"
        _:
            return "generic"

func _elite_trait_tactical_detail_name(elite_trait: String) -> String:
    match elite_trait:
        "frenzy":
            return "EliteTraitTacticalFrenzyRushLane"
        "bulwark":
            return "EliteTraitTacticalBulwarkBreakWindow"
        "splitter":
            return "EliteTraitTacticalSplitterBloomRadius"
        "treasure":
            return "EliteTraitTacticalTreasureFleeVector"
        _:
            return "EliteTraitTacticalGeneric"

func _elite_trait_tactical_pocket_count(elite_trait: String) -> int:
    match elite_trait:
        "frenzy":
            return 2
        "bulwark":
            return 3
        "splitter":
            return 4
        "treasure":
            return 3
        _:
            return 2

func _add_elite_trait_tactical_readout(telegraph: Node3D, elite_trait: String, radius: float) -> void:
    var readout := Node3D.new()
    readout.name = "EliteTraitTacticalReadout"
    readout.set_meta("elite_trait", elite_trait)
    readout.set_meta("tactical_type", _elite_trait_tactical_type(elite_trait))
    readout.set_meta("detail_node", _elite_trait_tactical_detail_name(elite_trait))
    readout.set_meta("safe_pocket_count", _elite_trait_tactical_pocket_count(elite_trait))
    readout.set_meta("combat_visual_channel", "elite_trait_tactical_readability")
    readout.set_meta("material_grade", "low_glare_elite_trait_tactical_readout")
    readout.set_meta("elite_tactical_readout_layer", true)
    telegraph.add_child(readout)

    var color := _elite_trait_color(elite_trait)
    var shadow := _mat("elite_tactical_shadow_" + elite_trait, Color(0.0, 0.0, 0.0, 0.26), 0.0, true, true)
    var safe := _mat("elite_tactical_safe_" + elite_trait, Color(0.020, 0.080, 0.090, 0.22), 0.0, true, true)
    var trait_mat := _mat("elite_tactical_trait_" + elite_trait, Color(color.r, color.g, color.b, 0.24), 0.06, true, true)
    var tick := _mat("elite_tactical_tick_" + elite_trait, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.24), 0.04, true, true)

    var base := Node3D.new()
    base.name = "EliteTraitTacticalBase"
    base.set_meta("combat_visual_channel", "elite_trait_tactical_readability")
    readout.add_child(base)
    _add_cylinder_segments(base, radius * 1.72, 0.008, 8, shadow, Vector3(0, 0.056, 0), Vector3(0, 22.5, 0))

    var pockets := Node3D.new()
    pockets.name = "EliteTraitTacticalSafePockets"
    pockets.set_meta("safe_pocket_count", _elite_trait_tactical_pocket_count(elite_trait))
    pockets.set_meta("combat_visual_channel", "elite_trait_tactical_readability")
    readout.add_child(pockets)

    var detail := Node3D.new()
    detail.name = _elite_trait_tactical_detail_name(elite_trait)
    detail.set_meta("elite_trait", elite_trait)
    detail.set_meta("base_y", 0.204)
    detail.set_meta("combat_visual_channel", "elite_trait_tactical_readability")
    readout.add_child(detail)

    match elite_trait:
        "frenzy":
            for side in [-1.0, 1.0]:
                var pocket := _add_box(pockets, Vector3(radius * 0.24, 0.010, radius * 1.18), safe, Vector3(side * radius * 0.42, 0.084, radius * 0.28), Vector3(0, side * 8.0, 0))
                pocket.name = "EliteTraitSafePocket_" + ("Left" if side < 0.0 else "Right")
            _add_box(detail, Vector3(radius * 0.16, 0.010, radius * 1.70), trait_mat, Vector3(0, 0.204, radius * 0.58))
            _add_tapered_cylinder(detail, radius * 0.070, radius * 0.012, radius * 0.46, 6, tick, Vector3(0, 0.228, radius * 1.34), Vector3(72, 0, 0))
        "bulwark":
            for i in range(3):
                var offset := float(i) - 1.0
                var pocket := _add_box(pockets, Vector3(radius * 0.32, 0.010, radius * 0.42), safe, Vector3(offset * radius * 0.34, 0.084, radius * 0.46))
                pocket.name = "EliteTraitSafePocket_%d" % i
            _add_cylinder_segments(detail, radius * 0.62, 0.008, 6, trait_mat, Vector3(0, 0.204, radius * 0.12), Vector3(0, 30, 0))
            _add_box(detail, Vector3(radius * 1.04, 0.010, radius * 0.060), tick, Vector3(0, 0.228, radius * 0.12))
        "splitter":
            for i in range(4):
                var angle := TAU * float(i) / 4.0 + PI * 0.25
                var pocket := _add_box(pockets, Vector3(radius * 0.28, 0.010, radius * 0.54), safe, Vector3(cos(angle) * radius * 0.78, 0.084, sin(angle) * radius * 0.60), Vector3(0, -rad_to_deg(angle), 0))
                pocket.name = "EliteTraitSafePocket_%d" % i
            _add_cylinder_segments(detail, radius * 0.92, 0.008, 8, trait_mat, Vector3(0, 0.204, 0), Vector3(0, 22.5, 0))
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_sphere(detail, radius * 0.040, tick, Vector3(cos(angle) * radius * 0.62, 0.228, sin(angle) * radius * 0.48))
        "treasure":
            for i in range(3):
                var step := float(i)
                var pocket := _add_box(pockets, Vector3(radius * (0.44 - step * 0.06), 0.010, radius * 0.18), safe, Vector3(0, 0.084, radius * (0.22 + step * 0.34)))
                pocket.name = "EliteTraitSafePocket_%d" % i
            _add_box(detail, Vector3(radius * 0.18, 0.010, radius * 1.34), trait_mat, Vector3(0, 0.204, radius * 0.60))
            _add_box(detail, Vector3(radius * 0.62, 0.010, radius * 0.070), tick, Vector3(0, 0.226, radius * 1.18))
        _:
            for i in range(2):
                var side := -1.0 if i == 0 else 1.0
                var pocket := _add_box(pockets, Vector3(radius * 0.30, 0.010, radius * 0.48), safe, Vector3(side * radius * 0.44, 0.084, 0))
                pocket.name = "EliteTraitSafePocket_%d" % i
            _add_box(detail, Vector3(radius * 0.80, 0.010, radius * 0.060), trait_mat, Vector3(0, 0.204, 0))

func _add_elite_trait_intent_profile(telegraph: Node3D, elite_trait: String, radius: float, soft: Material, hot: Material, dark: Material, gold: Material) -> void:
    var profile := Node3D.new()
    profile.name = "EliteTraitIntentProfile"
    profile.set_meta("elite_trait", elite_trait)
    profile.set_meta("intent_type", _elite_trait_intent_type(elite_trait))
    profile.set_meta("detail_node", _elite_trait_intent_detail_name(elite_trait))
    telegraph.add_child(profile)

    var y := 0.206
    var frame := _add_cylinder_segments(profile, radius * 0.54, 0.010, 6, soft, Vector3(0, y, -radius * 0.76), Vector3(0, 30, 0))
    frame.name = "EliteTraitIntentFrame"
    var pip := _add_sphere(profile, radius * 0.050, hot, Vector3(0, y + 0.034, -radius * 0.76))
    pip.name = "EliteTraitIntentPip"

    var detail_name := _elite_trait_intent_detail_name(elite_trait)
    var detail: Node3D = null
    match elite_trait:
        "frenzy":
            detail = _add_box(profile, Vector3(radius * 0.080, 0.012, radius * 0.68), hot, Vector3(0, y + 0.044, -radius * 0.52), Vector3(0, 0, 0))
            _add_box(profile, Vector3(radius * 0.060, 0.010, radius * 0.48), hot, Vector3(-radius * 0.18, y + 0.038, -radius * 0.60), Vector3(0, -16, -18))
            _add_box(profile, Vector3(radius * 0.060, 0.010, radius * 0.48), hot, Vector3(radius * 0.18, y + 0.038, -radius * 0.60), Vector3(0, 16, 18))
        "bulwark":
            detail = _add_cylinder_segments(profile, radius * 0.30, 0.010, 6, hot, Vector3(0, y + 0.038, -radius * 0.76), Vector3(0, 30, 0))
            _add_box(profile, Vector3(radius * 0.56, 0.010, radius * 0.070), gold, Vector3(0, y + 0.064, -radius * 0.72))
        "splitter":
            detail = _add_sphere(profile, radius * 0.082, hot, Vector3(0, y + 0.044, -radius * 0.76))
            for side in [-1.0, 1.0]:
                _add_sphere(profile, radius * 0.052, soft, Vector3(side * radius * 0.26, y + 0.030, -radius * 0.64))
        "treasure":
            detail = _add_cylinder_segments(profile, radius * 0.22, 0.018, 6, gold, Vector3(0, y + 0.034, -radius * 0.76), Vector3(0, 30, 0))
            _add_box(profile, Vector3(radius * 0.44, 0.010, radius * 0.060), hot, Vector3(0, y + 0.060, -radius * 0.76))
            _add_sphere(profile, radius * 0.044, gold, Vector3(0, y + 0.084, -radius * 0.76))
        _:
            detail = _add_cylinder_segments(profile, radius * 0.28, 0.010, 6, hot, Vector3(0, y + 0.038, -radius * 0.76), Vector3(0, 30, 0))
            _add_box(profile, Vector3(radius * 0.42, 0.010, radius * 0.060), dark, Vector3(0, y + 0.064, -radius * 0.76))
    if detail != null:
        detail.name = detail_name
        detail.set_meta("base_y", detail.position.y)

func _add_elite_trait_behavior_state_rig(telegraph: Node3D, elite_trait: String, radius: float, soft: Material, hot: Material, dark: Material, gold: Material) -> void:
    var rig := Node3D.new()
    rig.name = "EliteTraitBehaviorStateRig"
    rig.visible = false
    rig.set_meta("elite_trait", elite_trait)
    rig.set_meta("state_node", _elite_trait_behavior_state_name(elite_trait))
    telegraph.add_child(rig)

    var halo := _add_cylinder_segments(rig, radius * 0.72, 0.010, 6, soft, Vector3(0, 0.244, radius * 0.84), Vector3(0, 30, 0))
    halo.name = "EliteTraitStateHalo"
    var meter := _add_box(rig, Vector3(radius * 0.72, 0.010, radius * 0.055), hot, Vector3(0, 0.272, radius * 1.12))
    meter.name = "EliteTraitStateMeter"

    match elite_trait:
        "frenzy":
            var dash := Node3D.new()
            dash.name = "EliteTraitStateFrenzyDash"
            dash.visible = false
            rig.add_child(dash)
            _add_box(dash, Vector3(radius * 0.12, 0.012, radius * 1.18), hot, Vector3(0, 0.302, radius * 0.70))
            for side in [-1.0, 1.0]:
                _add_box(dash, Vector3(radius * 0.080, 0.010, radius * 0.82), soft, Vector3(side * radius * 0.22, 0.290, radius * 0.52), Vector3(0, side * 18.0, side * 22.0))
                _add_tapered_cylinder(dash, radius * 0.052, radius * 0.008, radius * 0.42, 6, gold, Vector3(side * radius * 0.34, 0.318, radius * 1.03), Vector3(70, 0, side * 18.0))
        "bulwark":
            var guard := Node3D.new()
            guard.name = "EliteTraitStateBulwarkGuardPips"
            guard.visible = false
            rig.add_child(guard)
            for i in range(3):
                var pip := _add_cylinder_segments(guard, radius * 0.090, 0.022, 6, gold if i == 0 else soft, Vector3((float(i) - 1.0) * radius * 0.24, 0.308, radius * 0.92), Vector3(0, 30, 0))
                pip.name = "BulwarkGuardPip%d" % i
                pip.set_meta("pip_index", i)
            var crack := Node3D.new()
            crack.name = "EliteTraitStateBulwarkBreak"
            crack.visible = false
            rig.add_child(crack)
            _add_cylinder_segments(crack, radius * 0.38, 0.010, 6, soft, Vector3(0, 0.302, radius * 0.84), Vector3(0, 30, 0))
            _add_box(crack, Vector3(radius * 0.72, 0.012, radius * 0.060), hot, Vector3(0, 0.328, radius * 0.84), Vector3(0, 20, 0))
            _add_box(crack, Vector3(radius * 0.060, 0.012, radius * 0.60), hot, Vector3(radius * 0.10, 0.344, radius * 0.84), Vector3(0, -18, 0))
        "splitter":
            var bloom := Node3D.new()
            bloom.name = "EliteTraitStateSplitterBloom"
            bloom.visible = false
            rig.add_child(bloom)
            _add_sphere(bloom, radius * 0.105, hot, Vector3(0, 0.322, radius * 0.86))
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(bloom, radius * 0.060, soft, Vector3(cos(angle) * radius * 0.42, 0.300, radius * 0.86 + sin(angle) * radius * 0.30))
                _add_box(bloom, Vector3(radius * 0.050, 0.010, radius * 0.38), gold if i % 2 == 0 else hot, Vector3(cos(angle) * radius * 0.26, 0.334, radius * 0.86 + sin(angle) * radius * 0.18), Vector3(0, -rad_to_deg(angle), 0))
        "treasure":
            var flee := Node3D.new()
            flee.name = "EliteTraitStateTreasureFlee"
            flee.visible = false
            rig.add_child(flee)
            _add_cylinder_segments(flee, radius * 0.26, 0.020, 6, gold, Vector3(0, 0.308, radius * 0.86), Vector3(0, 30, 0))
            for i in range(3):
                var step := float(i)
                _add_box(flee, Vector3(radius * (0.32 - step * 0.04), 0.010, radius * 0.070), hot if i == 0 else gold, Vector3(0, 0.332 + step * 0.012, radius * (0.54 + step * 0.24)), Vector3(0, 0, 0))
                _add_box(flee, Vector3(radius * 0.070, 0.010, radius * (0.24 - step * 0.02)), hot, Vector3(-radius * 0.18, 0.324 + step * 0.012, radius * (0.58 + step * 0.24)), Vector3(0, -24, 0))
                _add_box(flee, Vector3(radius * 0.070, 0.010, radius * (0.24 - step * 0.02)), hot, Vector3(radius * 0.18, 0.324 + step * 0.012, radius * (0.58 + step * 0.24)), Vector3(0, 24, 0))
        _:
            var generic := Node3D.new()
            generic.name = "EliteTraitStateGeneric"
            generic.visible = false
            rig.add_child(generic)
            _add_cylinder_segments(generic, radius * 0.32, 0.010, 6, hot, Vector3(0, 0.310, radius * 0.86), Vector3(0, 30, 0))
            _add_box(generic, Vector3(radius * 0.54, 0.010, radius * 0.060), dark, Vector3(0, 0.334, radius * 0.86))

func _sync_elite_trait_telegraph(telegraph: Node3D, enemy: Node, kind: String, elite_trait: String, id: int) -> void:
    telegraph.visible = float(enemy.get("health")) > 0.0
    if not telegraph.visible:
        return
    var time := Time.get_ticks_msec() / 1000.0
    var attack_window := 0.86 if kind == "spitter" or kind == "void_eye" or kind == "rift_crystal" or kind == "burrower" else 0.62
    var attack_t := 1.0 - clampf(float(enemy.get("attack_timer")) / attack_window, 0.0, 1.0)
    var dash_t := clampf(float(enemy.get("dash_timer")) / (0.72 if kind != "boss_reksai" else 3.0), 0.0, 1.0)
    var summon_t := 1.0 - clampf(float(enemy.get("summon_timer")) / 1.35, 0.0, 1.0) if kind == "rift_crystal" else 0.0
    var bulwark_break_t := clampf(float(enemy.get("bulwark_break_timer")) / 2.60, 0.0, 1.0)
    var treasure_flee_t := clampf(float(enemy.get("treasure_flee_timer")) / 1.55, 0.0, 1.0)
    var urgency := clampf(maxf(attack_t, maxf(dash_t, summon_t)), 0.0, 1.0)
    match elite_trait:
        "frenzy":
            urgency = maxf(urgency, dash_t)
        "bulwark":
            urgency = maxf(urgency, 1.0 - clampf(float(enemy.get("health")) / maxf(1.0, float(enemy.get("max_health"))), 0.0, 1.0))
            urgency = maxf(urgency, bulwark_break_t)
        "splitter":
            if bool(enemy.get("splitter_spawned")):
                urgency = maxf(urgency, 0.42)
            elif float(enemy.get("health")) <= maxf(1.0, float(enemy.get("max_health"))) * 0.52:
                urgency = maxf(urgency, 0.72)
        "treasure":
            urgency = maxf(urgency, 0.32)
            urgency = maxf(urgency, treasure_flee_t)
        _:
            pass

    var pulse := 1.0 + sin(time * (3.4 + urgency * 3.2) + float(id % 19)) * (0.026 + urgency * 0.060)
    telegraph.rotation.y += 0.010 + urgency * 0.026
    telegraph.scale = Vector3.ONE * (lerpf(0.92, 1.16, urgency) * pulse)
    var core := telegraph.get_node_or_null("EliteTraitTelegraphCore") as Node3D
    if core != null:
        core.rotation.y -= 0.018 + urgency * 0.020
        core.position.y = 0.004 + sin(time * 5.2 + float(id % 11)) * 0.006
    var pattern := telegraph.get_node_or_null("EliteTraitTelegraphPattern") as Node3D
    if pattern != null:
        pattern.rotation.y += 0.030 + urgency * 0.044
        pattern.scale = Vector3.ONE * lerpf(0.86, 1.24, urgency)
        pattern.position.y = sin(time * 6.8 + float(id % 7)) * 0.008
    _sync_elite_trait_intent_profile(telegraph, urgency, time, id)
    _sync_elite_trait_behavior_state_rig(telegraph, enemy, elite_trait, urgency, time, id)
    _sync_elite_trait_tactical_readout(telegraph, enemy, elite_trait, urgency, time, id)

func _sync_elite_trait_intent_profile(telegraph: Node3D, urgency: float, time: float, id: int) -> void:
    var profile := telegraph.get_node_or_null("EliteTraitIntentProfile") as Node3D
    if profile == null:
        return
    profile.visible = true
    profile.rotation.y -= 0.026 + urgency * 0.050
    var pulse := lerpf(0.84, 1.18, urgency) + sin(time * (5.6 + urgency * 4.0) + float(id % 13)) * (0.030 + urgency * 0.050)
    profile.scale = Vector3(pulse, 1.0, pulse)
    var frame := profile.get_node_or_null("EliteTraitIntentFrame") as Node3D
    if frame != null:
        frame.rotation.y += 0.050 + urgency * 0.055
    var pip := profile.get_node_or_null("EliteTraitIntentPip") as Node3D
    if pip != null:
        pip.scale = Vector3.ONE * (0.88 + urgency * 0.42 + sin(time * 8.8 + float(id % 5)) * 0.052)
    var detail_name := str(profile.get_meta("detail_node", ""))
    var detail := profile.get_node_or_null(detail_name) as Node3D
    if detail != null:
        var base_y := float(detail.get_meta("base_y", detail.position.y))
        detail.position.y = base_y + sin(time * 7.4 + float(id % 17)) * 0.012
        detail.scale = Vector3.ONE * (0.90 + urgency * 0.22)

func _sync_elite_trait_tactical_readout(telegraph: Node3D, enemy: Node, elite_trait: String, urgency: float, time: float, id: int) -> void:
    var readout := telegraph.get_node_or_null("EliteTraitTacticalReadout") as Node3D
    if readout == null:
        return
    var health_max := maxf(1.0, float(enemy.get("max_health")))
    var health_ratio := clampf(float(enemy.get("health")) / health_max, 0.0, 1.0)
    var dash_t := clampf(float(enemy.get("dash_timer")) / 0.72, 0.0, 1.0)
    var break_t := clampf(float(enemy.get("bulwark_break_timer")) / 2.60, 0.0, 1.0)
    var treasure_t := clampf(float(enemy.get("treasure_flee_timer")) / 1.55, 0.0, 1.0)
    var split_t := 1.0 - health_ratio
    var tactical_t := urgency
    match elite_trait:
        "frenzy":
            tactical_t = maxf(tactical_t, dash_t)
        "bulwark":
            tactical_t = maxf(tactical_t, break_t)
        "splitter":
            tactical_t = maxf(tactical_t, 0.72 if bool(enemy.get("splitter_spawned")) else (0.62 if health_ratio <= 0.52 else split_t))
        "treasure":
            tactical_t = maxf(tactical_t, treasure_t)
        _:
            pass
    readout.visible = tactical_t > 0.10 or elite_trait == "treasure"
    if not readout.visible:
        return
    readout.set_meta("tactical_urgency", tactical_t)
    readout.rotation.y += 0.010 + tactical_t * 0.026
    var pulse := 0.92 + tactical_t * 0.12 + sin(time * 4.8 + float(id % 23)) * (0.010 + tactical_t * 0.018)
    readout.scale = Vector3(pulse, 1.0, pulse)

    var pockets := readout.get_node_or_null("EliteTraitTacticalSafePockets") as Node3D
    if pockets != null:
        var pocket_index := 0
        for child in pockets.get_children():
            var pocket := child as Node3D
            if pocket == null:
                continue
            pocket.visible = tactical_t < 0.95 or pocket_index % 2 == 0
            pocket.scale = Vector3.ONE * (1.0 + tactical_t * 0.050 + sin(time * 5.6 + float(pocket_index) * 0.9) * 0.018)
            pocket.set_meta("tactical_urgency", tactical_t)
            pocket_index += 1

    var detail_name := str(readout.get_meta("detail_node", ""))
    var detail := readout.get_node_or_null(detail_name) as Node3D
    if detail != null:
        detail.position.y = float(detail.get_meta("base_y", detail.position.y)) + sin(time * 6.4 + float(id % 11)) * 0.008
        detail.scale = Vector3.ONE * (0.90 + tactical_t * 0.16)
        match elite_trait:
            "frenzy":
                detail.position.z = tactical_t * 0.10
            "bulwark":
                detail.rotation.y -= 0.018 + break_t * 0.028
            "splitter":
                detail.rotation.y += 0.026 + split_t * 0.030
            "treasure":
                detail.position.z = -treasure_t * 0.14
            _:
                pass

func _sync_elite_trait_behavior_state_rig(telegraph: Node3D, enemy: Node, elite_trait: String, urgency: float, time: float, id: int) -> void:
    var rig := telegraph.get_node_or_null("EliteTraitBehaviorStateRig") as Node3D
    if rig == null:
        return
    var health_max := maxf(1.0, float(enemy.get("max_health")))
    var health_ratio := clampf(float(enemy.get("health")) / health_max, 0.0, 1.0)
    var dash_t := clampf(float(enemy.get("dash_timer")) / 0.72, 0.0, 1.0)
    var break_t := clampf(float(enemy.get("bulwark_break_timer")) / 2.60, 0.0, 1.0)
    var treasure_t := clampf(float(enemy.get("treasure_flee_timer")) / 1.55, 0.0, 1.0)
    var guard_count := clampi(int(enemy.get("bulwark_guard")), 0, 3)
    var split_ready := bool(enemy.get("splitter_spawned")) or health_ratio <= 0.52

    var frenzy := rig.get_node_or_null("EliteTraitStateFrenzyDash") as Node3D
    var guard := rig.get_node_or_null("EliteTraitStateBulwarkGuardPips") as Node3D
    var break_node := rig.get_node_or_null("EliteTraitStateBulwarkBreak") as Node3D
    var splitter := rig.get_node_or_null("EliteTraitStateSplitterBloom") as Node3D
    var treasure := rig.get_node_or_null("EliteTraitStateTreasureFlee") as Node3D
    var generic := rig.get_node_or_null("EliteTraitStateGeneric") as Node3D

    var active := false
    if frenzy != null:
        frenzy.visible = elite_trait == "frenzy" and dash_t > 0.0
        active = active or frenzy.visible
        if frenzy.visible:
            frenzy.position.z = -0.10 + dash_t * 0.16 + sin(time * 10.0 + float(id % 7)) * 0.020
            frenzy.scale = Vector3.ONE * (0.92 + dash_t * 0.34)
    if guard != null:
        guard.visible = elite_trait == "bulwark" and guard_count > 0
        active = active or guard.visible
        if guard.visible:
            guard.rotation.y += 0.020
            for child in guard.get_children():
                if child.has_meta("pip_index"):
                    child.visible = int(child.get_meta("pip_index")) < guard_count
    if break_node != null:
        break_node.visible = elite_trait == "bulwark" and break_t > 0.0
        active = active or break_node.visible
        if break_node.visible:
            break_node.scale = Vector3.ONE * (0.92 + break_t * 0.38 + sin(time * 9.0) * 0.040)
            break_node.rotation.y -= 0.032 + break_t * 0.030
    if splitter != null:
        splitter.visible = elite_trait == "splitter" and split_ready
        active = active or splitter.visible
        if splitter.visible:
            var split_t := 0.72 if bool(enemy.get("splitter_spawned")) else 1.0 - health_ratio
            splitter.rotation.y += 0.030 + split_t * 0.040
            splitter.scale = Vector3.ONE * (0.82 + split_t * 0.42 + sin(time * 7.8 + float(id % 11)) * 0.035)
    if treasure != null:
        treasure.visible = elite_trait == "treasure" and treasure_t > 0.0
        active = active or treasure.visible
        if treasure.visible:
            treasure.position.z = -0.08 - treasure_t * 0.12 + sin(time * 8.8 + float(id % 5)) * 0.018
            treasure.scale = Vector3.ONE * (0.90 + treasure_t * 0.26)
    if generic != null:
        generic.visible = elite_trait == "" and urgency > 0.55
        active = active or generic.visible

    rig.visible = active
    if not rig.visible:
        return
    rig.rotation.y += 0.020 + urgency * 0.030
    var pulse := 1.0 + sin(time * 5.0 + float(id % 17)) * (0.030 + urgency * 0.030)
    rig.scale = Vector3.ONE * pulse
    var halo := rig.get_node_or_null("EliteTraitStateHalo") as Node3D
    if halo != null:
        halo.visible = true
        halo.rotation.y -= 0.030 + urgency * 0.040
    var meter := rig.get_node_or_null("EliteTraitStateMeter") as Node3D
    if meter != null:
        meter.visible = true
        meter.scale.x = lerpf(0.42, 1.18, maxf(urgency, maxf(dash_t, maxf(break_t, treasure_t))))

func _elite_trait_color(elite_trait: String) -> Color:
    match elite_trait:
        "bulwark":
            return Color(0.70, 0.86, 1.0)
        "splitter":
            return Color(0.82, 0.30, 1.0)
        "treasure":
            return Color(1.0, 0.76, 0.20)
        _:
            return Color(1.0, 0.30, 0.42)

func _add_boss_enrage_aura(model: Node3D, radius: float) -> void:
    var aura := Node3D.new()
    aura.name = "EnrageAura"
    aura.visible = false
    model.add_child(aura)
    var danger := _mat("boss_enrage_aura", Color(1.0, 0.12, 0.34, 0.24), 1.05, true, true)
    var hot := _mat("boss_enrage_hot", Color(1.0, 0.42, 0.82, 0.46), 1.20, true, true)
    _add_cylinder_segments(aura, radius * 1.92, 0.018, 24, danger, Vector3(0, 0.086, 0))
    _add_cylinder_segments(aura, radius * 1.34, 0.014, 8, hot, Vector3(0, 0.108, 0), Vector3(0, 22.5, 0))
    for i in range(8):
        var angle := TAU * float(i) / 8.0
        _add_box(aura, Vector3(radius * 0.18, 0.016, radius * 0.62), hot, Vector3(cos(angle) * radius * 1.42, 0.128, sin(angle) * radius * 1.42), Vector3(0, -rad_to_deg(angle), 0))

func _boss_phase_state_detail_name(boss_kind: String) -> String:
    match boss_kind:
        "boss_cho":
            return "BossPhaseChoDevourState"
        "boss_velkoz":
            return "BossPhaseVelkozFocusState"
        "boss_reksai":
            return "BossPhaseReksaiBurrowState"
        "boss_belveth":
            return "BossPhaseBelvethSwarmState"
        _:
            return "BossPhaseGenericState"

func _add_boss_phase_state_rig(model: Node3D, boss_kind: String, radius: float, height: float, color: Color) -> void:
    var rig := Node3D.new()
    rig.name = "BossPhaseStateRig"
    rig.visible = false
    rig.set_meta("boss_kind", boss_kind)
    rig.set_meta("detail_node", _boss_phase_state_detail_name(boss_kind))
    model.add_child(rig)

    var boss_color := color.lightened(0.18)
    var danger := _mat("boss_phase_danger_" + boss_kind, Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.36), 1.12, true, true)
    var void_mat := _mat("boss_phase_void_" + boss_kind, Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.36), 1.08, true, true)
    var hot := _mat("boss_phase_hot_" + boss_kind, Color(boss_color.r, boss_color.g, boss_color.b, 0.54), 1.18, true, true)
    var gold := _mat("boss_phase_gold_" + boss_kind, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.46), 0.86, true, true)
    var dark := _mat("boss_phase_dark_" + boss_kind, Color(0.018, 0.004, 0.034, 0.46), 0.08, true, true)
    var y := maxf(0.32, height * 0.92)
    var front_z := radius * 1.34

    var frame := _add_cylinder_segments(rig, radius * 0.82, 0.014, 8, void_mat, Vector3(0, y, front_z), Vector3(90, 0, 22.5))
    frame.name = "BossPhaseFrame"
    var meter := _add_box(rig, Vector3(radius * 1.24, 0.016, radius * 0.090), hot, Vector3(0, y + radius * 0.12, front_z + radius * 0.15))
    meter.name = "BossPhaseMeter"
    meter.set_meta("base_width", radius * 1.24)

    var cast_state := Node3D.new()
    cast_state.name = "BossPhaseCastState"
    cast_state.visible = false
    rig.add_child(cast_state)
    _add_cylinder_segments(cast_state, radius * 0.50, 0.012, 6, hot, Vector3(0, y + radius * 0.20, front_z), Vector3(90, 0, 30))
    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        _add_box(cast_state, Vector3(radius * 0.080, 0.012, radius * 0.42), gold, Vector3(cos(angle) * radius * 0.44, y + radius * 0.26, front_z + sin(angle) * radius * 0.32), Vector3(0, -rad_to_deg(angle), 0))

    var enrage_state := Node3D.new()
    enrage_state.name = "BossPhaseEnrageState"
    enrage_state.visible = false
    rig.add_child(enrage_state)
    _add_cylinder_segments(enrage_state, radius * 0.66, 0.012, 8, danger, Vector3(0, y + radius * 0.08, front_z - radius * 0.20), Vector3(90, 0, 22.5))
    for i in range(6):
        var spike_angle := TAU * float(i) / 6.0
        _add_tapered_cylinder(enrage_state, radius * 0.090, radius * 0.012, radius * 0.54, 6, danger, Vector3(cos(spike_angle) * radius * 0.50, y + radius * 0.32, front_z - radius * 0.20 + sin(spike_angle) * radius * 0.34), Vector3(70, -rad_to_deg(spike_angle), 0))

    var detail_name := _boss_phase_state_detail_name(boss_kind)
    var detail := Node3D.new()
    detail.name = detail_name
    detail.visible = false
    rig.add_child(detail)
    match boss_kind:
        "boss_cho":
            _add_cylinder_segments(detail, radius * 0.46, 0.012, 5, danger, Vector3(0, y + radius * 0.31, front_z + radius * 0.36), Vector3(90, 0, 18))
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(detail, radius * 0.090, radius * 0.012, radius * 0.54, 6, hot, Vector3(side * radius * 0.30, y + radius * 0.38, front_z + radius * 0.58), Vector3(72, 0, side * 18.0))
        "boss_velkoz":
            _add_cylinder_segments(detail, radius * 0.54, 0.012, 3, void_mat, Vector3(0, y + radius * 0.30, front_z + radius * 0.22), Vector3(90, 0, 30))
            _add_box(detail, Vector3(radius * 1.05, 0.014, radius * 0.070), hot, Vector3(0, y + radius * 0.36, front_z + radius * 0.22))
            _add_sphere(detail, radius * 0.12, hot, Vector3(0, y + radius * 0.43, front_z + radius * 0.22))
        "boss_reksai":
            _add_box(detail, Vector3(radius * 0.28, 0.016, radius * 1.20), danger, Vector3(0, y + radius * 0.30, front_z + radius * 0.42))
            for i in range(4):
                var side := -1.0 if i % 2 == 0 else 1.0
                _add_tapered_cylinder(detail, radius * 0.095, radius * 0.012, radius * 0.54, 6, hot, Vector3(side * radius * 0.34, y + radius * 0.38, front_z + radius * (0.12 + float(i) * 0.22)), Vector3(72, side * 14.0, side * 22.0))
        "boss_belveth":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.090, 0.014, radius * 1.02), void_mat, Vector3(side * radius * 0.50, y + radius * 0.30, front_z + radius * 0.28), Vector3(0, side * 20.0, side * 44.0))
                _add_box(detail, Vector3(radius * 0.070, 0.012, radius * 0.66), hot, Vector3(side * radius * 0.78, y + radius * 0.37, front_z + radius * 0.36), Vector3(0, side * -18.0, side * 52.0))
            _add_cylinder_segments(detail, radius * 0.42, 0.012, 6, gold, Vector3(0, y + radius * 0.34, front_z + radius * 0.12), Vector3(0, 30, 0))
        _:
            _add_cylinder_segments(detail, radius * 0.40, 0.012, 6, hot, Vector3(0, y + radius * 0.32, front_z + radius * 0.24), Vector3(90, 0, 30))
            _add_box(detail, Vector3(radius * 0.78, 0.012, radius * 0.070), dark, Vector3(0, y + radius * 0.38, front_z + radius * 0.24))

func _sync_boss_phase_state_rig(model: Node3D, enemy: Node, boss_kind: String, id: int) -> void:
    var rig := model.get_node_or_null("BossPhaseStateRig") as Node3D
    if rig == null:
        return
    var health_ratio := clampf(float(enemy.get("health")) / maxf(1.0, float(enemy.get("max_health"))), 0.0, 1.0)
    var cast_t := 1.0 - clampf(float(enemy.get("attack_timer")) / 0.68, 0.0, 1.0)
    var cinematic_state := _boss_cinematic_state(health_ratio, cast_t)
    var cinematic_intensity := _boss_cinematic_intensity(health_ratio, cast_t)
    var enrage_t := clampf((0.45 - health_ratio) / 0.45, 0.0, 1.0)
    var dash_t := clampf(float(enemy.get("dash_timer")) / 3.0, 0.0, 1.0)
    var summon_t := 1.0 - clampf(float(enemy.get("summon_timer")) / 1.85, 0.0, 1.0)
    var detail_t := cast_t
    match boss_kind:
        "boss_cho", "boss_belveth":
            detail_t = maxf(cast_t, summon_t)
        "boss_reksai":
            detail_t = maxf(cast_t, dash_t if float(enemy.get("dash_timer")) > 2.42 else 0.0)
        "boss_velkoz":
            detail_t = cast_t
        _:
            detail_t = maxf(cast_t, enrage_t)

    if cinematic_state == "pressuring":
        detail_t = maxf(detail_t, cinematic_intensity * 0.65)

    model.set_meta("boss_cinematic_state", cinematic_state)
    model.set_meta("boss_cinematic_intensity", cinematic_intensity)
    rig.set_meta("cinematic_state", cinematic_state)
    rig.set_meta("cinematic_intensity", cinematic_intensity)
    rig.set_meta("boss_health_ratio", health_ratio)
    rig.set_meta("boss_cast_t", cast_t)
    var active := float(enemy.get("health")) > 0.0 and cinematic_state != "steady" and maxf(cinematic_intensity, maxf(enrage_t, detail_t)) > 0.0
    rig.visible = active
    if not active:
        return
    var time := Time.get_ticks_msec() / 1000.0
    var intensity := maxf(cinematic_intensity, maxf(enrage_t, detail_t))
    rig.rotation.y += 0.018 + intensity * 0.032
    rig.scale = Vector3.ONE * (1.0 + sin(time * 4.6 + float(id % 17)) * (0.026 + intensity * 0.034))

    var frame := rig.get_node_or_null("BossPhaseFrame") as Node3D
    if frame != null:
        frame.rotation.y -= 0.030 + intensity * 0.040
        frame.scale = Vector3.ONE * lerpf(0.92, 1.18, intensity)
    var meter := rig.get_node_or_null("BossPhaseMeter") as Node3D
    if meter != null:
        meter.visible = true
        meter.scale.x = lerpf(0.36, 1.22, intensity)
    var cast_state := rig.get_node_or_null("BossPhaseCastState") as Node3D
    if cast_state != null:
        cast_state.visible = cast_t > 0.0
        if cast_state.visible:
            cast_state.rotation.y += 0.042 + cast_t * 0.060
            cast_state.scale = Vector3.ONE * (0.86 + cast_t * 0.34)
    var enrage_state := rig.get_node_or_null("BossPhaseEnrageState") as Node3D
    if enrage_state != null:
        enrage_state.visible = enrage_t > 0.0
        if enrage_state.visible:
            enrage_state.rotation.y -= 0.036 + enrage_t * 0.070
            enrage_state.scale = Vector3.ONE * (0.90 + enrage_t * 0.42 + sin(time * 8.0) * 0.040)
    var detail_name := str(rig.get_meta("detail_node", ""))
    var detail := rig.get_node_or_null(detail_name) as Node3D
    if detail != null:
        detail.visible = detail_t > 0.0
        if detail.visible:
            detail.rotation.y += 0.024 + detail_t * 0.048
            detail.scale = Vector3.ONE * (0.86 + detail_t * 0.36 + sin(time * 6.8 + float(id % 11)) * 0.030)

func _enemy_has_windup_warning(kind: String, boss: bool) -> bool:
    return boss or kind == "spitter" or kind == "void_eye" or kind == "rift_crystal" or kind == "burrower"

func _add_enemy_windup_aura(model: Node3D, kind: String, radius: float, boss: bool) -> void:
    var aura := Node3D.new()
    aura.name = "WindupAura"
    aura.visible = false
    model.add_child(aura)
    var warning := DANGER_RED
    if kind == "spitter":
        warning = Color(0.58, 1.0, 0.28)
    elif kind == "rift_crystal":
        warning = Color(0.34, 0.88, 1.0)
    elif kind == "burrower" or kind == "boss_reksai":
        warning = Color(1.0, 0.48, 0.16)
    elif kind == "void_eye" or kind == "boss_velkoz":
        warning = Color(1.0, 0.34, 1.0)
    var ring_radius := radius * (2.08 if boss else 1.56)
    var warning_mat := _mat(kind + "_windup_warning", Color(warning.r, warning.g, warning.b, 0.34), 1.10, true, true)
    var hot_mat := _mat(kind + "_windup_hot", Color(1.0, 0.12, 0.34, 0.42), 1.20, true, true)
    _add_cylinder_segments(aura, ring_radius, 0.014, 24 if boss else 16, warning_mat, Vector3(0, 0.076, 0))
    _add_box(aura, Vector3(ring_radius * 2.08, 0.014, radius * 0.13), hot_mat, Vector3(0, 0.096, 0), Vector3.ZERO)
    _add_box(aura, Vector3(radius * 0.13, 0.014, ring_radius * 2.08), hot_mat, Vector3(0, 0.098, 0), Vector3.ZERO)
    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        _add_box(aura, Vector3(radius * 0.16, 0.012, radius * (0.74 if boss else 0.52)), warning_mat, Vector3(cos(angle) * ring_radius * 0.70, 0.112, sin(angle) * ring_radius * 0.70), Vector3(0, -rad_to_deg(angle), 0))
    _add_enemy_windup_signature(aura, kind, radius, ring_radius, warning, boss)

func _add_enemy_windup_signature(aura: Node3D, kind: String, radius: float, ring_radius: float, warning: Color, boss: bool) -> void:
    var sig_mat := _mat(kind + "_windup_signature", Color(warning.r, warning.g, warning.b, 0.42), 1.16, true, true)
    var hot_mat := _mat(kind + "_windup_signature_hot", Color(1.0, 0.86, 0.94, 0.48), 1.22, true, true)
    match kind:
        "spitter":
            for i in range(3):
                var offset := -0.30 + float(i) * 0.30
                _add_sphere(aura, radius * 0.13, sig_mat, Vector3(offset * ring_radius, 0.138, ring_radius * 0.48))
            _add_cylinder_segments(aura, radius * 0.62, 0.012, 3, sig_mat, Vector3(0, 0.126, ring_radius * 0.30), Vector3(0, 30, 0))
        "rift_crystal":
            _add_cylinder_segments(aura, ring_radius * 0.62, 0.012, 6, sig_mat, Vector3(0, 0.128, 0), Vector3(0, 30, 0))
            for i in range(6):
                var crystal_angle := TAU * float(i) / 6.0
                _add_box(aura, Vector3(radius * 0.085, 0.012, radius * 0.70), sig_mat, Vector3(cos(crystal_angle) * ring_radius * 0.36, 0.148, sin(crystal_angle) * ring_radius * 0.36), Vector3(0, -rad_to_deg(crystal_angle), 0))
        "burrower", "boss_reksai":
            _add_box(aura, Vector3(radius * 0.32, 0.018, ring_radius * 1.78), sig_mat, Vector3(0, 0.132, ring_radius * 0.34))
            for i in range(4 if boss else 3):
                var step := float(i + 1) / float(5 if boss else 4)
                _add_tapered_cylinder(aura, radius * 0.13, radius * 0.02, radius * 0.70, 6, hot_mat, Vector3(((-1.0 if i % 2 == 0 else 1.0) * radius * 0.34), 0.170, ring_radius * step), Vector3(72, 0, 0))
        "void_eye", "boss_velkoz":
            _add_cylinder_segments(aura, ring_radius * 0.70, 0.012, 3, sig_mat, Vector3(0, 0.132, ring_radius * 0.10), Vector3(90, 0, 30))
            _add_box(aura, Vector3(ring_radius * 0.96, 0.014, radius * 0.080), hot_mat, Vector3(0, 0.154, ring_radius * 0.08))
            _add_sphere(aura, radius * 0.13, hot_mat, Vector3(0, 0.174, ring_radius * 0.08))
        "boss_cho":
            _add_cylinder_segments(aura, ring_radius * 0.58, 0.012, 5, sig_mat, Vector3(0, 0.132, ring_radius * 0.24), Vector3(90, 0, 18))
            for side in [-1.0, 0.0, 1.0]:
                _add_tapered_cylinder(aura, radius * 0.12, radius * 0.02, radius * 0.76, 6, hot_mat, Vector3(side * radius * 0.42, 0.168, ring_radius * 0.52), Vector3(70, 0, side * 16.0))
        "boss_belveth":
            for side in [-1.0, 1.0]:
                _add_box(aura, Vector3(radius * 0.18, 0.016, ring_radius * 1.56), sig_mat, Vector3(side * ring_radius * 0.50, 0.136, ring_radius * 0.06), Vector3(0, side * 12.0, side * 38.0))
                _add_box(aura, Vector3(radius * 0.12, 0.014, ring_radius * 0.92), hot_mat, Vector3(side * ring_radius * 0.78, 0.158, ring_radius * 0.22), Vector3(0, side * -18.0, side * 50.0))
        _:
            if boss:
                _add_cylinder_segments(aura, ring_radius * 0.62, 0.012, 6, sig_mat, Vector3(0, 0.132, 0), Vector3(0, 30, 0))

func _add_enemy_charge_lane(model: Node3D, kind: String, radius: float, boss: bool, lite := false) -> void:
    var lane := Node3D.new()
    lane.name = "ChargeLane"
    lane.visible = false
    model.add_child(lane)
    var color := Color(1.0, 0.46, 0.16)
    if kind == "skitter":
        color = Color(1.0, 0.30, 0.64)
    elif kind == "boss_reksai":
        color = Color(1.0, 0.52, 0.18)
    var rune_path := _warning_rune_texture_path()
    var lane_mat: StandardMaterial3D
    var hot_mat: StandardMaterial3D
    if rune_path != "":
        lane_mat = _texture_mat(kind + "_charge_lane", rune_path, Color(color.r, color.g, color.b, 0.30 if boss else 0.24), 0.72, true, true, Vector3(0.72, 0.72, 1.0))
        hot_mat = _texture_mat(kind + "_charge_lane_hot", rune_path, Color(1.0, 0.86, 0.72, 0.48 if boss else 0.36), 0.92, true, true, Vector3(0.58, 0.58, 1.0))
    else:
        lane_mat = _mat(kind + "_charge_lane", Color(color.r, color.g, color.b, 0.28 if boss else 0.24), 1.02, true, true)
        hot_mat = _mat(kind + "_charge_lane_hot", Color(1.0, 0.86, 0.72, 0.48 if boss else 0.36), 1.16, true, true)
    var lane_len := radius * (4.80 if boss else (2.55 if lite else 3.30))
    var lane_width := radius * (0.34 if boss else (0.22 if lite else 0.26))
    _add_box(lane, Vector3(lane_width, 0.014, lane_len), lane_mat, Vector3(0, 0.088, radius * 1.05))
    _add_box(lane, Vector3(lane_width * 2.25, 0.012, radius * 0.14), hot_mat, Vector3(0, 0.108, radius * (2.72 if boss else 1.92)))
    if not lite:
        for side in [-1.0, 1.0]:
            _add_box(lane, Vector3(radius * 0.10, 0.012, lane_len * 0.70), lane_mat, Vector3(side * radius * (0.38 if boss else 0.28), 0.104, radius * 0.82), Vector3(0, side * 5.0, 0))
        for i in range(3 if boss else 2):
            var step := float(i + 1) / float(4 if boss else 3)
            _add_tapered_cylinder(lane, radius * 0.09, radius * 0.018, radius * 0.46, 6, hot_mat, Vector3(0, 0.144, radius * (0.72 + step * (2.40 if boss else 1.55))), Vector3(72, 0, 0))

func _add_enemy_summon_aura(model: Node3D, kind: String, radius: float, boss: bool, lite := false) -> void:
    var aura := Node3D.new()
    aura.name = "SummonAura"
    aura.visible = false
    model.add_child(aura)
    var color := Color(0.34, 0.88, 1.0) if kind == "rift_crystal" else Color(0.92, 0.32, 1.0)
    if kind == "boss_cho":
        color = Color(1.0, 0.48, 0.86)
    var rune_path := _warning_rune_texture_path()
    var ring_mat: StandardMaterial3D
    var hot_mat: StandardMaterial3D
    if rune_path != "":
        ring_mat = _texture_mat(kind + "_summon_ring", rune_path, Color(color.r, color.g, color.b, 0.32 if boss else 0.24), 0.82, true, true, Vector3(0.80, 0.80, 1.0))
        hot_mat = _texture_mat(kind + "_summon_hot", rune_path, Color(color.lightened(0.16).r, color.lightened(0.16).g, color.lightened(0.16).b, 0.52 if boss else 0.38), 1.02, true, true, Vector3(0.56, 0.56, 1.0))
    else:
        ring_mat = _mat(kind + "_summon_ring", Color(color.r, color.g, color.b, 0.30 if boss else 0.24), 1.06, true, true)
        hot_mat = _mat(kind + "_summon_hot", Color(color.lightened(0.16).r, color.lightened(0.16).g, color.lightened(0.16).b, 0.50 if boss else 0.38), 1.18, true, true)
    var outer := radius * (2.24 if boss else 1.62)
    var inner := radius * (1.28 if boss else 0.92)
    _add_cylinder_segments(aura, outer, 0.014, 6, ring_mat, Vector3(0, 0.082, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(aura, inner, 0.012, 12 if lite else 24, hot_mat, Vector3(0, 0.106, 0))
    var shard_count := 0 if lite else (8 if boss else 6)
    for i in range(shard_count):
        var angle := TAU * float(i) / float(shard_count)
        var shard := _add_box(aura, Vector3(radius * 0.10, 0.012, radius * (0.62 if boss else 0.44)), hot_mat, Vector3(cos(angle) * outer * 0.62, 0.128, sin(angle) * outer * 0.62), Vector3(0, -rad_to_deg(angle), 0))
        shard.name = "SummonShard" + str(i)

func _add_enemy_health_bar(model: Node3D, radius: float, boss: bool) -> void:
    var bar := Node3D.new()
    bar.name = "HealthBar"
    model.add_child(bar)
    var width := radius * (2.90 if boss else 2.10)
    var z_offset := -radius * (1.24 if boss else 1.08)
    var back := _add_box(bar, Vector3(width, 0.020, radius * 0.13), _mat("enemy_health_back", Color(0.02, 0.01, 0.02, 0.62), 0.0, true, true), Vector3(0, 0.160, z_offset))
    back.name = "Back"
    var fill_color := Color(1.0, 0.22, 0.38, 0.82) if boss else Color(0.94, 0.54, 1.0, 0.78)
    var fill := _add_box(bar, Vector3(width, 0.024, radius * 0.095), _mat("enemy_health_fill", fill_color, 0.60, true, true), Vector3(0, 0.182, z_offset))
    fill.name = "Fill"
    fill.set_meta("bar_width", width)
    _add_box(bar, Vector3(width * 1.08, 0.014, radius * 0.030), _mat("enemy_health_gold_trim", Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42), 0.56, true, true), Vector3(0, 0.202, z_offset - radius * 0.085))

func _sync_enemy_status_marks(model: Node3D, enemy: Node, radius: float, boss: bool) -> void:
    var poison_active := float(enemy.get("poison_timer")) > 0.0
    var slow_active := float(enemy.get("slow_timer")) > 0.0
    var root_active := float(enemy.get("root_timer")) > 0.0
    var weaken_active := float(enemy.get("weakened_timer")) > 0.0
    var has_status := poison_active or slow_active or root_active or weaken_active
    var marks := model.get_node_or_null("StatusMarks") as Node3D
    if not has_status:
        if marks != null:
            marks.visible = false
        return
    if marks == null:
        marks = _create_enemy_status_marks(radius, boss)
        model.add_child(marks)
    marks.visible = true
    marks.rotation.y += 0.024 if boss else 0.034
    var pulse := 1.0 + sin(Time.get_ticks_msec() / 1000.0 * 6.0) * 0.045
    _set_status_mark_visible(marks, "Poison", poison_active, pulse)
    _set_status_mark_visible(marks, "Slow", slow_active and not root_active, 1.0)
    _set_status_mark_visible(marks, "Root", root_active, pulse)
    _set_status_mark_visible(marks, "Weaken", weaken_active, 1.0)

func _set_status_mark_visible(marks: Node3D, mark_name: String, visible: bool, scale_value: float) -> void:
    var mark := marks.get_node_or_null(mark_name) as Node3D
    if mark == null:
        return
    mark.visible = visible
    if visible:
        mark.scale = Vector3.ONE * scale_value

func _create_enemy_status_marks(radius: float, boss: bool) -> Node3D:
    var marks := Node3D.new()
    marks.name = "StatusMarks"
    var status_scale := 1.32 if boss else 1.0
    var poison := Node3D.new()
    poison.name = "Poison"
    marks.add_child(poison)
    var poison_col := Color(0.54, 1.0, 0.22)
    _add_cylinder_segments(poison, radius * 1.52 * status_scale, 0.012, 18, _mat("status_poison_ring", Color(poison_col.r, poison_col.g, poison_col.b, 0.34), 0.96, true, true), Vector3(0, 0.128, 0))
    for i in range(6):
        var poison_angle := TAU * float(i) / 6.0
        _add_sphere(poison, radius * 0.070, _mat("status_poison_bubble", Color(poison_col.r, poison_col.g, poison_col.b, 0.46), 0.90, true, true), Vector3(cos(poison_angle) * radius * 1.12, 0.168, sin(poison_angle) * radius * 1.12))

    var slow := Node3D.new()
    slow.name = "Slow"
    marks.add_child(slow)
    var slow_col := Color(0.58, 0.84, 1.0)
    _add_cylinder_segments(slow, radius * 1.68 * status_scale, 0.012, 6, _mat("status_slow_hex", Color(slow_col.r, slow_col.g, slow_col.b, 0.28), 0.82, true, true), Vector3(0, 0.116, 0), Vector3(0, 30, 0))
    _add_box(slow, Vector3(radius * 2.22, 0.012, radius * 0.060), _mat("status_slow_axis_a", Color(slow_col.r, slow_col.g, slow_col.b, 0.34), 0.92, true, true), Vector3(0, 0.136, 0))
    _add_box(slow, Vector3(radius * 0.060, 0.012, radius * 2.22), _mat("status_slow_axis_b", Color(slow_col.r, slow_col.g, slow_col.b, 0.34), 0.92, true, true), Vector3(0, 0.138, 0))

    var root := Node3D.new()
    root.name = "Root"
    marks.add_child(root)
    var root_col := Color(1.0, 0.38, 0.74)
    _add_cylinder_segments(root, radius * 1.84 * status_scale, 0.014, 5, _mat("status_root_star", Color(root_col.r, root_col.g, root_col.b, 0.34), 0.98, true, true), Vector3(0, 0.150, 0), Vector3(0, 18, 0))
    for i in range(5):
        var root_angle := TAU * float(i) / 5.0
        _add_box(root, Vector3(radius * 0.090, 0.016, radius * 0.88), _mat("status_root_pin", Color(root_col.r, root_col.g, root_col.b, 0.50), 1.02, true, true), Vector3(cos(root_angle) * radius * 0.58, 0.172, sin(root_angle) * radius * 0.58), Vector3(0, -rad_to_deg(root_angle), 0))

    var weaken := Node3D.new()
    weaken.name = "Weaken"
    marks.add_child(weaken)
    var weak_col := Color(1.0, 0.86, 0.24)
    _add_box(weaken, Vector3(radius * 2.28 * status_scale, 0.018, radius * 0.10), _mat("status_weaken_slash_a", Color(weak_col.r, weak_col.g, weak_col.b, 0.46), 0.98, true, true), Vector3(0, 0.190, 0), Vector3(0, 34, 0))
    _add_box(weaken, Vector3(radius * 2.28 * status_scale, 0.018, radius * 0.10), _mat("status_weaken_slash_b", Color(weak_col.r, weak_col.g, weak_col.b, 0.34), 0.82, true, true), Vector3(0, 0.212, 0), Vector3(0, -34, 0))

    poison.visible = false
    slow.visible = false
    root.visible = false
    weaken.visible = false
    return marks

func _add_void_species_marker(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite: bool) -> void:
    var marker_color := color.lightened(0.26)
    var marker_alpha := 0.34 if boss or elite else 0.20
    var marker_mat := _mat(kind + "_species_marker", Color(marker_color.r, marker_color.g, marker_color.b, marker_alpha), 0.72, true, true)
    var hot_mat := _mat(kind + "_species_hot", Color(1.0, 0.22, 0.72, 0.54 if boss or elite else 0.34), 0.95, true, true)
    var shell_mat := _mat(kind + "_species_shell", color.darkened(0.34), 0.10, true)
    var base_radius := radius * (1.42 if boss else (1.22 if elite else 0.96))
    _add_enemy_species_decal(model, kind, radius, color, boss, elite)
    _add_cylinder_segments(model, base_radius, 0.014, 6, marker_mat, Vector3(0, 0.032, 0), Vector3(0, 30, 0))

    match kind:
        "skitter":
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(radius * 0.72, 0.016, radius * 0.10), hot_mat, Vector3(side * radius * 0.42, 0.052, radius * 0.78), Vector3(0, side * 20.0, side * -18.0))
        "spitter":
            _add_cylinder_segments(model, radius * 0.58, 0.012, 3, hot_mat, Vector3(0, 0.054, radius * 0.62), Vector3(0, 30, 0))
            _add_sphere(model, radius * 0.10, hot_mat, Vector3(0, height * 0.92, -radius * 0.36))
        "burrower", "boss_reksai":
            var count := 5 if boss else 3
            for i in range(count):
                var t := -0.5 + float(i) / maxf(1.0, float(count - 1))
                _add_box(model, Vector3(radius * 0.18, 0.018, radius * (0.68 if boss else 0.46)), hot_mat, Vector3(t * radius * 1.25, 0.056, radius * (0.40 - abs(t) * 0.26)), Vector3(0, 0, t * 34.0))
        "carapace":
            for i in range(3):
                _add_box(model, Vector3(radius * (1.00 - i * 0.16), 0.018, radius * 0.12), shell_mat, Vector3(0, 0.060, radius * (-0.18 + i * 0.26)), Vector3(0, 0, i * 10.0 - 10.0))
        "void_eye", "boss_velkoz":
            _add_cylinder_segments(model, radius * (0.82 if boss else 0.62), 0.014, 24, hot_mat, Vector3(0, 0.060, radius * 0.08), Vector3(90, 0, 0))
            _add_box(model, Vector3(radius * 1.30, 0.014, radius * 0.08), marker_mat, Vector3(0, 0.058, 0), Vector3.ZERO)
            _add_box(model, Vector3(radius * 0.08, 0.014, radius * 1.30), marker_mat, Vector3(0, 0.056, 0), Vector3.ZERO)
        "rift_crystal":
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_box(model, Vector3(radius * 0.10, 0.016, radius * 0.58), marker_mat, Vector3(cos(angle) * radius * 0.20, 0.056, sin(angle) * radius * 0.20), Vector3(0, -rad_to_deg(angle), 0))
        "boss_cho":
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(radius * 0.16, 0.020, radius * 1.00), hot_mat, Vector3(side * radius * 0.48, 0.062, radius * 0.80), Vector3(0, side * 20.0, side * 24.0))
            _add_cylinder_segments(model, radius * 0.76, 0.014, 18, hot_mat, Vector3(0, 0.060, radius * 0.58), Vector3(90, 0, 0))
        "boss_belveth":
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(radius * 0.18, 0.020, radius * 1.64), hot_mat, Vector3(side * radius * 0.88, 0.060, 0), Vector3(0, side * 12.0, side * 42.0))
                _add_box(model, Vector3(radius * 0.12, 0.018, radius * 1.04), marker_mat, Vector3(side * radius * 1.24, 0.056, radius * 0.28), Vector3(0, side * -18.0, side * 55.0))
        _:
            _add_box(model, Vector3(radius * 0.88, 0.014, radius * 0.10), marker_mat, Vector3(0, 0.054, radius * 0.62))

func _add_enemy_species_decal(model: Node3D, kind: String, radius: float, color: Color, boss: bool, elite: bool) -> void:
    var decal_path := _vfx_decal_texture_path()
    if decal_path == "":
        return
    var uv_offset := Vector3(0.25, 0.25, 0.0)
    var tint := Color(color.lightened(0.18).r, color.lightened(0.18).g, color.lightened(0.18).b, 0.18)
    match kind:
        "spitter":
            uv_offset = Vector3(0.75, 0.75, 0.0)
            tint = Color(0.50, 1.0, 0.30, 0.17)
        "burrower", "boss_reksai":
            uv_offset = Vector3(0.0, 0.75, 0.0)
            tint = Color(1.0, 0.48, 0.16, 0.20)
        "carapace", "boss_cho":
            uv_offset = Vector3(0.75, 0.25, 0.0)
            tint = Color(0.78, 0.46, 1.0, 0.18)
        "void_eye", "boss_velkoz":
            uv_offset = Vector3(0.25, 0.0, 0.0)
            tint = Color(1.0, 0.28, 1.0, 0.20)
        "rift_crystal":
            uv_offset = Vector3(0.50, 0.75, 0.0)
            tint = Color(0.34, 0.88, 1.0, 0.20)
        "boss_belveth":
            uv_offset = Vector3(0.75, 0.75, 0.0)
            tint = Color(0.88, 0.28, 1.0, 0.22)
        _:
            pass
    var scale := radius * (2.92 if boss else (2.42 if elite else 1.82))
    var mat := _vfx_decal_mat("enemy_species_decal_" + kind, decal_path, tint, 0.64 if boss or elite else 0.46, Vector3(0.25, 0.25, 1.0), uv_offset)
    var decal := _add_textured_plane(model, Vector2(scale, scale), mat, Vector3(0, 0.024, 0))
    decal.name = "EnemySpeciesDecal"

func _add_enemy_species_role_banner(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite: bool) -> void:
    var banner := Node3D.new()
    banner.name = "EnemySpeciesRoleBanner"
    banner.set_meta("kind", kind)
    model.add_child(banner)
    var role_color := color.lightened(0.26)
    match kind:
        "skitter":
            role_color = Color(1.0, 0.30, 0.64)
        "spitter":
            role_color = Color(0.54, 1.0, 0.28)
        "burrower", "boss_reksai":
            role_color = Color(1.0, 0.52, 0.18)
        "carapace", "boss_cho":
            role_color = Color(0.76, 0.48, 1.0)
        "void_eye", "boss_velkoz":
            role_color = Color(1.0, 0.34, 1.0)
        "rift_crystal":
            role_color = Color(0.34, 0.88, 1.0)
        "boss_belveth":
            role_color = Color(0.92, 0.36, 1.0)
        _:
            pass
    var alpha := 0.44 if boss or elite else 0.30
    var ring_radius := radius * (0.92 if boss else (0.74 if elite else 0.56))
    var y := height * (1.05 if boss else (0.92 if elite else 0.82))
    var banner_mat := _mat(kind + "_role_banner", Color(role_color.r, role_color.g, role_color.b, alpha), 1.02 if boss or elite else 0.84, true, true)
    var hot_mat := _mat(kind + "_role_banner_hot", role_color.lightened(0.14), 1.16, true)
    _add_cylinder_segments(banner, ring_radius, 0.012, 6 if kind == "rift_crystal" else 4, banner_mat, Vector3(0, y, 0), Vector3(90, 0, 30))
    match kind:
        "skitter":
            for side in [-1.0, 1.0]:
                _add_box(banner, Vector3(radius * 0.080, 0.016, radius * 0.58), hot_mat, Vector3(side * radius * 0.26, y + radius * 0.05, 0), Vector3(0, side * 24.0, side * 28.0))
        "spitter":
            _add_cylinder_segments(banner, ring_radius * 0.62, 0.010, 3, hot_mat, Vector3(0, y + radius * 0.04, radius * 0.18), Vector3(90, 0, 30))
            for i in range(3):
                var a := -0.38 + float(i) * 0.38
                _add_sphere(banner, radius * 0.070, hot_mat, Vector3(sin(a) * radius * 0.42, y + radius * 0.10, radius * 0.46))
        "burrower", "boss_reksai":
            _add_box(banner, Vector3(radius * 0.18, 0.016, radius * 1.12), hot_mat, Vector3(0, y + radius * 0.05, radius * 0.12))
            for i in range(3 if not boss else 5):
                var offset := -0.42 + float(i) * (0.84 / float(2 if not boss else 4))
                _add_tapered_cylinder(banner, radius * 0.065, radius * 0.012, radius * 0.36, 6, hot_mat, Vector3(offset * radius, y + radius * 0.10, radius * 0.54), Vector3(72, 0, offset * 18.0))
        "carapace", "boss_cho":
            for i in range(3):
                _add_box(banner, Vector3(radius * (0.82 - float(i) * 0.13), 0.016, radius * 0.12), hot_mat, Vector3(0, y + radius * (0.04 + float(i) * 0.025), radius * (-0.20 + float(i) * 0.20)), Vector3(0, 0, -8.0 + float(i) * 8.0))
        "void_eye", "boss_velkoz":
            _add_box(banner, Vector3(radius * 0.92, 0.014, radius * 0.070), hot_mat, Vector3(0, y + radius * 0.05, 0))
            _add_sphere(banner, radius * 0.090, hot_mat, Vector3(0, y + radius * 0.10, radius * 0.12))
        "rift_crystal":
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_box(banner, Vector3(radius * 0.060, 0.014, radius * 0.42), hot_mat, Vector3(cos(angle) * radius * 0.22, y + radius * 0.060, sin(angle) * radius * 0.22), Vector3(0, -rad_to_deg(angle), 0))
        "boss_belveth":
            for side in [-1.0, 1.0]:
                _add_box(banner, Vector3(radius * 0.12, 0.016, radius * 1.04), hot_mat, Vector3(side * radius * 0.54, y + radius * 0.060, 0), Vector3(0, side * 14.0, side * 42.0))
        _:
            _add_box(banner, Vector3(radius * 0.80, 0.014, radius * 0.080), hot_mat, Vector3(0, y + radius * 0.05, radius * 0.18))

func _enemy_tactical_role(kind: String) -> String:
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

func _enemy_tactical_detail_node_name(kind: String) -> String:
    match _enemy_tactical_role(kind):
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

func _enemy_tactical_role_color(kind: String, fallback: Color) -> Color:
    match _enemy_tactical_role(kind):
        "diver":
            return Color(1.0, 0.40, 0.28)
        "artillery":
            return Color(0.76, 0.92, 1.0)
        "tank":
            return Color(0.74, 0.56, 1.0)
        "summoner":
            return Color(0.34, 0.88, 1.0)
        _:
            return fallback.lightened(0.12)

func _add_enemy_tactical_readability_plaque(model: Node3D, kind: String, radius: float, height: float, color: Color, boss: bool, elite: bool) -> void:
    var plaque := Node3D.new()
    plaque.name = "EnemyTacticalReadabilityPlaque"
    plaque.set_meta("kind", kind)
    plaque.set_meta("boss", boss)
    plaque.set_meta("elite", elite)
    plaque.set_meta("enemy_role", _enemy_tactical_role(kind))
    plaque.set_meta("detail_node", _enemy_tactical_detail_node_name(kind))
    plaque.set_meta("combat_visual_channel", "enemy_role_readability")
    plaque.set_meta("material_grade", "low_glare_enemy_tactical_plaque")
    plaque.set_meta("pickup_confusion_guard", true)
    model.add_child(plaque)

    var role_color := _enemy_tactical_role_color(kind, color)
    var scale_boost := 1.24 if boss else 1.10 if elite else 1.0
    var y := 0.126
    var front_z := radius * (1.34 if boss else 1.12)
    var matte := _mat("enemy_tactical_matte_" + kind, Color(0.010, 0.008, 0.018, 0.30 if boss or elite else 0.24), 0.0, true, true)
    var accent := _mat("enemy_tactical_accent_" + kind, Color(role_color.r, role_color.g, role_color.b, 0.23 if boss or elite else 0.17), 0.0, true, true)
    var trim := _mat("enemy_tactical_trim_" + kind, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.20 if boss or elite else 0.14), 0.0, true, true)

    var backplate := _add_box(plaque, Vector3(radius * 1.44 * scale_boost, 0.010, radius * 0.22), matte, Vector3(0, y, front_z))
    backplate.name = "EnemyTacticalPlaqueBackplate"
    var glyph := _add_cylinder_segments(plaque, radius * 0.42 * scale_boost, 0.010, 6, accent, Vector3(0, y + 0.016, front_z), Vector3(0, 30, 0))
    glyph.name = "EnemyTacticalPlaqueRoleGlyph"
    var facing := _add_box(plaque, Vector3(radius * 0.10, 0.010, radius * 0.46 * scale_boost), trim, Vector3(0, y + 0.030, front_z + radius * 0.34))
    facing.name = "EnemyTacticalPlaqueFacingTick"

    var detail := Node3D.new()
    detail.name = _enemy_tactical_detail_node_name(kind)
    detail.set_meta("base_y", y + 0.044)
    plaque.add_child(detail)
    match _enemy_tactical_role(kind):
        "diver":
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(detail, radius * 0.070, radius * 0.010, radius * 0.46 * scale_boost, 6, accent, Vector3(side * radius * 0.22, y + 0.044, front_z + radius * 0.12), Vector3(70, 0, side * 22.0))
            _add_box(detail, Vector3(radius * 0.10, 0.010, radius * 0.62 * scale_boost), trim, Vector3(0, y + 0.060, front_z + radius * 0.08))
        "artillery":
            _add_box(detail, Vector3(radius * 0.82 * scale_boost, 0.010, radius * 0.060), accent, Vector3(0, y + 0.044, front_z))
            _add_box(detail, Vector3(radius * 0.060, 0.010, radius * 0.82 * scale_boost), accent, Vector3(0, y + 0.048, front_z))
            _add_sphere(detail, radius * 0.060, trim, Vector3(0, y + 0.064, front_z))
        "tank":
            _add_box(detail, Vector3(radius * 0.72 * scale_boost, 0.012, radius * 0.12), accent, Vector3(0, y + 0.044, front_z - radius * 0.10))
            _add_box(detail, Vector3(radius * 0.58 * scale_boost, 0.012, radius * 0.12), accent, Vector3(0, y + 0.058, front_z + radius * 0.10))
            _add_box(detail, Vector3(radius * 0.12, 0.012, radius * 0.48 * scale_boost), trim, Vector3(0, y + 0.060, front_z))
        "summoner":
            _add_cylinder_segments(detail, radius * 0.34 * scale_boost, 0.010, 6, accent, Vector3(0, y + 0.044, front_z), Vector3(0, 30, 0))
            for i in range(4):
                var angle := TAU * float(i) / 4.0 + PI * 0.25
                _add_box(detail, Vector3(radius * 0.046, 0.010, radius * 0.32 * scale_boost), trim, Vector3(cos(angle) * radius * 0.28, y + 0.058, front_z + sin(angle) * radius * 0.28), Vector3(0, -rad_to_deg(angle), 0))
        _:
            _add_box(detail, Vector3(radius * 0.62 * scale_boost, 0.010, radius * 0.070), accent, Vector3(0, y + 0.044, front_z), Vector3(0, 26, 0))
            _add_box(detail, Vector3(radius * 0.62 * scale_boost, 0.010, radius * 0.070), accent, Vector3(0, y + 0.050, front_z), Vector3(0, -26, 0))
            _add_sphere(detail, radius * 0.050, trim, Vector3(0, y + 0.064, front_z))

func _add_boss_signature(model: Node3D, kind: String, radius: float, height: float, color: Color) -> void:
    var hot := Color(1.0, 0.24, 0.72)
    var void_hot := _mat(kind + "_boss_hot", hot, 1.15, true)
    var shell := _mat(kind + "_boss_shell_dark", color.darkened(0.38), 0.12, true)
    var glass := _mat(kind + "_boss_glass", Color(0.78, 0.22, 1.0, 0.56), 1.05, true, true)
    match kind:
        "boss_cho":
            for side in [-1.0, 1.0]:
                _add_tapered_cylinder(model, radius * 0.10, radius * 0.02, radius * 0.78, 8, _mat(kind + "_tusk", Color(0.92, 0.82, 0.72), 0.20, true), Vector3(side * radius * 0.46, height * 0.90, radius * 0.84), Vector3(55, 0, side * 20.0))
                _add_box(model, Vector3(radius * 0.12, radius * 0.18, radius * 0.92), shell, Vector3(side * radius * 0.62, height * 1.05, -radius * 0.16), Vector3(0, side * 22.0, side * 36.0))
            _add_cylinder_segments(model, radius * 0.54, 0.030, 24, _mat(kind + "_maw_warning", Color(1.0, 0.18, 0.54, 0.38), 1.1, true, true), Vector3(0, height * 0.78, radius * 0.92), Vector3(90, 0, 0))
        "boss_belveth":
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(radius * 0.18, height * 0.78, radius * 2.30), glass, Vector3(side * radius * 1.36, height * 0.56, -radius * 0.10), Vector3(0, side * 8.0, side * 36.0))
                _add_box(model, Vector3(radius * 0.12, height * 0.58, radius * 1.52), shell, Vector3(side * radius * 1.78, height * 0.44, radius * 0.12), Vector3(0, side * -12.0, side * 50.0))
            _add_tapered_cylinder(model, radius * 0.18, radius * 0.02, radius * 1.20, 8, void_hot, Vector3(0, height * 0.42, -radius * 1.16), Vector3(32, 0, 0))
        "boss_velkoz":
            _add_cylinder_segments(model, radius * 1.12, 0.035, 32, glass, Vector3(0, height * 0.58, 0), Vector3(90, 0, 0))
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                var pos := Vector3(cos(angle) * radius * 1.08, height * 0.58 + sin(angle * 2.0) * radius * 0.10, sin(angle) * radius * 1.08)
                _add_sphere(model, radius * 0.12, void_hot, pos)
        "boss_reksai":
            for i in range(6):
                var t := float(i) / 5.0
                _add_box(model, Vector3(radius * (0.22 - t * 0.05), radius * 0.22, radius * 0.88), shell, Vector3(0, height * (0.70 + t * 0.12), -radius * (0.76 - t * 0.23)), Vector3(0, 0, 28.0 - t * 20.0))
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(radius * 0.30, radius * 0.16, radius * 1.18), void_hot, Vector3(side * radius * 1.58, height * 0.28, radius * 0.46), Vector3(0, side * -18.0, side * 20.0))
        _:
            _add_cylinder_segments(model, radius * 1.08, 0.026, 8, glass, Vector3(0, height * 0.74, 0), Vector3(0, 22.5, 0))

func _add_bug_legs(model: Node3D, radius: float, height: float, color: Color, pairs: int) -> void:
    var leg_mat := _mat("bug_leg_" + color.to_html(false), color, 0.04, true)
    for i in range(pairs):
        var z := (-0.42 + float(i) * (0.84 / maxf(1.0, float(pairs - 1)))) * radius
        for side in [-1, 1]:
            var sx := float(side)
            _add_box(model, Vector3(radius * 0.82, radius * 0.12, radius * 0.16), leg_mat, Vector3(sx * radius * 0.82, height * 0.22, z), Vector3(0, 0, sx * 22.0))
            _add_box(model, Vector3(radius * 0.62, radius * 0.10, radius * 0.14), leg_mat, Vector3(sx * radius * 1.28, height * 0.12, z + radius * 0.18), Vector3(0, sx * 12.0, sx * -18.0))

func _add_tentacles(model: Node3D, radius: float, height: float, color: Color, count: int) -> void:
    var tentacle_mat := _mat("tentacle_" + color.to_html(false), color, 0.25, true)
    for i in range(count):
        var angle := TAU * float(i) / float(count)
        var x := cos(angle) * radius * 0.62
        var z := sin(angle) * radius * 0.62
        var tilt := Vector3(34.0 + float(i % 3) * 7.0, float(i) * 18.0, sin(angle) * 18.0)
        _add_cylinder(model, radius * 0.085, radius * 1.42, tentacle_mat, Vector3(x, height * 0.24, z), tilt)
        _add_sphere(model, radius * 0.12, tentacle_mat, Vector3(x * 1.45, height * 0.06, z * 1.45))

func _create_projectile_model(projectile, lite_enemy := false, lite_player := false) -> Node3D:
    var model := Node3D.new()
    var from_player := bool(projectile.get("from_player"))
    var label := str(projectile.get("label"))
    model.set_meta("label", label)
    model.set_meta("from_player", from_player)
    model.set_meta("combat_visual_channel", _projectile_visual_channel(from_player, label, lite_enemy, lite_player))
    model.set_meta("readability_priority", _projectile_readability_priority(from_player, label))
    var color: Color = Color(1.0, 0.10, 0.38)
    if from_player and projectile.get("projectile_color") is Color:
        color = projectile.get("projectile_color")
    var radius := maxf(0.10, float(projectile.get("radius")) * WORLD_SCALE * (1.6 if from_player else 2.0))
    if not from_player:
        if lite_enemy:
            _add_enemy_projectile_shape_lite(model, radius, label)
        else:
            _add_enemy_projectile_shape(model, radius, label)
        return model

    if lite_player:
        _add_player_projectile_shape_lite(model, radius, label, color)
        _add_player_projectile_signature_rig(model, radius, label, color, true)
        return model

    match label:
        "fishbones", "death_rocket":
            var rocket_color := Color(1.0, 0.34, 0.42) if label == "death_rocket" else Color(1.0, 0.66, 0.18)
            _add_cylinder(model, radius * 0.38, radius * 3.2, _mat("rocket_body_" + rocket_color.to_html(false), rocket_color, 0.38, true), Vector3(0, 0, radius * 0.10), Vector3(90, 0, 0))
            _add_sphere(model, radius * 0.58, _mat("rocket_nose_" + rocket_color.to_html(false), rocket_color.lightened(0.20), 0.95, true), Vector3(0, 0, radius * 1.86))
            _add_projectile_tail(model, radius * 0.42, radius * 3.4, rocket_color, radius * -1.62)
            _add_box(model, Vector3(radius * 0.18, radius * 0.78, radius * 0.52), _mat("rocket_fin", Color(0.22, 0.20, 0.26), 0.05, true), Vector3(-radius * 0.54, 0, -radius * 1.28), Vector3(0, 0, 18))
            _add_box(model, Vector3(radius * 0.18, radius * 0.78, radius * 0.52), _mat("rocket_fin", Color(0.22, 0.20, 0.26), 0.05, true), Vector3(radius * 0.54, 0, -radius * 1.28), Vector3(0, 0, -18))
        "senna_beam", "senna_snare":
            var beam_color := Color(0.58, 1.0, 0.78) if label == "senna_beam" else Color(0.90, 1.0, 0.95)
            _add_cylinder(model, radius * 0.26, radius * 6.2, _mat("senna_beam_" + beam_color.to_html(false), Color(beam_color.r, beam_color.g, beam_color.b, 0.58), 1.25, true, true), Vector3(0, 0, radius * 0.56), Vector3(90, 0, 0))
            _add_sphere(model, radius * 0.70, _mat("senna_core_" + beam_color.to_html(false), beam_color, 1.25, true), Vector3(0, 0, radius * 2.84))
            _add_cylinder_segments(model, radius * 1.06, 0.022, 24, _mat("senna_ring_" + beam_color.to_html(false), Color(beam_color.r, beam_color.g, beam_color.b, 0.32), 0.9, true, true), Vector3(0, 0, radius * 1.30), Vector3(90, 0, 0))
        "viktor_laser":
            _add_cylinder(model, radius * 0.22, radius * 5.8, _mat("viktor_laser_line", Color(0.70, 0.94, 1.0, 0.62), 1.35, true, true), Vector3(0, 0, radius * 0.62), Vector3(90, 0, 0))
            _add_box(model, Vector3(radius * 1.12, radius * 1.12, radius * 1.12), _mat("viktor_hexcore", Color(0.72, 0.94, 1.0), 1.1, true), Vector3(0, 0, radius * 2.80), Vector3(45, 35, 0))
            _add_projectile_tail(model, radius * 0.24, radius * 3.0, Color(0.35, 0.84, 1.0), radius * -1.62)
        "xayah_feather", "xayah_recall":
            var feather_color := Color(1.0, 0.34, 0.62) if label == "xayah_feather" else Color(0.92, 0.28, 1.0)
            _add_box(model, Vector3(radius * 0.34, radius * 0.12, radius * 3.2), _mat("xayah_spine_" + feather_color.to_html(false), feather_color, 0.80, true), Vector3(0, 0, radius * 0.42), Vector3(0, 0, 0))
            _add_box(model, Vector3(radius * 0.18, radius * 0.08, radius * 1.72), _mat("xayah_side_" + feather_color.to_html(false), Color(feather_color.r, feather_color.g, feather_color.b, 0.62), 0.75, true, true), Vector3(-radius * 0.34, 0, radius * 0.08), Vector3(0, -18, 0))
            _add_box(model, Vector3(radius * 0.18, radius * 0.08, radius * 1.72), _mat("xayah_side_" + feather_color.to_html(false), Color(feather_color.r, feather_color.g, feather_color.b, 0.62), 0.75, true, true), Vector3(radius * 0.34, 0, radius * 0.08), Vector3(0, 18, 0))
            _add_projectile_tail(model, radius * 0.20, radius * 2.4, feather_color, radius * -1.48)
        "teemo_dart", "blind_dart":
            var dart_color := Color(0.56, 1.0, 0.26) if label == "teemo_dart" else Color(0.98, 0.90, 0.24)
            _add_tapered_cylinder(model, radius * 0.26, radius * 0.04, radius * 2.3, 8, _mat("teemo_dart_tip_" + dart_color.to_html(false), dart_color, 0.55, true), Vector3(0, 0, radius * 0.88), Vector3(90, 0, 0))
            _add_sphere(model, radius * 0.36, _mat("teemo_dart_vial_" + dart_color.to_html(false), dart_color.lightened(0.18), 0.85, true), Vector3(0, 0, -radius * 0.16))
            _add_box(model, Vector3(radius * 0.82, radius * 0.08, radius * 0.28), _mat("teemo_dart_fletch", Color(0.86, 0.58, 0.22), 0.18, true), Vector3(0, 0, -radius * 0.92))
            _add_projectile_tail(model, radius * 0.20, radius * 2.2, dart_color, radius * -1.30)
        "samira_pistol", "powpow":
            var bullet_color := Color(1.0, 0.62, 0.22) if label == "samira_pistol" else Color(0.42, 0.82, 1.0)
            _add_tapered_cylinder(model, radius * 0.32, radius * 0.08, radius * 2.4, 12, _mat("bullet_slug_" + bullet_color.to_html(false), bullet_color, 0.65, true), Vector3(0, 0, radius * 0.72), Vector3(90, 0, 0))
            _add_projectile_tail(model, radius * 0.32, radius * 2.2, bullet_color, radius * -1.05)
        "comet":
            _add_sphere(model, radius * 0.86, _mat("comet_core", Color(1.0, 0.88, 0.42), 1.35, true), Vector3(0, 0, radius * 0.80))
            _add_sphere(model, radius * 1.25, _mat("comet_aura", Color(0.76, 0.38, 1.0, 0.24), 0.95, true, true), Vector3(0, 0, radius * 0.80))
            _add_projectile_tail(model, radius * 0.52, radius * 4.6, Color(0.76, 0.38, 1.0), radius * -1.80)
            for i in range(4):
                _add_box(model, Vector3(radius * 0.10, radius * 0.10, radius * 1.35), _mat("comet_star_ray", Color(1.0, 0.88, 0.42, 0.66), 1.0, true, true), Vector3(0, 0, radius * 0.80), Vector3(0, float(i) * 45.0, 48.0))
        _:
            _add_sphere(model, radius * 1.08, _mat("proj_shell_" + color.to_html(false), Color(color.r, color.g, color.b, 0.34), 0.95, true, true), Vector3.ZERO)
            _add_sphere(model, radius * 0.66, _mat("proj_core_" + color.to_html(false), color.lightened(0.18), 1.15, true), Vector3.ZERO)
            _add_projectile_tail(model, radius * 0.34, radius * 4.0, color, radius * -1.70)
    _add_projectile_vfx_decal(model, radius, label, color, true)
    _add_player_projectile_path_signature(model, radius, label, color)
    _add_player_projectile_signature_rig(model, radius, label, color, false)
    _add_player_projectile_role_profile(model, radius, label, color)
    _add_player_projectile_impact_intent_profile(model, radius, label, color)
    _add_player_projectile_spell_trail_profile(model, radius, label, color)
    _add_player_projectile_premium_fx_rig(model, radius, label, color)
    _add_champion_projectile_mechanic_silhouette_rig(model, radius, label, color)
    return model

func _add_player_projectile_path_signature(model: Node3D, radius: float, label: String, color: Color) -> void:
    if model.get_node_or_null("PlayerProjectilePathSignature") != null:
        return
    var family := _player_projectile_family(label)
    var root := Node3D.new()
    root.name = "PlayerProjectilePathSignature"
    root.set_meta("label", label)
    root.set_meta("family", family)
    root.set_meta("combat_visual_channel", "player_skill")
    root.set_meta("readability_priority", _projectile_readability_priority(true, label))
    model.add_child(root)

    var family_color := _player_projectile_family_color(label, color)
    var lane_mat := _mat("player_path_lane_" + family, Color(family_color.r, family_color.g, family_color.b, 0.26), 0.98, true, true)
    var hot_mat := _mat("player_path_hot_" + family, Color(family_color.lightened(0.16).r, family_color.lightened(0.16).g, family_color.lightened(0.16).b, 0.46), 1.18, true, true)
    var gold_mat := _mat("player_path_gold_" + family, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.38), 0.78, true, true)
    var dark_mat := _mat("player_path_dark_" + family, Color(0.012, 0.012, 0.024, 0.36), 0.02, true, true)
    var y := -0.575

    var lane_length := radius * 4.10
    var lane_width := radius * 0.34
    match family:
        "artillery", "laser":
            lane_length = radius * 6.80
            lane_width = radius * 0.20
        "comet":
            lane_length = radius * 5.40
            lane_width = radius * 0.52
        "feather":
            lane_length = radius * 3.55
            lane_width = radius * 0.22
        "poison":
            lane_length = radius * 3.10
            lane_width = radius * 0.30
        "juggernaut":
            lane_length = radius * 3.35
            lane_width = radius * 0.48
        _:
            pass

    var lane := _add_box(root, Vector3(lane_width, 0.012, lane_length), lane_mat, Vector3(0, y, -radius * 0.62))
    lane.name = "PlayerProjectileLaneRibbon"

    var impact := _add_cylinder_segments(root, radius * 1.18, 0.012, 8, hot_mat, Vector3(0, y + 0.024, radius * 1.20), Vector3(0, 22.5, 0))
    impact.name = "PlayerProjectileImpactMark"

    var glyph := _add_cylinder_segments(root, radius * 0.64, 0.010, 6, gold_mat, Vector3(0, y + 0.040, -radius * 1.18), Vector3(0, 30, 0))
    glyph.name = "PlayerProjectileRoleGlyph"

    match family:
        "rocket":
            _add_box(root, Vector3(radius * 1.12, 0.014, radius * 0.14), hot_mat, Vector3(0, y + 0.052, -radius * 1.50))
            for spark in range(4):
                var spark_angle := TAU * float(spark) / 4.0
                _add_tapered_cylinder(root, radius * 0.060, radius * 0.010, radius * 0.76, 6, hot_mat, Vector3(cos(spark_angle) * radius * 0.54, y + 0.070, -radius * 1.34 + sin(spark_angle) * radius * 0.30), Vector3(74, -rad_to_deg(spark_angle), 0))
        "artillery":
            _add_box(root, Vector3(radius * 1.10, 0.010, radius * 0.10), gold_mat, Vector3(0, y + 0.056, radius * 0.12))
            _add_cylinder_segments(root, radius * 0.72, 0.010, 28, lane_mat, Vector3(0, y + 0.066, radius * 1.90), Vector3(90, 0, 0))
            for mote in range(4):
                var mote_angle := TAU * float(mote) / 4.0
                _add_sphere(root, radius * 0.070, hot_mat, Vector3(cos(mote_angle) * radius * 0.72, y + 0.088, radius * 1.20 + sin(mote_angle) * radius * 0.38))
        "duelist":
            for slash in range(3):
                var slash_offset := float(slash) - 1.0
                _add_box(root, Vector3(radius * 0.10, 0.012, radius * 1.36), hot_mat, Vector3(slash_offset * radius * 0.28, y + 0.052, -radius * 0.10 + abs(slash_offset) * radius * 0.14), Vector3(0, slash_offset * 18.0, 0))
            _add_cylinder_segments(root, radius * 0.84, 0.010, 24, lane_mat, Vector3(0, y + 0.060, -radius * 0.20), Vector3(90, 0, 0))
        "laser":
            _add_cylinder_segments(root, radius * 0.96, 0.010, 6, lane_mat, Vector3(0, y + 0.052, radius * 0.62), Vector3(0, 30, 0))
            for circuit in range(4):
                var circuit_angle := TAU * float(circuit) / 4.0
                _add_box(root, Vector3(radius * 0.050, 0.010, radius * 0.92), hot_mat, Vector3(cos(circuit_angle) * radius * 0.48, y + 0.068, radius * 0.62 + sin(circuit_angle) * radius * 0.48), Vector3(0, -rad_to_deg(circuit_angle), 0))
        "feather":
            for feather in range(5):
                var offset := float(feather) - 2.0
                _add_box(root, Vector3(radius * 0.088, 0.012, radius * (1.52 - abs(offset) * 0.12)), hot_mat, Vector3(offset * radius * 0.24, y + 0.056, -radius * 0.22 + abs(offset) * radius * 0.12), Vector3(0, offset * 11.0, 0))
        "poison":
            for spore in range(6):
                var spore_angle := TAU * float(spore) / 6.0
                var spore_z := -radius * 1.42 + float(spore % 3) * radius * 0.48
                _add_sphere(root, radius * 0.080, hot_mat, Vector3(cos(spore_angle) * radius * 0.52, y + 0.064, spore_z + sin(spore_angle) * radius * 0.16))
            _add_cylinder_segments(root, radius * 0.88, 0.010, 16, lane_mat, Vector3(0, y + 0.052, -radius * 0.18))
        "comet":
            _add_box(root, Vector3(radius * 0.12, 0.010, radius * 3.30), hot_mat, Vector3(0, y + 0.064, -radius * 1.02), Vector3(0, 30, 0))
            for star in range(5):
                var star_angle := TAU * float(star) / 5.0
                _add_sphere(root, radius * 0.075, _mat("player_path_star_" + str(star), Color(1.0, 0.86, 0.50, 0.48), 1.14, true, true), Vector3(cos(star_angle) * radius * 0.84, y + 0.082, radius * 0.18 + sin(star_angle) * radius * 0.58))
        "juggernaut":
            _add_box(root, Vector3(radius * 0.30, 0.012, radius * 2.40), hot_mat, Vector3(0.18 * radius, y + 0.056, -radius * 0.06), Vector3(0, -26, 0))
            _add_box(root, Vector3(radius * 1.18, 0.014, radius * 0.30), hot_mat, Vector3(0.62 * radius, y + 0.070, radius * 0.86), Vector3(0, -26, 0))
            _add_cylinder_segments(root, radius * 1.26, 0.010, 8, dark_mat, Vector3(0, y + 0.044, 0), Vector3(0, 22.5, 0))
        _:
            _add_cylinder_segments(root, radius * 0.84, 0.010, 6, lane_mat, Vector3(0, y + 0.052, 0), Vector3(0, 30, 0))

func _sync_player_projectile_path_signature(model: Node3D, id: int) -> void:
    var root := model.get_node_or_null("PlayerProjectilePathSignature") as Node3D
    if root == null:
        return
    var family := str(root.get_meta("family", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var pulse_strength := 0.040
    match family:
        "rocket", "duelist", "poison":
            pulse_strength = 0.060
        "laser", "artillery":
            pulse_strength = 0.032
        "comet":
            pulse_strength = 0.050
        _:
            pass
    var pulse := 1.0 + sin(time * (4.8 if family == "rocket" or family == "duelist" else 3.4) + float(id % 19)) * pulse_strength
    root.scale = Vector3(1.0 + (pulse - 1.0) * 0.42, 1.0, pulse)
    root.position.y = sin(time * 5.0 + float(id % 13)) * 0.010
    var impact := root.get_node_or_null("PlayerProjectileImpactMark") as Node3D
    if impact != null:
        impact.rotation.y += 0.034 if family == "comet" or family == "poison" else -0.026
    var glyph := root.get_node_or_null("PlayerProjectileRoleGlyph") as Node3D
    if glyph != null:
        glyph.rotation.y += 0.042 if family == "rocket" or family == "duelist" else 0.024
    _sync_player_projectile_role_profile(model, id)
    _sync_player_projectile_impact_intent_profile(model, id)
    _sync_player_projectile_spell_trail_profile(model, id)
    _sync_player_projectile_premium_fx_rig(model, id)
    _sync_champion_projectile_mechanic_silhouette_rig(model, id)

func _player_projectile_family(label: String) -> String:
    match label:
        "fishbones", "death_rocket", "powpow":
            return "rocket"
        "senna", "senna_beam", "senna_snare":
            return "artillery"
        "samira", "samira_pistol":
            return "duelist"
        "viktor", "viktor_laser":
            return "laser"
        "xayah", "xayah_feather", "xayah_recall":
            return "feather"
        "teemo", "teemo_dart", "blind_dart":
            return "poison"
        "aurelion_sol", "asol", "comet":
            return "comet"
        "morde", "mordekaiser":
            return "juggernaut"
        _:
            return "generic"

func _player_projectile_family_color(label: String, fallback: Color) -> Color:
    match _player_projectile_family(label):
        "rocket":
            return Color(1.0, 0.56, 0.18)
        "artillery":
            return Color(0.58, 1.0, 0.78)
        "duelist":
            return Color(1.0, 0.34, 0.14)
        "laser":
            return Color(0.72, 0.94, 1.0)
        "feather":
            return Color(1.0, 0.30, 0.68)
        "poison":
            return Color(0.62, 1.0, 0.22)
        "comet":
            return Color(0.92, 0.72, 1.0)
        "juggernaut":
            return Color(0.42, 1.0, 0.46)
        _:
            return fallback

func _projectile_visual_channel(from_player: bool, label: String, lite_enemy: bool, lite_player: bool) -> String:
    if from_player:
        return "player_skill_lite" if lite_player else "player_skill"
    var tier := _enemy_projectile_threat_tier(label)
    if lite_enemy:
        return "enemy_hazard_lite_" + ("minor" if tier == "" else tier)
    return "enemy_hazard_" + ("minor" if tier == "" else tier)

func _projectile_readability_priority(from_player: bool, label: String) -> float:
    if from_player:
        match _player_projectile_family(label):
            "laser", "artillery", "comet":
                return 0.72
            "rocket", "duelist", "juggernaut":
                return 0.62
            _:
                return 0.50
    return _enemy_projectile_readability_priority(label)

func _enemy_projectile_readability_priority(label: String) -> float:
    match _enemy_projectile_threat_tier(label):
        "boss":
            return 1.0
        "special":
            return 0.78
        "hazard":
            return 0.64
        _:
            return 0.45

func _player_projectile_role(family: String) -> String:
    match family:
        "rocket":
            return "marksman_demolition"
        "artillery":
            return "support_artillery"
        "duelist":
            return "melee_duelist"
        "laser":
            return "control_mage"
        "feather":
            return "recall_marksman"
        "poison":
            return "trap_summoner"
        "comet":
            return "celestial_mage"
        "juggernaut":
            return "melee_tank"
        _:
            return "generic_projectile"

func _player_projectile_source_champion(label: String) -> String:
    match _player_projectile_family(label):
        "rocket":
            return "jinx"
        "artillery":
            return "senna"
        "duelist":
            return "samira"
        "laser":
            return "viktor"
        "feather":
            return "xayah"
        "poison":
            return "teemo"
        "comet":
            return "aurelion_sol"
        "juggernaut":
            return "mordekaiser"
        _:
            return "generic"

func _player_projectile_role_profile_node_name(family: String) -> String:
    match family:
        "rocket":
            return "PlayerProjectileProfileRocketArtillery"
        "artillery":
            return "PlayerProjectileProfileSoulPiercer"
        "duelist":
            return "PlayerProjectileProfileDuelistBlades"
        "laser":
            return "PlayerProjectileProfileHexcoreCircuit"
        "feather":
            return "PlayerProjectileProfileFeatherRecall"
        "poison":
            return "PlayerProjectileProfilePoisonTrap"
        "comet":
            return "PlayerProjectileProfileStarForge"
        "juggernaut":
            return "PlayerProjectileProfileJuggernautSlam"
        _:
            return "PlayerProjectileProfileGeneric"

func _player_projectile_impact_intent_node_name(family: String) -> String:
    match family:
        "rocket":
            return "PlayerProjectileImpactRocketBurst"
        "artillery":
            return "PlayerProjectileImpactSoulPierce"
        "duelist":
            return "PlayerProjectileImpactDuelistCut"
        "laser":
            return "PlayerProjectileImpactHexcoreBurn"
        "feather":
            return "PlayerProjectileImpactFeatherRecall"
        "poison":
            return "PlayerProjectileImpactPoisonBloom"
        "comet":
            return "PlayerProjectileImpactStarFall"
        "juggernaut":
            return "PlayerProjectileImpactIronCrush"
        _:
            return "PlayerProjectileImpactGeneric"

func _player_projectile_spell_trail_node_name(family: String) -> String:
    match family:
        "rocket":
            return "PlayerProjectileTrailRocketExhaust"
        "artillery":
            return "PlayerProjectileTrailSoulBeam"
        "duelist":
            return "PlayerProjectileTrailDuelistSlice"
        "laser":
            return "PlayerProjectileTrailHexCircuit"
        "feather":
            return "PlayerProjectileTrailFeatherReturn"
        "poison":
            return "PlayerProjectileTrailPoisonSpores"
        "comet":
            return "PlayerProjectileTrailStarWake"
        "juggernaut":
            return "PlayerProjectileTrailIronWake"
        _:
            return "PlayerProjectileTrailGeneric"

func _add_player_projectile_role_profile(model: Node3D, radius: float, label: String, color: Color) -> void:
    if model.get_node_or_null("PlayerProjectileRoleProfile") != null:
        return
    var family := _player_projectile_family(label)
    var role := _player_projectile_role(family)
    var family_color := _player_projectile_family_color(label, color)
    var root := Node3D.new()
    root.name = "PlayerProjectileRoleProfile"
    root.set_meta("label", label)
    root.set_meta("family", family)
    root.set_meta("role", role)
    root.set_meta("source_champion", _player_projectile_source_champion(label))
    root.set_meta("detail_node", _player_projectile_role_profile_node_name(family))
    model.add_child(root)

    var soft := _mat("player_role_profile_soft_" + family, Color(family_color.r, family_color.g, family_color.b, 0.28), 0.96, true, true)
    var hot := _mat("player_role_profile_hot_" + family, Color(family_color.lightened(0.18).r, family_color.lightened(0.18).g, family_color.lightened(0.18).b, 0.54), 1.18, true, true)
    var gold := _mat("player_role_profile_gold_" + family, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.44), 0.82, true, true)
    var dark := _mat("player_role_profile_dark_" + family, Color(0.012, 0.010, 0.022, 0.48), 0.03, true, true)
    var y := -0.462

    var ring := _add_cylinder_segments(root, radius * 1.44, 0.010, 8, soft, Vector3(0, y, radius * 0.10), Vector3(0, 22.5, 0))
    ring.name = "PlayerProjectileRoleProfileRing"
    var plate := _add_box(root, Vector3(radius * 1.05, 0.010, radius * 0.12), gold, Vector3(0, y + 0.018, -radius * 0.82))
    plate.name = "PlayerProjectileClassPlate"

    var detail := Node3D.new()
    detail.name = _player_projectile_role_profile_node_name(family)
    root.add_child(detail)
    match family:
        "rocket":
            _add_tapered_cylinder(detail, radius * 0.15, radius * 0.035, radius * 1.20, 8, hot, Vector3(0, y + 0.060, -radius * 0.18), Vector3(90, 0, 0))
            _add_box(detail, Vector3(radius * 0.70, 0.012, radius * 0.11), gold, Vector3(0, y + 0.080, -radius * 0.88))
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_sphere(detail, radius * 0.052, hot, Vector3(cos(angle) * radius * 0.52, y + 0.092, -radius * 1.02 + sin(angle) * radius * 0.20))
        "artillery":
            _add_box(detail, Vector3(radius * 0.12, 0.012, radius * 1.80), hot, Vector3(0, y + 0.062, radius * 0.42))
            _add_cylinder_segments(detail, radius * 0.58, 0.010, 24, soft, Vector3(0, y + 0.078, radius * 1.22), Vector3(90, 0, 0))
            _add_sphere(detail, radius * 0.095, hot, Vector3(0, y + 0.100, radius * 1.22))
        "duelist":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.080, 0.012, radius * 1.36), hot, Vector3(side * radius * 0.18, y + 0.070, 0), Vector3(0, side * 30.0, side * 24.0))
            _add_cylinder_segments(detail, radius * 0.58, 0.010, 16, gold, Vector3(0, y + 0.088, -radius * 0.12), Vector3(90, 0, 0))
        "laser":
            _add_cylinder_segments(detail, radius * 0.62, 0.012, 6, hot, Vector3(0, y + 0.070, 0), Vector3(0, 30, 0))
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_box(detail, Vector3(radius * 0.044, 0.010, radius * 0.54), soft, Vector3(cos(angle) * radius * 0.44, y + 0.088, sin(angle) * radius * 0.44), Vector3(0, -rad_to_deg(angle), 0))
            _add_sphere(detail, radius * 0.080, hot, Vector3(0, y + 0.108, 0))
        "feather":
            for i in range(5):
                var offset := float(i) - 2.0
                _add_box(detail, Vector3(radius * 0.070, 0.012, radius * (1.00 - abs(offset) * 0.08)), hot, Vector3(offset * radius * 0.15, y + 0.070, -radius * 0.06 + abs(offset) * radius * 0.06), Vector3(0, offset * 12.0, offset * 13.0))
            _add_box(detail, Vector3(radius * 0.82, 0.010, radius * 0.060), gold, Vector3(0, y + 0.088, radius * 0.52))
        "poison":
            _add_cylinder(detail, radius * 0.090, radius * 0.28, dark, Vector3(0, y + 0.070, -radius * 0.02))
            _add_sphere(detail, radius * 0.30, hot, Vector3(0, y + 0.180, -radius * 0.02))
            for i in range(5):
                var angle := TAU * float(i) / 5.0
                _add_sphere(detail, radius * 0.050, soft, Vector3(cos(angle) * radius * 0.54, y + 0.090, sin(angle) * radius * 0.54))
        "comet":
            _add_cylinder_segments(detail, radius * 0.68, 0.010, 32, soft, Vector3(0, y + 0.072, 0), Vector3(90, 0, 0))
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_sphere(detail, radius * (0.090 if i == 0 else 0.060), hot, Vector3(cos(angle) * radius * 0.56, y + 0.094, sin(angle) * radius * 0.56))
            _add_box(detail, Vector3(radius * 0.070, 0.010, radius * 1.12), gold, Vector3(0, y + 0.088, 0), Vector3(0, 35, 0))
        "juggernaut":
            _add_box(detail, Vector3(radius * 0.22, 0.016, radius * 1.14), hot, Vector3(radius * 0.08, y + 0.078, -radius * 0.08), Vector3(0, -24, 0))
            _add_box(detail, Vector3(radius * 0.86, 0.018, radius * 0.22), gold, Vector3(radius * 0.48, y + 0.098, radius * 0.38), Vector3(0, -24, 0))
            _add_cylinder_segments(detail, radius * 0.74, 0.010, 8, dark, Vector3(0, y + 0.062, 0), Vector3(0, 22.5, 0))
        _:
            _add_cylinder_segments(detail, radius * 0.56, 0.010, 6, hot, Vector3(0, y + 0.070, 0), Vector3(0, 30, 0))

func _sync_player_projectile_role_profile(model: Node3D, id: int) -> void:
    var root := model.get_node_or_null("PlayerProjectileRoleProfile") as Node3D
    if root == null:
        return
    var family := str(root.get_meta("family", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var pulse_speed := 3.2
    if family == "rocket" or family == "duelist" or family == "poison":
        pulse_speed = 4.8
    elif family == "comet" or family == "artillery":
        pulse_speed = 2.6
    var pulse := 1.0 + sin(time * pulse_speed + float(id % 31)) * 0.035
    root.scale = Vector3(pulse, 1.0, pulse)
    root.rotation.y += 0.018 if family == "comet" or family == "poison" else -0.014
    var ring := root.get_node_or_null("PlayerProjectileRoleProfileRing") as Node3D
    if ring != null:
        ring.rotation.y += 0.030 if family == "laser" or family == "comet" else 0.018
    var detail_name := str(root.get_meta("detail_node", ""))
    var detail := root.get_node_or_null(detail_name) as Node3D
    if detail != null:
        detail.position.y = sin(time * (pulse_speed + 1.2) + float(id % 17)) * 0.008

func _add_player_projectile_impact_intent_profile(model: Node3D, radius: float, label: String, color: Color) -> void:
    if model.get_node_or_null("PlayerProjectileImpactIntentProfile") != null:
        return
    var family := _player_projectile_family(label)
    var family_color := _player_projectile_family_color(label, color)
    var root := Node3D.new()
    root.name = "PlayerProjectileImpactIntentProfile"
    root.set_meta("label", label)
    root.set_meta("family", family)
    root.set_meta("source_champion", _player_projectile_source_champion(label))
    root.set_meta("detail_node", _player_projectile_impact_intent_node_name(family))
    model.add_child(root)

    var soft := _mat("player_impact_intent_soft_" + family, Color(family_color.r, family_color.g, family_color.b, 0.24), 0.92, true, true)
    var hot := _mat("player_impact_intent_hot_" + family, Color(family_color.lightened(0.18).r, family_color.lightened(0.18).g, family_color.lightened(0.18).b, 0.50), 1.16, true, true)
    var gold := _mat("player_impact_intent_gold_" + family, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.38), 0.78, true, true)
    var y := -0.356
    var front_z := radius * 1.82

    var frame := _add_cylinder_segments(root, radius * 0.72, 0.010, 8, soft, Vector3(0, y, front_z), Vector3(90, 0, 22.5))
    frame.name = "PlayerProjectileImpactIntentFrame"
    var core := _add_sphere(root, radius * 0.080, hot, Vector3(0, y + 0.040, front_z))
    core.name = "PlayerProjectileImpactIntentCore"

    var detail := Node3D.new()
    detail.name = _player_projectile_impact_intent_node_name(family)
    root.add_child(detail)
    match family:
        "rocket":
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_box(detail, Vector3(radius * 0.070, 0.010, radius * 0.46), hot if i % 2 == 0 else gold, Vector3(cos(angle) * radius * 0.36, y + 0.070, front_z + sin(angle) * radius * 0.30), Vector3(0, -rad_to_deg(angle), 0))
        "artillery":
            _add_box(detail, Vector3(radius * 0.090, 0.010, radius * 1.14), hot, Vector3(0, y + 0.068, front_z + radius * 0.30))
            _add_cylinder_segments(detail, radius * 0.42, 0.010, 24, soft, Vector3(0, y + 0.088, front_z + radius * 0.72), Vector3(90, 0, 0))
        "duelist":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.070, 0.010, radius * 0.92), hot, Vector3(side * radius * 0.18, y + 0.070, front_z + radius * 0.14), Vector3(0, side * 32.0, side * 24.0))
            _add_box(detail, Vector3(radius * 0.58, 0.010, radius * 0.065), gold, Vector3(0, y + 0.088, front_z + radius * 0.62))
        "laser":
            _add_cylinder_segments(detail, radius * 0.44, 0.010, 6, hot, Vector3(0, y + 0.070, front_z), Vector3(0, 30, 0))
            for i in range(3):
                var angle := TAU * float(i) / 3.0
                _add_box(detail, Vector3(radius * 0.042, 0.010, radius * 0.60), soft, Vector3(cos(angle) * radius * 0.34, y + 0.088, front_z + sin(angle) * radius * 0.34), Vector3(0, -rad_to_deg(angle), 0))
        "feather":
            for i in range(5):
                var offset := float(i) - 2.0
                _add_box(detail, Vector3(radius * 0.054, 0.010, radius * (0.70 - abs(offset) * 0.05)), hot, Vector3(offset * radius * 0.12, y + 0.070, front_z + abs(offset) * radius * 0.06), Vector3(0, offset * 13.0, offset * 16.0))
        "poison":
            _add_sphere(detail, radius * 0.18, hot, Vector3(0, y + 0.086, front_z))
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_sphere(detail, radius * 0.050, soft, Vector3(cos(angle) * radius * 0.34, y + 0.068, front_z + sin(angle) * radius * 0.28))
        "comet":
            _add_cylinder_segments(detail, radius * 0.48, 0.010, 5, soft, Vector3(0, y + 0.070, front_z), Vector3(0, 18, 0))
            _add_box(detail, Vector3(radius * 0.060, 0.010, radius * 0.92), gold, Vector3(0, y + 0.090, front_z), Vector3(0, 36, 0))
            _add_box(detail, Vector3(radius * 0.060, 0.010, radius * 0.92), hot, Vector3(0, y + 0.092, front_z), Vector3(0, -36, 0))
        "juggernaut":
            _add_box(detail, Vector3(radius * 0.18, 0.012, radius * 0.82), hot, Vector3(radius * 0.08, y + 0.070, front_z), Vector3(0, -24, 0))
            _add_box(detail, Vector3(radius * 0.76, 0.014, radius * 0.20), gold, Vector3(radius * 0.34, y + 0.092, front_z + radius * 0.28), Vector3(0, -24, 0))
        _:
            _add_cylinder_segments(detail, radius * 0.38, 0.010, 6, hot, Vector3(0, y + 0.070, front_z), Vector3(0, 30, 0))

func _sync_player_projectile_impact_intent_profile(model: Node3D, id: int) -> void:
    var root := model.get_node_or_null("PlayerProjectileImpactIntentProfile") as Node3D
    if root == null:
        return
    var family := str(root.get_meta("family", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var speed := 4.2
    match family:
        "rocket", "duelist", "poison":
            speed = 5.6
        "artillery", "laser":
            speed = 3.2
        "comet":
            speed = 2.8
        _:
            pass
    var pulse := 1.0 + sin(time * speed + float(id % 29)) * 0.038
    root.scale = Vector3(1.0 + (pulse - 1.0) * 0.52, 1.0, pulse)
    root.rotation.y += 0.026 if family == "rocket" or family == "duelist" else -0.018
    var frame := root.get_node_or_null("PlayerProjectileImpactIntentFrame") as Node3D
    if frame != null:
        frame.rotation.y += 0.030 if family == "laser" or family == "comet" else -0.022
    var detail_name := str(root.get_meta("detail_node", ""))
    var detail := root.get_node_or_null(detail_name) as Node3D
    if detail != null:
        detail.position.y = sin(time * (speed + 1.4) + float(id % 17)) * 0.008

func _add_player_projectile_spell_trail_profile(model: Node3D, radius: float, label: String, color: Color) -> void:
    if model.get_node_or_null("PlayerProjectileSpellTrailProfile") != null:
        return
    var family := _player_projectile_family(label)
    var family_color := _player_projectile_family_color(label, color)
    var root := Node3D.new()
    root.name = "PlayerProjectileSpellTrailProfile"
    root.set_meta("label", label)
    root.set_meta("family", family)
    root.set_meta("source_champion", _player_projectile_source_champion(label))
    root.set_meta("detail_node", _player_projectile_spell_trail_node_name(family))
    model.add_child(root)

    var soft := _mat("player_spell_trail_soft_" + family, Color(family_color.r, family_color.g, family_color.b, 0.20), 0.86, true, true)
    var hot := _mat("player_spell_trail_hot_" + family, Color(family_color.lightened(0.20).r, family_color.lightened(0.20).g, family_color.lightened(0.20).b, 0.48), 1.20, true, true)
    var gold := _mat("player_spell_trail_gold_" + family, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.36), 0.78, true, true)
    var y := -0.246
    var trail_length := radius * 4.35
    var trail_width := radius * 0.24
    match family:
        "artillery", "laser":
            trail_length = radius * 6.10
            trail_width = radius * 0.16
        "comet":
            trail_length = radius * 5.65
            trail_width = radius * 0.42
        "feather", "poison":
            trail_length = radius * 3.82
        "juggernaut":
            trail_width = radius * 0.42
        _:
            pass

    var spine := _add_box(root, Vector3(trail_width, 0.010, trail_length), soft, Vector3(0, y, -radius * 1.02))
    spine.name = "PlayerProjectileTrailSpine"
    var bloom := _add_cylinder_segments(root, radius * 0.76, 0.008, 6, hot, Vector3(0, y + 0.020, radius * 0.86), Vector3(0, 30, 0))
    bloom.name = "PlayerProjectileTrailBloom"

    var detail_name := _player_projectile_spell_trail_node_name(family)
    var detail: Node3D = null
    match family:
        "rocket":
            detail = _add_tapered_cylinder(root, radius * 0.16, radius * 0.020, radius * 1.35, 8, hot, Vector3(0, y + 0.040, -radius * 2.02), Vector3(72, 0, 0))
        "artillery":
            detail = _add_box(root, Vector3(radius * 0.11, 0.010, radius * 2.18), hot, Vector3(0, y + 0.040, radius * 0.72))
        "duelist":
            detail = _add_box(root, Vector3(radius * 0.085, 0.010, radius * 1.54), hot, Vector3(-radius * 0.16, y + 0.042, -radius * 0.18), Vector3(0, -28, 0))
            _add_box(root, Vector3(radius * 0.085, 0.010, radius * 1.54), hot, Vector3(radius * 0.16, y + 0.046, -radius * 0.02), Vector3(0, 28, 0))
        "laser":
            detail = _add_cylinder_segments(root, radius * 0.48, 0.010, 6, hot, Vector3(0, y + 0.044, radius * 0.50), Vector3(0, 30, 0))
            _add_box(root, Vector3(radius * 0.050, 0.010, radius * 1.46), gold, Vector3(radius * 0.34, y + 0.056, radius * 0.42), Vector3(0, 14, 0))
        "feather":
            detail = _add_box(root, Vector3(radius * 0.058, 0.010, radius * 1.26), hot, Vector3(0, y + 0.044, -radius * 0.28), Vector3(0, 16, 0))
            _add_box(root, Vector3(radius * 0.050, 0.010, radius * 0.96), hot, Vector3(-radius * 0.24, y + 0.048, -radius * 0.12), Vector3(0, -12, 0))
            _add_box(root, Vector3(radius * 0.050, 0.010, radius * 0.96), hot, Vector3(radius * 0.24, y + 0.048, -radius * 0.12), Vector3(0, 12, 0))
        "poison":
            detail = _add_sphere(root, radius * 0.16, hot, Vector3(0, y + 0.062, -radius * 0.78))
            for i in range(3):
                var spore_angle := TAU * float(i) / 3.0
                _add_sphere(root, radius * 0.052, hot, Vector3(cos(spore_angle) * radius * 0.46, y + 0.052, -radius * 1.14 + sin(spore_angle) * radius * 0.26))
        "comet":
            detail = _add_box(root, Vector3(radius * 0.070, 0.010, radius * 2.20), gold, Vector3(0, y + 0.052, -radius * 0.74), Vector3(0, 35, 0))
            _add_sphere(root, radius * 0.090, hot, Vector3(radius * 0.38, y + 0.070, -radius * 1.62))
            _add_sphere(root, radius * 0.065, hot, Vector3(-radius * 0.46, y + 0.060, -radius * 1.02))
        "juggernaut":
            detail = _add_box(root, Vector3(radius * 0.22, 0.012, radius * 1.58), hot, Vector3(radius * 0.14, y + 0.048, -radius * 0.22), Vector3(0, -24, 0))
            _add_box(root, Vector3(radius * 0.88, 0.014, radius * 0.20), gold, Vector3(radius * 0.54, y + 0.066, radius * 0.56), Vector3(0, -24, 0))
        _:
            detail = _add_box(root, Vector3(radius * 0.090, 0.010, radius * 1.56), hot, Vector3(0, y + 0.044, -radius * 0.34), Vector3(0, 45, 0))
    if detail != null:
        detail.name = detail_name

func _sync_player_projectile_spell_trail_profile(model: Node3D, id: int) -> void:
    var root := model.get_node_or_null("PlayerProjectileSpellTrailProfile") as Node3D
    if root == null:
        return
    var family := str(root.get_meta("family", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var speed := 3.6
    match family:
        "rocket", "duelist", "poison":
            speed = 5.0
        "artillery", "laser":
            speed = 2.8
        "comet":
            speed = 2.4
        _:
            pass
    var pulse := 1.0 + sin(time * speed + float(id % 37)) * 0.040
    root.scale = Vector3(1.0 + (pulse - 1.0) * 0.36, 1.0, pulse)
    root.position.y = sin(time * (speed + 1.8) + float(id % 19)) * 0.006
    var bloom := root.get_node_or_null("PlayerProjectileTrailBloom") as Node3D
    if bloom != null:
        bloom.rotation.y += 0.034 if family == "comet" or family == "poison" else -0.024
    var detail_name := str(root.get_meta("detail_node", ""))
    var detail := root.get_node_or_null(detail_name) as Node3D
    if detail != null:
        match family:
            "duelist", "feather":
                detail.rotation.y += 0.032
            "comet", "laser":
                detail.rotation.y -= 0.022
            _:
                detail.position.z += sin(time * speed + float(id % 11)) * 0.002

func _player_projectile_premium_detail_node(family: String) -> String:
    match family:
        "rocket":
            return "PlayerProjectilePremiumRocketWarhead"
        "artillery":
            return "PlayerProjectilePremiumSoulFocusLens"
        "duelist":
            return "PlayerProjectilePremiumDuelistEdge"
        "laser":
            return "PlayerProjectilePremiumHexcorePrism"
        "feather":
            return "PlayerProjectilePremiumFeatherInlay"
        "poison":
            return "PlayerProjectilePremiumPoisonVial"
        "comet":
            return "PlayerProjectilePremiumStarCore"
        "juggernaut":
            return "PlayerProjectilePremiumIronHead"
        _:
            return "PlayerProjectilePremiumGenericHead"

func _add_player_projectile_premium_fx_rig(model: Node3D, radius: float, label: String, color: Color) -> void:
    if model.get_node_or_null("PlayerProjectilePremiumFxRig") != null:
        return
    var family := _player_projectile_family(label)
    var family_color := _player_projectile_family_color(label, color)
    var detail_name := _player_projectile_premium_detail_node(family)
    var rig := Node3D.new()
    rig.name = "PlayerProjectilePremiumFxRig"
    rig.set_meta("label", label)
    rig.set_meta("family", family)
    rig.set_meta("source_champion", _player_projectile_source_champion(label))
    rig.set_meta("detail_node", detail_name)
    rig.set_meta("material_grade", "premium_projectile_fx")
    rig.set_meta("combat_visual_channel", "player_skill")
    model.add_child(rig)

    var soft := _mat("player_projectile_premium_soft_" + family, Color(family_color.r, family_color.g, family_color.b, 0.28), 0.94, true, true)
    var hot := _mat("player_projectile_premium_hot_" + family, Color(family_color.lightened(0.20).r, family_color.lightened(0.20).g, family_color.lightened(0.20).b, 0.56), 1.22, true, true)
    var gold := _mat("player_projectile_premium_gold_" + family, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42), 0.86, true, true)
    var dark := _mat("player_projectile_premium_dark_" + family, Color(0.018, 0.014, 0.030, 0.58), 0.10, true, true)
    var y := -0.132
    var front_z := radius * 1.36

    var core_shell := Node3D.new()
    core_shell.name = "PlayerProjectilePremiumCoreShell"
    core_shell.set_meta("family", family)
    rig.add_child(core_shell)
    _add_sphere(core_shell, radius * 0.18, hot, Vector3(0, y + 0.050, front_z))
    _add_cylinder_segments(core_shell, radius * 0.54, 0.010, 6, soft, Vector3(0, y + 0.028, front_z), Vector3(90, 0, 30))

    var rim := _add_cylinder_segments(rig, radius * 0.74, 0.010, 8, gold, Vector3(0, y, front_z - radius * 0.14), Vector3(90, 0, 22.5))
    rim.name = "PlayerProjectilePremiumEnergyRim"
    rim.set_meta("family", family)

    var bands := Node3D.new()
    bands.name = "PlayerProjectilePremiumMaterialBands"
    bands.set_meta("material_grade", "premium_projectile_fx")
    rig.add_child(bands)
    _add_box(bands, Vector3(radius * 0.10, 0.012, radius * 1.08), soft, Vector3(0, y + 0.034, front_z - radius * 0.62))
    _add_box(bands, Vector3(radius * 0.82, 0.012, radius * 0.052), gold, Vector3(0, y + 0.048, front_z + radius * 0.32))

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("family", family)
    rig.add_child(detail)

    match family:
        "rocket":
            _add_tapered_cylinder(detail, radius * 0.18, radius * 0.040, radius * 0.92, 8, hot, Vector3(0, y + 0.074, front_z + radius * 0.32), Vector3(90, 0, 0))
            for fin in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.080, 0.014, radius * 0.62), gold, Vector3(fin * radius * 0.30, y + 0.060, front_z - radius * 0.34), Vector3(0, fin * 18.0, fin * 18.0))
        "artillery":
            _add_box(detail, Vector3(radius * 0.090, 0.012, radius * 1.42), hot, Vector3(0, y + 0.070, front_z + radius * 0.20))
            _add_cylinder_segments(detail, radius * 0.40, 0.010, 24, soft, Vector3(0, y + 0.092, front_z + radius * 0.76), Vector3(90, 0, 0))
            _add_sphere(detail, radius * 0.060, gold, Vector3(0, y + 0.118, front_z + radius * 0.76))
        "duelist":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.060, 0.012, radius * 1.10), hot, Vector3(side * radius * 0.16, y + 0.068, front_z), Vector3(0, side * 35.0, side * 22.0))
            _add_cylinder_segments(detail, radius * 0.46, 0.010, 6, gold, Vector3(0, y + 0.086, front_z + radius * 0.20), Vector3(0, 30, 0))
        "laser":
            _add_box(detail, Vector3(radius * 0.080, 0.012, radius * 1.46), hot, Vector3(0, y + 0.070, front_z + radius * 0.28))
            _add_cylinder_segments(detail, radius * 0.46, 0.010, 6, soft, Vector3(0, y + 0.092, front_z), Vector3(0, 30, 0))
            for circuit in range(3):
                var circuit_angle := TAU * float(circuit) / 3.0
                _add_box(detail, Vector3(radius * 0.040, 0.010, radius * 0.42), gold, Vector3(cos(circuit_angle) * radius * 0.38, y + 0.104, front_z + sin(circuit_angle) * radius * 0.28), Vector3(0, -rad_to_deg(circuit_angle), 0))
        "feather":
            for plume in range(5):
                var plume_offset := float(plume) - 2.0
                _add_box(detail, Vector3(radius * 0.052, 0.012, radius * (0.88 - abs(plume_offset) * 0.07)), hot, Vector3(plume_offset * radius * 0.12, y + 0.070, front_z + abs(plume_offset) * radius * 0.06), Vector3(0, plume_offset * 10.0, plume_offset * 14.0))
        "poison":
            _add_cylinder(detail, radius * 0.090, radius * 0.32, dark, Vector3(0, y + 0.070, front_z - radius * 0.10))
            _add_sphere(detail, radius * 0.25, hot, Vector3(0, y + 0.182, front_z - radius * 0.10))
            for spore in range(4):
                var spore_angle := TAU * float(spore) / 4.0
                _add_sphere(detail, radius * 0.044, soft, Vector3(cos(spore_angle) * radius * 0.42, y + 0.092, front_z + sin(spore_angle) * radius * 0.30))
        "comet":
            _add_sphere(detail, radius * 0.34, hot, Vector3(0, y + 0.090, front_z))
            _add_cylinder_segments(detail, radius * 0.60, 0.010, 5, soft, Vector3(0, y + 0.066, front_z), Vector3(0, 18, 0))
            _add_box(detail, Vector3(radius * 0.060, 0.012, radius * 1.02), gold, Vector3(0, y + 0.108, front_z), Vector3(0, 36, 0))
        "juggernaut":
            _add_box(detail, Vector3(radius * 0.24, 0.018, radius * 0.92), dark, Vector3(radius * 0.08, y + 0.070, front_z), Vector3(0, -24, 0))
            _add_box(detail, Vector3(radius * 0.72, 0.020, radius * 0.22), hot, Vector3(radius * 0.38, y + 0.098, front_z + radius * 0.28), Vector3(0, -24, 0))
            _add_cylinder_segments(detail, radius * 0.46, 0.010, 6, gold, Vector3(radius * 0.10, y + 0.060, front_z - radius * 0.22), Vector3(0, 30, 0))
        _:
            _add_cylinder_segments(detail, radius * 0.42, 0.010, 6, hot, Vector3(0, y + 0.070, front_z), Vector3(0, 30, 0))

func _sync_player_projectile_premium_fx_rig(model: Node3D, id: int) -> void:
    var rig := model.get_node_or_null("PlayerProjectilePremiumFxRig") as Node3D
    if rig == null:
        return
    var family := str(rig.get_meta("family", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var pulse_speed := 3.4
    match family:
        "rocket", "duelist", "poison":
            pulse_speed = 5.0
        "artillery", "laser":
            pulse_speed = 2.8
        "comet":
            pulse_speed = 2.4
        _:
            pass
    var pulse := 1.0 + sin(time * pulse_speed + float(id % 41)) * 0.034
    rig.scale = Vector3(1.0 + (pulse - 1.0) * 0.40, 1.0, pulse)
    rig.position.y = sin(time * (pulse_speed + 1.1) + float(id % 23)) * 0.006
    var rim := rig.get_node_or_null("PlayerProjectilePremiumEnergyRim") as Node3D
    if rim != null:
        rim.rotation.y += 0.036 if family == "laser" or family == "comet" else -0.026
    var shell := rig.get_node_or_null("PlayerProjectilePremiumCoreShell") as Node3D
    if shell != null:
        shell.scale = Vector3.ONE * (1.0 + (pulse - 1.0) * 0.68)
    var detail := rig.get_node_or_null(str(rig.get_meta("detail_node", ""))) as Node3D
    if detail != null:
        if family == "duelist" or family == "feather":
            detail.rotation.y += 0.034
        elif family == "laser" or family == "comet":
            detail.rotation.y -= 0.026
        else:
            detail.position.y = sin(time * (pulse_speed + 1.8) + float(id % 17)) * 0.006

func _champion_projectile_mechanic_detail_node(family: String) -> String:
    match family:
        "rocket":
            return "ChampionProjectileMechanicJinxRocketRack"
        "artillery":
            return "ChampionProjectileMechanicSennaRelicBeam"
        "duelist":
            return "ChampionProjectileMechanicSamiraBladeArc"
        "laser":
            return "ChampionProjectileMechanicViktorLaserCircuit"
        "feather":
            return "ChampionProjectileMechanicXayahFeatherRecall"
        "poison":
            return "ChampionProjectileMechanicTeemoPoisonDart"
        "comet":
            return "ChampionProjectileMechanicAsolOrbitComet"
        "juggernaut":
            return "ChampionProjectileMechanicMordeIronWake"
        _:
            return "ChampionProjectileMechanicGenericSpell"

func _add_champion_projectile_mechanic_silhouette_rig(model: Node3D, radius: float, label: String, color: Color) -> void:
    if model.get_node_or_null("ChampionProjectileMechanicSilhouetteRig") != null:
        return
    var family := _player_projectile_family(label)
    var family_color := _player_projectile_family_color(label, color)
    var detail_name := _champion_projectile_mechanic_detail_node(family)
    var rig := Node3D.new()
    rig.name = "ChampionProjectileMechanicSilhouetteRig"
    rig.set_meta("label", label)
    rig.set_meta("family", family)
    rig.set_meta("source_champion", _player_projectile_source_champion(label))
    rig.set_meta("detail_node", detail_name)
    rig.set_meta("combat_visual_channel", "player_projectile_mechanic_readability")
    rig.set_meta("material_grade", "low_glare_champion_projectile_mechanic")
    rig.set_meta("role_profile", _player_projectile_role(family))
    rig.set_meta("non_lite_only", true)
    model.add_child(rig)

    var soft := _mat("player_projectile_mechanic_soft_" + family, Color(family_color.r, family_color.g, family_color.b, 0.24), 0.26, true, true)
    var hot := _mat("player_projectile_mechanic_hot_" + family, Color(family_color.lightened(0.18).r, family_color.lightened(0.18).g, family_color.lightened(0.18).b, 0.28), 0.38, true, true)
    var gold := _mat("player_projectile_mechanic_gold_" + family, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.26), 0.22, true, true)
    var dark := _mat("player_projectile_mechanic_dark_" + family, Color(0.016, 0.014, 0.024, 1.0), 0.0, true)
    var y := -0.066
    var rail_length := radius * 2.70
    var rail_width := radius * 0.28
    match family:
        "artillery", "laser":
            rail_length = radius * 4.10
            rail_width = radius * 0.16
        "comet":
            rail_length = radius * 3.35
            rail_width = radius * 0.42
        "feather":
            rail_length = radius * 2.45
            rail_width = radius * 0.22
        "juggernaut":
            rail_length = radius * 2.25
            rail_width = radius * 0.48
        _:
            pass

    var shadow := _add_cylinder_segments(rig, radius * 0.96, 0.010, 6, dark, Vector3(0, y - 0.018, -radius * 0.16), Vector3(0, 30, 0))
    shadow.name = "ChampionProjectileMechanicShadowPlate"
    var rail := _add_box(rig, Vector3(rail_width, 0.010, rail_length), soft, Vector3(0, y, -radius * 0.32))
    rail.name = "ChampionProjectileMechanicDirectionRail"
    var anchor := _add_cylinder_segments(rig, radius * 0.46, 0.010, 6, gold, Vector3(0, y + 0.020, radius * 0.96), Vector3(0, 30, 0))
    anchor.name = "ChampionProjectileMechanicImpactAnchor"

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("family", family)
    rig.add_child(detail)

    match family:
        "rocket":
            _add_tapered_cylinder(detail, radius * 0.12, radius * 0.028, radius * 0.96, 8, hot, Vector3(0, y + 0.048, radius * 0.16), Vector3(90, 0, 0))
        "artillery":
            _add_box(detail, Vector3(radius * 0.075, 0.010, radius * 1.90), hot, Vector3(0, y + 0.046, radius * 0.48))
        "duelist":
            _add_box(detail, Vector3(radius * 0.080, 0.010, radius * 1.48), hot, Vector3(0, y + 0.050, 0), Vector3(0, -35, 0))
        "laser":
            _add_cylinder_segments(detail, radius * 0.48, 0.010, 6, hot, Vector3(0, y + 0.050, radius * 0.34), Vector3(0, 30, 0))
        "feather":
            _add_box(detail, Vector3(radius * 0.082, 0.010, radius * 1.20), hot, Vector3(0, y + 0.050, -radius * 0.08), Vector3(0, 16, 12))
        "poison":
            _add_tapered_cylinder(detail, radius * 0.095, radius * 0.018, radius * 0.92, 8, hot, Vector3(0, y + 0.052, radius * 0.16), Vector3(90, 0, 0))
        "comet":
            _add_cylinder_segments(detail, radius * 0.58, 0.010, 5, soft, Vector3(0, y + 0.046, radius * 0.28), Vector3(0, 18, 0))
        "juggernaut":
            _add_box(detail, Vector3(radius * 0.22, 0.016, radius * 0.76), hot, Vector3(radius * 0.10, y + 0.052, radius * 0.02), Vector3(0, -24, 0))
        _:
            _add_cylinder_segments(detail, radius * 0.44, 0.010, 6, hot, Vector3(0, y + 0.050, 0), Vector3(0, 30, 0))

func _sync_champion_projectile_mechanic_silhouette_rig(model: Node3D, id: int) -> void:
    var rig := model.get_node_or_null("ChampionProjectileMechanicSilhouetteRig") as Node3D
    if rig == null:
        return
    var family := str(rig.get_meta("family", ""))
    var time := Time.get_ticks_msec() / 1000.0
    var speed := 3.2
    match family:
        "rocket", "duelist", "poison":
            speed = 4.8
        "artillery", "laser":
            speed = 2.6
        "comet":
            speed = 2.2
        _:
            pass
    var pulse := 1.0 + sin(time * speed + float(id % 43)) * 0.026
    rig.scale = Vector3(1.0 + (pulse - 1.0) * 0.34, 1.0, pulse)
    rig.position.y = sin(time * (speed + 0.8) + float(id % 31)) * 0.004
    var anchor := rig.get_node_or_null("ChampionProjectileMechanicImpactAnchor") as Node3D
    if anchor != null:
        anchor.rotation.y += 0.026 if family == "laser" or family == "comet" else -0.018
    var detail := rig.get_node_or_null(str(rig.get_meta("detail_node", ""))) as Node3D
    if detail != null:
        if family == "duelist" or family == "feather":
            detail.rotation.y += 0.026
        elif family == "comet" or family == "laser":
            detail.rotation.y -= 0.020
        else:
            detail.position.y = sin(time * (speed + 1.2) + float(id % 19)) * 0.004

func _add_player_projectile_signature_rig(model: Node3D, radius: float, label: String, color: Color, lite: bool) -> void:
    var rig := Node3D.new()
    rig.name = "PlayerProjectileSignatureRig"
    rig.set_meta("label", label)
    model.add_child(rig)
    var alpha := 0.22 if lite else 0.34
    var glow := _mat("player_proj_sig_" + label + "_" + color.to_html(false), Color(color.r, color.g, color.b, alpha), 0.94, true, true)
    var hot := _mat("player_proj_sig_hot_" + label + "_" + color.to_html(false), Color(color.lightened(0.18).r, color.lightened(0.18).g, color.lightened(0.18).b, 0.42 if not lite else 0.28), 1.05, true, true)
    var y := -0.50
    if lite:
        _add_player_projectile_signature_lite(rig, radius, label, color, glow, hot, y)
        return
    match label:
        "fishbones", "death_rocket":
            _add_cylinder_segments(rig, radius * (1.55 if lite else 1.95), 0.012, 10, glow, Vector3(0, y, -radius * 0.72), Vector3(0, 18, 0))
            if not lite:
                for i in range(5):
                    var burst_angle := TAU * float(i) / 5.0
                    _add_tapered_cylinder(rig, radius * 0.050, radius * 0.006, radius * 0.82, 6, hot, Vector3(cos(burst_angle) * radius * 0.72, y + 0.016, -radius * 0.72 + sin(burst_angle) * radius * 0.72), Vector3(74, -rad_to_deg(burst_angle), 0))
        "senna_beam", "senna_snare":
            _add_box(rig, Vector3(radius * 0.22, 0.012, radius * (4.60 if lite else 5.80)), glow, Vector3(0, y, radius * 0.90))
            _add_cylinder_segments(rig, radius * (0.78 if lite else 1.05), 0.012, 24, hot, Vector3(0, y + 0.018, radius * 1.64), Vector3(90, 0, 0))
        "samira_pistol", "powpow":
            var lane_width := radius * (1.00 if lite else 1.34)
            _add_box(rig, Vector3(lane_width, 0.012, radius * 0.11), glow, Vector3(0, y, -radius * 0.86))
            _add_box(rig, Vector3(radius * 0.10, 0.012, radius * (2.40 if lite else 3.20)), hot, Vector3(0, y + 0.016, radius * 0.22), Vector3(0, 0, 0))
            if not lite:
                _add_cylinder_segments(rig, radius * 0.70, 0.010, 24, glow, Vector3(0, y + 0.026, 0), Vector3(90, 0, 0))
        "viktor_laser":
            _add_cylinder_segments(rig, radius * (0.92 if lite else 1.18), 0.012, 6, glow, Vector3(0, y, radius * 0.34), Vector3(0, 30, 0))
            for i in range(3 if lite else 6):
                var circuit_angle := TAU * float(i) / float(3 if lite else 6)
                _add_box(rig, Vector3(radius * 0.070, 0.012, radius * 1.10), hot, Vector3(cos(circuit_angle) * radius * 0.64, y + 0.018, sin(circuit_angle) * radius * 0.64 + radius * 0.34), Vector3(0, -rad_to_deg(circuit_angle), 0))
        "xayah_feather", "xayah_recall":
            var feather_count := 3 if lite else 5
            for i in range(feather_count):
                var offset := float(i) - float(feather_count - 1) * 0.5
                _add_box(rig, Vector3(radius * 0.13, 0.012, radius * (1.55 - abs(offset) * 0.10)), glow, Vector3(offset * radius * 0.25, y, -radius * 0.14 + abs(offset) * radius * 0.10), Vector3(0, offset * 12.0, 0))
        "teemo_dart", "blind_dart":
            _add_cylinder_segments(rig, radius * (0.86 if lite else 1.12), 0.012, 16, glow, Vector3(0, y, -radius * 0.18), Vector3.ZERO)
            var spore_count := 3 if lite else 6
            for i in range(spore_count):
                var spore_angle := TAU * float(i) / float(spore_count)
                _add_sphere(rig, radius * 0.090, hot, Vector3(cos(spore_angle) * radius * 0.72, y + 0.020, -radius * 0.18 + sin(spore_angle) * radius * 0.72))
        "comet":
            _add_cylinder_segments(rig, radius * (1.00 if lite else 1.32), 0.012, 5, glow, Vector3(0, y, radius * 0.10), Vector3(0, 18, 0))
            _add_box(rig, Vector3(radius * 0.12, 0.012, radius * (3.40 if lite else 4.50)), hot, Vector3(0, y + 0.018, -radius * 0.92), Vector3(0, 30, 0))
        _:
            _add_cylinder_segments(rig, radius * (0.82 if lite else 1.02), 0.012, 6, glow, Vector3(0, y, 0), Vector3(0, 30, 0))
    _add_player_projectile_hero_glyph(rig, radius, label, color, lite)

func _add_player_projectile_signature_lite(rig: Node3D, radius: float, label: String, color: Color, glow: Material, hot: Material, y: float) -> void:
    var family := _player_projectile_family(label)
    match family:
        "rocket", "artillery", "laser", "comet":
            _add_box(rig, Vector3(radius * 0.11, 0.010, radius * 2.35), hot, Vector3(0, y + 0.018, radius * 0.36))
        "duelist", "feather":
            _add_box(rig, Vector3(radius * 0.14, 0.010, radius * 1.55), hot, Vector3(0, y + 0.018, 0), Vector3(0, 24, 0))
        "poison":
            _add_sphere(rig, radius * 0.15, hot, Vector3(0, y + 0.030, 0))
        _:
            _add_box(rig, Vector3(radius * 0.10, 0.010, radius * 1.55), glow, Vector3(0, y + 0.018, 0), Vector3(0, 45, 0))

func _add_player_projectile_hero_glyph(rig: Node3D, radius: float, label: String, color: Color, lite: bool) -> void:
    if lite:
        return
    var decal_path := _vfx_decal_texture_path()
    if decal_path == "":
        return
    var uv_offset := _projectile_vfx_atlas_offset(label, true)
    var tint := Color(color.r, color.g, color.b, 0.18 if lite else 0.30)
    var emission := 0.48 if lite else 0.78
    var glyph_size := radius * (1.30 if lite else 1.72)
    var z_offset := radius * 0.18
    match label:
        "fishbones", "death_rocket", "samira_pistol", "powpow":
            uv_offset = Vector3(0.50, 0.50, 0.0)
            tint = Color(1.0, 0.58, 0.20, 0.20 if lite else 0.34)
            z_offset = -radius * 0.56
        "senna_beam", "senna_snare", "viktor_laser":
            uv_offset = Vector3(0.0, 0.50, 0.0)
            tint = Color(0.66, 0.96, 1.0, 0.18 if lite else 0.30)
            glyph_size *= 0.92
            z_offset = radius * 0.88
        "xayah_feather", "xayah_recall":
            uv_offset = Vector3(0.75, 0.50, 0.0)
            tint = Color(1.0, 0.32, 0.82, 0.18 if lite else 0.32)
            z_offset = -radius * 0.12
        "teemo_dart", "blind_dart":
            uv_offset = Vector3(0.75, 0.75, 0.0)
            tint = Color(0.58, 1.0, 0.24, 0.17 if lite else 0.30)
            glyph_size *= 0.86
            z_offset = -radius * 0.24
        "comet":
            uv_offset = Vector3(0.25, 0.0, 0.0)
            tint = Color(0.88, 0.56, 1.0, 0.20 if lite else 0.34)
            glyph_size *= 1.08
            z_offset = -radius * 0.38
        _:
            pass
    var mat := _vfx_decal_mat("player_projectile_hero_glyph_" + label, decal_path, tint, emission, Vector3(0.25, 0.25, 1.0), uv_offset)
    var glyph := _add_textured_plane(rig, Vector2(glyph_size, glyph_size), mat, Vector3(0, -0.532, z_offset))
    glyph.name = "PlayerProjectileHeroGlyph"

func _player_projectile_signature_speed(label: String) -> float:
    match label:
        "fishbones", "death_rocket", "samira_pistol", "powpow":
            return 0.050
        "viktor_laser", "senna_beam", "senna_snare":
            return 0.018
        "xayah_feather", "xayah_recall":
            return -0.032
        "teemo_dart", "blind_dart":
            return 0.040
        "comet":
            return -0.026
        _:
            return 0.024

func _player_projectile_signature_pulse(label: String) -> float:
    match label:
        "fishbones", "death_rocket", "samira_pistol", "powpow":
            return 5.2
        "teemo_dart", "blind_dart":
            return 3.8
        "comet":
            return 2.4
        _:
            return 3.0

func _add_player_projectile_shape_lite(model: Node3D, radius: float, label: String, fallback_color: Color) -> void:
    var color := fallback_color
    match label:
        "fishbones", "death_rocket":
            color = Color(1.0, 0.34, 0.42) if label == "death_rocket" else Color(1.0, 0.66, 0.18)
            _add_tapered_cylinder(model, radius * 0.34, radius * 0.10, radius * 2.55, 6, _mat("lite_rocket_body_" + label, color, 0.72, true), Vector3(0, 0, radius * 0.68), Vector3(90, 0, 0))
            _add_box(model, Vector3(radius * 0.95, radius * 0.055, radius * 0.26), _mat("lite_rocket_wing_" + label, Color(0.20, 0.18, 0.24), 0.12, true), Vector3(0, 0, radius * -0.82))
            _add_projectile_tail_lite(model, radius * 0.28, radius * 2.85, color, radius * -1.26)
        "senna_beam", "senna_snare":
            color = Color(0.58, 1.0, 0.78) if label == "senna_beam" else Color(0.90, 1.0, 0.95)
            _add_cylinder_segments(model, radius * 0.19, radius * 5.65, 8, _mat("lite_senna_beam_" + label, Color(color.r, color.g, color.b, 0.62), 1.28, true, true), Vector3(0, 0, radius * 0.50), Vector3(90, 0, 0))
            _add_cylinder_segments(model, radius * 0.72, 0.014, 14, _mat("lite_senna_focus_" + label, Color(color.r, color.g, color.b, 0.34), 0.92, true, true), Vector3(0, 0, radius * 2.65), Vector3(90, 0, 0))
        "viktor_laser":
            color = Color(0.70, 0.94, 1.0)
            _add_cylinder_segments(model, radius * 0.17, radius * 5.35, 8, _mat("lite_viktor_laser", Color(color.r, color.g, color.b, 0.66), 1.34, true, true), Vector3(0, 0, radius * 0.60), Vector3(90, 0, 0))
            _add_cylinder_segments(model, radius * 0.72, 0.020, 6, _mat("lite_viktor_hex", Color(color.r, color.g, color.b, 0.48), 1.05, true, true), Vector3(0, 0, radius * 2.54), Vector3(90, 0, 30))
        "xayah_feather", "xayah_recall":
            color = Color(1.0, 0.34, 0.62) if label == "xayah_feather" else Color(0.92, 0.28, 1.0)
            _add_box(model, Vector3(radius * 0.28, radius * 0.075, radius * 2.85), _mat("lite_xayah_spine_" + label, color, 0.92, true), Vector3(0, 0, radius * 0.36))
            _add_box(model, Vector3(radius * 1.00, radius * 0.055, radius * 0.20), _mat("lite_xayah_fletch_" + label, Color(color.r, color.g, color.b, 0.54), 0.82, true, true), Vector3(0, 0, radius * -0.78), Vector3(0, 0, 18))
            _add_projectile_tail_lite(model, radius * 0.16, radius * 2.10, color, radius * -1.30)
        "teemo_dart", "blind_dart":
            color = Color(0.56, 1.0, 0.26) if label == "teemo_dart" else Color(0.98, 0.90, 0.24)
            _add_tapered_cylinder(model, radius * 0.23, radius * 0.035, radius * 2.05, 6, _mat("lite_teemo_dart_" + label, color, 0.72, true), Vector3(0, 0, radius * 0.64), Vector3(90, 0, 0))
            _add_sphere(model, radius * 0.28, _mat("lite_teemo_vial_" + label, Color(color.r, color.g, color.b, 0.80), 0.95, true, true), Vector3(0, 0, radius * -0.30))
            _add_projectile_tail_lite(model, radius * 0.15, radius * 1.95, color, radius * -1.08)
        "samira_pistol", "powpow":
            color = Color(1.0, 0.62, 0.22) if label == "samira_pistol" else Color(0.42, 0.82, 1.0)
            _add_tapered_cylinder(model, radius * 0.27, radius * 0.070, radius * 2.05, 8, _mat("lite_bullet_" + label, color, 0.78, true), Vector3(0, 0, radius * 0.60), Vector3(90, 0, 0))
            _add_projectile_tail_lite(model, radius * 0.24, radius * 1.92, color, radius * -0.92)
        "comet":
            color = Color(0.96, 0.78, 1.0)
            _add_sphere(model, radius * 0.84, _mat("lite_comet_core", Color(1.0, 0.88, 0.42), 1.28, true), Vector3(0, 0, radius * 0.66))
            _add_cylinder_segments(model, radius * 1.10, 0.014, 5, _mat("lite_comet_star", Color(color.r, color.g, color.b, 0.32), 0.96, true, true), Vector3(0, 0, radius * 0.66), Vector3(90, 0, 18))
            _add_projectile_tail_lite(model, radius * 0.42, radius * 3.90, color, radius * -1.48)
        _:
            _add_sphere(model, radius * 0.74, _mat("lite_proj_core_" + label + "_" + color.to_html(false), color.lightened(0.16), 1.05, true), Vector3.ZERO)
            _add_projectile_tail_lite(model, radius * 0.25, radius * 3.10, color, radius * -1.34)

func _add_projectile_tail_lite(parent: Node3D, radius: float, length: float, color: Color, z_offset: float) -> void:
    _add_cylinder_segments(parent, radius, length, 8, _mat("proj_lite_tail_" + color.to_html(false), Color(color.r, color.g, color.b, 0.30), 0.88, true, true), Vector3(0, 0, z_offset), Vector3(90, 0, 0))

func _add_enemy_projectile_shape_lite(model: Node3D, radius: float, label: String) -> void:
    var warning := DANGER_RED
    var core := VOID_PURPLE
    if label == "A":
        warning = Color(0.54, 1.0, 0.28)
        core = Color(0.20, 0.84, 0.20)
    elif label == "C":
        warning = Color(0.30, 0.86, 1.0)
        core = Color(0.54, 0.94, 1.0)
    elif label == "R" or label == "X":
        warning = Color(1.0, 0.46, 0.14)
        core = Color(1.0, 0.72, 0.24)
    elif label == "Q" or label == "V" or label == "B" or label == "E":
        warning = Color(0.98, 0.32, 1.0)
        core = Color(0.78, 0.22, 1.0)
    _add_enemy_projectile_readability_shell(model, radius, label, warning, core, true)
    _add_enemy_projectile_lane(model, radius, label, warning, true)
    _add_enemy_projectile_danger_rig(model, radius, label, warning, true)
    _add_enemy_projectile_threat_badge(model, radius, label, warning, true)

func _add_enemy_projectile_shape(model: Node3D, radius: float, label: String) -> void:
    var warning := DANGER_RED
    var core := VOID_PURPLE
    if label == "A":
        warning = Color(0.54, 1.0, 0.28)
        core = Color(0.20, 0.84, 0.20)
    elif label == "E":
        warning = Color(1.0, 0.36, 0.96)
        core = Color(0.86, 0.18, 1.0)
    elif label == "C":
        warning = Color(0.30, 0.86, 1.0)
        core = Color(0.54, 0.94, 1.0)
    elif label == "R" or label == "X":
        warning = Color(1.0, 0.46, 0.14)
        core = Color(1.0, 0.72, 0.24)
    elif label == "Q":
        warning = Color(0.94, 0.36, 1.0)
        core = Color(1.0, 0.60, 0.92)
    elif label == "V":
        warning = Color(0.98, 0.36, 1.0)
        core = Color(0.78, 0.22, 1.0)
    elif label == "B":
        warning = Color(0.86, 0.34, 1.0)
        core = Color(0.54, 0.16, 1.0)
    var floor_warning := _mat("enemy_proj_floor_danger_" + label, Color(warning.r, warning.g, warning.b, 0.30), 0.38, true, true)
    _add_cylinder_segments(model, radius * 2.80, 0.012, 4, floor_warning, Vector3(0, -0.58, 0), Vector3(0, 45, 0))
    _add_box(model, Vector3(radius * 4.10, 0.018, radius * 0.13), _mat("enemy_proj_floor_cross_a_" + label, Color(warning.r, warning.g, warning.b, 0.34), 0.42, true, true), Vector3(0, -0.56, 0), Vector3.ZERO)
    _add_box(model, Vector3(radius * 0.13, 0.018, radius * 4.10), _mat("enemy_proj_floor_cross_b_" + label, Color(warning.r, warning.g, warning.b, 0.34), 0.42, true, true), Vector3(0, -0.555, 0), Vector3.ZERO)
    _add_box(model, Vector3(radius * 1.95, radius * 1.95, radius * 1.95), _mat("enemy_proj_warning_" + label, warning.darkened(0.08), 0.58, true), Vector3.ZERO, Vector3(45, 20, 0))
    _add_sphere(model, radius * 0.52, _mat("enemy_proj_core_" + label, core.darkened(0.08), 0.42, true), Vector3.ZERO)
    _add_cylinder_segments(model, radius * 1.58, 0.020, 24, _mat("enemy_proj_ring_" + label, Color(warning.r, warning.g, warning.b, 0.34), 0.36, true, true), Vector3(0, 0, 0), Vector3(90, 0, 0))
    _add_cylinder_segments(model, radius * 2.25, 0.014, 24, _mat("enemy_proj_floor_warning_" + label, Color(warning.r, warning.g, warning.b, 0.28), 0.32, true, true), Vector3(0, -0.52, 0))
    _add_enemy_projectile_readability_shell(model, radius, label, warning, core, false)
    for i in range(4):
        var angle := TAU * float(i) / 4.0
        var pos := Vector3(cos(angle) * radius * 1.18, 0, sin(angle) * radius * 1.18)
        _add_box(model, Vector3(radius * 0.12, radius * 0.12, radius * 1.08), _mat("enemy_proj_spike_" + label, warning.darkened(0.08), 0.44, true), pos, Vector3(0, -rad_to_deg(angle), 38.0))
    match label:
        "A":
            for acid_index in range(3):
                var acid_angle := TAU * float(acid_index) / 3.0
                _add_sphere(model, radius * 0.24, _mat("enemy_proj_acid_drop", Color(0.72, 1.0, 0.34, 0.58), 0.95, true, true), Vector3(cos(acid_angle) * radius * 0.72, 0, sin(acid_angle) * radius * 0.72))
        "E":
            _add_box(model, Vector3(radius * 1.58, radius * 0.12, radius * 0.18), _mat("enemy_proj_eye_slit", Color(1.0, 0.78, 1.0), 1.22, true), Vector3(0, 0, radius * 0.06))
            _add_sphere(model, radius * 0.26, _mat("enemy_proj_eye_pupil", Color(0.08, 0.00, 0.12), 0.45, true), Vector3(0, 0, radius * 0.18))
        "C":
            _add_tapered_cylinder(model, radius * 0.42, radius * 0.08, radius * 2.20, 6, _mat("enemy_proj_crystal_shard", core, 1.15, true), Vector3(0, 0, radius * 0.62), Vector3(90, 0, 0))
            _add_cylinder_segments(model, radius * 1.30, 0.016, 6, _mat("enemy_proj_crystal_hex", Color(warning.r, warning.g, warning.b, 0.34), 0.88, true, true), Vector3(0, -0.42, 0), Vector3(0, 30, 0))
        "R", "X":
            for shard_index in range(3):
                var shard_offset := -0.42 + float(shard_index) * 0.42
                _add_box(model, Vector3(radius * 0.18, radius * 0.20, radius * 1.42), _mat("enemy_proj_burrow_spike", warning, 1.05, true), Vector3(shard_offset * radius, 0, radius * 0.14), Vector3(0, shard_offset * 18.0, 44.0))
        "Q":
            for tooth_index in range(4):
                var tooth_side := -1.0 if tooth_index < 2 else 1.0
                var tooth_z := -0.36 + float(tooth_index % 2) * 0.72
                _add_tapered_cylinder(model, radius * 0.12, radius * 0.02, radius * 0.92, 8, _mat("enemy_proj_cho_tooth", Color(1.0, 0.84, 0.92), 0.50, true), Vector3(tooth_side * radius * 0.66, 0, tooth_z * radius), Vector3(72, 0, tooth_side * 24.0))
        "V":
            _add_cylinder_segments(model, radius * 1.88, 0.018, 3, _mat("enemy_proj_velkoz_focus", Color(warning.r, warning.g, warning.b, 0.34), 1.05, true, true), Vector3(0, 0, radius * 0.06), Vector3(90, 0, 30))
        "B":
            for side in [-1.0, 1.0]:
                _add_box(model, Vector3(radius * 0.18, radius * 0.10, radius * 1.72), _mat("enemy_proj_belveth_wing", Color(warning.r, warning.g, warning.b, 0.46), 1.00, true, true), Vector3(side * radius * 0.74, 0, -radius * 0.06), Vector3(0, side * 14.0, side * 38.0))
        _:
            pass
    _add_projectile_tail(model, radius * 0.28, radius * 4.2, warning, radius * -1.72)
    _add_projectile_vfx_decal(model, radius, label, warning, false)
    _add_enemy_projectile_lane(model, radius, label, warning, false)
    _add_enemy_projectile_danger_rig(model, radius, label, warning, false)
    _add_enemy_projectile_threat_badge(model, radius, label, warning, false)
    _add_enemy_projectile_intent_profile(model, radius, label, warning, core)

func _add_projectile_tail(parent: Node3D, radius: float, length: float, color: Color, z_offset: float) -> void:
    _add_cylinder(parent, radius, length, _mat("proj_tail_" + color.to_html(false), Color(color.r, color.g, color.b, 0.34), 0.90, true, true), Vector3(0, 0, z_offset), Vector3(90, 0, 0))

func _add_enemy_projectile_readability_shell(model: Node3D, radius: float, label: String, warning: Color, core: Color, lite: bool) -> void:
    var shell := Node3D.new()
    shell.name = "EnemyProjectileReadabilityShell"
    shell.set_meta("label", label)
    shell.set_meta("lite", lite)
    shell.set_meta("combat_visual_channel", "enemy_hazard")
    shell.set_meta("readability_priority", _enemy_projectile_readability_priority(label))
    shell.set_meta("pickup_confusion_guard", true)
    shell.set_meta("hazard_shape_language", "red_black_triangle")
    model.add_child(shell)

    var black_mat := _mat("enemy_proj_black_core_" + label, Color(0.010, 0.000, 0.018, 0.92 if lite else 0.98), 0.0, true, true)
    var hot_core := _mat("enemy_proj_hot_core_" + label, Color(core.lightened(0.12).r, core.lightened(0.12).g, core.lightened(0.12).b, 0.50), 0.34, true, true)
    var silhouette_mat := _mat("enemy_proj_silhouette_" + label, Color(warning.r, warning.g, warning.b, 0.34 if lite else 0.46), 0.0, true, true)
    var ring_mat := _mat("enemy_proj_pickup_separation_" + label, Color(1.0, 0.04, 0.14, 0.72 if lite else 0.88), 0.12, true, true)
    var outline_mat := _mat("enemy_proj_threat_outline_" + label, Color(1.0, 0.02, 0.06, 0.86 if lite else 0.96), 0.0, true, true)
    var gap_mat := _mat("enemy_proj_dark_ground_gap_" + label, Color(0.0, 0.0, 0.0, 0.68 if lite else 0.78), 0.0, true, true)
    var backplate_mat := _mat("enemy_proj_danger_backplate_" + label, Color(0.0, 0.0, 0.0, 0.68 if lite else 0.74), 0.0, true, true)
    var needle_mat := _mat("enemy_proj_danger_needle_" + label, Color(1.0, 0.02, 0.08, 0.76 if lite else 0.86), 0.0, true, true)
    var occlusion_mat := _mat("enemy_proj_occlusion_matte_" + label, Color(0.0, 0.0, 0.0, 0.62 if lite else 0.70), 0.0, true, true)

    var occlusion_matte := _add_cylinder_segments(shell, radius * (3.62 if lite else 4.12), 0.008, 5, occlusion_mat, Vector3(0, -0.744, radius * 0.08), Vector3(0, 18, 0))
    occlusion_matte.name = "EnemyProjectileOcclusionMatte"
    occlusion_matte.set_meta("combat_visual_channel", "enemy_hazard")
    occlusion_matte.set_meta("pickup_confusion_guard", true)
    var danger_backplate := _add_cylinder_segments(shell, radius * (3.34 if lite else 3.86), 0.010, 3, backplate_mat, Vector3(0, -0.724, 0), Vector3(0, 30, 0))
    danger_backplate.name = "EnemyProjectileDangerBackplate"
    danger_backplate.set_meta("combat_visual_channel", "enemy_hazard")
    danger_backplate.set_meta("pickup_confusion_guard", true)
    var danger_needle := _add_box(shell, Vector3(radius * (0.18 if lite else 0.24), 0.014, radius * (2.64 if lite else 3.12)), needle_mat, Vector3(0, -0.646, -radius * (1.02 if lite else 1.18)), Vector3(0, 0, 0))
    danger_needle.name = "EnemyProjectileDangerNeedle"
    danger_needle.set_meta("combat_visual_channel", "enemy_hazard")
    danger_needle.set_meta("pickup_confusion_guard", true)
    if not lite:
        var silhouette := _add_box(shell, Vector3(radius * 3.34, radius * 3.34, radius * 3.34), silhouette_mat, Vector3.ZERO, Vector3(45, 45, 0))
        silhouette.name = "EnemyProjectileDangerSilhouette"
    var dark_gap := _add_cylinder_segments(shell, radius * (2.52 if lite else 2.88), 0.010, 12, gap_mat, Vector3(0, -0.706, 0), Vector3(0, 15, 0))
    dark_gap.name = "EnemyProjectileDarkGroundGap"
    _add_enemy_projectile_silhouette_guard(shell, radius, label, lite)
    var black_core := _add_sphere(shell, radius * (0.78 if lite else 0.92), black_mat, Vector3(0, 0, radius * 0.02))
    black_core.name = "EnemyProjectileBlackCore"
    if not lite:
        var core_glow := _add_sphere(shell, radius * 0.32, hot_core, Vector3(0, 0, radius * 0.16))
        core_glow.name = "EnemyProjectileHotCore"
    if not lite:
        var hazard_chevron := _add_box(shell, Vector3(radius * (0.56 if lite else 0.72), 0.016, radius * (0.18 if lite else 0.24)), ring_mat, Vector3(0, -0.636 if lite else -0.624, -radius * (2.28 if lite else 2.54)), Vector3(0, 0, 0))
        hazard_chevron.name = "EnemyProjectileHazardChevron"
        hazard_chevron.set_meta("label", label)
        hazard_chevron.set_meta("lite", lite)
        hazard_chevron.set_meta("combat_visual_channel", "enemy_hazard")
    var separation_ring := _add_cylinder_segments(shell, radius * (2.96 if lite else 3.38), 0.012, 8, ring_mat, Vector3(0, -0.690, 0), Vector3(0, 22.5, 0))
    separation_ring.name = "EnemyProjectilePickupSeparationRing"
    separation_ring.set_meta("combat_visual_channel", "enemy_hazard")
    var threat_outline := _add_cylinder_segments(shell, radius * (2.28 if lite else 2.72), 0.016, 4, outline_mat, Vector3(0, -0.666, 0), Vector3(0, 45, 0))
    threat_outline.name = "EnemyProjectileThreatOutline"
    threat_outline.set_meta("combat_visual_channel", "enemy_hazard")
    threat_outline.set_meta("pickup_confusion_guard", true)
    threat_outline.set_meta("material_grade", "low_glare_enemy_collision_radius")
    threat_outline.set_meta("hazard_shape_language", "black_red_collision_radius")
    threat_outline.set_meta("collision_radius_marker", true)
    _add_enemy_projectile_hitbox_lock(shell, radius, label, warning, lite)
    _add_enemy_projectile_danger_blade_rig(shell, radius, label, lite)
    _add_enemy_projectile_motion_contrast_rig(shell, radius, label, lite)
    _add_enemy_projectile_threat_shape_code(shell, radius, label, warning, core, lite)
    if lite:
        return
    var trim_mat := _mat("enemy_proj_pickup_separation_trim_" + label, Color(1.0, 0.76, 0.30, 0.34), 0.82, true, true)
    _add_cylinder_segments(shell, radius * 2.58, 0.010, 8, trim_mat, Vector3(0, -0.674, 0), Vector3(0, 22.5, 0))

    for i in range(8):
        var angle := TAU * float(i) / 8.0
        var long_tick := i % 2 == 0
        var tick := _add_box(shell, Vector3(radius * 0.12, 0.014, radius * (0.88 if long_tick else 0.58)), ring_mat, Vector3(cos(angle) * radius * 2.78, -0.646, sin(angle) * radius * 2.78), Vector3(0, -rad_to_deg(angle), 0))
        tick.name = "EnemyProjectileDangerTick" + str(i)

func _add_enemy_projectile_hitbox_lock(shell: Node3D, radius: float, label: String, warning: Color, lite: bool) -> void:
    if shell.get_node_or_null("EnemyProjectileHitboxLock") != null:
        return
    var tier := _enemy_projectile_threat_tier(label)
    var lock := Node3D.new()
    lock.name = "EnemyProjectileHitboxLock"
    lock.set_meta("label", label)
    lock.set_meta("lite", lite)
    lock.set_meta("threat_tier", tier)
    lock.set_meta("combat_visual_channel", "enemy_hazard")
    lock.set_meta("pickup_confusion_guard", true)
    lock.set_meta("collision_radius_marker", true)
    lock.set_meta("readability_priority", _enemy_projectile_readability_priority(label))
    lock.set_meta("material_grade", "low_glare_enemy_projectile_hitbox_lock")
    lock.set_meta("hazard_shape_language", "black_red_hitbox_lock")
    shell.add_child(lock)

    var tier_scale := 1.12 if tier == "boss" else 1.06 if tier == "special" else 1.0
    var lock_radius := radius * (3.10 if lite else 3.54) * tier_scale
    var shadow_mat := _mat("enemy_projectile_hitbox_lock_shadow_" + label, Color(0.0, 0.0, 0.0, 0.34 if lite else 0.36), 0.0, true, true)
    var ring_mat := _mat("enemy_projectile_hitbox_lock_ring_" + label, Color(1.0, 0.02, 0.08, 0.30 if lite else 0.34), 0.0, true, true)
    var notch_mat := _mat("enemy_projectile_hitbox_lock_notch_" + label, Color(warning.r, warning.g, warning.b, 0.28 if lite else 0.32), 0.0, true, true)

    var sides := 6 if tier == "boss" else 5 if tier == "special" else 4
    var shadow := _add_cylinder_segments(lock, lock_radius * 1.08, 0.008, sides, shadow_mat, Vector3(0, -0.764, 0), Vector3(0, 30 if sides == 6 else 45, 0))
    shadow.name = "EnemyProjectileHitboxLockShadow"
    shadow.set_meta("combat_visual_channel", "enemy_hazard")
    shadow.set_meta("pickup_confusion_guard", true)
    shadow.set_meta("collision_radius_marker", true)

    var ring := _add_cylinder_segments(lock, lock_radius, 0.010, sides, ring_mat, Vector3(0, -0.742, 0), Vector3(0, 30 if sides == 6 else 45, 0))
    ring.name = "EnemyProjectileHitboxLockRing"
    ring.set_meta("combat_visual_channel", "enemy_hazard")
    ring.set_meta("pickup_confusion_guard", true)
    ring.set_meta("collision_radius_marker", true)

    var direction_tab := _add_box(lock, Vector3(radius * (0.66 if lite else 0.82), 0.010, radius * 0.15), notch_mat, Vector3(0, -0.722, -lock_radius * 0.70))
    direction_tab.name = "EnemyProjectileHitboxLockDirectionTab"
    direction_tab.set_meta("combat_visual_channel", "enemy_hazard")
    direction_tab.set_meta("pickup_confusion_guard", true)
    direction_tab.set_meta("collision_radius_marker", true)

    if lite:
        return

    var ticks := Node3D.new()
    ticks.name = "EnemyProjectileHitboxLockTierTicks"
    ticks.set_meta("combat_visual_channel", "enemy_hazard")
    ticks.set_meta("pickup_confusion_guard", true)
    ticks.set_meta("collision_radius_marker", true)
    ticks.set_meta("threat_tier", tier)
    lock.add_child(ticks)
    var tick_count := 5 if tier == "boss" else 4 if tier == "special" else 3
    for i in range(tick_count):
        var angle := TAU * float(i) / float(tick_count)
        var tick := _add_box(ticks, Vector3(radius * 0.11, 0.010, radius * (0.50 if tier != "boss" else 0.68)), notch_mat, Vector3(cos(angle) * lock_radius * 0.84, -0.710, sin(angle) * lock_radius * 0.84), Vector3(0, -rad_to_deg(angle), 0))
        tick.name = "EnemyProjectileHitboxLockTierTick%d" % i
        tick.set_meta("combat_visual_channel", "enemy_hazard")
        tick.set_meta("pickup_confusion_guard", true)
        tick.set_meta("collision_radius_marker", true)

func _add_enemy_projectile_motion_contrast_rig(shell: Node3D, radius: float, label: String, lite: bool) -> void:
    if shell.get_node_or_null("EnemyProjectileMotionContrastRig") != null:
        return
    var rig := Node3D.new()
    rig.name = "EnemyProjectileMotionContrastRig"
    rig.set_meta("label", label)
    rig.set_meta("lite", lite)
    rig.set_meta("combat_visual_channel", "enemy_hazard")
    rig.set_meta("pickup_confusion_guard", true)
    rig.set_meta("material_grade", "low_glare_enemy_projectile_motion_contrast")
    rig.set_meta("hazard_shape_language", "black_motion_tail")
    rig.set_meta("motion_contrast_layer", true)
    shell.add_child(rig)

    var core_mat := _mat("enemy_projectile_motion_shadow_core_" + label, Color(0.0, 0.0, 0.0, 0.78 if lite else 0.84), 0.0, true, true)
    var tail_mat := _mat("enemy_projectile_motion_tail_separator_" + label, Color(0.0, 0.0, 0.0, 0.54 if lite else 0.62), 0.0, true, true)
    var notch_mat := _mat("enemy_projectile_motion_head_notch_" + label, Color(1.0, 0.02, 0.06, 0.42 if lite else 0.52), 0.0, true, true)

    var core := _add_cylinder_segments(rig, radius * (1.52 if lite else 1.82), 0.008, 6, core_mat, Vector3(0, -0.758, radius * 0.06), Vector3(0, 30, 0))
    core.name = "EnemyProjectileMotionShadowCore"
    core.set_meta("combat_visual_channel", "enemy_hazard")
    core.set_meta("pickup_confusion_guard", true)
    core.set_meta("motion_contrast_layer", true)

    var tail := _add_box(rig, Vector3(radius * (1.18 if lite else 1.46), 0.008, radius * (1.62 if lite else 2.10)), tail_mat, Vector3(0, -0.750, -radius * (1.42 if lite else 1.72)))
    tail.name = "EnemyProjectileMotionTailSeparator"
    tail.set_meta("combat_visual_channel", "enemy_hazard")
    tail.set_meta("pickup_confusion_guard", true)
    tail.set_meta("motion_contrast_layer", true)

    var notch := _add_box(rig, Vector3(radius * (0.46 if lite else 0.58), 0.010, radius * 0.13), notch_mat, Vector3(0, -0.738, radius * (1.14 if lite else 1.34)))
    notch.name = "EnemyProjectileMotionHeadNotch"
    notch.set_meta("combat_visual_channel", "enemy_hazard")
    notch.set_meta("pickup_confusion_guard", true)
    notch.set_meta("motion_contrast_layer", true)

func _add_enemy_projectile_silhouette_guard(shell: Node3D, radius: float, label: String, lite: bool) -> void:
    if shell.get_node_or_null("EnemyProjectileSilhouetteGuard") != null:
        return
    var guard := Node3D.new()
    guard.name = "EnemyProjectileSilhouetteGuard"
    guard.set_meta("label", label)
    guard.set_meta("lite", lite)
    guard.set_meta("combat_visual_channel", "enemy_hazard")
    guard.set_meta("pickup_confusion_guard", true)
    guard.set_meta("material_grade", "low_glare_enemy_projectile_silhouette_guard")
    guard.set_meta("hazard_shape_language", "black_matte_outer_silhouette")
    shell.add_child(guard)

    var matte := _mat("enemy_projectile_silhouette_guard_matte_" + label, Color(0.0, 0.0, 0.0, 0.32 if lite else 0.34), 0.0, true, true)
    var cut := _mat("enemy_projectile_silhouette_guard_cut_" + label, Color(0.0, 0.0, 0.0, 0.28 if lite else 0.30), 0.0, true, true)
    var separator := _mat("enemy_projectile_silhouette_guard_separator_" + label, Color(0.015, 0.000, 0.020, 0.24 if lite else 0.28), 0.0, true, true)

    var guard_radius := radius * (3.02 if lite else 3.42)
    var matte_plate := _add_cylinder_segments(guard, guard_radius, 0.008, 6, matte, Vector3(0, -0.734, radius * 0.16), Vector3(0, 30, 0))
    matte_plate.name = "EnemyProjectileSilhouetteGuardMatte"
    matte_plate.set_meta("combat_visual_channel", "enemy_hazard")
    matte_plate.set_meta("pickup_confusion_guard", true)
    var directional_cut := _add_box(guard, Vector3(radius * (0.34 if lite else 0.42), 0.010, radius * (2.08 if lite else 2.56)), cut, Vector3(0, -0.712, -radius * (0.92 if lite else 1.10)))
    directional_cut.name = "EnemyProjectileSilhouetteDirectionalCut"
    directional_cut.set_meta("combat_visual_channel", "enemy_hazard")
    directional_cut.set_meta("pickup_confusion_guard", true)
    var no_pickup_band := _add_box(guard, Vector3(radius * (2.32 if lite else 2.72), 0.008, radius * 0.110), separator, Vector3(0, -0.704, radius * (0.96 if lite else 1.14)))
    no_pickup_band.name = "EnemyProjectileNoPickupConfusionBand"
    no_pickup_band.set_meta("combat_visual_channel", "enemy_hazard")
    no_pickup_band.set_meta("pickup_confusion_guard", true)

func _add_enemy_projectile_danger_blade_rig(shell: Node3D, radius: float, label: String, lite: bool) -> void:
    if shell.get_node_or_null("EnemyProjectileDangerBladeRig") != null:
        return
    var blade := Node3D.new()
    blade.name = "EnemyProjectileDangerBladeRig"
    blade.set_meta("label", label)
    blade.set_meta("lite", lite)
    blade.set_meta("combat_visual_channel", "enemy_hazard")
    blade.set_meta("pickup_confusion_guard", true)
    blade.set_meta("hazard_shape_language", "red_black_directional_blade")
    shell.add_child(blade)

    var black_mat := _mat("enemy_proj_danger_blade_black_" + label, Color(0.0, 0.0, 0.0, 0.66 if lite else 0.74), 0.0, true, true)
    var red_mat := _mat("enemy_proj_danger_blade_red_" + label, Color(1.0, 0.02, 0.08, 0.64 if lite else 0.72), 0.0, true, true)
    var blade_z := -radius * (0.92 if lite else 1.06)
    for side in [-1.0, 1.0]:
        var black := _add_box(blade, Vector3(radius * (0.16 if lite else 0.20), 0.014, radius * (1.42 if lite else 1.72)), black_mat, Vector3(side * radius * (1.10 if lite else 1.28), -0.632, blade_z), Vector3(0, side * 18.0, side * 32.0))
        black.name = "EnemyProjectileDangerBladeBlack" + ("Left" if side < 0.0 else "Right")
        black.set_meta("combat_visual_channel", "enemy_hazard")
        black.set_meta("pickup_confusion_guard", true)
        var red := _add_box(blade, Vector3(radius * (0.10 if lite else 0.13), 0.016, radius * (1.10 if lite else 1.34)), red_mat, Vector3(side * radius * (1.22 if lite else 1.42), -0.614, blade_z - radius * 0.10), Vector3(0, side * 18.0, side * 32.0))
        red.name = "EnemyProjectileDangerBladeRed" + ("Left" if side < 0.0 else "Right")
        red.set_meta("combat_visual_channel", "enemy_hazard")
        red.set_meta("pickup_confusion_guard", true)

func _add_enemy_projectile_threat_shape_code(shell: Node3D, radius: float, label: String, warning: Color, core: Color, lite: bool) -> void:
    if shell.get_node_or_null("EnemyProjectileThreatShapeCode") != null:
        return
    var shape_type := _enemy_projectile_threat_shape_type(label)
    var detail_name := _enemy_projectile_threat_shape_detail_node(shape_type)
    var tier := _enemy_projectile_threat_tier(label)
    var shape := Node3D.new()
    shape.name = "EnemyProjectileThreatShapeCode"
    shape.set_meta("label", label)
    shape.set_meta("lite", lite)
    shape.set_meta("shape_type", shape_type)
    shape.set_meta("detail_node", detail_name)
    shape.set_meta("threat_tier", tier)
    shape.set_meta("combat_visual_channel", "enemy_hazard")
    shape.set_meta("readability_priority", _enemy_projectile_readability_priority(label))
    shape.set_meta("pickup_confusion_guard", true)
    shape.set_meta("material_grade", "low_glare_enemy_projectile_shape_code")
    shape.set_meta("hazard_shape_language", "enemy_projectile_intent_silhouette")
    shell.add_child(shape)

    var dark_mat := _mat("enemy_projectile_shape_code_dark_" + shape_type, Color(0.0, 0.0, 0.0, 0.68 if lite else 0.78), 0.0, true, true)
    var signal_mat := _mat("enemy_projectile_shape_code_signal_" + shape_type, Color(warning.r, warning.g, warning.b, 0.48 if lite else 0.58), 0.22, true, true)
    var core_mat := _mat("enemy_projectile_shape_code_core_" + shape_type, Color(core.lightened(0.12).r, core.lightened(0.12).g, core.lightened(0.12).b, 0.44 if lite else 0.54), 0.26, true, true)
    var gold_mat := _mat("enemy_projectile_shape_code_gold_" + shape_type, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.34 if tier == "boss" else 0.22), 0.18, true, true)
    var anchor_sides := 6 if tier == "boss" else 5 if tier == "special" else 4
    var anchor := _add_cylinder_segments(shape, radius * (1.04 if lite else 1.24), 0.010, anchor_sides, dark_mat, Vector3(0, -0.626, radius * (1.02 if lite else 1.18)), Vector3(0, 30 if anchor_sides == 6 else 45, 0))
    anchor.name = "EnemyProjectileThreatCodeAnchor"
    anchor.set_meta("combat_visual_channel", "enemy_hazard")
    anchor.set_meta("pickup_confusion_guard", true)

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("shape_type", shape_type)
    detail.set_meta("combat_visual_channel", "enemy_hazard")
    detail.set_meta("pickup_confusion_guard", true)
    shape.add_child(detail)

    match shape_type:
        "acid_spit":
            for i in range(2 if lite else 3):
                var angle := TAU * float(i) / float(2 if lite else 3)
                var drop := _add_sphere(detail, radius * 0.16, core_mat, Vector3(cos(angle) * radius * 0.42, -0.598, radius * 1.18 + sin(angle) * radius * 0.26))
                drop.name = "EnemyProjectileThreatCodeAcidDrop%d" % i
        "void_eye_focus":
            var slit := _add_box(detail, Vector3(radius * 1.12, 0.014, radius * 0.110), signal_mat, Vector3(0, -0.596, radius * 1.18))
            slit.name = "EnemyProjectileThreatCodeEyeSlit"
            var pupil := _add_sphere(detail, radius * 0.16, dark_mat, Vector3(0, -0.584, radius * 1.18))
            pupil.name = "EnemyProjectileThreatCodeEyePupil"
        "crystal_shard":
            var shard := _add_tapered_cylinder(detail, radius * 0.20, radius * 0.035, radius * (0.78 if lite else 1.02), 5, core_mat, Vector3(0, -0.594, radius * 1.16), Vector3(62, 0, 0))
            shard.name = "EnemyProjectileThreatCodeCrystalShard"
            if not lite:
                var hex := _add_cylinder_segments(detail, radius * 0.62, 0.010, 6, signal_mat, Vector3(0, -0.620, radius * 1.16), Vector3(0, 30, 0))
                hex.name = "EnemyProjectileThreatCodeCrystalFrame"
        "burrow_lance":
            var lance := _add_box(detail, Vector3(radius * 0.20, 0.016, radius * (1.16 if lite else 1.48)), signal_mat, Vector3(0, -0.594, radius * 1.06))
            lance.name = "EnemyProjectileThreatCodeBurrowLance"
            for side in [-1.0, 1.0]:
                var barb := _add_box(detail, Vector3(radius * 0.12, 0.014, radius * 0.54), dark_mat, Vector3(side * radius * 0.36, -0.586, radius * 0.92), Vector3(0, side * 18.0, side * 28.0))
                barb.name = "EnemyProjectileThreatCodeBurrowBarb" + ("Left" if side < 0.0 else "Right")
        "rupture_maw":
            for side in [-1.0, 1.0]:
                var jaw := _add_box(detail, Vector3(radius * 0.16, 0.014, radius * (0.96 if lite else 1.24)), signal_mat, Vector3(side * radius * 0.46, -0.594, radius * 1.12), Vector3(0, side * 14.0, 0))
                jaw.name = "EnemyProjectileThreatCodeMawJaw" + ("Left" if side < 0.0 else "Right")
        "disintegration_ray":
            var beam := _add_box(detail, Vector3(radius * 0.11, 0.014, radius * (1.36 if lite else 1.76)), signal_mat, Vector3(0, -0.594, radius * 1.02))
            beam.name = "EnemyProjectileThreatCodeDisintegrationBeam"
            var focus := _add_cylinder_segments(detail, radius * 0.48, 0.010, 3, core_mat, Vector3(0, -0.612, radius * 1.62), Vector3(0, 30, 0))
            focus.name = "EnemyProjectileThreatCodeDisintegrationFocus"
        "royal_blade":
            for side in [-1.0, 1.0]:
                var wing := _add_box(detail, Vector3(radius * 0.12, 0.014, radius * (0.98 if lite else 1.30)), signal_mat, Vector3(side * radius * 0.44, -0.592, radius * 1.06), Vector3(0, side * 24.0, side * 36.0))
                wing.name = "EnemyProjectileThreatCodeRoyalBlade" + ("Left" if side < 0.0 else "Right")
            if not lite:
                var crown := _add_cylinder_segments(detail, radius * 0.58, 0.010, 6, gold_mat, Vector3(0, -0.614, radius * 1.06), Vector3(0, 30, 0))
                crown.name = "EnemyProjectileThreatCodeRoyalCrown"
        "split_spore", "swarm_seed", "trap_spore":
            var count := 2 if lite else 4
            for i in range(count):
                var angle := TAU * float(i) / float(count)
                var seed := _add_sphere(detail, radius * (0.14 if lite else 0.17), core_mat, Vector3(cos(angle) * radius * 0.44, -0.596, radius * 1.08 + sin(angle) * radius * 0.30))
                seed.name = "EnemyProjectileThreatCodeSpore%d" % i
            if shape_type == "trap_spore":
                var trap := _add_cylinder_segments(detail, radius * 0.54, 0.010, 3, signal_mat, Vector3(0, -0.620, radius * 1.08), Vector3(0, 30, 0))
                trap.name = "EnemyProjectileThreatCodeTrapTriangle"
        "void_orb":
            var orb := _add_sphere(detail, radius * 0.22, core_mat, Vector3(0, -0.590, radius * 1.14))
            orb.name = "EnemyProjectileThreatCodeVoidOrbCore"
            var ring := _add_cylinder_segments(detail, radius * 0.62, 0.010, 8, signal_mat, Vector3(0, -0.616, radius * 1.14), Vector3(90, 0, 0))
            ring.name = "EnemyProjectileThreatCodeVoidOrbRing"
        _:
            var bolt := _add_box(detail, Vector3(radius * 0.62, 0.014, radius * 0.16), signal_mat, Vector3(0, -0.594, radius * 1.12), Vector3(0, 45, 0))
            bolt.name = "EnemyProjectileThreatCodeMinorBolt"

func _enemy_projectile_threat_shape_type(label: String) -> String:
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

func _enemy_projectile_threat_shape_detail_node(shape_type: String) -> String:
    match shape_type:
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

func _enemy_projectile_threat_shape_spin(shape_type: String, lite: bool) -> float:
    var scale := 0.62 if lite else 1.0
    match shape_type:
        "void_eye_focus", "crystal_shard", "void_orb":
            return -0.026 * scale
        "burrow_lance", "disintegration_ray", "royal_blade":
            return 0.018 * scale
        "acid_spit", "split_spore", "swarm_seed", "trap_spore":
            return 0.032 * scale
        _:
            return 0.020 * scale

func _add_projectile_vfx_decal(model: Node3D, radius: float, label: String, color: Color, from_player: bool) -> void:
    var decal_path := _vfx_decal_texture_path()
    if decal_path == "":
        return
    var name_prefix := "Projectile" if from_player else "EnemyProjectile"
    var tint := Color(color.r, color.g, color.b, 0.34 if from_player else 0.34)
    var mat := _vfx_decal_mat(name_prefix.to_lower() + "_vfx_decal_" + label, decal_path, tint, 0.98 if from_player else 0.86, Vector3(0.25, 0.25, 1.0), _projectile_vfx_atlas_offset(label, from_player))
    var width := radius * (2.16 if from_player else 2.62)
    var length := radius * (5.10 if from_player else 5.85)
    var z_offset := radius * (-1.48 if from_player else -1.58)
    if label == "senna_beam" or label == "senna_snare" or label == "viktor_laser":
        width = radius * 1.36
        length = radius * 7.25
        z_offset = radius * -1.36
    elif label == "comet" or label == "death_rocket":
        width = radius * 2.86
        length = radius * 6.65
        z_offset = radius * -1.88
    elif label == "xayah_feather" or label == "xayah_recall" or label == "teemo_dart" or label == "blind_dart":
        width = radius * 1.82
        length = radius * 4.72
    var decal := _add_textured_plane(model, Vector2(width, length), mat, Vector3(0, -0.405 if from_player else -0.515, z_offset))
    decal.name = name_prefix + "VfxDecal"

func _projectile_vfx_atlas_offset(label: String, from_player: bool) -> Vector3:
    match label:
        "senna_beam", "senna_snare", "viktor_laser", "C":
            return Vector3(0.0, 0.50, 0.0)
        "fishbones", "death_rocket", "samira_pistol", "powpow", "comet", "R", "X":
            return Vector3(0.50, 0.50, 0.0)
        "xayah_feather", "xayah_recall", "Q", "V", "B", "void_spit":
            return Vector3(0.75, 0.50, 0.0)
        "teemo_dart", "blind_dart", "A":
            return Vector3(0.75, 0.75, 0.0)
        "E":
            return Vector3(0.25, 0.75, 0.0)
        _:
            return Vector3.ZERO if from_player else Vector3(0.25, 0.50, 0.0)

func _void_boss_emblem_atlas_offset(kind: String) -> Vector3:
    match kind:
        "boss_velkoz":
            return Vector3(0.50, 0.0, 0.0)
        "boss_reksai":
            return Vector3(0.0, 0.50, 0.0)
        "boss_belveth":
            return Vector3(0.50, 0.50, 0.0)
        _:
            return Vector3.ZERO

func _add_enemy_projectile_danger_rig(model: Node3D, radius: float, label: String, warning: Color, lite: bool) -> void:
    var rig := Node3D.new()
    rig.name = "EnemyProjectileDangerRig"
    model.add_child(rig)
    rig.set_meta("label", label)
    rig.set_meta("lite", lite)
    rig.set_meta("combat_visual_channel", "enemy_hazard")
    rig.set_meta("lite_semantic_only", lite)
    if lite:
        return
    var alpha := 0.30 if lite else 0.38
    var ring_mat := _mat("enemy_proj_danger_rig_" + label, Color(warning.r, warning.g, warning.b, alpha), 0.88, true, true)
    var tick_mat := _mat("enemy_proj_danger_tick_" + label, Color(1.0, 0.82, 0.92, 0.34 if lite else 0.44), 0.92, true, true)
    var ring_radius := radius * (2.72 if lite else 3.20)
    _add_cylinder_segments(rig, ring_radius, 0.012, 4, ring_mat, Vector3(0, -0.615, 0), Vector3(0, 45, 0))
    for i in range(4):
        var angle := TAU * float(i) / 4.0 + PI * 0.25
        var pos := Vector3(cos(angle) * ring_radius * 0.68, -0.595, sin(angle) * ring_radius * 0.68)
        _add_box(rig, Vector3(radius * 0.16, 0.014, radius * 0.90), tick_mat, pos, Vector3(0, -rad_to_deg(angle), 0))

func _add_enemy_projectile_lane(model: Node3D, radius: float, label: String, warning: Color, lite: bool) -> void:
    var lane := Node3D.new()
    lane.name = "EnemyProjectileLane"
    lane.set_meta("combat_visual_channel", "enemy_hazard")
    lane.set_meta("readability_priority", _enemy_projectile_readability_priority(label))
    model.add_child(lane)
    var rune_path := _warning_rune_texture_path()
    var lane_color := Color(warning.r, warning.g, warning.b, 0.22 if lite else 0.30)
    var hot_color := Color(1.0, 0.82, 0.92, 0.26 if lite else 0.36)
    var lane_mat: StandardMaterial3D
    var hot_mat: StandardMaterial3D
    if rune_path != "":
        lane_mat = _texture_mat("enemy_projectile_lane_" + label, rune_path, lane_color, 0.68, true, true, Vector3(0.70, 0.70, 1.0))
        hot_mat = _texture_mat("enemy_projectile_lane_hot_" + label, rune_path, hot_color, 0.78, true, true, Vector3(0.46, 0.46, 1.0))
    else:
        lane_mat = _mat("enemy_projectile_lane_" + label, lane_color, 0.68, true, true)
        hot_mat = _mat("enemy_projectile_lane_hot_" + label, hot_color, 0.78, true, true)
    var lane_len := radius * (5.45 if not lite else 3.80)
    var lane_width := radius * (0.18 if not lite else 0.14)
    _add_box(lane, Vector3(lane_width, 0.012, lane_len), lane_mat, Vector3(0, 0.000, -radius * 1.05))
    if not lite:
        _add_box(lane, Vector3(radius * 1.45, 0.012, radius * 0.12), hot_mat, Vector3(0, 0.014, radius * 1.22))
    _add_enemy_projectile_trajectory_marks(lane, radius, label, lane_len, warning, lane_mat, hot_mat, lite)
    if lite:
        return
    for side in [-1.0, 1.0]:
        _add_box(lane, Vector3(radius * 0.080, 0.010, lane_len * 0.58), lane_mat, Vector3(side * radius * 0.30, 0.022, -radius * 0.78), Vector3(0, side * 4.0, 0))
    for i in range(3):
        var t := float(i) / 2.0
        var z := -radius * (2.10 - t * 1.10)
        _add_box(lane, Vector3(radius * 0.72, 0.010, radius * 0.060), hot_mat, Vector3(0, 0.034, z), Vector3(0, 0, 0))

func _add_enemy_projectile_trajectory_marks(lane: Node3D, radius: float, label: String, lane_len: float, warning: Color, lane_mat: Material, hot_mat: Material, lite: bool) -> void:
    var marks := Node3D.new()
    marks.name = "EnemyProjectileTrajectoryMarks"
    marks.set_meta("label", label)
    marks.set_meta("lite", lite)
    marks.set_meta("combat_visual_channel", "enemy_hazard")
    lane.add_child(marks)

    var arrow_z := radius * (1.54 if lite else 1.78)
    var heading := _add_tapered_cylinder(marks, radius * (0.22 if lite else 0.28), radius * 0.018, radius * (0.74 if lite else 0.98), 4, hot_mat, Vector3(0, 0.050, arrow_z), Vector3(90, 45, 0))
    heading.name = "EnemyProjectileHeadingArrow"
    heading.set_meta("combat_visual_channel", "enemy_hazard")
    if lite:
        return

    var tier := _enemy_projectile_threat_tier(label)
    var accent_mat := hot_mat
    if tier == "boss":
        accent_mat = _mat("enemy_proj_boss_heading_gold_" + label, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.48), 0.98, true, true)
    elif tier == "":
        accent_mat = _mat("enemy_proj_minor_heading_" + label, Color(warning.r, warning.g, warning.b, 0.32), 0.82, true, true)
    for side in [-1.0, 1.0]:
        _add_box(marks, Vector3(radius * 0.11, 0.012, radius * 0.68), accent_mat, Vector3(side * radius * 0.34, 0.058, arrow_z - radius * 0.28), Vector3(0, side * 24.0, 0))

    var notch_count := 4 if tier == "boss" else 3
    for i in range(notch_count):
        var t := float(i) / float(maxi(1, notch_count - 1))
        var z := -lane_len * 0.45 + lane_len * 0.50 * t
        var notch := _add_box(marks, Vector3(radius * (0.58 if tier != "boss" else 0.78), 0.010, radius * 0.050), lane_mat, Vector3(0, 0.048 + float(i % 2) * 0.008, z), Vector3(0, 0, 0))
        notch.name = "EnemyProjectileRangeNotch" + str(i)

func _enemy_projectile_threat_tier(label: String) -> String:
    match label:
        "Q", "V", "X", "B":
            return "boss"
        "E", "C", "R", "U", "S":
            return "special"
        "A", "F", "T":
            return "hazard"
        _:
            return ""

func _add_enemy_projectile_threat_badge(model: Node3D, radius: float, label: String, warning: Color, lite: bool) -> void:
    var tier := _enemy_projectile_threat_tier(label)
    if tier == "":
        return
    var badge := Node3D.new()
    badge.name = "EnemyProjectileThreatBadge"
    badge.set_meta("tier", tier)
    badge.set_meta("label", label)
    badge.set_meta("lite", lite)
    badge.set_meta("combat_visual_channel", "enemy_hazard")
    badge.set_meta("lite_semantic_only", lite)
    model.add_child(badge)
    if lite:
        return
    var boss_tier := tier == "boss"
    var outer_radius := radius * (3.62 if boss_tier else 2.86)
    var inner_radius := radius * (2.32 if boss_tier else 1.84)
    var alpha := 0.36 if lite else (0.52 if boss_tier else 0.42)
    var gold := Color(1.0, 0.74, 0.24, 0.44 if boss_tier else 0.30)
    var ring_mat := _mat("enemy_proj_threat_ring_" + tier + "_" + label, Color(warning.r, warning.g, warning.b, alpha), 1.12, true, true)
    var trim_mat := _mat("enemy_proj_threat_trim_" + tier + "_" + label, gold, 0.88, true, true)
    _add_cylinder_segments(badge, outer_radius, 0.012, 6 if boss_tier else 4, ring_mat, Vector3(0, -0.655, 0), Vector3(0, 30 if boss_tier else 45, 0))
    _add_cylinder_segments(badge, inner_radius, 0.010, 6 if boss_tier else 4, trim_mat, Vector3(0, -0.640, 0), Vector3(0, 30 if boss_tier else 45, 0))
    var tick_count := 6 if boss_tier else 4
    for i in range(tick_count):
        var angle := TAU * float(i) / float(tick_count)
        var pos := Vector3(cos(angle) * outer_radius * 0.78, -0.612, sin(angle) * outer_radius * 0.78)
        _add_box(badge, Vector3(radius * (0.18 if boss_tier else 0.13), 0.014, radius * (0.92 if boss_tier else 0.62)), trim_mat, pos, Vector3(0, -rad_to_deg(angle), 0))
    if boss_tier:
        _add_box(badge, Vector3(radius * 1.42, 0.018, radius * 0.15), ring_mat, Vector3(0, -0.594, radius * 0.96))
        _add_box(badge, Vector3(radius * 0.15, 0.018, radius * 1.42), ring_mat, Vector3(0, -0.590, radius * 0.96))
        for side in [-1.0, 1.0]:
            _add_box(badge, Vector3(radius * 0.18, 0.016, radius * 1.36), ring_mat, Vector3(side * radius * 1.16, -0.586, -radius * 0.16), Vector3(0, side * 18.0, 0))
    elif tier == "hazard":
        for i in range(3):
            var angle := TAU * float(i) / 3.0
            _add_sphere(badge, radius * 0.20, ring_mat, Vector3(cos(angle) * inner_radius * 0.46, -0.585, sin(angle) * inner_radius * 0.46))
    else:
        _add_box(badge, Vector3(radius * 1.02, 0.014, radius * 0.12), ring_mat, Vector3(0, -0.592, radius * 0.70))
        _add_box(badge, Vector3(radius * 0.12, 0.014, radius * 1.02), ring_mat, Vector3(0, -0.590, radius * 0.70))

func _enemy_projectile_intent_type(label: String) -> String:
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
            return "rupture_bite"
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

func _enemy_projectile_intent_detail_node(intent_type: String) -> String:
    match intent_type:
        "acid_spit":
            return "EnemyProjectileIntentAcidDrops"
        "void_eye_focus":
            return "EnemyProjectileIntentEyeFocus"
        "crystal_shard":
            return "EnemyProjectileIntentCrystalArray"
        "burrow_lance":
            return "EnemyProjectileIntentBurrowLance"
        "rupture_bite":
            return "EnemyProjectileIntentRuptureMaw"
        "disintegration_ray":
            return "EnemyProjectileIntentDisintegrationRay"
        "royal_blade":
            return "EnemyProjectileIntentRoyalBlade"
        "split_spore":
            return "EnemyProjectileIntentSplitSpore"
        "swarm_seed":
            return "EnemyProjectileIntentSwarmSeed"
        "trap_spore":
            return "EnemyProjectileIntentTrapSpore"
        "void_orb":
            return "EnemyProjectileIntentVoidOrb"
        _:
            return "EnemyProjectileIntentMinorBolt"

func _enemy_projectile_intent_spin(intent_type: String) -> float:
    match intent_type:
        "disintegration_ray", "burrow_lance", "royal_blade":
            return 0.018
        "void_eye_focus", "crystal_shard":
            return -0.030
        "rupture_bite":
            return 0.010
        _:
            return 0.026

func _enemy_projectile_intent_pulse(intent_type: String) -> float:
    match intent_type:
        "rupture_bite", "royal_blade":
            return 6.6
        "disintegration_ray", "void_eye_focus":
            return 7.2
        "burrow_lance":
            return 5.8
        "acid_spit", "trap_spore":
            return 4.8
        _:
            return 5.4

func _add_enemy_projectile_intent_profile(model: Node3D, radius: float, label: String, warning: Color, core: Color) -> void:
    if model.get_node_or_null("EnemyProjectileIntentProfile") != null:
        return
    var intent_type := _enemy_projectile_intent_type(label)
    var detail_name := _enemy_projectile_intent_detail_node(intent_type)
    var tier := _enemy_projectile_threat_tier(label)
    var profile := Node3D.new()
    profile.name = "EnemyProjectileIntentProfile"
    profile.set_meta("label", label)
    profile.set_meta("intent_type", intent_type)
    profile.set_meta("detail_node", detail_name)
    profile.set_meta("threat_tier", tier)
    profile.set_meta("combat_visual_channel", "enemy_hazard")
    profile.set_meta("readability_priority", _enemy_projectile_readability_priority(label))
    model.add_child(profile)

    var frame_sides := 6 if tier == "boss" else (5 if tier == "special" else 4)
    var frame_radius := radius * (4.04 if tier == "boss" else 3.46)
    var frame_mat := _mat("enemy_proj_intent_frame_" + intent_type, Color(warning.r, warning.g, warning.b, 0.30 if tier != "boss" else 0.42), 1.08, true, true)
    var core_mat := _mat("enemy_proj_intent_core_" + intent_type, Color(core.lightened(0.18).r, core.lightened(0.18).g, core.lightened(0.18).b, 0.64), 1.24, true, true)
    var gold_mat := _mat("enemy_proj_intent_gold_" + intent_type, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.38), 0.84, true, true)
    var dark_mat := _mat("enemy_proj_intent_dark_" + intent_type, Color(0.025, 0.000, 0.050, 0.62), 0.10, true, true)

    var frame := _add_cylinder_segments(profile, frame_radius, 0.012, frame_sides, frame_mat, Vector3(0, -0.704, 0), Vector3(0, 30 if frame_sides == 6 else 45, 0))
    frame.name = "EnemyProjectileIntentFrame"
    frame.set_meta("combat_visual_channel", "enemy_hazard")
    var center := _add_sphere(profile, radius * 0.24, core_mat, Vector3(0, -0.665, radius * 0.44))
    center.name = "EnemyProjectileIntentCore"
    center.set_meta("combat_visual_channel", "enemy_hazard")

    var detail := Node3D.new()
    detail.name = detail_name
    detail.set_meta("intent_type", intent_type)
    detail.set_meta("combat_visual_channel", "enemy_hazard")
    profile.add_child(detail)

    match intent_type:
        "acid_spit":
            for i in range(4):
                var angle := TAU * float(i) / 4.0
                _add_sphere(detail, radius * 0.18, core_mat, Vector3(cos(angle) * radius * 0.86, -0.640, sin(angle) * radius * 0.86))
            _add_cylinder_segments(detail, radius * 1.22, 0.010, 6, frame_mat, Vector3(0, -0.682, 0), Vector3(0, 30, 0))
        "void_eye_focus":
            _add_box(detail, Vector3(radius * 1.62, 0.014, radius * 0.16), gold_mat, Vector3(0, -0.636, radius * 0.54))
            _add_sphere(detail, radius * 0.34, dark_mat, Vector3(0, -0.620, radius * 0.54))
            _add_cylinder_segments(detail, radius * 1.30, 0.010, 3, frame_mat, Vector3(0, -0.680, 0), Vector3(0, 30, 0))
        "crystal_shard":
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_tapered_cylinder(detail, radius * 0.10, radius * 0.025, radius * 0.74, 5, core_mat, Vector3(cos(angle) * radius * 0.96, -0.628, sin(angle) * radius * 0.96), Vector3(64, -rad_to_deg(angle), 0))
            _add_cylinder_segments(detail, radius * 1.62, 0.010, 6, gold_mat, Vector3(0, -0.686, 0), Vector3(0, 30, 0))
        "burrow_lance":
            for i in range(4):
                var z := -radius * 1.34 + float(i) * radius * 0.74
                _add_box(detail, Vector3(radius * 0.22, 0.018, radius * 0.74), frame_mat, Vector3(0, -0.640, z), Vector3(0, 0, 0))
                _add_tapered_cylinder(detail, radius * 0.12, radius * 0.025, radius * 0.62, 5, core_mat, Vector3((float(i % 2) - 0.5) * radius * 0.74, -0.616, z), Vector3(58, 0, 0))
        "rupture_bite":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.18, 0.014, radius * 1.78), frame_mat, Vector3(side * radius * 0.82, -0.650, radius * 0.12), Vector3(0, side * 14.0, 0))
                for i in range(3):
                    _add_tapered_cylinder(detail, radius * 0.12, radius * 0.018, radius * 0.54, 6, gold_mat, Vector3(side * radius * 0.58, -0.618, -radius * 0.56 + float(i) * radius * 0.56), Vector3(70, 0, side * 20.0))
        "disintegration_ray":
            _add_box(detail, Vector3(radius * 0.18, 0.014, radius * 2.62), frame_mat, Vector3(0, -0.650, radius * 0.08))
            _add_box(detail, Vector3(radius * 1.18, 0.014, radius * 0.12), gold_mat, Vector3(0, -0.632, radius * 1.22))
            _add_cylinder_segments(detail, radius * 1.18, 0.010, 3, core_mat, Vector3(0, -0.682, radius * 0.12), Vector3(0, 30, 0))
        "royal_blade":
            for side in [-1.0, 1.0]:
                _add_box(detail, Vector3(radius * 0.18, 0.014, radius * 1.94), frame_mat, Vector3(side * radius * 0.72, -0.646, -radius * 0.02), Vector3(0, side * 22.0, 0))
                _add_box(detail, Vector3(radius * 0.12, 0.014, radius * 1.18), gold_mat, Vector3(side * radius * 1.18, -0.632, radius * 0.36), Vector3(0, side * 36.0, 0))
        "split_spore", "swarm_seed", "trap_spore":
            var count := 5 if intent_type == "swarm_seed" else 4
            for i in range(count):
                var angle := TAU * float(i) / float(count)
                var dist := radius * (1.10 if intent_type == "swarm_seed" else 0.84)
                _add_sphere(detail, radius * (0.16 if intent_type != "trap_spore" else 0.20), core_mat, Vector3(cos(angle) * dist, -0.632, sin(angle) * dist))
            if intent_type == "trap_spore":
                _add_cylinder_segments(detail, radius * 1.46, 0.010, 8, gold_mat, Vector3(0, -0.684, 0), Vector3(0, 22.5, 0))
        "void_orb":
            _add_cylinder_segments(detail, radius * 1.48, 0.010, 8, frame_mat, Vector3(0, -0.682, 0), Vector3(0, 22.5, 0))
            _add_sphere(detail, radius * 0.44, dark_mat, Vector3(0, -0.628, radius * 0.18))
            _add_sphere(detail, radius * 0.18, core_mat, Vector3(0, -0.610, radius * 0.34))
        _:
            _add_box(detail, Vector3(radius * 1.18, 0.014, radius * 0.12), frame_mat, Vector3(0, -0.642, radius * 0.72))
            _add_box(detail, Vector3(radius * 0.12, 0.014, radius * 1.18), frame_mat, Vector3(0, -0.640, radius * 0.72))

func _should_use_lite_pickup(kind: String, amount: int, dense_pickup_count: int) -> bool:
    return dense_pickup_count > PICKUP_DETAIL_LIMIT and kind == "xp" and amount < 12

func _create_pickup_model(kind: String, pickup_color, amount := 1, lite := false) -> Node3D:
    var model := Node3D.new()
    model.set_meta("kind", kind)
    model.set_meta("amount", amount)
    model.set_meta("lite_pickup", lite)
    model.set_meta("combat_visual_channel", _pickup_visual_channel(kind, amount, lite))
    model.set_meta("visual_stratum", "pickup_collectible")
    model.set_meta("pickup_confusion_safe", true)
    model.set_meta("enemy_hazard_language", false)
    model.set_meta("readability_priority", _pickup_readability_priority(kind, amount, lite))
    var color: Color = Color(0.42, 1.0, 0.45)
    if pickup_color is Color:
        color = pickup_color
    if lite:
        _add_lite_xp_pickup_model(model, color, amount)
        _add_pickup_collectible_backplate(model, kind, color, amount, lite)
        return model
    match kind:
        "gold":
            var gold := Color(1.0, 0.76, 0.18)
            color = gold
            var coin_count := clampi(1 + int(amount / 8), 1, 4)
            for coin_index in range(coin_count):
                _add_cylinder_segments(model, 0.25, 0.050, 6, _mat("pickup_gold_coin", gold, 0.42, true), Vector3(0, 0.02 + float(coin_index) * 0.052, 0), Vector3(0, 30 + coin_index * 10, 0))
            _add_cylinder_segments(model, 0.17, 0.020, 6, _mat("pickup_gold_stamp", Color(1.0, 0.92, 0.42), 0.65, true), Vector3(0, 0.080 + float(coin_count - 1) * 0.052, 0), Vector3(0, 30, 0))
            _add_cylinder_segments(model, 0.32, 0.014, 24, _mat("pickup_gold_glow", Color(gold.r, gold.g, gold.b, 0.18), 0.52, true, true), Vector3(0, -0.040, 0))
            _add_cylinder_segments(model, 0.048, 0.42, 12, _mat("pickup_gold_beam", Color(gold.r, gold.g, gold.b, 0.12), 0.36, true, true), Vector3(0, 0.28, 0))
            if amount >= 12:
                _add_pickup_rarity_frame(model, gold, 0.46)
        "heal":
            var red := Color(1.0, 0.26, 0.34)
            color = red
            _add_crystal(model, 0.15, 0.42, red, Vector3(0, 0.10, 0), Vector3(0, 30, 0), "pickup_heal_crystal")
            _add_box(model, Vector3(0.07, 0.035, 0.32), _mat("pickup_heal_cross", Color(1.0, 0.88, 0.90), 0.70, true), Vector3(0, 0.36, 0))
            _add_box(model, Vector3(0.28, 0.035, 0.07), _mat("pickup_heal_cross", Color(1.0, 0.88, 0.90), 0.70, true), Vector3(0, 0.36, 0))
            _add_cylinder_segments(model, 0.26, 0.014, 24, _mat("pickup_heal_floor", Color(red.r, red.g, red.b, 0.14), 0.46, true, true), Vector3(0, -0.04, 0))
        "shield":
            var shield_col := Color(0.62, 0.92, 1.0)
            color = shield_col
            _add_box(model, Vector3(0.32, 0.09, 0.38), _mat("pickup_shield_plate", shield_col, 0.46, true), Vector3(0, 0.14, 0), Vector3(0, 45, 0))
            _add_box(model, Vector3(0.42, 0.040, 0.08), _mat("pickup_shield_trim", HEXTECH_GOLD, 0.36, true), Vector3(0, 0.21, 0))
            _add_cylinder_segments(model, 0.32, 0.014, 24, _mat("pickup_shield_glow", Color(shield_col.r, shield_col.g, shield_col.b, 0.16), 0.50, true, true), Vector3(0, -0.04, 0))
            _add_cylinder_segments(model, 0.048, 0.44, 12, _mat("pickup_shield_beam", Color(shield_col.r, shield_col.g, shield_col.b, 0.10), 0.34, true, true), Vector3(0, 0.28, 0))
        _:
            var big_reward := amount >= 6
            var crystal_radius := 0.15 + minf(0.05, float(amount) * 0.004)
            var crystal_height := 0.42 + minf(0.14, float(amount) * 0.010)
            _add_crystal(model, crystal_radius, crystal_height, color, Vector3(0, 0.10, 0), Vector3(0, 30, 0), "pickup_xp_crystal")
            _add_cylinder_segments(model, 0.28, 0.014, 18, _mat("pickup_xp_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.14), 0.42, true, true), Vector3(0, -0.04, 0))
            _add_cylinder_segments(model, 0.034, 0.34, 10, _mat("pickup_xp_beam_" + color.to_html(false), Color(color.r, color.g, color.b, 0.08), 0.26, true, true), Vector3(0, 0.22, 0))
            if big_reward:
                _add_cylinder_segments(model, 0.46, 0.012, 6, _mat("pickup_xp_big_hex_" + color.to_html(false), Color(color.r, color.g, color.b, 0.20), 0.58, true, true), Vector3(0, -0.015, 0), Vector3(0, 30, 0))
                for sparkle in range(4):
                    var sparkle_angle := TAU * float(sparkle) / 4.0 + PI * 0.25
                    _add_sphere(model, 0.028, _mat("pickup_xp_big_spark_" + color.to_html(false), color.lightened(0.14), 0.54, true), Vector3(cos(sparkle_angle) * 0.36, 0.34 + float(sparkle % 2) * 0.08, sin(sparkle_angle) * 0.36))
                _add_pickup_rarity_frame(model, color, 0.42)
    _add_pickup_value_halo(model, kind, color, amount)
    _add_pickup_icon_plate(model, kind, color, amount)
    _add_pickup_reward_beacon(model, kind, color, amount)
    _add_pickup_treasure_crest(model, kind, color, amount)
    _add_pickup_hover_glyph(model, kind, color, amount)
    if _is_high_value_pickup(kind, amount):
        _add_pickup_facet_silhouette_rig(model, kind, color, amount)
    _add_pickup_collectible_backplate(model, kind, color, amount, lite)
    return model

func _add_lite_xp_pickup_model(model: Node3D, color: Color, amount: int) -> void:
    model.name = "LitePickupModel"
    var core_radius := 0.13 + minf(0.040, float(amount) * 0.004)
    var core := _add_sphere(model, core_radius, _mat("lite_pickup_xp_core_" + color.to_html(false), color.lightened(0.06), 0.42, true), Vector3(0, 0.14, 0))
    core.name = "LitePickupCore"
    core.set_meta("combat_visual_channel", "pickup_xp_lite")
    if amount >= 8:
        var ring := _add_cylinder_segments(model, 0.28 + minf(0.050, float(amount) * 0.004), 0.010, 6, _mat("lite_pickup_xp_ring_" + color.to_html(false), Color(color.r, color.g, color.b, 0.14), 0.32, true, true), Vector3(0, -0.036, 0), Vector3(0, 30, 0))
        ring.name = "LitePickupValueRing"
        ring.set_meta("combat_visual_channel", "pickup_xp_lite")
    if amount >= 10:
        var spark := _add_box(model, Vector3(0.24, 0.012, 0.046), _mat("lite_pickup_xp_tick_" + color.to_html(false), Color(color.lightened(0.08).r, color.lightened(0.08).g, color.lightened(0.08).b, 0.20), 0.34, true, true), Vector3(0, 0.26, 0), Vector3(0, 45, 0))
        spark.name = "LitePickupValueTick"
        spark.set_meta("combat_visual_channel", "pickup_xp_lite")

func _add_pickup_collectible_backplate(model: Node3D, kind: String, color: Color, amount: int, lite: bool) -> void:
    if model.get_node_or_null("PickupCollectibleBackplate") != null:
        return
    var channel := _pickup_visual_channel(kind, amount, lite)
    var plate := Node3D.new()
    plate.name = "PickupCollectibleBackplate"
    plate.set_meta("kind", kind)
    plate.set_meta("amount", amount)
    plate.set_meta("lite_pickup", lite)
    plate.set_meta("combat_visual_channel", channel)
    plate.set_meta("visual_stratum", "pickup_collectible_floor")
    plate.set_meta("material_grade", "low_glare_pickup_stratum")
    plate.set_meta("pickup_confusion_safe", true)
    plate.set_meta("enemy_hazard_language", false)
    model.add_child(plate)

    var plate_color := color.darkened(0.48)
    if kind == "gold":
        plate_color = Color(0.36, 0.25, 0.08)
    elif kind == "heal":
        plate_color = Color(0.34, 0.07, 0.08)
    elif kind == "shield":
        plate_color = Color(0.08, 0.20, 0.28)
    var alpha := 0.105 if lite else 0.145
    var outer_radius := 0.26 if lite else 0.38
    if _is_high_value_pickup(kind, amount):
        alpha = 0.17
        outer_radius = 0.54
    elif kind == "gold":
        alpha = 0.155
        outer_radius = 0.46
    var matte := _add_cylinder_segments(plate, outer_radius, 0.008, 6, _mat("pickup_collectible_backplate_" + kind, Color(plate_color.r, plate_color.g, plate_color.b, alpha), 0.0, true, true), Vector3(0, -0.126, 0), Vector3(0, 30, 0))
    matte.name = "PickupCollectibleMatte"
    matte.set_meta("combat_visual_channel", channel)
    matte.set_meta("visual_stratum", "pickup_collectible_floor")
    matte.set_meta("material_grade", "low_glare_pickup_stratum")
    matte.set_meta("pickup_confusion_safe", true)
    matte.set_meta("enemy_hazard_language", false)
    if amount >= 8 or _is_high_value_pickup(kind, amount):
        var notch := _add_box(plate, Vector3(outer_radius * 0.72, 0.008, 0.040), _mat("pickup_collectible_notch_" + kind, Color(color.r, color.g, color.b, 0.115), 0.0, true, true), Vector3(0, -0.112, outer_radius * 0.48))
        notch.name = "PickupCollectibleValueNotch"
        notch.set_meta("combat_visual_channel", channel)
        notch.set_meta("visual_stratum", "pickup_collectible_floor")
        notch.set_meta("material_grade", "low_glare_pickup_stratum")
        notch.set_meta("pickup_confusion_safe", true)
        notch.set_meta("enemy_hazard_language", false)

func _add_pickup_facet_silhouette_rig(model: Node3D, kind: String, color: Color, amount: int) -> void:
    if model.get_node_or_null("PickupFacetSilhouetteRig") != null:
        return
    var channel := _pickup_visual_channel(kind, amount, false)
    var rig := Node3D.new()
    rig.name = "PickupFacetSilhouetteRig"
    rig.set_meta("kind", kind)
    rig.set_meta("amount", amount)
    rig.set_meta("combat_visual_channel", channel)
    rig.set_meta("visual_stratum", "pickup_collectible_facet")
    rig.set_meta("material_grade", "low_glare_pickup_facet_silhouette")
    rig.set_meta("pickup_confusion_safe", true)
    rig.set_meta("enemy_hazard_language", false)
    rig.set_meta("reward_facet_language", _pickup_facet_language(kind, amount))
    model.add_child(rig)

    var facet_color := color
    if kind == "gold":
        facet_color = Color(1.0, 0.76, 0.20)
    elif kind == "heal":
        facet_color = Color(1.0, 0.28, 0.34)
    elif kind == "shield":
        facet_color = Color(0.64, 0.94, 1.0)
    var high_value := _is_high_value_pickup(kind, amount)
    var shadow_mat := _mat("pickup_facet_shadow_" + kind, Color(0.010, 0.010, 0.018, 0.20 if high_value else 0.16), 0.0, true, true)
    var facet_mat := _mat("pickup_facet_body_" + kind + "_" + facet_color.to_html(false), Color(facet_color.r, facet_color.g, facet_color.b, 0.16 if high_value else 0.12), 0.18 if high_value else 0.10, true, true)
    var cut_color := facet_color.lightened(0.18)
    var cut_mat := _mat("pickup_facet_cut_" + kind + "_" + facet_color.to_html(false), Color(cut_color.r, cut_color.g, cut_color.b, 0.13 if high_value else 0.10), 0.14 if high_value else 0.08, true, true)
    var gold_mat := _mat("pickup_facet_gold_trim_" + kind, Color(1.0, 0.78, 0.24, 0.13 if high_value else 0.09), 0.12 if high_value else 0.06, true, true)

    var base_radius := 0.32 if not high_value else 0.44
    if kind == "gold":
        base_radius += 0.05
    var base := _add_cylinder_segments(rig, base_radius, 0.008, 6, shadow_mat, Vector3(0, -0.150, 0), Vector3(0, 30, 0))
    base.name = "PickupFacetBaseShadow"
    _tag_pickup_facet_node(base, channel)

    var primary: Node3D
    match kind:
        "gold":
            primary = _add_cylinder_segments(rig, 0.22 if high_value else 0.18, 0.026, 6, facet_mat, Vector3(0, 0.105, 0), Vector3(0, 30, 0))
        "heal":
            primary = _add_crystal(rig, 0.115 if high_value else 0.095, 0.32 if high_value else 0.26, facet_color, Vector3(0, 0.080, 0), Vector3(0, 30, 0), "pickup_facet_heal_crystal")
        "shield":
            primary = _add_box(rig, Vector3(0.28 if high_value else 0.22, 0.034, 0.32 if high_value else 0.26), facet_mat, Vector3(0, 0.085, 0), Vector3(0, 45, 0))
        _:
            primary = _add_crystal(rig, 0.115 if high_value else 0.092, 0.34 if high_value else 0.26, facet_color, Vector3(0, 0.082, 0), Vector3(0, 30, 0), "pickup_facet_xp_crystal")
    primary.name = "PickupFacetPrimarySilhouette"
    _tag_pickup_facet_node(primary, channel)

    var cut := _add_box(rig, Vector3(0.050 if high_value else 0.040, 0.010, 0.32 if high_value else 0.24), cut_mat, Vector3(0, 0.160 if high_value else 0.128, 0), Vector3(0, 45, 0))
    cut.name = "PickupFacetSpecularCut"
    _tag_pickup_facet_node(cut, channel)

    var inlay: Node3D
    match kind:
        "gold":
            inlay = _add_box(rig, Vector3(0.30 if high_value else 0.22, 0.010, 0.044), gold_mat, Vector3(0, 0.140, 0), Vector3(0, 45, 0))
        "heal":
            inlay = _add_box(rig, Vector3(0.30 if high_value else 0.22, 0.010, 0.050), cut_mat, Vector3(0, 0.176 if high_value else 0.144, 0))
            var heal_vertical := _add_box(rig, Vector3(0.050, 0.010, 0.30 if high_value else 0.22), cut_mat, Vector3(0, 0.178 if high_value else 0.146, 0))
            heal_vertical.name = "PickupFacetRoleInlayCross"
            _tag_pickup_facet_node(heal_vertical, channel)
        "shield":
            inlay = _add_cylinder_segments(rig, 0.22 if high_value else 0.17, 0.010, 6, gold_mat, Vector3(0, 0.154 if high_value else 0.126, 0), Vector3(0, 30, 0))
        _:
            inlay = _add_cylinder_segments(rig, 0.22 if high_value else 0.17, 0.010, 6, gold_mat, Vector3(0, 0.148 if high_value else 0.122, 0), Vector3(0, 30, 0))
    inlay.name = "PickupFacetRoleInlay"
    _tag_pickup_facet_node(inlay, channel)

    if high_value:
        var frame := _add_cylinder_segments(rig, base_radius * 0.92, 0.010, 6, gold_mat, Vector3(0, -0.116, 0), Vector3(0, 30, 0))
        frame.name = "PickupFacetRewardFrame"
        _tag_pickup_facet_node(frame, channel)
        for i in range(3):
            var angle := TAU * float(i) / 3.0 + PI * 0.18
            var pip := _add_box(rig, Vector3(0.060, 0.010, 0.040), cut_mat, Vector3(cos(angle) * base_radius * 0.62, 0.026, sin(angle) * base_radius * 0.62), Vector3(0, -rad_to_deg(angle), 0))
            pip.name = "PickupFacetRewardPip%d" % i
            _tag_pickup_facet_node(pip, channel)

func _tag_pickup_facet_node(node: Node3D, channel: String) -> void:
    node.set_meta("combat_visual_channel", channel)
    node.set_meta("visual_stratum", "pickup_collectible_facet")
    node.set_meta("material_grade", "low_glare_pickup_facet_silhouette")
    node.set_meta("pickup_confusion_safe", true)
    node.set_meta("enemy_hazard_language", false)

func _pickup_facet_language(kind: String, amount: int) -> String:
    match kind:
        "gold":
            return "hextech_coin_stamp"
        "heal":
            return "red_life_crystal"
        "shield":
            return "blue_hex_shield"
        _:
            return "xp_crystal_facet_reward" if amount >= 12 else "xp_crystal_facet"

func _add_pickup_icon_plate(model: Node3D, kind: String, color: Color, amount: int) -> void:
    if kind == "xp" and amount < 6:
        return
    var decal_path := _vfx_decal_texture_path()
    if decal_path == "":
        return
    var uv_offset := Vector3(0.50, 0.75, 0.0)
    var tint := Color(color.r, color.g, color.b, 0.18)
    var size := Vector2(0.76, 0.76)
    var emission := 0.38
    match kind:
        "gold":
            uv_offset = Vector3(0.50, 0.0, 0.0)
            tint = Color(1.0, 0.76, 0.22, 0.22)
            size = Vector2(0.86, 0.86)
            emission = 0.48
        "heal":
            uv_offset = Vector3(0.0, 0.75, 0.0)
            tint = Color(1.0, 0.24, 0.32, 0.20)
            size = Vector2(0.78, 0.78)
            emission = 0.42
        "shield":
            uv_offset = Vector3(0.50, 0.25, 0.0)
            tint = Color(0.62, 0.92, 1.0, 0.20)
            size = Vector2(0.82, 0.82)
            emission = 0.44
        _:
            pass
    var mat := _vfx_decal_mat("pickup_icon_plate_" + kind, decal_path, tint, emission, Vector3(0.25, 0.25, 1.0), uv_offset)
    var plate := _add_textured_plane(model, size, mat, Vector3(0, -0.106, 0))
    plate.name = "PickupPremiumIconPlate"
    plate.set_meta("combat_visual_channel", _pickup_visual_channel(kind, amount, false))

func _add_pickup_hover_glyph(model: Node3D, kind: String, color: Color, amount: int) -> void:
    if kind == "xp" and amount < 6:
        return
    var glyph := Node3D.new()
    glyph.name = "PickupHoverGlyph"
    glyph.position = Vector3(0, 0.62, 0)
    model.add_child(glyph)
    var glow := Color(color.r, color.g, color.b, 0.34)
    var glow_mat := _mat("pickup_hover_glow_" + kind + "_" + color.to_html(false), glow, 0.62, true, true)
    var gold_mat := _mat("pickup_hover_gold_" + kind, Color(1.0, 0.78, 0.24, 0.34), 0.56, true, true)
    match kind:
        "gold":
            _add_cylinder_segments(glyph, 0.18, 0.026, 6, _mat("pickup_hover_coin", Color(1.0, 0.78, 0.20), 0.46, true), Vector3.ZERO, Vector3(0, 30, 0))
            _add_cylinder_segments(glyph, 0.25, 0.010, 6, gold_mat, Vector3(0, -0.050, 0), Vector3(0, 30, 0))
        "heal":
            _add_box(glyph, Vector3(0.072, 0.018, 0.34), glow_mat, Vector3.ZERO)
            _add_box(glyph, Vector3(0.34, 0.018, 0.072), glow_mat, Vector3.ZERO)
            _add_cylinder_segments(glyph, 0.22, 0.010, 24, _mat("pickup_hover_heal_ring", Color(1.0, 0.26, 0.34, 0.20), 0.52, true, true), Vector3(0, -0.046, 0))
        "shield":
            _add_cylinder_segments(glyph, 0.22, 0.018, 6, _mat("pickup_hover_shield_hex", Color(0.64, 0.94, 1.0, 0.38), 0.52, true, true), Vector3.ZERO, Vector3(0, 30, 0))
            _add_box(glyph, Vector3(0.30, 0.014, 0.060), gold_mat, Vector3(0, 0.020, 0))
            _add_box(glyph, Vector3(0.060, 0.014, 0.26), gold_mat, Vector3(0, 0.022, 0))
        _:
            _add_box(glyph, Vector3(0.12, 0.018, 0.36), glow_mat, Vector3.ZERO, Vector3(0, 45, 0))
            _add_box(glyph, Vector3(0.36, 0.018, 0.12), glow_mat, Vector3.ZERO, Vector3(0, 45, 0))
            _add_cylinder_segments(glyph, 0.24, 0.010, 6, gold_mat, Vector3(0, -0.052, 0), Vector3(0, 30, 0))

func _add_pickup_value_halo(model: Node3D, kind: String, color: Color, amount: int) -> void:
    if kind == "xp" and amount < 6:
        return
    var halo := Node3D.new()
    halo.name = "PickupValueHalo"
    halo.set_meta("combat_visual_channel", _pickup_visual_channel(kind, amount, false))
    model.add_child(halo)
    var value_color := color
    var outer_radius := 0.50
    var inner_radius := 0.34
    var segment_count := 6
    match kind:
        "gold":
            value_color = Color(1.0, 0.76, 0.18)
            outer_radius = 0.54 + minf(0.08, float(amount) * 0.004)
            inner_radius = 0.34
            segment_count = 6
        "heal":
            value_color = Color(1.0, 0.26, 0.34)
            outer_radius = 0.48
            inner_radius = 0.28
            segment_count = 24
        "shield":
            value_color = Color(0.62, 0.92, 1.0)
            outer_radius = 0.52
            inner_radius = 0.36
            segment_count = 6
        _:
            outer_radius = 0.46 + minf(0.08, float(amount) * 0.006)
            inner_radius = 0.28
            segment_count = 6
    var hot_color := value_color.lightened(0.18)
    var gold := Color(1.0, 0.78, 0.24)
    var halo_mat := _mat("pickup_value_halo_" + kind + "_" + value_color.to_html(false), Color(value_color.r, value_color.g, value_color.b, 0.20), 0.52, true, true)
    var hot_mat := _mat("pickup_value_hot_" + kind + "_" + value_color.to_html(false), Color(hot_color.r, hot_color.g, hot_color.b, 0.30), 0.62, true, true)
    var trim_mat := _mat("pickup_value_trim_" + kind, Color(gold.r, gold.g, gold.b, 0.30), 0.54, true, true)
    _add_cylinder_segments(halo, outer_radius, 0.012, segment_count, halo_mat, Vector3(0, -0.082, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(halo, inner_radius, 0.010, 6, trim_mat, Vector3(0, -0.060, 0), Vector3(0, 30, 0))
    match kind:
        "gold":
            var pip_count := 6 if amount >= 12 else 4
            for i in range(pip_count):
                var angle := TAU * float(i) / float(pip_count)
                _add_cylinder_segments(halo, 0.045, 0.018, 6, hot_mat, Vector3(cos(angle) * outer_radius * 0.82, -0.036, sin(angle) * outer_radius * 0.82), Vector3(0, 30, 0))
            _add_box(halo, Vector3(0.10, 0.014, 0.46), trim_mat, Vector3(0, -0.026, 0), Vector3(0, 45, 0))
            _add_box(halo, Vector3(0.46, 0.014, 0.10), trim_mat, Vector3(0, -0.024, 0), Vector3(0, 45, 0))
        "heal":
            _add_box(halo, Vector3(0.12, 0.016, 0.70), hot_mat, Vector3(0, -0.026, 0))
            _add_box(halo, Vector3(0.70, 0.016, 0.12), hot_mat, Vector3(0, -0.024, 0))
            for i in range(4):
                var angle := TAU * float(i) / 4.0 + PI * 0.25
                _add_sphere(halo, 0.036, hot_mat, Vector3(cos(angle) * outer_radius * 0.76, 0.010, sin(angle) * outer_radius * 0.76))
        "shield":
            _add_box(halo, Vector3(0.62, 0.014, 0.10), trim_mat, Vector3(0, -0.028, -0.08))
            _add_box(halo, Vector3(0.12, 0.014, 0.56), trim_mat, Vector3(0, -0.026, 0.04))
            for i in range(6):
                var angle := TAU * float(i) / 6.0
                _add_box(halo, Vector3(0.048, 0.014, 0.20), hot_mat, Vector3(cos(angle) * outer_radius * 0.76, -0.018, sin(angle) * outer_radius * 0.76), Vector3(0, -rad_to_deg(angle), 0))
        _:
            _add_box(halo, Vector3(0.12, 0.014, 0.54), hot_mat, Vector3(0, -0.026, 0), Vector3(0, 45, 0))
            _add_box(halo, Vector3(0.54, 0.014, 0.12), hot_mat, Vector3(0, -0.024, 0), Vector3(0, 45, 0))
            for i in range(4):
                var angle := TAU * float(i) / 4.0 + PI * 0.25
                _add_box(halo, Vector3(0.08, 0.014, 0.22), trim_mat, Vector3(cos(angle) * outer_radius * 0.80, -0.016, sin(angle) * outer_radius * 0.80), Vector3(0, -rad_to_deg(angle), 0))

func _add_pickup_reward_beacon(model: Node3D, kind: String, color: Color, amount: int) -> void:
    if not _is_high_value_pickup(kind, amount):
        return
    var beacon := Node3D.new()
    beacon.name = "PickupRewardBeacon"
    beacon.set_meta("combat_visual_channel", "pickup_reward")
    model.add_child(beacon)
    var beacon_color := color
    if kind == "gold":
        beacon_color = Color(1.0, 0.76, 0.18)
    elif kind == "heal":
        beacon_color = Color(1.0, 0.28, 0.34)
    elif kind == "shield":
        beacon_color = Color(0.64, 0.94, 1.0)
    var glow_mat := _mat("pickup_reward_beacon_glow_" + kind + "_" + beacon_color.to_html(false), Color(beacon_color.r, beacon_color.g, beacon_color.b, 0.22), 0.56, true, true)
    var hot_mat := _mat("pickup_reward_beacon_hot_" + kind + "_" + beacon_color.to_html(false), beacon_color.lightened(0.10), 0.66, true)
    var gold_mat := _mat("pickup_reward_beacon_gold_" + kind, Color(1.0, 0.78, 0.24, 0.34), 0.54, true, true)
    _add_cylinder_segments(beacon, 0.62, 0.012, 6, gold_mat, Vector3(0, -0.080, 0), Vector3(0, 30, 0))
    _add_cylinder_segments(beacon, 0.46, 0.010, 24, glow_mat, Vector3(0, -0.058, 0))
    _add_cylinder(beacon, 0.026, 0.78, glow_mat, Vector3(0, 0.36, 0))
    _add_sphere(beacon, 0.056, hot_mat, Vector3(0, 0.80, 0))
    var pip_count := 6 if kind == "gold" else 4
    for i in range(pip_count):
        var angle := TAU * float(i) / float(pip_count)
        _add_sphere(beacon, 0.034, hot_mat, Vector3(cos(angle) * 0.50, 0.030, sin(angle) * 0.50))

func _add_pickup_treasure_crest(model: Node3D, kind: String, color: Color, amount: int) -> void:
    if not _is_high_value_pickup(kind, amount):
        return
    var crest := Node3D.new()
    crest.name = "PickupTreasureCrest"
    crest.position = Vector3(0, 0.72, 0)
    crest.set_meta("kind", kind)
    crest.set_meta("combat_visual_channel", "pickup_reward")
    model.add_child(crest)

    var crest_color := color
    if kind == "gold":
        crest_color = Color(1.0, 0.76, 0.18)
    elif kind == "heal":
        crest_color = Color(1.0, 0.28, 0.34)
    elif kind == "shield":
        crest_color = Color(0.64, 0.94, 1.0)

    var hot := crest_color.lightened(0.18)
    var glow_mat := _mat("pickup_treasure_glow_" + kind + "_" + crest_color.to_html(false), Color(crest_color.r, crest_color.g, crest_color.b, 0.28), 0.62, true, true)
    var hot_mat := _mat("pickup_treasure_hot_" + kind + "_" + crest_color.to_html(false), Color(hot.r, hot.g, hot.b, 0.56), 0.72, true, true)
    var gold_mat := _mat("pickup_treasure_gold_" + kind, Color(1.0, 0.78, 0.24, 0.44), 0.62, true, true)
    var shadow_mat := _mat("pickup_treasure_shadow_" + kind, Color(0.015, 0.010, 0.026, 0.48), 0.0, true, true)

    var crown := _add_cylinder_segments(crest, 0.31, 0.018, 6, gold_mat, Vector3(0, -0.20, 0), Vector3(0, 30, 0))
    crown.name = "PickupTreasureCrown"
    _add_cylinder_segments(crest, 0.21, 0.014, 6, shadow_mat, Vector3(0, -0.182, 0), Vector3(0, 30, 0))

    match kind:
        "gold":
            var facet := _add_cylinder_segments(crest, 0.18, 0.046, 6, hot_mat, Vector3(0, -0.030, 0), Vector3(0, 30, 0))
            facet.name = "PickupTreasureFacet"
            _add_cylinder_segments(crest, 0.13, 0.030, 6, glow_mat, Vector3(0, 0.035, 0), Vector3(0, 30, 0))
            _add_box(crest, Vector3(0.070, 0.016, 0.32), gold_mat, Vector3(0, 0.080, 0), Vector3(0, 45, 0))
        "heal":
            var facet_node := _add_crystal(crest, 0.095, 0.30, crest_color, Vector3(0, -0.040, 0), Vector3(0, 30, 0), "pickup_treasure_heal_crystal")
            facet_node.name = "PickupTreasureFacet"
            _add_box(crest, Vector3(0.070, 0.018, 0.31), hot_mat, Vector3(0, 0.090, 0))
            _add_box(crest, Vector3(0.31, 0.018, 0.070), hot_mat, Vector3(0, 0.092, 0))
        "shield":
            var shield := _add_box(crest, Vector3(0.30, 0.052, 0.34), hot_mat, Vector3(0, -0.020, 0), Vector3(0, 45, 0))
            shield.name = "PickupTreasureFacet"
            _add_box(crest, Vector3(0.37, 0.014, 0.052), gold_mat, Vector3(0, 0.040, 0))
            _add_cylinder_segments(crest, 0.20, 0.010, 6, glow_mat, Vector3(0, 0.074, 0), Vector3(0, 30, 0))
        _:
            var crystal := _add_crystal(crest, 0.105, 0.34, crest_color, Vector3(0, -0.055, 0), Vector3(0, 30, 0), "pickup_treasure_xp_crystal")
            crystal.name = "PickupTreasureFacet"
            for i in range(2):
                var side := -1.0 if i == 0 else 1.0
                _add_crystal(crest, 0.060, 0.22, crest_color.lightened(0.12), Vector3(side * 0.18, -0.084, 0.030), Vector3(0, 30 + side * 18.0, 0), "pickup_treasure_xp_side_crystal")
            _add_box(crest, Vector3(0.050, 0.014, 0.34), gold_mat, Vector3(0, 0.086, 0), Vector3(0, 45, 0))

func _is_high_value_pickup(kind: String, amount: int) -> bool:
    return kind == "heal" or kind == "shield" or (kind == "gold" and amount >= 12) or (kind == "xp" and amount >= 12)

func _add_pickup_rarity_frame(model: Node3D, color: Color, radius: float) -> void:
    var gold_mat := _mat("pickup_rarity_gold", Color(1.0, 0.78, 0.24, 0.32), 0.54, true, true)
    var glow_mat := _mat("pickup_rarity_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.18), 0.48, true, true)
    _add_cylinder_segments(model, radius, 0.012, 6, gold_mat, Vector3(0, -0.056, 0), Vector3(0, 30, 0))
    for i in range(6):
        var angle := TAU * float(i) / 6.0
        _add_box(model, Vector3(0.11, 0.012, 0.035), glow_mat, Vector3(cos(angle) * radius, -0.040, sin(angle) * radius), Vector3(0, -rad_to_deg(angle), 0))

func _pickup_visual_scale(kind: String, amount: int) -> float:
    match kind:
        "xp":
            if amount >= 12:
                return 1.02 + minf(0.18, float(amount - 12) * 0.018)
            return 0.72 + minf(0.18, float(amount) * 0.020)
        "gold":
            return 0.94 + minf(0.22, float(amount) * 0.015)
        "heal", "shield":
            return 1.04
        _:
            return 1.0

func _pickup_visual_channel(kind: String, amount: int, lite: bool) -> String:
    if _is_high_value_pickup(kind, amount):
        return "pickup_reward"
    if lite:
        return "pickup_xp_lite"
    match kind:
        "gold":
            return "pickup_gold"
        "heal", "shield":
            return "pickup_reward"
        _:
            return "pickup_xp"

func _pickup_readability_priority(kind: String, amount: int, lite: bool) -> float:
    if _is_high_value_pickup(kind, amount):
        return 0.46
    if kind == "gold":
        return 0.34
    if lite:
        return 0.10
    if kind == "xp":
        return 0.16
    return 0.24

func _pickup_bob_amount(kind: String, amount: int, lite: bool) -> float:
    if _is_high_value_pickup(kind, amount):
        return 0.070
    if lite:
        return 0.026
    if kind == "xp":
        return 0.038
    return 0.052

func _add_lite_zone_floor_layers(disc: Node3D, kind: String, color: Color) -> void:
    var soft := _mat("zone_lite_soft_" + kind, Color(color.r, color.g, color.b, 0.24), 0.72, true, true)
    var hot := _mat("zone_lite_hot_" + kind, Color(color.lightened(0.18).r, color.lightened(0.18).g, color.lightened(0.18).b, 0.46), 0.92, true, true)
    var core := _add_cylinder_segments(disc, 0.62, 0.010, 6, hot, Vector3(0, 0.062, 0), Vector3(0, 30, 0))
    core.name = "ZonePulseCore"
    var tick_count := 4
    if kind == "asol_singularity":
        tick_count = 5
    elif kind == "morde_realm":
        tick_count = 3
    for i in range(tick_count):
        var angle := TAU * float(i) / float(tick_count)
        _add_box(disc, Vector3(0.13, 0.012, 0.030), soft, Vector3(cos(angle) * 0.86, 0.078, sin(angle) * 0.86), Vector3(0, -rad_to_deg(angle), 0))

func _add_lite_zone_marker(marker: Node3D, kind: String, color: Color) -> void:
    var hot := _mat("zone_lite_marker_hot_" + kind, Color(color.lightened(0.18).r, color.lightened(0.18).g, color.lightened(0.18).b, 0.70), 1.02, true, true)
    var dark := _mat("zone_lite_marker_dark_" + kind, Color(0.035, 0.018, 0.060, 0.64), 0.12, true, true)
    match kind:
        "teemo_mushroom":
            _add_cylinder(marker, 0.064, 0.18, dark, Vector3(0, 0.09, 0))
            _add_sphere(marker, 0.15, hot, Vector3(0, 0.24, 0))
            var armed := Node3D.new()
            armed.name = "ZoneArmedSigils"
            marker.add_child(armed)
            _add_cylinder_segments(armed, 0.42, 0.010, 6, hot, Vector3(0, 0.050, 0), Vector3(0, 30, 0))
        "viktor_gravity":
            _add_sphere(marker, 0.16, hot, Vector3(0, 0.16, 0))
            _add_cylinder_segments(marker, 0.42, 0.010, 6, hot, Vector3(0, 0.060, 0), Vector3(0, 30, 0))
        "asol_singularity":
            _add_sphere(marker, 0.20, dark, Vector3(0, 0.17, 0))
            _add_cylinder_segments(marker, 0.52, 0.010, 5, hot, Vector3(0, 0.056, 0), Vector3(0, 18, 0))
        "morde_realm":
            _add_box(marker, Vector3(0.34, 0.060, 0.34), dark, Vector3(0, 0.15, 0), Vector3(0, 45, 0))
            _add_cylinder_segments(marker, 0.48, 0.010, 6, hot, Vector3(0, 0.062, 0), Vector3(0, 30, 0))
        _:
            _add_sphere(marker, 0.16, hot, Vector3(0, 0.16, 0))

func _add_zone_floor_layers(disc: Node3D, kind: String, color: Color) -> void:
    var rune_path := _warning_rune_texture_path()
    var base_alpha := 0.22
    var hot_alpha := 0.36
    match kind:
        "asol_singularity":
            base_alpha = 0.28
            hot_alpha = 0.44
        "viktor_gravity":
            base_alpha = 0.24
            hot_alpha = 0.38
        "morde_realm":
            base_alpha = 0.24
            hot_alpha = 0.40
        "teemo_mushroom":
            base_alpha = 0.20
            hot_alpha = 0.32
        _:
            pass
    if rune_path != "":
        var plate_mat := _texture_mat("zone_rune_plate_" + kind, rune_path, Color(color.r, color.g, color.b, base_alpha), 0.58, true, true, Vector3(0.62, 0.62, 1.0))
        var plate := _add_textured_plane(disc, Vector2(1.72, 1.72), plate_mat, Vector3(0, 0.062, 0))
        plate.name = "ZoneRunePlate"
        var hot_mat := _texture_mat("zone_pulse_plate_" + kind, rune_path, Color(color.lightened(0.18).r, color.lightened(0.18).g, color.lightened(0.18).b, hot_alpha), 0.86, true, true, Vector3(0.46, 0.46, 1.0))
        var pulse_plate := _add_textured_plane(disc, Vector2(1.04, 1.04), hot_mat, Vector3(0, 0.076, 0), Vector3(0, 45, 0))
        pulse_plate.name = "ZonePulseCore"
    else:
        var pulse := Node3D.new()
        pulse.name = "ZonePulseCore"
        disc.add_child(pulse)
        _add_cylinder_segments(pulse, 0.52, 0.010, 18, _mat("zone_pulse_core_" + kind, Color(color.r, color.g, color.b, hot_alpha), 0.84, true, true), Vector3(0, 0.076, 0))
    _add_zone_progress_sigils(disc, kind, color)
    _add_zone_source_profile(disc, kind, color)
    _add_zone_resolution_profile(disc, kind, color)

func _add_zone_progress_sigils(disc: Node3D, kind: String, color: Color) -> void:
    var progress := Node3D.new()
    progress.name = "ZoneProgressSigils"
    disc.add_child(progress)
    var tick_count := 10
    var radius := 1.03
    match kind:
        "asol_singularity":
            tick_count = 12
            radius = 1.07
        "viktor_gravity":
            tick_count = 8
            radius = 1.01
        "morde_realm":
            tick_count = 6
            radius = 1.05
        _:
            pass
    var sigil_mat := _mat("zone_progress_sigil_" + kind, Color(color.lightened(0.20).r, color.lightened(0.20).g, color.lightened(0.20).b, 0.58), 1.02, true, true)
    var trim_mat := _mat("zone_progress_trim_" + kind, Color(1.0, 0.76, 0.28, 0.42), 0.76, true, true)
    for i in range(tick_count):
        var angle := TAU * float(i) / float(tick_count)
        var sigil := Node3D.new()
        sigil.name = "ZoneProgressSigil%02d" % i
        progress.add_child(sigil)
        var pos := Vector3(cos(angle) * radius, 0.096, sin(angle) * radius)
        _add_box(sigil, Vector3(0.090, 0.018, 0.030), trim_mat, pos, Vector3(0, -rad_to_deg(angle), 0))
        _add_box(sigil, Vector3(0.052, 0.020, 0.112), sigil_mat, pos + Vector3(0, 0.010, 0), Vector3(0, -rad_to_deg(angle), 0))

func _add_boss_hazard_zone_frame(disc: Node3D, kind: String, color: Color) -> void:
    var frame := Node3D.new()
    frame.name = "BossHazardZoneFrame"
    frame.set_meta("kind", kind)
    frame.set_meta("zone_threat_channel", "boss_hazard_zone")
    disc.add_child(frame)

    var warning := _mat("boss_hazard_zone_warning_" + kind, Color(1.0, 0.12, 0.34, 0.46), 1.18, true, true)
    var void_mat := _mat("boss_hazard_zone_void_" + kind, Color(color.r, color.g, color.b, 0.40), 1.06, true, true)
    var gold := _mat("boss_hazard_zone_gold_" + kind, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.42), 0.82, true, true)
    _add_cylinder_segments(frame, 1.18, 0.012, 8, warning, Vector3(0, 0.112, 0), Vector3(0, 22.5, 0))
    _add_cylinder_segments(frame, 0.96, 0.010, 8, void_mat, Vector3(0, 0.128, 0), Vector3(0, 22.5, 0))
    for i in range(8):
        var angle := TAU * float(i) / 8.0
        var pos := Vector3(cos(angle) * 1.05, 0.146, sin(angle) * 1.05)
        _add_box(frame, Vector3(0.050, 0.018, 0.30), warning if i % 2 == 0 else gold, pos, Vector3(0, -rad_to_deg(angle), 0))
    var icon := _zone_resolution_node_name(kind)
    frame.set_meta("hazard_icon", icon)

func _add_teemo_armed_sigils(marker: Node3D) -> void:
    var armed := Node3D.new()
    armed.name = "ZoneArmedSigils"
    marker.add_child(armed)
    var glow_mat := _mat("zone_mushroom_armed_glow", Color(0.66, 1.0, 0.24, 0.48), 0.92, true, true)
    var tooth_mat := _mat("zone_mushroom_armed_tooth", Color(1.0, 0.74, 0.30, 0.42), 0.82, true, true)
    _add_cylinder_segments(armed, 0.54, 0.012, 6, glow_mat, Vector3(0, 0.052, 0), Vector3(0, 30, 0))
    for i in range(6):
        var angle := TAU * float(i) / 6.0
        _add_box(armed, Vector3(0.050, 0.016, 0.18), tooth_mat, Vector3(cos(angle) * 0.55, 0.072, sin(angle) * 0.55), Vector3(0, -rad_to_deg(angle), 0))

func _zone_source_champion(kind: String) -> String:
    match kind:
        "viktor_gravity":
            return "viktor"
        "asol_singularity":
            return "aurelion_sol"
        "morde_realm":
            return "mordekaiser"
        "teemo_mushroom":
            return "teemo"
        "boss_cho_rupture":
            return "boss_cho"
        "boss_velkoz_focus":
            return "boss_velkoz"
        "boss_reksai_tunnel":
            return "boss_reksai"
        "boss_belveth_swarm":
            return "boss_belveth"
        _:
            return "generic"

func _zone_source_profile_family(kind: String) -> String:
    match kind:
        "viktor_gravity":
            return "laser"
        "asol_singularity":
            return "comet"
        "morde_realm":
            return "juggernaut"
        "teemo_mushroom":
            return "poison"
        "boss_cho_rupture":
            return "void_rupture"
        "boss_velkoz_focus":
            return "void_laser"
        "boss_reksai_tunnel":
            return "void_burrow"
        "boss_belveth_swarm":
            return "void_swarm"
        _:
            return "generic"

func _zone_source_profile_node_name(kind: String) -> String:
    match kind:
        "viktor_gravity":
            return "ZoneSourceProfileHexcoreField"
        "asol_singularity":
            return "ZoneSourceProfileStarForgeField"
        "morde_realm":
            return "ZoneSourceProfileRealmSeal"
        "teemo_mushroom":
            return "ZoneSourceProfileMushroomTrap"
        "boss_cho_rupture":
            return "ZoneSourceProfileBossChoRupture"
        "boss_velkoz_focus":
            return "ZoneSourceProfileBossVelkozFocus"
        "boss_reksai_tunnel":
            return "ZoneSourceProfileBossReksaiTunnel"
        "boss_belveth_swarm":
            return "ZoneSourceProfileBossBelvethSwarm"
        _:
            return "ZoneSourceProfileGeneric"

func _zone_resolution_type(kind: String) -> String:
    match kind:
        "viktor_gravity":
            return "containment_lock"
        "asol_singularity":
            return "gravity_collapse"
        "morde_realm":
            return "realm_execution"
        "teemo_mushroom":
            return "poison_bloom"
        "boss_cho_rupture":
            return "rupture_maw"
        "boss_velkoz_focus":
            return "laser_disintegration"
        "boss_reksai_tunnel":
            return "burrow_tremor"
        "boss_belveth_swarm":
            return "swarm_execution"
        _:
            return "generic_zone"

func _zone_resolution_node_name(kind: String) -> String:
    match kind:
        "viktor_gravity":
            return "ZoneResolutionHexcoreLock"
        "asol_singularity":
            return "ZoneResolutionStarCollapse"
        "morde_realm":
            return "ZoneResolutionRealmJudgement"
        "teemo_mushroom":
            return "ZoneResolutionPoisonBloom"
        "boss_cho_rupture":
            return "ZoneResolutionBossChoTeeth"
        "boss_velkoz_focus":
            return "ZoneResolutionBossVelkozEye"
        "boss_reksai_tunnel":
            return "ZoneResolutionBossReksaiSpines"
        "boss_belveth_swarm":
            return "ZoneResolutionBossBelvethNeedles"
        _:
            return "ZoneResolutionGeneric"

func _add_zone_source_profile(disc: Node3D, kind: String, color: Color) -> void:
    if disc.get_node_or_null("ZoneSourceProfile") != null:
        return
    var profile_family := _zone_source_profile_family(kind)
    var detail_name := _zone_source_profile_node_name(kind)
    var source := Node3D.new()
    source.name = "ZoneSourceProfile"
    source.set_meta("kind", kind)
    source.set_meta("source_champion", _zone_source_champion(kind))
    source.set_meta("profile_family", profile_family)
    source.set_meta("profile_role", _player_projectile_role(profile_family))
    source.set_meta("detail_node", detail_name)
    disc.add_child(source)

    var soft := _mat("zone_source_soft_" + kind, Color(color.r, color.g, color.b, 0.26), 0.86, true, true)
    var hot := _mat("zone_source_hot_" + kind, Color(color.lightened(0.18).r, color.lightened(0.18).g, color.lightened(0.18).b, 0.52), 1.08, true, true)
    var gold := _mat("zone_source_gold_" + kind, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.40), 0.76, true, true)
    var dark := _mat("zone_source_dark_" + kind, Color(0.015, 0.012, 0.026, 0.46), 0.04, true, true)
    var y := 0.126

    var ring := _add_cylinder_segments(source, 0.46, 0.010, 8, soft, Vector3(0, y, 0), Vector3(0, 22.5, 0))
    ring.name = "ZoneSourceProfileRing"
    var badge := _add_box(source, Vector3(0.62, 0.012, 0.052), gold, Vector3(0, y + 0.024, -0.42), Vector3(0, 12, 0))
    badge.name = "ZoneSourceClassBadge"

    var detail: Node3D = null
    match kind:
        "viktor_gravity":
            detail = _add_cylinder_segments(source, 0.34, 0.010, 6, hot, Vector3(0, y + 0.052, 0), Vector3(0, 30, 0))
            detail.name = detail_name
            _add_box(source, Vector3(0.044, 0.012, 0.72), soft, Vector3(0, y + 0.070, 0), Vector3(0, -32, 0))
        "asol_singularity":
            detail = _add_cylinder_segments(source, 0.40, 0.010, 16, soft, Vector3(0, y + 0.050, 0), Vector3(90, 0, 0))
            detail.name = detail_name
            _add_box(source, Vector3(0.046, 0.010, 0.78), gold, Vector3(0, y + 0.070, 0), Vector3(0, 36, 0))
        "morde_realm":
            detail = _add_cylinder_segments(source, 0.42, 0.010, 8, dark, Vector3(0, y + 0.046, 0), Vector3(0, 22.5, 0))
            detail.name = detail_name
            _add_box(source, Vector3(0.16, 0.014, 0.72), hot, Vector3(0.04, y + 0.074, -0.04), Vector3(0, -24, 0))
        "teemo_mushroom":
            detail = _add_cylinder(source, 0.040, 0.16, dark, Vector3(0, y + 0.038, 0))
            detail.name = detail_name
            _add_sphere(source, 0.15, hot, Vector3(0, y + 0.130, 0))
        "boss_cho_rupture":
            detail = _add_cylinder_segments(source, 0.44, 0.012, 5, dark, Vector3(0, y + 0.052, 0), Vector3(0, 18, 0))
            detail.name = detail_name
            for tooth_index in range(5):
                var tooth_angle := TAU * float(tooth_index) / 5.0 + PI * 0.10
                _add_tapered_cylinder(source, 0.045, 0.012, 0.34, 5, hot, Vector3(cos(tooth_angle) * 0.38, y + 0.094, sin(tooth_angle) * 0.38), Vector3(72, 0, -rad_to_deg(tooth_angle)))
        "boss_velkoz_focus":
            detail = _add_cylinder_segments(source, 0.40, 0.010, 24, hot, Vector3(0, y + 0.052, 0), Vector3(90, 0, 0))
            detail.name = detail_name
            _add_box(source, Vector3(0.92, 0.012, 0.040), soft, Vector3(0, y + 0.074, 0), Vector3(0, -18, 0))
            _add_box(source, Vector3(0.040, 0.012, 0.92), soft, Vector3(0, y + 0.076, 0), Vector3(0, 18, 0))
        "boss_reksai_tunnel":
            detail = _add_box(source, Vector3(0.26, 0.014, 0.86), hot, Vector3(0, y + 0.060, 0), Vector3(0, 0, 0))
            detail.name = detail_name
            for side in [-1.0, 1.0]:
                _add_box(source, Vector3(0.060, 0.014, 0.58), soft, Vector3(side * 0.24, y + 0.080, 0.06), Vector3(0, side * 18.0, 0))
        "boss_belveth_swarm":
            detail = _add_cylinder_segments(source, 0.42, 0.010, 8, soft, Vector3(0, y + 0.052, 0), Vector3(0, 22.5, 0))
            detail.name = detail_name
            for needle_index in range(6):
                var needle_angle := TAU * float(needle_index) / 6.0
                _add_box(source, Vector3(0.044, 0.014, 0.46), hot, Vector3(cos(needle_angle) * 0.32, y + 0.078, sin(needle_angle) * 0.32), Vector3(0, -rad_to_deg(needle_angle), 0))
        _:
            detail = _add_cylinder_segments(source, 0.34, 0.010, 6, hot, Vector3(0, y + 0.052, 0), Vector3(0, 30, 0))
            detail.name = detail_name
            _add_box(source, Vector3(0.050, 0.010, 0.54), soft, Vector3(0, y + 0.070, 0), Vector3(0, 35, 0))
            _add_sphere(source, 0.050, hot, Vector3(0, y + 0.092, 0))

func _add_zone_resolution_profile(disc: Node3D, kind: String, color: Color) -> void:
    if disc.get_node_or_null("ZoneResolutionProfile") != null:
        return
    var resolution_type := _zone_resolution_type(kind)
    var detail_name := _zone_resolution_node_name(kind)
    var profile := Node3D.new()
    profile.name = "ZoneResolutionProfile"
    profile.set_meta("kind", kind)
    profile.set_meta("resolution_type", resolution_type)
    profile.set_meta("detail_node", detail_name)
    disc.add_child(profile)

    var soft := _mat("zone_resolution_soft_" + kind, Color(color.r, color.g, color.b, 0.22), 0.82, true, true)
    var hot := _mat("zone_resolution_hot_" + kind, Color(color.lightened(0.20).r, color.lightened(0.20).g, color.lightened(0.20).b, 0.50), 1.08, true, true)
    var gold := _mat("zone_resolution_gold_" + kind, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.44), 0.78, true, true)
    var y := 0.152

    var frame := _add_cylinder_segments(profile, 1.10, 0.010, 12, soft, Vector3(0, y, 0), Vector3(0, 15, 0))
    frame.name = "ZoneResolutionFrame"
    var edge := _add_cylinder_segments(profile, 0.88, 0.008, 8, gold, Vector3(0, y + 0.014, 0), Vector3(0, 22.5, 0))
    edge.name = "ZoneResolutionEdge"
    var needle := _add_box(profile, Vector3(0.62, 0.014, 0.026), hot, Vector3(0.31, y + 0.030, 0), Vector3.ZERO)
    needle.name = "ZoneResolutionTimerNeedle"

    var detail: MeshInstance3D = null
    match kind:
        "viktor_gravity":
            detail = _add_cylinder_segments(profile, 0.48, 0.010, 6, hot, Vector3(0, y + 0.050, 0), Vector3(0, 30, 0))
        "asol_singularity":
            detail = _add_cylinder_segments(profile, 0.54, 0.010, 18, hot, Vector3(0, y + 0.050, 0), Vector3(90, 0, 0))
        "morde_realm":
            detail = _add_box(profile, Vector3(0.20, 0.024, 0.82), hot, Vector3(-0.02, y + 0.080, 0), Vector3(0, -32, 0))
        "teemo_mushroom":
            detail = _add_sphere(profile, 0.086, hot, Vector3(0, y + 0.082, 0))
        "boss_cho_rupture":
            detail = _add_cylinder_segments(profile, 0.48, 0.012, 5, hot, Vector3(0, y + 0.050, 0), Vector3(0, 18, 0))
            for tooth_index in range(5):
                var tooth_angle := TAU * float(tooth_index) / 5.0
                _add_box(profile, Vector3(0.10, 0.026, 0.42), hot, Vector3(cos(tooth_angle) * 0.42, y + 0.082, sin(tooth_angle) * 0.42), Vector3(0, -rad_to_deg(tooth_angle), 0))
        "boss_velkoz_focus":
            detail = _add_cylinder_segments(profile, 0.50, 0.010, 24, hot, Vector3(0, y + 0.050, 0), Vector3(90, 0, 0))
            _add_box(profile, Vector3(1.12, 0.018, 0.034), hot, Vector3(0, y + 0.082, 0), Vector3(0, -16, 0))
        "boss_reksai_tunnel":
            detail = _add_box(profile, Vector3(0.24, 0.024, 1.02), hot, Vector3(0, y + 0.074, 0), Vector3(0, 0, 0))
            for side in [-1.0, 1.0]:
                _add_box(profile, Vector3(0.070, 0.020, 0.58), soft, Vector3(side * 0.30, y + 0.072, 0.02), Vector3(0, side * 22.0, 0))
        "boss_belveth_swarm":
            detail = _add_cylinder_segments(profile, 0.52, 0.010, 8, hot, Vector3(0, y + 0.050, 0), Vector3(0, 22.5, 0))
            for needle_index in range(8):
                var needle_angle := TAU * float(needle_index) / 8.0
                _add_box(profile, Vector3(0.046, 0.018, 0.52), hot, Vector3(cos(needle_angle) * 0.44, y + 0.082, sin(needle_angle) * 0.44), Vector3(0, -rad_to_deg(needle_angle), 0))
        _:
            detail = _add_cylinder_segments(profile, 0.44, 0.010, 8, hot, Vector3(0, y + 0.050, 0), Vector3(0, 22.5, 0))
    if detail != null:
        detail.name = detail_name

func _create_zone_model(zone, lite := false) -> Node3D:
    var model := Node3D.new()
    var kind := str(zone.get("kind"))
    var from_player := true
    var from_player_value = zone.get("from_player")
    if from_player_value != null:
        from_player = bool(from_player_value)
    lite = lite and from_player
    model.set_meta("kind", kind)
    model.set_meta("from_player", from_player)
    model.set_meta("lite_zone_model", lite)
    model.set_meta("zone_threat_channel", "player_zone" if from_player else "boss_hazard_zone")
    var color: Color = Color(0.62, 0.36, 1.0, 0.25)
    if zone.get("zone_color") is Color:
        color = zone.get("zone_color")

    var disc := Node3D.new()
    disc.name = "Disc"
    model.add_child(disc)
    var disc_mesh := CylinderMesh.new()
    disc_mesh.top_radius = 1.0
    disc_mesh.bottom_radius = 1.0
    disc_mesh.height = 0.028
    disc_mesh.radial_segments = 16 if lite else 48
    var disc_instance := MeshInstance3D.new()
    disc_instance.mesh = disc_mesh
    disc_instance.material_override = _mat("zone_disc_" + kind, Color(color.r, color.g, color.b, 0.25 if not from_player else 0.20), 0.92 if not from_player else 0.75, true, true)
    disc_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    disc.add_child(disc_instance)
    if lite:
        _add_cylinder_segments(disc, 1.0, 0.014, 12, _mat("zone_edge_lite_" + kind, Color(color.r, color.g, color.b, 0.42), 0.80, true, true), Vector3(0, 0.030, 0), Vector3(0, 15, 0))
        _add_lite_zone_floor_layers(disc, kind, color)
    else:
        _add_cylinder(disc, 1.0, 0.018, _mat("zone_edge_" + kind, Color(color.r, color.g, color.b, 0.62 if not from_player else 0.50), 1.12 if not from_player else 1.0, true, true), Vector3(0, 0.030, 0))
        _add_cylinder(disc, 0.66, 0.012, _mat("zone_inner_" + kind, Color(color.r, color.g, color.b, 0.28), 0.80, true, true), Vector3(0, 0.044, 0))
        var rune_mat := _mat("zone_rune_" + kind, Color(color.r, color.g, color.b, 0.52), 1.05, true, true)
        for i in range(12):
            var angle := TAU * float(i) / 12.0
            var pos := Vector3(cos(angle) * 0.86, 0.056, sin(angle) * 0.86)
            _add_box(disc, Vector3(0.12, 0.012, 0.026), rune_mat, pos, Vector3(0, -rad_to_deg(angle), 0))
        _add_zone_floor_layers(disc, kind, color)
        if not from_player:
            _add_boss_hazard_zone_frame(disc, kind, color)

    var marker := Node3D.new()
    marker.name = "Marker"
    model.add_child(marker)
    if lite:
        _add_lite_zone_marker(marker, kind, color)
        return model
    match kind:
        "teemo_mushroom":
            _add_cylinder(marker, 0.08, 0.22, _mat("zone_mushroom_stem", Color(0.88, 0.76, 0.52), 0.05, true), Vector3(0, 0.11, 0))
            _add_sphere(marker, 0.18, _mat("zone_mushroom_cap", Color(0.84, 0.18, 0.16), 0.35, true), Vector3(0, 0.28, 0))
            _add_sphere(marker, 0.04, _mat("zone_mushroom_spot", Color(1.0, 0.92, 0.70), 0.18, true), Vector3(0.07, 0.36, 0.10))
            var poison_mat := _mat("zone_mushroom_poison", Color(0.55, 1.0, 0.22, 0.32), 0.82, true, true)
            _add_cylinder_segments(marker, 0.34, 0.014, 30, poison_mat, Vector3(0, 0.050, 0))
            for spore_index in range(6):
                var spore_angle := TAU * float(spore_index) / 6.0
                var spore_radius := 0.28 + float(spore_index % 2) * 0.08
                _add_sphere(marker, 0.032, poison_mat, Vector3(cos(spore_angle) * spore_radius, 0.086, sin(spore_angle) * spore_radius))
            for fang_index in range(4):
                var fang_angle := TAU * float(fang_index) / 4.0 + PI * 0.25
                _add_box(marker, Vector3(0.040, 0.030, 0.24), _mat("zone_mushroom_warning_tooth", Color(0.78, 1.0, 0.28, 0.36), 0.88, true, true), Vector3(cos(fang_angle) * 0.46, 0.066, sin(fang_angle) * 0.46), Vector3(0, -rad_to_deg(fang_angle), 0))
            _add_teemo_armed_sigils(marker)
        "viktor_gravity":
            var gravity_blue := Color(0.62, 0.82, 1.0)
            _add_sphere(marker, 0.20, _mat("zone_gravity_core", Color(0.62, 0.82, 1.0), 1.35, true), Vector3(0, 0.20, 0))
            _add_cylinder(marker, 0.38, 0.020, _mat("zone_gravity_ring", Color(0.72, 0.94, 1.0, 0.52), 1.0, true, true), Vector3(0, 0.08, 0))
            _add_box(marker, Vector3(0.92, 0.016, 0.045), _mat("zone_gravity_axis_a", Color(gravity_blue.r, gravity_blue.g, gravity_blue.b, 0.42), 0.96, true, true), Vector3(0, 0.060, 0), Vector3.ZERO)
            _add_box(marker, Vector3(0.045, 0.016, 0.92), _mat("zone_gravity_axis_b", Color(gravity_blue.r, gravity_blue.g, gravity_blue.b, 0.42), 0.96, true, true), Vector3(0, 0.062, 0), Vector3.ZERO)
            for pylon_index in range(3):
                var pylon_angle := TAU * float(pylon_index) / 3.0 - PI * 0.5
                var pylon_pos := Vector3(cos(pylon_angle) * 0.50, 0.15, sin(pylon_angle) * 0.50)
                _add_box(marker, Vector3(0.085, 0.24, 0.15), _mat("zone_gravity_pylon", Color(0.28, 0.34, 0.55), 0.22, true), pylon_pos, Vector3(0, -rad_to_deg(pylon_angle), 0))
                _add_sphere(marker, 0.045, _mat("zone_gravity_pylon_core", Color(0.82, 0.98, 1.0), 1.30, true), pylon_pos + Vector3(0, 0.15, 0))
            _add_cylinder_segments(marker, 0.62, 0.012, 6, _mat("zone_gravity_hex_field", Color(0.62, 0.82, 1.0, 0.20), 0.75, true, true), Vector3(0, 0.045, 0), Vector3(0, 30, 0))
        "asol_singularity":
            var star_purple := Color(0.78, 0.42, 1.0)
            _add_sphere(marker, 0.26, _mat("zone_singularity_core", Color(0.06, 0.02, 0.12), 0.6, true), Vector3(0, 0.22, 0))
            _add_cylinder(marker, 0.48, 0.024, _mat("zone_singularity_ring", Color(0.78, 0.42, 1.0, 0.62), 1.25, true, true), Vector3(0, 0.09, 0))
            _add_cylinder_segments(marker, 0.72, 0.014, 42, _mat("zone_singularity_outer_orbit", Color(star_purple.r, star_purple.g, star_purple.b, 0.30), 1.05, true, true), Vector3(0, 0.052, 0))
            for star_index in range(5):
                var star_angle := TAU * float(star_index) / 5.0
                var star_pos := Vector3(cos(star_angle) * 0.66, 0.112, sin(star_angle) * 0.66)
                _add_sphere(marker, 0.050, _mat("zone_singularity_star", Color(0.96, 0.82, 1.0), 1.25, true), star_pos)
                _add_box(marker, Vector3(0.24, 0.012, 0.035), _mat("zone_singularity_star_tail", Color(star_purple.r, star_purple.g, star_purple.b, 0.28), 0.82, true, true), star_pos * 0.80 + Vector3(0, 0.006, 0), Vector3(0, -rad_to_deg(star_angle) + 24.0, 0))
            for crack_index in range(6):
                var crack_angle := TAU * float(crack_index) / 6.0 + PI * 0.10
                _add_box(marker, Vector3(0.48, 0.010, 0.026), _mat("zone_singularity_floor_crack", Color(0.70, 0.18, 1.0, 0.34), 0.90, true, true), Vector3(cos(crack_angle) * 0.36, 0.038, sin(crack_angle) * 0.36), Vector3(0, -rad_to_deg(crack_angle), 0))
        "morde_realm":
            var realm_green := Color(0.42, 1.0, 0.46)
            _add_cylinder(marker, 0.44, 0.034, _mat("zone_realm_ring", Color(0.42, 1.0, 0.46, 0.66), 1.15, true, true), Vector3(0, 0.08, 0))
            _add_box(marker, Vector3(0.46, 0.08, 0.46), _mat("zone_realm_iron", Color(0.12, 0.28, 0.20), 0.20, true), Vector3(0, 0.18, 0), Vector3(0, 45, 0))
            for rune_index in range(4):
                var rune_angle := TAU * float(rune_index) / 4.0 + PI * 0.25
                var rune_pos := Vector3(cos(rune_angle) * 0.58, 0.085, sin(rune_angle) * 0.58)
                _add_box(marker, Vector3(0.18, 0.035, 0.28), _mat("zone_realm_rune_slab", Color(0.08, 0.18, 0.13), 0.18, true), rune_pos, Vector3(0, -rad_to_deg(rune_angle), 0))
                _add_box(marker, Vector3(0.12, 0.014, 0.030), _mat("zone_realm_rune_mark", Color(realm_green.r, realm_green.g, realm_green.b, 0.58), 1.05, true, true), rune_pos + Vector3(0, 0.030, 0), Vector3(0, -rad_to_deg(rune_angle), 0))
            for chain_index in range(8):
                var chain_angle := TAU * float(chain_index) / 8.0
                var chain_pos := Vector3(cos(chain_angle) * 0.74, 0.070, sin(chain_angle) * 0.74)
                _add_box(marker, Vector3(0.20, 0.030, 0.060), _mat("zone_realm_chain_dark", Color(0.06, 0.10, 0.08), 0.16, true), chain_pos, Vector3(0, -rad_to_deg(chain_angle) + 18.0, 0))
            _add_cylinder_segments(marker, 0.78, 0.012, 8, _mat("zone_realm_outer_field", Color(realm_green.r, realm_green.g, realm_green.b, 0.22), 0.78, true, true), Vector3(0, 0.046, 0), Vector3(0, 22.5, 0))
        "boss_cho_rupture":
            var cho_void := Color(0.84, 0.32, 1.0)
            _add_cylinder_segments(marker, 0.56, 0.024, 5, _mat("zone_boss_cho_maw", Color(0.08, 0.02, 0.12, 0.68), 0.20, true, true), Vector3(0, 0.076, 0), Vector3(0, 18, 0))
            _add_cylinder_segments(marker, 0.76, 0.014, 5, _mat("zone_boss_cho_rupture_ring", Color(cho_void.r, cho_void.g, cho_void.b, 0.42), 1.08, true, true), Vector3(0, 0.050, 0), Vector3(0, 18, 0))
            for tooth_index in range(10):
                var tooth_angle := TAU * float(tooth_index) / 10.0
                _add_tapered_cylinder(marker, 0.060, 0.012, 0.46, 5, _mat("zone_boss_cho_tooth", Color(1.0, 0.72, 0.96, 0.52), 0.92, true, true), Vector3(cos(tooth_angle) * 0.54, 0.136, sin(tooth_angle) * 0.54), Vector3(72, 0, -rad_to_deg(tooth_angle)))
        "boss_velkoz_focus":
            var velkoz_pink := Color(1.0, 0.34, 1.0)
            _add_cylinder_segments(marker, 0.56, 0.014, 24, _mat("zone_boss_velkoz_eye_ring", Color(velkoz_pink.r, velkoz_pink.g, velkoz_pink.b, 0.48), 1.18, true, true), Vector3(0, 0.070, 0), Vector3(90, 0, 0))
            _add_sphere(marker, 0.18, _mat("zone_boss_velkoz_eye_core", Color(0.96, 0.76, 1.0), 1.36, true), Vector3(0, 0.190, 0))
            for beam_index in range(4):
                var beam_angle := TAU * float(beam_index) / 4.0 + PI * 0.25
                _add_box(marker, Vector3(0.060, 0.016, 1.10), _mat("zone_boss_velkoz_focus_beam", Color(velkoz_pink.r, velkoz_pink.g, velkoz_pink.b, 0.42), 1.04, true, true), Vector3(cos(beam_angle) * 0.26, 0.084, sin(beam_angle) * 0.26), Vector3(0, -rad_to_deg(beam_angle), 0))
        "boss_reksai_tunnel":
            var reksai_orange := Color(1.0, 0.48, 0.18)
            _add_box(marker, Vector3(0.32, 0.038, 1.18), _mat("zone_boss_reksai_tunnel_core", Color(reksai_orange.r, reksai_orange.g, reksai_orange.b, 0.44), 0.96, true, true), Vector3(0, 0.074, 0), Vector3(0, 0, 0))
            for side in [-1.0, 1.0]:
                _add_box(marker, Vector3(0.10, 0.030, 0.78), _mat("zone_boss_reksai_tunnel_spine", Color(0.28, 0.10, 0.06, 0.72), 0.28, true, true), Vector3(side * 0.34, 0.112, 0.06), Vector3(0, side * 18.0, 0))
            _add_cylinder_segments(marker, 0.72, 0.012, 8, _mat("zone_boss_reksai_tremor_ring", Color(reksai_orange.r, reksai_orange.g, reksai_orange.b, 0.30), 0.84, true, true), Vector3(0, 0.048, 0), Vector3(0, 22.5, 0))
        "boss_belveth_swarm":
            var belveth_purple := Color(0.86, 0.28, 1.0)
            _add_cylinder_segments(marker, 0.66, 0.014, 8, _mat("zone_boss_belveth_swarm_crown", Color(belveth_purple.r, belveth_purple.g, belveth_purple.b, 0.42), 1.08, true, true), Vector3(0, 0.070, 0), Vector3(0, 22.5, 0))
            for wing_index in range(4):
                var wing_angle := TAU * float(wing_index) / 4.0 + PI * 0.25
                _add_box(marker, Vector3(0.13, 0.020, 0.96), _mat("zone_boss_belveth_wing_blade", Color(belveth_purple.r, belveth_purple.g, belveth_purple.b, 0.44), 1.0, true, true), Vector3(cos(wing_angle) * 0.38, 0.102, sin(wing_angle) * 0.38), Vector3(0, -rad_to_deg(wing_angle), 0))
            _add_sphere(marker, 0.13, _mat("zone_boss_belveth_void_core", Color(0.98, 0.74, 1.0), 1.22, true), Vector3(0, 0.176, 0))
        _:
            _add_sphere(marker, 0.18, _mat("zone_core_" + kind, color, 0.8, true), Vector3(0, 0.18, 0))
    return model

func _create_pulse_model(color_value) -> Node3D:
    var model := Node3D.new()
    var color: Color = Color(1.0, 0.36, 0.08, 0.30)
    if color_value is Color:
        color = color_value
    var disc_mat := _mat("pulse_disc_" + color.to_html(false), Color(color.r, color.g, color.b, 0.20), 0.75, true, true)
    var ring_mat := _mat("pulse_ring_" + color.to_html(false), Color(color.r, color.g, color.b, 0.58), 1.05, true, true)
    var family := _pulse_family(color)
    model.set_meta("pulse_family", family)
    _add_cylinder_segments(model, 1.0, 0.030, 48, disc_mat, Vector3.ZERO)
    _add_cylinder_segments(model, 0.72, 0.018, 48, ring_mat, Vector3(0, 0.024, 0))
    _add_cylinder_segments(model, 0.30, 0.022, 32, ring_mat, Vector3(0, 0.042, 0))
    var decal_path := _vfx_decal_texture_path()
    if decal_path != "":
        var decal_tint := Color(color.r, color.g, color.b, minf(0.54, color.a * 1.90 + 0.10))
        var decal_mat := _vfx_decal_mat("pulse_vfx_decal_" + family, decal_path, decal_tint, 1.18, Vector3(0.25, 0.25, 1.0), _pulse_vfx_atlas_offset(family))
        var decal := _add_textured_plane(model, Vector2(2.08, 2.08), decal_mat, Vector3(0, 0.048, 0), Vector3(0, float(model.get_instance_id() % 4) * 90.0, 0))
        decal.name = "PulseVfxDecal"
    _add_pulse_impact_signature(model, family, color)
    _add_pulse_survival_pressure_silhouette(model, family, color)
    for i in range(12):
        var angle := TAU * float(i) / 12.0
        var pos := Vector3(cos(angle) * 0.72, 0.055, sin(angle) * 0.72)
        _add_box(model, Vector3(0.16, 0.014, 0.030), ring_mat, pos, Vector3(0, -rad_to_deg(angle), 0))
    match family:
        "morde":
            var iron_mat := _mat("pulse_morde_iron", Color(color.r, color.g, color.b, 0.42), 0.72, true, true)
            _add_box(model, Vector3(0.30, 0.026, 1.16), iron_mat, Vector3(0, 0.070, 0), Vector3(0, 45, 0))
            _add_box(model, Vector3(1.16, 0.026, 0.30), iron_mat, Vector3(0, 0.072, 0), Vector3(0, 45, 0))
            for chain_index in range(8):
                var morde_chain_angle := TAU * float(chain_index) / 8.0
                _add_box(model, Vector3(0.18, 0.018, 0.060), ring_mat, Vector3(cos(morde_chain_angle) * 0.88, 0.084, sin(morde_chain_angle) * 0.88), Vector3(0, -rad_to_deg(morde_chain_angle) + 18.0, 0))
        "poison":
            var poison_mat := _mat("pulse_poison_spore", Color(color.r, color.g, color.b, 0.38), 0.72, true, true)
            for spore_index in range(10):
                var poison_angle := TAU * float(spore_index) / 10.0
                var poison_radius := 0.34 + float(spore_index % 3) * 0.13
                _add_sphere(model, 0.045, poison_mat, Vector3(cos(poison_angle) * poison_radius, 0.082, sin(poison_angle) * poison_radius))
        "star":
            var star_mat := _mat("pulse_star_ray", Color(color.r, color.g, color.b, 0.42), 0.92, true, true)
            _add_cylinder_segments(model, 0.92, 0.014, 5, star_mat, Vector3(0, 0.060, 0), Vector3(0, 18, 0))
            for star_index in range(8):
                var pulse_star_angle := TAU * float(star_index) / 8.0
                _add_box(model, Vector3(0.10, 0.016, 0.84), star_mat, Vector3(cos(pulse_star_angle) * 0.36, 0.088, sin(pulse_star_angle) * 0.36), Vector3(0, -rad_to_deg(pulse_star_angle), 0))
        "blade":
            var blade_mat := _mat("pulse_blade_slash", Color(color.r, color.g, color.b, 0.42), 0.95, true, true)
            for slash_index in range(3):
                var slash_offset := -0.28 + float(slash_index) * 0.28
                _add_box(model, Vector3(0.13, 0.018, 1.22), blade_mat, Vector3(slash_offset, 0.082, 0), Vector3(0, -34.0 + float(slash_index) * 16.0, 0))
        "feather":
            var feather_mat := _mat("pulse_feather_mark", Color(color.r, color.g, color.b, 0.42), 0.90, true, true)
            for feather_index in range(5):
                var feather_offset := float(feather_index) - 2.0
                _add_box(model, Vector3(0.08, 0.018, 0.78), feather_mat, Vector3(feather_offset * 0.16, 0.082, -0.10 + abs(feather_offset) * 0.06), Vector3(0, feather_offset * 11.0, 0))
        "soul":
            var soul_mat := _mat("pulse_soul_gate", Color(color.r, color.g, color.b, 0.36), 0.90, true, true)
            _add_cylinder_segments(model, 0.52, 0.014, 24, soul_mat, Vector3(0, 0.078, 0), Vector3(90, 0, 0))
            _add_box(model, Vector3(0.86, 0.014, 0.045), soul_mat, Vector3(0, 0.090, 0), Vector3.ZERO)
            _add_box(model, Vector3(0.045, 0.014, 0.86), soul_mat, Vector3(0, 0.092, 0), Vector3.ZERO)
        "rocket":
            var blast_mat := _mat("pulse_rocket_blast", Color(1.0, 0.36, 0.12, 0.46), 1.08, true, true)
            _add_cylinder_segments(model, 0.82, 0.016, 10, blast_mat, Vector3(0, 0.072, 0), Vector3(0, 18, 0))
            for shard_index in range(8):
                var shard_angle := TAU * float(shard_index) / 8.0
                _add_tapered_cylinder(model, 0.045, 0.006, 0.58, 6, blast_mat, Vector3(cos(shard_angle) * 0.45, 0.102, sin(shard_angle) * 0.45), Vector3(74, -rad_to_deg(shard_angle), 0))
            _add_sphere(model, 0.18, _mat("pulse_rocket_core", Color(1.0, 0.82, 0.24), 1.25, true), Vector3(0, 0.112, 0))
        "hextech":
            var hex_mat := _mat("pulse_hextech_grid", Color(color.r, color.g, color.b, 0.38), 1.0, true, true)
            _add_cylinder_segments(model, 0.88, 0.014, 6, hex_mat, Vector3(0, 0.070, 0), Vector3(0, 30, 0))
            _add_cylinder_segments(model, 0.46, 0.012, 6, hex_mat, Vector3(0, 0.088, 0), Vector3(0, 30, 0))
            for circuit_index in range(6):
                var circuit_angle := TAU * float(circuit_index) / 6.0
                _add_box(model, Vector3(0.045, 0.014, 0.74), hex_mat, Vector3(cos(circuit_angle) * 0.38, 0.104, sin(circuit_angle) * 0.38), Vector3(0, -rad_to_deg(circuit_angle), 0))
                _add_sphere(model, 0.035, _mat("pulse_hextech_node", Color(0.84, 1.0, 1.0), 1.22, true), Vector3(cos(circuit_angle) * 0.72, 0.118, sin(circuit_angle) * 0.72))
        "shield":
            var shield_mat := _mat("pulse_shield_plate", Color(color.r, color.g, color.b, 0.42), 0.82, true, true)
            _add_cylinder_segments(model, 0.86, 0.014, 6, shield_mat, Vector3(0, 0.074, 0), Vector3(0, 30, 0))
            _add_box(model, Vector3(0.34, 0.018, 1.02), shield_mat, Vector3(0, 0.096, 0))
            _add_box(model, Vector3(1.02, 0.018, 0.34), shield_mat, Vector3(0, 0.098, 0))
            for shield_index in range(6):
                var shield_angle := TAU * float(shield_index) / 6.0
                _add_sphere(model, 0.040, _mat("pulse_shield_node", Color(0.88, 1.0, 1.0), 1.16, true), Vector3(cos(shield_angle) * 0.66, 0.124, sin(shield_angle) * 0.66))
        "gold":
            var gold_mat := _mat("pulse_gold_reward", Color(1.0, 0.78, 0.24, 0.42), 0.94, true, true)
            _add_cylinder_segments(model, 0.82, 0.016, 6, gold_mat, Vector3(0, 0.070, 0), Vector3(0, 30, 0))
            for coin_index in range(8):
                var coin_angle := TAU * float(coin_index) / 8.0
                _add_cylinder_segments(model, 0.070, 0.022, 6, gold_mat, Vector3(cos(coin_angle) * 0.58, 0.106, sin(coin_angle) * 0.58), Vector3(0, 30, 0))
            _add_cylinder_segments(model, 0.34, 0.012, 6, _mat("pulse_gold_center", Color(1.0, 0.90, 0.42, 0.50), 1.02, true, true), Vector3(0, 0.118, 0), Vector3(0, 30, 0))
        "void":
            var void_mat := _mat("pulse_void_rift", Color(VOID_PURPLE.r, VOID_PURPLE.g, VOID_PURPLE.b, 0.38), 1.02, true, true)
            _add_cylinder_segments(model, 0.88, 0.014, 8, void_mat, Vector3(0, 0.072, 0), Vector3(0, 22.5, 0))
            for rift_index in range(6):
                var rift_angle := TAU * float(rift_index) / 6.0 + PI * 0.08
                _add_box(model, Vector3(0.13, 0.016, 0.76), void_mat, Vector3(cos(rift_angle) * 0.38, 0.102, sin(rift_angle) * 0.38), Vector3(0, -rad_to_deg(rift_angle), 0))
            _add_sphere(model, 0.12, _mat("pulse_void_core", Color(0.92, 0.42, 1.0), 1.22, true), Vector3(0, 0.128, 0))
        "danger":
            var danger_mat := _mat("pulse_danger_warning", Color(DANGER_RED.r, DANGER_RED.g, DANGER_RED.b, 0.44), 1.08, true, true)
            _add_cylinder_segments(model, 0.92, 0.014, 4, danger_mat, Vector3(0, 0.070, 0), Vector3(0, 45, 0))
            _add_box(model, Vector3(1.22, 0.016, 0.070), danger_mat, Vector3(0, 0.096, 0))
            _add_box(model, Vector3(0.070, 0.016, 1.22), danger_mat, Vector3(0, 0.098, 0))
            for warning_index in range(4):
                var warning_angle := TAU * float(warning_index) / 4.0 + PI * 0.25
                _add_box(model, Vector3(0.11, 0.016, 0.48), danger_mat, Vector3(cos(warning_angle) * 0.60, 0.120, sin(warning_angle) * 0.60), Vector3(0, -rad_to_deg(warning_angle), 0))
        _:
            var generic_mat := _mat("pulse_generic_hex_nodes", Color(color.r, color.g, color.b, 0.34), 0.84, true, true)
            _add_cylinder_segments(model, 0.82, 0.012, 6, generic_mat, Vector3(0, 0.066, 0), Vector3(0, 30, 0))
            for node_index in range(6):
                var node_angle := TAU * float(node_index) / 6.0
                _add_sphere(model, 0.032, generic_mat, Vector3(cos(node_angle) * 0.72, 0.088, sin(node_angle) * 0.72))
    return model

func _add_pulse_impact_signature(model: Node3D, family: String, color: Color) -> void:
    var signature := Node3D.new()
    signature.name = "PulseImpactSignature"
    signature.set_meta("family", family)
    model.add_child(signature)

    var hot := color.lightened(0.20)
    var shock_alpha := minf(0.62, maxf(0.36, color.a * 1.70 + 0.18))
    var shock_mat := _mat("pulse_impact_shock_" + family + "_" + color.to_html(false), Color(color.r, color.g, color.b, shock_alpha), 1.18, true, true)
    var hot_mat := _mat("pulse_impact_hot_" + family + "_" + color.to_html(false), Color(hot.r, hot.g, hot.b, 0.70), 1.34, true, true)
    var dark_mat := _mat("pulse_impact_dark_" + family, Color(0.020, 0.010, 0.034, 0.42), 0.08, true, true)
    var trim_mat := _mat("pulse_impact_trim_" + family, Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.34), 0.72, true, true)

    var shock := _add_cylinder_segments(signature, 1.10, 0.012, 32, shock_mat, Vector3(0, 0.104, 0))
    shock.name = "PulseImpactShockRing"
    _add_cylinder_segments(signature, 0.64, 0.010, 8, trim_mat, Vector3(0, 0.122, 0), Vector3(0, 22.5, 0))
    var core := _add_sphere(signature, 0.110, hot_mat, Vector3(0, 0.184, 0))
    core.name = "PulseImpactCore"
    _add_cylinder_segments(signature, 0.26, 0.010, 24, dark_mat, Vector3(0, 0.104, 0))

    var tick_count := 8
    var tick_len := 0.56
    var tick_width := 0.070
    match family:
        "danger", "rocket":
            tick_count = 10
            tick_len = 0.78
            tick_width = 0.090
        "star":
            tick_count = 5
            tick_len = 0.90
            tick_width = 0.075
        "void":
            tick_count = 8
            tick_len = 0.74
            tick_width = 0.080
        "poison", "gold":
            tick_count = 6
            tick_len = 0.46
            tick_width = 0.065
        _:
            pass
    for i in range(tick_count):
        var angle := TAU * float(i) / float(tick_count)
        var radius := 0.74 if i % 2 == 0 else 0.64
        var tick := _add_box(signature, Vector3(tick_width, 0.014, tick_len), shock_mat, Vector3(cos(angle) * radius, 0.136, sin(angle) * radius), Vector3(0, -rad_to_deg(angle), 0))
        tick.name = "PulseImpactGlyphTick%d" % i

    var facet_rig := Node3D.new()
    facet_rig.name = "PulseImpactFacetRig"
    facet_rig.set_meta("family", family)
    signature.add_child(facet_rig)
    var facet_count := 5
    match family:
        "danger", "rocket", "void":
            facet_count = 6
        "star":
            facet_count = 5
        "poison", "gold":
            facet_count = 4
        _:
            pass
    for i in range(facet_count):
        var facet_angle := TAU * float(i) / float(facet_count) + PI * 0.08
        var facet_radius := 0.34 + float(i % 2) * 0.16
        var facet_pos := Vector3(cos(facet_angle) * facet_radius, 0.168 + float(i % 3) * 0.012, sin(facet_angle) * facet_radius)
        var facet: MeshInstance3D
        match family:
            "star":
                facet = _add_tapered_cylinder(facet_rig, 0.044, 0.006, 0.380, 5, hot_mat, facet_pos, Vector3(68, -rad_to_deg(facet_angle), 0))
            "poison":
                facet = _add_sphere(facet_rig, 0.034, hot_mat, facet_pos)
            "void":
                facet = _add_box(facet_rig, Vector3(0.070, 0.012, 0.360), dark_mat if i % 2 == 0 else hot_mat, facet_pos, Vector3(0, -rad_to_deg(facet_angle), 0))
            "danger", "rocket":
                facet = _add_box(facet_rig, Vector3(0.084, 0.014, 0.460), hot_mat if i % 2 == 0 else shock_mat, facet_pos, Vector3(0, -rad_to_deg(facet_angle), 0))
            _:
                facet = _add_box(facet_rig, Vector3(0.074, 0.012, 0.320), shock_mat, facet_pos, Vector3(0, -rad_to_deg(facet_angle), 0))
        facet.name = "PulseImpactFacet%d" % i

    match family:
        "danger", "rocket":
            _add_box(signature, Vector3(1.34, 0.016, 0.070), hot_mat, Vector3(0, 0.158, 0))
            _add_box(signature, Vector3(0.070, 0.016, 1.34), hot_mat, Vector3(0, 0.160, 0))
        "void":
            for i in range(4):
                var crack_angle := TAU * float(i) / 4.0 + PI * 0.18
                _add_box(signature, Vector3(0.12, 0.014, 0.92), hot_mat, Vector3(cos(crack_angle) * 0.26, 0.160, sin(crack_angle) * 0.26), Vector3(0, -rad_to_deg(crack_angle), 0))
        "hextech", "shield":
            _add_cylinder_segments(signature, 0.86, 0.010, 6, hot_mat, Vector3(0, 0.154, 0), Vector3(0, 30, 0))
            _add_cylinder_segments(signature, 0.42, 0.010, 6, shock_mat, Vector3(0, 0.168, 0), Vector3(0, 30, 0))
        "star":
            _add_cylinder_segments(signature, 0.76, 0.012, 5, hot_mat, Vector3(0, 0.154, 0), Vector3(0, 18, 0))
        "poison":
            for i in range(6):
                var spore_angle := TAU * float(i) / 6.0
                _add_sphere(signature, 0.046, hot_mat, Vector3(cos(spore_angle) * 0.54, 0.176, sin(spore_angle) * 0.54))
        _:
            _add_cylinder_segments(signature, 0.72, 0.010, 6, shock_mat, Vector3(0, 0.150, 0), Vector3(0, 30, 0))

func _add_pulse_survival_pressure_silhouette(model: Node3D, family: String, color: Color) -> void:
    var rank := _pulse_pressure_rank(family)
    if rank == "":
        return
    var detail_node := _pulse_pressure_detail_node(family)
    var silhouette := Node3D.new()
    silhouette.name = "PulseSurvivalPressureSilhouette"
    silhouette.set_meta("pulse_family", family)
    silhouette.set_meta("pressure_rank", rank)
    silhouette.set_meta("detail_node", detail_node)
    silhouette.set_meta("combat_visual_channel", "survival_pressure_readability")
    silhouette.set_meta("material_grade", "low_glare_pulse_pressure_silhouette")
    silhouette.set_meta("pickup_confusion_guard", true)
    silhouette.set_meta("anti_glare", true)
    model.add_child(silhouette)

    var signal_source := _pulse_pressure_signal_color(family, color)
    var dark_color := Color(0.010, 0.008, 0.018, 0.16)
    var signal_color := Color(signal_source.r, signal_source.g, signal_source.b, 0.18)
    var trim_color := Color(HEXTECH_GOLD.r, HEXTECH_GOLD.g, HEXTECH_GOLD.b, 0.12)
    var shadow_mat := _mat("pulse_pressure_shadow_" + family, dark_color, 0.0, true, true)
    var signal_mat := _mat("pulse_pressure_signal_" + family, signal_color, 0.32, true, true)
    var trim_mat := _mat("pulse_pressure_trim_" + family, trim_color, 0.16, true, true)

    var shadow := _add_cylinder_segments(silhouette, 1.18, 0.010, 8, shadow_mat, Vector3(0, 0.030, 0), Vector3(0, 22.5, 0))
    shadow.name = "PulsePressureShadowPlate"
    _mark_pulse_pressure_mesh(shadow, dark_color, 1.0)
    var bracket_segments := 4 if family == "danger" else 6
    var bracket_rot := 45.0 if family == "danger" else 30.0
    var bracket := _add_cylinder_segments(silhouette, 1.04, 0.012, bracket_segments, signal_mat, Vector3(0, 0.060, 0), Vector3(0, bracket_rot, 0))
    bracket.name = "PulsePressureOuterBracket"
    _mark_pulse_pressure_mesh(bracket, signal_color, 1.0)
    var needle := _add_box(silhouette, Vector3(0.095, 0.016, 0.86), signal_mat, Vector3(0, 0.086, -0.55), Vector3.ZERO)
    needle.name = "PulsePressureDirectionNeedle"
    _mark_pulse_pressure_mesh(needle, signal_color, 0.92)
    var trim := _add_box(silhouette, Vector3(0.72, 0.014, 0.050), trim_mat, Vector3(0, 0.074, 0.40), Vector3.ZERO)
    trim.name = "PulsePressureReadabilityTrim"
    _mark_pulse_pressure_mesh(trim, trim_color, 0.85)

    var detail := Node3D.new()
    detail.name = detail_node
    detail.set_meta("pulse_family", family)
    detail.set_meta("pressure_rank", rank)
    silhouette.add_child(detail)
    match family:
        "danger":
            for i in range(3):
                var offset := float(i - 1) * 0.20
                var spike := _add_tapered_cylinder(detail, 0.050, 0.008, 0.34, 4, signal_mat, Vector3(offset, 0.116, 0.06 + abs(offset) * 0.22), Vector3(68, 0, 0))
                spike.name = "PulsePressureBossCrownSpike%d" % i
                _mark_pulse_pressure_mesh(spike, signal_color, 0.95)
        "void":
            for i in range(4):
                var angle := TAU * float(i) / 4.0 + PI * 0.25
                var spike := _add_box(detail, Vector3(0.074, 0.014, 0.48), signal_mat, Vector3(cos(angle) * 0.28, 0.112, sin(angle) * 0.28), Vector3(0, -rad_to_deg(angle), 0))
                spike.name = "PulsePressureVoidSpike%d" % i
                _mark_pulse_pressure_mesh(spike, signal_color, 0.90)
        "hextech":
            var hex := _add_cylinder_segments(detail, 0.34, 0.010, 6, signal_mat, Vector3(0, 0.112, 0), Vector3(0, 30, 0))
            hex.name = "PulsePressureHexCircuitRing"
            _mark_pulse_pressure_mesh(hex, signal_color, 0.90)
            for i in range(2):
                var bar := _add_box(detail, Vector3(0.56, 0.012, 0.040), trim_mat, Vector3(0, 0.128 + float(i) * 0.010, 0), Vector3(0, 60.0 * float(i), 0))
                bar.name = "PulsePressureHexCircuitBar%d" % i
                _mark_pulse_pressure_mesh(bar, trim_color, 0.82)
        _:
            var mark := _add_box(detail, Vector3(0.46, 0.012, 0.080), signal_mat, Vector3(0, 0.112, 0), Vector3.ZERO)
            mark.name = "PulsePressureGenericMark"
            _mark_pulse_pressure_mesh(mark, signal_color, 0.90)

func _mark_pulse_pressure_mesh(mesh: MeshInstance3D, alpha_color: Color, alpha_multiplier: float) -> void:
    mesh.set_meta("combat_visual_channel", "survival_pressure_readability")
    mesh.set_meta("material_grade", "low_glare_pulse_pressure_silhouette")
    mesh.set_meta("anti_glare", true)
    mesh.set_meta("pulse_alpha_color", alpha_color)
    mesh.set_meta("pulse_alpha_multiplier", alpha_multiplier)
    mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _pulse_pressure_rank(family: String) -> String:
    match family:
        "danger":
            return "boss_danger"
        "void":
            return "void_elite"
        "hextech":
            return "hextech_event"
        _:
            return ""

func _pulse_pressure_detail_node(family: String) -> String:
    match family:
        "danger":
            return "PulsePressureBossDangerCrown"
        "void":
            return "PulsePressureVoidEliteSpikes"
        "hextech":
            return "PulsePressureHextechEventCircuit"
        _:
            return "PulsePressureGenericDetail"

func _pulse_pressure_signal_color(family: String, color: Color) -> Color:
    match family:
        "danger":
            return Color(1.0, 0.18, 0.26)
        "void":
            return Color(0.78, 0.30, 1.0)
        "hextech":
            return Color(0.42, 0.82, 1.0)
        _:
            return color

func _pulse_family(color: Color) -> String:
    if color.r > 0.92 and color.g > 0.68 and color.b < 0.34:
        return "gold"
    if color.r > 0.86 and color.g < 0.20 and color.b < 0.34:
        return "danger"
    if color.b > 0.90 and color.g > 0.88 and color.r > 0.66:
        return "shield"
    if color.r > 0.70 and color.g < 0.66 and color.b > 0.80:
        return "void"
    if color.g > 0.78 and color.b < 0.34:
        return "poison"
    if color.g > 0.78 and color.r < 0.48 and color.b < 0.66:
        return "morde"
    if color.r > 0.88 and color.g > 0.50 and color.g < 0.82 and color.b < 0.34:
        return "rocket"
    if color.r > 0.88 and color.g > 0.26 and color.g < 0.50 and color.b < 0.34:
        return "rocket"
    if color.b > 0.88 and color.g > 0.78 and color.r > 0.50 and color.r < 0.84:
        return "hextech"
    if color.b > 0.86 and color.r > 0.55:
        return "star"
    if color.r > 0.82 and color.g < 0.52 and color.b > 0.50:
        return "feather"
    if color.r > 0.82 and color.g < 0.52:
        return "blade"
    if color.g > 0.78 and color.b > 0.62 and color.r < 0.72:
        return "soul"
    return "generic"

func _pulse_vfx_atlas_offset(family: String) -> Vector3:
    match family:
        "void":
            return Vector3(0.25, 0.0, 0.0)
        "gold":
            return Vector3(0.50, 0.0, 0.0)
        "danger":
            return Vector3(0.0, 0.75, 0.0)
        "poison", "morde":
            return Vector3(0.75, 0.75, 0.0)
        "star":
            return Vector3(0.50, 0.75, 0.0)
        "blade", "feather", "rocket":
            return Vector3(0.25, 0.50, 0.0)
        "shield":
            return Vector3(0.50, 0.25, 0.0)
        "hextech", "soul":
            return Vector3(0.0, 0.25, 0.0)
        _:
            return Vector3.ZERO

func _pulse_rotation_speed(family: String) -> float:
    match family:
        "rocket", "danger", "blade":
            return 1.55
        "hextech", "shield":
            return 0.72
        "star", "void":
            return -0.96
        "poison":
            return 0.42
        "morde":
            return -0.34
        "gold":
            return 1.12
        "soul":
            return 0.50
        "feather":
            return -0.62
        _:
            return 0.38

func _make_unique_materials(node: Node) -> void:
    for child in node.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.material_override is StandardMaterial3D:
                mesh_instance.material_override = (mesh_instance.material_override as StandardMaterial3D).duplicate()
        _make_unique_materials(child)

func _add_topdown_model_outline(model: Node3D, key: String, inflate: float) -> void:
    var outline_root := Node3D.new()
    outline_root.name = "TopdownOutline"
    model.add_child(outline_root)
    var outline_mat := _mat(key + "_topdown_outline", Color(0.0, 0.0, 0.0, 0.50), 0.0, true, true)
    _copy_outline_meshes(model, outline_root, Transform3D.IDENTITY, outline_mat, inflate)

func _copy_outline_meshes(source: Node3D, outline_root: Node3D, parent_transform: Transform3D, outline_mat: Material, inflate: float) -> void:
    for child in source.get_children():
        if child == outline_root or not (child is Node3D):
            continue
        var child_3d := child as Node3D
        var combined := parent_transform * child_3d.transform
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.mesh == null:
                continue
            if _skip_outline_material(mesh_instance.material_override):
                continue
            var outline := MeshInstance3D.new()
            outline.mesh = mesh_instance.mesh
            outline.material_override = outline_mat
            outline.transform = combined
            outline.scale = outline.scale * Vector3(inflate, 1.02, inflate)
            outline.position.y = maxf(0.006, outline.position.y - 0.026)
            outline.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
            outline_root.add_child(outline)
        else:
            _copy_outline_meshes(child_3d, outline_root, combined, outline_mat, inflate)

func _skip_outline_material(material: Material) -> bool:
    if material is StandardMaterial3D:
        var standard_mat := material as StandardMaterial3D
        return standard_mat.albedo_color.a < 0.99 or standard_mat.emission_enabled
    return false

func _champion_style(champion: String) -> Dictionary:
    match champion:
        "senna":
            return {"body": Color(0.08, 0.12, 0.12), "accent": Color(0.48, 1.0, 0.76), "hair": Color(0.92, 0.98, 0.92), "scale": 1.04}
        "samira":
            return {"body": Color(0.78, 0.20, 0.16), "accent": Color(1.0, 0.74, 0.24), "hair": Color(0.16, 0.10, 0.08), "scale": 1.0}
        "viktor":
            return {"body": Color(0.42, 0.25, 0.66), "accent": Color(0.72, 0.94, 1.0), "hair": Color(0.72, 0.62, 0.34), "scale": 1.06}
        "xayah":
            return {"body": Color(0.50, 0.18, 0.60), "accent": Color(1.0, 0.34, 0.62), "hair": Color(0.82, 0.18, 0.38), "scale": 0.98}
        "mordekaiser":
            return {"body": Color(0.18, 0.34, 0.28), "accent": Color(0.58, 1.0, 0.58), "hair": Color(0.50, 0.58, 0.52), "scale": 1.18}
        "teemo":
            return {"body": Color(0.34, 0.56, 0.28), "accent": Color(0.82, 0.62, 0.24), "hair": Color(0.72, 0.48, 0.25), "scale": 0.86}
        "aurelion_sol":
            return {"body": Color(0.16, 0.28, 0.72), "accent": Color(0.92, 0.72, 1.0), "hair": Color(0.30, 0.72, 1.0), "scale": 1.1}
        _:
            return {"body": Color(0.26, 0.72, 0.98), "accent": Color(1.0, 0.26, 0.62), "hair": Color(0.18, 0.62, 1.0), "scale": 0.98}

func _get_player() -> Node2D:
    var players := get_tree().get_nodes_in_group("survivor_player")
    if players.size() == 0:
        return null
    return players[0]

func _remove_missing(models: Dictionary, alive: Dictionary) -> void:
    for id in models.keys():
        if alive.has(id):
            continue
        if is_instance_valid(models[id]):
            models[id].queue_free()
        models.erase(id)

func _to3d(pos: Vector2, height := 0.0) -> Vector3:
    return Vector3(pos.x * WORLD_SCALE, height, pos.y * WORLD_SCALE)

func _asset_available(path: String) -> bool:
    return ResourceLoader.exists(path) or FileAccess.file_exists(path)

func _mat(key: String, color: Color, emission := 0.0, rough := false, transparent := false) -> StandardMaterial3D:
    var lower_key := key.to_lower()
    var render_color := _readability_material_color(lower_key, color, transparent)
    var render_emission := _readability_material_emission(lower_key, emission, transparent)
    var final_key := "%s_%s_%.2f_%s" % [key, render_color.to_html(true), render_emission, str(transparent)]
    if material_cache.has(final_key):
        return material_cache[final_key]
    var mat := StandardMaterial3D.new()
    mat.albedo_color = render_color
    mat.roughness = 0.78 if rough else 0.52
    if lower_key.contains("gold") or lower_key.contains("trim") or lower_key.contains("metal") or lower_key.contains("armor") or lower_key.contains("coin"):
        mat.metallic = 0.62
        mat.roughness = 0.38
    elif lower_key.contains("stone") or lower_key.contains("tile") or lower_key.contains("floor"):
        mat.metallic = 0.0
        mat.roughness = 0.92
    elif lower_key.contains("crystal") or lower_key.contains("void") or lower_key.contains("core"):
        mat.metallic = 0.08
        mat.roughness = 0.34
    _apply_material_quality_grade(mat, lower_key, render_emission, transparent)
    var texture_path := _texture_for_material_key(lower_key, render_emission, transparent)
    if texture_path != "":
        var texture := _load_texture(texture_path)
        if texture != null:
            mat.albedo_texture = texture
            mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
    if transparent or render_color.a < 0.99:
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    if render_emission > 0.0:
        mat.emission_enabled = true
        mat.emission = Color(render_color.r, render_color.g, render_color.b)
        mat.emission_energy_multiplier = render_emission
        _apply_material_quality_grade(mat, lower_key, render_emission, transparent)
    material_cache[final_key] = mat
    return mat

func _readability_material_color(lower_key: String, color: Color, transparent: bool) -> Color:
    var result := color
    if transparent or result.a < 0.99:
        var alpha_scale := 0.26
        var alpha_min := 0.02
        var alpha_max := 0.98
        if lower_key.contains("enemy_proj") or lower_key.contains("enemy_projectile"):
            alpha_scale = 0.30
            if lower_key.contains("danger") or lower_key.contains("threat") or lower_key.contains("occlusion"):
                alpha_scale = 0.34
                alpha_min = 0.246
                alpha_max = 0.340
        elif lower_key.contains("pickup"):
            alpha_scale = 0.028
            if lower_key.contains("reward") or lower_key.contains("treasure") or lower_key.contains("heal") or lower_key.contains("shield") or lower_key.contains("gold"):
                alpha_scale = 0.048
        elif lower_key.contains("player_projectile") or lower_key.contains("player_path") or lower_key.contains("player_spell") or lower_key.contains("player_impact") or lower_key.contains("proj_tail") or _is_player_projectile_material_key(lower_key):
            alpha_scale = 0.052
        elif lower_key.contains("zone_") or lower_key.contains("pulse_"):
            alpha_scale = 0.030
        elif lower_key.contains("decal"):
            alpha_scale = 0.034
        result.a = clampf(result.a * alpha_scale, alpha_min, alpha_max)
    return result

func _readability_material_emission(lower_key: String, emission: float, transparent: bool) -> float:
    if emission <= 0.0:
        return 0.0
    var scale := 0.058
    if lower_key.contains("enemy_proj") or lower_key.contains("enemy_projectile"):
        scale = 0.054
    elif lower_key.contains("pickup"):
        scale = 0.008
        if lower_key.contains("reward") or lower_key.contains("treasure") or lower_key.contains("heal") or lower_key.contains("shield") or lower_key.contains("gold"):
            scale = 0.014
    elif lower_key.contains("player_projectile") or lower_key.contains("player_path") or lower_key.contains("player_spell") or lower_key.contains("player_impact") or lower_key.contains("proj_tail") or _is_player_projectile_material_key(lower_key):
        scale = 0.026
    elif lower_key.contains("zone_") or lower_key.contains("pulse_"):
        scale = 0.011
    elif lower_key.contains("decal"):
        scale = 0.013
    elif lower_key.contains("death_burst"):
        scale = 0.026
    elif transparent:
        scale = 0.032
    return clampf(emission * scale, 0.008, _readability_material_emission_cap(lower_key, transparent))

func _readability_material_emission_cap(lower_key: String, transparent: bool) -> float:
    if lower_key.contains("enemy_proj") or lower_key.contains("enemy_projectile"):
        return 0.082
    if lower_key.contains("pickup"):
        if lower_key.contains("reward") or lower_key.contains("treasure") or lower_key.contains("heal") or lower_key.contains("shield") or lower_key.contains("gold"):
            return 0.038
        return 0.026
    if lower_key.contains("player_projectile") or lower_key.contains("player_path") or lower_key.contains("player_spell") or lower_key.contains("player_impact") or lower_key.contains("proj_tail") or _is_player_projectile_material_key(lower_key):
        return 0.054
    if lower_key.contains("zone_") or lower_key.contains("pulse_"):
        return 0.030
    if lower_key.contains("decal"):
        return 0.034
    if transparent:
        return 0.058
    return 0.105

func _is_player_projectile_material_key(lower_key: String) -> bool:
    var is_player_fx := lower_key.contains("player_proj") or lower_key.contains("player_role")
    is_player_fx = is_player_fx or lower_key.contains("rocket_")
    is_player_fx = is_player_fx or lower_key.contains("senna_")
    is_player_fx = is_player_fx or lower_key.contains("viktor_")
    is_player_fx = is_player_fx or lower_key.contains("xayah_")
    is_player_fx = is_player_fx or lower_key.contains("teemo_dart")
    is_player_fx = is_player_fx or lower_key.contains("blind_dart")
    is_player_fx = is_player_fx or lower_key.contains("bullet_")
    is_player_fx = is_player_fx or lower_key.contains("comet_")
    is_player_fx = is_player_fx or lower_key.contains("proj_shell")
    is_player_fx = is_player_fx or lower_key.contains("proj_core")
    return is_player_fx

func _apply_material_quality_grade(mat: StandardMaterial3D, lower_key: String, emission: float, transparent: bool) -> void:
    var is_stone := _material_is_stone(lower_key)
    var is_metal := not is_stone and _material_is_metal(lower_key)
    var is_energy := _material_is_energy(lower_key, emission)
    var material_family := "energy" if is_energy else "metal" if is_metal else "stone" if is_stone else "painted"
    mat.set_meta("cinematic_material_family", material_family)
    mat.set_meta("cinematic_material_grade", "hextech_void_painted")
    mat.set_meta("cinematic_material_emission", emission)
    if is_stone:
        mat.metallic = 0.0
        mat.roughness = maxf(mat.roughness, 0.88)
        _set_material_property_if_available(mat, "metallic_specular", 0.18)
    elif is_metal:
        mat.metallic = maxf(mat.metallic, 0.74)
        mat.roughness = minf(mat.roughness, 0.26)
        _set_material_property_if_available(mat, "metallic_specular", 0.88)
        _set_material_property_if_available(mat, "clearcoat_enabled", true)
        _set_material_property_if_available(mat, "clearcoat", 0.58)
        _set_material_property_if_available(mat, "clearcoat_roughness", 0.16)
        _set_material_property_if_available(mat, "anisotropy_enabled", true)
        _set_material_property_if_available(mat, "anisotropy", 0.34)
    if is_energy:
        mat.roughness = minf(mat.roughness, 0.30)
        _set_material_property_if_available(mat, "metallic_specular", 0.56 if transparent else 0.66)
        _set_material_property_if_available(mat, "rim_enabled", true)
        var rim_value := 0.42
        if transparent or emission <= 0.70:
            rim_value = 0.34
        elif emission > 0.90:
            rim_value = 0.46
        _set_material_property_if_available(mat, "rim", rim_value)
        _set_material_property_if_available(mat, "rim_tint", 0.42 if transparent else 0.50)
        _set_material_property_if_available(mat, "clearcoat_enabled", true)
        _set_material_property_if_available(mat, "clearcoat", 0.14 if transparent else 0.22)
        _set_material_property_if_available(mat, "clearcoat_roughness", 0.20 if transparent else 0.16)

func _material_is_stone(lower_key: String) -> bool:
    return lower_key.contains("stone") or lower_key.contains("tile") or lower_key.contains("floor") or lower_key.contains("shadow")

func _material_is_metal(lower_key: String) -> bool:
    return (
        lower_key.contains("gold")
        or lower_key.contains("trim")
        or lower_key.contains("metal")
        or lower_key.contains("armor")
        or lower_key.contains("coin")
        or lower_key.contains("pillar")
        or lower_key.contains("pylon")
        or lower_key.contains("tower")
    )

func _material_is_energy(lower_key: String, emission: float) -> bool:
    return (
        lower_key.contains("glow")
        or lower_key.contains("core")
        or lower_key.contains("crystal")
        or lower_key.contains("void")
        or lower_key.contains("energy")
        or lower_key.contains("beam")
        or lower_key.contains("rune")
        or lower_key.contains("pulse")
        or lower_key.contains("decal")
        or lower_key.contains("aura")
        or lower_key.contains("weakpoint")
        or lower_key.contains("eye")
        or emission > 0.78
    )

func _set_material_property_if_available(mat: Object, property_name: String, value) -> void:
    _set_object_property_if_available(mat, property_name, value)

func _material_supports_property(mat: Object, property_name: String) -> bool:
    return _object_supports_property(mat, property_name)

func _set_object_property_if_available(object: Object, property_name: String, value) -> void:
    if not _object_supports_property(object, property_name):
        return
    object.set(property_name, value)

func _object_supports_property(object: Object, property_name: String) -> bool:
    var cache_key := object.get_class() + ":" + property_name
    if material_property_support_cache.has(cache_key):
        return bool(material_property_support_cache[cache_key])
    for property in object.get_property_list():
        if str(property.get("name", "")) == property_name:
            material_property_support_cache[cache_key] = true
            return true
    material_property_support_cache[cache_key] = false
    return false

func _texture_for_material_key(lower_key: String, emission: float, transparent: bool) -> String:
    if transparent or emission > 0.80:
        return ""
    if lower_key.contains("skitter") or lower_key.contains("spitter") or lower_key.contains("burrower") or lower_key.contains("carapace") or lower_key.contains("void_eye") or lower_key.contains("boss_") or lower_key.contains("bug_leg") or lower_key.contains("tentacle") or lower_key.contains("void_shell"):
        return _void_carapace_texture_path()
    if lower_key.contains("gold") or lower_key.contains("trim") or lower_key.contains("metal") or lower_key.contains("frame") or lower_key.contains("pillar") or lower_key.contains("pylon") or lower_key.contains("coin") or lower_key.contains("plate"):
        return _hextech_metal_texture_path()
    return ""

func _load_texture(texture_path: String) -> Texture2D:
    if texture_cache.has(texture_path):
        return texture_cache[texture_path]
    if not _asset_available(texture_path):
        texture_cache[texture_path] = null
        return null
    var image := Image.new()
    var err := image.load(texture_path)
    if err != OK:
        texture_cache[texture_path] = null
        return null
    var texture := ImageTexture.create_from_image(image)
    texture_cache[texture_path] = texture
    return texture

func _texture_mat(key: String, texture_path: String, color: Color, emission := 0.0, rough := true, transparent := false, uv_scale := Vector3.ONE, uv_offset := Vector3.ZERO) -> StandardMaterial3D:
    var lower_key := key.to_lower()
    var render_color := _readability_material_color(lower_key, color, transparent)
    var render_emission := _readability_material_emission(lower_key, emission, transparent)
    var final_key := "%s_%s_%s_%.2f_%s_%s_%s" % [key, texture_path, render_color.to_html(true), render_emission, str(transparent), str(uv_scale), str(uv_offset)]
    if material_cache.has(final_key):
        return material_cache[final_key]
    var mat := _mat(key + "_fallback", render_color, render_emission, rough, transparent)
    if not _asset_available(texture_path):
        return mat
    var texture := _load_texture(texture_path)
    if texture == null:
        return mat

    var textured_mat := StandardMaterial3D.new()
    textured_mat.albedo_color = render_color
    textured_mat.albedo_texture = texture
    textured_mat.roughness = 0.82 if rough else 0.48
    textured_mat.uv1_scale = uv_scale
    textured_mat.uv1_offset = uv_offset
    textured_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
    if transparent or render_color.a < 0.99:
        textured_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    if lower_key.contains("floor"):
        textured_mat.roughness = 0.90
    if lower_key.contains("void"):
        textured_mat.roughness = 0.46
    if render_emission > 0.0:
        textured_mat.emission_enabled = true
        textured_mat.emission = Color(render_color.r, render_color.g, render_color.b)
        textured_mat.emission_energy_multiplier = render_emission
    _apply_material_quality_grade(textured_mat, lower_key, render_emission, transparent)
    material_cache[final_key] = textured_mat
    return textured_mat

func _vfx_decal_mat(key: String, texture_path: String, color: Color, emission := 1.0, uv_scale := Vector3.ONE, uv_offset := Vector3.ZERO) -> StandardMaterial3D:
    var mat := _texture_mat(key, texture_path, color, emission, true, true, uv_scale, uv_offset)
    mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
    mat.disable_receive_shadows = true
    return mat

func _add_box(parent: Node3D, size: Vector3, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size
    return _add_mesh(parent, mesh, mat, pos, rot)

func _add_sphere(parent: Node3D, radius: float, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    if radius <= 0.065:
        mesh.radial_segments = 8
        mesh.rings = 4
    elif radius <= 0.16:
        mesh.radial_segments = 12
        mesh.rings = 6
    else:
        mesh.radial_segments = 18
        mesh.rings = 9
    return _add_mesh(parent, mesh, mat, pos, rot)

func _add_capsule(parent: Node3D, radius: float, height: float, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    mesh.radial_segments = 16
    mesh.rings = 8
    return _add_mesh(parent, mesh, mat, pos, rot)

func _add_cylinder_segments(parent: Node3D, radius: float, height: float, segments: int, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = segments
    return _add_mesh(parent, mesh, mat, pos, rot)

func _add_tapered_cylinder(parent: Node3D, bottom_radius: float, top_radius: float, height: float, segments: int, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
    var mesh := CylinderMesh.new()
    mesh.top_radius = top_radius
    mesh.bottom_radius = bottom_radius
    mesh.height = height
    mesh.radial_segments = segments
    return _add_mesh(parent, mesh, mat, pos, rot)

func _add_crystal(parent: Node3D, radius: float, height: float, color: Color, pos: Vector3, rot := Vector3.ZERO, material_prefix := "crystal") -> Node3D:
    var model := Node3D.new()
    model.position = pos
    model.rotation_degrees = rot
    parent.add_child(model)
    var key_prefix := material_prefix.to_lower()
    var body_mat := _mat(key_prefix + "_body_" + color.to_html(false), color.lightened(0.10), 0.85, true)
    var side_mat := _mat(key_prefix + "_side_" + color.to_html(false), color.darkened(0.18), 0.50, true)
    var glow_mat := _mat(key_prefix + "_glow_" + color.to_html(false), Color(color.r, color.g, color.b, 0.18), 0.62, true, true)
    _add_tapered_cylinder(model, radius, radius * 0.16, height * 0.62, 6, body_mat, Vector3(0, height * 0.14, 0), Vector3(0, 30, 0))
    _add_tapered_cylinder(model, radius * 0.76, radius * 0.08, height * 0.36, 6, side_mat, Vector3(0, -height * 0.36, 0), Vector3(180, 30, 0))
    _add_cylinder_segments(model, radius * 1.45, 0.018, 24, glow_mat, Vector3(0, -height * 0.53, 0))
    return model

func _add_cylinder(parent: Node3D, radius: float, height: float, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 18
    return _add_mesh(parent, mesh, mat, pos, rot)

func _add_textured_plane(parent: Node3D, size: Vector2, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
    var mesh := PlaneMesh.new()
    mesh.size = size
    var instance := _add_mesh(parent, mesh, mat, pos, rot)
    instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    return instance

func _add_mesh(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    instance.material_override = mat
    instance.position = pos
    instance.rotation_degrees = rot
    instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    if mat is StandardMaterial3D:
        var standard_mat := mat as StandardMaterial3D
        if standard_mat.albedo_color.a < 0.99 or standard_mat.emission_enabled:
            instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    parent.add_child(instance)
    return instance

func _set_model_shadow_casting(node: Node, enabled: bool) -> void:
    for child in node.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.mesh == null:
                continue
            var can_cast := enabled
            if mesh_instance.material_override is StandardMaterial3D:
                var standard_mat := mesh_instance.material_override as StandardMaterial3D
                can_cast = can_cast and standard_mat.albedo_color.a >= 0.99 and not standard_mat.emission_enabled
            mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if can_cast else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        _set_model_shadow_casting(child, enabled)

func _add_shadow(parent: Node3D, radius: float) -> void:
    var shadow := _add_cylinder_segments(parent, radius, 0.014, 28, _mat("grounded_contact_shadow", Color(0.0, 0.0, 0.0, 0.32), 0.0, true, true), Vector3(0, 0.010, 0))
    shadow.name = "GroundedContactShadow"
    shadow.set_meta("art_role", "grounding_contact_shadow")
    shadow.set_meta("combat_visual_channel", "grounding_shadow")
    shadow.set_meta("readability_priority", 0.05)
    shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

    var core := _add_cylinder_segments(parent, radius * 0.46, 0.012, 20, _mat("grounded_contact_core", Color(0.0, 0.0, 0.0, 0.24), 0.0, true, true), Vector3(0, 0.020, radius * 0.05))
    core.name = "GroundedContactCore"
    core.set_meta("art_role", "grounding_contact_core")
    core.set_meta("combat_visual_channel", "grounding_shadow")
    core.set_meta("readability_priority", 0.08)
    core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
