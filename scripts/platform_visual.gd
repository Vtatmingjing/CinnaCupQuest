extends Node2D
class_name CinnaPlatformVisual

const PixelTileset := preload("res://scripts/pixel_tileset.gd")

var platform_size := Vector2(100, 24)
var platform_color := Color(0.50, 0.30, 0.16)
var style := "wood"

func setup(new_size: Vector2, new_color: Color, new_style := "wood") -> void:
    platform_size = new_size
    platform_color = new_color
    style = new_style
    queue_redraw()

func _draw() -> void:
    PixelTileset.draw_pixel_platform(self, platform_size, platform_color, style)
