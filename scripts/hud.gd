extends CanvasLayer
class_name CinnaHUD

const ItemData := preload("res://scripts/item_data.gd")
const RecipeData := preload("res://scripts/recipe_data.gd")
const MetaProgress := preload("res://scripts/meta_progress.gd")
const AugmentData := preload("res://scripts/hextech_augment_data.gd")
const CharacterData := preload("res://scripts/character_data.gd")
const RouteMapScene := preload("res://scripts/route_map.gd")
const RouteOverlayScene := preload("res://scripts/route_overlay.gd")
const MenuAnimationScene := preload("res://scripts/menu_animation.gd")

var title_label: Label
var stat_label: Label
var room_label: Label
var recipe_label: Label
var message_label: Label
var choice_label: Label
var help_label: Label
var tutorial_label: Label
var skill_bar: ColorRect
var skill_fill: ColorRect
var overlay_rect: ColorRect
var overlay_title: Label
var overlay_body: Label
var overlay_hint: Label
var route_map: CinnaRouteMap
var route_overlay: CinnaRouteOverlay
var menu_animation: CinnaMenuAnimation
var banner_timer := 0.0
var tutorial_timer := 0.0

func _ready() -> void:
    menu_animation = MenuAnimationScene.new()
    menu_animation.z_index = -5
    add_child(menu_animation)

    title_label = _make_label(Vector2(12, 8), 26)
    title_label.text = "CINNA CUP QUEST"
    stat_label = _make_label(Vector2(12, 42), 17)
    room_label = _make_label(Vector2(12, 70), 17)
    recipe_label = _make_label(Vector2(12, 96), 15)
    message_label = _make_label(Vector2(12, 128), 21)
    choice_label = _make_label(Vector2(12, 720), 18)
    choice_label.size = Vector2(516, 145)
    tutorial_label = _make_label(Vector2(12, 640), 16)
    tutorial_label.size = Vector2(516, 68)
    tutorial_label.add_theme_color_override("font_color", Color(0.78, 1.0, 0.62))
    tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    tutorial_label.text = ""
    help_label = _make_label(Vector2(12, 920), 15)
    help_label.text = "A/D move | Space/W jump | J dash | K attack | L/E skill | 1/2/3 route/event | 1-4 char | P pause | C codex | S settings"

    skill_bar = ColorRect.new()
    skill_bar.position = Vector2(12, 116)
    skill_bar.size = Vector2(210, 8)
    skill_bar.color = Color(0.05, 0.035, 0.025, 0.88)
    add_child(skill_bar)
    skill_fill = ColorRect.new()
    skill_fill.position = skill_bar.position
    skill_fill.size = Vector2(0, 8)
    skill_fill.color = Color(0.92, 0.74, 0.26, 0.88)
    add_child(skill_fill)

    route_map = RouteMapScene.new()
    route_map.position = Vector2(332, 158)
    add_child(route_map)
    route_overlay = RouteOverlayScene.new()
    route_overlay.z_index = 40
    add_child(route_overlay)
    _build_overlay()

func _process(delta: float) -> void:
    if banner_timer > 0.0:
        banner_timer -= delta
        if banner_timer <= 0.0:
            message_label.text = ""
    if tutorial_timer > 0.0:
        tutorial_timer -= delta
        if tutorial_timer <= 0.0:
            tutorial_label.text = ""

func _make_label(pos: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.position = pos
    label.size = Vector2(520, 36)
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.66))
    label.add_theme_color_override("font_shadow_color", Color(0.02, 0.01, 0.0))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    add_child(label)
    return label

func _build_overlay() -> void:
    overlay_rect = ColorRect.new()
    overlay_rect.position = Vector2(28, 170)
    overlay_rect.size = Vector2(484, 620)
    overlay_rect.color = Color(0.05, 0.035, 0.03, 0.94)
    overlay_rect.visible = false
    add_child(overlay_rect)

    overlay_title = Label.new()
    overlay_title.position = Vector2(52, 198)
    overlay_title.size = Vector2(436, 60)
    overlay_title.add_theme_font_size_override("font_size", 30)
    overlay_title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.32))
    overlay_title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0))
    overlay_title.add_theme_constant_override("shadow_offset_x", 3)
    overlay_title.add_theme_constant_override("shadow_offset_y", 3)
    overlay_title.visible = false
    add_child(overlay_title)

    overlay_body = Label.new()
    overlay_body.position = Vector2(52, 266)
    overlay_body.size = Vector2(436, 398)
    overlay_body.add_theme_font_size_override("font_size", 17)
    overlay_body.add_theme_color_override("font_color", Color(0.94, 0.91, 0.76))
    overlay_body.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0))
    overlay_body.add_theme_constant_override("shadow_offset_x", 2)
    overlay_body.add_theme_constant_override("shadow_offset_y", 2)
    overlay_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    overlay_body.visible = false
    add_child(overlay_body)

    overlay_hint = Label.new()
    overlay_hint.position = Vector2(52, 690)
    overlay_hint.size = Vector2(436, 78)
    overlay_hint.add_theme_font_size_override("font_size", 18)
    overlay_hint.add_theme_color_override("font_color", Color(0.58, 1.0, 0.58))
    overlay_hint.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0))
    overlay_hint.add_theme_constant_override("shadow_offset_x", 2)
    overlay_hint.add_theme_constant_override("shadow_offset_y", 2)
    overlay_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    overlay_hint.visible = false
    add_child(overlay_hint)

func update_stats(player: CinnaPlayer) -> void:
    var hearts := ""
    for i in range(player.max_health):
        hearts += "♥" if i < player.health else "♡"
    stat_label.text = "%s  盾:%d  金币:%03d  水晶:%d  分:%05d  伤害:%d" % [hearts, player.shield, player.gold, player.hextech_crystals, player.score, player.damage]
    var recipe_names := player.get_recipe_names()
    var skill_text := player.get_skill_status_text()
    if recipe_names.size() == 0:
        recipe_label.text = "Skill: %s  |  Recipes: none" % skill_text
    else:
        recipe_label.text = "Skill: %s  |  Recipes: %s" % [skill_text, _join_inline(recipe_names)]
    skill_fill.size = Vector2(210.0 * player.get_skill_fill(), 8)

func update_room(index: int, total: int, room_type: String, region_name := "") -> void:
    var region_text := "" if region_name == "" else "  |  " + region_name
    room_label.text = "ROOM %d/%d  |  %s%s" % [index + 1, total, _room_label(room_type), region_text]

func update_route_map(index: int, total: int, choices: Array, selected: String, region_name: String) -> void:
    if route_map == null:
        return
    route_map.set_state(index, total, choices, selected, region_name)

func show_route_overlay(title: String, choices: Array, selected: String, region_name: String, index: int, total: int) -> void:
    if route_overlay == null:
        return
    route_overlay.show_routes(title, choices, selected, region_name, index, total)

func hide_route_overlay() -> void:
    if route_overlay == null:
        return
    route_overlay.hide_routes()

func show_message(text: String, duration := 2.2) -> void:
    message_label.text = text
    banner_timer = duration

func show_tutorial_tip(text: String, duration := 6.0) -> void:
    tutorial_label.text = "TIP：" + text
    tutorial_timer = duration

func hide_tutorial() -> void:
    tutorial_label.text = ""
    tutorial_timer = 0.0

func set_permanent_message(text: String) -> void:
    message_label.text = text
    banner_timer = 999999.0

func show_choices(title: String, choices: Array) -> void:
    var text := title
    for i in range(choices.size()):
        text += "\n%d) %s" % [i + 1, choices[i]]
    choice_label.text = text

func hide_choices() -> void:
    choice_label.text = ""

func show_title_menu(meta: Dictionary, selected_character_id := "bartender", settings := {}) -> void:
    _set_menu_animation(true)
    _show_overlay()
    overlay_title.text = "CINNA CUP QUEST"
    overlay_body.text = "杯中冒险 v0.8\n\n新增：主菜单杯影动画、程序化像素 Tileset、第四名角色“柠檬枪手”、通关短演出和更清晰的新手提示。现在这杯不是静止菜单，是一只偷偷冒泡的标题杯。\n\n角色选择：\n%s\n\n局外进度：\nRun：%d   Victory：%d\nBest Score：%05d\nAroma Shards：%d\n\n已解锁开局道具：%s\n\n%s\n\n设置：\n%s" % [
        CharacterData.menu_lines(selected_character_id),
        int(meta.get("runs", 0)),
        int(meta.get("victories", 0)),
        int(meta.get("best_score", 0)),
        int(meta.get("aroma_shards", 0)),
        _starter_text(meta),
        MetaProgress.get_unlock_status_text(meta),
        MetaProgress.get_settings_text(settings)
    ]
    overlay_hint.text = "1/2/3/4：选择角色    Enter：开始新一局    C：图鉴    S：设置"

func show_pause(meta: Dictionary, player: CinnaPlayer) -> void:
    _set_menu_animation(false)
    _show_overlay()
    overlay_title.text = "PAUSED / 暂停"
    overlay_body.text = "小调酒师把勺子插进空气里，游戏世界暂时不再冒泡。\n\n当前分数：%05d\n金币：%d\n生命：%d/%d    护盾：%d\n主动技能：%s\n当前配方：%s\n\n局外香气碎片：%d\n开局解锁：%s" % [
        player.score,
        player.gold,
        player.health,
        player.max_health,
        player.shield,
        player.get_skill_status_text(),
        _player_recipe_text(player),
        int(meta.get("aroma_shards", 0)),
        _starter_text(meta)
    ]
    overlay_hint.text = "P / Enter：继续    1：继续    2：重新开始    3：回主菜单    C：图鉴    S：设置"

func show_summary(won: bool, player: CinnaPlayer, shards: int, unlocks: Array, meta: Dictionary) -> void:
    _set_menu_animation(false)
    _show_overlay()
    overlay_title.text = "VICTORY!" if won else "RUN ENDED"
    var result_text := "香气信标点亮，杯中王国开始闪闪发泡。" if won else "这局倒在吧台边缘，但配方笔记被抢救回来了。"
    var unlock_text := "本次没有新解锁。"
    if unlocks.size() > 0:
        unlock_text = _join_lines(unlocks)
    overlay_body.text = "%s\n\nFinal Score：%05d\n获得香气碎片：+%d\n总香气碎片：%d\nBest Score：%05d\nRun：%d   Victory：%d\n\n本局道具：%s\n本局配方：%s\n\n%s" % [
        result_text,
        player.score,
        shards,
        int(meta.get("aroma_shards", 0)),
        int(meta.get("best_score", 0)),
        int(meta.get("runs", 0)),
        int(meta.get("victories", 0)),
        _inventory_text(player),
        _player_recipe_text(player),
        unlock_text
    ]
    overlay_hint.text = "Enter / R：再来一局    2：回主菜单    C：查看图鉴    S：设置"

func show_codex(meta: Dictionary) -> void:
    _set_menu_animation(false)
    _show_overlay()
    overlay_title.text = "FLAVOR CODEX / 风味图鉴"
    overlay_body.text = "已发现道具：\n%s\n\n已发现配方：\n%s\n\n解锁路线：\n%s" % [
        _discovered_items_text(meta),
        _discovered_recipes_text(meta),
        MetaProgress.get_unlock_status_text(meta)
    ]
    overlay_hint.text = "Esc / Enter / C：返回"

func show_settings(meta: Dictionary, settings: Dictionary) -> void:
    _set_menu_animation(false)
    _show_overlay()
    overlay_title.text = "SETTINGS / 设置"
    overlay_body.text = "用 1 / 2 / 3 切换设置。设置会写入存档。\n\n%s\n\n难度说明：\nCozy：玩家开局 +1 生命上限和 +1 护盾，敌人更软。\nNormal：标准体验。\nSpicy：敌人更硬更快，但给更多分数。\n\n当前局外进度：\nRun：%d   Victory：%d\nBest Score：%05d\nAroma Shards：%d" % [
        MetaProgress.get_settings_text(settings),
        int(meta.get("runs", 0)),
        int(meta.get("victories", 0)),
        int(meta.get("best_score", 0)),
        int(meta.get("aroma_shards", 0))
    ]
    overlay_hint.text = "1：音效开关    2：镜头抖动开关    3：切换难度    Esc / Enter / S：返回"

func show_victory_ceremony(player: CinnaPlayer, region_name: String) -> void:
    _set_menu_animation(false)
    _show_overlay()
    overlay_title.text = "AROMA BEACON LIT!"
    overlay_body.text = "最终信标被点亮，巨大的玻璃杯开始像金色灯塔一样发泡。\n\n%s 举起工具，薄荷精灵吹响青柠小号，冰块朋友把自己敲成礼花，肉桂桥郑重宣布：今天没有加班。\n\nFinal Score Preview：%05d\n当前配方：%s\n所在区域：%s\n\n几秒后进入结算，也可以按 Enter 直接跳过。" % [
        CharacterData.get_name(player.character_id),
        player.score,
        _player_recipe_text(player),
        region_name
    ]
    overlay_hint.text = "Enter / 1：跳过演出并进入结算"

func hide_overlay() -> void:
    _set_menu_animation(false)
    overlay_rect.visible = false
    overlay_title.visible = false
    overlay_body.visible = false
    overlay_hint.visible = false

func _show_overlay() -> void:
    overlay_rect.visible = true
    overlay_title.visible = true
    overlay_body.visible = true
    overlay_hint.visible = true

func _set_menu_animation(value: bool) -> void:
    if menu_animation != null:
        menu_animation.set_enabled(value)

func _room_label(room_type: String) -> String:
    match room_type:
        "fight":
            return "FIGHT"
        "elite":
            return "ELITE"
        "treasure":
            return "TREASURE"
        "rest":
            return "REST"
        "shop":
            return "SHOP"
        "event":
            return "EVENT"
        "shelf_boss":
            return "MID BOSS"
        "boss":
            return "BOSS"
		"hextech_forge":
			return "锻造炉"
		"hextech_shop":
			return "海克斯商店"
    return room_type.to_upper()

func _starter_text(meta: Dictionary) -> String:
    var starters: Array = meta.get("unlocked_starters", [])
    if starters.size() == 0:
        return "暂无。先赚香气碎片，开局口袋会慢慢鼓起来。"
    var names := []
    for item_id in starters:
        names.append(ItemData.get_display_name(str(item_id)))
    return _join_inline(names)

func _inventory_text(player: CinnaPlayer) -> String:
    var names := []
    for item_id in player.inventory.keys():
        var count := int(player.inventory[item_id])
        names.append("[%s] %s x%d" % [ItemData.get_rarity_zh(str(item_id)), ItemData.get_display_name(str(item_id)), count])
    if names.size() == 0:
        return "空空如也。连杯底都在回声。"
    return _join_inline(names)

func _player_recipe_text(player: CinnaPlayer) -> String:
    var names := player.get_recipe_names()
    if names.size() == 0:
        return "暂无"
    return _join_inline(names)

func _discovered_items_text(meta: Dictionary) -> String:
    var items: Array = meta.get("discovered_items", [])
    if items.size() == 0:
        return "还没有发现。进游戏摸一摸配料。"
    var names := []
    for item_id in items:
        names.append("• [%s] %s：%s" % [ItemData.get_rarity_zh(str(item_id)), ItemData.get_display_name(str(item_id)), ItemData.get_desc(str(item_id))])
    return _join_lines(names)

func _discovered_recipes_text(meta: Dictionary) -> String:
    var recipes: Array = meta.get("discovered_recipes", [])
    if recipes.size() == 0:
        return "还没有合成配方。让配料在背包里开小会。"
    var names := []
    for recipe_id in recipes:
        names.append("• %s：%s" % [RecipeData.get_name(str(recipe_id)), RecipeData.get_desc(str(recipe_id))])
    return _join_lines(names)

func _join_inline(values: Array) -> String:
    var text := ""
    for i in range(values.size()):
        if i > 0:
            text += ", "
        text += str(values[i])
    return text

func _join_lines(values: Array) -> String:
    var text := ""
    for i in range(values.size()):
        if i > 0:
            text += "\n"
        text += str(values[i])
    return text
