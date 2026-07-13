extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const DeathBurstScript := preload("res://scripts/survivor_death_burst.gd")

const CASES := [
    {"kind": "voidling", "elite": false, "boss": false, "color": Color(0.72, 0.20, 1.0, 0.42), "min_meshes": 18},
    {"kind": "rift_crystal", "elite": true, "boss": false, "color": Color(0.44, 0.86, 1.0, 0.46), "min_meshes": 42},
    {"kind": "boss_velkoz", "elite": true, "boss": true, "color": Color(0.96, 0.38, 1.0, 0.52), "min_meshes": 48}
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
        var model: Node3D = view.call("_create_enemy_death_burst_model", kind, bool(case["elite"]), bool(case["boss"]), case["color"])
        if model == null:
            push_error("Death burst visual matrix could not create model for %s." % kind)
            quit(1)
            return
        model.name = "DeathBurstMatrix_" + kind
        view.add_child(model)
        await process_frame

        if not _require_node(model, "EnemyDeathBurstSignature", kind):
            return
        if not _require_node(model, "EnemyDeathBurstCore", kind):
            return
        if not _require_node(model, "EnemyDeathShardRig", kind):
            return
        if not _require_node(model, "EnemyDeathBurstVfxDecal", kind):
            return
        if not _require_node(model, "EnemyDeathAfterimageRig", kind):
            return
        if not _require_node(model, "EnemyDeathAfterimageRing", kind):
            return
        if not _require_node(model, "EnemyDeathSoulCore", kind):
            return
        if not _require_node(model, "EnemyDeathEmber0", kind):
            return
        if bool(case["elite"]) and not _require_node(model, "EnemyDeathRewardCrown", kind):
            return
        if bool(case["elite"]) and not _require_premium_reward_relic(model, kind, bool(case["boss"])):
            return
        if bool(case["boss"]) and not _require_node(model, "EnemyDeathBossEcho", kind):
            return
        if not bool(case["elite"]) and model.find_child("EnemyDeathRewardCrown", true, false) != null:
            push_error("Normal death burst %s should not carry reward crown." % kind)
            quit(1)
            return
        if not bool(case["elite"]) and model.find_child("EnemyDeathPremiumRewardRelic", true, false) != null:
            push_error("Normal death burst %s should not carry premium reward relic." % kind)
            quit(1)
            return

        var mesh_count := _count_mesh_instances(model)
        if mesh_count < int(case["min_meshes"]):
            push_error("Death burst %s looks underbuilt: %d meshes." % [kind, mesh_count])
            quit(1)
            return
        total_meshes += mesh_count
        model.queue_free()
        await process_frame

    var burst = DeathBurstScript.new()
    burst.setup(Vector2.ZERO, "rift_crystal", true, false, 136.0, Color(0.44, 0.86, 1.0, 0.46))
    root.add_child(burst)
    await process_frame
    if not burst.is_in_group("survivor_death_bursts"):
        push_error("Death burst scene did not enter survivor_death_bursts group.")
        quit(1)
        return
    burst.queue_free()

    print("SURVIVOR_DEATH_BURST_VISUAL_MATRIX_OK cases=%d meshes=%d" % [CASES.size(), total_meshes])
    quit(0)

func _require_node(model: Node3D, node_name: String, label: String) -> bool:
    if model.find_child(node_name, true, false) == null:
        push_error("Death burst visual matrix: %s missing %s." % [label, node_name])
        quit(1)
        return false
    return true

func _require_premium_reward_relic(model: Node3D, kind: String, boss: bool) -> bool:
    var root := model.find_child("EnemyDeathPremiumRewardRelic", true, false) as Node3D
    if root == null:
        push_error("Death burst visual matrix: %s missing EnemyDeathPremiumRewardRelic." % kind)
        quit(1)
        return false
    if str(root.get_meta("kind", "")) != kind:
        push_error("Death burst visual matrix: %s reward relic kind metadata mismatch." % kind)
        quit(1)
        return false
    var expected_grade := "boss_reward_relic" if boss else "elite_reward_relic"
    if str(root.get_meta("reward_grade", "")) != expected_grade:
        push_error("Death burst visual matrix: %s reward relic grade mismatch." % kind)
        quit(1)
        return false
    var expected_detail := _expected_reward_detail_name(kind, boss)
    if str(root.get_meta("detail_node", "")) != expected_detail:
        push_error("Death burst visual matrix: %s reward relic detail metadata mismatch." % kind)
        quit(1)
        return false
    for node_name in [
        "EnemyDeathRewardRelicSignal",
        "EnemyDeathRewardRelicCore",
        "EnemyDeathRewardRelicRing",
        "EnemyDeathRewardRelicPips",
        expected_detail
    ]:
        if not _require_node(root, node_name, kind):
            return false
    var relic_meshes := _count_mesh_instances(root)
    var min_relic_meshes := 18 if boss else 14
    if relic_meshes < min_relic_meshes:
        push_error("Death burst visual matrix: %s premium reward relic looks underbuilt: %d meshes." % [kind, relic_meshes])
        quit(1)
        return false
    return true

func _expected_reward_detail_name(kind: String, boss: bool) -> String:
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

func _count_mesh_instances(node: Node) -> int:
    var count := 1 if node is MeshInstance3D else 0
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count
