extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")

const PULSE_CASES := [
    {"Label": "gold", "Color": Color(1.0, 0.76, 0.18, 0.34)},
    {"Label": "danger", "Color": Color(1.0, 0.10, 0.24, 0.34)},
    {"Label": "shield", "Color": Color(0.72, 0.95, 1.0, 0.30)},
    {"Label": "void", "Color": Color(0.74, 0.35, 1.0, 0.32)},
    {"Label": "poison", "Color": Color(0.52, 1.0, 0.22, 0.30)},
    {"Label": "star", "Color": Color(0.62, 0.34, 1.0, 0.32)},
    {"Label": "hextech", "Color": Color(0.60, 0.82, 0.94, 0.30)}
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    var total_meshes := 0
    for pulse_case in PULSE_CASES:
        var expected := str(pulse_case["Label"])
        var model: Node3D = view.call("_create_pulse_model", pulse_case["Color"])
        view.add_child(model)
        await process_frame
        var family := str(model.get_meta("pulse_family", ""))
        if family != expected:
            push_error("Pulse visual matrix expected family %s, got %s." % [expected, family])
            quit(1)
            return
        view.call("_sync_pulse_survival_pressure_silhouette", model, expected, 0.58, 12.0, 37)
        view.call("_sync_pulse_material_alpha", model, pulse_case["Color"], 0.82)
        if not _require_node(model, "PulseVfxDecal", expected):
            return
        if not _require_node(model, "PulseImpactSignature", expected):
            return
        if not _require_node(model, "PulseImpactShockRing", expected):
            return
        if not _require_node(model, "PulseImpactCore", expected):
            return
        if not _require_node(model, "PulseImpactGlyphTick0", expected):
            return
        if not _require_node(model, "PulseImpactFacetRig", expected):
            return
        if not _require_node(model, "PulseImpactFacet0", expected):
            return
        if _expects_pressure_silhouette(expected):
            if not _require_pulse_pressure_silhouette(model, expected):
                return
        elif model.find_child("PulseSurvivalPressureSilhouette", true, false) != null:
            push_error("Pulse visual matrix: %s should not use pressure silhouette." % expected)
            quit(1)
            return
        var mesh_count := _count_mesh_instances(model)
        if mesh_count < 24:
            push_error("Pulse visual matrix: %s looks underbuilt with %d meshes." % [expected, mesh_count])
            quit(1)
            return
        total_meshes += mesh_count
        model.queue_free()
        await process_frame

    print("SURVIVOR_PULSE_VISUAL_MATRIX_OK pulses=%d meshes=%d" % [PULSE_CASES.size(), total_meshes])
    quit(0)

func _require_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) == null:
        push_error("Pulse visual matrix: %s missing %s." % [label, node_name])
        quit(1)
        return false
    return true

func _require_pulse_pressure_silhouette(model: Node3D, label: String) -> bool:
    var silhouette := model.find_child("PulseSurvivalPressureSilhouette", true, false) as Node3D
    if silhouette == null:
        push_error("Pulse visual matrix: %s missing PulseSurvivalPressureSilhouette." % label)
        quit(1)
        return false
    if str(silhouette.get_meta("combat_visual_channel", "")) != "survival_pressure_readability":
        push_error("Pulse visual matrix: %s pressure silhouette has wrong combat channel." % label)
        quit(1)
        return false
    if str(silhouette.get_meta("material_grade", "")) != "low_glare_pulse_pressure_silhouette":
        push_error("Pulse visual matrix: %s pressure silhouette has wrong material grade." % label)
        quit(1)
        return false
    if not bool(silhouette.get_meta("pickup_confusion_guard", false)):
        push_error("Pulse visual matrix: %s pressure silhouette missing pickup confusion guard." % label)
        quit(1)
        return false
    if not bool(silhouette.get_meta("anti_glare", false)):
        push_error("Pulse visual matrix: %s pressure silhouette missing anti-glare flag." % label)
        quit(1)
        return false
    var expected_detail := _expected_pressure_detail_node(label)
    if expected_detail == "" or silhouette.find_child(expected_detail, true, false) == null:
        push_error("Pulse visual matrix: %s pressure silhouette missing detail node %s." % [label, expected_detail])
        quit(1)
        return false
    var mesh_count := _count_mesh_instances(silhouette)
    if mesh_count < 6 or mesh_count > 10:
        push_error("Pulse visual matrix: %s pressure silhouette mesh budget invalid: %d." % [label, mesh_count])
        quit(1)
        return false
    var stats := {"max_emission": 0.0, "max_alpha": 0.0, "bad_mesh": ""}
    _scan_pressure_materials(silhouette, stats)
    if float(stats["max_emission"]) > 0.036:
        push_error("Pulse visual matrix: %s pressure silhouette emission too high %.3f at %s." % [label, float(stats["max_emission"]), str(stats["bad_mesh"])])
        quit(1)
        return false
    if float(stats["max_alpha"]) > 0.18:
        push_error("Pulse visual matrix: %s pressure silhouette alpha too high %.3f at %s." % [label, float(stats["max_alpha"]), str(stats["bad_mesh"])])
        quit(1)
        return false
    return true

func _expects_pressure_silhouette(label: String) -> bool:
    return ["danger", "void", "hextech"].has(label)

func _expected_pressure_detail_node(label: String) -> String:
    match label:
        "danger":
            return "PulsePressureBossDangerCrown"
        "void":
            return "PulsePressureVoidEliteSpikes"
        "hextech":
            return "PulsePressureHextechEventCircuit"
        _:
            return ""

func _scan_pressure_materials(node: Node, stats: Dictionary) -> void:
    if node is MeshInstance3D:
        var mesh := node as MeshInstance3D
        var mat := mesh.material_override as StandardMaterial3D
        if mat != null:
            var emission := mat.emission_energy_multiplier if mat.emission_enabled else 0.0
            if emission > float(stats["max_emission"]):
                stats["max_emission"] = emission
                stats["bad_mesh"] = str(mesh.name)
            if mat.albedo_color.a > float(stats["max_alpha"]):
                stats["max_alpha"] = mat.albedo_color.a
                stats["bad_mesh"] = str(mesh.name)
    for child in node.get_children():
        _scan_pressure_materials(child, stats)

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count
