extends SceneTree

const PlayerScript := preload("res://scripts/survivor_player.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _check_ballistic_storm():
        return
    if not await _check_arcane_engine():
        return
    if not await _check_juggernaut_core():
        return
    if not await _check_soul_network():
        return

    print("SURVIVOR_ROUTE_SYNERGY_MATRIX_OK routes=4")
    quit(0)

func _make_player(champion_id: String):
    var player = PlayerScript.new()
    root.add_child(player)
    await process_frame
    player.reset_run(champion_id)
    await process_frame
    return player

func _check_ballistic_storm() -> bool:
    var player = await _make_player("jinx")
    var base_pierce := int(player.get("pierce_bonus"))
    var base_lime := int(player.get("lime_level"))
    player.add_upgrade("physical_hex")
    player.add_upgrade("physical_hex")
    player.add_upgrade("marksman_hex")
    var recipes: Dictionary = player.get("recipe_synergies")
    if not recipes.has("route_ballistic_storm"):
        return _fail(player, "physical/marksman route synergy did not unlock.")
    if int(player.get("pierce_bonus")) <= base_pierce or int(player.get("lime_level")) <= base_lime:
        return _fail(player, "ballistic storm did not improve pierce and side shots.")
    player.queue_free()
    await process_frame
    return true

func _check_arcane_engine() -> bool:
    var player = await _make_player("aurelion_sol")
    var base_skill := int(player.get("skill_power"))
    var base_orbits := int(player.get("orbit_count"))
    player.add_upgrade("magic_hex")
    player.add_upgrade("magic_hex")
    player.add_upgrade("summon_hex")
    var recipes: Dictionary = player.get("recipe_synergies")
    if not recipes.has("route_arcane_engine"):
        return _fail(player, "magic/summon route synergy did not unlock.")
    if int(player.get("skill_power")) <= base_skill + 4 or int(player.get("orbit_count")) <= base_orbits:
        return _fail(player, "arcane engine did not improve skill power and orbits.")
    player.queue_free()
    await process_frame
    return true

func _check_juggernaut_core() -> bool:
    var player = await _make_player("mordekaiser")
    var base_health := int(player.get("max_health"))
    var base_aura := int(player.get("aura_level"))
    player.add_upgrade("tank_hex")
    player.add_upgrade("tank_hex")
    player.add_upgrade("melee_hex")
    var recipes: Dictionary = player.get("recipe_synergies")
    if not recipes.has("route_juggernaut_core"):
        return _fail(player, "tank/melee route synergy did not unlock.")
    if int(player.get("max_health")) <= base_health + 4 or int(player.get("aura_level")) <= base_aura:
        return _fail(player, "juggernaut core did not improve health and aura.")
    player.queue_free()
    await process_frame
    return true

func _check_soul_network() -> bool:
    var player = await _make_player("senna")
    var base_magnet := float(player.get("magnet_radius"))
    player.add_upgrade("support_hex")
    player.add_upgrade("support_hex")
    player.add_upgrade("summon_hex")
    var recipes: Dictionary = player.get("recipe_synergies")
    if not recipes.has("route_soul_network"):
        return _fail(player, "support/summon route synergy did not unlock.")
    if float(player.get("magnet_radius")) <= base_magnet or int(player.get("shield")) < 7:
        return _fail(player, "soul network did not improve magnet radius and shielding.")
    player.queue_free()
    await process_frame
    return true

func _fail(player, message: String) -> bool:
    push_error("Route synergy matrix: " + message)
    if player != null and is_instance_valid(player):
        player.queue_free()
    quit(1)
    return false
