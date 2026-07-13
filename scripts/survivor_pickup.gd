extends Node2D
class_name CinnaSurvivorPickup

signal collected(kind: String, amount: int, position: Vector2)

var kind := "xp"
var amount := 1
var pickup_color := Color(0.42, 1.0, 0.45)
var magnet_speed := 420.0
var bob_timer := 0.0
var base_y := 0.0

func setup(start_pos: Vector2, new_kind: String, new_amount: int, new_color: Color) -> void:
    position = start_pos
    base_y = start_pos.y
    kind = new_kind
    amount = new_amount
    pickup_color = new_color

func _ready() -> void:
    add_to_group("survivor_pickups")
    base_y = position.y
    queue_redraw()

func _process(delta: float) -> void:
    bob_timer += delta
    var player := _find_player()
    if player != null:
        var dist := global_position.distance_to(player.global_position)
        var magnet_radius := 78.0
        var collect_radius := 18.0
        var player_magnet_radius = player.get("magnet_radius")
        if player_magnet_radius != null:
            magnet_radius = float(player_magnet_radius)
        var player_pickup_radius = player.get("pickup_radius")
        if player_pickup_radius != null:
            collect_radius = float(player_pickup_radius)
        if dist <= magnet_radius:
            global_position = global_position.move_toward(player.global_position, magnet_speed * delta * (1.0 + (magnet_radius - dist) / magnet_radius))
        else:
            position.y = base_y + sin(bob_timer * 5.0) * 3.0
        if global_position.distance_to(player.global_position) <= collect_radius:
            collected.emit(kind, amount, global_position)
            queue_free()
            return
    queue_redraw()

func _find_player() -> Node2D:
    var players := get_tree().get_nodes_in_group("survivor_player")
    if players.size() == 0:
        return null
    return players[0]

func _draw() -> void:
    match kind:
        "gold":
            _draw_coin()
        "heal":
            _draw_heal()
        "shield":
            _draw_shield()
        _:
            _draw_xp_crystal()

func _draw_xp_crystal() -> void:
    var outline := Color(0.02, 0.06, 0.035)
    var h := 10.0 + minf(4.0, float(amount))
    var w := 7.0 + minf(3.0, float(amount) * 0.5)
    draw_polygon([Vector2(0, -h - 2), Vector2(w + 3, 0), Vector2(0, h + 2), Vector2(-w - 3, 0)], [outline])
    draw_polygon([Vector2(0, -h), Vector2(w, 0), Vector2(0, h), Vector2(-w, 0)], [pickup_color])
    draw_line(Vector2(0, -h + 2), Vector2(0, h - 2), pickup_color.lightened(0.45), 2.0)
    draw_line(Vector2(-w + 2, 0), Vector2(w - 2, 0), Color(0.90, 1.0, 0.88, 0.65), 1.5)

func _draw_coin() -> void:
    var outline := Color(0.08, 0.045, 0.00)
    draw_circle(Vector2.ZERO, 9.0, outline)
    draw_circle(Vector2.ZERO, 7.0, Color(1.0, 0.76, 0.18))
    draw_arc(Vector2.ZERO, 4.8, -0.8, 2.2, 14, Color(1.0, 0.94, 0.42), 2.0)
    draw_rect(Rect2(-1.5, -6.0, 3.0, 12.0), Color(0.74, 0.42, 0.04, 0.55))

func _draw_heal() -> void:
    var outline := Color(0.12, 0.00, 0.02)
    draw_circle(Vector2(-4.0, -3.0), 6.0, outline)
    draw_circle(Vector2(4.0, -3.0), 6.0, outline)
    draw_polygon([Vector2(-10, 0), Vector2(10, 0), Vector2(0, 12)], [outline])
    draw_circle(Vector2(-4.0, -3.0), 4.5, Color(1.0, 0.28, 0.34))
    draw_circle(Vector2(4.0, -3.0), 4.5, Color(1.0, 0.28, 0.34))
    draw_polygon([Vector2(-8, 0), Vector2(8, 0), Vector2(0, 9)], [Color(1.0, 0.28, 0.34)])
    draw_rect(Rect2(-1.5, -7.0, 3.0, 12.0), Color(1.0, 0.86, 0.90))
    draw_rect(Rect2(-6.0, -2.5, 12.0, 3.0), Color(1.0, 0.86, 0.90))

func _draw_shield() -> void:
    var outline := Color(0.02, 0.06, 0.08)
    draw_polygon([Vector2(0, -12), Vector2(10, -7), Vector2(8, 6), Vector2(0, 13), Vector2(-8, 6), Vector2(-10, -7)], [outline])
    draw_polygon([Vector2(0, -9), Vector2(7, -5), Vector2(6, 5), Vector2(0, 10), Vector2(-6, 5), Vector2(-7, -5)], [Color(0.72, 0.95, 1.0)])
    draw_line(Vector2(0, -8), Vector2(0, 9), Color(1.0, 1.0, 1.0, 0.55), 2.0)
