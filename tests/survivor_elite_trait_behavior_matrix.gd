extends SceneTree

const EnemyScript := preload("res://scripts/survivor_enemy.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _check_frenzy_rush():
        return
    if not await _check_bulwark_breakpoint():
        return
    if not await _check_splitter_bloom():
        return
    if not await _check_treasure_flee():
        return

    print("SURVIVOR_ELITE_TRAIT_BEHAVIOR_MATRIX_OK traits=4")
    quit(0)

func _check_frenzy_rush() -> bool:
    var ctx := await _make_enemy("voidling", "frenzy", Vector2(280, 0))
    var enemy: Node = ctx["enemy"]
    var player: Node2D = ctx["player"]
    var shots := _watch_projectiles(enemy)
    enemy.set("elite_trait_cooldown", 0.0)
    enemy.set("pounce_timer", 0.0)
    enemy.set("dash_timer", 0.0)
    enemy.call("_try_elite_trait_special", player)
    var dash_dir: Vector2 = enemy.get("dash_dir")
    if float(enemy.get("dash_timer")) < 0.50:
        return await _fail("frenzy elite did not start a rush dash.")
    if dash_dir.length() < 0.80:
        return await _fail("frenzy elite did not store a rush direction.")
    if float(enemy.get("attack_timer")) > 0.19:
        return await _fail("frenzy elite did not compress its attack windup.")
    if str(enemy.get("last_elite_trait_profile")) != "frenzy_rush_claw":
        return await _fail("frenzy elite did not write its combat profile.")
    if int(shots["F"]) < 3:
        return await _fail("frenzy elite did not emit rush claw projectiles.")
    await _cleanup()
    return true

func _check_bulwark_breakpoint() -> bool:
    var ctx := await _make_enemy("voidling", "bulwark", Vector2(260, 0))
    var enemy: Node = ctx["enemy"]
    var shots := _watch_projectiles(enemy)
    enemy.set("max_health", 80)
    enemy.set("health", 80)
    enemy.set("bulwark_guard", 1)
    enemy.set("bulwark_break_timer", 0.0)
    enemy.call("take_damage", 6, Vector2.ZERO, false)
    var guarded_loss := 80 - int(enemy.get("health"))
    if int(enemy.get("bulwark_guard")) != 0:
        return await _fail("bulwark elite guard did not spend on hit.")
    if float(enemy.get("bulwark_break_timer")) <= 0.0:
        return await _fail("bulwark elite did not open a break window.")
    if guarded_loss > 4:
        return await _fail("bulwark elite guard did not reduce incoming damage.")
    if str(enemy.get("last_elite_trait_profile")) != "bulwark_break":
        return await _fail("bulwark elite did not write its break profile.")
    if int(shots["U"]) < 5:
        return await _fail("bulwark elite did not emit shield break projectiles.")
    var before_break := int(enemy.get("health"))
    enemy.call("take_damage", 2, Vector2.ZERO, false)
    var break_loss := before_break - int(enemy.get("health"))
    if break_loss < 3:
        return await _fail("bulwark elite break window did not increase damage taken.")
    await _cleanup()
    return true

func _check_splitter_bloom() -> bool:
    var ctx := await _make_enemy("skitter", "splitter", Vector2(300, 0))
    var enemy: Node = ctx["enemy"]
    var player: Node2D = ctx["player"]
    var shots := _watch_projectiles(enemy)
    var spawn_report := {"kind": "", "count": 0}
    enemy.spawn_requested.connect(func(_pos: Vector2, kind: String, count: int) -> void:
        spawn_report["kind"] = kind
        spawn_report["count"] = int(spawn_report["count"]) + count
    )
    enemy.set("elite_trait_cooldown", 0.0)
    enemy.set("splitter_spawned", false)
    enemy.set("health", int(float(enemy.get("max_health")) * 0.50))
    enemy.call("_try_elite_trait_special", player)
    if not bool(enemy.get("splitter_spawned")):
        return await _fail("splitter elite did not mark its bloom as spent.")
    if str(spawn_report["kind"]) != "voidling" or int(spawn_report["count"]) != 2:
        return await _fail("splitter elite did not request its half-health voidling bloom.")
    if str(enemy.get("last_elite_trait_profile")) != "splitter_bloom_voidling":
        return await _fail("splitter elite did not write its bloom profile.")
    if int(shots["S"]) < 5:
        return await _fail("splitter elite did not emit bloom projectiles.")
    await _cleanup()
    return true

func _check_treasure_flee() -> bool:
    var ctx := await _make_enemy("spitter", "treasure", Vector2(180, 0))
    var enemy: Node = ctx["enemy"]
    var player: Node2D = ctx["player"]
    var shots := _watch_projectiles(enemy)
    enemy.global_position = Vector2.ZERO
    enemy.set("elite_trait_cooldown", 0.0)
    enemy.set("treasure_flee_timer", 0.0)
    enemy.call("_try_elite_trait_special", player)
    if float(enemy.get("treasure_flee_timer")) <= 0.0:
        return await _fail("treasure elite did not enter flee state near the player.")
    if str(enemy.get("last_elite_trait_profile")) != "treasure_flee_decoy":
        return await _fail("treasure elite did not write its flee profile.")
    if int(shots["T"]) < 3:
        return await _fail("treasure elite did not emit decoy projectiles.")
    var before_dist: float = enemy.global_position.distance_to(player.global_position)
    enemy.call("_move_toward_player", 0.20, player)
    var after_dist: float = enemy.global_position.distance_to(player.global_position)
    if after_dist <= before_dist:
        return await _fail("treasure elite flee movement did not increase distance from player.")
    await _cleanup()
    return true

func _make_enemy(kind: String, elite_trait_id: String, player_pos: Vector2) -> Dictionary:
    await _cleanup()
    var player := Node2D.new()
    player.global_position = player_pos
    player.add_to_group("survivor_player")
    root.add_child(player)

    var enemy = EnemyScript.new()
    enemy.setup(kind, 10, false)
    enemy.elite = true
    enemy.configure_elite_trait(elite_trait_id)
    enemy.global_position = Vector2.ZERO
    root.add_child(enemy)
    await process_frame
    return {"enemy": enemy, "player": player}

func _watch_projectiles(enemy: Node) -> Dictionary:
    var report := {"F": 0, "U": 0, "S": 0, "T": 0}
    enemy.projectile_requested.connect(func(_pos: Vector2, _vel: Vector2, _damage: int, _radius: float, _color: Color, label: String) -> void:
        if report.has(label):
            report[label] = int(report[label]) + 1
    )
    return report

func _cleanup() -> void:
    for group_name in ["survivor_enemies", "survivor_player"]:
        for node in get_nodes_in_group(group_name):
            if is_instance_valid(node):
                node.queue_free()
    await process_frame

func _fail(message: String) -> bool:
    push_error("Elite trait behavior matrix: " + message)
    await _cleanup()
    quit(1)
    return false
