extends RefCounted
class_name CinnaPixelTileset

static func palette(style: String, base: Color) -> Dictionary:
    var p := {
        "base": base,
        "top": base.lightened(0.24),
        "bottom": base.darkened(0.24),
        "line": base.darkened(0.38),
        "spark": Color(1.0, 0.94, 0.60, 0.55)
    }
    match style:
        "ice":
            p["base"] = Color(0.74, 0.92, 1.0)
            p["top"] = Color(0.95, 1.0, 1.0)
            p["bottom"] = Color(0.42, 0.76, 0.96)
            p["line"] = Color(0.30, 0.62, 0.88)
            p["spark"] = Color(1.0, 1.0, 1.0, 0.70)
        "mint":
            p["base"] = Color(0.34, 0.88, 0.34)
            p["top"] = Color(0.78, 1.0, 0.38)
            p["bottom"] = Color(0.12, 0.48, 0.24)
            p["line"] = Color(0.06, 0.34, 0.16)
            p["spark"] = Color(0.90, 1.0, 0.55, 0.68)
        "cinnamon":
            p["base"] = Color(0.70, 0.35, 0.14)
            p["top"] = Color(0.95, 0.56, 0.20)
            p["bottom"] = Color(0.36, 0.14, 0.06)
            p["line"] = Color(0.25, 0.09, 0.04)
            p["spark"] = Color(1.0, 0.62, 0.24, 0.52)
        "glass":
            p["base"] = Color(0.58, 0.86, 1.0)
            p["top"] = Color(0.96, 1.0, 1.0)
            p["bottom"] = Color(0.30, 0.62, 0.82)
            p["line"] = Color(0.20, 0.42, 0.58)
            p["spark"] = Color(1.0, 1.0, 1.0, 0.76)
    return p

static func draw_pixel_platform(canvas: CanvasItem, platform_size: Vector2, platform_color: Color, style: String) -> void:
    var w := platform_size.x
    var h := platform_size.y
    var pal := palette(style, platform_color)
    var outline := Color(0.055, 0.035, 0.025)
    var rect := Rect2(-w / 2, -h / 2, w, h)
    canvas.draw_rect(Rect2(rect.position.x - 3, rect.position.y - 3, w + 6, h + 6), outline)
    _draw_tiled_body(canvas, rect, style, pal)
    canvas.draw_rect(Rect2(rect.position.x, rect.position.y, w, 4), pal["top"])
    canvas.draw_rect(Rect2(rect.position.x, rect.position.y + h - 5, w, 5), pal["bottom"])
    _draw_style_details(canvas, rect, style, pal)

static func _draw_tiled_body(canvas: CanvasItem, rect: Rect2, style: String, pal: Dictionary) -> void:
    var tile := 16
    var columns := int(ceil(rect.size.x / float(tile)))
    var rows := int(ceil(rect.size.y / float(tile)))
    for cx in range(columns):
        for cy in range(rows):
            var x := rect.position.x + cx * tile
            var y := rect.position.y + cy * tile
            var tw := minf(tile, rect.position.x + rect.size.x - x)
            var th := minf(tile, rect.position.y + rect.size.y - y)
            var col: Color = pal["base"]
            if (cx + cy) % 2 == 1:
                col = col.darkened(0.035)
            canvas.draw_rect(Rect2(x, y, tw, th), col)
            if style == "wood" and cx % 3 == 0:
                canvas.draw_rect(Rect2(x + 3, y + 6, maxf(3, tw - 7), 2), pal["line"])
            elif style == "ice" and (cx + cy) % 3 == 0:
                canvas.draw_rect(Rect2(x + 3, y + 3, maxf(2, tw - 6), 2), pal["spark"])
            elif style == "glass" and (cx + cy) % 2 == 0:
                canvas.draw_rect(Rect2(x + 2, y + 2, maxf(2, tw - 10), 2), pal["spark"])
            elif style == "cinnamon" and cx % 2 == 0:
                canvas.draw_rect(Rect2(x + 3, y + 5, maxf(3, tw - 5), 3), pal["line"])

static func _draw_style_details(canvas: CanvasItem, rect: Rect2, style: String, pal: Dictionary) -> void:
    var w := rect.size.x
    var h := rect.size.y
    if style == "ice":
        for x in range(int(rect.position.x) + 10, int(rect.position.x + w), 34):
            canvas.draw_rect(Rect2(x, rect.position.y - 4, 15, 5), pal["spark"])
            canvas.draw_rect(Rect2(x + 8, rect.position.y + h - 10, 18, 3), pal["line"].lightened(0.25))
    elif style == "mint":
        for x in range(int(rect.position.x) + 8, int(rect.position.x + w), 28):
            canvas.draw_rect(Rect2(x, rect.position.y - 7, 16, 8), pal["top"])
            canvas.draw_rect(Rect2(x + 7, rect.position.y - 12, 8, 8), pal["base"].lightened(0.10))
            canvas.draw_rect(Rect2(x + 4, rect.position.y - 3, 12, 2), pal["line"])
    elif style == "cinnamon":
        for x in range(int(rect.position.x) + 6, int(rect.position.x + w), 32):
            canvas.draw_rect(Rect2(x, rect.position.y + 6, 22, 4), pal["line"])
            canvas.draw_rect(Rect2(x + 4, rect.position.y + h - 8, 18, 3), pal["top"])
    elif style == "glass":
        for x in range(int(rect.position.x) + 10, int(rect.position.x + w), 38):
            canvas.draw_rect(Rect2(x, rect.position.y + 5, 22, 4), pal["spark"])
            canvas.draw_rect(Rect2(x + 12, rect.position.y + 13, 16, 3), pal["bottom"].lightened(0.20))
    else:
        for x in range(int(rect.position.x) + 12, int(rect.position.x + w), 46):
            canvas.draw_rect(Rect2(x, rect.position.y + 5, 3, h - 10), pal["line"])
            canvas.draw_rect(Rect2(x + 10, rect.position.y + 10, 18, 3), pal["top"])
