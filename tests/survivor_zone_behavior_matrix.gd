extends SceneTree

const ZoneScript := preload("res://scripts/survivor_zone.gd")
const EnemyScript := preload("res://scripts/survivor_enemy.gd")

class MockPlayer:
    extends Node2D
    var hit_radius := 15.0
    var damage_taken := 0

    func _ready() -> void:
        add_to_group("survivor_player")

    func take_damage(amount: int, _source_pos := Vector2.ZERO) -> void:
        damage_taken += amount

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _check_hostile_zone_targets_player():
        return
    if not await _check_player_zone_targets_enemies():
        return

    print("SURVIVOR_ZONE_BEHAVIOR_MATRIX_OK modes=2")
    quit(0)

func _check_hostile_zone_targets_player() -> bool:
    await _cleanup()
    var player := MockPlayer.new()
    player.global_position = Vector2.ZERO
    root.add_child(player)

    var enemy = EnemyScript.new()
    enemy.setup("voidling", 8, false)
    enemy.global_position = Vector2(84, 0)
    root.add_child(enemy)
    await process_frame

    var enemy_health_before := int(enemy.get("health"))
    var zone = ZoneScript.new()
    zone.setup(Vector2.ZERO, "boss_velkoz_focus", 128.0, 2, 2.0, 0.25, Color(1.0, 0.32, 1.0, 0.28), "", 2, false)
    root.add_child(zone)
    await process_frame
    zone.set("tick_timer", 0.0)
    zone.call("_process", 0.05)

    if int(player.damage_taken) <= 0:
        return await _fail("hostile boss zone did not damage the player.")
    if int(enemy.get("health")) != enemy_health_before:
        return await _fail("hostile boss zone damaged enemies.")
    await _cleanup()
    return true

func _check_player_zone_targets_enemies() -> bool:
    await _cleanup()
    var player := MockPlayer.new()
    player.global_position = Vector2(320, 0)
    root.add_child(player)

    var enemy = EnemyScript.new()
    enemy.setup("voidling", 8, false)
    enemy.global_position = Vector2.ZERO
    root.add_child(enemy)
    await process_frame

    var enemy_health_before := int(enemy.get("health"))
    var zone = ZoneScript.new()
    zone.setup(Vector2.ZERO, "viktor_gravity", 128.0, 2, 2.0, 0.25, Color(0.58, 0.82, 1.0, 0.26), "slow", 2, true)
    root.add_child(zone)
    await process_frame
    zone.set("tick_timer", 0.0)
    zone.call("_process", 0.05)

    if int(enemy.get("health")) >= enemy_health_before:
        return await _fail("player zone did not damage enemies.")
    if int(player.damage_taken) != 0:
        return await _fail("player zone damaged the player.")
    await _cleanup()
    return true

func _cleanup() -> void:
    for group_name in ["survivor_player", "survivor_enemies", "survivor_zones"]:
        for node in get_nodes_in_group(group_name):
            if is_instance_valid(node):
                node.queue_free()
    await process_frame

func _fail(message: String) -> bool:
    push_error("Zone behavior matrix: " + message)
    await _cleanup()
    quit(1)
    return false
