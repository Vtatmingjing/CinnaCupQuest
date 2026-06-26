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
    var outline := Color(0.04, 0.025, 0.015)
    draw_circle(Vector2.ZERO, 8.0, outline)
    draw_circle(Vector2.ZERO, 6.0, pickup_color)
    draw_rect(Rect2(-2, -11, 4, 22), pickup_color.lightened(0.35))
    draw_rect(Rect2(-11, -2, 22, 4), pickup_color.lightened(0.25))
