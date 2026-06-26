extends RefCounted
class_name CinnaCharacterData

const CHARACTERS := {
    "bartender": {
        "name": "小调酒师",
        "tag": "平衡型 / 推荐开局",
        "desc": "生命、速度、伤害都均衡，开局自带一滴蜂蜜。主动技能：摇壶爆发，近距离范围伤害。",
        "health_bonus": 0,
        "shield_bonus": 0,
        "speed_mult": 1.00,
        "damage_bonus": 0,
        "gold_bonus": 0,
        "double_jump": false,
        "starting_items": ["honey"],
        "active_skill": "shaker_burst",
        "skill_name": "摇壶爆发",
        "skill_cooldown": 5.8,
        "body_color": Color(0.95, 0.74, 0.35),
        "apron_color": Color(0.52, 0.94, 0.62),
        "hat_color": Color(0.96, 0.96, 0.86)
    },
    "ice_knight": {
        "name": "冰块骑士",
        "tag": "防御型 / 新手稳杯",
        "desc": "生命和护盾更高，速度慢一点。主动技能：冰杯守护，获得护盾并震开近身敌人。",
        "health_bonus": 1,
        "shield_bonus": 2,
        "speed_mult": 0.92,
        "damage_bonus": 0,
        "gold_bonus": 0,
        "double_jump": false,
        "starting_items": ["ice"],
        "active_skill": "ice_guard",
        "skill_name": "冰杯守护",
        "skill_cooldown": 7.2,
        "body_color": Color(0.78, 0.94, 1.0),
        "apron_color": Color(0.44, 0.78, 1.0),
        "hat_color": Color(0.90, 1.0, 1.0)
    },
    "mint_ninja": {
        "name": "薄荷忍者",
        "tag": "机动型 / 高速构筑",
        "desc": "速度更快并自带二段跳，但最大生命少一点。主动技能：薄荷闪身，瞬移穿梭并造成落点伤害。",
        "health_bonus": -1,
        "shield_bonus": 0,
        "speed_mult": 1.16,
        "damage_bonus": 0,
        "gold_bonus": 4,
        "double_jump": true,
        "starting_items": ["mint"],
        "active_skill": "mint_blink",
        "skill_name": "薄荷闪身",
        "skill_cooldown": 4.6,
        "body_color": Color(0.62, 0.98, 0.55),
        "apron_color": Color(0.14, 0.55, 0.32),
        "hat_color": Color(0.80, 1.0, 0.38)
    },
    "lemon_gunner": {
        "name": "柠檬枪手",
        "tag": "远程暴击型 / 新手也能风筝",
        "desc": "攻击距离更长，暴击率略高，开局带青柠星片和柠檬皮弹匣。主动技能：青柠连珠，向前方扇形发射酸甜弹幕。",
        "health_bonus": 0,
        "shield_bonus": 0,
        "speed_mult": 1.04,
        "damage_bonus": 0,
        "gold_bonus": 2,
        "double_jump": false,
        "starting_items": ["lime", "zest"],
        "active_skill": "lime_barrage",
        "skill_name": "青柠连珠",
        "skill_cooldown": 5.1,
        "body_color": Color(0.96, 0.92, 0.25),
        "apron_color": Color(0.38, 0.74, 0.18),
        "hat_color": Color(1.0, 0.98, 0.60)
    }
}

static func get_all_ids() -> Array:
    return ["bartender", "ice_knight", "mint_ninja", "lemon_gunner"]

static func has_character(character_id: String) -> bool:
    return CHARACTERS.has(character_id)

static func get_data(character_id: String) -> Dictionary:
    if CHARACTERS.has(character_id):
        return CHARACTERS[character_id]
    return CHARACTERS["bartender"]

static func get_name(character_id: String) -> String:
    return str(get_data(character_id).get("name", character_id))

static func get_tag(character_id: String) -> String:
    return str(get_data(character_id).get("tag", ""))

static func get_desc(character_id: String) -> String:
    return str(get_data(character_id).get("desc", ""))

static func get_skill_name(character_id: String) -> String:
    return str(get_data(character_id).get("skill_name", "主动技能"))

static func menu_lines(selected_id: String) -> String:
    var lines := []
    var ids := get_all_ids()
    for i in range(ids.size()):
        var cid := str(ids[i])
        var marker := "▶" if cid == selected_id else " "
        lines.append("%s %d. %s：%s" % [marker, i + 1, get_name(cid), get_tag(cid)])
    lines.append("")
    lines.append("当前角色：%s" % get_name(selected_id))
    lines.append(get_desc(selected_id))
    return _join_lines(lines)

static func _join_lines(lines: Array) -> String:
    var text := ""
    for i in range(lines.size()):
        if i > 0:
            text += "\n"
        text += str(lines[i])
    return text
