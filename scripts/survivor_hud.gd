extends CanvasLayer
class_name CinnaSurvivorHUD

signal choice_selected(index: int)
signal start_pressed
signal shop_closed
signal mute_pressed
signal return_select_pressed

const XP_WIDTH := 650.0
const CHOICE_ICON_ATLAS_TEXTURE_PATH := "res://art/textures/hextech_void_vfx_decal_atlas_v1.png"
const SHOP_ITEM_ICON_ATLAS_TEXTURE_PATH := "res://art/textures/hextech_shop_item_icon_atlas_v1.png"
const CHAMPION_PORTRAIT_TEXTURE_TEMPLATE := "res://art/champions/portraits/%s_identity_v1.png"
const HUD_OVERLAY_RECT := Rect2(150, 46, 980, 632)
const HERO_CARD_SIZE := Vector2(446, 92)
const OPTION_CARD_SIZE := Vector2(760, 112)
const SHOP_CARD_SIZE := Vector2(292, 80)
const HERO_MEDIA_SLOT := Rect2(16, 10, 72, 72)
const OPTION_MEDIA_SLOT := Rect2(22, 24, 64, 64)
const SHOP_MEDIA_SLOT := Rect2(16, 14, 48, 48)
const CARD_TEXT_GAP := 16.0
const CARD_SAFE_PAD := 12.0
const CARD_BADGE_GAP := 12.0
const CHOICE_ICON_ATLAS_INSET := 8.0
const SHOP_ITEM_ICON_ATLAS_INSET := 12.0
const SHOP_ITEM_ICON_GRIDS := {
    "infinity_edge": Vector2i(0, 0),
    "statikk_shiv": Vector2i(1, 0),
    "bloodthirster": Vector2i(2, 0),
    "runaans_hurricane": Vector2i(3, 0),
    "nashors_tooth": Vector2i(0, 1),
    "rabadons_hat": Vector2i(1, 1),
    "randuins_omen": Vector2i(2, 1),
    "shield_pack": Vector2i(2, 1),
    "zhonyas_hourglass": Vector2i(0, 2),
    "black_cleaver": Vector2i(1, 2),
    "titanic": Vector2i(1, 2),
    "guardian_angel": Vector2i(2, 2),
    "future_market": Vector2i(3, 2),
    "warmogs_armor": Vector2i(0, 3),
    "liandrys": Vector2i(1, 3),
    "zekes": Vector2i(2, 3),
    "hextech_cache": Vector2i(3, 3),
    "mystery_spice": Vector2i(3, 3)
}

var title_label: Label
var stats_label: Label
var wave_label: Label
var weapon_label: Label
var message_label: Label
var help_label: Label
var xp_back: ColorRect
var xp_fill: ColorRect
var overlay_rect: ColorRect
var overlay_frame_parts: Array = []
var overlay_title: Label
var overlay_body: Label
var overlay_hint: Label
var choice_buttons: Array = []
var choice_accent_bars: Array = []
var choice_frame_parts: Array = []
var choice_icon_backs: Array = []
var choice_icon_images: Array = []
var choice_icon_labels: Array = []
var choice_badge_backs: Array = []
var choice_badge_labels: Array = []
var shop_price_backs: Array = []
var shop_price_labels: Array = []
var shop_route_labels: Array = []
var shop_route_pips: Array = []
var choice_title_labels: Array = []
var choice_desc_labels: Array = []
var start_button: Button
var shop_close_button: Button
var mute_button: Button
var return_button: Button

var message_timer := 0.0
var current_choices: Array = []
var choice_icon_atlas_texture: Texture2D = null
var shop_item_icon_atlas_texture: Texture2D = null
var champion_portrait_textures: Dictionary = {}

func _ready() -> void:
    title_label = _make_label(Vector2(24, 12), 24, Color(0.82, 0.92, 1.0))
    title_label.text = "海克斯虚空大乱斗"
    stats_label = _make_label(Vector2(24, 44), 17, Color(1.0, 0.92, 0.66))
    wave_label = _make_label(Vector2(24, 70), 16, Color(0.82, 1.0, 0.70))
    weapon_label = _make_label(Vector2(24, 96), 15, Color(0.74, 0.95, 1.0))
    message_label = _make_label(Vector2(24, 140), 20, Color(1.0, 0.86, 0.36))
    help_label = _make_label(Vector2(24, 686), 15, Color(0.88, 0.84, 0.66))
    help_label.text = "WASD / 方向键移动 | 自动攻击 | 数字键/鼠标选择 | P 暂停 | R 重开"

    xp_back = ColorRect.new()
    xp_back.position = Vector2(24, 124)
    xp_back.size = Vector2(XP_WIDTH, 8)
    xp_back.color = Color(0.04, 0.03, 0.025, 0.90)
    add_child(xp_back)

    xp_fill = ColorRect.new()
    xp_fill.position = xp_back.position
    xp_fill.size = Vector2(0, 8)
    xp_fill.color = Color(0.40, 1.0, 0.46, 0.88)
    add_child(xp_fill)

    _build_overlay()
    _build_buttons()
    _localize_static_controls()

func _localize_static_controls() -> void:
    if title_label != null:
        title_label.text = "海克斯虚空大乱斗"
    if help_label != null:
        help_label.text = "WASD / 方向键移动 | 自动攻击 | 数字键或鼠标选择 | P 暂停 | R 重开"
    if start_button != null:
        start_button.text = "开始游戏"
    if shop_close_button != null:
        shop_close_button.text = "离开商店"
    if mute_button != null:
        mute_button.text = "音效：开"
    if return_button != null:
        return_button.text = "返回选人"

func _process(delta: float) -> void:
    if message_timer > 0.0:
        message_timer -= delta
        if message_timer <= 0.0:
            message_label.text = ""

func _make_label(pos: Vector2, font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.position = pos
    label.size = Vector2(1180, 34)
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.02, 0.01, 0.0))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    add_child(label)
    return label

func _build_overlay() -> void:
    overlay_rect = ColorRect.new()
    overlay_rect.position = HUD_OVERLAY_RECT.position
    overlay_rect.size = HUD_OVERLAY_RECT.size
    overlay_rect.color = Color(0.036, 0.044, 0.070, 0.88)
    overlay_rect.visible = false
    add_child(overlay_rect)
    _build_overlay_frame()

    overlay_title = Label.new()
    overlay_title.position = Vector2(190, 72)
    overlay_title.size = Vector2(900, 48)
    overlay_title.add_theme_font_size_override("font_size", 29)
    overlay_title.add_theme_color_override("font_color", Color(0.80, 0.92, 1.0))
    overlay_title.add_theme_color_override("font_shadow_color", Color.BLACK)
    overlay_title.add_theme_constant_override("shadow_offset_x", 3)
    overlay_title.add_theme_constant_override("shadow_offset_y", 3)
    overlay_title.visible = false
    add_child(overlay_title)

    overlay_body = Label.new()
    overlay_body.position = Vector2(220, 154)
    overlay_body.size = Vector2(840, 420)
    overlay_body.add_theme_font_size_override("font_size", 17)
    overlay_body.add_theme_color_override("font_color", Color(0.94, 0.91, 0.78))
    overlay_body.add_theme_color_override("font_shadow_color", Color.BLACK)
    overlay_body.add_theme_constant_override("shadow_offset_x", 2)
    overlay_body.add_theme_constant_override("shadow_offset_y", 2)
    overlay_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    overlay_body.visible = false
    add_child(overlay_body)

    overlay_hint = Label.new()
    overlay_hint.position = Vector2(190, 650)
    overlay_hint.size = Vector2(900, 30)
    overlay_hint.add_theme_font_size_override("font_size", 15)
    overlay_hint.add_theme_color_override("font_color", Color(0.62, 1.0, 0.62))
    overlay_hint.add_theme_color_override("font_shadow_color", Color.BLACK)
    overlay_hint.add_theme_constant_override("shadow_offset_x", 2)
    overlay_hint.add_theme_constant_override("shadow_offset_y", 2)
    overlay_hint.autowrap_mode = TextServer.AUTOWRAP_OFF
    overlay_hint.clip_text = true
    overlay_hint.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    overlay_hint.visible = false
    add_child(overlay_hint)

func _build_overlay_frame() -> void:
    var frame := Rect2(overlay_rect.position, overlay_rect.size)
    var gold := Color(0.78, 0.52, 0.23, 0.92)
    var gold_soft := Color(0.78, 0.52, 0.23, 0.34)
    var blue := Color(0.24, 0.82, 1.0, 0.26)
    _add_overlay_frame_part(frame.position, Vector2(frame.size.x, 2), gold)
    _add_overlay_frame_part(frame.position + Vector2(0, frame.size.y - 2), Vector2(frame.size.x, 2), gold)
    _add_overlay_frame_part(frame.position, Vector2(2, frame.size.y), gold)
    _add_overlay_frame_part(frame.position + Vector2(frame.size.x - 2, 0), Vector2(2, frame.size.y), gold)
    var corner_len := 78.0
    var corner_thick := 4.0
    var corners := [
        frame.position,
        frame.position + Vector2(frame.size.x, 0),
        frame.position + Vector2(0, frame.size.y),
        frame.position + frame.size
    ]
    for i in range(corners.size()):
        var corner: Vector2 = corners[i]
        var sx := -1.0 if i == 1 or i == 3 else 1.0
        var sy := -1.0 if i >= 2 else 1.0
        _add_overlay_frame_part(corner + Vector2(minf(0.0, sx) * corner_len, 0), Vector2(corner_len, corner_thick), gold)
        _add_overlay_frame_part(corner + Vector2(0, minf(0.0, sy) * corner_len), Vector2(corner_thick, corner_len), gold)
    _add_overlay_frame_part(frame.position + Vector2(34, 80), Vector2(frame.size.x - 68, 1), gold_soft)
    _add_overlay_frame_part(frame.position + Vector2(190, 596), Vector2(frame.size.x - 380, 1), blue)
    _set_overlay_frame_visible(false)

func _add_overlay_frame_part(pos: Vector2, size: Vector2, color: Color) -> void:
    var part := ColorRect.new()
    part.position = pos
    part.size = size
    part.color = color
    part.visible = false
    part.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(part)
    overlay_frame_parts.append(part)

func _set_overlay_frame_visible(visible: bool) -> void:
    for part in overlay_frame_parts:
        if is_instance_valid(part):
            part.visible = visible

func _build_buttons() -> void:
    for i in range(18):
        var button := Button.new()
        button.position = Vector2(286 + (i % 2) * 360, 220 + int(i / 2) * 54)
        button.size = Vector2(342, 44)
        button.text = ""
        button.visible = false
        button.clip_contents = true
        button.focus_mode = Control.FOCUS_NONE
        button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        button.add_theme_font_size_override("font_size", 15)
        button.pressed.connect(_on_choice_button_pressed.bind(i))
        add_child(button)
        choice_buttons.append(button)

        var accent_bar := ColorRect.new()
        accent_bar.position = Vector2(10, 8)
        accent_bar.size = Vector2(6, 28)
        accent_bar.color = Color(0.82, 0.92, 1.0)
        accent_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
        button.add_child(accent_bar)
        choice_accent_bars.append(accent_bar)

        var frame_parts := []
        for frame_index in range(7):
            var frame_part := ColorRect.new()
            frame_part.mouse_filter = Control.MOUSE_FILTER_IGNORE
            frame_part.visible = false
            button.add_child(frame_part)
            frame_parts.append(frame_part)
        choice_frame_parts.append(frame_parts)

        var icon_back := ColorRect.new()
        icon_back.position = Vector2(24, 8)
        icon_back.size = Vector2(24, 24)
        icon_back.color = Color(0.08, 0.10, 0.14, 0.86)
        icon_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
        button.add_child(icon_back)
        choice_icon_backs.append(icon_back)

        var icon_image := TextureRect.new()
        icon_image.position = Vector2(26, 10)
        icon_image.size = Vector2(20, 20)
        icon_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
        icon_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        icon_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        icon_image.visible = false
        button.add_child(icon_image)
        choice_icon_images.append(icon_image)

        var icon_label := _make_card_label(Vector2(24, 8), 13, Color(1.0, 0.92, 0.58))
        icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        button.add_child(icon_label)
        choice_icon_labels.append(icon_label)

        var badge_back := ColorRect.new()
        badge_back.position = Vector2(250, 8)
        badge_back.size = Vector2(64, 20)
        badge_back.color = Color(0.08, 0.10, 0.14, 0.82)
        badge_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
        badge_back.visible = false
        button.add_child(badge_back)
        choice_badge_backs.append(badge_back)

        var badge := _make_card_label(Vector2(250, 9), 11, Color(1.0, 0.92, 0.58))
        badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        badge.visible = false
        button.add_child(badge)
        choice_badge_labels.append(badge)

        var price_back := ColorRect.new()
        price_back.position = Vector2(262, 36)
        price_back.size = Vector2(58, 22)
        price_back.color = Color(0.05, 0.04, 0.03, 0.90)
        price_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
        price_back.visible = false
        button.add_child(price_back)
        shop_price_backs.append(price_back)

        var price := _make_card_label(Vector2(262, 38), 13, Color(1.0, 0.82, 0.28))
        price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        price.visible = false
        button.add_child(price)
        shop_price_labels.append(price)

        var route := _make_card_label(Vector2(72, 52), 10, Color(0.76, 0.94, 1.0))
        route.visible = false
        button.add_child(route)
        shop_route_labels.append(route)

        var pips := []
        for pip_index in range(3):
            var pip := ColorRect.new()
            pip.position = Vector2(72 + pip_index * 12, 58)
            pip.size = Vector2(8, 3)
            pip.color = Color(1.0, 0.78, 0.28, 0.72)
            pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
            pip.visible = false
            button.add_child(pip)
            pips.append(pip)
        shop_route_pips.append(pips)

        var title := _make_card_label(Vector2(28, 6), 16, Color(0.92, 0.98, 1.0))
        var desc := _make_card_label(Vector2(28, 30), 12, Color(0.78, 0.86, 0.92))
        desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.add_child(title)
        button.add_child(desc)
        choice_title_labels.append(title)
        choice_desc_labels.append(desc)

    start_button = _make_action_button(Vector2(220, 604), Vector2(160, 40), "开始游戏")
    start_button.pressed.connect(func(): start_pressed.emit())

    shop_close_button = _make_action_button(Vector2(398, 604), Vector2(160, 40), "离开商店")
    shop_close_button.pressed.connect(func(): shop_closed.emit())

    mute_button = _make_action_button(Vector2(576, 604), Vector2(150, 40), "音效：开")
    mute_button.pressed.connect(func(): mute_pressed.emit())

    return_button = _make_action_button(Vector2(744, 604), Vector2(210, 40), "返回选人")
    return_button.pressed.connect(func(): return_select_pressed.emit())

func _make_card_label(pos: Vector2, font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.position = pos
    label.size = Vector2(200, 24)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.clip_text = true
    label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color.BLACK)
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    return label

func _make_action_button(pos: Vector2, size: Vector2, text: String) -> Button:
    var button := Button.new()
    button.position = pos
    button.size = size
    button.text = text
    button.visible = false
    button.focus_mode = Control.FOCUS_NONE
    button.add_theme_font_size_override("font_size", 15)
    add_child(button)
    return button

func _layout_overlay_controls_default() -> void:
    if overlay_hint != null:
        overlay_hint.position = Vector2(190, 650)
        overlay_hint.size = Vector2(900, 30)
    if start_button != null:
        start_button.position = Vector2(220, 586)
        start_button.size = Vector2(160, 40)
    if shop_close_button != null:
        shop_close_button.position = Vector2(398, 586)
        shop_close_button.size = Vector2(160, 40)
    if mute_button != null:
        mute_button.position = Vector2(576, 586)
        mute_button.size = Vector2(150, 40)
    if return_button != null:
        return_button.position = Vector2(744, 586)
        return_button.size = Vector2(210, 40)

func _layout_shop_overlay_controls() -> void:
    overlay_hint.position = Vector2(190, 106)
    overlay_hint.size = Vector2(420, 24)
    return_button.position = Vector2(646, 70)
    return_button.size = Vector2(142, 34)
    mute_button.position = Vector2(804, 70)
    mute_button.size = Vector2(124, 34)
    shop_close_button.position = Vector2(944, 70)
    shop_close_button.size = Vector2(142, 34)

func _on_choice_button_pressed(index: int) -> void:
    choice_selected.emit(index)

func _hide_choice_buttons() -> void:
    for i in range(choice_buttons.size()):
        var button := choice_buttons[i] as Button
        if button != null:
            button.visible = false
            button.text = ""
            button.set_meta("card_layout_profile", "inactive")
        _reset_choice_card_state(i)
    start_button.visible = false
    shop_close_button.visible = false
    mute_button.visible = false
    return_button.visible = false

func _hide_unused_choice_cards(active_count: int) -> void:
    for i in range(maxi(0, active_count), choice_buttons.size()):
        var button := choice_buttons[i] as Button
        if button != null:
            button.visible = false
            button.text = ""
            button.set_meta("card_layout_profile", "inactive")
        _reset_choice_card_state(i)

func _reset_choice_card_state(index: int) -> void:
    _reset_choice_media(index)
    _reset_shop_adornments(index)
    if index >= 0 and index < choice_accent_bars.size():
        var accent_bar := choice_accent_bars[index] as ColorRect
        if accent_bar != null:
            accent_bar.visible = false
            accent_bar.position = Vector2(10, 8)
            accent_bar.size = Vector2(6, 28)
            accent_bar.scale = Vector2.ONE
            accent_bar.rotation = 0.0
    if index >= 0 and index < choice_frame_parts.size():
        for frame_part in choice_frame_parts[index]:
            var rect := frame_part as ColorRect
            if rect != null:
                rect.visible = false
                rect.position = Vector2.ZERO
                rect.size = Vector2.ZERO
                rect.scale = Vector2.ONE
                rect.rotation = 0.0
    if index >= 0 and index < choice_badge_backs.size():
        var badge_back := choice_badge_backs[index] as ColorRect
        if badge_back != null:
            badge_back.visible = false
            badge_back.position = Vector2.ZERO
            badge_back.size = Vector2.ZERO
            badge_back.scale = Vector2.ONE
            badge_back.rotation = 0.0
    if index >= 0 and index < choice_badge_labels.size():
        var badge_label := choice_badge_labels[index] as Label
        if badge_label != null:
            badge_label.text = ""
            badge_label.visible = false
            badge_label.position = Vector2.ZERO
            badge_label.size = Vector2.ZERO
            badge_label.scale = Vector2.ONE
            badge_label.rotation = 0.0
    if index >= 0 and index < choice_title_labels.size():
        var title_label := choice_title_labels[index] as Label
        if title_label != null:
            title_label.text = ""
            title_label.visible = false
            title_label.position = Vector2.ZERO
            title_label.size = Vector2.ZERO
            title_label.scale = Vector2.ONE
            title_label.rotation = 0.0
    if index >= 0 and index < choice_desc_labels.size():
        var desc_label := choice_desc_labels[index] as Label
        if desc_label != null:
            desc_label.text = ""
            desc_label.visible = false
            desc_label.position = Vector2.ZERO
            desc_label.size = Vector2.ZERO
            desc_label.scale = Vector2.ONE
            desc_label.rotation = 0.0

func _hero_choice_position(index: int) -> Vector2:
    return HUD_OVERLAY_RECT.position + Vector2(34.0 + float(index % 2) * 480.0, 82.0 + float(index / 2) * 98.0)

func _option_choice_position(index: int) -> Vector2:
    var x := HUD_OVERLAY_RECT.position.x + (HUD_OVERLAY_RECT.size.x - OPTION_CARD_SIZE.x) * 0.5
    return Vector2(x, HUD_OVERLAY_RECT.position.y + 116.0 + float(index) * 126.0)

func _shop_choice_position(index: int) -> Vector2:
    return HUD_OVERLAY_RECT.position + Vector2(40.0 + float(index % 3) * 314.0, 112.0 + float(index / 3) * 88.0)

func _reset_choice_media(index: int) -> void:
    if index < 0:
        return
    if index < choice_buttons.size():
        var button := choice_buttons[index] as Button
        if button != null:
            _clear_media_slot_meta(button)
    if index < choice_icon_images.size():
        var icon_image := choice_icon_images[index] as TextureRect
        if icon_image != null:
            icon_image.texture = null
            icon_image.visible = false
            icon_image.custom_minimum_size = Vector2.ZERO
            icon_image.position = Vector2.ZERO
            icon_image.size = Vector2.ZERO
            icon_image.pivot_offset = Vector2.ZERO
            icon_image.scale = Vector2.ONE
            icon_image.rotation = 0.0
            icon_image.modulate = Color.WHITE
            _clear_media_slot_meta(icon_image)
    if index < choice_icon_backs.size():
        var icon_back := choice_icon_backs[index] as ColorRect
        if icon_back != null:
            icon_back.visible = false
            icon_back.position = Vector2.ZERO
            icon_back.size = Vector2.ZERO
            icon_back.scale = Vector2.ONE
            icon_back.rotation = 0.0
            _clear_media_slot_meta(icon_back)
    if index < choice_icon_labels.size():
        var icon_label := choice_icon_labels[index] as Label
        if icon_label != null:
            icon_label.text = ""
            icon_label.visible = false
            icon_label.position = Vector2.ZERO
            icon_label.size = Vector2.ZERO
            icon_label.scale = Vector2.ONE
            icon_label.rotation = 0.0

func _clear_media_slot_meta(node: Object) -> void:
    node.set_meta("media_slot_profile", "inactive")
    node.set_meta("media_slot_rect", Rect2())
    node.set_meta("media_slot_center", Vector2.ZERO)
    node.set_meta("media_inner_rect", Rect2())
    node.set_meta("media_slot_padding", 0.0)
    node.set_meta("media_alignment_mode", "inactive")
    node.set_meta("media_visual_rect", Rect2())
    node.set_meta("media_rect_locked", false)

func _layout_choice_media(index: int, back_pos: Vector2, back_size: Vector2, padding: float, profile := "choice", stretch_mode := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> void:
    if index < 0 or index >= choice_icon_backs.size() or index >= choice_icon_images.size() or index >= choice_buttons.size():
        return
    var slot_pos := back_pos.round()
    var slot_size := back_size.round()
    var inner_size := Vector2(maxf(1.0, slot_size.x - padding * 2.0), maxf(1.0, slot_size.y - padding * 2.0)).round()
    var inner_pos := (slot_pos + (slot_size - inner_size) * 0.5).round()
    var inner_rect := Rect2(inner_pos, inner_size)
    var slot_rect := Rect2(slot_pos, slot_size)
    var slot_center := slot_pos + slot_size * 0.5
    var alignment_mode := "cover_centered" if stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED else "aspect_centered"
    var button: Button = choice_buttons[index]
    button.set_meta("media_slot_profile", profile)
    button.set_meta("media_slot_rect", slot_rect)
    button.set_meta("media_inner_rect", inner_rect)
    button.set_meta("media_slot_padding", padding)
    button.set_meta("media_alignment_mode", alignment_mode)

    var icon_back: ColorRect = choice_icon_backs[index]
    icon_back.set_anchors_preset(Control.PRESET_TOP_LEFT)
    icon_back.position = slot_rect.position
    icon_back.size = slot_rect.size
    icon_back.scale = Vector2.ONE
    icon_back.rotation = 0.0
    icon_back.visible = true
    icon_back.set_meta("media_slot_profile", profile)
    icon_back.set_meta("media_slot_rect", slot_rect)
    icon_back.set_meta("media_slot_center", slot_center)
    icon_back.set_meta("media_inner_rect", inner_rect)
    icon_back.set_meta("media_slot_padding", padding)
    icon_back.set_meta("media_alignment_mode", alignment_mode)

    var icon_image: TextureRect = choice_icon_images[index]
    icon_image.set_anchors_preset(Control.PRESET_TOP_LEFT)
    icon_image.custom_minimum_size = Vector2.ZERO
    icon_image.position = inner_rect.position
    icon_image.size = inner_rect.size
    icon_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon_image.stretch_mode = stretch_mode
    icon_image.clip_contents = true
    icon_image.pivot_offset = icon_image.size * 0.5
    icon_image.scale = Vector2.ONE
    icon_image.rotation = 0.0
    icon_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
    icon_image.set_meta("media_slot_profile", profile)
    icon_image.set_meta("media_slot_rect", slot_rect)
    icon_image.set_meta("media_slot_center", slot_center)
    icon_image.set_meta("media_inner_rect", inner_rect)
    icon_image.set_meta("media_slot_padding", padding)
    icon_image.set_meta("media_alignment_mode", alignment_mode)
    icon_image.set_meta("media_visual_rect", Rect2(icon_image.position, icon_image.size))
    icon_image.set_meta("media_rect_locked", true)

func set_muted_display(muted: bool) -> void:
    if mute_button != null:
        mute_button.text = "音效：关" if muted else "音效：开"
    return
    if mute_button != null:
        mute_button.text = "音效：关" if muted else "音效：开"

func _set_choice_card(index: int, pos: Vector2, size: Vector2, title: String, desc: String, accent: Color, selected := false, badge := "") -> void:
    if index < 0 or index >= choice_buttons.size():
        return
    var button: Button = choice_buttons[index]
    button.position = pos
    button.size = size
    button.text = ""
    button.visible = true
    button.set_meta("card_layout_profile", "choice")
    _apply_card_style(button, accent, selected)
    _reset_choice_media(index)
    _reset_shop_adornments(index)

    var accent_bar: ColorRect = choice_accent_bars[index]
    accent_bar.position = Vector2(10, 8)
    accent_bar.size = Vector2(6, maxf(28.0, size.y - 16.0))
    accent_bar.color = Color(1.0, 0.82, 0.28) if selected else accent
    accent_bar.visible = true
    _sync_choice_frame(index, size, accent, selected)

    var badge_width := clampf(size.x * 0.23, 52.0, 92.0)
    var has_badge := badge.strip_edges() != ""
    var badge_back: ColorRect = choice_badge_backs[index]
    badge_back.position = Vector2(size.x - badge_width - 10.0, 8)
    badge_back.size = Vector2(badge_width, 20)
    badge_back.color = Color(accent.r, accent.g, accent.b, 0.24) if not selected else Color(1.0, 0.70, 0.18, 0.30)
    badge_back.visible = has_badge

    var badge_label: Label = choice_badge_labels[index]
    badge_label.position = badge_back.position + Vector2(0, 1)
    badge_label.size = badge_back.size
    badge_label.text = badge
    badge_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42) if selected else Color(0.86, 0.96, 1.0))
    badge_label.visible = has_badge

    var icon_text := _choice_icon_for(title, badge)
    _layout_choice_media(index, OPTION_MEDIA_SLOT.position, OPTION_MEDIA_SLOT.size, 4.0, "choice", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
    var icon_back: ColorRect = choice_icon_backs[index]
    icon_back.color = Color(accent.r, accent.g, accent.b, 0.24) if not selected else Color(1.0, 0.70, 0.18, 0.34)

    var icon_image: TextureRect = choice_icon_images[index]
    icon_image.texture = _choice_icon_texture_for(title, badge)
    icon_image.modulate = Color(1.0, 1.0, 1.0, 1.0 if selected else 0.88)
    icon_image.visible = icon_image.texture != null

    var icon_label: Label = choice_icon_labels[index]
    icon_label.position = icon_back.position
    icon_label.size = icon_back.size
    icon_label.text = "" if icon_image.visible else icon_text
    icon_label.add_theme_font_size_override("font_size", 12 if size.y < 70.0 else 13)
    icon_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.42) if selected else Color(0.88, 0.98, 1.0))
    icon_label.visible = not icon_image.visible

    var text_x := icon_back.position.x + icon_back.size.x + CARD_TEXT_GAP
    var title_y := 10.0 if size.y >= 96.0 else 6.0
    var title_label: Label = choice_title_labels[index]
    title_label.position = Vector2(text_x, title_y)
    var title_badge_pad := badge_width + CARD_BADGE_GAP + 12.0 if has_badge else 0.0
    title_label.size = Vector2(_card_text_width(size, text_x, title_badge_pad), minf(30.0, size.y * 0.35))
    title_label.add_theme_font_size_override("font_size", 15 if size.y < 76.0 else 16)
    title_label.add_theme_color_override("font_color", Color(1.0, 0.97, 0.86) if selected else Color(0.92, 0.98, 1.0))
    title_label.text = title
    title_label.visible = true

    var desc_label: Label = choice_desc_labels[index]
    desc_label.position = Vector2(text_x, title_y + 28.0)
    desc_label.size = Vector2(_card_text_width(size, text_x, 0.0), maxf(22.0, size.y - title_y - 34.0))
    desc_label.add_theme_font_size_override("font_size", 11 if size.y < 76.0 else 12)
    desc_label.text = desc
    desc_label.visible = true

func _set_shop_card(index: int, pos: Vector2, size: Vector2, option: Dictionary, gold: int) -> void:
    _set_shop_card_localized(index, pos, size, option, gold)
    return
    var price := int(option.get("price", 0))
    var recommended := bool(option.get("recommended", false))
    var affordable := price <= gold
    var accent: Color = option.get("color", Color(1.0, 0.76, 0.22) if recommended else Color(0.56, 0.78, 1.0))
    if not affordable:
        accent = Color(0.80, 0.36, 0.44)
    var badge := str(option.get("badge", "推荐" if recommended else "装备"))
    if not affordable:
        badge = "缺金币"
    var title := "%d. %s%s" % [index + 1, "★ " if recommended else "", option.get("name", "商品")]
    _set_choice_card(index, pos, size, title, str(option.get("desc", "")), accent, recommended and affordable, badge)
    _layout_choice_media(index, SHOP_MEDIA_SLOT.position, SHOP_MEDIA_SLOT.size, 3.0, "shop", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
    var icon_back: ColorRect = choice_icon_backs[index]
    icon_back.color = Color(accent.r, accent.g, accent.b, 0.18) if affordable else Color(0.18, 0.06, 0.08, 0.84)

    var icon_image: TextureRect = choice_icon_images[index]
    icon_image.texture = _shop_item_icon_texture_for(option)
    icon_image.modulate = Color(1.0, 1.0, 1.0, 0.96 if affordable else 0.46)
    icon_image.visible = icon_image.texture != null

    var icon_label: Label = choice_icon_labels[index]
    icon_label.position = icon_back.position
    icon_label.size = icon_back.size
    icon_label.text = _shop_fallback_icon_for(option)
    icon_label.add_theme_font_size_override("font_size", 17)
    icon_label.visible = not icon_image.visible

    var title_label: Label = choice_title_labels[index]
    title_label.position = Vector2(SHOP_MEDIA_SLOT.position.x + SHOP_MEDIA_SLOT.size.x + 12.0, 7)
    title_label.size = Vector2(maxf(1.0, size.x - title_label.position.x - 96.0), 22)
    title_label.add_theme_font_size_override("font_size", 14)

    var desc_label: Label = choice_desc_labels[index]
    desc_label.position = Vector2(72, 30)
    desc_label.size = Vector2(size.x - 86.0, 20)
    desc_label.add_theme_font_size_override("font_size", 10)

    var price_back: ColorRect = shop_price_backs[index]
    price_back.position = Vector2(size.x - 72.0, 38)
    price_back.size = Vector2(60, 22)
    price_back.color = Color(1.0, 0.72, 0.16, 0.24) if affordable else Color(0.60, 0.10, 0.18, 0.42)
    price_back.visible = true

    var price_label: Label = shop_price_labels[index]
    price_label.position = price_back.position + Vector2(0, 2)
    price_label.size = price_back.size
    price_label.text = "%dG" % price
    price_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.28) if affordable else Color(1.0, 0.50, 0.56))
    price_label.visible = true

    var route_label: Label = shop_route_labels[index]
    route_label.position = Vector2(72, 47)
    route_label.size = Vector2(size.x - 150.0, 16)
    route_label.text = _shop_route_text_for(option)
    route_label.add_theme_color_override("font_color", accent.lightened(0.20) if affordable else Color(0.92, 0.56, 0.58))
    route_label.visible = true

    _sync_shop_route_pips(index, option, accent, affordable)

func _set_shop_card_localized(index: int, pos: Vector2, size: Vector2, option: Dictionary, gold: int) -> void:
    var price := int(option.get("price", option.get("cost", 0)))
    var recommended := bool(option.get("recommended", false))
    var affordable := price <= gold
    var accent: Color = option.get("color", Color(1.0, 0.76, 0.22) if recommended else Color(0.56, 0.78, 1.0))
    if not affordable:
        accent = Color(0.80, 0.36, 0.44)
    var badge := str(option.get("badge", "推荐" if recommended else "装备"))
    if not affordable:
        badge = "金币不足"
    var title := "%d. %s%s" % [index + 1, "推荐 " if recommended else "", option.get("name", "商品")]
    _set_choice_card(index, pos, size, title, str(option.get("desc", "")), accent, recommended and affordable, badge)

    var button := choice_buttons[index] as Button
    if button != null:
        button.set_meta("card_layout_profile", "shop")
    _layout_choice_media(index, SHOP_MEDIA_SLOT.position, SHOP_MEDIA_SLOT.size, 3.0, "shop", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
    var icon_back: ColorRect = choice_icon_backs[index]
    icon_back.color = Color(accent.r, accent.g, accent.b, 0.18) if affordable else Color(0.18, 0.06, 0.08, 0.84)

    var icon_image: TextureRect = choice_icon_images[index]
    icon_image.texture = _shop_item_icon_texture_for(option)
    icon_image.modulate = Color(1.0, 1.0, 1.0, 0.96 if affordable else 0.46)
    icon_image.visible = icon_image.texture != null

    var icon_label: Label = choice_icon_labels[index]
    icon_label.position = icon_back.position
    icon_label.size = icon_back.size
    icon_label.text = _shop_fallback_icon_for(option)
    icon_label.add_theme_font_size_override("font_size", 17)
    icon_label.visible = not icon_image.visible

    var title_label: Label = choice_title_labels[index]
    title_label.position = Vector2(SHOP_MEDIA_SLOT.position.x + SHOP_MEDIA_SLOT.size.x + 12.0, 7)
    title_label.size = Vector2(maxf(1.0, size.x - title_label.position.x - 96.0), 22)
    title_label.add_theme_font_size_override("font_size", 14)

    var desc_label: Label = choice_desc_labels[index]
    desc_label.position = Vector2(title_label.position.x, 30)
    desc_label.size = Vector2(size.x - title_label.position.x - 18.0, 20)
    desc_label.add_theme_font_size_override("font_size", 10)

    var price_back: ColorRect = shop_price_backs[index]
    price_back.position = Vector2(size.x - 74.0, 38)
    price_back.size = Vector2(62, 22)
    price_back.color = Color(1.0, 0.72, 0.16, 0.24) if affordable else Color(0.60, 0.10, 0.18, 0.42)
    price_back.visible = true

    var price_label: Label = shop_price_labels[index]
    price_label.position = price_back.position + Vector2(0, 2)
    price_label.size = price_back.size
    price_label.text = "%dG" % price
    price_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.28) if affordable else Color(1.0, 0.50, 0.56))
    price_label.visible = true

    var route_label: Label = shop_route_labels[index]
    route_label.position = Vector2(title_label.position.x, 47)
    route_label.size = Vector2(size.x - title_label.position.x - 84.0, 16)
    route_label.text = _shop_route_text_for(option)
    route_label.add_theme_color_override("font_color", accent.lightened(0.20) if affordable else Color(0.92, 0.56, 0.58))
    route_label.visible = true

    _sync_shop_route_pips(index, option, accent, affordable)

func _reset_shop_adornments(index: int) -> void:
    if index >= 0 and index < shop_price_backs.size():
        var price_back: ColorRect = shop_price_backs[index]
        price_back.visible = false
        price_back.position = Vector2.ZERO
        price_back.size = Vector2.ZERO
    if index >= 0 and index < shop_price_labels.size():
        var price_label: Label = shop_price_labels[index]
        price_label.visible = false
        price_label.text = ""
        price_label.position = Vector2.ZERO
        price_label.size = Vector2.ZERO
    if index >= 0 and index < shop_route_labels.size():
        var route_label: Label = shop_route_labels[index]
        route_label.visible = false
        route_label.text = ""
        route_label.position = Vector2.ZERO
        route_label.size = Vector2.ZERO
    if index >= 0 and index < shop_route_pips.size():
        for pip in shop_route_pips[index]:
            if is_instance_valid(pip):
                pip.visible = false
                pip.position = Vector2.ZERO
                pip.size = Vector2.ZERO

func _sync_shop_route_pips(index: int, option: Dictionary, accent: Color, affordable: bool) -> void:
    if index < 0 or index >= shop_route_pips.size():
        return
    var route_score := int(option.get("route_score", 0))
    if route_score <= 0 and bool(option.get("recommended", false)):
        route_score = 1
    var pips: Array = shop_route_pips[index]
    for pip_index in range(pips.size()):
        var pip := pips[pip_index] as ColorRect
        if pip == null:
            continue
        pip.position = Vector2(SHOP_MEDIA_SLOT.position.x + SHOP_MEDIA_SLOT.size.x + 42.0 + pip_index * 12, 66)
        pip.size = Vector2(8, 3)
        pip.color = Color(1.0, 0.78, 0.24, 0.78) if pip_index < route_score and affordable else Color(accent.r, accent.g, accent.b, 0.24)
        pip.visible = true

func _sync_choice_frame(index: int, size: Vector2, accent: Color, selected: bool) -> void:
    if index < 0 or index >= choice_frame_parts.size():
        return
    var parts: Array = choice_frame_parts[index]
    if parts.size() < 7:
        return
    var bright := Color(1.0, 0.78, 0.28, 0.76) if selected else Color(accent.r, accent.g, accent.b, 0.46)
    var soft := Color(1.0, 0.78, 0.28, 0.28) if selected else Color(accent.r, accent.g, accent.b, 0.20)
    var corner := minf(34.0, maxf(20.0, size.y * 0.34))
    var line := 2.0
    _set_card_frame_part(parts[0], Vector2(4, 4), Vector2(corner, line), bright)
    _set_card_frame_part(parts[1], Vector2(4, 4), Vector2(line, corner), bright)
    _set_card_frame_part(parts[2], Vector2(size.x - corner - 4.0, size.y - 6.0), Vector2(corner, line), bright)
    _set_card_frame_part(parts[3], Vector2(size.x - 6.0, size.y - corner - 4.0), Vector2(line, corner), bright)
    _set_card_frame_part(parts[4], Vector2(58, size.y - 8.0), Vector2(maxf(40.0, size.x - 116.0), 1.0), soft)
    _set_card_frame_part(parts[5], Vector2(size.x - 38.0, 8.0), Vector2(22.0, 1.0), soft)
    _set_card_frame_part(parts[6], Vector2(size.x - 18.0, 8.0), Vector2(1.0, 20.0), soft)

func _set_card_frame_part(part, pos: Vector2, size: Vector2, color: Color) -> void:
    if not (part is ColorRect):
        return
    var rect := part as ColorRect
    rect.position = pos
    rect.size = size
    rect.color = color
    rect.visible = true

func _choice_icon_texture_for(title: String, badge: String) -> Texture2D:
    var atlas := _choice_icon_atlas()
    if atlas == null:
        return null
    var grid := _choice_icon_grid_for(title, badge)
    return _make_ui_atlas_texture(atlas, grid, 4, 4, CHOICE_ICON_ATLAS_INSET)

func _choice_icon_atlas() -> Texture2D:
    if choice_icon_atlas_texture != null:
        return choice_icon_atlas_texture
    if ResourceLoader.exists(CHOICE_ICON_ATLAS_TEXTURE_PATH):
        choice_icon_atlas_texture = load(CHOICE_ICON_ATLAS_TEXTURE_PATH) as Texture2D
    elif FileAccess.file_exists(CHOICE_ICON_ATLAS_TEXTURE_PATH):
        var image := Image.new()
        var err := image.load(CHOICE_ICON_ATLAS_TEXTURE_PATH)
        if err == OK:
            choice_icon_atlas_texture = ImageTexture.create_from_image(image)
    return choice_icon_atlas_texture

func _shop_item_icon_texture_for(option: Dictionary) -> Texture2D:
    var atlas := _shop_item_icon_atlas()
    if atlas == null:
        return null
    var grid := _shop_item_icon_grid_for(option)
    return _make_ui_atlas_texture(atlas, grid, 4, 4, SHOP_ITEM_ICON_ATLAS_INSET)

func _make_ui_atlas_texture(atlas: Texture2D, grid: Vector2i, columns: int, rows: int, inset: float) -> AtlasTexture:
    var cell := Vector2(float(atlas.get_width()) / float(columns), float(atlas.get_height()) / float(rows))
    var safe_inset := clampf(inset, 0.0, minf(cell.x, cell.y) * 0.24)
    var cell_rect := Rect2(Vector2(float(grid.x) * cell.x, float(grid.y) * cell.y), cell)
    var region := Rect2(
        cell_rect.position + Vector2(safe_inset, safe_inset),
        Vector2(maxf(1.0, cell.x - safe_inset * 2.0), maxf(1.0, cell.y - safe_inset * 2.0))
    )
    var texture := AtlasTexture.new()
    texture.atlas = atlas
    texture.region = region
    texture.set_meta("ui_atlas_grid", grid)
    texture.set_meta("ui_atlas_cell_rect", cell_rect)
    texture.set_meta("ui_atlas_safe_inset_px", safe_inset)
    texture.set_meta("ui_atlas_region_center_locked", region.get_center().distance_to(cell_rect.get_center()) <= 0.01)
    return texture

func _shop_item_icon_atlas() -> Texture2D:
    if shop_item_icon_atlas_texture != null:
        return shop_item_icon_atlas_texture
    if ResourceLoader.exists(SHOP_ITEM_ICON_ATLAS_TEXTURE_PATH):
        shop_item_icon_atlas_texture = load(SHOP_ITEM_ICON_ATLAS_TEXTURE_PATH) as Texture2D
    elif FileAccess.file_exists(SHOP_ITEM_ICON_ATLAS_TEXTURE_PATH):
        var image := Image.new()
        var err := image.load(SHOP_ITEM_ICON_ATLAS_TEXTURE_PATH)
        if err == OK:
            shop_item_icon_atlas_texture = ImageTexture.create_from_image(image)
    return shop_item_icon_atlas_texture

func _shop_item_icon_grid_for(option: Dictionary) -> Vector2i:
    var item_id := str(option.get("item", option.get("id", "")))
    var option_id := str(option.get("id", item_id))
    if SHOP_ITEM_ICON_GRIDS.has(item_id):
        return SHOP_ITEM_ICON_GRIDS[item_id]
    if SHOP_ITEM_ICON_GRIDS.has(option_id):
        return SHOP_ITEM_ICON_GRIDS[option_id]
    match str(option.get("type", "item")):
        "hextech":
            return Vector2i(3, 3)
        "shield":
            return Vector2i(2, 1)
    var tags: Array = option.get("tags", [])
    if tags.has("marksman"):
        return Vector2i(3, 0)
    if tags.has("magic"):
        return Vector2i(1, 1)
    if tags.has("tank"):
        return Vector2i(0, 3)
    if tags.has("melee"):
        return Vector2i(1, 2)
    if tags.has("summon"):
        return Vector2i(0, 1)
    if tags.has("support"):
        return Vector2i(2, 3)
    return Vector2i(0, 0)

func _shop_fallback_icon_for(option: Dictionary) -> String:
    var clean_tags: Array = option.get("tags", [])
    if clean_tags.has("marksman"):
        return "射"
    if clean_tags.has("magic"):
        return "法"
    if clean_tags.has("tank"):
        return "盾"
    if clean_tags.has("melee"):
        return "斩"
    if clean_tags.has("summon"):
        return "召"
    if clean_tags.has("support"):
        return "辅"
    return "装"
    var tags: Array = option.get("tags", [])
    if tags.has("marksman"):
        return "弓"
    if tags.has("magic"):
        return "法"
    if tags.has("tank"):
        return "盾"
    if tags.has("melee"):
        return "斧"
    if tags.has("summon"):
        return "晶"
    if tags.has("support"):
        return "旗"
    return "装"

func _shop_route_text_for(option: Dictionary) -> String:
    var clean_tags: Array = option.get("tags", [])
    var clean_parts := []
    for tag in clean_tags:
        match str(tag):
            "physical":
                clean_parts.append("物理")
            "crit":
                clean_parts.append("暴击")
            "marksman":
                clean_parts.append("射手")
            "magic":
                clean_parts.append("法系")
            "haste":
                clean_parts.append("急速")
            "summon":
                clean_parts.append("召唤")
            "tank":
                clean_parts.append("坦克")
            "melee":
                clean_parts.append("近战")
            "support":
                clean_parts.append("支援")
            "pierce":
                clean_parts.append("穿透")
    if clean_parts.is_empty():
        return "通用装备"
    var clean_text := " / ".join(clean_parts.slice(0, mini(3, clean_parts.size())))
    var clean_score := int(option.get("route_score", 0))
    if clean_score > 0:
        clean_text += "  推荐+%d" % clean_score
    return clean_text
    var tags: Array = option.get("tags", [])
    var parts := []
    for tag in tags:
        match str(tag):
            "physical":
                parts.append("物理")
            "crit":
                parts.append("暴击")
            "marksman":
                parts.append("射手")
            "magic":
                parts.append("法系")
            "haste":
                parts.append("急速")
            "summon":
                parts.append("召唤")
            "tank":
                parts.append("坦克")
            "melee":
                parts.append("近战")
            "support":
                parts.append("支援")
            "pierce":
                parts.append("穿透")
    if parts.is_empty():
        return "通用装备"
    var text := " / ".join(parts.slice(0, mini(3, parts.size())))
    var score := int(option.get("route_score", 0))
    if score > 0:
        text += "  推荐+%d" % score
    return text

func _champion_portrait_texture(character_id: String) -> Texture2D:
    if champion_portrait_textures.has(character_id):
        return champion_portrait_textures[character_id]
    var path := CHAMPION_PORTRAIT_TEXTURE_TEMPLATE % character_id
    var texture: Texture2D = null
    if ResourceLoader.exists(path):
        texture = load(path) as Texture2D
    elif FileAccess.file_exists(path):
        var image := Image.new()
        var err := image.load(path)
        if err == OK:
            texture = ImageTexture.create_from_image(image)
    if texture != null:
        texture = _make_champion_portrait_focus_texture(texture, character_id)
    champion_portrait_textures[character_id] = texture
    return texture

func _make_champion_portrait_focus_texture(texture: Texture2D, character_id: String) -> Texture2D:
    var source_size := Vector2(float(texture.get_width()), float(texture.get_height()))
    if source_size.x <= 1.0 or source_size.y <= 1.0:
        return texture
    var region := _champion_portrait_focus_region(character_id, source_size)
    var atlas := AtlasTexture.new()
    atlas.atlas = texture
    atlas.region = region
    atlas.set_meta("portrait_focus_character", character_id)
    atlas.set_meta("portrait_focus_source_size", source_size)
    atlas.set_meta("portrait_focus_square", absf(region.size.x - region.size.y) <= 1.0)
    atlas.set_meta("portrait_focus_center_locked", true)
    return atlas

func _champion_portrait_focus_region(character_id: String, source_size: Vector2) -> Rect2:
    var normalized := Rect2(0.18, 0.08, 0.66, 0.72)
    match character_id:
        "jinx":
            normalized = Rect2(0.20, 0.08, 0.66, 0.70)
        "senna":
            normalized = Rect2(0.18, 0.07, 0.66, 0.72)
        "samira":
            normalized = Rect2(0.18, 0.08, 0.64, 0.70)
        "viktor":
            normalized = Rect2(0.18, 0.06, 0.66, 0.72)
        "xayah":
            normalized = Rect2(0.18, 0.07, 0.66, 0.72)
        "mordekaiser":
            normalized = Rect2(0.16, 0.06, 0.70, 0.74)
        "teemo":
            normalized = Rect2(0.16, 0.06, 0.70, 0.72)
        "aurelion_sol":
            normalized = Rect2(0.14, 0.05, 0.72, 0.74)
        _:
            pass
    var center := normalized.position + normalized.size * 0.5
    var side := clampf(maxf(normalized.size.x, normalized.size.y), 0.62, 0.78)
    normalized = Rect2(center - Vector2(side, side) * 0.5, Vector2(side, side))
    normalized.position.x = clampf(normalized.position.x, 0.0, maxf(0.0, 1.0 - normalized.size.x))
    normalized.position.y = clampf(normalized.position.y, 0.0, maxf(0.0, 1.0 - normalized.size.y))
    var pixel_side := minf(normalized.size.x * source_size.x, normalized.size.y * source_size.y)
    var region_center := Vector2(normalized.position.x * source_size.x, normalized.position.y * source_size.y) + Vector2(pixel_side, pixel_side) * 0.5
    var region := Rect2(region_center - Vector2(pixel_side, pixel_side) * 0.5, Vector2(pixel_side, pixel_side))
    region.position.x = clampf(region.position.x, 0.0, source_size.x - 1.0)
    region.position.y = clampf(region.position.y, 0.0, source_size.y - 1.0)
    var final_side := clampf(region.size.x, 1.0, minf(source_size.x - region.position.x, source_size.y - region.position.y))
    region.size = Vector2(final_side, final_side)
    return region

func _set_character_card_portrait(index: int, character_id: String, selected: bool) -> void:
    if index < 0 or index >= choice_buttons.size():
        return
    var texture := _champion_portrait_texture(character_id)
    if texture == null:
        return
    var button: Button = choice_buttons[index]
    var card_size := button.size
    button.set_meta("card_layout_profile", "hero")
    _layout_choice_media(index, HERO_MEDIA_SLOT.position, HERO_MEDIA_SLOT.size, 3.0, "hero", TextureRect.STRETCH_KEEP_ASPECT_COVERED)
    var icon_back: ColorRect = choice_icon_backs[index]
    icon_back.color = Color(1.0, 0.70, 0.18, 0.30) if selected else Color(0.06, 0.08, 0.12, 0.88)

    var icon_image: TextureRect = choice_icon_images[index]
    icon_image.texture = texture
    icon_image.modulate = Color(1.0, 1.0, 1.0, 1.0 if selected else 0.92)
    icon_image.visible = true

    var icon_label: Label = choice_icon_labels[index]
    icon_label.visible = false

    var text_x := icon_back.position.x + icon_back.size.x + CARD_TEXT_GAP
    var badge_reserved := 18.0
    if index >= 0 and index < choice_badge_backs.size():
        var badge_back: ColorRect = choice_badge_backs[index]
        if badge_back != null and bool(badge_back.visible):
            badge_reserved = badge_back.size.x + 24.0
    var title_label: Label = choice_title_labels[index]
    title_label.position = Vector2(text_x, 9)
    title_label.size = Vector2(_card_text_width(card_size, text_x, badge_reserved), 26)
    title_label.add_theme_font_size_override("font_size", 16)

    var desc_label: Label = choice_desc_labels[index]
    desc_label.position = Vector2(text_x, 36)
    desc_label.size = Vector2(_card_text_width(card_size, text_x, 0.0), maxf(36.0, card_size.y - 42.0))
    desc_label.add_theme_font_size_override("font_size", 11)

func _card_text_width(card_size: Vector2, text_x: float, right_reserved: float) -> float:
    return maxf(1.0, card_size.x - text_x - CARD_SAFE_PAD - right_reserved)

func _choice_icon_grid_for(title: String, badge: String) -> Vector2i:
    var clean_haystack := (title + " " + badge).to_lower()
    if clean_haystack.find("金币不足") >= 0 or clean_haystack.find("危险") >= 0:
        return Vector2i(0, 3)
    if clean_haystack.find("黄金") >= 0 or clean_haystack.find("金币") >= 0 or clean_haystack.find("装备") >= 0 or clean_haystack.find("商品") >= 0:
        return Vector2i(2, 0)
    if clean_haystack.find("虚空") >= 0 or clean_haystack.find("毒") >= 0 or clean_haystack.find("召唤") >= 0:
        return Vector2i(1, 0)
    if clean_haystack.find("物理") >= 0 or clean_haystack.find("射手") >= 0 or clean_haystack.find("暴击") >= 0:
        return Vector2i(2, 2)
    if clean_haystack.find("近战") >= 0 or clean_haystack.find("连招") >= 0:
        return Vector2i(3, 2)
    if clean_haystack.find("魔法") >= 0 or clean_haystack.find("法师") >= 0 or clean_haystack.find("海克斯") >= 0:
        return Vector2i(0, 0)
    if clean_haystack.find("坦克") >= 0 or clean_haystack.find("护盾") >= 0:
        return Vector2i(2, 1)
    if clean_haystack.find("棱彩") >= 0 or clean_haystack.find("命运") >= 0:
        return Vector2i(3, 0)
    if clean_haystack.find("专属") >= 0 or clean_haystack.find("升级") >= 0:
        return Vector2i(0, 1)
    var haystack := (title + " " + badge).to_lower()
    if haystack.find("缺金币") >= 0 or haystack.find("危险") >= 0:
        return Vector2i(0, 3)
    if haystack.find("黄金") >= 0 or haystack.find("金币") >= 0 or haystack.find("装备") >= 0 or haystack.find("商品") >= 0:
        return Vector2i(2, 0)
    if haystack.find("虚空") >= 0 or haystack.find("毒") >= 0 or haystack.find("召唤") >= 0:
        return Vector2i(1, 0)
    if haystack.find("物理") >= 0 or haystack.find("射手") >= 0 or haystack.find("暴击") >= 0:
        return Vector2i(2, 2)
    if haystack.find("近战") >= 0 or haystack.find("连招") >= 0:
        return Vector2i(3, 2)
    if haystack.find("魔法") >= 0 or haystack.find("法师") >= 0 or haystack.find("海克斯") >= 0:
        return Vector2i(0, 0)
    if haystack.find("坦克") >= 0 or haystack.find("护盾") >= 0:
        return Vector2i(2, 1)
    if haystack.find("棱彩") >= 0 or haystack.find("命运") >= 0:
        return Vector2i(3, 0)
    if haystack.find("专属") >= 0 or haystack.find("升级") >= 0:
        return Vector2i(0, 1)
    return Vector2i(0, 0)

func _choice_icon_for(title: String, badge: String) -> String:
    var clean_haystack := (title + " " + badge).to_lower()
    if clean_haystack.find("推荐") >= 0:
        return "荐"
    if clean_haystack.find("命运") >= 0:
        return "命"
    if clean_haystack.find("海克斯") >= 0 or clean_haystack.find("棱彩") >= 0 or clean_haystack.find("白银") >= 0 or clean_haystack.find("黄金") >= 0:
        return "海"
    if clean_haystack.find("商品") >= 0 or clean_haystack.find("装备") >= 0:
        return "装"
    if clean_haystack.find("金币") >= 0:
        return "金"
    if clean_haystack.find("射手") >= 0:
        return "射"
    if clean_haystack.find("魔法") >= 0 or clean_haystack.find("法师") >= 0:
        return "法"
    if clean_haystack.find("坦克") >= 0:
        return "坦"
    if clean_haystack.find("近战") >= 0 or clean_haystack.find("连招") >= 0:
        return "斩"
    if clean_haystack.find("召唤") >= 0 or clean_haystack.find("毒") >= 0:
        return "召"
    if clean_haystack.find("支援") >= 0:
        return "辅"
    if clean_haystack.find("升级") >= 0:
        return "升"
    return "◆"
    var haystack := (title + " " + badge).to_lower()
    if haystack.find("专") >= 0:
        return "专"
    if haystack.find("推荐") >= 0:
        return "荐"
    if haystack.find("命运") >= 0:
        return "命"
    if haystack.find("海克斯") >= 0 or haystack.find("棱彩") >= 0 or haystack.find("白银") >= 0 or haystack.find("黄金") >= 0:
        return "海"
    if haystack.find("商") >= 0 or haystack.find("装备") >= 0:
        return "装"
    if haystack.find("金币") >= 0:
        return "金"
    if haystack.find("射") >= 0:
        return "射"
    if haystack.find("法") >= 0 or haystack.find("星") >= 0:
        return "法"
    if haystack.find("坦") >= 0:
        return "坦"
    if haystack.find("近") >= 0 or haystack.find("连招") >= 0:
        return "斩"
    if haystack.find("召") >= 0 or haystack.find("毒") >= 0:
        return "召"
    if haystack.find("辅助") >= 0 or haystack.find("支援") >= 0:
        return "辅"
    if haystack.find("升级") >= 0:
        return "升"
    return "◇"

func _apply_card_style(button: Button, accent: Color, selected: bool) -> void:
    var base := Color(0.090, 0.104, 0.150, 0.96)
    if selected:
        base = Color(0.205, 0.150, 0.060, 0.97)
    var normal := StyleBoxFlat.new()
    normal.bg_color = base
    normal.border_color = accent
    normal.border_width_left = 2
    normal.border_width_top = 2
    normal.border_width_right = 2
    normal.border_width_bottom = 2
    normal.corner_radius_top_left = 8
    normal.corner_radius_top_right = 8
    normal.corner_radius_bottom_left = 8
    normal.corner_radius_bottom_right = 8
    normal.content_margin_left = 8
    normal.content_margin_right = 8
    normal.content_margin_top = 8
    normal.content_margin_bottom = 8

    var hover := normal.duplicate()
    hover.bg_color = base.lightened(0.08)
    hover.border_color = accent.lightened(0.18)

    var pressed := normal.duplicate()
    pressed.bg_color = base.darkened(0.08)
    pressed.border_color = accent.lightened(0.35)

    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("focus", hover)

func update_run(player, elapsed: float, wave: int, enemies: int, boss_active: bool, boss_time: float, boss_health_ratio := -1.0) -> void:
    _update_run_localized(player, elapsed, wave, enemies, boss_active, boss_time, boss_health_ratio)
    return
    var hp := ""
    for i in range(player.max_health):
        hp += "#" if i < player.health else "-"
    stats_label.text = "%s[%s/%s/%s]  生命[%s]  护盾:%d  等级:%d  金币:%03d  分数:%05d" % [
        player.get_character_name(),
        player.get_role_label(),
        player.get_damage_type(),
        player.get_range_type(),
        hp,
        player.shield,
        player.level,
        player.gold,
        player.score
    ]
    var boss_text := "  |  虚空 Boss 已登场" if boss_active else "  |  Boss %.0f 秒" % maxf(0.0, boss_time)
    wave_label.text = "时间 %s  |  波次 %02d  |  敌人 %02d%s" % [_format_time(elapsed), wave, enemies, boss_text]
    if boss_active and boss_health_ratio >= 0.0:
        wave_label.text = "时间 %s  |  波次 %02d  |  敌人 %02d  |  虚空 Boss 生命 %.0f%%" % [_format_time(elapsed), wave, enemies, boss_health_ratio * 100.0]
    var upgrade_total := 0
    for key in player.inventory.keys():
        upgrade_total += int(player.inventory[key])
    weapon_label.text = "伤害:%d  冷却:%.2fs  侧射:%d  范围:%d  飞环:%d  升级:%d  海克斯:%d" % [
        player.damage,
        player.attack_cooldown * player.cooldown_mult,
        player.lime_level,
        player.aura_level,
        player.orbit_count,
        upgrade_total,
        player.get_hextech_augment_ids().size()
    ]
    xp_fill.size = Vector2(XP_WIDTH * player.get_xp_fill(), 8)

func show_message(text: String, duration := 2.2) -> void:
    message_label.text = text
    message_timer = duration

func show_title(selected_character: String) -> void:
    _show_title_localized(selected_character)
    return
    _show_overlay(false)
    _hide_choice_buttons()
    overlay_title.text = "海克斯虚空大乱斗"
    overlay_body.text = ""
    var cards := [
        {"id": "jinx", "title": "1. 金克丝 | 远程射手 | 物理暴击", "desc": "火箭弹幕和烟花溅射，吃暴击、弹速、飓风。", "color": Color(1.0, 0.30, 0.62)},
        {"id": "senna", "title": "2. 赛娜 | 远程支援 | 混合穿透", "desc": "长距离穿透与灵魂成长，偏支援、穿透、保命。", "color": Color(0.55, 1.0, 0.78)},
        {"id": "samira", "title": "3. 莎弥拉 | 近战射手 | 物理连招", "desc": "贴脸双枪和评分爆发，偏攻速、吸血、近战路线。", "color": Color(1.0, 0.62, 0.22)},
        {"id": "viktor", "title": "4. 维克托 | 远程法师 | 魔法激光", "desc": "高穿透激光与重力场，偏技能强度和急速。", "color": Color(0.72, 0.94, 1.0)},
        {"id": "xayah", "title": "5. 霞 | 远程射手 | 羽刃回收", "desc": "羽毛前后夹击，吃穿透、弹链和暴击路线。", "color": Color(1.0, 0.34, 0.62)},
        {"id": "mordekaiser", "title": "6. 莫德凯撒 | 近战坦克 | 魔法暗域", "desc": "近身锤击和暗域脉冲，偏坦度、范围、护盾。", "color": Color(0.58, 1.0, 0.58)},
        {"id": "teemo", "title": "7. 提莫 | 远程召唤 | 毒蘑菇", "desc": "毒镖风筝与蘑菇陷阱，偏召唤、持续区域控制。", "color": Color(0.70, 1.0, 0.22)},
        {"id": "aurelion_sol", "title": "8. 龙王 | 远程法师 | 星轨黑洞", "desc": "星体环绕和黑洞爆发，偏魔法、召唤、后期成长。", "color": Color(0.92, 0.72, 1.0)}
    ]
    for i in range(cards.size()):
        var card: Dictionary = cards[i]
        var card_id := str(card.get("id", ""))
        var selected := card_id == selected_character
        var title := ("✓ " if selected else "") + str(card.get("title", "英雄"))
        _set_choice_card(i, _hero_choice_position(i), HERO_CARD_SIZE, title, str(card.get("desc", "")), card.get("color", Color.WHITE), selected, "已选" if selected else _character_route_badge(card_id))
        _set_character_card_portrait(i, card_id, selected)
    _hide_unused_choice_cards(cards.size())
    start_button.text = "开始游戏"
    start_button.visible = true
    mute_button.visible = true
    overlay_hint.text = "点击英雄后点开始，或按 1-8 选择、Enter/R 开始。当前：%s" % _character_label(selected_character)

func show_pause() -> void:
    _show_pause_localized()
    return
    _show_overlay()
    _hide_choice_buttons()
    overlay_title.text = "已暂停"
    overlay_body.text = "虚空虫潮暂时停住了。调整一下手指，回去继续绕弹幕。"
    mute_button.visible = true
    return_button.visible = true
    overlay_hint.text = "P / Enter / Esc：继续    R：重新开始"

func show_upgrade_choices(options: Array) -> void:
    _show_upgrade_choices_localized(options)
    return
    current_choices = options
    _show_overlay(false)
    _hide_choice_buttons()
    overlay_title.text = "选择升级"
    overlay_body.text = ""
    for i in range(options.size()):
        var option: Dictionary = options[i]
        var title := "%d. %s" % [i + 1, option.get("name", "升级")]
        _set_choice_card(i, _option_choice_position(i), OPTION_CARD_SIZE, title, str(option.get("desc", "")), option.get("color", Color(0.82, 0.92, 1.0)), bool(option.get("recommended", false)), str(option.get("badge", "升级")))
    _hide_unused_choice_cards(options.size())
    return_button.visible = true
    mute_button.visible = true
    overlay_hint.text = "点击卡片或按 1 / 2 / 3 选择。卡片内已显示效果描述。"

func show_fate_choices(options: Array) -> void:
    _show_fate_choices_localized(options)
    return
    current_choices = options
    _show_overlay(false)
    _hide_choice_buttons()
    overlay_title.text = "选择本局命运"
    overlay_body.text = ""
    for i in range(options.size()):
        var option: Dictionary = options[i]
        var title := "%d. %s" % [i + 1, option.get("name", "命运")]
        _set_choice_card(i, _option_choice_position(i), OPTION_CARD_SIZE, title, str(option.get("desc", "")), Color(0.82, 0.54, 1.0), false, "命运")
    _hide_unused_choice_cards(options.size())
    return_button.visible = true
    mute_button.visible = true
    overlay_hint.text = "每局开局先选方向。点击卡片或按 1 / 2 / 3。"

func show_hextech_choices(options: Array) -> void:
    _show_hextech_choices_localized(options)
    return
    current_choices = options
    _show_overlay(false)
    _hide_choice_buttons()
    overlay_title.text = "海克斯强化"
    overlay_body.text = ""
    for i in range(options.size()):
        var option: Dictionary = options[i]
        var title := "%d. [%s] %s" % [i + 1, option.get("tier_label", "海克斯"), option.get("name", "强化")]
        _set_choice_card(i, _option_choice_position(i), OPTION_CARD_SIZE, title, str(option.get("desc", "")), option.get("color", Color(0.82, 0.54, 1.0)), bool(option.get("recommended", false)), str(option.get("badge", option.get("tier_label", "海克斯"))))
    _hide_unused_choice_cards(options.size())
    return_button.visible = true
    mute_button.visible = true
    overlay_hint.text = "海克斯会整局生效。点击卡片或按 1 / 2 / 3 锻造。"

func show_shop_choices(options: Array, gold: int) -> void:
    _show_shop_choices_localized(options, gold)
    return
    current_choices = options
    _show_overlay(false)
    _hide_choice_buttons()
    overlay_title.text = "海克斯装备商店    金币：%d" % gold
    overlay_body.text = ""
    for i in range(options.size()):
        var option: Dictionary = options[i]
        if i < choice_buttons.size():
            _set_shop_card(i, _shop_choice_position(i), SHOP_CARD_SIZE, option, gold)
    _hide_unused_choice_cards(mini(options.size(), choice_buttons.size()))
    shop_close_button.visible = true
    mute_button.visible = true
    return_button.visible = true
    overlay_hint.text = "点击商品可连续购买。大图标是装备类型，路线条越亮越适合当前英雄；离开商店后继续战斗。"

func show_summary(won: bool, player, elapsed: float) -> void:
    _show_summary_localized(won, player, elapsed)
    return
    _show_overlay()
    _hide_choice_buttons()
    overlay_title.text = "虚空 Boss 已击败！" if won else "本局结束"
    var result := "你在海克斯大桥上活过了虚空弹幕，并击败了最后的 Boss。" if won else "这局倒下了，但构筑思路已经留下。下一把换个英雄或命运试试。"
    overlay_body.text = "%s\n\n英雄：%s - %s\n时间：%s\n等级：%d\n分数：%05d\n升级：%s\n装备：%s\n海克斯：%s\n联动：%s" % [
        result,
        player.get_character_name(),
        player.get_character_title(),
        _format_time(elapsed),
        player.level,
        player.score,
        player.get_upgrade_summary(),
        player.get_item_summary(),
        player.get_hextech_summary(),
        player.get_recipe_summary()
    ]
    start_button.text = "再来一局"
    start_button.visible = true
    return_button.visible = true
    mute_button.visible = true
    overlay_hint.text = "Enter / R：新一局"

func _update_run_localized(player, elapsed: float, wave: int, enemies: int, boss_active: bool, boss_time: float, boss_health_ratio := -1.0) -> void:
    var character_id := str(player.get("character_id"))
    var data := _localized_character_data(character_id)
    var hp := ""
    var max_hp := int(player.get("max_health"))
    var cur_hp := int(player.get("health"))
    for i in range(max_hp):
        hp += "#" if i < cur_hp else "-"
    stats_label.text = "%s[%s/%s/%s]  生命[%s]  护盾:%d  等级:%d  金币:%03d  分数:%05d" % [
        data.get("name", character_id),
        data.get("role", "英雄"),
        data.get("damage_type", "混合"),
        data.get("range_type", "远程"),
        hp,
        int(player.get("shield")),
        int(player.get("level")),
        int(player.get("gold")),
        int(player.get("score"))
    ]
    var boss_text := "  |  虚空 Boss 已登场" if boss_active else "  |  Boss %.0f 秒" % maxf(0.0, boss_time)
    wave_label.text = "时间 %s  |  波次 %02d  |  敌人 %02d%s" % [_format_time(elapsed), wave, enemies, boss_text]
    if boss_active and boss_health_ratio >= 0.0:
        wave_label.text = "时间 %s  |  波次 %02d  |  敌人 %02d  |  虚空 Boss 生命 %.0f%%" % [_format_time(elapsed), wave, enemies, boss_health_ratio * 100.0]
    var upgrade_total := 0
    var inventory = player.get("inventory")
    if inventory is Dictionary:
        for key in inventory.keys():
            upgrade_total += int(inventory[key])
    var augment_count := 0
    if player.has_method("get_hextech_augment_ids"):
        augment_count = player.get_hextech_augment_ids().size()
    weapon_label.text = "伤害:%d  冷却:%.2fs  侧射:%d  范围:%d  飞环:%d  升级:%d  海克斯:%d" % [
        int(player.get("damage")),
        float(player.get("attack_cooldown")) * float(player.get("cooldown_mult")),
        int(player.get("lime_level")),
        int(player.get("aura_level")),
        int(player.get("orbit_count")),
        upgrade_total,
        augment_count
    ]
    if player.has_method("get_xp_fill"):
        xp_fill.size = Vector2(XP_WIDTH * player.get_xp_fill(), 8)

func _show_title_localized(selected_character: String) -> void:
    _show_overlay(false)
    _hide_choice_buttons()
    _localize_static_controls()
    overlay_title.text = "海克斯虚空大乱斗"
    overlay_body.text = ""
    var ids := ["jinx", "senna", "samira", "viktor", "xayah", "mordekaiser", "teemo", "aurelion_sol"]
    for i in range(ids.size()):
        var card_id := str(ids[i])
        var data := _localized_character_data(card_id)
        var selected := card_id == selected_character
        var title := "%d. %s | %s | %s%s" % [
            i + 1,
            data.get("name", card_id),
            data.get("range_type", "远程"),
            data.get("role", "英雄"),
            "  已选" if selected else ""
        ]
        _set_choice_card(i, _hero_choice_position(i), HERO_CARD_SIZE, title, str(data.get("desc", "")), data.get("color", Color.WHITE), selected, "已选" if selected else str(data.get("badge", "英雄")))
        _set_character_card_portrait(i, card_id, selected)
    _hide_unused_choice_cards(ids.size())
    start_button.text = "开始游戏"
    start_button.visible = true
    mute_button.visible = true
    overlay_hint.text = "点击英雄后点开始，或按 1-8 选择、Enter/R 开始。当前：%s" % _localized_character_data(selected_character).get("name", selected_character)

func _show_pause_localized() -> void:
    _show_overlay()
    _hide_choice_buttons()
    overlay_title.text = "已暂停"
    overlay_body.text = "战斗已暂停。可以调整音效，或返回选人重新选择英雄。"
    mute_button.visible = true
    return_button.visible = true
    overlay_hint.text = "P / Enter / Esc：继续   R：重新开始"

func _show_upgrade_choices_localized(options: Array) -> void:
    current_choices = options
    _show_overlay(false)
    _hide_choice_buttons()
    overlay_title.text = "选择升级"
    overlay_body.text = ""
    for i in range(options.size()):
        var option: Dictionary = options[i]
        var display := _localized_upgrade_option(option)
        _set_choice_card(i, _option_choice_position(i), OPTION_CARD_SIZE, "%d. %s" % [i + 1, display.get("name", "升级")], str(display.get("desc", "")), display.get("color", Color(0.82, 0.92, 1.0)), bool(option.get("recommended", false)), str(display.get("badge", "升级")))
    _hide_unused_choice_cards(options.size())
    return_button.visible = true
    mute_button.visible = true
    overlay_hint.text = "点击卡片或按 1 / 2 / 3 选择。卡片会显示升级路线和效果。"

func _show_fate_choices_localized(options: Array) -> void:
    current_choices = options
    _show_overlay(false)
    _hide_choice_buttons()
    overlay_title.text = "选择本局命运"
    overlay_body.text = ""
    for i in range(options.size()):
        var option: Dictionary = options[i]
        var display := _localized_fate_option(option)
        _set_choice_card(i, _option_choice_position(i), OPTION_CARD_SIZE, "%d. %s" % [i + 1, display.get("name", "命运")], str(display.get("desc", "")), display.get("color", Color(0.82, 0.54, 1.0)), false, "本局命运")
    _hide_unused_choice_cards(options.size())
    return_button.visible = true
    mute_button.visible = true
    overlay_hint.text = "每局开局先选方向。点击卡片或按 1 / 2 / 3。"

func _show_hextech_choices_localized(options: Array) -> void:
    current_choices = options
    _show_overlay(false)
    _hide_choice_buttons()
    overlay_title.text = "海克斯强化"
    overlay_body.text = ""
    for i in range(options.size()):
        var option: Dictionary = options[i]
        var display := _localized_hextech_option(option)
        var tier_id := str(option.get("tier", display.get("tier", "silver")))
        var tier_label := str(display.get("tier_label", _localized_tier_label(tier_id)))
        _set_choice_card(i, _option_choice_position(i), OPTION_CARD_SIZE, "%d. [%s] %s" % [i + 1, tier_label, display.get("name", "强化")], str(display.get("desc", "")), display.get("color", Color(0.82, 0.54, 1.0)), bool(option.get("recommended", false)), str(display.get("badge", tier_label)))
    _hide_unused_choice_cards(options.size())
    return_button.visible = true
    mute_button.visible = true
    overlay_hint.text = "海克斯会整局生效。点击卡片或按 1 / 2 / 3 锻造。"

func _show_shop_choices_localized(options: Array, gold: int) -> void:
    current_choices = options
    _show_overlay(false)
    _hide_choice_buttons()
    _layout_shop_overlay_controls()
    overlay_title.text = "海克斯装备商店   金币：%d" % gold
    overlay_body.text = ""
    for i in range(options.size()):
        if i < choice_buttons.size():
            _set_shop_card(i, _shop_choice_position(i), SHOP_CARD_SIZE, _localized_shop_option(options[i]), gold)
    _hide_unused_choice_cards(mini(options.size(), choice_buttons.size()))
    shop_close_button.text = "离开商店"
    shop_close_button.visible = true
    mute_button.visible = true
    return_button.visible = true
    overlay_hint.text = "点击商品可连续购买。图标代表装备类型，路线条越亮越适合当前英雄；离开商店后继续战斗。"

func _show_summary_localized(won: bool, player, elapsed: float) -> void:
    _show_overlay()
    _hide_choice_buttons()
    var character_id := str(player.get("character_id"))
    var data := _localized_character_data(character_id)
    overlay_title.text = "虚空 Boss 已击败" if won else "本局结束"
    var result := "你在虚空弹幕里活了下来，并击败了最后的 Boss。" if won else "这局倒下了。下一把可以换英雄、命运或路线。"
    overlay_body.text = "%s\n\n英雄：%s - %s\n时间：%s\n等级：%d\n分数：%05d\n升级：%s\n装备：%s\n海克斯：%s\n联动：%s" % [
        result,
        data.get("name", character_id),
        data.get("title", ""),
        _format_time(elapsed),
        int(player.get("level")),
        int(player.get("score")),
        _localized_upgrade_summary(player),
        _localized_item_summary(player),
        _localized_hextech_summary(player),
        _localized_recipe_summary(player)
    ]
    start_button.text = "再来一局"
    start_button.visible = true
    return_button.visible = true
    mute_button.visible = true
    overlay_hint.text = "Enter / R：新一局"

func _localized_character_data(character_id: String) -> Dictionary:
    match character_id:
        "senna":
            return {"name": "赛娜", "title": "赦除圣枪", "role": "支援射手", "damage_type": "混合", "range_type": "远程", "badge": "支援/穿透", "desc": "长距离穿透与灵魂成长，偏支援、穿透、保命。", "color": Color(0.55, 1.0, 0.78)}
        "samira":
            return {"name": "莎弥拉", "title": "连招评分", "role": "近战射手", "damage_type": "物理", "range_type": "近战", "badge": "近战/连招", "desc": "贴脸双枪和评分爆发，偏攻速、吸血、近战路线。", "color": Color(1.0, 0.62, 0.22)}
        "viktor":
            return {"name": "维克托", "title": "光荣进化", "role": "控制法师", "damage_type": "魔法", "range_type": "远程", "badge": "法师/激光", "desc": "高穿透激光与重力场，偏技能强度和急速。", "color": Color(0.72, 0.94, 1.0)}
        "xayah":
            return {"name": "霞", "title": "羽刃回收", "role": "羽刃射手", "damage_type": "物理", "range_type": "远程", "badge": "射手/羽刃", "desc": "羽毛前后夹击，吃穿透、弹链和暴击路线。", "color": Color(1.0, 0.34, 0.62)}
        "mordekaiser":
            return {"name": "莫德凯撒", "title": "铁铠冥魂", "role": "近战坦克", "damage_type": "魔法", "range_type": "近战", "badge": "坦克/近战", "desc": "近身锤击和暗域脉冲，偏坦度、范围、护盾。", "color": Color(0.58, 1.0, 0.58)}
        "teemo":
            return {"name": "提莫", "title": "斥候陷阱", "role": "召唤陷阱", "damage_type": "魔法", "range_type": "远程", "badge": "召唤/毒", "desc": "毒镖风筝与蘑菇陷阱，偏召唤、持续区域控制。", "color": Color(0.70, 1.0, 0.22)}
        "aurelion_sol":
            return {"name": "奥瑞利安·索尔", "title": "星轨黑洞", "role": "星界法师", "damage_type": "魔法", "range_type": "远程", "badge": "法师/星轨", "desc": "星体环绕和黑洞爆发，偏魔法、召唤、后期成长。", "color": Color(0.92, 0.72, 1.0)}
        _:
            return {"name": "金克丝", "title": "枪炮交响", "role": "远程射手", "damage_type": "物理", "range_type": "远程", "badge": "射手/物理", "desc": "火箭弹幕和烟花溅射，吃暴击、弹速、飓风。", "color": Color(1.0, 0.30, 0.62)}

func _localized_upgrade_option(option: Dictionary) -> Dictionary:
    var id := str(option.get("id", ""))
    var data := _localized_upgrade_catalog(id)
    data["color"] = option.get("color", data.get("color", Color(0.82, 0.92, 1.0)))
    return data

func _localized_upgrade_catalog(id: String) -> Dictionary:
    match id:
        "physical_hex":
            return {"name": "物理海克斯：破甲弹仓", "desc": "伤害、穿透和暴击提高，适合射手和物理近战。", "badge": "物理", "color": Color(1.0, 0.58, 0.22)}
        "magic_hex":
            return {"name": "魔法海克斯：符文过载", "desc": "技能威力和弹体体积提高，后续可增强范围脉冲。", "badge": "魔法", "color": Color(0.66, 0.48, 1.0)}
        "tank_hex":
            return {"name": "坦克海克斯：巨像核心", "desc": "最大生命和护盾提高，适合近战抗压。", "badge": "坦克", "color": Color(0.52, 0.90, 0.72)}
        "summon_hex":
            return {"name": "召唤海克斯：自动工坊", "desc": "增加环绕单位和技能威力，适合陷阱/召唤流。", "badge": "召唤", "color": Color(0.58, 0.92, 1.0)}
        "melee_hex":
            return {"name": "近战海克斯：贴脸开团", "desc": "范围脉冲、护盾和移速提高。", "badge": "近战", "color": Color(1.0, 0.34, 0.30)}
        "marksman_hex":
            return {"name": "射手海克斯：风暴弹链", "desc": "侧射、攻速和弹速提高。", "badge": "射手", "color": Color(1.0, 0.86, 0.25)}
        "support_hex":
            return {"name": "支援海克斯：灵魂补给", "desc": "护盾、生命和回复提高，适合稳扎稳打。", "badge": "支援", "color": Color(0.62, 1.0, 0.78)}
        "jinx_rockets":
            return {"name": "金克丝：鱼骨头营火", "desc": "火箭出现更频繁，爆炸半径和伤害提高。", "badge": "专属", "color": Color(1.0, 0.28, 0.64)}
        "jinx_fireworks":
            return {"name": "金克丝：烟花别回头", "desc": "火箭追加散射烟花，击杀后周期触发大火箭。", "badge": "专属", "color": Color(1.0, 0.72, 0.18)}
        "jinx_zoomies":
            return {"name": "金克丝：罪恶快感续杯", "desc": "击杀后的加速更久，攻速更快。", "badge": "专属", "color": Color(0.42, 0.82, 1.0)}
        "senna_souls":
            return {"name": "赛娜：灵魂收款码", "desc": "更容易收集灵魂，穿透提高。", "badge": "专属", "color": Color(0.55, 1.0, 0.78)}
        "senna_absolution":
            return {"name": "赛娜：全场赦除", "desc": "周期护盾/治疗更强，并发射束缚射线。", "badge": "专属", "color": Color(0.75, 1.0, 0.88)}
        "senna_laser":
            return {"name": "赛娜：大枪不讲理", "desc": "圣枪主射线更粗更穿透，后续追加束缚射线。", "badge": "专属", "color": Color(0.66, 1.0, 0.86)}
        "samira_combo":
            return {"name": "莎弥拉：S 级表演", "desc": "评分更快，暴击和攻速提高。", "badge": "专属", "color": Color(1.0, 0.62, 0.22)}
        "samira_inferno":
            return {"name": "莎弥拉：炼狱扳机", "desc": "贴脸刀舞和满评分环形爆发范围提高。", "badge": "专属", "color": Color(1.0, 0.22, 0.16)}
        "samira_daredevil":
            return {"name": "莎弥拉：悍勇本色", "desc": "半血以下更耐打，贴脸连招能获得护盾。", "badge": "专属", "color": Color(1.0, 0.42, 0.32)}
        "viktor_laser":
            return {"name": "维克托：直线真理", "desc": "激光伤害和穿透提高。", "badge": "专属", "color": Color(0.72, 0.94, 1.0)}
        "viktor_storm":
            return {"name": "维克托：重力场罚站", "desc": "周期生成重力场，持续减速并拉扯敌群。", "badge": "专属", "color": Color(0.60, 0.68, 1.0)}
        "viktor_hexcore":
            return {"name": "维克托：光荣进化", "desc": "技能威力提高，射线更快，重力场更频繁。", "badge": "专属", "color": Color(0.92, 0.72, 1.0)}
        "xayah_feathers":
            return {"name": "霞：羽毛库存爆仓", "desc": "普攻留下更多羽毛，羽刃伤害和穿透提高。", "badge": "专属", "color": Color(1.0, 0.34, 0.62)}
        "xayah_recall":
            return {"name": "霞：倒钩回收", "desc": "羽毛会周期穿回身边，形成后撤反打线。", "badge": "专属", "color": Color(0.92, 0.28, 1.0)}
        "xayah_root":
            return {"name": "霞：羽毛排队扎人", "desc": "回收羽毛会定身敌人，并追加身边控制脉冲。", "badge": "专属", "color": Color(1.0, 0.54, 0.72)}
        "morde_darkness":
            return {"name": "莫德凯撒：黑暗起兮", "desc": "强化大锤近战范围，数次锤击后爆出暗域伤害。", "badge": "专属", "color": Color(0.58, 1.0, 0.58)}
        "morde_realm":
            return {"name": "莫德凯撒：死亡领域", "desc": "周期生成领域，削弱敌人并给铁男护盾收益。", "badge": "专属", "color": Color(0.40, 1.0, 0.45)}
        "morde_iron":
            return {"name": "莫德凯撒：铁皮更厚", "desc": "最大生命和护盾提高。", "badge": "专属", "color": Color(0.34, 0.62, 0.42)}
        "teemo_poison":
            return {"name": "提莫：毒镖加料", "desc": "毒镖附加持续毒伤，毒性弹道更频繁。", "badge": "专属", "color": Color(0.70, 1.0, 0.22)}
        "teemo_shrooms":
            return {"name": "提莫：蘑菇摊扩张", "desc": "定时布置实体蘑菇，踩中后生成毒云。", "badge": "专属", "color": Color(0.52, 1.0, 0.22)}
        "teemo_blind":
            return {"name": "提莫：致盲吹箭", "desc": "周期发射致盲吹箭，削弱敌人接触伤害。", "badge": "专属", "color": Color(0.92, 0.84, 0.22)}
        "asol_stars":
            return {"name": "龙王：星轨加班", "desc": "增加环绕星体，星轨半径和伤害随星尘成长。", "badge": "专属", "color": Color(0.46, 0.82, 1.0)}
        "asol_singularity":
            return {"name": "龙王：星芒凝聚", "desc": "周期生成黑洞，吸引、减速并伤害敌群。", "badge": "专属", "color": Color(0.64, 0.34, 1.0)}
        "asol_comet":
            return {"name": "龙王：星天落瀑", "desc": "周期发射重型彗星，星尘越多威力越高。", "badge": "专属", "color": Color(1.0, 0.88, 0.42)}
        "mint_leaf":
            return {"name": "灵巧靴垫", "desc": "移动速度和拾取范围提高。", "badge": "机动", "color": Color(0.28, 1.0, 0.48)}
        "ice_cube":
            return {"name": "多兰护盾贴纸", "desc": "获得护盾，多次选择会提高最大生命。", "badge": "防御", "color": Color(0.72, 0.96, 1.0)}
        "cinnamon_stick":
            return {"name": "暴风大剑碎片", "desc": "基础伤害提高。", "badge": "伤害", "color": Color(0.92, 0.42, 0.20)}
        "lime_zest":
            return {"name": "卢安娜小风扇", "desc": "增加额外侧射弹道。", "badge": "弹链", "color": Color(0.78, 1.0, 0.16)}
        "almond_syrup":
            return {"name": "攻速小瓶", "desc": "自动攻击冷却降低。", "badge": "攻速", "color": Color(0.93, 0.78, 0.52)}
        "bubble_water":
            return {"name": "纳什之牙飞环", "desc": "增加环绕飞环，近身持续伤害。", "badge": "召唤", "color": Color(0.45, 0.78, 1.0)}
        "ember_spark":
            return {"name": "日炎余烬", "desc": "强化近身范围脉冲。", "badge": "范围", "color": Color(1.0, 0.27, 0.08)}
        "honey_drop":
            return {"name": "治疗宝珠", "desc": "最大生命提高，并回复生命。", "badge": "回复", "color": Color(1.0, 0.72, 0.18)}
        "tonic_splash":
            return {"name": "技能急速核心", "desc": "提高特殊技能威力，并让弹体稍微变大。", "badge": "技能", "color": Color(0.62, 0.88, 1.0)}
        "glass_rim":
            return {"name": "穿甲杯沿", "desc": "主弹体额外穿透敌人。", "badge": "穿透", "color": Color(0.70, 0.95, 1.0)}
        "star_anise":
            return {"name": "暴击星星", "desc": "暴击率提高。", "badge": "暴击", "color": Color(1.0, 0.72, 0.25)}
        "mystery_spice":
            return {"name": "随机英雄梦", "desc": "随机获得两个基础或英雄升级。", "badge": "随机", "color": Color(0.92, 0.56, 1.0)}
        _:
            return {"name": id if id != "" else "升级", "desc": "提高本局战斗能力。", "badge": "升级", "color": Color(0.82, 0.92, 1.0)}

func _localized_hextech_option(option: Dictionary) -> Dictionary:
    var id := str(option.get("id", ""))
    var data := _localized_hextech_catalog(id)
    data["color"] = option.get("color", data.get("color", Color(0.82, 0.54, 1.0)))
    data["tier_label"] = option.get("tier_label", data.get("tier_label", _localized_tier_label(str(option.get("tier", data.get("tier", "silver"))))))
    return data

func _localized_hextech_catalog(id: String) -> Dictionary:
    match id:
        "swift_steps":
            return {"name": "迅捷步伐", "desc": "移动速度 +15%。", "badge": "白银", "tier": "silver"}
        "sturdy_shell":
            return {"name": "坚硬杯壳", "desc": "最大生命 +2，并立刻回复 2 点生命。", "badge": "白银", "tier": "silver"}
        "lucky_find":
            return {"name": "好运冒泡", "desc": "暴击率 +10%，金币掉落率小幅提高。", "badge": "白银", "tier": "silver"}
        "hextech_shield":
            return {"name": "海克斯护盾", "desc": "立刻获得 2 层护盾。", "badge": "白银", "tier": "silver"}
        "quick_hands":
            return {"name": "快手调酒", "desc": "自动攻击冷却 -15%。", "badge": "白银", "tier": "silver"}
        "minty_breeze":
            return {"name": "薄荷清风", "desc": "拾取范围大幅提高，移动速度小幅提高。", "badge": "白银", "tier": "silver"}
        "crystal_pocket":
            return {"name": "水晶口袋", "desc": "立刻获得 20 金币和 1 层护盾。", "badge": "白银", "tier": "silver"}
        "overflowing_cup":
            return {"name": "满杯溢出", "desc": "伤害 +1，护盾 +1。", "badge": "黄金", "tier": "gold"}
        "echo_strike":
            return {"name": "回响打击", "desc": "每 3 次主攻击额外发射一次回响弹。", "badge": "黄金", "tier": "gold"}
        "vampiric_spoon":
            return {"name": "吸血汤勺", "desc": "击败精英时回复 2 点生命。", "badge": "黄金", "tier": "gold"}
        "crystal_armor":
            return {"name": "水晶甲胄", "desc": "每次受到生命伤害时减免 1 点。", "badge": "黄金", "tier": "gold"}
        "frostfire_combo":
            return {"name": "霜火爆裂", "desc": "主攻击有概率附加额外霜火伤害。", "badge": "黄金", "tier": "gold"}
        "alchemist_touch":
            return {"name": "炼金触媒", "desc": "金币收益 +30%。", "badge": "黄金", "tier": "gold"}
        "chain_lightning":
            return {"name": "连锁闪电", "desc": "主弹体命中时有机会向附近敌人跳电。", "badge": "黄金", "tier": "gold"}
        "elite_hunter":
            return {"name": "精英猎手", "desc": "精英掉落更多奖励，基础伤害 +1。", "badge": "黄金", "tier": "gold"}
        "golden_ticket":
            return {"name": "黄金购物券", "desc": "商店价格降低，金币收益小幅提高。", "badge": "黄金", "tier": "gold"}
        "orbital_laser":
            return {"name": "轨道调酒光束", "desc": "立刻获得一层火圈，并提高特殊技能威力。", "badge": "黄金", "tier": "gold"}
        "cheat_death":
            return {"name": "死里逃生", "desc": "每局一次，致命伤害会保留 1 点生命并短暂无敌。", "badge": "棱彩", "tier": "prismatic"}
        "double_edged":
            return {"name": "双刃鸡尾酒", "desc": "造成 2 倍伤害，但受到的生命伤害提高。", "badge": "棱彩", "tier": "prismatic"}
        "rolling_pin":
            return {"name": "擀面杖冲刺", "desc": "主弹体更大，并额外穿透 2 个敌人。", "badge": "棱彩", "tier": "prismatic"}
        "prismatic_body":
            return {"name": "棱彩之躯", "desc": "受击后的无敌时间更长，并获得 4 层护盾。", "badge": "棱彩", "tier": "prismatic"}
        "treasure_sense":
            return {"name": "寻宝感知", "desc": "金币掉落率和金币数量提高。", "badge": "棱彩", "tier": "prismatic"}
        "mayhem_overdrive":
            return {"name": "乱斗过载", "desc": "攻击冷却大幅降低，弹体速度提高，但更依赖走位。", "badge": "棱彩", "tier": "prismatic"}
        _:
            return {"name": id if id != "" else "海克斯强化", "desc": "整局生效的强化。", "badge": "海克斯", "tier": "silver"}

func _localized_fate_option(option: Dictionary) -> Dictionary:
    match str(option.get("id", "")):
        "prismatic_party":
            return {"name": "棱彩乱斗局", "desc": "开局获得乱斗过载和一项随机英雄专属升级，但敌人压力更早抬头。", "color": Color(1.0, 0.38, 0.82)}
        "elite_contract":
            return {"name": "虚空悬赏令", "desc": "开局获得精英猎手，精英更早出现，击败后掉落更多奖励。", "color": Color(0.82, 0.54, 1.0)}
        "market_day":
            return {"name": "海克斯购物节", "desc": "开局金币 +60，商店更早出现，并获得购物折扣。", "color": Color(1.0, 0.78, 0.22)}
        "swarm_alarm":
            return {"name": "虚空虫潮", "desc": "敌人更多，但经验和金币掉落更好，适合快速成型。", "color": Color(0.78, 0.22, 1.0)}
        "starfall":
            return {"name": "星界坠落", "desc": "开局获得轨道光束和一层飞环，技能流更容易启动。", "color": Color(0.56, 0.82, 1.0)}
        "signature_draft":
            return {"name": "专属训练赛", "desc": "本局升级池更偏向当前英雄专属技能，开局立刻获得一项专属升级。", "color": Color(0.82, 0.92, 1.0)}
        "black_market":
            return {"name": "地下装备局", "desc": "商店更早出现，当前英雄路线装备获得额外折扣。", "color": Color(1.0, 0.66, 0.24)}
        "unstable_forge":
            return {"name": "不稳定海克斯炉", "desc": "海克斯锻造品质提前一档，但敌人压力和奖励都会提高。", "color": Color(0.92, 0.42, 1.0)}
        "void_rivalry":
            return {"name": "虚空宿敌悬赏", "desc": "精英更早出现，首个精英必定携带宝藏特质，击败精英收益更高。", "color": Color(0.72, 0.42, 1.0)}
        _:
            return {"name": str(option.get("name", "本局命运")), "desc": str(option.get("desc", "")), "color": Color(0.82, 0.54, 1.0)}

func _localized_shop_option(option: Dictionary) -> Dictionary:
    var id := str(option.get("id", option.get("item", "")))
    var data := _localized_shop_catalog(id)
    var result := option.duplicate()
    result["name"] = data.get("name", option.get("name", id))
    result["desc"] = data.get("desc", option.get("desc", ""))
    result["badge"] = _shop_route_badge_clean(option.get("tags", []), int(option.get("route_score", 0)))
    return result

func _localized_shop_catalog(id: String) -> Dictionary:
    match id:
        "infinity_edge":
            return {"name": "无尽之刃", "desc": "伤害和暴击提高。"}
        "statikk_shiv":
            return {"name": "斯塔缇克电刃", "desc": "获得连锁闪电，弹体速度提高。"}
        "bloodthirster":
            return {"name": "饮血剑", "desc": "精英战后回复生命，最大生命提高。"}
        "nashors_tooth":
            return {"name": "纳什之牙", "desc": "攻击冷却降低，技能威力提高。"}
        "rabadons_hat":
            return {"name": "灭世者的帽子", "desc": "特殊技能威力大幅提高。"}
        "randuins_omen":
            return {"name": "兰顿之兆", "desc": "最大生命和护盾提高。"}
        "runaans_hurricane":
            return {"name": "卢安娜的飓风", "desc": "额外弹道和穿透提高。"}
        "zhonyas_hourglass":
            return {"name": "中娅沙漏", "desc": "获得一次死里逃生和护盾。"}
        "black_cleaver":
            return {"name": "黑色切割者", "desc": "伤害和穿透提高。"}
        "guardian_angel":
            return {"name": "守护天使", "desc": "获得一次死里逃生。"}
        "future_market":
            return {"name": "未来市场", "desc": "立刻获得金币，金币收益和商店折扣提高。"}
        "warmogs_armor":
            return {"name": "狂徒铠甲", "desc": "最大生命大量提高并回复。"}
        "liandrys":
            return {"name": "兰德里的折磨", "desc": "技能威力提高，范围/陷阱流更强。"}
        "zekes":
            return {"name": "基克的聚合", "desc": "护盾与支援能力提高。"}
        "titanic":
            return {"name": "巨型九头蛇", "desc": "近战范围和坦度提高。"}
        "shield_pack":
            return {"name": "海克斯护盾包", "desc": "立刻获得 4 层护盾。"}
        "hextech_cache":
            return {"name": "海克斯强化盲盒", "desc": "随机获得一项白银海克斯强化。"}
        "mystery_spice":
            return {"name": "随机英雄梦", "desc": "随机获得两个升级。"}
        _:
            return {"name": id if id != "" else "商品", "desc": "当前路线可用的商品。"}

func _localized_tier_label(tier: String) -> String:
    match tier:
        "gold":
            return "黄金"
        "prismatic":
            return "棱彩"
        _:
            return "白银"

func _shop_route_badge_clean(tags: Array, recommend_score: int) -> String:
    var label := "装备"
    if tags.has("marksman"):
        label = "射手"
    elif tags.has("magic"):
        label = "法系"
    elif tags.has("tank"):
        label = "坦克"
    elif tags.has("melee"):
        label = "近战"
    elif tags.has("summon"):
        label = "召唤"
    elif tags.has("support"):
        label = "支援"
    elif tags.has("physical"):
        label = "物理"
    if recommend_score >= 2:
        return "%s+%d" % [label, recommend_score]
    return label

func _localized_upgrade_summary(player) -> String:
    var inventory = player.get("inventory")
    if not (inventory is Dictionary) or inventory.is_empty():
        return "无"
    var parts := []
    for key in inventory.keys():
        var id := str(key)
        parts.append("%s x%d" % [_localized_upgrade_catalog(id).get("name", id), int(inventory[key])])
    parts.sort()
    return _join_display_parts(parts)

func _localized_item_summary(player) -> String:
    var items = player.get("league_items")
    if not (items is Dictionary) or items.is_empty():
        return "无"
    var parts := []
    for key in items.keys():
        var id := str(key)
        parts.append("%s x%d" % [_localized_shop_catalog(id).get("name", id), int(items[key])])
    parts.sort()
    return _join_display_parts(parts)

func _localized_hextech_summary(player) -> String:
    var augments = player.get("hextech_augments")
    if not (augments is Dictionary) or augments.is_empty():
        return "无"
    var parts := []
    for key in augments.keys():
        var id := str(key)
        parts.append(str(_localized_hextech_catalog(id).get("name", id)))
    parts.sort()
    return _join_display_parts(parts)

func _localized_recipe_summary(player) -> String:
    var recipes = player.get("recipe_synergies")
    if not (recipes is Dictionary) or recipes.is_empty():
        return "无"
    var parts := []
    for key in recipes.keys():
        parts.append(str(key))
    parts.sort()
    return _join_display_parts(parts)

func _join_display_parts(parts: Array) -> String:
    if parts.is_empty():
        return "无"
    var text := ""
    for i in range(parts.size()):
        if i > 0:
            text += "，"
        text += str(parts[i])
    return text

func hide_overlay() -> void:
    overlay_rect.visible = false
    _set_overlay_frame_visible(false)
    overlay_title.visible = false
    overlay_body.visible = false
    overlay_hint.visible = false
    _hide_choice_buttons()

func _show_overlay(show_body := true) -> void:
    _layout_overlay_controls_default()
    overlay_rect.visible = true
    _set_overlay_frame_visible(true)
    overlay_title.visible = true
    overlay_body.visible = show_body
    overlay_hint.visible = true

func _format_time(value: float) -> String:
    var seconds := int(value)
    return "%02d:%02d" % [int(seconds / 60), seconds % 60]

func _character_label(character_id: String) -> String:
    match character_id:
        "senna":
            return "赛娜"
        "samira":
            return "莎弥拉"
        "viktor":
            return "维克托"
        "xayah":
            return "霞"
        "mordekaiser":
            return "莫德凯撒"
        "teemo":
            return "提莫"
        "aurelion_sol":
            return "奥瑞利安·索尔"
        _:
            return "金克丝"

func _character_route_badge(character_id: String) -> String:
    match character_id:
        "jinx":
            return "射手/物理"
        "senna":
            return "支援/穿透"
        "samira":
            return "近战/连招"
        "viktor":
            return "法师/激光"
        "xayah":
            return "射手/羽刃"
        "mordekaiser":
            return "坦克/近战"
        "teemo":
            return "召唤/毒"
        "aurelion_sol":
            return "法师/星轨"
        _:
            return "英雄"
