extends SceneTree

const ForgeScript := preload("res://scripts/hextech_forge_ui.gd")

const EXPECTED_SLOT := Rect2(Vector2(390, 204), Vector2(56, 56))
const EXPECTED_INNER := Rect2(Vector2(395, 209), Vector2(46, 46))

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var forge = ForgeScript.new()
    root.add_child(forge)
    await process_frame
    await process_frame

    var chosen := []
    forge.augment_chosen.connect(func(augment_id: String) -> void:
        chosen.append(augment_id)
    )

    var options := ["swift_steps", "crystal_armor", "cheat_death"]
    forge.show_forge(options)
    await process_frame

    if not _require_visible_shell(forge):
        return
    if not _require_clean_text(forge):
        return
    if not _require_cards(forge, options):
        return
    forge.call("_choose_index", 1)
    await process_frame
    if chosen.size() != 1 or str(chosen[0]) != "crystal_armor":
        push_error("Forge UI visual matrix: mouse/card choice did not emit the expected augment.")
        quit(1)
        return

    forge.hide_forge()
    await process_frame
    if not _require_hidden(forge):
        return

    forge.show_forge(["swift_steps", "cheat_death"])
    await process_frame
    if not _require_visible_shell(forge):
        return
    if not _require_inactive_cards(forge, 2, "partial_show"):
        return

    forge.hide_forge()
    await process_frame
    if not _require_hidden(forge):
        return

    print("CINNA_FORGE_UI_VISUAL_MATRIX_OK cards=3 icons=3 layout=aligned localized=clean reset=locked")
    quit(0)

func _require_visible_shell(forge) -> bool:
    var overlay := forge.get("overlay") as ColorRect
    var title := forge.get("title_label") as Label
    var hint := forge.get("hint_label") as Label
    if overlay == null or not bool(overlay.visible):
        push_error("Forge UI visual matrix: missing visible overlay.")
        quit(1)
        return false
    if Rect2(overlay.position, overlay.size) != Rect2(Vector2(300, 86), Vector2(680, 548)):
        push_error("Forge UI visual matrix: overlay rect drifted.")
        quit(1)
        return false
    if title == null or not bool(title.visible) or title.text.find("海克斯锻造炉") < 0:
        push_error("Forge UI visual matrix: title is not localized or visible.")
        quit(1)
        return false
    if hint == null or not bool(hint.visible) or hint.text.find("点击卡片") < 0:
        push_error("Forge UI visual matrix: hint is not localized or visible.")
        quit(1)
        return false
    return true

func _require_clean_text(forge) -> bool:
    var text := ""
    for field in ["title_label", "hint_label"]:
        var label := forge.get(field) as Label
        if label != null:
            text += " " + label.text
    for group_name in ["card_names", "card_descs", "card_tiers"]:
        var group: Array = forge.get(group_name)
        for node in group:
            var label := node as Label
            if label != null and bool(label.visible):
                text += " " + label.text
    for term in ["迅捷步伐", "水晶甲胄", "死里逃生", "白银", "黄金", "棱彩"]:
        if text.find(term) < 0:
            push_error("Forge UI visual matrix: missing localized term %s in %s" % [term, text])
            quit(1)
            return false
    for marker in ["濞", "閺", "閻", "缂", "鈧", "鍗", "娴峰"]:
        if text.find(marker) >= 0:
            push_error("Forge UI visual matrix: visible text still contains mojibake marker %s in %s" % [marker, text])
            quit(1)
            return false
    return true

func _require_cards(forge, options: Array) -> bool:
    var cards: Array = forge.get("cards")
    var buttons: Array = forge.get("card_buttons")
    var icon_backs: Array = forge.get("card_icon_backs")
    var icon_images: Array = forge.get("card_icon_images")
    var names: Array = forge.get("card_names")
    var descs: Array = forge.get("card_descs")
    var tiers: Array = forge.get("card_tiers")
    if cards.size() < 3 or buttons.size() < 3 or icon_backs.size() < 3 or icon_images.size() < 3:
        push_error("Forge UI visual matrix: card controls are incomplete.")
        quit(1)
        return false
    for i in range(3):
        var card := cards[i] as ColorRect
        var button := buttons[i] as Button
        var back := icon_backs[i] as ColorRect
        var image := icon_images[i] as TextureRect
        var name := names[i] as Label
        var desc := descs[i] as Label
        var tier := tiers[i] as Label
        if card == null or button == null or back == null or image == null or name == null or desc == null or tier == null:
            push_error("Forge UI visual matrix: card %d has null controls." % i)
            quit(1)
            return false
        for control in [card, button, back, image, name, desc, tier]:
            if not bool(control.visible):
                push_error("Forge UI visual matrix: card %d has hidden control %s." % [i, control.name])
                quit(1)
                return false
        if str(card.get_meta("forge_layout_profile", "")) != "hextech_forge_card":
            push_error("Forge UI visual matrix: card %d missing layout metadata." % i)
            quit(1)
            return false
        if str(card.get_meta("augment_id", "")) != str(options[i]):
            push_error("Forge UI visual matrix: card %d augment metadata mismatch." % i)
            quit(1)
            return false
        if not button.flat or button.mouse_default_cursor_shape != Control.CURSOR_POINTING_HAND:
            push_error("Forge UI visual matrix: card %d is not configured for mouse selection." % i)
            quit(1)
            return false
        if not _require_media_geometry(card, back, image, i):
            return false
        if name.position.x < back.position.x + back.size.x + 18.0:
            push_error("Forge UI visual matrix: card %d name overlaps icon lane." % i)
            quit(1)
            return false
        if desc.position.x != name.position.x:
            push_error("Forge UI visual matrix: card %d desc column is not aligned to name column." % i)
            quit(1)
            return false
        if tier.position.x + tier.size.x > card.position.x + card.size.x - 12.0:
            push_error("Forge UI visual matrix: card %d tier label escapes card." % i)
            quit(1)
            return false
    return true

func _require_media_geometry(card: ColorRect, back: ColorRect, image: TextureRect, index: int) -> bool:
    var expected_slot := Rect2(EXPECTED_SLOT.position + Vector2(0, float(index) * 112.0), EXPECTED_SLOT.size)
    var expected_inner := Rect2(EXPECTED_INNER.position + Vector2(0, float(index) * 112.0), EXPECTED_INNER.size)
    if Rect2(back.position, back.size) != expected_slot:
        push_error("Forge UI visual matrix: card %d media slot drifted: got=%s expected=%s." % [index, str(Rect2(back.position, back.size)), str(expected_slot)])
        quit(1)
        return false
    if Rect2(image.position, image.size) != expected_inner:
        push_error("Forge UI visual matrix: card %d media inner rect drifted." % index)
        quit(1)
        return false
    for node in [card, back, image]:
        var slot: Variant = node.get_meta("media_slot_rect", null)
        var inner: Variant = node.get_meta("media_inner_rect", null)
        if not (slot is Rect2) or not (inner is Rect2):
            push_error("Forge UI visual matrix: card %d missing media metadata." % index)
            quit(1)
            return false
        if slot != expected_slot or inner != expected_inner:
            push_error("Forge UI visual matrix: card %d media metadata mismatch." % index)
            quit(1)
            return false
    var image_center := image.position + image.size * 0.5
    var back_center := back.position + back.size * 0.5
    if image_center.distance_to(back_center) > 0.25:
        push_error("Forge UI visual matrix: card %d media texture is not centered." % index)
        quit(1)
        return false
    var atlas_texture := image.texture as AtlasTexture
    if atlas_texture == null or atlas_texture.atlas == null:
        push_error("Forge UI visual matrix: card %d does not use an atlas icon." % index)
        quit(1)
        return false
    var cell := Vector2(float(atlas_texture.atlas.get_width()) / 4.0, float(atlas_texture.atlas.get_height()) / 4.0)
    if atlas_texture.region.size.x >= cell.x or atlas_texture.region.size.y >= cell.y:
        push_error("Forge UI visual matrix: card %d atlas icon was not inset." % index)
        quit(1)
        return false
    if fmod(atlas_texture.region.position.x, cell.x) <= 0.01 or fmod(atlas_texture.region.position.y, cell.y) <= 0.01:
        push_error("Forge UI visual matrix: card %d atlas icon starts on a raw cell edge." % index)
        quit(1)
        return false
    var cell_rect: Variant = atlas_texture.get_meta("ui_atlas_cell_rect", null)
    if not (cell_rect is Rect2):
        push_error("Forge UI visual matrix: card %d atlas icon missing cell metadata." % index)
        quit(1)
        return false
    if not bool(atlas_texture.get_meta("ui_atlas_region_center_locked", false)):
        push_error("Forge UI visual matrix: card %d atlas icon is not center locked." % index)
        quit(1)
        return false
    var declared_cell: Rect2 = cell_rect
    if atlas_texture.region.get_center().distance_to(declared_cell.get_center()) > 0.25:
        push_error("Forge UI visual matrix: card %d atlas icon center drifted." % index)
        quit(1)
        return false
    return true

func _require_hidden(forge) -> bool:
    if bool(forge.get("active")):
        push_error("Forge UI visual matrix: forge remains active after hide.")
        quit(1)
        return false
    for group_name in ["cards", "card_buttons", "card_icon_backs", "card_icon_images", "card_names", "card_descs", "card_tiers"]:
        var group: Array = forge.get(group_name)
        for i in range(group.size()):
            var control := group[i] as Control
            if control != null and bool(control.visible):
                push_error("Forge UI visual matrix: %s card %d still visible after hide." % [group_name, i])
                quit(1)
                return false
    if not _require_inactive_cards(forge, 0, "hide"):
        return false
    return true

func _require_inactive_cards(forge, active_count: int, label: String) -> bool:
    for group_name in ["cards", "card_buttons", "card_icon_backs", "card_icon_images", "card_labels", "card_names", "card_descs", "card_tiers"]:
        var group: Array = forge.get(group_name)
        for i in range(active_count, group.size()):
            var control := group[i] as Control
            if control == null:
                continue
            if bool(control.visible):
                push_error("Forge UI visual matrix: %s inactive card %d kept %s visible." % [label, i, group_name])
                quit(1)
                return false
            if str(control.get_meta("forge_layout_profile", "")) != "inactive":
                push_error("Forge UI visual matrix: %s inactive card %d retained %s layout metadata." % [label, i, group_name])
                quit(1)
                return false
            if str(control.get_meta("augment_id", "")) != "":
                push_error("Forge UI visual matrix: %s inactive card %d retained %s augment id." % [label, i, group_name])
                quit(1)
                return false
            var slot: Variant = control.get_meta("media_slot_rect", Rect2(1, 1, 1, 1))
            var inner: Variant = control.get_meta("media_inner_rect", Rect2(1, 1, 1, 1))
            if not (slot is Rect2) or not (inner is Rect2) or slot != Rect2() or inner != Rect2():
                push_error("Forge UI visual matrix: %s inactive card %d retained %s media rect metadata." % [label, i, group_name])
                quit(1)
                return false
            if str(control.get_meta("media_alignment_mode", "")) != "inactive":
                push_error("Forge UI visual matrix: %s inactive card %d retained %s media alignment." % [label, i, group_name])
                quit(1)
                return false
            if control is Label and (control as Label).text.strip_edges() != "":
                push_error("Forge UI visual matrix: %s inactive card %d retained %s text." % [label, i, group_name])
                quit(1)
                return false
            if control is TextureRect and (control as TextureRect).texture != null:
                push_error("Forge UI visual matrix: %s inactive card %d retained %s texture." % [label, i, group_name])
                quit(1)
                return false
    return true
