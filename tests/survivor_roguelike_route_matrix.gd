extends SceneTree

const MainScene := preload("res://scenes/Main.tscn")
const CORE_FATE_IDS := ["prismatic_party", "elite_contract", "market_day", "swarm_alarm", "starfall", "yordle_mischief"]
const EXTRA_FATE_IDS := ["signature_draft", "black_market", "unstable_forge", "void_rivalry"]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _check_fate_roll_mix():
        return
    if not await _check_signature_draft():
        return
    if not await _check_black_market():
        return
    if not await _check_unstable_forge():
        return
    if not await _check_void_rivalry():
        return

    print("SURVIVOR_ROGUELIKE_ROUTE_MATRIX_OK fates=4 roll_mix=forced")
    quit(0)

func _make_run(fate_id: String, champion_id: String):
    var main = MainScene.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame
    main.set("selected_character_id", champion_id)
    main._start_new_run()
    await process_frame
    main.set("current_fate_options", [{"id": fate_id, "name": fate_id, "desc": "", "message": ""}])
    main._choose_fate(0)
    await process_frame
    return main

func _check_fate_roll_mix() -> bool:
    var main = MainScene.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame
    var saw_extra := false
    var saw_core := false
    for attempt in range(12):
        var options: Array = main._roll_fate_options()
        if options.size() != 3:
            return _fail(main, "fate roll did not return exactly three choices.")
        var extra_count := 0
        var core_count := 0
        var seen := {}
        for option in options:
            var id := str(option.get("id", ""))
            if seen.has(id):
                return _fail(main, "fate roll returned duplicate choices.")
            seen[id] = true
            if EXTRA_FATE_IDS.has(id):
                extra_count += 1
            if CORE_FATE_IDS.has(id):
                core_count += 1
        saw_extra = saw_extra or extra_count > 0
        saw_core = saw_core or core_count > 0
        if extra_count <= 0 or core_count <= 0:
            return _fail(main, "fate roll did not force both extra and core choices.")
    if not saw_extra or not saw_core:
        return _fail(main, "fate roll mix was never observed.")
    main.queue_free()
    await process_frame
    return true

func _check_signature_draft() -> bool:
    var main = await _make_run("signature_draft", "jinx")
    var player = main.get("player")
    var hero_ids: Array = player.get_hero_upgrade_ids()
    var inventory: Dictionary = player.get("inventory")
    var has_hero_upgrade := false
    for id in hero_ids:
        if inventory.has(str(id)):
            has_hero_upgrade = true
            break
    if not has_hero_upgrade:
        return _fail(main, "Signature draft did not grant a hero upgrade.")

    var options: Array = main._roll_upgrade_options()
    var hero_option_count := 0
    for option in options:
        if hero_ids.has(str(option.get("id", ""))):
            hero_option_count += 1
    if hero_option_count < 2:
        return _fail(main, "Signature draft did not bias level-up choices toward hero routes.")
    main.queue_free()
    await process_frame
    return true

func _check_black_market() -> bool:
    var main = await _make_run("black_market", "jinx")
    var options: Array = main._roll_shop_options()
    if options.size() < 18:
        return _fail(main, "Black market shop did not expose the full item shelf.")
    var first: Dictionary = options[0]
    if int(first.get("route_score", 0)) < 3:
        return _fail(main, "Black market did not push route items to the top shelf.")
    if int(first.get("price", 0)) >= int(first.get("cost", 0)):
        return _fail(main, "Black market route item was not discounted.")
    if float(main.get("shop_time_shift")) > -40.0:
        return _fail(main, "Black market shop timing was not moved earlier.")
    main.queue_free()
    await process_frame
    return true

func _check_unstable_forge() -> bool:
    var main = await _make_run("unstable_forge", "viktor")
    if str(main._hextech_tier_for_index(0)) != "gold":
        return _fail(main, "Unstable forge did not upgrade the first hextech tier.")
    if int(main.get("enemy_pressure_bonus")) < 1 or int(main.get("reward_bonus")) < 1:
        return _fail(main, "Unstable forge did not trade higher pressure for higher reward.")
    main.queue_free()
    await process_frame
    return true

func _check_void_rivalry() -> bool:
    var main = await _make_run("void_rivalry", "mordekaiser")
    if float(main.get("elite_timer")) > 16.1:
        return _fail(main, "Void rivalry did not make the first elite arrive early.")
    if int(main.get("reward_bonus")) < 2:
        return _fail(main, "Void rivalry reward bonus is too low.")
    if str(main._elite_trait("skitter")) != "treasure":
        return _fail(main, "Void rivalry first elite was not forced to treasure.")
    main.queue_free()
    await process_frame
    return true

func _fail(main, message: String) -> bool:
    push_error("Roguelike route matrix: " + message)
    if main != null and is_instance_valid(main):
        main.queue_free()
    quit(1)
    return false
