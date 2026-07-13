extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const SpawnRiftScript := preload("res://scripts/survivor_spawn_rift.gd")

const CASES := [
    {"kind": "voidling", "elite": false, "boss": false, "color": Color(0.70, 0.20, 1.0, 0.40), "min_meshes": 10},
    {"kind": "rift_crystal", "elite": true, "boss": false, "color": Color(0.34, 0.86, 1.0, 0.42), "min_meshes": 20},
    {"kind": "boss_velkoz", "elite": true, "boss": true, "color": Color(0.94, 0.34, 1.0, 0.52), "min_meshes": 25}
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    var total_meshes := 0
    for case in CASES:
        var kind := str(case["kind"])
        var model: Node3D = view.call("_create_enemy_spawn_rift_model", kind, bool(case["elite"]), bool(case["boss"]), case["color"])
        if model == null:
            push_error("Spawn rift visual matrix could not create model for %s." % kind)
            quit(1)
            return
        model.name = "SpawnRiftMatrix_" + kind
        view.add_child(model)
        await process_frame

        if not _require_node(model, "EnemySpawnRiftSignature", kind):
            return
        if not _require_node(model, "EnemySpawnRiftPortalDecal", kind):
            return
        if not _require_node(model, "EnemySpawnRiftSpeciesMark", kind):
            return
        if not _require_node(model, "EnemySpawnRiftPillarRig", kind):
            return
        if bool(case["elite"]) and not _require_node(model, "EnemySpawnRiftPriorityCrown", kind):
            return
        if not bool(case["elite"]) and model.find_child("EnemySpawnRiftPriorityCrown", true, false) != null:
            push_error("Normal spawn rift %s should not carry priority crown." % kind)
            quit(1)
            return

        var mesh_count := _count_mesh_instances(model)
        if mesh_count < int(case["min_meshes"]):
            push_error("Spawn rift %s looks underbuilt: %d meshes." % [kind, mesh_count])
            quit(1)
            return
        total_meshes += mesh_count
        model.queue_free()
        await process_frame

    var rift = SpawnRiftScript.new()
    rift.setup(Vector2.ZERO, "rift_crystal", true, false, 136.0, Color(0.34, 0.86, 1.0, 0.42))
    root.add_child(rift)
    await process_frame
    if not rift.is_in_group("survivor_spawn_rifts"):
        push_error("Spawn rift scene did not enter survivor_spawn_rifts group.")
        quit(1)
        return
    rift.queue_free()

    print("SURVIVOR_SPAWN_RIFT_VISUAL_MATRIX_OK cases=%d meshes=%d" % [CASES.size(), total_meshes])
    quit(0)

func _require_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) == null:
        push_error("Spawn rift visual matrix: %s missing %s." % [label, node_name])
        quit(1)
        return false
    return true

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count
