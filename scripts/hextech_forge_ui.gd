extends CanvasLayer
class_name CinnaForgeUI

signal augment_chosen(augment_id: String)

const AugmentData := preload("res://scripts/hextech_augment_data.gd")

const FORGE_ICON_ATLAS_TEXTURE_PATH := "res://art/textures/hextech_void_vfx_decal_atlas_v1.png"
const FORGE_OVERLAY_RECT := Rect2(300, 86, 680, 548)
const FORGE_CARD_SIZE := Vector2(612, 92)
const FORGE_CARD_START := Vector2(334, 186)
const FORGE_CARD_STEP_Y := 112.0
const FORGE_MEDIA_SLOT := Rect2(56, 18, 56, 56)
const FORGE_MEDIA_PADDING := 5.0
const FORGE_TEXT_X := 132.0
const FORGE_ATLAS_INSET := 8.0

const TIER_TEXT := {
    "silver": {"label": "白银", "ui_label": "白银海克斯", "color": Color(0.76, 0.80, 0.84)},
    "gold": {"label": "黄金", "ui_label": "黄金海克斯", "color": Color(1.0, 0.82, 0.14)},
    "prismatic": {"label": "棱彩", "ui_label": "棱彩海克斯", "color": Color(1.0, 0.38, 0.82)}
}

const AUGMENT_TEXT := {
    "swift_steps": {"name": "迅捷步伐", "desc": "移动速度提高，适合风筝和躲弹幕。"},
    "sturdy_shell": {"name": "坚硬杯壳", "desc": "最大生命提高，并立即回复生命。"},
    "lucky_find": {"name": "好运冒泡", "desc": "暴击率和金币掉落率提高。"},
    "hextech_shield": {"name": "海克斯护盾", "desc": "立即获得护盾，给高压房间留容错。"},
    "quick_hands": {"name": "快手调酒", "desc": "自动攻击冷却降低，输出节奏更快。"},
    "minty_breeze": {"name": "薄荷清风", "desc": "拾取范围和移动速度提高。"},
    "crystal_pocket": {"name": "水晶口袋", "desc": "立即获得金币和护盾。"},
    "overflowing_cup": {"name": "满杯溢出", "desc": "伤害和护盾提高。"},
    "echo_strike": {"name": "回响打击", "desc": "每隔数次主攻击追加回响弹。"},
    "vampiric_spoon": {"name": "吸血汤勺", "desc": "击败精英时回复生命。"},
    "crystal_armor": {"name": "水晶甲胄", "desc": "受到生命伤害时减免部分伤害。"},
    "frostfire_combo": {"name": "霜火爆裂", "desc": "主攻击有概率附加额外霜火伤害。"},
    "alchemist_touch": {"name": "炼金触媒", "desc": "金币收益提高。"},
    "chain_lightning": {"name": "连锁闪电", "desc": "主弹体命中时有机会跳电。"},
    "elite_hunter": {"name": "精英猎手", "desc": "精英怪奖励提高，基础伤害提高。"},
    "golden_ticket": {"name": "黄金购物券", "desc": "商店折扣，并提高金币收益。"},
    "orbital_laser": {"name": "轨道光束", "desc": "获得火圈，并提高特殊武器威力。"},
    "cheat_death": {"name": "死里逃生", "desc": "每局一次，致命伤害会保留生命并短暂无敌。"},
    "double_edged": {"name": "双刃鸡尾酒", "desc": "造成双倍伤害，但受到的生命伤害提高。"},
    "rolling_pin": {"name": "擀面杖冲刺", "desc": "主弹体更大，并额外穿透敌人。"},
    "prismatic_body": {"name": "棱彩之躯", "desc": "受伤后的无敌时间更长，并获得护盾。"},
    "treasure_sense": {"name": "寻宝嗅觉", "desc": "金币掉落率和掉落数量提高。"},
    "mayhem_overdrive": {"name": "乱斗过载", "desc": "攻击冷却大幅降低，弹体速度提高。"}
}

var overlay: ColorRect
var title_label: Label
var cards: Array = []
var card_buttons: Array = []
var card_frames: Array = []
var card_labels: Array = []
var card_icon_backs: Array = []
var card_icon_images: Array = []
var card_names: Array = []
var card_descs: Array = []
var card_tiers: Array = []
var hint_label: Label
var active := false
var current_options: Array = []
var icon_atlas_texture: Texture2D = null

func _ready() -> void:
    overlay = ColorRect.new()
    overlay.position = FORGE_OVERLAY_RECT.position
    overlay.size = FORGE_OVERLAY_RECT.size
    overlay.color = Color(0.025, 0.020, 0.040, 0.96)
    overlay.visible = false
    add_child(overlay)

    title_label = _make_label(FORGE_OVERLAY_RECT.position + Vector2(34, 32), Vector2(612, 46), 28, Color(0.82, 0.92, 1.0))
    title_label.text = "海克斯锻造炉"

    for i in range(3):
        _build_card(i)

    hint_label = _make_label(Vector2(334, 562), Vector2(612, 40), 18, Color(0.62, 1.0, 0.62))
    hint_label.text = "点击卡片或按 1 / 2 / 3 选择强化"
    hide_forge()

func _build_card(index: int) -> void:
    var card_pos := FORGE_CARD_START + Vector2(0, float(index) * FORGE_CARD_STEP_Y)
    var card := ColorRect.new()
    card.position = card_pos
    card.size = FORGE_CARD_SIZE
    card.color = Color(0.08, 0.06, 0.12, 0.94)
    card.visible = false
    add_child(card)
    cards.append(card)

    var parts := []
    for frame_index in range(6):
        var part := ColorRect.new()
        part.visible = false
        part.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(part)
        parts.append(part)
    card_frames.append(parts)

    var button := Button.new()
    button.position = card_pos
    button.size = FORGE_CARD_SIZE
    button.text = ""
    button.flat = true
    button.focus_mode = Control.FOCUS_NONE
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    button.visible = false
    button.pressed.connect(_choose_index.bind(index))
    add_child(button)
    card_buttons.append(button)

    var key_label := _make_label(card_pos + Vector2(14, 12), Vector2(28, 30), 24, Color(1.0, 0.90, 0.30))
    key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    key_label.text = str(index + 1)
    card_labels.append(key_label)

    var icon_back := ColorRect.new()
    icon_back.position = card_pos + FORGE_MEDIA_SLOT.position
    icon_back.size = FORGE_MEDIA_SLOT.size
    icon_back.color = Color(0.08, 0.10, 0.14, 0.88)
    icon_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
    icon_back.visible = false
    add_child(icon_back)
    card_icon_backs.append(icon_back)

    var icon_image := TextureRect.new()
    icon_image.position = icon_back.position + Vector2(FORGE_MEDIA_PADDING, FORGE_MEDIA_PADDING)
    icon_image.size = icon_back.size - Vector2(FORGE_MEDIA_PADDING * 2.0, FORGE_MEDIA_PADDING * 2.0)
    icon_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
    icon_image.visible = false
    add_child(icon_image)
    card_icon_images.append(icon_image)

    card_names.append(_make_label(card_pos + Vector2(FORGE_TEXT_X, 12), Vector2(346, 30), 20, Color(1.0, 0.92, 0.66)))
    var desc := _make_label(card_pos + Vector2(FORGE_TEXT_X, 44), Vector2(366, 38), 15, Color(0.88, 0.84, 0.74))
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    card_descs.append(desc)
    var tier := _make_label(card_pos + Vector2(500, 12), Vector2(94, 24), 13, Color(0.76, 0.76, 0.74))
    tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    card_tiers.append(tier)

func _make_label(pos: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.position = pos
    label.size = size
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color.BLACK)
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    label.clip_text = true
    label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    label.visible = false
    add_child(label)
    return label

func show_forge(options: Array) -> void:
    current_options = options.duplicate()
    active = true
    overlay.visible = true
    title_label.visible = true
    hint_label.visible = true
    for i in range(3):
        if i >= options.size():
            _set_card_visible(i, false)
            continue
        var augment_id := str(options[i])
        var tier := AugmentData.get_tier(augment_id)
        var tier_info := _tier_info(tier)
        var tier_color: Color = tier_info.get("color", Color.WHITE)
        var text := _augment_text(augment_id)
        _set_card_visible(i, true)
        _sync_card(i, augment_id, tier, tier_color, text, tier_info)

func hide_forge() -> void:
    active = false
    overlay.visible = false
    title_label.visible = false
    hint_label.visible = false
    for i in range(cards.size()):
        _set_card_visible(i, false)

func _set_card_visible(index: int, visible: bool) -> void:
    if index < 0 or index >= cards.size():
        return
    for group in [cards, card_buttons, card_labels, card_icon_backs, card_icon_images, card_names, card_descs, card_tiers]:
        var control := group[index] as Control
        if control != null:
            control.visible = visible
    for part in card_frames[index]:
        if is_instance_valid(part):
            part.visible = visible
    if not visible:
        _reset_card_state(index)

func _reset_card_state(index: int) -> void:
    if index < 0 or index >= cards.size():
        return
    for group in [cards, card_buttons, card_icon_backs, card_icon_images]:
        var control := group[index] as Control
        if control != null:
            _clear_layout_meta(control)
    for group in [card_labels, card_names, card_descs, card_tiers]:
        var label := group[index] as Label
        if label != null:
            label.text = ""
            _clear_layout_meta(label)
    if index < card_icon_images.size():
        var image := card_icon_images[index] as TextureRect
        if image != null:
            image.texture = null
            image.modulate = Color.WHITE
    for part in card_frames[index]:
        if is_instance_valid(part) and part is ColorRect:
            var rect := part as ColorRect
            rect.position = Vector2.ZERO
            rect.size = Vector2.ZERO

func _clear_layout_meta(node: Object) -> void:
    node.set_meta("forge_layout_profile", "inactive")
    node.set_meta("augment_id", "")
    node.set_meta("tier", "")
    node.set_meta("media_slot_rect", Rect2())
    node.set_meta("media_inner_rect", Rect2())
    node.set_meta("media_slot_center", Vector2.ZERO)
    node.set_meta("media_slot_padding", 0.0)
    node.set_meta("media_alignment_mode", "inactive")

func _sync_card(index: int, augment_id: String, tier: String, tier_color: Color, text: Dictionary, tier_info: Dictionary) -> void:
    var card_pos := FORGE_CARD_START + Vector2(0, float(index) * FORGE_CARD_STEP_Y)
    var slot_rect := Rect2(card_pos + FORGE_MEDIA_SLOT.position, FORGE_MEDIA_SLOT.size)
    var inner_rect := Rect2(
        slot_rect.position + Vector2(FORGE_MEDIA_PADDING, FORGE_MEDIA_PADDING),
        slot_rect.size - Vector2(FORGE_MEDIA_PADDING * 2.0, FORGE_MEDIA_PADDING * 2.0)
    )

    var card: ColorRect = cards[index]
    card.position = card_pos
    card.size = FORGE_CARD_SIZE
    card.color = Color(tier_color.r * 0.16, tier_color.g * 0.13, tier_color.b * 0.18, 0.92)
    _set_layout_meta(card, augment_id, tier, slot_rect, inner_rect)

    var button: Button = card_buttons[index]
    button.position = card_pos
    button.size = FORGE_CARD_SIZE
    _set_layout_meta(button, augment_id, tier, slot_rect, inner_rect)

    _sync_card_frame(index, card_pos, tier_color)

    var key_label: Label = card_labels[index]
    key_label.position = card_pos + Vector2(14, 12)
    key_label.size = Vector2(28, 30)
    key_label.text = str(index + 1)

    var icon_back: ColorRect = card_icon_backs[index]
    icon_back.position = slot_rect.position
    icon_back.size = slot_rect.size
    icon_back.color = Color(tier_color.r, tier_color.g, tier_color.b, 0.20)
    _set_layout_meta(icon_back, augment_id, tier, slot_rect, inner_rect)

    var icon_image: TextureRect = card_icon_images[index]
    icon_image.position = inner_rect.position
    icon_image.size = inner_rect.size
    icon_image.texture = _augment_icon_texture(augment_id, tier)
    icon_image.visible = icon_image.texture != null
    icon_image.modulate = Color(1.0, 1.0, 1.0, 0.94)
    _set_layout_meta(icon_image, augment_id, tier, slot_rect, inner_rect)

    var name_label: Label = card_names[index]
    name_label.position = card_pos + Vector2(FORGE_TEXT_X, 12)
    name_label.size = Vector2(346, 30)
    name_label.text = "[%s] %s" % [tier_info.get("label", tier), text.get("name", augment_id)]
    name_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.66))

    var desc_label: Label = card_descs[index]
    desc_label.position = card_pos + Vector2(FORGE_TEXT_X, 44)
    desc_label.size = Vector2(366, 38)
    desc_label.text = str(text.get("desc", "未知强化。"))

    var tier_label: Label = card_tiers[index]
    tier_label.position = card_pos + Vector2(500, 12)
    tier_label.size = Vector2(94, 24)
    tier_label.text = str(tier_info.get("ui_label", tier))
    tier_label.add_theme_color_override("font_color", tier_color.lightened(0.12))

func _set_layout_meta(node: Object, augment_id: String, tier: String, slot_rect: Rect2, inner_rect: Rect2) -> void:
    node.set_meta("forge_layout_profile", "hextech_forge_card")
    node.set_meta("augment_id", augment_id)
    node.set_meta("tier", tier)
    node.set_meta("media_slot_rect", slot_rect)
    node.set_meta("media_inner_rect", inner_rect)
    node.set_meta("media_slot_center", slot_rect.position + slot_rect.size * 0.5)
    node.set_meta("media_slot_padding", FORGE_MEDIA_PADDING)
    node.set_meta("media_alignment_mode", "aspect_centered")

func _sync_card_frame(index: int, card_pos: Vector2, tier_color: Color) -> void:
    var parts: Array = card_frames[index]
    if parts.size() < 6:
        return
    var bright := Color(tier_color.r, tier_color.g, tier_color.b, 0.58)
    var soft := Color(tier_color.r, tier_color.g, tier_color.b, 0.22)
    _set_frame_part(parts[0], card_pos + Vector2(4, 4), Vector2(42, 2), bright)
    _set_frame_part(parts[1], card_pos + Vector2(4, 4), Vector2(2, 42), bright)
    _set_frame_part(parts[2], card_pos + Vector2(FORGE_CARD_SIZE.x - 46, FORGE_CARD_SIZE.y - 6), Vector2(42, 2), bright)
    _set_frame_part(parts[3], card_pos + Vector2(FORGE_CARD_SIZE.x - 6, FORGE_CARD_SIZE.y - 46), Vector2(2, 42), bright)
    _set_frame_part(parts[4], card_pos + Vector2(132, FORGE_CARD_SIZE.y - 9), Vector2(360, 1), soft)
    _set_frame_part(parts[5], card_pos + Vector2(500, 39), Vector2(94, 1), soft)

func _set_frame_part(part, pos: Vector2, size: Vector2, color: Color) -> void:
    var rect := part as ColorRect
    if rect == null:
        return
    rect.position = pos
    rect.size = size
    rect.color = color
    rect.visible = true

func _choose_index(index: int) -> void:
    if not active or index < 0 or index >= current_options.size():
        return
    augment_chosen.emit(str(current_options[index]))

func _input(event: InputEvent) -> void:
    if not active:
        return
    var chosen := -1
    if event.is_action_pressed("choice_1"):
        chosen = 0
    elif event.is_action_pressed("choice_2"):
        chosen = 1
    elif event.is_action_pressed("choice_3"):
        chosen = 2
    if chosen >= 0 and chosen < current_options.size():
        augment_chosen.emit(str(current_options[chosen]))
        get_viewport().set_input_as_handled()

func _tier_info(tier: String) -> Dictionary:
    if TIER_TEXT.has(tier):
        return TIER_TEXT[tier]
    var data := AugmentData.get_tier_data(tier)
    return {
        "label": data.get("zh", tier),
        "ui_label": data.get("label", tier),
        "color": data.get("color", Color.WHITE)
    }

func _augment_text(augment_id: String) -> Dictionary:
    if AUGMENT_TEXT.has(augment_id):
        return AUGMENT_TEXT[augment_id]
    var data := AugmentData.get_data(augment_id)
    return {
        "name": data.get("name", augment_id),
        "desc": data.get("desc", "未知强化。")
    }

func _augment_icon_texture(augment_id: String, tier: String) -> Texture2D:
    var atlas := _icon_atlas()
    if atlas == null:
        return null
    return _make_ui_atlas_texture(atlas, _augment_icon_grid(augment_id, tier), 4, 4, FORGE_ATLAS_INSET)

func _icon_atlas() -> Texture2D:
    if icon_atlas_texture != null:
        return icon_atlas_texture
    if ResourceLoader.exists(FORGE_ICON_ATLAS_TEXTURE_PATH):
        icon_atlas_texture = load(FORGE_ICON_ATLAS_TEXTURE_PATH) as Texture2D
    elif FileAccess.file_exists(FORGE_ICON_ATLAS_TEXTURE_PATH):
        var image := Image.new()
        var err := image.load(FORGE_ICON_ATLAS_TEXTURE_PATH)
        if err == OK:
            icon_atlas_texture = ImageTexture.create_from_image(image)
    return icon_atlas_texture

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

func _augment_icon_grid(augment_id: String, tier: String) -> Vector2i:
    match augment_id:
        "swift_steps", "quick_hands", "minty_breeze", "mayhem_overdrive":
            return Vector2i(3, 2)
        "sturdy_shell", "hextech_shield", "crystal_armor", "prismatic_body":
            return Vector2i(2, 1)
        "lucky_find", "crystal_pocket", "alchemist_touch", "golden_ticket", "treasure_sense":
            return Vector2i(2, 0)
        "chain_lightning", "orbital_laser", "echo_strike":
            return Vector2i(0, 0)
        "vampiric_spoon", "cheat_death":
            return Vector2i(1, 0)
        "frostfire_combo", "rolling_pin", "double_edged":
            return Vector2i(0, 3)
        _:
            pass
    match tier:
        "gold":
            return Vector2i(2, 0)
        "prismatic":
            return Vector2i(3, 0)
        _:
            return Vector2i(0, 1)
