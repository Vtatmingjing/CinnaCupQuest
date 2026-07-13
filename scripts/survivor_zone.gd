extends Node2D
class_name CinnaSurvivorZone

var kind := "zone"
var radius := 80.0
var trigger_radius := 34.0
var damage := 1
var life := 4.0
var max_life := 4.0
var tick_interval := 0.55
var tick_timer := 0.0
var zone_color := Color(0.62, 0.36, 1.0, 0.25)
var status := ""
var status_power := 1
var triggered := true
var active_life := 3.0
var pull_strength := 0.0
var wobble := 0.0
var from_player := true

func setup(
        start_pos: Vector2,
        zone_kind: String,
        zone_radius: float,
        zone_damage: int,
        duration: float,
        interval: float,
        color: Color,
        zone_status := "",
        power := 1,
        player_owned := true
) -> void:
    position = start_pos
    kind = zone_kind
    radius = zone_radius
    damage = zone_damage
    life = duration
    max_life = duration
    tick_interval = maxf(0.12, interval)
    tick_timer = 0.0
    zone_color = color
    status = zone_status
    status_power = maxi(1, power)
    from_player = player_owned
    triggered = kind != "teemo_mushroom"
    active_life = minf(3.8, duration)
    match kind:
        "teemo_mushroom":
            trigger_radius = 42.0
            radius = zone_radius
            active_life = 3.4 + float(power) * 0.35
        "viktor_gravity":
            pull_strength = 72.0 + float(power) * 10.0
        "asol_singularity":
            pull_strength = 126.0 + float(power) * 18.0
        "morde_realm":
            pull_strength = 46.0
        "boss_cho_rupture":
            pull_strength = 0.0
        "boss_velkoz_focus":
            pull_strength = 0.0
        "boss_reksai_tunnel":
            pull_strength = 0.0
        "boss_belveth_swarm":
            pull_strength = 0.0
        _:
            pass

func _ready() -> void:
    add_to_group("survivor_zones")
    queue_redraw()

func _process(delta: float) -> void:
    life -= delta
    wobble += delta
    if life <= 0.0:
        queue_free()
        return

    if from_player and kind == "teemo_mushroom" and not triggered:
        _check_mushroom_trigger()
        queue_redraw()
        return

    if from_player and pull_strength > 0.0:
        _pull_enemies(delta)

    tick_timer -= delta
    if tick_timer <= 0.0:
        tick_timer = tick_interval
        if from_player:
            _tick_enemy_damage()
        else:
            _tick_player_damage()
    queue_redraw()

func _check_mushroom_trigger() -> void:
    for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        var enemy_radius := float(enemy.get("hit_radius"))
        if global_position.distance_to(enemy.global_position) <= trigger_radius + enemy_radius:
            triggered = true
            life = active_life
            max_life = active_life
            tick_timer = 0.0
            return

func _tick_enemy_damage() -> void:
    for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        var enemy_radius := float(enemy.get("hit_radius"))
        if global_position.distance_to(enemy.global_position) > radius + enemy_radius:
            continue
        if enemy.has_method("take_damage"):
            enemy.take_damage(damage, global_position, false)
        _apply_status(enemy)

func _tick_player_damage() -> void:
    for player in get_tree().get_nodes_in_group("survivor_player"):
        if not is_instance_valid(player):
            continue
        var player_radius := 16.0
        var player_hit_radius = player.get("hit_radius")
        if player_hit_radius != null:
            player_radius = float(player_hit_radius)
        if global_position.distance_to(player.global_position) > radius + player_radius:
            continue
        if player.has_method("take_damage"):
            player.take_damage(damage, global_position)

func _pull_enemies(delta: float) -> void:
    for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        var enemy_node := enemy as Node2D
        if enemy_node == null:
            continue
        var offset: Vector2 = global_position - enemy_node.global_position
        var distance := offset.length()
        if distance <= 1.0 or distance > radius * 1.15:
            continue
        var strength := pull_strength * (1.0 - clampf(distance / maxf(1.0, radius * 1.15), 0.0, 1.0))
        enemy_node.global_position += offset.normalized() * strength * delta

func _apply_status(enemy: Node) -> void:
    match status:
        "poison":
            if enemy.has_method("apply_poison"):
                enemy.apply_poison(3.2 + float(status_power) * 0.25, maxi(1, ceili(float(damage) * 0.45)))
            if enemy.has_method("apply_slow"):
                enemy.apply_slow(1.1, 0.68)
        "slow":
            if enemy.has_method("apply_slow"):
                enemy.apply_slow(1.2 + float(status_power) * 0.18, 0.52)
        "root":
            if enemy.has_method("apply_root"):
                enemy.apply_root(0.42 + float(status_power) * 0.06)
        "weaken":
            if enemy.has_method("apply_weaken"):
                enemy.apply_weaken(1.8 + float(status_power) * 0.2)
        _:
            pass

func _draw() -> void:
    var t := 1.0 - life / maxf(0.01, max_life)
    if kind == "teemo_mushroom" and not triggered:
        draw_circle(Vector2.ZERO, 16.0 + sin(wobble * 4.0) * 1.2, Color(0.58, 1.0, 0.22, 0.18))
        draw_circle(Vector2.ZERO, 8.0, Color(0.82, 0.24, 0.18, 0.95))
        draw_circle(Vector2(0, 7), 5.0, Color(0.86, 0.76, 0.52, 0.95))
        return

    var color := zone_color
    color.a *= 0.72 * (1.0 - t * 0.35)
    draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, color.a * 0.20))
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 72, color, 4.0)
    draw_arc(Vector2.ZERO, radius * 0.62, 0.0, TAU, 56, color.lightened(0.28), 2.0)
    if kind == "asol_singularity":
        for i in range(5):
            var angle := wobble * (1.6 + i * 0.12) + TAU * float(i) / 5.0
            draw_line(Vector2.ZERO, Vector2(cos(angle), sin(angle)) * radius * 0.82, color.lightened(0.35), 2.0)
