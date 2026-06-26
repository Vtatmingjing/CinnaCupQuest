extends Node2D
class_name CinnaBackground

var region_id := "bar_top"

func _ready() -> void:
    set_process(false)

func set_region(new_region_id: String) -> void:
    if region_id == new_region_id:
        return
    region_id = new_region_id
    queue_redraw()

func _draw() -> void:
    if region_id == "bottle_shelf":
        _draw_bottle_shelf()
    elif region_id == "aroma_shrine":
        _draw_aroma_shrine()
    else:
        _draw_bar_top()

func _draw_bar_top() -> void:
    draw_rect(Rect2(0, 0, 540, 960), Color(0.08, 0.055, 0.05))
    draw_rect(Rect2(0, 96, 540, 570), Color(0.15, 0.095, 0.075))
    draw_rect(Rect2(0, 660, 540, 300), Color(0.44, 0.25, 0.12))
    draw_rect(Rect2(0, 838, 540, 122), Color(0.55, 0.34, 0.18))
    _draw_bottles(false)
    _draw_mug_landmark(Vector2(0, 0), Color(0.91, 0.68, 0.18, 0.36))
    _draw_torch_tower()
    _draw_sparkles(Color(1.0, 0.92, 0.55, 0.75))

func _draw_bottle_shelf() -> void:
    draw_rect(Rect2(0, 0, 540, 960), Color(0.045, 0.035, 0.065))
    draw_rect(Rect2(0, 86, 540, 632), Color(0.10, 0.055, 0.12))
    draw_rect(Rect2(0, 170, 540, 34), Color(0.26, 0.12, 0.075))
    draw_rect(Rect2(0, 388, 540, 34), Color(0.26, 0.12, 0.075))
    draw_rect(Rect2(0, 642, 540, 34), Color(0.26, 0.12, 0.075))
    draw_rect(Rect2(0, 820, 540, 140), Color(0.32, 0.16, 0.10))
    for i in range(7):
        var x := 24 + i * 74
        var h := 260 + (i % 3) * 45
        draw_rect(Rect2(x, 150 + (i % 2) * 22, 42, h), Color(0.07 + 0.03 * (i % 3), 0.10, 0.12 + 0.04 * (i % 2)))
        draw_rect(Rect2(x + 10, 110 + (i % 2) * 22, 22, 48), Color(0.08, 0.08, 0.10))
        draw_rect(Rect2(x + 5, 250 + (i % 4) * 45, 32, 58), Color(0.72, 0.42, 0.95, 0.36))
    _draw_mug_landmark(Vector2(-28, 42), Color(0.62, 0.30, 0.90, 0.30))
    _draw_sparkles(Color(0.90, 0.58, 1.0, 0.76))

func _draw_aroma_shrine() -> void:
    draw_rect(Rect2(0, 0, 540, 960), Color(0.09, 0.035, 0.025))
    draw_rect(Rect2(0, 120, 540, 560), Color(0.18, 0.060, 0.040))
    draw_rect(Rect2(0, 680, 540, 280), Color(0.32, 0.13, 0.07))
    draw_rect(Rect2(68, 168, 404, 460), Color(0.88, 0.50, 0.12, 0.12))
    _draw_mug_landmark(Vector2(10, 0), Color(1.0, 0.42, 0.12, 0.34))
    draw_rect(Rect2(248, 246, 44, 190), Color(1.0, 0.22, 0.08, 0.28))
    _draw_torch_tower()
    _draw_sparkles(Color(1.0, 0.46, 0.20, 0.85))

func _draw_bottles(_dark := false) -> void:
    draw_rect(Rect2(28, 120, 58, 400), Color(0.11, 0.16, 0.11))
    draw_rect(Rect2(42, 82, 30, 52), Color(0.11, 0.16, 0.11))
    draw_rect(Rect2(34, 238, 48, 96), Color(0.88, 0.70, 0.38))
    draw_rect(Rect2(410, 86, 82, 476), Color(0.18, 0.12, 0.06))
    draw_rect(Rect2(430, 38, 42, 58), Color(0.18, 0.12, 0.06))
    draw_rect(Rect2(418, 290, 66, 92), Color(0.95, 0.73, 0.22))
    draw_rect(Rect2(190, 100, 76, 470), Color(0.18, 0.05, 0.07))
    draw_rect(Rect2(206, 52, 42, 60), Color(0.18, 0.05, 0.07))

func _draw_mug_landmark(offset: Vector2, liquid: Color) -> void:
    draw_rect(Rect2(92 + offset.x, 430 + offset.y, 250, 250), Color(0.68, 0.91, 0.93, 0.17))
    draw_rect(Rect2(100 + offset.x, 450 + offset.y, 234, 36), Color(0.88, 1.0, 1.0, 0.22))
    draw_rect(Rect2(112 + offset.x, 502 + offset.y, 208, 120), liquid)
    draw_arc(Vector2(342 + offset.x, 542 + offset.y), 52, -1.45, 1.45, 16, Color(0.70, 0.95, 1.0, 0.25), 12)
    draw_rect(Rect2(146 + offset.x, 550 + offset.y, 42, 26), Color(0.52, 0.93, 0.43, 0.55))
    draw_rect(Rect2(222 + offset.x, 512 + offset.y, 54, 32), Color(0.78, 0.96, 1.0, 0.42))

func _draw_torch_tower() -> void:
    draw_rect(Rect2(444, 548, 42, 190), Color(0.06, 0.06, 0.07))
    draw_rect(Rect2(450, 622, 30, 112), Color(0.96, 0.10, 0.06, 0.60))
    draw_rect(Rect2(434, 738, 64, 16), Color(0.04, 0.04, 0.04))

func _draw_sparkles(sparkle_color: Color) -> void:
    for p in [Vector2(70, 585), Vector2(126, 390), Vector2(304, 445), Vector2(386, 610), Vector2(472, 472), Vector2(220, 278)]:
        draw_rect(Rect2(p.x, p.y, 5, 5), sparkle_color)
        draw_rect(Rect2(p.x - 5, p.y + 5, 5, 5), sparkle_color.darkened(0.25))
