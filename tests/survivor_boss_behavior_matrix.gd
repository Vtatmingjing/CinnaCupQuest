extends SceneTree

const EnemyScript := preload("res://scripts/survivor_enemy.gd")

const CASES := [
    {
        "kind": "boss_cho",
        "profile": "devour_rupture",
        "role": "tank",
        "label": "Q",
        "min_count": 8,
        "min_radius": 10.0,
        "min_speed": 130.0,
        "zone_kind": "boss_cho_rupture",
        "zone_profile": "rupture_spikes"
    },
    {
        "kind": "boss_velkoz",
        "profile": "focus_laser",
        "role": "artillery",
        "label": "V",
        "min_count": 5,
        "min_radius": 7.0,
        "min_speed": 270.0,
        "zone_kind": "boss_velkoz_focus",
        "zone_profile": "focus_laser_sweep"
    },
    {
        "kind": "boss_reksai",
        "profile": "burrow_charge",
        "role": "diver",
        "label": "X",
        "min_count": 3,
        "min_radius": 8.0,
        "min_speed": 210.0,
        "zone_kind": "boss_reksai_tunnel",
        "zone_profile": "burrow_charge_lane"
    },
    {
        "kind": "boss_belveth",
        "profile": "royal_swarm",
        "role": "summoner",
        "label": "B",
        "min_count": 8,
        "min_radius": 7.0,
        "min_speed": 200.0,
        "zone_kind": "boss_belveth_swarm",
        "zone_profile": "royal_swarm_slash",
        "summon_kind": "skitter",
        "summon_count": 3,
        "special_profile": "royal_swarm_summon"
    }
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for data in CASES:
        if not await _check_boss(data):
            return

    print("SURVIVOR_BOSS_BEHAVIOR_MATRIX_OK bosses=%d" % CASES.size())
    quit(0)

func _check_boss(data: Dictionary) -> bool:
    await _cleanup()

    var player := Node2D.new()
    player.global_position = Vector2(360, 0)
    player.add_to_group("survivor_player")
    root.add_child(player)

    var enemy = EnemyScript.new()
    var kind := str(data["kind"])
    enemy.setup(kind, 12, true)
    enemy.global_position = Vector2.ZERO
    root.add_child(enemy)
    await process_frame

    var report := _watch_projectiles(enemy)
    var zones := _watch_zones(enemy)
    var spawn_report := _watch_spawns(enemy)
    enemy.set("attack_timer", 0.0)
    enemy.set("attack_cycle", 0)
    enemy.call("_try_attack", player)

    var expected_label := str(data["label"])
    if str(enemy.get("combat_role")) != str(data["role"]):
        return await _fail("boss %s expected role %s, got %s." % [kind, data["role"], str(enemy.get("combat_role"))])
    if str(enemy.get("last_attack_profile")) != str(data["profile"]):
        return await _fail("boss %s expected profile %s, got %s." % [kind, data["profile"], str(enemy.get("last_attack_profile"))])
    if int(report["count"]) < int(data["min_count"]):
        return await _fail("boss %s emitted too few projectiles: %d." % [kind, int(report["count"])])
    if int(report["labels"].get(expected_label, 0)) != int(report["count"]):
        return await _fail("boss %s did not keep its signature projectile label %s." % [kind, expected_label])
    if float(report["max_radius"]) < float(data["min_radius"]):
        return await _fail("boss %s projectile radius too small: %.2f." % [kind, float(report["max_radius"])])
    if float(report["max_speed"]) < float(data["min_speed"]):
        return await _fail("boss %s projectile speed too low: %.2f." % [kind, float(report["max_speed"])])

    if kind == "boss_reksai" and float(enemy.get("dash_timer")) < 2.90:
        return await _fail("boss_reksai did not enter burrow charge state.")
    if str(enemy.get("last_zone_profile")) != str(data["zone_profile"]):
        return await _fail("boss %s expected zone profile %s, got %s." % [kind, data["zone_profile"], str(enemy.get("last_zone_profile"))])
    if int(zones["count"]) < 1:
        return await _fail("boss %s did not emit a hazard zone." % kind)
    if str(zones["kind"]) != str(data["zone_kind"]):
        return await _fail("boss %s emitted zone %s instead of %s." % [kind, str(zones["kind"]), str(data["zone_kind"])])
    if float(zones["radius"]) < 100.0:
        return await _fail("boss %s hazard zone radius too small." % kind)

    if data.has("summon_kind"):
        enemy.set("summon_timer", 0.0)
        enemy.call("_try_special", player)
        if str(enemy.get("last_special_profile")) != str(data["special_profile"]):
            return await _fail("boss %s did not write summon profile." % kind)
        if str(spawn_report["kind"]) != str(data["summon_kind"]):
            return await _fail("boss %s summoned %s instead of %s." % [kind, str(spawn_report["kind"]), str(data["summon_kind"])])
        if int(spawn_report["count"]) < int(data["summon_count"]):
            return await _fail("boss %s summon count too low." % kind)

    await _cleanup()
    return true

func _watch_projectiles(enemy: Node) -> Dictionary:
    var report := {
        "count": 0,
        "labels": {},
        "max_radius": 0.0,
        "max_speed": 0.0
    }
    enemy.projectile_requested.connect(func(_pos: Vector2, vel: Vector2, _damage: int, radius: float, _color: Color, label: String) -> void:
        report["count"] = int(report["count"]) + 1
        report["max_radius"] = maxf(float(report["max_radius"]), radius)
        report["max_speed"] = maxf(float(report["max_speed"]), vel.length())
        var labels: Dictionary = report["labels"]
        labels[label] = int(labels.get(label, 0)) + 1
    )
    return report

func _watch_spawns(enemy: Node) -> Dictionary:
    var report := {"kind": "", "count": 0}
    enemy.spawn_requested.connect(func(_pos: Vector2, kind: String, count: int) -> void:
        report["kind"] = kind
        report["count"] = int(report["count"]) + count
    )
    return report

func _watch_zones(enemy: Node) -> Dictionary:
    var report := {"kind": "", "count": 0, "radius": 0.0, "damage": 0}
    enemy.zone_requested.connect(func(_pos: Vector2, kind: String, radius: float, damage: int, _duration: float, _tick_interval: float, _color: Color, _status: String, _power: int) -> void:
        report["kind"] = kind
        report["count"] = int(report["count"]) + 1
        report["radius"] = maxf(float(report["radius"]), radius)
        report["damage"] = maxi(int(report["damage"]), damage)
    )
    return report

func _cleanup() -> void:
    for group_name in ["survivor_enemies", "survivor_player"]:
        for node in get_nodes_in_group(group_name):
            if is_instance_valid(node):
                node.queue_free()
    await process_frame

func _fail(message: String) -> bool:
    push_error("Boss behavior matrix: " + message)
    await _cleanup()
    quit(1)
    return false
