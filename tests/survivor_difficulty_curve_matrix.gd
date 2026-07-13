extends SceneTree

const MainScene := preload("res://scenes/Main.tscn")
const EnemyScript := preload("res://scripts/survivor_enemy.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _check_boss_timing():
        return
    if not await _check_start_pressure():
        return
    if not await _check_pressure_timers():
        return
    if not await _check_spawn_pressure_steps():
        return
    if not await _check_pressure_surge_director():
        return
    if not _check_enemy_late_wave_growth():
        return
    if not await _check_enemy_attack_pressure():
        return

    print("SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=90 timers=survival_pressure_v7 spawn_steps=challenge_v6 surge=tactical_mix_v1 enemy_growth=harder_v5 attacks=pressure_v2")
    quit(0)

func _make_run():
    var main = MainScene.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame
    main._start_new_run()
    await process_frame
    main.set("current_fate_options", [{"id": "signature_draft", "name": "test", "desc": "", "message": ""}])
    main._choose_fate(0)
    await process_frame
    return main

func _check_boss_timing() -> bool:
    var main = await _make_run()
    main.set("elapsed", 89.90)
    main.set("spawn_timer", 999.0)
    main.set("elite_timer", 999.0)
    main.set("boss_spawned", false)
    main._run_survivor_loop(0.20)
    await process_frame
    if not bool(main.get("boss_spawned")):
        return _fail(main, "boss did not spawn immediately after the 90 second mark.")
    main.queue_free()
    await process_frame
    return true

func _check_start_pressure() -> bool:
    var main = await _make_run()
    if float(main.get("elite_timer")) > 2.25:
        return _fail(main, "new run elite timer is still using the old forgiving reset value.")
    if float(main.get("pressure_surge_timer")) > 74.5:
        return _fail(main, "first pressure surge is still too late: %.2f." % float(main.get("pressure_surge_timer")))
    main.queue_free()
    await process_frame
    return true

func _check_pressure_timers() -> bool:
    var main = await _make_run()
    main.set("elapsed", 145.0)
    main.set("spawn_timer", -0.01)
    main.set("elite_timer", -0.01)
    main.set("boss_spawned", true)
    _clear_group("survivor_enemies")
    await process_frame
    main._run_survivor_loop(0.05)
    await process_frame
    if float(main.get("spawn_timer")) > 0.023:
        return _fail(main, "midgame spawn timer is still too forgiving.")
    if float(main.get("elite_timer")) > 0.83:
        return _fail(main, "midgame elite timer is still too forgiving.")
    main.queue_free()
    await process_frame
    return true

func _check_spawn_pressure_steps() -> bool:
    var main = await _make_run()
    main.set("enemy_pressure_bonus", 0)
    _clear_group("survivor_enemies")
    await process_frame
    await process_frame

    main.set("elapsed", 200.0)
    main.set("wave", 6)
    var before_mid := get_nodes_in_group("survivor_enemies").size()
    main._spawn_pack(before_mid)
    await process_frame
    var mid_count := get_nodes_in_group("survivor_enemies").size() - before_mid
    if mid_count < 60:
        return _fail(main, "midgame spawn pack is still too light.")
    _clear_group("survivor_enemies")
    await process_frame
    await process_frame

    main.set("elapsed", 421.0)
    main.set("wave", 13)
    var before_late := get_nodes_in_group("survivor_enemies").size()
    main._spawn_pack(before_late)
    await process_frame
    var late_count := get_nodes_in_group("survivor_enemies").size() - before_late
    if late_count < 92:
        return _fail(main, "late spawn pack is still too light: mid=%d late=%d." % [mid_count, late_count])
    if late_count <= mid_count:
        return _fail(main, "late spawn pack did not grow beyond the midgame pack: mid=%d late=%d." % [mid_count, late_count])
    main.queue_free()
    await process_frame
    return true

func _check_pressure_surge_director() -> bool:
    var main = await _make_run()
    main.set("elapsed", 150.0)
    main.set("wave", 6)
    main.set("spawn_timer", 999.0)
    main.set("elite_timer", 999.0)
    main.set("pressure_surge_timer", -0.01)
    _clear_group("survivor_enemies")
    await process_frame
    main._run_survivor_loop(0.05)
    await process_frame

    var enemies := get_nodes_in_group("survivor_enemies")
    var elite_count := 0
    for enemy in enemies:
        if is_instance_valid(enemy) and bool(enemy.get("elite")):
            elite_count += 1
    if elite_count < 2:
        return _fail(main, "pressure surge did not spawn a double elite squad.")
    if enemies.size() < 14:
        return _fail(main, "pressure surge escort pack is too small: %d." % enemies.size())
    var reset_timer := float(main.get("pressure_surge_timer"))
    if reset_timer > 22.5 or reset_timer < 14.9:
        return _fail(main, "pressure surge timer reset outside challenge bounds: %.2f." % reset_timer)
    var escort_kinds: Array = main.get("last_pressure_surge_escort_kinds")
    if escort_kinds.size() < 9:
        return _fail(main, "pressure surge did not record tactical escort kinds.")
    var role_counts: Dictionary = main.get("last_pressure_surge_role_counts")
    if int(role_counts.get("diver", 0)) <= 0:
        return _fail(main, "pressure surge missing diver pressure.")
    if int(role_counts.get("artillery", 0)) <= 0:
        return _fail(main, "pressure surge missing ranged artillery pressure.")
    if int(role_counts.get("tank", 0)) <= 0:
        return _fail(main, "pressure surge missing tank pressure.")
    var role_total := 0
    for role in role_counts.keys():
        if int(role_counts[role]) > 0:
            role_total += 1
    if role_total < 3:
        return _fail(main, "pressure surge did not mix enough combat roles.")
    if str(main.get("last_pressure_surge_profile")) == "":
        return _fail(main, "pressure surge did not record tactical profile.")

    main.queue_free()
    await process_frame
    return true

func _check_enemy_late_wave_growth() -> bool:
    var mid = EnemyScript.new()
    mid.setup("voidling", 8, false)
    var late = EnemyScript.new()
    late.setup("voidling", 12, false)
    if int(late.get("max_health")) < int(mid.get("max_health")) + 52:
        return _fail(null, "late wave enemy health did not grow.")
    if float(late.get("speed")) < float(mid.get("speed")) + 34.0:
        return _fail(null, "late wave enemy speed did not grow.")
    if int(late.get("damage")) <= int(mid.get("damage")):
        return _fail(null, "late wave enemy damage did not grow.")
    return true

func _check_enemy_attack_pressure() -> bool:
    var player := Node2D.new()
    player.global_position = Vector2(300, 0)
    root.add_child(player)

    var early = EnemyScript.new()
    early.setup("spitter", 3, false)
    early.global_position = Vector2.ZERO
    root.add_child(early)
    await process_frame
    seed(4201)
    early.set("attack_timer", 0.0)
    early.call("_try_attack", player)
    var early_timer := float(early.get("attack_timer"))

    var late = EnemyScript.new()
    late.setup("spitter", 12, false)
    late.global_position = Vector2.ZERO
    root.add_child(late)
    await process_frame
    seed(4201)
    late.set("attack_timer", 0.0)
    late.call("_try_attack", player)
    var late_timer := float(late.get("attack_timer"))

    early.queue_free()
    late.queue_free()
    player.queue_free()
    await process_frame

    if late_timer >= early_timer * 0.64:
        return _fail(null, "late wave ranged enemy attack cadence is still too slow: early=%.3f late=%.3f." % [early_timer, late_timer])
    return true

func _clear_group(group_name: String) -> void:
    for node in get_nodes_in_group(group_name):
        if is_instance_valid(node):
            node.free()

func _fail(main, message: String) -> bool:
    push_error("Difficulty curve matrix: " + message)
    if main != null and is_instance_valid(main):
        main.queue_free()
    quit(1)
    return false
