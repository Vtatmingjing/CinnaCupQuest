extends RefCounted
class_name CinnaAugmentData

const TIERS := {
    "silver": {"label": "SILVER", "zh": "白银", "color": Color(0.76, 0.76, 0.74)},
    "gold": {"label": "GOLD", "zh": "黄金", "color": Color(1.0, 0.82, 0.14)},
    "prismatic": {"label": "PRISMATIC", "zh": "棱彩", "color": Color(1.0, 0.38, 0.82)}
}

const AUGMENTS := {
    "swift_steps": {
        "name": "迅捷步伐",
        "desc": "移动速度 +15%。",
        "tier": "silver"
    },
    "sturdy_shell": {
        "name": "坚硬杯壳",
        "desc": "最大生命 +2，并立刻回复 2 点生命。",
        "tier": "silver"
    },
    "lucky_find": {
        "name": "好运冒泡",
        "desc": "暴击率 +10%，金币掉落率小幅提高。",
        "tier": "silver"
    },
    "hextech_shield": {
        "name": "海克斯护盾",
        "desc": "立刻获得 2 层护盾。",
        "tier": "silver"
    },
    "quick_hands": {
        "name": "快手调酒",
        "desc": "自动攻击冷却 -15%。",
        "tier": "silver"
    },
    "minty_breeze": {
        "name": "薄荷清风",
        "desc": "拾取范围大幅提高，移动速度小幅提高。",
        "tier": "silver"
    },
    "crystal_pocket": {
        "name": "水晶口袋",
        "desc": "立刻获得 20 金币和 1 层护盾。",
        "tier": "silver"
    },
    "overflowing_cup": {
        "name": "满杯溢出",
        "desc": "伤害 +1，护盾 +1。",
        "tier": "gold"
    },
    "echo_strike": {
        "name": "回响打击",
        "desc": "每 3 次主攻击额外发射一次回响汤勺。",
        "tier": "gold"
    },
    "vampiric_spoon": {
        "name": "吸血汤勺",
        "desc": "击败精英敌人时回复 2 点生命。",
        "tier": "gold"
    },
    "crystal_armor": {
        "name": "水晶甲胄",
        "desc": "每次受到生命伤害时减免 1 点。",
        "tier": "gold"
    },
    "frostfire_combo": {
        "name": "霜火爆裂",
        "desc": "主攻击有 20% 几率附加额外霜火伤害。",
        "tier": "gold"
    },
    "alchemist_touch": {
        "name": "炼金触媒",
        "desc": "金币收益 +30%。",
        "tier": "gold"
    },
    "chain_lightning": {
        "name": "连锁闪电",
        "desc": "主弹体命中时有机会向附近敌人跳跃电弧。",
        "tier": "gold"
    },
    "elite_hunter": {
        "name": "精英猎手",
        "desc": "精英怪掉落更多奖励，你的基础伤害 +1。",
        "tier": "gold"
    },
    "golden_ticket": {
        "name": "黄金购物券",
        "desc": "商店价格降低 25%，金币收益小幅提高。",
        "tier": "gold"
    },
    "orbital_laser": {
        "name": "轨道调酒光束",
        "desc": "立刻获得一层火圈，并提高特殊武器威力。",
        "tier": "gold"
    },
    "cheat_death": {
        "name": "死里逃生",
        "desc": "每局一次，致命伤害会保留 1 点生命并短暂无敌。",
        "tier": "prismatic"
    },
    "double_edged": {
        "name": "双刃鸡尾酒",
        "desc": "造成 2 倍伤害，但受到的生命伤害提高。",
        "tier": "prismatic"
    },
    "rolling_pin": {
        "name": "擀面杖冲刺",
        "desc": "主弹体更大，并额外穿透 2 个敌人。",
        "tier": "prismatic"
    },
    "prismatic_body": {
        "name": "棱彩之躯",
        "desc": "受伤后的无敌时间更长，并获得 4 层护盾。",
        "tier": "prismatic"
    },
    "treasure_sense": {
        "name": "寻宝嗅觉",
        "desc": "金币掉落率和金币掉落数量提高。",
        "tier": "prismatic"
    },
    "mayhem_overdrive": {
        "name": "乱斗过载",
        "desc": "攻击冷却大幅降低，弹体速度提高，但你会更依赖走位。",
        "tier": "prismatic"
    }
}

static func get_data(augment_id: String) -> Dictionary:
    if AUGMENTS.has(augment_id):
        return AUGMENTS[augment_id]
    return {"name": augment_id, "desc": "未知强化。", "tier": "silver"}

static func get_name(augment_id: String) -> String:
    return str(get_data(augment_id).get("name", augment_id))

static func get_desc(augment_id: String) -> String:
    return str(get_data(augment_id).get("desc", "未知效果。"))

static func get_tier(augment_id: String) -> String:
    return str(get_data(augment_id).get("tier", "silver"))

static func get_tier_data(tier: String) -> Dictionary:
    if TIERS.has(tier):
        return TIERS[tier]
    return TIERS["silver"]

static func get_by_tier(tier: String) -> Array:
    var result := []
    for augment_id in AUGMENTS.keys():
        if str(AUGMENTS[augment_id].get("tier", "silver")) == tier:
            result.append(str(augment_id))
    return result

static func get_random_options(count: int, tier: String, exclude: Array = []) -> Array:
    var pool := get_by_tier(tier)
    var available := []
    for augment_id in pool:
        if not exclude.has(augment_id):
            available.append(augment_id)
    if available.size() == 0:
        available = pool.duplicate()
    available.shuffle()

    var result := []
    for i in range(mini(count, available.size())):
        result.append(str(available[i]))

    if result.size() > 0 and tier == "gold" and randf() < 0.15:
        var prismatic_pool := get_by_tier("prismatic")
        if prismatic_pool.size() > 0:
            result[randi() % result.size()] = prismatic_pool[randi() % prismatic_pool.size()]
    return result
