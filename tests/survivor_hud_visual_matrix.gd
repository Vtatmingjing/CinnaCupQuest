extends SceneTree

const HUDScript := preload("res://scripts/survivor_hud.gd")

const HERO_MEDIA_SLOT := Rect2(16, 10, 72, 72)
const OPTION_MEDIA_SLOT := Rect2(22, 24, 64, 64)
const SHOP_MEDIA_SLOT := Rect2(16, 14, 48, 48)
const DEFAULT_HINT_RECT := Rect2(190, 650, 900, 45)
const DEFAULT_RETURN_RECT := Rect2(744, 586, 210, 53)
const DEFAULT_MUTE_RECT := Rect2(576, 586, 150, 53)
const SHOP_HINT_RECT := Rect2(190, 106, 420, 45)
const SHOP_RETURN_RECT := Rect2(646, 70, 142, 53)
const SHOP_MUTE_RECT := Rect2(804, 70, 124, 53)
const SHOP_CLOSE_RECT := Rect2(944, 70, 142, 53)

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var hud = HUDScript.new()
    root.add_child(hud)
    await process_frame
    await process_frame

    hud.show_title("jinx")
    await process_frame
    if not _require_clean_hud_text(hud, "hero_select"):
        return
    if not _require_visible_chinese_terms(hud, ["海克斯", "当前"], "hero_select"):
        return
    if not _require_visible_cards_inside_overlay(hud, 8, "hero_select"):
        return
    if not _require_only_first_cards_visible(hud, 8, "hero_select"):
        return
    if not _require_card_child_bounds(hud, 8, "hero_select"):
        return
    if not _require_portraits(hud, 8, "hero_select"):
        return
    if not _require_media_slot_profile(hud, 8, "hero_select", Vector2(72, 72), "hero", 3.0):
        return
    if not _require_action_control_layout(hud, "hero_select", "default"):
        return
    if not _require_no_shop_adornments(hud, "hero_select"):
        return

    hud.show_upgrade_choices([
        {"name": "物理海克斯：破甲弹仓", "desc": "伤害、穿透和暴击提高。", "color": Color(1.0, 0.58, 0.22), "badge": "物理", "recommended": true},
        {"name": "召唤海克斯：自动工坊", "desc": "增加环绕单位和技能威力。", "color": Color(0.58, 0.92, 1.0), "badge": "召唤"},
        {"name": "坦克海克斯：巨像核心", "desc": "最大生命和护盾提高。", "color": Color(0.52, 0.90, 0.72), "badge": "坦克"}
    ])
    await process_frame
    if not _require_clean_hud_text(hud, "upgrade"):
        return
    if not _require_visible_chinese_terms(hud, ["选择升级", "升级"], "upgrade"):
        return
    if not _require_visible_cards_inside_overlay(hud, 3, "upgrade"):
        return
    if not _require_only_first_cards_visible(hud, 3, "upgrade"):
        return
    if not _require_card_child_bounds(hud, 3, "upgrade"):
        return
    if not _require_icons(hud, 3, "upgrade"):
        return
    if not _require_media_slot_profile(hud, 3, "upgrade", Vector2(64, 64), "choice", 4.0):
        return
    if not _require_action_control_layout(hud, "upgrade", "default"):
        return
    if not _require_no_shop_adornments(hud, "upgrade"):
        return

    hud.show_hextech_choices([
        {"name": "链式闪电", "desc": "攻击有概率跳电。", "tier_label": "白银", "color": Color(0.70, 0.92, 1.0), "badge": "海克斯"},
        {"name": "棱彩之躯", "desc": "受击后获得更久无敌。", "tier_label": "棱彩", "color": Color(0.92, 0.42, 1.0), "badge": "棱彩", "recommended": true},
        {"name": "黄金门票", "desc": "商店折扣与金币收益提高。", "tier_label": "黄金", "color": Color(1.0, 0.82, 0.14), "badge": "黄金"}
    ])
    await process_frame
    if not _require_clean_hud_text(hud, "hextech"):
        return
    if not _require_visible_chinese_terms(hud, ["海克斯强化", "海克斯"], "hextech"):
        return
    if not _require_visible_cards_inside_overlay(hud, 3, "hextech"):
        return
    if not _require_only_first_cards_visible(hud, 3, "hextech"):
        return
    if not _require_card_child_bounds(hud, 3, "hextech"):
        return
    if not _require_icons(hud, 3, "hextech"):
        return
    if not _require_media_slot_profile(hud, 3, "hextech", Vector2(64, 64), "choice", 4.0):
        return
    if not _require_action_control_layout(hud, "hextech", "default"):
        return
    if not _require_no_shop_adornments(hud, "hextech"):
        return

    var shop_options := [
        {"id": "infinity_edge", "item": "infinity_edge", "name": "无尽之刃", "desc": "伤害与暴击提高。", "price": 58, "color": Color(1.0, 0.72, 0.18), "badge": "装备", "recommended": true, "route_score": 2, "tags": ["physical", "crit", "marksman"]},
        {"id": "randuins_omen", "item": "randuins_omen", "name": "兰顿之兆", "desc": "最大生命和护盾提高。", "price": 46, "color": Color(0.52, 0.90, 0.72), "badge": "坦克", "route_score": 1, "tags": ["tank", "melee"]},
        {"id": "rabadons_hat", "item": "rabadons_hat", "name": "灭世者的帽子", "desc": "特殊技能威力提高。", "price": 62, "color": Color(0.66, 0.48, 1.0), "badge": "魔法", "tags": ["magic"]}
    ]
    var extra_shop_ids := ["statikk_shiv", "bloodthirster", "runaans_hurricane", "nashors_tooth", "zhonyas_hourglass", "black_cleaver", "guardian_angel", "future_market", "warmogs_armor", "liandrys", "zekes", "titanic", "shield_pack", "hextech_cache", "mystery_spice"]
    for i in range(extra_shop_ids.size()):
        var item_id := str(extra_shop_ids[i])
        shop_options.append({
            "id": item_id,
            "item": item_id,
            "name": "测试商品%d" % [i + 4],
            "desc": "测试商品描述。",
            "price": 30 + i,
            "color": Color(0.56, 0.78, 1.0),
            "badge": "装备",
            "route_score": i % 3,
            "tags": ["support"] if i % 3 == 0 else ["magic"] if i % 3 == 1 else ["physical"]
        })
    hud.show_shop_choices(shop_options, 30)
    await process_frame
    if not _require_clean_hud_text(hud, "shop"):
        return
    if not _require_visible_chinese_terms(hud, ["海克斯装备商店", "金币", "离开商店"], "shop"):
        return
    if not _require_visible_cards_inside_overlay(hud, 18, "shop"):
        return
    if not _require_only_first_cards_visible(hud, 18, "shop"):
        return
    if not _require_card_child_bounds(hud, 18, "shop"):
        return
    if not _require_icons(hud, 18, "shop"):
        return
    if not _require_shop_cards(hud, 18):
        return
    if not _require_media_slot_profile(hud, 18, "shop", Vector2(48, 48), "shop", 3.0):
        return
    if not _require_action_control_layout(hud, "shop", "shop"):
        return

    hud.show_upgrade_choices([
        {"id": "jinx_rockets", "recommended": true},
        {"id": "marksman_hex"},
        {"id": "ice_cube"}
    ])
    await process_frame
    if not _require_visible_cards_inside_overlay(hud, 3, "upgrade_after_shop"):
        return
    if not _require_only_first_cards_visible(hud, 3, "upgrade_after_shop"):
        return
    if not _require_icons(hud, 3, "upgrade_after_shop"):
        return
    if not _require_media_slot_profile(hud, 3, "upgrade_after_shop", Vector2(64, 64), "choice", 4.0):
        return
    if not _require_action_control_layout(hud, "upgrade_after_shop", "default"):
        return
    if not _require_no_shop_adornments(hud, "upgrade_after_shop"):
        return

    print("SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean")
    quit(0)

func _require_clean_hud_text(hud, label: String) -> bool:
    var overlay_title := hud.get("overlay_title") as Label
    var overlay_hint := hud.get("overlay_hint") as Label
    var texts := []
    if overlay_title != null:
        texts.append(overlay_title.text)
    if overlay_hint != null:
        texts.append(overlay_hint.text)
    var titles: Array = hud.get("choice_title_labels")
    var descs: Array = hud.get("choice_desc_labels")
    for i in range(mini(3, titles.size())):
        var title := titles[i] as Label
        if title != null and bool(title.visible):
            texts.append(title.text)
        var desc := descs[i] as Label if descs.size() > i else null
        if desc != null and bool(desc.visible):
            texts.append(desc.text)
    for text in texts:
        if _has_mojibake(str(text)):
            push_error("HUD visual matrix: %s still contains mojibake text: %s" % [label, str(text)])
            quit(1)
            return false
    return true

func _require_visible_chinese_terms(hud, terms: Array, label: String) -> bool:
    var text := ""
    for node_name in ["overlay_title", "overlay_hint"]:
        var node := hud.get(node_name) as Label
        if node != null and bool(node.visible):
            text += " " + node.text
    for control_name in ["start_button", "shop_close_button", "mute_button", "return_button"]:
        var button := hud.get(control_name) as Button
        if button != null and bool(button.visible):
            text += " " + button.text
    var titles: Array = hud.get("choice_title_labels")
    var descs: Array = hud.get("choice_desc_labels")
    var badges: Array = hud.get("choice_badge_labels")
    var routes: Array = hud.get("shop_route_labels")
    for group in [titles, descs, badges, routes]:
        for node in group:
            var label_node := node as Label
            if label_node != null and bool(label_node.visible):
                text += " " + label_node.text
    for term in terms:
        if text.find(str(term)) < 0:
            push_error("HUD visual matrix: %s missing visible Chinese term '%s' in: %s" % [label, str(term), text])
            quit(1)
            return false
    return true

func _has_mojibake(text: String) -> bool:
    for marker in ["娴", "鏂", "鐗", "鍗", "缁", "鍧", "铏", "闊", "绂", "€?"]:
        if text.find(marker) >= 0:
            return true
    return false

func _require_portraits(hud, count: int, label: String) -> bool:
    var images: Array = hud.get("choice_icon_images")
    var backs: Array = hud.get("choice_icon_backs")
    var labels: Array = hud.get("choice_icon_labels")
    var titles: Array = hud.get("choice_title_labels")
    if images.size() < count or backs.size() < count or labels.size() < count:
        push_error("HUD visual matrix: %s missing portrait controls." % label)
        quit(1)
        return false
    for i in range(count):
        var portrait := images[i] as TextureRect
        var back := backs[i] as ColorRect
        var fallback := labels[i] as Label
        if portrait == null or portrait.texture == null or not bool(portrait.visible):
            push_error("HUD visual matrix: %s card %d missing champion portrait." % [label, i])
            quit(1)
            return false
        if not _require_media_alignment(portrait, back, label, i):
            return false
        if portrait.size.x < 50.0 or portrait.size.y < 50.0:
            push_error("HUD visual matrix: %s card %d portrait is too small." % [label, i])
            quit(1)
            return false
        if portrait.stretch_mode != TextureRect.STRETCH_KEEP_ASPECT_COVERED:
            push_error("HUD visual matrix: %s card %d portrait should fill the portrait frame without inheriting icon sizing." % [label, i])
            quit(1)
            return false
        if not _require_portrait_focus_region(portrait, label, i):
            return false
        var title := titles[i] as Label if titles.size() > i else null
        if title == null or title.position.x <= portrait.position.x + portrait.size.x:
            push_error("HUD visual matrix: %s card %d portrait overlaps title column. portrait_x=%.1f portrait_w=%.1f title_x=%.1f" % [label, i, portrait.position.x, portrait.size.x, title.position.x if title != null else -1.0])
            quit(1)
            return false
        if fallback != null and bool(fallback.visible):
            push_error("HUD visual matrix: %s card %d still shows portrait fallback text." % [label, i])
            quit(1)
            return false
    return true

func _require_icons(hud, count: int, label: String) -> bool:
    var images: Array = hud.get("choice_icon_images")
    var backs: Array = hud.get("choice_icon_backs")
    var labels: Array = hud.get("choice_icon_labels")
    var titles: Array = hud.get("choice_title_labels")
    if images.size() < count or backs.size() < count or labels.size() < count:
        push_error("HUD visual matrix: %s missing icon controls." % label)
        quit(1)
        return false
    for i in range(count):
        var icon := images[i] as TextureRect
        var back := backs[i] as ColorRect
        var fallback := labels[i] as Label
        if icon == null or icon.texture == null or not bool(icon.visible):
            push_error("HUD visual matrix: %s card %d missing atlas icon." % [label, i])
            quit(1)
            return false
        if not _require_media_alignment(icon, back, label, i):
            return false
        if icon.stretch_mode != TextureRect.STRETCH_KEEP_ASPECT_CENTERED:
            push_error("HUD visual matrix: %s card %d atlas icon should keep aspect centered." % [label, i])
            quit(1)
            return false
        if not _require_inset_atlas_region(icon, label, i):
            return false
        if label == "upgrade" or label == "hextech":
            if icon.size.x < 44.0 or icon.size.y < 44.0:
                push_error("HUD visual matrix: %s card %d atlas icon is too small for the card." % [label, i])
                quit(1)
                return false
            var title := titles[i] as Label if titles.size() > i else null
            if title == null or title.position.x <= icon.position.x + icon.size.x:
                push_error("HUD visual matrix: %s card %d icon overlaps title column." % [label, i])
                quit(1)
                return false
        if fallback != null and bool(fallback.visible):
            push_error("HUD visual matrix: %s card %d still shows text fallback over atlas icon." % [label, i])
            quit(1)
            return false
    return true

func _require_shop_cards(hud, count: int) -> bool:
    var atlas = hud.call("_shop_item_icon_atlas") as Texture2D
    if atlas == null or atlas.get_width() < 1024 or atlas.get_height() < 1024:
        push_error("HUD visual matrix: shop item icon atlas is missing or too small.")
        quit(1)
        return false
    var images: Array = hud.get("choice_icon_images")
    var backs: Array = hud.get("choice_icon_backs")
    var price_labels: Array = hud.get("shop_price_labels")
    var route_labels: Array = hud.get("shop_route_labels")
    var pips: Array = hud.get("shop_route_pips")
    if images.size() < count or backs.size() < count or price_labels.size() < count or route_labels.size() < count or pips.size() < count:
        push_error("HUD visual matrix: shop card controls are incomplete.")
        quit(1)
        return false
    for i in range(count):
        var icon := images[i] as TextureRect
        var back := backs[i] as ColorRect
        var price := price_labels[i] as Label
        var route := route_labels[i] as Label
        if icon == null or icon.texture == null or icon.size.x < 40.0 or icon.size.y < 40.0:
            push_error("HUD visual matrix: shop card %d missing large equipment icon." % i)
            quit(1)
            return false
        if not _require_media_alignment(icon, back, "shop", i):
            return false
        if not _require_inset_atlas_region(icon, "shop", i):
            return false
        if price == null or not bool(price.visible) or price.text.find("G") < 0:
            push_error("HUD visual matrix: shop card %d missing visible price plate." % i)
            quit(1)
            return false
        if not _child_fits_in_button(price, _button_for_index(hud, i), "shop", i, "price"):
            return false
        if route == null or not bool(route.visible) or route.text.strip_edges() == "":
            push_error("HUD visual matrix: shop card %d missing route label." % i)
            quit(1)
            return false
        if not _child_fits_in_button(route, _button_for_index(hud, i), "shop", i, "route"):
            return false
        var pip_group: Array = pips[i]
        if pip_group.size() < 3:
            push_error("HUD visual matrix: shop card %d missing route pips." % i)
            quit(1)
            return false
        for pip in pip_group:
            if not is_instance_valid(pip) or not bool(pip.visible):
                push_error("HUD visual matrix: shop card %d has hidden route pip." % i)
                quit(1)
                return false
    return true

func _require_no_shop_adornments(hud, label: String) -> bool:
    var price_labels: Array = hud.get("shop_price_labels")
    var route_labels: Array = hud.get("shop_route_labels")
    var pips: Array = hud.get("shop_route_pips")
    for i in range(price_labels.size()):
        var price := price_labels[i] as Label
        if price != null and (bool(price.visible) or price.text.strip_edges() != ""):
            push_error("HUD visual matrix: %s card %d retained shop price label." % [label, i])
            quit(1)
            return false
    for i in range(route_labels.size()):
        var route := route_labels[i] as Label
        if route != null and (bool(route.visible) or route.text.strip_edges() != ""):
            push_error("HUD visual matrix: %s card %d retained shop route label." % [label, i])
            quit(1)
            return false
    for i in range(pips.size()):
        var pip_group: Array = pips[i]
        for pip in pip_group:
            if is_instance_valid(pip) and bool(pip.visible):
                push_error("HUD visual matrix: %s card %d retained shop route pip." % [label, i])
                quit(1)
                return false
    return true

func _require_action_control_layout(hud, label: String, profile: String) -> bool:
    var hint := hud.get("overlay_hint") as Label
    var return_button := hud.get("return_button") as Button
    var mute_button := hud.get("mute_button") as Button
    var close_button := hud.get("shop_close_button") as Button
    if hint == null or return_button == null or mute_button == null or close_button == null:
        push_error("HUD visual matrix: %s missing action controls for layout probe." % label)
        quit(1)
        return false
    if profile == "shop":
        if not _control_rect_close(hint, SHOP_HINT_RECT, label, "hint"):
            return false
        if not _control_rect_close(return_button, SHOP_RETURN_RECT, label, "return"):
            return false
        if not _control_rect_close(mute_button, SHOP_MUTE_RECT, label, "mute"):
            return false
        if not _control_rect_close(close_button, SHOP_CLOSE_RECT, label, "shop_close"):
            return false
        return true
    if not _control_rect_close(hint, DEFAULT_HINT_RECT, label, "hint"):
        return false
    if not _control_rect_close(return_button, DEFAULT_RETURN_RECT, label, "return"):
        return false
    if not _control_rect_close(mute_button, DEFAULT_MUTE_RECT, label, "mute"):
        return false
    return true

func _control_rect_close(control: Control, expected: Rect2, label: String, control_name: String) -> bool:
    var actual := Rect2(control.position, control.size)
    if not _rect_close(actual, expected):
        push_error("HUD visual matrix: %s %s layout drifted: got=%s expected=%s." % [label, control_name, str(actual), str(expected)])
        quit(1)
        return false
    return true

func _require_visible_cards_inside_overlay(hud, count: int, label: String) -> bool:
    var overlay := hud.get("overlay_rect") as ColorRect
    if overlay == null or not bool(overlay.visible):
        push_error("HUD visual matrix: %s missing visible overlay." % label)
        quit(1)
        return false
    var overlay_rect := Rect2(overlay.position, overlay.size)
    var buttons: Array = hud.get("choice_buttons")
    var visible_rects := []
    for i in range(count):
        if i >= buttons.size():
            push_error("HUD visual matrix: %s missing button %d." % [label, i])
            quit(1)
            return false
        var button := buttons[i] as Button
        if button == null or not bool(button.visible):
            push_error("HUD visual matrix: %s expected visible card %d." % [label, i])
            quit(1)
            return false
        var card_rect := Rect2(button.position, button.size)
        if not _rect_contains_rect(overlay_rect, card_rect):
            push_error("HUD visual matrix: %s card %d escapes overlay: card=%s overlay=%s." % [label, i, str(card_rect), str(overlay_rect)])
            quit(1)
            return false
        for other_rect in visible_rects:
            if card_rect.intersects(other_rect):
                push_error("HUD visual matrix: %s card %d overlaps another card." % [label, i])
                quit(1)
                return false
        visible_rects.append(card_rect)
    return true

func _require_only_first_cards_visible(hud, active_count: int, label: String) -> bool:
    var buttons: Array = hud.get("choice_buttons")
    var images: Array = hud.get("choice_icon_images")
    var backs: Array = hud.get("choice_icon_backs")
    var labels: Array = hud.get("choice_icon_labels")
    var badges: Array = hud.get("choice_badge_labels")
    var titles: Array = hud.get("choice_title_labels")
    var descs: Array = hud.get("choice_desc_labels")
    for i in range(buttons.size()):
        var button := buttons[i] as Button
        var should_be_visible := i < active_count
        if button != null and bool(button.visible) != should_be_visible:
            push_error("HUD visual matrix: %s card %d visibility mismatch. expected=%s actual=%s" % [label, i, str(should_be_visible), str(button.visible)])
            quit(1)
            return false
        if i >= active_count:
            var image := images[i] as TextureRect if images.size() > i else null
            var back := backs[i] as ColorRect if backs.size() > i else null
            var fallback := labels[i] as Label if labels.size() > i else null
            var badge := badges[i] as Label if badges.size() > i else null
            if image != null and (image.texture != null or bool(image.visible)):
                push_error("HUD visual matrix: %s inactive card %d still has media texture/visibility." % [label, i])
                quit(1)
                return false
            if back != null and bool(back.visible):
                push_error("HUD visual matrix: %s inactive card %d still has media backing visible." % [label, i])
                quit(1)
                return false
            if fallback != null and (bool(fallback.visible) or fallback.text.strip_edges() != ""):
                push_error("HUD visual matrix: %s inactive card %d still has fallback text." % [label, i])
                quit(1)
                return false
            if badge != null and (bool(badge.visible) or badge.text.strip_edges() != ""):
                push_error("HUD visual matrix: %s inactive card %d still has badge text." % [label, i])
                quit(1)
                return false
            var title := titles[i] as Label if titles.size() > i else null
            if title != null and (bool(title.visible) or title.text.strip_edges() != ""):
                push_error("HUD visual matrix: %s inactive card %d still has title text." % [label, i])
                quit(1)
                return false
            var desc := descs[i] as Label if descs.size() > i else null
            if desc != null and (bool(desc.visible) or desc.text.strip_edges() != ""):
                push_error("HUD visual matrix: %s inactive card %d still has desc text." % [label, i])
                quit(1)
                return false
            if not _require_inactive_media_metadata(button, back, image, label, i):
                return false
    return true

func _require_inactive_media_metadata(button: Button, back: ColorRect, image: TextureRect, label: String, index: int) -> bool:
    for pair in [[button, "button"], [back, "backing"], [image, "texture"]]:
        var node = pair[0]
        var node_label := str(pair[1])
        if node == null:
            continue
        if str(node.get_meta("media_slot_profile", "")) != "inactive":
            push_error("HUD visual matrix: %s inactive card %d retained %s media profile." % [label, index, node_label])
            quit(1)
            return false
        var slot: Variant = node.get_meta("media_slot_rect", Rect2(1, 1, 1, 1))
        var inner: Variant = node.get_meta("media_inner_rect", Rect2(1, 1, 1, 1))
        var visual: Variant = node.get_meta("media_visual_rect", Rect2(1, 1, 1, 1))
        if not (slot is Rect2) or not (inner is Rect2) or not (visual is Rect2):
            push_error("HUD visual matrix: %s inactive card %d retained malformed %s media metadata." % [label, index, node_label])
            quit(1)
            return false
        if slot != Rect2() or inner != Rect2() or visual != Rect2():
            push_error("HUD visual matrix: %s inactive card %d retained %s media rect metadata." % [label, index, node_label])
            quit(1)
            return false
        if bool(node.get_meta("media_rect_locked", true)):
            push_error("HUD visual matrix: %s inactive card %d retained locked %s media rect." % [label, index, node_label])
            quit(1)
            return false
        if str(node.get_meta("media_alignment_mode", "")) != "inactive":
            push_error("HUD visual matrix: %s inactive card %d retained %s media alignment." % [label, index, node_label])
            quit(1)
            return false
        if absf(float(node.get_meta("media_slot_padding", -1.0))) > 0.01:
            push_error("HUD visual matrix: %s inactive card %d retained %s media padding." % [label, index, node_label])
            quit(1)
            return false
    return true

func _require_card_child_bounds(hud, count: int, label: String) -> bool:
    var buttons: Array = hud.get("choice_buttons")
    var images: Array = hud.get("choice_icon_images")
    var backs: Array = hud.get("choice_icon_backs")
    var titles: Array = hud.get("choice_title_labels")
    var descs: Array = hud.get("choice_desc_labels")
    var badges: Array = hud.get("choice_badge_backs")
    for i in range(count):
        var button: Button = null
        if buttons.size() > i:
            button = buttons[i] as Button
        if button == null:
            push_error("HUD visual matrix: %s missing card %d for child bounds." % [label, i])
            quit(1)
            return false
        var image: TextureRect = null
        if images.size() > i:
            image = images[i] as TextureRect
        var back: ColorRect = null
        if backs.size() > i:
            back = backs[i] as ColorRect
        var title: Label = null
        if titles.size() > i:
            title = titles[i] as Label
        var desc: Label = null
        if descs.size() > i:
            desc = descs[i] as Label
        var badge: ColorRect = null
        if badges.size() > i:
            badge = badges[i] as ColorRect
        if back != null and bool(back.visible) and not _child_fits_in_button(back, button, label, i, "media backing"):
            return false
        if image != null and bool(image.visible) and not _child_fits_in_button(image, button, label, i, "media texture"):
            return false
        if title == null or not _child_fits_in_button(title, button, label, i, "title"):
            return false
        if desc == null or not _child_fits_in_button(desc, button, label, i, "desc"):
            return false
        if back != null and title != null and title.position.x < back.position.x + back.size.x + 12.0:
            push_error("HUD visual matrix: %s card %d title column is not separated from media." % [label, i])
            quit(1)
            return false
        if back != null and desc != null:
            var media_rect := Rect2(back.position, back.size)
            var desc_rect := Rect2(desc.position, desc.size)
            if media_rect.intersects(desc_rect) or desc.position.x < back.position.x + back.size.x + 12.0:
                push_error("HUD visual matrix: %s card %d desc column overlaps or crowds media." % [label, i])
                quit(1)
                return false
        if badge != null and bool(badge.visible) and title != null and Rect2(title.position, title.size).intersects(Rect2(badge.position, badge.size)):
            push_error("HUD visual matrix: %s card %d badge overlaps title." % [label, i])
            quit(1)
            return false
        if badge != null and bool(badge.visible) and title != null:
            var title_rect := Rect2(title.position, title.size)
            var badge_rect := Rect2(badge.position, badge.size)
            if title_rect.position.x + title_rect.size.x > badge_rect.position.x - 8.0:
                push_error("HUD visual matrix: %s card %d title crowds badge." % [label, i])
                quit(1)
                return false
    return true

func _button_for_index(hud, index: int) -> Button:
    var buttons: Array = hud.get("choice_buttons")
    if index < 0 or index >= buttons.size():
        return null
    return buttons[index] as Button

func _child_fits_in_button(child: Control, button: Button, label: String, index: int, child_name: String) -> bool:
    if child == null or button == null:
        push_error("HUD visual matrix: %s card %d missing %s bounds probe." % [label, index, child_name])
        quit(1)
        return false
    var child_rect := Rect2(child.position, child.size)
    var button_rect := Rect2(Vector2.ZERO, button.size)
    if not _rect_contains_rect(button_rect, child_rect):
        push_error("HUD visual matrix: %s card %d %s escapes card bounds: child=%s card=%s." % [label, index, child_name, str(child_rect), str(button_rect)])
        quit(1)
        return false
    return true

func _rect_contains_rect(outer: Rect2, inner: Rect2) -> bool:
    return (
        inner.position.x >= outer.position.x
        and inner.position.y >= outer.position.y
        and inner.position.x + inner.size.x <= outer.position.x + outer.size.x
        and inner.position.y + inner.size.y <= outer.position.y + outer.size.y
    )

func _require_media_alignment(image: TextureRect, back: ColorRect, label: String, index: int) -> bool:
    if back == null or not bool(back.visible):
        push_error("HUD visual matrix: %s card %d missing visible media backing." % [label, index])
        quit(1)
        return false
    var image_center := image.position + image.size * 0.5
    var back_center := back.position + back.size * 0.5
    if image_center.distance_to(back_center) > 0.75:
        push_error("HUD visual matrix: %s card %d media is off-center: image=%s back=%s." % [label, index, str(image_center), str(back_center)])
        quit(1)
        return false
    if image.position.x < back.position.x or image.position.y < back.position.y:
        push_error("HUD visual matrix: %s card %d media escapes backing min bounds." % [label, index])
        quit(1)
        return false
    if image.position.x + image.size.x > back.position.x + back.size.x or image.position.y + image.size.y > back.position.y + back.size.y:
        push_error("HUD visual matrix: %s card %d media escapes backing max bounds." % [label, index])
        quit(1)
        return false
    return true

func _require_media_slot_profile(hud, count: int, label: String, expected_size: Vector2, expected_profile: String, expected_padding: float) -> bool:
    var buttons: Array = hud.get("choice_buttons")
    var backs: Array = hud.get("choice_icon_backs")
    var images: Array = hud.get("choice_icon_images")
    for i in range(count):
        var button: Button = null
        if buttons.size() > i:
            button = buttons[i] as Button
        var back: ColorRect = null
        if backs.size() > i:
            back = backs[i] as ColorRect
        var image: TextureRect = null
        if images.size() > i:
            image = images[i] as TextureRect
        if button == null or back == null or image == null:
            push_error("HUD visual matrix: %s card %d missing media slot controls." % [label, i])
            quit(1)
            return false
        if str(button.get_meta("card_layout_profile", "")) != expected_profile:
            push_error("HUD visual matrix: %s card %d expected profile %s, got %s." % [label, i, expected_profile, str(button.get_meta("card_layout_profile", ""))])
            quit(1)
            return false
        if str(button.get_meta("media_slot_profile", "")) != expected_profile:
            push_error("HUD visual matrix: %s card %d expected button media profile %s, got %s." % [label, i, expected_profile, str(button.get_meta("media_slot_profile", ""))])
            quit(1)
            return false
        if str(back.get_meta("media_slot_profile", "")) != expected_profile or str(image.get_meta("media_slot_profile", "")) != expected_profile:
            push_error("HUD visual matrix: %s card %d media slot profile did not propagate to backing and texture." % [label, i])
            quit(1)
            return false
        if absf(float(button.get_meta("media_slot_padding", -1.0)) - expected_padding) > 0.01:
            push_error("HUD visual matrix: %s card %d media padding metadata drifted." % [label, i])
            quit(1)
            return false
        if absf(float(back.get_meta("media_slot_padding", -1.0)) - expected_padding) > 0.01 or absf(float(image.get_meta("media_slot_padding", -1.0)) - expected_padding) > 0.01:
            push_error("HUD visual matrix: %s card %d media padding did not propagate to backing and texture." % [label, i])
            quit(1)
            return false
        var expected_alignment := "cover_centered" if expected_profile == "hero" else "aspect_centered"
        if str(button.get_meta("media_alignment_mode", "")) != expected_alignment or str(image.get_meta("media_alignment_mode", "")) != expected_alignment:
            push_error("HUD visual matrix: %s card %d media alignment mode drifted." % [label, i])
            quit(1)
            return false
        var expected_slot := _expected_media_slot_rect(expected_profile)
        if expected_slot.size != Vector2.ZERO:
            var back_slot: Variant = back.get_meta("media_slot_rect", null)
            var image_slot: Variant = image.get_meta("media_slot_rect", null)
            var button_slot: Variant = button.get_meta("media_slot_rect", null)
            if not (back_slot is Rect2) or not (image_slot is Rect2) or not (button_slot is Rect2):
                push_error("HUD visual matrix: %s card %d missing explicit media slot rect metadata." % [label, i])
                quit(1)
                return false
            if not _rect_close(back_slot, expected_slot) or not _rect_close(image_slot, expected_slot) or not _rect_close(button_slot, expected_slot):
                push_error("HUD visual matrix: %s card %d media slot drifted: got=%s expected=%s." % [label, i, str(back_slot), str(expected_slot)])
                quit(1)
                return false
            if not _rect_close(Rect2(back.position, back.size), expected_slot):
                push_error("HUD visual matrix: %s card %d visible media backing is not locked to its slot." % [label, i])
                quit(1)
                return false
        if back.size.distance_to(expected_size) > 0.75:
            push_error("HUD visual matrix: %s card %d media slot size mismatch: got=%s expected=%s." % [label, i, str(back.size), str(expected_size)])
            quit(1)
            return false
        if image.size.x > back.size.x or image.size.y > back.size.y:
            push_error("HUD visual matrix: %s card %d media texture larger than backing." % [label, i])
            quit(1)
            return false
        var expected_inner := Rect2(
            back.position + Vector2(expected_padding, expected_padding),
            Vector2(maxf(1.0, back.size.x - expected_padding * 2.0), maxf(1.0, back.size.y - expected_padding * 2.0))
        )
        if image.position.distance_to(expected_inner.position) > 0.25 or image.size.distance_to(expected_inner.size) > 0.25:
            push_error("HUD visual matrix: %s card %d media inner rect mismatch: image=%s expected=%s." % [label, i, str(Rect2(image.position, image.size)), str(expected_inner)])
            quit(1)
            return false
        var visual_rect: Variant = image.get_meta("media_visual_rect", null)
        if not (visual_rect is Rect2) or not _rect_close(visual_rect, Rect2(image.position, image.size)):
            push_error("HUD visual matrix: %s card %d media visual rect metadata mismatch." % [label, i])
            quit(1)
            return false
        if not bool(image.get_meta("media_rect_locked", false)):
            push_error("HUD visual matrix: %s card %d media rect is not explicitly locked." % [label, i])
            quit(1)
            return false
        var back_inner: Variant = back.get_meta("media_inner_rect", null)
        var image_inner: Variant = image.get_meta("media_inner_rect", null)
        var button_inner: Variant = button.get_meta("media_inner_rect", null)
        if not (back_inner is Rect2) or not (image_inner is Rect2) or not (button_inner is Rect2):
            push_error("HUD visual matrix: %s card %d missing media inner rect metadata." % [label, i])
            quit(1)
            return false
        var back_inner_rect: Rect2 = back_inner
        var image_inner_rect: Rect2 = image_inner
        var button_inner_rect: Rect2 = button_inner
        if back_inner_rect.position.distance_to(expected_inner.position) > 0.25 or image_inner_rect.size.distance_to(expected_inner.size) > 0.25 or button_inner_rect.size.distance_to(expected_inner.size) > 0.25:
            push_error("HUD visual matrix: %s card %d media inner rect metadata mismatch." % [label, i])
            quit(1)
            return false
        var slot_center: Variant = back.get_meta("media_slot_center", null)
        var image_slot_center: Variant = image.get_meta("media_slot_center", null)
        if slot_center == null or image_slot_center == null:
            push_error("HUD visual matrix: %s card %d missing media slot metadata." % [label, i])
            quit(1)
            return false
        if not (slot_center is Vector2) or not (image_slot_center is Vector2):
            push_error("HUD visual matrix: %s card %d media slot metadata is not Vector2." % [label, i])
            quit(1)
            return false
        var back_center: Vector2 = slot_center
        var image_center: Vector2 = image_slot_center
        if back_center.distance_to(image_center) > 0.25:
            push_error("HUD visual matrix: %s card %d media slot center metadata mismatch." % [label, i])
            quit(1)
            return false
    return true

func _expected_media_slot_rect(profile: String) -> Rect2:
    match profile:
        "hero":
            return HERO_MEDIA_SLOT
        "shop":
            return SHOP_MEDIA_SLOT
        "choice":
            return OPTION_MEDIA_SLOT
        _:
            return Rect2()

func _rect_close(a: Rect2, b: Rect2, tolerance := 0.25) -> bool:
    return a.position.distance_to(b.position) <= tolerance and a.size.distance_to(b.size) <= tolerance

func _require_inset_atlas_region(image: TextureRect, label: String, index: int) -> bool:
    var atlas_texture := image.texture as AtlasTexture
    if atlas_texture == null or atlas_texture.atlas == null:
        push_error("HUD visual matrix: %s card %d expected an inset AtlasTexture region." % [label, index])
        quit(1)
        return false
    var cell := Vector2(float(atlas_texture.atlas.get_width()) / 4.0, float(atlas_texture.atlas.get_height()) / 4.0)
    var region := atlas_texture.region
    var cell_rect: Variant = atlas_texture.get_meta("ui_atlas_cell_rect", null)
    if not (cell_rect is Rect2):
        push_error("HUD visual matrix: %s card %d missing atlas cell metadata." % [label, index])
        quit(1)
        return false
    if not bool(atlas_texture.get_meta("ui_atlas_region_center_locked", false)):
        push_error("HUD visual matrix: %s card %d atlas region is not center locked." % [label, index])
        quit(1)
        return false
    var declared_cell: Rect2 = cell_rect
    if region.get_center().distance_to(declared_cell.get_center()) > 0.25:
        push_error("HUD visual matrix: %s card %d atlas region center drifted: region=%s cell=%s." % [label, index, str(region), str(declared_cell)])
        quit(1)
        return false
    var inset := float(atlas_texture.get_meta("ui_atlas_safe_inset_px", -1.0))
    if inset < 4.0:
        push_error("HUD visual matrix: %s card %d atlas safe inset is too small: %.2f." % [label, index, inset])
        quit(1)
        return false
    if region.size.x >= cell.x or region.size.y >= cell.y:
        push_error("HUD visual matrix: %s card %d atlas region was not inset: region=%s cell=%s." % [label, index, str(region), str(cell)])
        quit(1)
        return false
    if fmod(region.position.x, cell.x) <= 0.01 or fmod(region.position.y, cell.y) <= 0.01:
        push_error("HUD visual matrix: %s card %d atlas region starts on a raw cell edge, risking adjacent-cell bleed." % [label, index])
        quit(1)
        return false
    return true

func _require_portrait_focus_region(image: TextureRect, label: String, index: int) -> bool:
    var atlas_texture := image.texture as AtlasTexture
    if atlas_texture == null or atlas_texture.atlas == null:
        push_error("HUD visual matrix: %s card %d expected a focused AtlasTexture portrait region." % [label, index])
        quit(1)
        return false
    var source_size := Vector2(float(atlas_texture.atlas.get_width()), float(atlas_texture.atlas.get_height()))
    var region := atlas_texture.region
    if not bool(atlas_texture.get_meta("portrait_focus_square", false)):
        push_error("HUD visual matrix: %s card %d portrait crop is not square." % [label, index])
        quit(1)
        return false
    if absf(region.size.x - region.size.y) > 1.0:
        push_error("HUD visual matrix: %s card %d portrait crop would be recropped in the square media slot: %s." % [label, index, str(region)])
        quit(1)
        return false
    if region.size.x >= source_size.x * 0.90 or region.size.y >= source_size.y * 0.90:
        push_error("HUD visual matrix: %s card %d portrait still uses the full source image instead of a focus crop." % [label, index])
        quit(1)
        return false
    if region.size.x < source_size.x * 0.55 or region.size.y < source_size.y * 0.62:
        push_error("HUD visual matrix: %s card %d portrait crop is too tight for readable identity art." % [label, index])
        quit(1)
        return false
    return true
