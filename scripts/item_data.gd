extends RefCounted
class_name CinnaItemData

const RARITIES := {
    "common": {"label": "COMMON", "zh": "普通", "weight": 58, "color": Color(0.76, 0.72, 0.62)},
    "uncommon": {"label": "UNCOMMON", "zh": "少见", "weight": 28, "color": Color(0.42, 0.95, 0.54)},
    "rare": {"label": "RARE", "zh": "稀有", "weight": 11, "color": Color(0.36, 0.74, 1.0)},
    "legendary": {"label": "LEGEND", "zh": "传说", "weight": 3, "color": Color(1.0, 0.66, 0.16)}
}

const ITEMS := {
    "mint": {
        "name": "薄荷叶",
        "desc": "移动速度 +15%，薄荷计数 +1",
        "color": Color(0.23, 0.95, 0.48),
        "icon": "M",
        "price": 35,
        "rarity": "common"
    },
    "ice": {
        "name": "清脆冰块",
        "desc": "获得 1 层护盾。护盾会先抵挡伤害",
        "color": Color(0.75, 0.94, 1.0),
        "icon": "I",
        "price": 30,
        "rarity": "common"
    },
    "lime": {
        "name": "青柠星片",
        "desc": "暴击率提升。好运开始冒泡",
        "color": Color(0.80, 1.0, 0.18),
        "icon": "L",
        "price": 36,
        "rarity": "common"
    },
    "zest": {
        "name": "柠檬皮弹匣",
        "desc": "主动技能威力 +1。酸甜弹片装填完毕",
        "color": Color(1.0, 0.95, 0.18),
        "icon": "Z",
        "price": 54,
        "rarity": "uncommon"
    },
    "honey": {
        "name": "蜂蜜滴",
        "desc": "最大生命 +1 并回复 1 点生命",
        "color": Color(1.0, 0.70, 0.18),
        "icon": "H",
        "price": 38,
        "rarity": "common"
    },
    "cinnamon": {
        "name": "肉桂棒",
        "desc": "攻击伤害 +1。让勺子闻起来很有战斗力",
        "color": Color(0.72, 0.36, 0.15),
        "icon": "C",
        "price": 48,
        "rarity": "uncommon"
    },
    "bubble": {
        "name": "气泡水",
        "desc": "解锁二段跳。杯中宇宙批准你再跳一次",
        "color": Color(0.45, 0.75, 1.0),
        "icon": "B",
        "price": 52,
        "rarity": "uncommon"
    },
    "almond": {
        "name": "杏仁香露",
        "desc": "攻击冷却缩短。勺子挥得像钟表发疯",
        "color": Color(0.93, 0.78, 0.53),
        "icon": "A",
        "price": 50,
        "rarity": "uncommon"
    },
    "vanilla": {
        "name": "香草云",
        "desc": "回复 2 点生命并获得 1 层护盾。软绵绵，但很可靠",
        "color": Color(0.98, 0.90, 0.64),
        "icon": "V",
        "price": 46,
        "rarity": "uncommon"
    },
    "ember": {
        "name": "打火星芯",
        "desc": "冲刺冷却缩短，并让火焰配方更容易成型",
        "color": Color(1.0, 0.22, 0.08),
        "icon": "E",
        "price": 66,
        "rarity": "rare"
    },
    "glass": {
        "name": "厚玻璃杯壁",
        "desc": "最大生命 +1。杯壁厚一点，胆子也大一点",
        "color": Color(0.70, 0.95, 1.0),
        "icon": "G",
        "price": 62,
        "rarity": "rare"
    },
    "copper": {
        "name": "铜制杯底",
        "desc": "护盾 +2，落地时感觉自己有底气",
        "color": Color(0.86, 0.48, 0.20),
        "icon": "T",
        "price": 68,
        "rarity": "rare"
    },
    "tonic": {
        "name": "滋补汤力水",
        "desc": "主动技能冷却缩短 12%。瓶盖打开，脑袋也亮了",
        "color": Color(0.62, 0.88, 1.0),
        "icon": "N",
        "price": 70,
        "rarity": "rare"
    },
    "star_anise": {
        "name": "八角星尘",
        "desc": "主动技能威力 +1。每一角都在认真发光",
        "color": Color(1.0, 0.72, 0.25),
        "icon": "S",
        "price": 96,
        "rarity": "legendary"
    },
    "sugar": {
        "name": "金糖晶",
        "desc": "立即获得金币和分数。甜到系统都开始加班",
        "color": Color(1.0, 0.84, 0.28),
        "icon": "$",
        "price": 88,
        "rarity": "legendary"
    }
}

static func random_item() -> String:
    return random_reward_item(0, "fight")

static func random_reward_item(depth := 0, room_type := "fight") -> String:
    var table := []
    var total_weight := 0
    for item_id in ITEMS.keys():
        var rarity := get_rarity(str(item_id))
        var weight := int(RARITIES[rarity].get("weight", 10))
        if room_type == "elite":
            if rarity == "rare":
                weight += 12 + depth * 2
            elif rarity == "legendary":
                weight += 3 + int(depth / 3)
        elif room_type == "treasure":
            if rarity == "uncommon":
                weight += 8
            elif rarity == "rare":
                weight += 5
        elif room_type == "boss":
            if rarity == "rare" or rarity == "legendary":
                weight += 18
        elif room_type == "shop":
            if rarity == "common":
                weight -= 10
            elif rarity == "rare":
                weight += 8
        if rarity == "legendary" and depth < 4 and room_type != "boss":
            weight = maxi(1, int(weight / 2))
        weight = maxi(1, weight)
        table.append({"id": str(item_id), "weight": weight})
        total_weight += weight
    var roll := randi_range(1, total_weight)
    var cursor := 0
    for entry in table:
        cursor += int(entry["weight"])
        if roll <= cursor:
            return str(entry["id"])
    return "mint"

static func random_shop_item(depth := 0) -> String:
    return random_reward_item(depth, "shop")

static func get_display_name(kind: String) -> String:
    if ITEMS.has(kind):
        return ITEMS[kind]["name"]
    return kind

static func get_desc(kind: String) -> String:
    if ITEMS.has(kind):
        return ITEMS[kind]["desc"]
    return "未知效果"

static func get_color(kind: String) -> Color:
    if ITEMS.has(kind):
        return ITEMS[kind]["color"]
    return Color.WHITE

static func get_icon(kind: String) -> String:
    if ITEMS.has(kind):
        return ITEMS[kind]["icon"]
    return "?"

static func get_price(kind: String) -> int:
    if ITEMS.has(kind):
        return int(ITEMS[kind]["price"])
    return 35

static func get_rarity(kind: String) -> String:
    if ITEMS.has(kind):
        return str(ITEMS[kind].get("rarity", "common"))
    return "common"

static func get_rarity_label(kind: String) -> String:
    var rarity := get_rarity(kind)
    if RARITIES.has(rarity):
        return str(RARITIES[rarity].get("label", rarity.to_upper()))
    return rarity.to_upper()

static func get_rarity_zh(kind: String) -> String:
    var rarity := get_rarity(kind)
    if RARITIES.has(rarity):
        return str(RARITIES[rarity].get("zh", rarity))
    return rarity

static func get_rarity_color(kind: String) -> Color:
    var rarity := get_rarity(kind)
    if RARITIES.has(rarity):
        return RARITIES[rarity].get("color", Color.WHITE)
    return Color.WHITE

static func get_sortable_item_ids() -> Array:
    var ids := ITEMS.keys()
    ids.sort()
    return ids
