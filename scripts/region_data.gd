extends RefCounted
class_name CinnaRegionData

const REGIONS := {
    "bar_top": {
        "name": "吧台起点",
        "subtitle": "木纹、杯影和第一批气泡麻烦。",
        "floor_style": "wood",
        "floor_color": Color(0.49, 0.30, 0.16),
        "left_platform_style": "ice",
        "right_platform_style": "mint",
        "bridge_style": "cinnamon",
        "accent": Color(1.0, 0.76, 0.24),
        "enemy_pool": ["bubble", "ice", "lime", "syrup_blob"],
        "start_depth": 0
    },
    "bottle_shelf": {
        "name": "酒瓶货架",
        "subtitle": "瓶塞巡逻、酒液瀑布和垂直小平台。",
        "floor_style": "cinnamon",
        "floor_color": Color(0.33, 0.17, 0.10),
        "left_platform_style": "glass",
        "right_platform_style": "cinnamon",
        "bridge_style": "ice",
        "accent": Color(0.72, 0.32, 0.84),
        "enemy_pool": ["cork", "ice", "lime", "bubble", "spice_imp", "crystal_sentry"],
        "start_depth": 6
    },
    "aroma_shrine": {
        "name": "香气祭坛",
        "subtitle": "最后一盏信标在杯口发烫。",
        "floor_style": "glass",
        "floor_color": Color(0.56, 0.74, 0.84),
        "left_platform_style": "cinnamon",
        "right_platform_style": "ice",
        "bridge_style": "mint",
        "accent": Color(1.0, 0.30, 0.12),
        "enemy_pool": ["boss"],
        "start_depth": 11
    }
}

static func get_region_id(depth: int, total_rooms: int) -> String:
    if depth >= total_rooms - 1:
        return "aroma_shrine"
    if depth >= int(REGIONS["bottle_shelf"]["start_depth"]):
        return "bottle_shelf"
    return "bar_top"

static func get_data(region_id: String) -> Dictionary:
    if REGIONS.has(region_id):
        return REGIONS[region_id]
    return REGIONS["bar_top"]

static func get_name(region_id: String) -> String:
    return str(get_data(region_id).get("name", region_id))

static func get_subtitle(region_id: String) -> String:
    return str(get_data(region_id).get("subtitle", ""))

static func get_enemy_pool(region_id: String) -> Array:
    return get_data(region_id).get("enemy_pool", ["bubble", "ice", "lime"])

static func get_style(region_id: String, key: String) -> String:
    return str(get_data(region_id).get(key, "wood"))

static func get_color(region_id: String, key: String) -> Color:
    return get_data(region_id).get(key, Color(0.49, 0.30, 0.16))
