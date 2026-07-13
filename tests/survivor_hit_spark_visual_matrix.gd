extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const HitSparkScript := preload("res://scripts/survivor_hit_spark.gd")

const CASES := [
    {"label": "fishbones", "family": "explosive", "color": Color(1.0, 0.62, 0.18, 0.48), "priority": true, "min_meshes": 48},
    {"label": "senna_beam", "family": "magic", "color": Color(0.58, 1.0, 0.78, 0.48), "priority": false, "min_meshes": 42},
    {"label": "viktor_laser", "family": "magic", "color": Color(0.62, 0.92, 1.0, 0.48), "priority": false, "min_meshes": 42},
    {"label": "xayah_recall", "family": "physical", "color": Color(1.0, 0.34, 0.68, 0.48), "priority": false, "min_meshes": 38},
    {"label": "teemo_dart", "family": "poison", "color": Color(0.62, 1.0, 0.22, 0.48), "priority": false, "min_meshes": 38},
    {"label": "comet", "family": "magic", "color": Color(0.92, 0.72, 1.0, 0.48), "priority": true, "min_meshes": 48},
    {"label": "morde", "family": "void", "color": Color(0.58, 1.0, 0.58, 0.48), "priority": false, "min_meshes": 38}
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    var total_meshes := 0
    for case in CASES:
        var label := str(case["label"])
        var model: Node3D = view.call("_create_hit_spark_model", label, str(case["family"]), case["color"], bool(case["priority"]))
        if model == null:
            push_error("Hit spark visual matrix could not create model for %s." % label)
            quit(1)
            return
        model.name = "HitSparkMatrix_" + label
        view.add_child(model)
        await process_frame

        if not _require_node(model, "HitSparkImpactSignature", label):
            return
        if not _require_node(model, "HitSparkCore", label):
            return
        if not _require_node(model, "HitSparkSlashRig", label):
            return
        if not _require_node(model, "HitSparkFamilyGlyph", label):
            return
        if not _require_node(model, "HitSparkVfxDecal", label):
            return
        if not _require_node(model, "HitSparkDirectionalShock", label):
            return
        if not _require_node(model, "HitSparkMaterialShardRig", label):
            return
        if not _require_node(model, "HitSparkMaterialShard0", label):
            return
        if not _require_source_profile(model, label):
            return
        if not _require_resolution_profile(model, label):
            return
        if not _require_severity_profile(model, label):
            return

        var mesh_count := _count_mesh_instances(model)
        if mesh_count < int(case["min_meshes"]):
            push_error("Hit spark %s looks underbuilt: %d meshes." % [label, mesh_count])
            quit(1)
            return
        total_meshes += mesh_count
        model.queue_free()
        await process_frame

    var dense_model: Node3D = view.call("_create_hit_spark_model", "dense_void", "void", Color(0.58, 1.0, 0.58, 0.48), false, true)
    dense_model.name = "HitSparkMatrix_DenseLOD"
    view.add_child(dense_model)
    await process_frame
    if not bool(dense_model.get_meta("dense_lod", false)):
        push_error("Hit spark dense LOD model did not record dense_lod meta.")
        quit(1)
        return
    if not _require_node(dense_model, "HitSparkDirectionalShock", "dense_lod"):
        return
    if not _require_node(dense_model, "HitSparkMaterialShardRig", "dense_lod"):
        return
    if not _forbid_node(dense_model, "HitSparkSourceProfile", "dense_lod"):
        return
    if not _forbid_node(dense_model, "HitSparkResolutionProfile", "dense_lod"):
        return
    if not _forbid_node(dense_model, "HitSparkSeverityRig", "dense_lod"):
        return
    var dense_meshes := _count_mesh_instances(dense_model)
    if dense_meshes > 24:
        push_error("Hit spark dense LOD is too expensive: %d meshes." % dense_meshes)
        quit(1)
        return
    dense_model.queue_free()
    await process_frame

    var spark = HitSparkScript.new()
    spark.setup(Vector2.ZERO, "fishbones", "explosive", 8, 72.0, Color(1.0, 0.62, 0.18, 0.48), true)
    root.add_child(spark)
    await process_frame
    if not spark.is_in_group("survivor_hit_sparks"):
        push_error("Hit spark scene did not enter survivor_hit_sparks group.")
        quit(1)
        return
    spark.queue_free()

    if not _require_dynamic_severity(view):
        return

    print("SURVIVOR_HIT_SPARK_VISUAL_MATRIX_OK cases=%d meshes=%d" % [CASES.size(), total_meshes])
    quit(0)

func _require_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) == null:
        push_error("Hit spark visual matrix: %s missing %s." % [label, node_name])
        quit(1)
        return false
    return true

func _forbid_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) != null:
        push_error("Hit spark visual matrix: %s should not include heavy %s." % [label, node_name])
        quit(1)
        return false
    return true

func _require_resolution_profile(model: Node3D, label: String) -> bool:
    var root := model.find_child("HitSparkResolutionProfile", true, false) as Node3D
    if root == null:
        push_error("Hit spark visual matrix: %s missing HitSparkResolutionProfile." % label)
        quit(1)
        return false
    if str(root.get_meta("source_champion", "")) == "":
        push_error("Hit spark visual matrix: %s resolution profile missing source_champion metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("resolution_family", "")) == "":
        push_error("Hit spark visual matrix: %s resolution profile missing resolution_family metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("detail_node", "")) != _expected_resolution_detail(label):
        push_error("Hit spark visual matrix: %s resolution detail metadata mismatch." % label)
        quit(1)
        return false
    var required_children := [
        "HitSparkResolutionFloorSeal",
        "HitSparkResolutionCore",
        _expected_resolution_detail(label)
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Hit spark visual matrix: %s resolution profile missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Hit spark visual matrix: %s resolution child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 10:
        push_error("Hit spark visual matrix: %s resolution profile looks underbuilt." % label)
        quit(1)
        return false
    return true

func _require_source_profile(model: Node3D, label: String) -> bool:
    var root := model.find_child("HitSparkSourceProfile", true, false) as Node3D
    if root == null:
        push_error("Hit spark visual matrix: %s missing HitSparkSourceProfile." % label)
        quit(1)
        return false
    if str(root.get_meta("source_champion", "")) == "":
        push_error("Hit spark visual matrix: %s source profile missing source_champion metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("profile_family", "")) == "":
        push_error("Hit spark visual matrix: %s source profile missing profile_family metadata." % label)
        quit(1)
        return false
    if str(root.get_meta("profile_role", "")) == "":
        push_error("Hit spark visual matrix: %s source profile missing profile_role metadata." % label)
        quit(1)
        return false
    var expected_detail := _expected_source_profile_detail(label)
    var required_children := [
        "HitSparkSourceProfileRing",
        "HitSparkSourceClassMark",
        expected_detail
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Hit spark visual matrix: %s source profile missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Hit spark visual matrix: %s source profile child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if _count_mesh_instances(root) < 5:
        push_error("Hit spark visual matrix: %s source profile looks underbuilt." % label)
        quit(1)
        return false
    return true

func _require_severity_profile(model: Node3D, label: String) -> bool:
    var root := model.find_child("HitSparkSeverityRig", true, false) as Node3D
    if root == null:
        push_error("Hit spark visual matrix: %s missing HitSparkSeverityRig." % label)
        quit(1)
        return false
    if str(root.get_meta("combat_visual_channel", "")) != "hit_spark_severity":
        push_error("Hit spark visual matrix: %s severity rig channel mismatch." % label)
        quit(1)
        return false
    if str(root.get_meta("source_champion", "")) == "":
        push_error("Hit spark visual matrix: %s severity rig missing source champion metadata." % label)
        quit(1)
        return false
    var required_children := [
        "HitSparkSeverityMatte",
        "HitSparkSeverityMeter",
        "HitSparkSeverityPips",
        "HitSparkSeverityChampionStamp"
    ]
    for child_name in required_children:
        var child := root.get_node_or_null(child_name) as Node3D
        if child == null:
            push_error("Hit spark visual matrix: %s severity rig missing %s." % [label, child_name])
            quit(1)
            return false
        if _count_mesh_instances(child) <= 0:
            push_error("Hit spark visual matrix: %s severity child %s has no mesh content." % [label, child_name])
            quit(1)
            return false
    if not _require_low_glare_severity(root, label):
        return false
    return true

func _require_low_glare_severity(node: Node, label: String) -> bool:
    if node is MeshInstance3D:
        var mesh := node as MeshInstance3D
        var mat := mesh.material_override as StandardMaterial3D
        if mat != null:
            if mat.emission_enabled:
                push_error("Hit spark visual matrix: %s severity rig should not use emissive material on %s." % [label, node.name])
                quit(1)
                return false
            if mat.albedo_color.a > 0.34:
                push_error("Hit spark visual matrix: %s severity rig alpha too high on %s: %.2f." % [label, node.name, mat.albedo_color.a])
                quit(1)
                return false
    for child in node.get_children():
        if not _require_low_glare_severity(child, label):
            return false
    return true

func _require_dynamic_severity(view: Node) -> bool:
    var heavy_model: Node3D = view.call("_create_hit_spark_model", "fishbones", "explosive", Color(1.0, 0.62, 0.18, 0.48), true)
    view.add_child(heavy_model)
    view.call("_sync_hit_spark_severity_rig", heavy_model, 12, true, 0.42, 2.0, 404)
    var heavy := heavy_model.find_child("HitSparkSeverityRig", true, false) as Node3D
    if heavy == null or not bool(heavy.visible):
        push_error("Hit spark visual matrix: heavy hit severity rig did not become visible.")
        quit(1)
        return false
    if float(heavy.get_meta("severity", 0.0)) < 0.70:
        push_error("Hit spark visual matrix: heavy hit severity too low: %.2f." % float(heavy.get_meta("severity", 0.0)))
        quit(1)
        return false
    var heavy_meter := heavy.get_node_or_null("HitSparkSeverityMeter") as MeshInstance3D
    if heavy_meter == null or not bool(heavy_meter.visible) or heavy_meter.scale.x < 0.70:
        push_error("Hit spark visual matrix: heavy hit severity meter did not fill.")
        quit(1)
        return false
    var heavy_stamp := heavy.get_node_or_null("HitSparkSeverityChampionStamp") as Node3D
    if heavy_stamp == null or not bool(heavy_stamp.visible):
        push_error("Hit spark visual matrix: heavy hit severity champion stamp did not show.")
        quit(1)
        return false
    var heavy_pips := _count_visible_severity_pips(heavy)
    if heavy_pips < 3:
        push_error("Hit spark visual matrix: heavy hit severity pips too low: %d." % heavy_pips)
        quit(1)
        return false
    heavy_model.queue_free()

    var small_model: Node3D = view.call("_create_hit_spark_model", "xayah_recall", "physical", Color(1.0, 0.34, 0.68, 0.48), false)
    view.add_child(small_model)
    view.call("_sync_hit_spark_severity_rig", small_model, 2, false, 0.42, 2.0, 405)
    var small := small_model.find_child("HitSparkSeverityRig", true, false) as Node3D
    if small == null:
        push_error("Hit spark visual matrix: small hit missing severity rig.")
        quit(1)
        return false
    if bool(small.visible):
        push_error("Hit spark visual matrix: small hit severity rig should stay hidden.")
        quit(1)
        return false
    small_model.queue_free()
    return true

func _count_visible_severity_pips(root: Node3D) -> int:
    var pips := root.get_node_or_null("HitSparkSeverityPips") as Node3D
    if pips == null:
        return 0
    var count := 0
    for child in pips.get_children():
        if child is Node3D and bool((child as Node3D).visible):
            count += 1
    return count

func _expected_source_profile_detail(label: String) -> String:
    match label:
        "fishbones", "death_rocket":
            return "HitSparkProfileRocketBurst"
        "senna", "senna_beam", "senna_snare":
            return "HitSparkProfileSoulPierce"
        "samira", "samira_pistol", "powpow":
            return "HitSparkProfileDuelistCut"
        "viktor", "viktor_laser":
            return "HitSparkProfileHexcoreBurn"
        "xayah", "xayah_feather", "xayah_recall":
            return "HitSparkProfileFeatherPin"
        "teemo", "teemo_dart", "blind_dart":
            return "HitSparkProfilePoisonBloom"
        "aurelion_sol", "asol", "comet":
            return "HitSparkProfileStarCollapse"
        "morde", "mordekaiser":
            return "HitSparkProfileRealmCrush"
        _:
            return "HitSparkProfileGeneric"

func _expected_resolution_detail(label: String) -> String:
    match label:
        "fishbones", "death_rocket":
            return "HitSparkResolutionRocketCrater"
        "senna", "senna_beam", "senna_snare":
            return "HitSparkResolutionSoulPierceLine"
        "samira", "samira_pistol", "powpow":
            return "HitSparkResolutionDuelistCutMark"
        "viktor", "viktor_laser":
            return "HitSparkResolutionHexcoreBurnSeal"
        "xayah", "xayah_feather", "xayah_recall":
            return "HitSparkResolutionFeatherPinFan"
        "teemo", "teemo_dart", "blind_dart":
            return "HitSparkResolutionPoisonBloomPool"
        "aurelion_sol", "asol", "comet":
            return "HitSparkResolutionStarCollapseWell"
        "morde", "mordekaiser":
            return "HitSparkResolutionRealmCrushSeal"
        _:
            return "HitSparkResolutionGeneric"

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count
