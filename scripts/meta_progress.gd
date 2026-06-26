extends RefCounted
class_name CinnaMetaProgress

const SAVE_PATH := "user://cinna_progress.cfg"

const STARTER_UNLOCKS := [
    {"shards": 4, "item": "mint", "name": "薄荷开局口袋"},
    {"shards": 8, "item": "ice", "name": "冰块护身符"},
    {"shards": 14, "item": "bubble", "name": "气泡二段跳券"},
    {"shards": 22, "item": "ember", "name": "打火星芯种子"},
    {"shards": 32, "item": "copper", "name": "铜制杯底保险"},
    {"shards": 42, "item": "vanilla", "name": "香草云软垫"},
    {"shards": 54, "item": "tonic", "name": "汤力水技能票"},
    {"shards": 66, "item": "zest", "name": "柠檬皮弹匣许可证"}
]

static func default_meta() -> Dictionary:
    return {
        "version": 8,
        "runs": 0,
        "victories": 0,
        "best_score": 0,
        "total_score": 0,
        "aroma_shards": 0,
        "unlocked_starters": [],
        "discovered_items": [],
        "discovered_recipes": [],
        "settings": {"sound_enabled": true, "screen_shake": true, "difficulty": "normal"}
    }

static func load_meta() -> Dictionary:
    var meta := default_meta()
    var cfg := ConfigFile.new()
    var err := cfg.load(SAVE_PATH)
    if err != OK:
        return meta
    for key in meta.keys():
        meta[key] = cfg.get_value("progress", key, meta[key])
    return meta

static func save_meta(meta: Dictionary) -> void:
    var cfg := ConfigFile.new()
    for key in meta.keys():
        cfg.set_value("progress", key, meta[key])
    cfg.save(SAVE_PATH)

static func reset_meta() -> Dictionary:
    var meta := default_meta()
    save_meta(meta)
    return meta

static func get_settings(meta: Dictionary) -> Dictionary:
    var defaults: Dictionary = default_meta().get("settings", {})
    var settings: Dictionary = meta.get("settings", {})
    for key in defaults.keys():
        if not settings.has(key):
            settings[key] = defaults[key]
    if not ["cozy", "normal", "spicy"].has(str(settings.get("difficulty", "normal"))):
        settings["difficulty"] = "normal"
    meta["settings"] = settings
    return settings

static func set_settings(meta: Dictionary, settings: Dictionary) -> void:
    meta["settings"] = get_settings({"settings": settings})
    save_meta(meta)

static func next_difficulty(current: String) -> String:
    match current:
        "cozy":
            return "normal"
        "normal":
            return "spicy"
        _:
            return "cozy"

static func get_settings_text(settings: Dictionary) -> String:
    var normalized := get_settings({"settings": settings})
    var sound := "开" if bool(normalized.get("sound_enabled", true)) else "关"
    var shake := "开" if bool(normalized.get("screen_shake", true)) else "关"
    var difficulty := str(normalized.get("difficulty", "normal"))
    var difficulty_zh := "标准"
    if difficulty == "cozy":
        difficulty_zh = "轻松"
    elif difficulty == "spicy":
        difficulty_zh = "辛辣"
    return "1. 音效：%s\n2. 镜头抖动：%s\n3. 难度：%s / %s" % [sound, shake, difficulty.to_upper(), difficulty_zh]

static func calculate_shards(won: bool, depth: int, score: int) -> int:
    var shards := 1
    shards += int(score / 350)
    shards += int(maxi(depth, 0) / 2)
    if won:
        shards += 8
    return mini(shards, 24)

static func apply_run_result(meta: Dictionary, won: bool, score: int, depth: int, shards: int) -> Array:
    meta["runs"] = int(meta.get("runs", 0)) + 1
    meta["total_score"] = int(meta.get("total_score", 0)) + score
    meta["best_score"] = maxi(int(meta.get("best_score", 0)), score)
    meta["aroma_shards"] = int(meta.get("aroma_shards", 0)) + shards
    if won:
        meta["victories"] = int(meta.get("victories", 0)) + 1

    var unlock_messages := _apply_threshold_unlocks(meta)
    save_meta(meta)
    return unlock_messages

static func mark_discovered_item(meta: Dictionary, item_id: String) -> void:
    var items: Array = meta.get("discovered_items", [])
    if not items.has(item_id):
        items.append(item_id)
        meta["discovered_items"] = items
        save_meta(meta)

static func mark_discovered_recipe(meta: Dictionary, recipe_id: String) -> void:
    var recipes: Array = meta.get("discovered_recipes", [])
    if not recipes.has(recipe_id):
        recipes.append(recipe_id)
        meta["discovered_recipes"] = recipes
        save_meta(meta)

static func get_starting_items(meta: Dictionary) -> Array:
    var unlocked: Array = meta.get("unlocked_starters", [])
    var result := []
    for item_id in unlocked:
        result.append(str(item_id))
    return result

static func get_unlock_status_text(meta: Dictionary) -> String:
    var lines := []
    var shards := int(meta.get("aroma_shards", 0))
    for unlock in STARTER_UNLOCKS:
        var unlocked: Array = meta.get("unlocked_starters", [])
        var status := "已解锁" if unlocked.has(unlock["item"]) else "需要 %d 香气碎片，当前 %d" % [int(unlock["shards"]), shards]
        lines.append("%s：%s" % [unlock["name"], status])
    if lines.size() == 0:
        return "暂无解锁。"
    return _join_lines(lines)

static func _apply_threshold_unlocks(meta: Dictionary) -> Array:
    var unlocked: Array = meta.get("unlocked_starters", [])
    var shards := int(meta.get("aroma_shards", 0))
    var messages := []
    for unlock in STARTER_UNLOCKS:
        if shards >= int(unlock["shards"]) and not unlocked.has(unlock["item"]):
            unlocked.append(unlock["item"])
            messages.append("新解锁：%s" % [unlock["name"]])
    meta["unlocked_starters"] = unlocked
    return messages

static func _join_lines(lines: Array) -> String:
    var text := ""
    for i in range(lines.size()):
        if i > 0:
            text += "\n"
        text += str(lines[i])
    return text
