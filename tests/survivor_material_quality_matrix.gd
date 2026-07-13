extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    var world_env := view.get_node_or_null("HextechVoidWorldEnvironment") as WorldEnvironment
    if world_env == null or world_env.environment == null:
        push_error("Material quality matrix expected named HextechVoidWorldEnvironment.")
        quit(1)
        return
    var environment := world_env.environment
    if not environment.glow_enabled or environment.glow_intensity > 0.003 or environment.glow_strength > 0.018 or environment.glow_bloom > 0.0004:
        push_error("Material quality matrix expected restrained low-glare glow.")
        quit(1)
        return
    if environment.tonemap_mode != Environment.TONE_MAPPER_ACES:
        push_error("Material quality matrix expected ACES tonemapping.")
        quit(1)
        return
    if environment.ambient_light_energy > 0.060 or environment.tonemap_exposure > 0.43:
        push_error("Material quality matrix expected darker ambient and lower ACES exposure.")
        quit(1)
        return
    if _supports_property(environment, "adjustment_enabled"):
        if not bool(environment.get("adjustment_enabled")):
            push_error("Material quality matrix expected cinematic color adjustment.")
            quit(1)
            return
        if _supports_property(environment, "adjustment_contrast") and float(environment.get("adjustment_contrast")) < 1.60:
            push_error("Material quality matrix expected stronger contrast and restrained saturation adjustment.")
            quit(1)
            return
        if _supports_property(environment, "adjustment_saturation") and float(environment.get("adjustment_saturation")) > 0.47:
            push_error("Material quality matrix expected stronger contrast and restrained saturation adjustment.")
            quit(1)
            return
    for light_name in ["HextechKeyLight", "HextechFillLight", "VoidRimLight", "HextechGoldRimLight"]:
        var light := view.get_node_or_null(light_name) as Light3D
        if light == null:
            push_error("Material quality matrix missing %s." % light_name)
            quit(1)
            return
        if str(light.get_meta("cinematic_role", "")) == "":
            push_error("Material quality matrix expected cinematic role metadata on %s." % light_name)
            quit(1)
            return
    var key_light := view.get_node_or_null("HextechKeyLight") as DirectionalLight3D
    var fill_light := view.get_node_or_null("HextechFillLight") as OmniLight3D
    var void_rim := view.get_node_or_null("VoidRimLight") as OmniLight3D
    var gold_rim := view.get_node_or_null("HextechGoldRimLight") as OmniLight3D
    if key_light.light_energy > 0.58 or fill_light.light_energy > 0.034:
        push_error("Material quality matrix expected reduced key and controlled fill light.")
        quit(1)
        return
    if void_rim.light_energy > 0.019 or gold_rim.light_energy > 0.019:
        push_error("Material quality matrix expected restrained void/gold rim lights.")
        quit(1)
        return

    var gold_mat := view.call("_mat", "arena_gold_trim_quality_probe", Color(1.0, 0.78, 0.24), 0.16, true, false) as StandardMaterial3D
    if gold_mat == null or gold_mat.metallic < 0.72 or gold_mat.roughness > 0.28:
        push_error("Material quality matrix expected polished metal grade.")
        quit(1)
        return
    if str(gold_mat.get_meta("cinematic_material_family", "")) != "metal":
        push_error("Material quality matrix expected metal family metadata.")
        quit(1)
        return
    if _supports_property(gold_mat, "clearcoat_enabled") and (not bool(gold_mat.get("clearcoat_enabled")) or float(gold_mat.get("clearcoat")) < 0.54):
        push_error("Material quality matrix expected stronger clearcoat on metal materials.")
        quit(1)
        return
    if _supports_property(gold_mat, "anisotropy_enabled") and (not bool(gold_mat.get("anisotropy_enabled")) or float(gold_mat.get("anisotropy")) < 0.30):
        push_error("Material quality matrix expected anisotropic polish on metal materials.")
        quit(1)
        return

    var void_mat := view.call("_mat", "void_core_quality_probe", Color(0.72, 0.22, 1.0, 0.72), 0.92, true, true) as StandardMaterial3D
    if void_mat == null or not void_mat.emission_enabled or void_mat.roughness > 0.32:
        push_error("Material quality matrix expected emissive polished void material.")
        quit(1)
        return
    if str(void_mat.get_meta("cinematic_material_family", "")) != "energy":
        push_error("Material quality matrix expected energy family metadata.")
        quit(1)
        return
    if void_mat.emission_energy_multiplier > 0.05:
        push_error("Material quality matrix expected energy material emission to be readability scaled.")
        quit(1)
        return
    if _supports_property(void_mat, "rim_enabled") and (not bool(void_mat.get("rim_enabled")) or float(void_mat.get("rim")) > 0.38):
        push_error("Material quality matrix expected restrained rim light on void/energy materials.")
        quit(1)
        return

    var decal_mat := view.call("_vfx_decal_mat", "anti_glare_vfx_decal_probe", str(view.call("_vfx_decal_texture_path")), Color(1.0, 0.18, 0.44, 0.46), 1.24, Vector3.ONE, Vector3.ZERO) as StandardMaterial3D
    if decal_mat == null or decal_mat.blend_mode != BaseMaterial3D.BLEND_MODE_MIX or decal_mat.emission_energy_multiplier > 0.03:
        push_error("Material quality matrix expected VFX decals to use non-additive anti-glare blending.")
        quit(1)
        return

    var texture_path := str(view.call("_hextech_metal_texture_path"))
    var textured_metal := view.call("_texture_mat", "citadel_wall_metal_quality_probe", texture_path, Color(0.36, 0.38, 0.48), 0.04, true, false, Vector3.ONE, Vector3.ZERO) as StandardMaterial3D
    if textured_metal == null or textured_metal.metallic < 0.68 or textured_metal.roughness > 0.34:
        push_error("Material quality matrix expected textured metal to inherit quality grade.")
        quit(1)
        return

    var floor := view.get_node_or_null("ArenaPaintedFloor") as MeshInstance3D
    var floor_mat := floor.material_override as StandardMaterial3D if floor != null else null
    if floor_mat == null or floor_mat.roughness < 0.88:
        push_error("Material quality matrix expected matte painted floor material.")
        quit(1)
        return
    if str(floor_mat.get_meta("cinematic_material_family", "")) != "stone":
        push_error("Material quality matrix expected stone family metadata on floor.")
        quit(1)
        return

    print("SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=%.2f ambient=%.2f key=%.2f metal=%.2f rough=%.2f rim=%s family=%s/%s/%s" % [
        environment.glow_intensity,
        environment.ambient_light_energy,
        key_light.light_energy,
        gold_mat.metallic,
        floor_mat.roughness,
        str(_supports_property(void_mat, "rim_enabled") and bool(void_mat.get("rim_enabled"))),
        str(gold_mat.get_meta("cinematic_material_family", "")),
        str(void_mat.get_meta("cinematic_material_family", "")),
        str(floor_mat.get_meta("cinematic_material_family", ""))
    ])
    quit(0)

func _supports_property(object: Object, property_name: String) -> bool:
    for property in object.get_property_list():
        if str(property.get("name", "")) == property_name:
            return true
    return false
