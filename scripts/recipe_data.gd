extends RefCounted
class_name CinnaRecipeData

const RECIPES := {
    "ice_mint_storm": {
        "name": "冰薄荷风暴",
        "requires": ["mint", "ice", "bubble"],
        "desc": "冲刺时释放清凉冰雾，对身边敌人造成 1 点伤害，并获得额外速度。"
    },
    "cinnamon_flame_cup": {
        "name": "肉桂火焰杯",
        "requires": ["cinnamon", "lime", "ember"],
        "desc": "攻击附带香料火星，基础伤害 +1，暴击时火花更灿烂。"
    },
    "honey_guard": {
        "name": "蜂蜜护盾",
        "requires": ["honey", "ice"],
        "desc": "受伤后凝出一层蜂蜜冰盾。被打了，也要甜甜地反弹回来。"
    },
    "bubble_crit": {
        "name": "青柠气泡暴击流",
        "requires": ["lime", "bubble", "almond"],
        "desc": "暴击率提高，空中攻击更容易打出双倍伤害。"
    },
    "tavern_tankard": {
        "name": "酒馆厚杯流",
        "requires": ["glass", "copper", "honey"],
        "desc": "最大生命 +1，护盾 +2。像杯壁一样稳，像吧台一样硬。"
    },
    "starry_shaker": {
        "name": "星尘摇壶",
        "requires": ["star_anise", "tonic", "bubble"],
        "desc": "主动技能冷却进一步缩短，技能威力 +1。按下技能键时，整只杯子都像醒了。"
    },
    "golden_toast": {
        "name": "金糖敬酒",
        "requires": ["sugar", "honey", "glass"],
        "desc": "金币收益提高，最大生命 +1。甜味经济学，已被吧台批准。"
    },
    "citrus_barrage": {
        "name": "柑橘连珠",
        "requires": ["lime", "zest", "almond"],
        "desc": "暴击率与技能威力提升。柠檬枪手会把吧台空气打成酸甜烟花。"
    }
}

static func get_name(recipe_id: String) -> String:
    if RECIPES.has(recipe_id):
        return RECIPES[recipe_id]["name"]
    return recipe_id

static func get_desc(recipe_id: String) -> String:
    if RECIPES.has(recipe_id):
        return RECIPES[recipe_id]["desc"]
    return "未知配方"

static func get_requires(recipe_id: String) -> Array:
    if RECIPES.has(recipe_id):
        return RECIPES[recipe_id]["requires"]
    return []

static func discoverable_recipes(inventory: Dictionary, active_recipes: Dictionary) -> Array:
    var newly_available := []
    for recipe_id in RECIPES.keys():
        if active_recipes.has(recipe_id):
            continue
        var ok := true
        for item_id in RECIPES[recipe_id]["requires"]:
            if inventory.get(item_id, 0) <= 0:
                ok = false
                break
        if ok:
            newly_available.append(recipe_id)
    return newly_available
