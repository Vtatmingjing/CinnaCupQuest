extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const ProjectileScript := preload("res://scripts/survivor_projectile.gd")

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

const ENEMY_KINDS := [
    "voidling",
    "skitter",
    "spitter",
    "burrower",
    "carapace",
    "void_eye",
    "rift_crystal",
    "boss_cho",
    "boss_velkoz",
    "boss_reksai",
    "boss_belveth"
]

const PLAYER_PROJECTILES := [
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

const ENEMY_PROJECTILES := [
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

const MAX_GLOBAL_EMISSION := 0.108
const MAX_TRANSPARENT_ALPHA := 0.340
const MAX_ENEMY_PROJECTILE_EMISSION := 0.084
const MAX_PLAYER_PROJECTILE_EMISSION := 0.056
const MAX_PICKUP_TRANSPARENT_ALPHA := 0.105
const MAX_PICKUP_EMISSION := 0.039
const MIN_DANGER_GUARD_ALPHA := 0.245

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    var model_count := 0
    for champion_value in CHAMPIONS:
        var champion := str(champion_value)
        var champion_model: Node3D = view.call("_create_player_model", champion)
        champion_model.name = "GlareChampion_" + champion
        view.add_child(champion_model)
        model_count += 1

    for kind_value in ENEMY_KINDS:
        var kind := str(kind_value)
        var is_boss: bool = kind.begins_with("boss_")
        var enemy_model: Node3D = view.call("_create_enemy_model", kind, is_boss, is_boss, _enemy_color(kind), 44.0 if is_boss else 22.0, false, "frenzy" if not is_boss else "")
        enemy_model.name = "GlareEnemy_" + kind
        view.add_child(enemy_model)
        model_count += 1

    for label_value in PLAYER_PROJECTILES:
        var label := str(label_value)
        var player_projectile = _make_projectile(label, true)
        var player_model: Node3D = view.call("_create_projectile_model", player_projectile, false, false)
        player_model.name = "GlarePlayerProjectile_" + label
        view.add_child(player_model)
        model_count += 1

    for label_value in ENEMY_PROJECTILES:
        var label := str(label_value)
        var enemy_projectile = _make_projectile(label, false)
        var enemy_model: Node3D = view.call("_create_projectile_model", enemy_projectile, false, false)
        enemy_model.name = "GlareEnemyProjectile_" + label
        view.add_child(enemy_model)
        model_count += 1

    var pickup_cases := [
        {"kind": "xp", "amount": 4, "color": Color(0.42, 1.0, 0.45)},
        {"kind": "xp", "amount": 14, "color": Color(0.52, 0.95, 1.0)},
        {"kind": "gold", "amount": 16, "color": Color(1.0, 0.76, 0.20)},
        {"kind": "heal", "amount": 1, "color": Color(1.0, 0.28, 0.34)},
        {"kind": "shield", "amount": 2, "color": Color(0.64, 0.94, 1.0)}
    ]
    for case in pickup_cases:
        var pickup_model: Node3D = view.call("_create_pickup_model", str(case["kind"]), case["color"], int(case["amount"]), false)
        pickup_model.name = "GlarePickup_" + str(case["kind"]) + "_" + str(case["amount"])
        view.add_child(pickup_model)
        model_count += 1

    await process_frame

    var stats := {
        "max_emission": 0.0,
        "max_transparent_alpha": 0.0,
        "enemy_projectile_max_emission": 0.0,
        "player_projectile_max_emission": 0.0,
        "pickup_max_emission": 0.0,
        "pickup_max_transparent_alpha": 0.0,
        "pickup_alpha_source": "",
        "danger_guard_min_alpha": 1.0,
        "danger_guard_count": 0,
        "material_count": 0
    }
    _scan_materials(view, stats)

    if float(stats["max_emission"]) > MAX_GLOBAL_EMISSION:
        push_error("Glare budget matrix: global emission too high %.3f." % float(stats["max_emission"]))
        quit(1)
        return
    if float(stats["max_transparent_alpha"]) > MAX_TRANSPARENT_ALPHA:
        push_error("Glare budget matrix: transparent alpha too high %.3f." % float(stats["max_transparent_alpha"]))
        quit(1)
        return
    if float(stats["enemy_projectile_max_emission"]) > MAX_ENEMY_PROJECTILE_EMISSION:
        push_error("Glare budget matrix: enemy projectile emission too high %.3f." % float(stats["enemy_projectile_max_emission"]))
        quit(1)
        return
    if float(stats["player_projectile_max_emission"]) > MAX_PLAYER_PROJECTILE_EMISSION:
        push_error("Glare budget matrix: player projectile emission too high %.3f." % float(stats["player_projectile_max_emission"]))
        quit(1)
        return
    if float(stats["pickup_max_emission"]) > MAX_PICKUP_EMISSION:
        push_error("Glare budget matrix: pickup emission too high %.3f." % float(stats["pickup_max_emission"]))
        quit(1)
        return
    if float(stats["pickup_max_transparent_alpha"]) > MAX_PICKUP_TRANSPARENT_ALPHA:
        push_error("Glare budget matrix: pickup transparent alpha too high %.3f at %s." % [float(stats["pickup_max_transparent_alpha"]), str(stats["pickup_alpha_source"])])
        quit(1)
        return
    if int(stats["danger_guard_count"]) < ENEMY_PROJECTILES.size() * 3:
        push_error("Glare budget matrix: missing enemy projectile danger guard materials.")
        quit(1)
        return
    if float(stats["danger_guard_min_alpha"]) < MIN_DANGER_GUARD_ALPHA:
        push_error("Glare budget matrix: enemy projectile danger guard alpha too low %.3f." % float(stats["danger_guard_min_alpha"]))
        quit(1)
        return

    print("SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=%d models=%d emission=%.3f alpha=%.3f enemy=%.3f player=%.3f pickup=%.3f danger=%.3f profile=low_glare_v6" % [
        int(stats["material_count"]),
        model_count,
        float(stats["max_emission"]),
        float(stats["max_transparent_alpha"]),
        float(stats["enemy_projectile_max_emission"]),
        float(stats["player_projectile_max_emission"]),
        float(stats["pickup_max_emission"]),
        float(stats["danger_guard_min_alpha"])
    ])
    quit(0)

func _make_projectile(label: String, from_player: bool):
    var projectile = ProjectileScript.new()
    var color := Color(0.34, 0.84, 1.0) if from_player else Color(1.0, 0.12, 0.34)
    projectile.setup(Vector2.ZERO, Vector2.RIGHT * 220.0, 3, 8.0, color, label, 1, 1.2, from_player)
    return projectile

func _scan_materials(node: Node, stats: Dictionary) -> void:
    if node is MeshInstance3D:
        var mesh := node as MeshInstance3D
        var mat := mesh.material_override as StandardMaterial3D
        if mat != null:
            stats["material_count"] = int(stats["material_count"]) + 1
            var emission := mat.emission_energy_multiplier if mat.emission_enabled else 0.0
            stats["max_emission"] = maxf(float(stats["max_emission"]), emission)
            if mat.albedo_color.a < 0.99:
                stats["max_transparent_alpha"] = maxf(float(stats["max_transparent_alpha"]), mat.albedo_color.a)
            if _node_path_contains(mesh, "GlareEnemyProjectile") or _node_path_contains(mesh, "EnemyProjectile"):
                stats["enemy_projectile_max_emission"] = maxf(float(stats["enemy_projectile_max_emission"]), emission)
            if _node_path_contains(mesh, "GlarePlayerProjectile") or _node_path_contains(mesh, "PlayerProjectile"):
                stats["player_projectile_max_emission"] = maxf(float(stats["player_projectile_max_emission"]), emission)
            if _node_path_contains(mesh, "GlarePickup") and not _is_grounding_shadow_mesh(mesh):
                stats["pickup_max_emission"] = maxf(float(stats["pickup_max_emission"]), emission)
                if mat.albedo_color.a < 0.99:
                    if mat.albedo_color.a > float(stats["pickup_max_transparent_alpha"]):
                        stats["pickup_max_transparent_alpha"] = mat.albedo_color.a
                        stats["pickup_alpha_source"] = _node_path_string(mesh)
            if _is_danger_guard_mesh(mesh):
                stats["danger_guard_count"] = int(stats["danger_guard_count"]) + 1
                stats["danger_guard_min_alpha"] = minf(float(stats["danger_guard_min_alpha"]), mat.albedo_color.a)
    for child in node.get_children():
        _scan_materials(child, stats)

func _is_danger_guard_mesh(node: Node) -> bool:
    return (
        str(node.name) == "EnemyProjectileDangerBackplate"
        or str(node.name) == "EnemyProjectileDangerNeedle"
        or str(node.name) == "EnemyProjectileOcclusionMatte"
        or str(node.name) == "EnemyProjectileThreatOutline"
    )

func _is_grounding_shadow_mesh(node: Node) -> bool:
    return str(node.get_meta("combat_visual_channel", "")) == "grounding_shadow"

func _node_path_contains(node: Node, token: String) -> bool:
    var current := node
    while current != null:
        if str(current.name).contains(token):
            return true
        current = current.get_parent()
    return false

func _node_path_string(node: Node) -> String:
    var parts: Array[String] = []
    var current := node
    while current != null:
        parts.push_front(str(current.name))
        current = current.get_parent()
    return "/".join(parts)

func _enemy_color(kind: String) -> Color:
    match kind:
        "spitter":
            return Color(0.44, 0.78, 0.34)
        "burrower", "boss_reksai":
            return Color(0.86, 0.38, 0.22)
        "carapace", "boss_cho":
            return Color(0.44, 0.22, 0.74)
        "void_eye", "boss_velkoz":
            return Color(0.82, 0.24, 1.0)
        "rift_crystal":
            return Color(0.30, 0.86, 1.0)
        "boss_belveth":
            return Color(0.70, 0.18, 1.0)
        _:
            return Color(0.58, 0.28, 0.86)
