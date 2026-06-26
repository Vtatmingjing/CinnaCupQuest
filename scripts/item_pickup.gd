extends Area2D
class_name CinnaItemPickup

signal picked(kind: String)
signal rejected(kind: String, price: int)

var kind := "mint"
var price := 0
var bob := 0.0
var is_shop_item := false

func _ready() -> void:
    collision_layer = 8
    collision_mask = 1
    body_entered.connect(_on_body_entered)
    var shape := CircleShape2D.new()
    shape.radius = 17
    var col := CollisionShape2D.new()
    col.shape = shape
    add_child(col)
    queue_redraw()

func setup(new_kind: String, new_price := 0) -> void:
    kind = new_kind
    price = new_price
    is_shop_item = price > 0
    queue_redraw()

func _process(delta: float) -> void:
    bob += delta
    queue_redraw()

func _on_body_entered(body: Node) -> void:
    if not body.has_method("add_item"):
        return
    if is_shop_item:
        if body.has_method("try_spend_gold") and body.try_spend_gold(price):
            body.add_item(kind)
            picked.emit(kind)
            queue_free()
        else:
            rejected.emit(kind, price)
    else:
        body.add_item(kind)
        picked.emit(kind)
        queue_free()

func _draw() -> void:
    var color := CinnaItemData.get_color(kind)
    var rarity_color := CinnaItemData.get_rarity_color(kind)
    var y := sin(bob * 4.0) * 3.0
    draw_rect(Rect2(-21, -21 + y, 42, 42), Color(0.03, 0.025, 0.02))
    draw_rect(Rect2(-18, -18 + y, 36, 36), rarity_color)
    draw_rect(Rect2(-14, -14 + y, 28, 28), color)
    draw_rect(Rect2(-7, -7 + y, 14, 14), color.lightened(0.35))
    draw_string(ThemeDB.fallback_font, Vector2(-5, 6 + y), CinnaItemData.get_icon(kind), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.05, 0.04, 0.035))
    if CinnaItemData.get_rarity(kind) == "legendary":
        draw_rect(Rect2(-25, -27 + y, 7, 7), Color(1.0, 0.92, 0.36))
        draw_rect(Rect2(18, -27 + y, 7, 7), Color(1.0, 0.92, 0.36))
        draw_rect(Rect2(-4, -31 + y, 8, 8), Color(1.0, 0.92, 0.36))
    if is_shop_item:
        draw_rect(Rect2(-29, 22 + y, 58, 18), Color(0.05, 0.04, 0.03, 0.92))
        draw_string(ThemeDB.fallback_font, Vector2(-24, 36 + y), "%dg" % price, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.86, 0.42))
    else:
        draw_string(ThemeDB.fallback_font, Vector2(-20, 36 + y), CinnaItemData.get_rarity_label(kind).substr(0, 4), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, rarity_color)
