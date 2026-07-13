extends Node2D
class_name CinnaSurvivorBackground

const VIEW := Rect2(0, 0, 1280, 720)
const ARENA := Rect2(-1520, -900, 3040, 1800)

func _ready() -> void:
    set_process(false)
    queue_redraw()

func _draw() -> void:
    _draw_void_backdrop()
    _draw_bridge()
    _draw_hextech_lanes()
    _draw_void_cracks()
    _draw_landmarks()
    _draw_bounds()

func _draw_void_backdrop() -> void:
    draw_rect(ARENA.grow(480.0), Color(0.025, 0.018, 0.040))
    for i in range(54):
        var x := ARENA.position.x - 300.0 + float((i * 173) % 3600)
        var y := ARENA.position.y - 260.0 + float((i * 97) % 2320)
        var c := Color(0.25, 0.12, 0.42, 0.12 + float(i % 4) * 0.025)
        draw_circle(Vector2(x, y), 2.0 + float(i % 3), c)

func _draw_bridge() -> void:
    var bridge := ARENA.grow(-130.0)
    draw_rect(bridge, Color(0.075, 0.085, 0.125))
    draw_rect(Rect2(bridge.position.x, bridge.position.y, bridge.size.x, 44.0), Color(0.13, 0.15, 0.21))
    draw_rect(Rect2(bridge.position.x, bridge.end.y - 44.0, bridge.size.x, 44.0), Color(0.13, 0.15, 0.21))
    draw_rect(Rect2(bridge.position.x, bridge.position.y, 46.0, bridge.size.y), Color(0.11, 0.13, 0.19))
    draw_rect(Rect2(bridge.end.x - 46.0, bridge.position.y, 46.0, bridge.size.y), Color(0.11, 0.13, 0.19))
    for x in range(int(bridge.position.x), int(bridge.end.x), 152):
        draw_line(Vector2(x, bridge.position.y + 44.0), Vector2(x + 74.0, bridge.end.y - 44.0), Color(0.22, 0.24, 0.32, 0.24), 2.0)
    for y in range(int(bridge.position.y) + 90, int(bridge.end.y), 128):
        draw_line(Vector2(bridge.position.x + 46.0, y), Vector2(bridge.end.x - 46.0, y - 18.0), Color(0.21, 0.23, 0.31, 0.26), 2.0)

func _draw_hextech_lanes() -> void:
    draw_line(Vector2(ARENA.position.x + 210.0, 0.0), Vector2(ARENA.end.x - 210.0, 0.0), Color(0.34, 0.56, 1.0, 0.20), 8.0)
    draw_line(Vector2(0.0, ARENA.position.y + 160.0), Vector2(0.0, ARENA.end.y - 160.0), Color(0.34, 0.56, 1.0, 0.13), 5.0)
    for i in range(9):
        var x := -960.0 + i * 240.0
        draw_circle(Vector2(x, 0.0), 18.0, Color(0.40, 0.72, 1.0, 0.12))
        draw_arc(Vector2(x, 0.0), 32.0, 0.0, TAU, 20, Color(0.62, 0.82, 1.0, 0.16), 2.0)

func _draw_void_cracks() -> void:
    var crack_color := Color(0.56, 0.20, 0.86, 0.34)
    var core_color := Color(0.86, 0.34, 1.0, 0.24)
    var crack_points := [
        Vector2(-1180, -520), Vector2(-990, -410), Vector2(-860, -500), Vector2(-690, -430),
        Vector2(720, 390), Vector2(860, 260), Vector2(1050, 320), Vector2(1240, 210),
        Vector2(-340, 620), Vector2(-180, 500), Vector2(-40, 560), Vector2(130, 450)
    ]
    for i in range(0, crack_points.size(), 4):
        for j in range(3):
            draw_line(crack_points[i + j], crack_points[i + j + 1], crack_color, 8.0)
            draw_line(crack_points[i + j], crack_points[i + j + 1], core_color, 3.0)
    for p in [Vector2(-1010, -430), Vector2(1000, 285), Vector2(-120, 548)]:
        draw_circle(p, 54.0, Color(0.35, 0.08, 0.50, 0.28))
        draw_arc(p, 76.0, 0.0, TAU, 32, Color(0.74, 0.28, 1.0, 0.28), 3.0)

func _draw_landmarks() -> void:
    _draw_tower(Vector2(-1320, -650), Color(0.30, 0.50, 0.86))
    _draw_tower(Vector2(1320, 650), Color(0.60, 0.22, 0.86))
    for p in [Vector2(-1260, 620), Vector2(1260, -620), Vector2(-540, -710), Vector2(540, 710)]:
        draw_rect(Rect2(p.x - 42.0, p.y - 22.0, 84.0, 44.0), Color(0.12, 0.15, 0.21))
        draw_rect(Rect2(p.x - 30.0, p.y - 10.0, 60.0, 20.0), Color(0.44, 0.58, 0.88, 0.24))

func _draw_tower(pos: Vector2, color: Color) -> void:
    draw_rect(Rect2(pos.x - 38.0, pos.y - 70.0, 76.0, 132.0), Color(0.06, 0.07, 0.10))
    draw_rect(Rect2(pos.x - 28.0, pos.y - 54.0, 56.0, 100.0), Color(0.12, 0.14, 0.18))
    draw_circle(pos + Vector2(0.0, -70.0), 34.0, Color(color.r, color.g, color.b, 0.28))
    draw_arc(pos + Vector2(0.0, -70.0), 44.0, 0.0, TAU, 28, Color(color.r, color.g, color.b, 0.48), 4.0)

func _draw_bounds() -> void:
    draw_rect(ARENA, Color(0.58, 0.38, 1.0, 0.18), false, 5.0)
    draw_rect(ARENA.grow(-16.0), Color(0.40, 0.70, 1.0, 0.08), false, 2.0)
