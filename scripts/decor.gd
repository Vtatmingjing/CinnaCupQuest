extends Node2D
class_name CinnaDecor

var kind := "chest"
var label := ""
var bob := 0.0

func setup(new_kind: String, new_label := "") -> void:
    kind = new_kind
    label = new_label
    queue_redraw()

func _process(delta: float) -> void:
    bob += delta
    queue_redraw()

func _draw() -> void:
    var y := sin(bob * 2.8) * 2.0
    var outline := Color(0.04, 0.03, 0.025)
    match kind:
        "shopkeeper":
            draw_rect(Rect2(-30, -52 + y, 60, 68), outline)
            draw_rect(Rect2(-23, -45 + y, 46, 56), Color(0.66, 0.37, 0.15))
            draw_rect(Rect2(-18, -62 + y, 36, 18), Color(0.20, 0.08, 0.05))
            draw_rect(Rect2(-14, -27 + y, 8, 8), outline)
            draw_rect(Rect2(7, -27 + y, 8, 8), outline)
            draw_rect(Rect2(-11, -10 + y, 22, 5), Color(1.0, 0.78, 0.27))
            draw_string(ThemeDB.fallback_font, Vector2(-39, -76 + y), "SHOP", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.90, 0.56))
        "event":
            draw_rect(Rect2(-34, -46 + y, 68, 58), outline)
            draw_rect(Rect2(-28, -40 + y, 56, 46), Color(0.28, 0.74, 0.34))
            draw_rect(Rect2(-18, -60 + y, 36, 18), Color(0.78, 1.0, 0.24))
            draw_rect(Rect2(-18, -20 + y, 8, 8), outline)
            draw_rect(Rect2(10, -20 + y, 8, 8), outline)
            draw_string(ThemeDB.fallback_font, Vector2(-42, -76 + y), "EVENT", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.84, 1.0, 0.54))
        "beacon":
            draw_rect(Rect2(-18, -70, 36, 86), outline)
            draw_rect(Rect2(-12, -62, 24, 74), Color(0.78, 0.36, 0.13))
            draw_rect(Rect2(-30, -82, 60, 18), outline)
            draw_rect(Rect2(-23, -78, 46, 10), Color(1.0, 0.78, 0.20))
            draw_rect(Rect2(-6, -101, 12, 24), Color(1.0, 0.28, 0.10))
            draw_rect(Rect2(-3, -112, 6, 12), Color(1.0, 0.90, 0.34))
            draw_string(ThemeDB.fallback_font, Vector2(-54, -124), "AROMA BEACON", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.90, 0.56))
        "chest":
            draw_rect(Rect2(-34, -32 + y, 68, 46), outline)
            draw_rect(Rect2(-28, -26 + y, 56, 34), Color(0.76, 0.40, 0.16))
            draw_rect(Rect2(-28, -15 + y, 56, 7), Color(1.0, 0.76, 0.20))
            draw_rect(Rect2(-5, -18 + y, 10, 13), Color(0.12, 0.07, 0.04))
    if label != "":
        draw_string(ThemeDB.fallback_font, Vector2(-52, 28 + y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.94, 0.70))
