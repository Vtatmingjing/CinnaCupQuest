extends Node2D
class_name CinnaSurvivorPlayer

signal died
signal stats_changed
signal damaged(position: Vector2, amount: int)
signal leveled_up
signal recipe_unlocked(recipe_name: String, desc: String)
signal projectile_requested(position: Vector2, velocity: Vector2, damage: int, radius: float, color: Color, label: String, pierce: int, ttl: float)
signal pulse_requested(position: Vector2, radius: float, damage: int, color: Color)
signal effect_requested(position: Vector2, radius: float, color: Color)
signal zone_requested(position: Vector2, kind: String, radius: float, damage: int, duration: float, tick_interval: float, color: Color, status: String, power: int)

const AugmentData := preload("res://scripts/hextech_augment_data.gd")

const ARENA := Rect2(-1520, -900, 3040, 1800)
const BASE_SPEED := 250.0
const BASE_ATTACK_COOLDOWN := 0.52

const CHAMPIONS := {
    "jinx": {
        "name": "金克丝",
        "title": "枪炮交响",
        "desc": "远程物理射手。机枪快射和鱼骨头火箭交替，击杀后触发罪恶快感。",
        "health": 8,
        "speed": 265.0,
        "damage": 2,
        "cooldown": 0.52,
        "crit": 0.12,
        "pierce": 0,
        "projectile_speed": 650.0,
        "radius": 9.0,
        "body": Color(0.42, 0.82, 1.0),
        "accent": Color(1.0, 0.28, 0.64),
        "hair": Color(0.24, 0.66, 1.0),
        "upgrades": ["jinx_rockets", "jinx_fireworks", "jinx_zoomies"],
        "role": "射手",
        "damage_type": "物理",
        "range_type": "远程",
        "shop_tags": ["physical", "crit", "marksman"]
    },
    "senna": {
        "name": "赛娜",
        "title": "赦除圣枪",
        "desc": "支援型远程射手。慢速重炮穿线、灵魂成长，并周期提供护盾/束缚。",
        "health": 8,
        "speed": 245.0,
        "damage": 3,
        "cooldown": 0.72,
        "crit": 0.08,
        "pierce": 2,
        "projectile_speed": 760.0,
        "radius": 8.0,
        "body": Color(0.12, 0.16, 0.16),
        "accent": Color(0.55, 1.0, 0.78),
        "hair": Color(0.90, 0.96, 0.90),
        "upgrades": ["senna_souls", "senna_absolution", "senna_laser"],
        "role": "支援射手",
        "damage_type": "混合",
        "range_type": "远程",
        "shop_tags": ["physical", "support", "pierce"]
    },
    "samira": {
        "name": "莎弥拉",
        "title": "连招评分员",
        "desc": "近中距离收割者。远处双枪、贴脸刀舞，评分满后触发炼狱扳机。",
        "health": 9,
        "speed": 280.0,
        "damage": 2,
        "cooldown": 0.42,
        "crit": 0.15,
        "pierce": 0,
        "projectile_speed": 610.0,
        "radius": 7.5,
        "body": Color(0.80, 0.24, 0.20),
        "accent": Color(1.0, 0.76, 0.24),
        "hair": Color(0.18, 0.12, 0.10),
        "upgrades": ["samira_combo", "samira_inferno", "samira_daredevil"],
        "role": "近战射手",
        "damage_type": "物理",
        "range_type": "近战",
        "shop_tags": ["physical", "crit", "melee"]
    },
    "viktor": {
        "name": "维克托",
        "title": "光荣进化",
        "desc": "中远程法师。海克斯射线切线，重力场负责控场和聚怪。",
        "health": 8,
        "speed": 238.0,
        "damage": 3,
        "cooldown": 0.58,
        "crit": 0.06,
        "pierce": 1,
        "projectile_speed": 700.0,
        "radius": 7.5,
        "body": Color(0.48, 0.32, 0.72),
        "accent": Color(0.78, 0.92, 1.0),
        "hair": Color(0.88, 0.78, 0.46),
        "upgrades": ["viktor_laser", "viktor_storm", "viktor_hexcore"],
        "role": "法师",
        "damage_type": "魔法",
        "range_type": "远程",
        "shop_tags": ["magic", "haste", "pierce"]
    },
    "xayah": {
        "name": "霞",
        "title": "羽毛回收站",
        "desc": "羽刃布阵射手。普攻留下羽毛，倒钩回收穿线并定身。",
        "health": 8,
        "speed": 270.0,
        "damage": 2,
        "cooldown": 0.49,
        "crit": 0.12,
        "pierce": 1,
        "projectile_speed": 680.0,
        "radius": 7.5,
        "body": Color(0.54, 0.20, 0.62),
        "accent": Color(1.0, 0.36, 0.58),
        "hair": Color(0.82, 0.18, 0.38),
        "upgrades": ["xayah_feathers", "xayah_recall", "xayah_root"],
        "role": "射手",
        "damage_type": "物理",
        "range_type": "远程",
        "shop_tags": ["physical", "crit", "marksman"]
    },
    "mordekaiser": {
        "name": "莫德凯撒",
        "title": "铁男开庭",
        "desc": "近战魔法坦克。大锤贴脸、黑暗起兮环绕，领域里越打越厚。",
        "health": 12,
        "speed": 224.0,
        "damage": 4,
        "cooldown": 0.82,
        "crit": 0.04,
        "pierce": 1,
        "projectile_speed": 520.0,
        "radius": 12.0,
        "body": Color(0.22, 0.42, 0.36),
        "accent": Color(0.58, 1.0, 0.58),
        "hair": Color(0.62, 0.70, 0.66),
        "upgrades": ["morde_darkness", "morde_realm", "morde_iron"],
        "role": "近战坦克",
        "damage_type": "魔法",
        "range_type": "近战",
        "shop_tags": ["tank", "magic", "melee"]
    },
    "teemo": {
        "name": "提莫",
        "title": "峡谷蘑菇摊",
        "desc": "远程陷阱召唤。毒镖风筝、实体蘑菇布雷，致盲削弱敌人威胁。",
        "health": 7,
        "speed": 286.0,
        "damage": 2,
        "cooldown": 0.46,
        "crit": 0.10,
        "pierce": 0,
        "projectile_speed": 640.0,
        "radius": 7.0,
        "body": Color(0.36, 0.58, 0.28),
        "accent": Color(0.82, 0.62, 0.24),
        "hair": Color(0.74, 0.50, 0.26),
        "upgrades": ["teemo_poison", "teemo_shrooms", "teemo_blind"],
        "role": "召唤陷阱",
        "damage_type": "魔法",
        "range_type": "远程",
        "shop_tags": ["summon", "magic", "haste"]
    },
    "aurelion_sol": {
        "name": "奥瑞利安·索尔",
        "title": "龙王星轨",
        "desc": "星界控场法师。星体环绕是主输出，黑洞和彗星靠星尘成长放大。",
        "health": 8,
        "speed": 240.0,
        "damage": 3,
        "cooldown": 0.66,
        "crit": 0.07,
        "pierce": 1,
        "projectile_speed": 600.0,
        "radius": 9.5,
        "body": Color(0.16, 0.28, 0.72),
        "accent": Color(0.92, 0.72, 1.0),
        "hair": Color(0.30, 0.72, 1.0),
        "upgrades": ["asol_stars", "asol_singularity", "asol_comet"],
        "role": "星界法师",
        "damage_type": "魔法",
        "range_type": "远程",
        "shop_tags": ["magic", "summon", "haste"]
    }
}

const UPGRADE_NAMES := {
    "mint_leaf": "迅捷鞋垫",
    "ice_cube": "多兰护盾",
    "cinnamon_stick": "暴风大剑碎片",
    "lime_zest": "飓风弹道",
    "almond_syrup": "攻速小瓶",
    "bubble_water": "纳沃利飞环",
    "ember_spark": "日炎余烬",
    "honey_drop": "治疗宝珠",
    "tonic_splash": "技能急速核心",
    "glass_rim": "穿甲杯沿",
    "star_anise": "暴击星星",
    "mystery_spice": "随机英雄梗",
    "jinx_rockets": "金克丝：鱼骨头营业",
    "jinx_fireworks": "金克丝：烟花别回头",
    "jinx_zoomies": "金克丝：罪恶快感续杯",
    "senna_souls": "赛娜：灵魂收款码",
    "senna_absolution": "赛娜：全场别倒",
    "senna_laser": "赛娜：大枪不讲理",
    "samira_combo": "莎弥拉：S 级表演",
    "samira_inferno": "莎弥拉：近战也算远程",
    "samira_daredevil": "莎弥拉：残血还要秀",
    "viktor_laser": "维克托：直线真理",
    "viktor_storm": "维克托：重力场罚站",
    "viktor_hexcore": "维克托：光荣进化",
    "xayah_feathers": "霞：羽毛库存爆仓",
    "xayah_recall": "霞：倒车请注意",
    "xayah_root": "霞：羽毛排队扎人",
    "morde_darkness": "莫德凯撒：铁锤加班",
    "morde_realm": "莫德凯撒：领域开庭",
    "morde_iron": "莫德凯撒：铁皮更厚",
    "teemo_poison": "提莫：毒镖加料",
    "teemo_shrooms": "提莫：蘑菇摊扩张",
    "teemo_blind": "提莫：致盲小票",
    "asol_stars": "龙王：星轨加班",
    "asol_singularity": "龙王：黑洞吸管",
    "asol_comet": "龙王：彗星账单",
    "physical_hex": "物理海克斯：破甲弹仓",
    "magic_hex": "魔法海克斯：符文过载",
    "tank_hex": "坦克海克斯：巨像核心",
    "summon_hex": "召唤海克斯：自动工坊",
    "melee_hex": "近战海克斯：贴脸开团",
    "marksman_hex": "射手海克斯：风暴弹链",
    "support_hex": "支援海克斯：灵魂补给"
}

var max_health := 8
var health := 8
var shield := 0
var speed := BASE_SPEED
var damage := 2
var score := 0
var gold := 0
var level := 1
var xp := 0
var xp_to_next := 6
var pending_levels := 0
var inventory: Dictionary = {}
var hextech_augments: Dictionary = {}
var recipe_synergies: Dictionary = {}
var league_items: Dictionary = {}

var character_id := "jinx"
var body_color := Color(0.42, 0.82, 1.0)
var accent_color := Color(1.0, 0.28, 0.64)
var hair_color := Color(0.24, 0.66, 1.0)
var character_sprite: Sprite2D
var using_external_sprite := false
var external_sprite_mode := "none"
var sprite_animations: Dictionary = {}
var sprite_current_animation := "idle"
var sprite_frame_size := Vector2.ZERO
var sprite_frame_cursor := 0
var sprite_frame_timer := 0.0
var sprite_fps := 8.0
var sprite_anchor := Vector2(0, -12)
var sprite_flip_with_facing := true

var attack_cooldown := BASE_ATTACK_COOLDOWN
var attack_timer := 0.0
var attack_counter := 0
var skill_timer := 0.0
var invincible_timer := 0.0
var aura_timer := 0.0
var orbit_timer := 0.0
var walk_timer := 0.0
var facing := Vector2.RIGHT
var controls_enabled := false

var hit_radius := 15.0
var pickup_radius := 26.0
var magnet_radius := 150.0
var crit_chance := 0.08
var projectile_speed := 600.0
var projectile_radius := 8.0
var pierce_bonus := 0
var lime_level := 0
var aura_level := 0
var orbit_count := 0
var cooldown_mult := 1.0
var skill_power := 0
var gold_bonus_rate := 1.0
var regen_timer := 0.0
var soul_count := 0
var style_meter := 0
var style_decay_timer := 0.0
var kill_haste_timer := 0.0
var passive_counter := 0
var xayah_feathers: Array = []
var xayah_recall_timer := 0.0
var morde_darkness_hits := 0
var asol_stardust := 0

func _ready() -> void:
    add_to_group("survivor_player")
    character_sprite = Sprite2D.new()
    character_sprite.centered = true
    character_sprite.position = Vector2(0, -12)
    character_sprite.region_enabled = false
    character_sprite.visible = false
    character_sprite.z_index = 2
    add_child(character_sprite)
    set_process(true)
    queue_redraw()

func reset_run(new_character_id := "jinx") -> void:
    max_health = 8
    health = 8
    shield = 0
    speed = BASE_SPEED
    damage = 2
    score = 0
    gold = 0
    level = 1
    xp = 0
    xp_to_next = 6
    pending_levels = 0
    inventory.clear()
    hextech_augments.clear()
    recipe_synergies.clear()
    league_items.clear()
    attack_cooldown = BASE_ATTACK_COOLDOWN
    attack_timer = 0.0
    attack_counter = 0
    skill_timer = 0.0
    invincible_timer = 0.0
    aura_timer = 0.0
    orbit_timer = 0.0
    walk_timer = 0.0
    facing = Vector2.RIGHT
    hit_radius = 15.0
    pickup_radius = 26.0
    magnet_radius = 150.0
    crit_chance = 0.08
    projectile_speed = 600.0
    projectile_radius = 8.0
    pierce_bonus = 0
    lime_level = 0
    aura_level = 0
    orbit_count = 0
    cooldown_mult = 1.0
    skill_power = 0
    gold_bonus_rate = 1.0
    regen_timer = 0.0
    soul_count = 0
    style_meter = 0
    style_decay_timer = 0.0
    kill_haste_timer = 0.0
    passive_counter = 0
    xayah_feathers.clear()
    xayah_recall_timer = 0.0
    morde_darkness_hits = 0
    asol_stardust = 0
    position = ARENA.get_center()
    apply_character(new_character_id)
    stats_changed.emit()
    queue_redraw()

func apply_character(new_character_id: String) -> void:
    character_id = new_character_id if CHAMPIONS.has(new_character_id) else "jinx"
    var data: Dictionary = CHAMPIONS[character_id]
    max_health = int(data.get("health", max_health))
    health = max_health
    speed = float(data.get("speed", speed))
    damage = int(data.get("damage", damage))
    attack_cooldown = float(data.get("cooldown", attack_cooldown))
    crit_chance = float(data.get("crit", crit_chance))
    pierce_bonus = int(data.get("pierce", pierce_bonus))
    projectile_speed = float(data.get("projectile_speed", projectile_speed))
    projectile_radius = float(data.get("radius", projectile_radius))
    body_color = data.get("body", body_color)
    accent_color = data.get("accent", accent_color)
    hair_color = data.get("hair", hair_color)
    _update_external_sprite()
    match character_id:
        "senna":
            magnet_radius += 18.0
        "samira":
            pickup_radius += 4.0
            hit_radius += 2.0
        "viktor":
            skill_power += 1
            skill_timer = 2.4
        "xayah":
            speed *= 1.03
            xayah_recall_timer = 2.2
        "mordekaiser":
            shield += 2
            aura_level = 1
            hit_radius += 4.0
        "teemo":
            magnet_radius += 16.0
            skill_timer = 1.1
        "aurelion_sol":
            orbit_count = 3
            skill_power += 1
            skill_timer = 2.8
        _:
            kill_haste_timer = 1.0

func _update_external_sprite() -> void:
    if character_sprite == null:
        return
    _reset_external_sprite()
    var sheet_path := "res://art/champions/%s_sheet.png" % character_id
    var sheet_meta_path := "res://art/champions/%s_sheet.json" % character_id
    if _try_load_sprite_sheet(sheet_path, sheet_meta_path):
        return
    var sprite_path := "res://art/champions/%s.png" % character_id
    var sprite_meta_path := "res://art/champions/%s.json" % character_id
    _try_load_static_sprite(sprite_path, sprite_meta_path)

func _reset_external_sprite() -> void:
    using_external_sprite = false
    external_sprite_mode = "none"
    sprite_animations.clear()
    sprite_current_animation = "idle"
    sprite_frame_size = Vector2.ZERO
    sprite_frame_cursor = 0
    sprite_frame_timer = 0.0
    sprite_fps = 8.0
    sprite_anchor = Vector2(0, -12)
    sprite_flip_with_facing = true
    if character_sprite != null:
        character_sprite.visible = false
        character_sprite.texture = null
        character_sprite.region_enabled = false
        character_sprite.region_rect = Rect2()
        character_sprite.flip_h = false

func _try_load_static_sprite(sprite_path: String, meta_path: String) -> bool:
    if not ResourceLoader.exists(sprite_path):
        return false
    var texture: Texture2D = load(sprite_path)
    if texture == null:
        return false
    var meta := _load_sprite_meta(meta_path)
    var size := texture.get_size()
    var target_height := float(meta.get("target_height", 74.0))
    var scale_value := target_height / maxf(1.0, size.y)
    sprite_anchor = _read_vector2(meta.get("offset", [0, -12]), Vector2(0, -12))
    sprite_flip_with_facing = bool(meta.get("flip_with_facing", true))
    character_sprite.texture = texture
    character_sprite.region_enabled = false
    character_sprite.scale = Vector2(scale_value, scale_value)
    character_sprite.position = sprite_anchor
    character_sprite.visible = true
    using_external_sprite = true
    external_sprite_mode = "static"
    return true

func _try_load_sprite_sheet(sheet_path: String, meta_path: String) -> bool:
    if not ResourceLoader.exists(sheet_path) or not FileAccess.file_exists(meta_path):
        return false
    var texture: Texture2D = load(sheet_path)
    var meta := _load_sprite_meta(meta_path)
    if texture == null or meta.is_empty():
        return false
    var frame_width := int(meta.get("frame_width", 0))
    var frame_height := int(meta.get("frame_height", 0))
    if frame_width <= 0 or frame_height <= 0:
        return false
    sprite_frame_size = Vector2(frame_width, frame_height)
    sprite_animations = _build_animation_dict(meta.get("animations", {}))
    sprite_fps = maxf(1.0, float(meta.get("fps", 8.0)))
    sprite_anchor = _read_vector2(meta.get("offset", [0, -12]), Vector2(0, -12))
    sprite_flip_with_facing = bool(meta.get("flip_with_facing", true))
    var target_height := float(meta.get("target_height", 74.0))
    var scale_value := target_height / maxf(1.0, sprite_frame_size.y)
    character_sprite.texture = texture
    character_sprite.region_enabled = true
    character_sprite.scale = Vector2(scale_value, scale_value)
    character_sprite.position = sprite_anchor
    character_sprite.visible = true
    using_external_sprite = true
    external_sprite_mode = "sheet"
    _set_sprite_animation("idle", true)
    return true

func _load_sprite_meta(meta_path: String) -> Dictionary:
    if not FileAccess.file_exists(meta_path):
        return {}
    var text := FileAccess.get_file_as_string(meta_path)
    var parsed = JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    return parsed

func _build_animation_dict(raw_animations) -> Dictionary:
    var result: Dictionary = {}
    if typeof(raw_animations) == TYPE_DICTIONARY:
        for key in raw_animations.keys():
            var raw_frames = raw_animations[key]
            if typeof(raw_frames) != TYPE_ARRAY or raw_frames.size() == 0:
                continue
            var frames := []
            for frame in raw_frames:
                frames.append(maxi(0, int(frame)))
            result[str(key)] = frames
    if not result.has("idle"):
        result["idle"] = [0]
    return result

func _read_vector2(value, fallback: Vector2) -> Vector2:
    if typeof(value) == TYPE_ARRAY and value.size() >= 2:
        return Vector2(float(value[0]), float(value[1]))
    return fallback

func _set_sprite_animation(animation_name: String, force := false) -> void:
    if external_sprite_mode != "sheet":
        return
    var next_animation := animation_name
    if not sprite_animations.has(next_animation):
        next_animation = "idle"
    if not force and sprite_current_animation == next_animation:
        return
    sprite_current_animation = next_animation
    sprite_frame_cursor = 0
    sprite_frame_timer = 0.0
    var frames: Array = sprite_animations.get(sprite_current_animation, [0])
    _apply_sprite_frame(int(frames[0]))

func _apply_sprite_frame(frame_index: int) -> void:
    if character_sprite == null or character_sprite.texture == null or sprite_frame_size == Vector2.ZERO:
        return
    var texture_size := character_sprite.texture.get_size()
    var columns := maxi(1, int(texture_size.x / sprite_frame_size.x))
    var column := frame_index % columns
    var row := int(frame_index / columns)
    character_sprite.region_rect = Rect2(Vector2(column * sprite_frame_size.x, row * sprite_frame_size.y), sprite_frame_size)

func set_controls_enabled(value: bool) -> void:
    controls_enabled = value

func _process(delta: float) -> void:
    attack_timer = maxf(0.0, attack_timer - delta)
    skill_timer = maxf(0.0, skill_timer - delta)
    invincible_timer = maxf(0.0, invincible_timer - delta)
    aura_timer = maxf(0.0, aura_timer - delta)
    orbit_timer = maxf(0.0, orbit_timer - delta)
    kill_haste_timer = maxf(0.0, kill_haste_timer - delta)
    xayah_recall_timer = maxf(0.0, xayah_recall_timer - delta)
    if style_meter > 0:
        style_decay_timer -= delta
        if style_decay_timer <= 0.0:
            style_decay_timer = 1.25
            style_meter = maxi(0, style_meter - 1)
    regen_timer += delta
    if controls_enabled:
        _move(delta)
        _tick_weapons(delta)
    _update_external_sprite_animation(delta)
    queue_redraw()

func _update_external_sprite_animation(delta: float) -> void:
    if not using_external_sprite or character_sprite == null:
        return
    var blink_hidden := invincible_timer > 0.0 and int(invincible_timer * 18.0) % 2 == 0
    character_sprite.visible = not blink_hidden
    var bob := sin(walk_timer * 12.0) * 2.0
    character_sprite.position = sprite_anchor + Vector2(0, bob)
    if sprite_flip_with_facing and absf(facing.x) > 0.05:
        character_sprite.flip_h = facing.x < 0.0
    if external_sprite_mode != "sheet":
        return
    var move_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var next_animation := "walk" if controls_enabled and move_input.length() > 0.05 and sprite_animations.has("walk") else "idle"
    if attack_timer > 0.0 and sprite_animations.has("attack"):
        next_animation = "attack"
    _set_sprite_animation(next_animation)
    var frames: Array = sprite_animations.get(sprite_current_animation, [0])
    if frames.size() <= 1:
        _apply_sprite_frame(int(frames[0]))
        return
    sprite_frame_timer += delta
    var frame_time := 1.0 / maxf(1.0, sprite_fps)
    while sprite_frame_timer >= frame_time:
        sprite_frame_timer -= frame_time
        sprite_frame_cursor = (sprite_frame_cursor + 1) % frames.size()
        _apply_sprite_frame(int(frames[sprite_frame_cursor]))

func _move(delta: float) -> void:
    var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if dir.length() > 0.01:
        facing = dir.normalized()
        walk_timer += delta
    var effective_speed := speed
    if kill_haste_timer > 0.0:
        effective_speed *= 1.25
    if character_id == "samira" and style_meter >= 4:
        effective_speed *= 1.08
    var target := position + dir * effective_speed * delta
    target.x = clampf(target.x, ARENA.position.x, ARENA.end.x)
    target.y = clampf(target.y, ARENA.position.y, ARENA.end.y)
    position = target

func _tick_weapons(delta: float) -> void:
    _tick_champion_skill(delta)
    var target := _nearest_enemy()
    if attack_timer <= 0.0 and target != null:
        attack_timer = _effective_attack_cooldown()
        _fire_weapon(target.global_position)
    if character_id == "xayah" and xayah_recall_timer <= 0.0 and xayah_feathers.size() > 0:
        _recall_xayah_feathers()
    if aura_level > 0 and aura_timer <= 0.0:
        aura_timer = maxf(0.54, 1.22 - aura_level * 0.08)
        var aura_color := Color(0.34, 1.0, 0.54, 0.28) if character_id == "mordekaiser" else Color(1.0, 0.36, 0.10, 0.30)
        pulse_requested.emit(global_position, 76.0 + aura_level * 13.0, damage + aura_level + skill_power, aura_color)
    if orbit_count > 0 and orbit_timer <= 0.0:
        orbit_timer = 0.34
        _tick_orbits()

func _tick_champion_skill(_delta: float) -> void:
    if skill_timer > 0.0:
        return
    match character_id:
        "senna":
            var absolution_level := _upgrade_count("senna_absolution")
            skill_timer = maxf(3.6, 7.0 - absolution_level * 0.55)
            shield += 1 + int(absolution_level / 2)
            if health < max_health and absolution_level >= 1:
                heal(1)
            var target := _nearest_enemy()
            if target != null:
                var dir := (target.global_position - global_position).normalized()
                _emit_projectile(dir, damage + skill_power + int(soul_count / 7) + absolution_level, projectile_radius + 2.0, Color(0.80, 1.0, 0.92), "senna_snare", pierce_bonus + 2, projectile_speed * 0.78, 1.45)
            effect_requested.emit(global_position, 126.0, Color(0.54, 1.0, 0.76, 0.18))
        "viktor":
            var storm_level := _upgrade_count("viktor_storm")
            var hex_level := _upgrade_count("viktor_hexcore")
            skill_timer = maxf(2.8, 6.0 - storm_level * 0.55 - hex_level * 0.22)
            var target := _nearest_enemy()
            var center := target.global_position if target != null else global_position + facing * 180.0
            _request_zone(center, "viktor_gravity", 118.0 + storm_level * 18.0, damage + skill_power + hex_level, 3.0 + storm_level * 0.35, 0.58, Color(0.58, 0.82, 1.0, 0.26), "slow", storm_level + hex_level)
        "mordekaiser":
            var realm_level := _upgrade_count("morde_realm")
            skill_timer = maxf(3.4, 7.2 - realm_level * 0.55)
            shield += 1 + int(realm_level / 2)
            _request_zone(global_position, "morde_realm", 132.0 + realm_level * 18.0, damage + skill_power + _upgrade_count("morde_darkness"), 2.5 + realm_level * 0.35, 0.62, Color(0.40, 1.0, 0.45, 0.22), "weaken", realm_level)
        "teemo":
            var shroom_level := _upgrade_count("teemo_shrooms")
            skill_timer = maxf(2.4, 6.2 - shroom_level * 0.70)
            _place_teemo_mushroom(shroom_level)
        "aurelion_sol":
            var singularity_level := _upgrade_count("asol_singularity")
            skill_timer = maxf(3.4, 6.8 - singularity_level * 0.52 - float(asol_stardust) * 0.025)
            var target := _nearest_enemy()
            var center := target.global_position if target != null else global_position + facing * 210.0
            _request_zone(center, "asol_singularity", 122.0 + singularity_level * 20.0 + asol_stardust * 1.8, damage + skill_power + _upgrade_count("asol_stars"), 3.2 + singularity_level * 0.35, 0.62, Color(0.64, 0.34, 1.0, 0.25), "slow", singularity_level + int(asol_stardust / 5))
        _:
            pass

func _effective_attack_cooldown() -> float:
    var cd := attack_cooldown * cooldown_mult
    if kill_haste_timer > 0.0:
        cd *= 0.72
    if character_id == "viktor":
        cd *= maxf(0.78, 1.0 - _upgrade_count("viktor_hexcore") * 0.05)
    if character_id == "samira" and style_meter >= 5:
        cd *= 0.88
    return maxf(0.16, cd)

func _fire_weapon(target_pos: Vector2) -> void:
    var dir := target_pos - global_position
    if dir.length() < 1.0:
        dir = facing
    dir = dir.normalized()
    facing = dir
    attack_counter += 1
    var target_distance := global_position.distance_to(target_pos)
    match character_id:
        "jinx":
            _fire_jinx(dir)
        "senna":
            _fire_senna(dir)
        "samira":
            _fire_samira(dir, target_distance)
        "viktor":
            _fire_viktor(dir)
        "xayah":
            _fire_xayah(dir)
        "mordekaiser":
            _fire_mordekaiser(dir, target_distance)
        "teemo":
            _fire_teemo(dir)
        "aurelion_sol":
            _fire_asol(dir, target_distance)
        _:
            _emit_projectile(dir, _rolled_damage(damage), projectile_radius, accent_color, "A", pierce_bonus, projectile_speed, 1.35)

func _fire_jinx(dir: Vector2) -> void:
    var rocket_level := _upgrade_count("jinx_rockets")
    var firework_level := _upgrade_count("jinx_fireworks")
    var use_rocket := attack_counter % maxi(3, 5 - mini(2, rocket_level)) == 0
    if use_rocket:
        var rocket_damage := _rolled_damage(damage + rocket_level + int(skill_power / 2) + 1)
        _emit_projectile(dir, rocket_damage, projectile_radius + 3.4 + rocket_level * 0.8, Color(1.0, 0.28, 0.64), "fishbones", pierce_bonus + int(rocket_level / 2), projectile_speed * 0.72, 1.85)
        if firework_level > 0:
            var shots := 2 + mini(3, firework_level)
            for i in range(shots):
                var side := -float(shots - 1) * 0.5 + float(i)
                _emit_projectile(dir.rotated(side * 0.22), maxi(1, rocket_damage - 2), projectile_radius + 0.8, Color(1.0, 0.72, 0.18), "fishbones", pierce_bonus, projectile_speed * 0.64, 1.25)
        attack_timer *= 1.18
        return

    var minigun_shots := 2 + (1 if kill_haste_timer > 0.0 else 0)
    var base_damage := _rolled_damage(damage + int(rocket_level / 2))
    for i in range(minigun_shots):
        var side := -float(minigun_shots - 1) * 0.5 + float(i)
        _emit_projectile(dir.rotated(side * 0.08), base_damage, maxf(5.8, projectile_radius - 1.8), Color(0.42, 0.82, 1.0), "powpow", pierce_bonus, projectile_speed * 1.08, 0.86)
    if firework_level >= 2 and attack_counter % 6 == 0:
        _emit_projectile(dir, base_damage + firework_level, projectile_radius + 2.2, Color(1.0, 0.72, 0.18), "death_rocket", pierce_bonus + 1, projectile_speed * 0.86, 2.0)

func _fire_senna(dir: Vector2) -> void:
    var soul_level := _upgrade_count("senna_souls")
    var laser_level := _upgrade_count("senna_laser")
    var soul_damage := int(soul_count / maxi(3, 6 - soul_level))
    var base_damage := _rolled_damage(damage + soul_damage + laser_level + 1)
    _emit_projectile(dir, base_damage, projectile_radius + 2.4 + laser_level * 0.7, Color(0.55, 1.0, 0.76), "senna_beam", pierce_bonus + 4 + laser_level, projectile_speed * 0.92, 2.05)
    effect_requested.emit(global_position + dir * 88.0, 42.0 + laser_level * 5.0, Color(0.55, 1.0, 0.76, 0.16))
    if laser_level >= 2 and attack_counter % 4 == 0:
        _emit_projectile(dir, maxi(1, base_damage + soul_level), projectile_radius + 3.0, Color(0.90, 1.0, 0.94), "senna_snare", pierce_bonus + 2, projectile_speed * 0.78, 1.75)
    attack_timer *= 1.22

func _fire_samira(dir: Vector2, target_distance: float) -> void:
    var combo_level := _upgrade_count("samira_combo")
    var inferno_level := _upgrade_count("samira_inferno")
    style_meter = mini(10, style_meter + 1 + (1 if combo_level >= 2 else 0))
    style_decay_timer = 1.6 + combo_level * 0.18
    var base_damage := _rolled_damage(damage + inferno_level)

    if target_distance <= 178.0 + combo_level * 10.0:
        _damage_radius(global_position + dir * 54.0, 88.0 + inferno_level * 10.0, base_damage + combo_level, Color(1.0, 0.22, 0.16, 0.23), "")
        if _upgrade_count("samira_daredevil") > 0:
            shield += 1 if style_meter >= 6 and attack_counter % 3 == 0 else 0
    else:
        var shots := 2 + (1 if inferno_level >= 2 and attack_counter % 3 == 0 else 0)
        for i in range(shots):
            var side := -float(shots - 1) * 0.5 + float(i)
            var shot_dir := dir.rotated(side * 0.16)
            _emit_projectile(shot_dir, base_damage, maxf(5.5, projectile_radius - 1.4), Color(1.0, 0.62, 0.22), "samira_pistol", pierce_bonus, projectile_speed * 0.86, 0.68)

    var threshold := maxi(4, 7 - combo_level)
    if style_meter >= threshold:
        style_meter = 0
        _damage_radius(global_position, 116.0 + inferno_level * 18.0, damage + skill_power + combo_level + inferno_level + 2, Color(1.0, 0.22, 0.16, 0.30), "slow")
        for i in range(10):
            var angle := TAU * float(i) / 10.0
            _emit_projectile(Vector2(cos(angle), sin(angle)), maxi(1, base_damage - 1), 6.0, Color(1.0, 0.62, 0.22), "samira_pistol", pierce_bonus, projectile_speed * 0.72, 0.52)

func _fire_viktor(dir: Vector2) -> void:
    var laser_level := _upgrade_count("viktor_laser")
    var hex_level := _upgrade_count("viktor_hexcore")
    var base_damage := _rolled_damage(damage + laser_level + skill_power)
    _emit_projectile(dir, base_damage, projectile_radius + 1.2 + laser_level * 0.45, Color(0.72, 0.94, 1.0), "viktor_laser", pierce_bonus + 2 + laser_level, projectile_speed * 1.18, 1.45)
    effect_requested.emit(global_position + dir * 120.0, 38.0 + laser_level * 5.0, Color(0.72, 0.94, 1.0, 0.15))
    if hex_level > 0 and attack_counter % maxi(2, 5 - hex_level) == 0:
        _request_zone(global_position + dir * 220.0, "viktor_gravity", 92.0 + hex_level * 12.0, maxi(1, base_damage - 1), 2.1 + hex_level * 0.22, 0.64, Color(0.60, 0.68, 1.0, 0.22), "slow", hex_level)

func _fire_xayah(dir: Vector2) -> void:
    var feather_level := _upgrade_count("xayah_feathers")
    var base_damage := _rolled_damage(damage + feather_level)
    var shots := 1 + (1 if feather_level >= 2 and attack_counter % 2 == 0 else 0)
    for i in range(shots):
        var side := -float(shots - 1) * 0.5 + float(i)
        var feather_dir := dir.rotated(side * 0.18)
        _emit_projectile(feather_dir, base_damage, projectile_radius, Color(1.0, 0.34, 0.62), "xayah_feather", pierce_bonus + 1 + int(feather_level / 2), projectile_speed + 10.0, 1.15)
        _remember_xayah_feather(global_position + feather_dir * (245.0 + feather_level * 20.0))
    if _upgrade_count("xayah_recall") > 0 and attack_counter % maxi(3, 6 - _upgrade_count("xayah_recall")) == 0:
        _recall_xayah_feathers()

func _fire_mordekaiser(dir: Vector2, target_distance: float) -> void:
    var dark_level := _upgrade_count("morde_darkness")
    var realm_level := _upgrade_count("morde_realm")
    var iron_level := _upgrade_count("morde_iron")
    var base_damage := _rolled_damage(damage + dark_level + int(skill_power / 2))
    var slam_radius := 104.0 + dark_level * 13.0 + realm_level * 8.0
    var slam_center := global_position + dir * 58.0
    _damage_radius(slam_center, slam_radius, base_damage + (2 if target_distance <= 150.0 else 0), Color(0.34, 1.0, 0.44, 0.25), "weaken")
    morde_darkness_hits += 1
    if morde_darkness_hits >= maxi(2, 4 - dark_level):
        morde_darkness_hits = 0
        _damage_radius(global_position, 128.0 + realm_level * 16.0, damage + dark_level + skill_power, Color(0.34, 1.0, 0.44, 0.22), "slow")
    if iron_level > 0 and attack_counter % 5 == 0:
        shield += 1
        stats_changed.emit()
    attack_timer *= 1.10

func _fire_teemo(dir: Vector2) -> void:
    var poison_level := _upgrade_count("teemo_poison")
    var shroom_level := _upgrade_count("teemo_shrooms")
    var blind_level := _upgrade_count("teemo_blind")
    var base_damage := _rolled_damage(damage + poison_level)
    _emit_projectile(dir, base_damage, projectile_radius, Color(0.70, 1.0, 0.22), "teemo_dart", pierce_bonus + int(poison_level / 2), projectile_speed + 20.0, 1.18)
    if poison_level > 0 and attack_counter % 3 == 0:
        _emit_projectile(dir.rotated(0.12), maxi(1, base_damage - 1), projectile_radius - 0.5, Color(0.44, 0.96, 0.30), "teemo_dart", pierce_bonus, projectile_speed * 0.90, 1.0)
    if blind_level > 0 and attack_counter % maxi(3, 6 - blind_level) == 0:
        _emit_projectile(dir, maxi(1, damage + blind_level), projectile_radius + 1.0, Color(0.92, 0.84, 0.22), "blind_dart", pierce_bonus, projectile_speed * 1.05, 1.0)
    if shroom_level >= 3 and attack_counter % 7 == 0:
        _place_teemo_mushroom(shroom_level)

func _fire_asol(dir: Vector2, _target_distance: float) -> void:
    var star_level := _upgrade_count("asol_stars")
    var comet_level := _upgrade_count("asol_comet")
    var singularity_level := _upgrade_count("asol_singularity")
    var base_damage := _rolled_damage(damage + star_level + skill_power)
    _damage_radius(global_position + dir * 116.0, 72.0 + star_level * 6.0 + asol_stardust * 0.45, base_damage, Color(0.92, 0.72, 1.0, 0.22), "slow")
    if comet_level > 0 and attack_counter % maxi(3, 6 - comet_level) == 0:
        var comet_dir := dir
        _emit_projectile(comet_dir, base_damage + comet_level + int(asol_stardust / 6), projectile_radius + 2.2, Color(1.0, 0.88, 0.42), "comet", pierce_bonus + 2, projectile_speed * 0.82, 1.55)
    if singularity_level >= 2 and attack_counter % maxi(5, 9 - singularity_level) == 0:
        _request_zone(global_position + dir * 210.0, "asol_singularity", 112.0 + singularity_level * 18.0 + asol_stardust * 1.4, damage + skill_power + singularity_level, 2.8, 0.64, Color(0.64, 0.34, 1.0, 0.24), "slow", singularity_level)
    attack_timer *= 1.14

func _emit_projectile(dir: Vector2, final_damage: int, radius: float, color: Color, label: String, pierce: int, speed_value: float, ttl: float) -> void:
    projectile_requested.emit(global_position + dir * 23.0, dir * speed_value, final_damage, radius, color, label, pierce, ttl)

func _emit_projectile_from(start_pos: Vector2, dir: Vector2, final_damage: int, radius: float, color: Color, label: String, pierce: int, speed_value: float, ttl: float) -> void:
    if dir.length() < 0.01:
        dir = facing
    projectile_requested.emit(start_pos, dir.normalized() * speed_value, final_damage, radius, color, label, pierce, ttl)

func _damage_radius(center: Vector2, radius: float, amount: int, color: Color, status := "") -> int:
    var hits := 0
    for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        var enemy_radius := 18.0
        var enemy_hit_radius = enemy.get("hit_radius")
        if enemy_hit_radius != null:
            enemy_radius = float(enemy_hit_radius)
        if center.distance_to(enemy.global_position) > radius + enemy_radius:
            continue
        if enemy.has_method("take_damage"):
            enemy.take_damage(amount, center, false)
        _apply_enemy_status(enemy, status)
        hits += 1
    effect_requested.emit(center, radius, color)
    return hits

func _apply_enemy_status(enemy: Node, status: String) -> void:
    match status:
        "slow":
            if enemy.has_method("apply_slow"):
                enemy.apply_slow(1.0, 0.62)
        "root":
            if enemy.has_method("apply_root"):
                enemy.apply_root(0.56)
        "weaken":
            if enemy.has_method("apply_weaken"):
                enemy.apply_weaken(1.8)
        "poison":
            if enemy.has_method("apply_poison"):
                enemy.apply_poison(3.0, maxi(1, ceili(float(damage) * 0.35)))
        _:
            pass

func _request_zone(pos: Vector2, kind: String, radius: float, zone_damage: int, duration: float, tick_interval: float, color: Color, status := "", power := 1) -> void:
    var clamped := _clamp_to_arena(pos)
    zone_requested.emit(clamped, kind, radius, zone_damage, duration, tick_interval, color, status, power)

func _place_teemo_mushroom(shroom_level: int) -> void:
    var angle := randf_range(-1.25, 1.25)
    var distance := randf_range(105.0, 235.0 + shroom_level * 18.0)
    var pos := global_position + facing.rotated(angle) * distance
    var radius := 82.0 + shroom_level * 16.0
    var zone_damage := 1 + skill_power + _upgrade_count("teemo_poison") + shroom_level
    _request_zone(pos, "teemo_mushroom", radius, zone_damage, 15.0 + shroom_level * 2.0, 0.58, Color(0.52, 1.0, 0.22, 0.24), "poison", shroom_level)
    effect_requested.emit(_clamp_to_arena(pos), 34.0, Color(0.52, 1.0, 0.22, 0.18))

func _remember_xayah_feather(pos: Vector2) -> void:
    var cap := 5 + _upgrade_count("xayah_feathers") * 2
    xayah_feathers.append(_clamp_to_arena(pos))
    while xayah_feathers.size() > cap:
        xayah_feathers.pop_front()
    effect_requested.emit(_clamp_to_arena(pos), 22.0, Color(1.0, 0.34, 0.62, 0.14))

func _recall_xayah_feathers() -> void:
    var recall_level := _upgrade_count("xayah_recall")
    var root_level := _upgrade_count("xayah_root")
    if xayah_feathers.size() == 0:
        xayah_recall_timer = maxf(1.4, 4.4 - recall_level * 0.45)
        return
    var recall_damage := _rolled_damage(damage + root_level + int(_upgrade_count("xayah_feathers") / 2))
    for feather_pos in xayah_feathers:
        var start_pos: Vector2 = feather_pos
        var dir := global_position - start_pos
        if dir.length() < 1.0:
            dir = facing
        _emit_projectile_from(start_pos, dir.normalized(), recall_damage, 7.0 + root_level * 0.6, Color(0.92, 0.28, 1.0), "xayah_recall", pierce_bonus + 2 + root_level, projectile_speed * 0.96, 1.15)
    if root_level > 0:
        _damage_radius(global_position, 78.0 + root_level * 12.0, maxi(1, damage + root_level), Color(1.0, 0.38, 0.74, 0.18), "root")
    xayah_feathers.clear()
    xayah_recall_timer = maxf(1.35, 4.6 - recall_level * 0.55)

func _clamp_to_arena(pos: Vector2) -> Vector2:
    return Vector2(
        clampf(pos.x, ARENA.position.x + 28.0, ARENA.end.x - 28.0),
        clampf(pos.y, ARENA.position.y + 28.0, ARENA.end.y - 28.0)
    )

func _rolled_damage(base: int) -> int:
    var final_damage := base
    var crit_roll := crit_chance
    if character_id == "samira":
        crit_roll += minf(0.16, style_meter * 0.018)
    if randf() < crit_roll:
        final_damage = int(round(float(final_damage) * 1.85))
    if has_hextech_augment("frostfire_combo") and randf() < 0.20:
        final_damage += 2 + int(skill_power / 2)
    if has_hextech_augment("double_edged"):
        final_damage *= 2
    return maxi(1, final_damage)

func _tick_orbits() -> void:
    var angle_base := Time.get_ticks_msec() / 1000.0 * (2.25 if character_id == "aurelion_sol" else 2.8)
    var orbit_radius := 48.0
    var hit_size := 24.0
    var orbit_damage := maxi(1, damage + int(orbit_count / 2))
    if character_id == "aurelion_sol":
        orbit_radius = 70.0 + _upgrade_count("asol_stars") * 8.0 + asol_stardust * 0.6
        hit_size = 30.0 + _upgrade_count("asol_stars") * 1.5
        orbit_damage += skill_power + int(asol_stardust / 6)
    for i in range(orbit_count):
        var angle := angle_base + TAU * float(i) / float(maxi(orbit_count, 1))
        var orb_pos := global_position + Vector2(cos(angle), sin(angle)) * orbit_radius
        for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
            if not is_instance_valid(enemy):
                continue
            if orb_pos.distance_to(enemy.global_position) <= hit_size:
                if enemy.has_method("take_damage"):
                    enemy.take_damage(orbit_damage, orb_pos, false)
                if character_id == "aurelion_sol" and enemy.has_method("apply_slow"):
                    enemy.apply_slow(0.45, 0.76)

func _nearest_enemy() -> Node2D:
    var best: Node2D = null
    var best_dist := INF
    for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        var dist := global_position.distance_squared_to(enemy.global_position)
        if dist < best_dist:
            best = enemy
            best_dist = dist
    return best

func take_damage(amount: int, source_pos := Vector2.ZERO) -> void:
    if invincible_timer > 0.0:
        return
    invincible_timer = 1.25 if has_hextech_augment("prismatic_body") else 0.85

    var remaining := amount
    if character_id == "samira" and _upgrade_count("samira_daredevil") > 0 and health <= max_health / 2:
        remaining = maxi(1, remaining - 1)
        style_meter = mini(10, style_meter + 2)
    if shield > 0:
        var absorbed := mini(shield, remaining)
        shield -= absorbed
        remaining -= absorbed
    if remaining > 0 and has_hextech_augment("crystal_armor"):
        remaining = maxi(0, remaining - 1)
    if remaining > 0 and has_hextech_augment("double_edged"):
        remaining = maxi(1, ceili(float(remaining) * 1.5))
    if remaining > 0 and character_id == "mordekaiser" and _upgrade_count("morde_iron") > 0:
        remaining = maxi(1, remaining - _upgrade_count("morde_iron"))

    if remaining > 0 and health - remaining <= 0 and has_hextech_augment("cheat_death"):
        health = 1
        invincible_timer = 2.0
        shield += 1
        hextech_augments.erase("cheat_death")
        damaged.emit(global_position, 0)
        stats_changed.emit()
        queue_redraw()
        return

    if remaining > 0:
        health -= remaining
    if source_pos != Vector2.ZERO:
        var push := (global_position - source_pos).normalized()
        position += push * 28.0
        position.x = clampf(position.x, ARENA.position.x, ARENA.end.x)
        position.y = clampf(position.y, ARENA.position.y, ARENA.end.y)
    damaged.emit(global_position, amount)
    stats_changed.emit()
    if health <= 0:
        died.emit()

func heal(amount: int) -> void:
    health = mini(max_health, health + amount)
    stats_changed.emit()

func add_score(points: int) -> void:
    score += points
    stats_changed.emit()

func add_gold(amount: int) -> void:
    gold += maxi(0, int(round(float(amount) * gold_bonus_rate)))
    stats_changed.emit()

func try_spend_gold(amount: int) -> bool:
    if gold < amount:
        return false
    gold -= amount
    stats_changed.emit()
    return true

func add_shield(amount: int) -> void:
    shield += maxi(0, amount)
    stats_changed.emit()

func get_shop_discount() -> float:
    var discount := 1.0
    if has_hextech_augment("golden_ticket"):
        discount *= 0.75
    if league_items.has("future_market"):
        discount *= 0.88
    return discount

func add_xp(amount: int) -> void:
    xp += amount
    while xp >= xp_to_next:
        xp -= xp_to_next
        level += 1
        xp_to_next = int(round(float(xp_to_next) * 1.18 + 3.0))
        pending_levels += 1
    stats_changed.emit()
    if pending_levels > 0:
        leveled_up.emit()

func consume_pending_level() -> void:
    pending_levels = maxi(0, pending_levels - 1)

func add_upgrade(upgrade_id: String) -> void:
    inventory[upgrade_id] = int(inventory.get(upgrade_id, 0)) + 1
    match upgrade_id:
        "mint_leaf":
            speed *= 1.10
            magnet_radius += 12.0
        "ice_cube":
            shield += 2
            max_health += 1 if _upgrade_count("ice_cube") >= 3 else 0
        "cinnamon_stick":
            damage += 1
        "lime_zest":
            lime_level += 1
            crit_chance += 0.02
        "almond_syrup":
            cooldown_mult = maxf(0.44, cooldown_mult * 0.90)
        "bubble_water":
            orbit_count = mini(7, orbit_count + 1)
        "ember_spark":
            aura_level += 1
        "honey_drop":
            max_health += 1
            heal(2)
        "tonic_splash":
            skill_power += 1
            projectile_radius += 0.7
        "glass_rim":
            pierce_bonus += 1
        "star_anise":
            crit_chance = minf(0.60, crit_chance + 0.10)
        "mystery_spice":
            _apply_mystery_spice()
        "physical_hex":
            damage += 1
            pierce_bonus += 1
            crit_chance = minf(0.70, crit_chance + 0.06)
        "magic_hex":
            skill_power += 2
            projectile_radius += 0.8
            aura_level += 1 if _upgrade_count("magic_hex") >= 2 else 0
        "tank_hex":
            max_health += 2
            shield += 3
            cooldown_mult = maxf(0.54, cooldown_mult * 0.96)
        "summon_hex":
            skill_power += 1
            orbit_count = mini(8, orbit_count + 1)
            magnet_radius += 12.0
        "melee_hex":
            aura_level += 1
            shield += 1
            speed *= 1.04
        "marksman_hex":
            lime_level += 1
            cooldown_mult = maxf(0.38, cooldown_mult * 0.92)
            projectile_speed += 30.0
        "support_hex":
            max_health += 1
            shield += 2
            heal(1)
        _:
            if _is_hero_upgrade(upgrade_id):
                _apply_champion_upgrade(upgrade_id)
            else:
                damage += 1
    _check_recipe_synergies()
    stats_changed.emit()
    queue_redraw()

func _apply_champion_upgrade(upgrade_id: String) -> void:
    match upgrade_id:
        "jinx_rockets":
            damage += 1
            projectile_radius += 0.8
        "jinx_fireworks":
            skill_power += 1
        "jinx_zoomies":
            speed *= 1.08
            kill_haste_timer += 1.2
            cooldown_mult = maxf(0.42, cooldown_mult * 0.94)
        "senna_souls":
            soul_count += 3
            pierce_bonus += 1
        "senna_absolution":
            max_health += 1
            heal(1)
            shield += 1
        "senna_laser":
            damage += 1
            projectile_radius += 0.4
        "samira_combo":
            crit_chance = minf(0.66, crit_chance + 0.06)
            cooldown_mult = maxf(0.40, cooldown_mult * 0.94)
        "samira_inferno":
            damage += 1
            skill_power += 1
        "samira_daredevil":
            max_health += 1
            speed *= 1.05
        "viktor_laser":
            damage += 1
            pierce_bonus += 1
        "viktor_storm":
            skill_power += 1
        "viktor_hexcore":
            skill_power += 1
            projectile_speed += 28.0
        "xayah_feathers":
            damage += 1
            pierce_bonus += 1 if _upgrade_count("xayah_feathers") % 2 == 0 else 0
        "xayah_recall":
            projectile_speed += 24.0
            speed *= 1.03
        "xayah_root":
            skill_power += 1
            crit_chance = minf(0.62, crit_chance + 0.05)
        "morde_darkness":
            damage += 1
            aura_level += 1 if _upgrade_count("morde_darkness") >= 2 else 0
        "morde_realm":
            max_health += 1
            shield += 1
        "morde_iron":
            max_health += 2
            shield += 2
            speed *= 0.98
        "teemo_poison":
            damage += 1
            crit_chance = minf(0.62, crit_chance + 0.04)
        "teemo_shrooms":
            skill_power += 1
            magnet_radius += 8.0
        "teemo_blind":
            speed *= 1.06
            shield += 1
        "asol_stars":
            orbit_count = mini(8, orbit_count + 1)
            skill_power += 1
        "asol_singularity":
            skill_power += 1
            projectile_radius += 0.6
        "asol_comet":
            damage += 1
            projectile_speed += 24.0

func add_item_purchase(item_id: String) -> void:
    league_items[item_id] = int(league_items.get(item_id, 0)) + 1
    match item_id:
        "infinity_edge":
            damage += 2
            crit_chance = minf(0.72, crit_chance + 0.18)
        "statikk_shiv":
            add_hextech_augment("chain_lightning")
            projectile_speed += 35.0
        "bloodthirster":
            add_hextech_augment("vampiric_spoon")
            max_health += 2
            heal(2)
        "nashors_tooth":
            cooldown_mult = maxf(0.38, cooldown_mult * 0.82)
            skill_power += 1
        "rabadons_hat":
            skill_power += 3
            projectile_radius += 1.0
        "randuins_omen":
            max_health += 3
            shield += 4
        "runaans_hurricane":
            lime_level += 2
            pierce_bonus += 1
        "zhonyas_hourglass":
            add_hextech_augment("cheat_death")
            shield += 2
        "black_cleaver":
            damage += 1
            pierce_bonus += 2
        "guardian_angel":
            add_hextech_augment("cheat_death")
            max_health += 1
        "future_market":
            gold_bonus_rate *= 1.15
            add_gold(30)
        "warmogs_armor":
            max_health += 4
            heal(4)
            shield += 1
        _:
            damage += 1
    _check_recipe_synergies()
    stats_changed.emit()

func add_hextech_augment(augment_id: String) -> void:
    if hextech_augments.has(augment_id):
        return
    hextech_augments[augment_id] = true
    match augment_id:
        "swift_steps":
            speed *= 1.15
        "sturdy_shell":
            max_health += 2
            heal(2)
        "lucky_find":
            crit_chance = minf(0.65, crit_chance + 0.10)
        "hextech_shield":
            shield += 2
        "quick_hands":
            cooldown_mult = maxf(0.40, cooldown_mult * 0.85)
        "minty_breeze":
            magnet_radius += 58.0
            speed *= 1.06
        "crystal_pocket":
            add_gold(22)
            shield += 1
        "overflowing_cup":
            damage += 1
            shield += 1
        "vampiric_spoon":
            max_health += 1
        "crystal_armor":
            shield += 1
        "frostfire_combo":
            skill_power += 1
        "alchemist_touch":
            gold_bonus_rate *= 1.30
        "chain_lightning":
            skill_power += 1
        "elite_hunter":
            damage += 1
            crit_chance = minf(0.65, crit_chance + 0.05)
        "golden_ticket":
            gold_bonus_rate *= 1.12
        "orbital_laser":
            aura_level += 1
            skill_power += 2
        "cheat_death":
            shield += 1
        "double_edged":
            damage += 1
        "rolling_pin":
            pierce_bonus += 2
            projectile_radius += 1.5
        "prismatic_body":
            max_health += 1
            shield += 4
            heal(1)
        "treasure_sense":
            magnet_radius += 32.0
        "mayhem_overdrive":
            cooldown_mult = maxf(0.36, cooldown_mult * 0.72)
            projectile_speed += 90.0
            crit_chance = minf(0.70, crit_chance + 0.08)
        _:
            damage += 1
    _check_recipe_synergies()
    stats_changed.emit()
    queue_redraw()

func notify_enemy_killed(was_elite: bool, enemy_kind: String) -> void:
    passive_counter += 1
    match character_id:
        "jinx":
            kill_haste_timer = 1.4 + _upgrade_count("jinx_zoomies") * 0.35
            if was_elite or passive_counter % maxi(6, 12 - _upgrade_count("jinx_fireworks")) == 0:
                _emit_projectile(facing, damage + skill_power + _upgrade_count("jinx_rockets") + 3, projectile_radius + 4.0, Color(1.0, 0.42, 0.18), "death_rocket", pierce_bonus + 2, projectile_speed * 0.82, 2.2)
        "senna":
            var chance := 0.16 + _upgrade_count("senna_souls") * 0.08
            if was_elite or randf() < chance:
                soul_count += 1 + (1 if was_elite else 0)
                if soul_count % 5 == 0:
                    damage += 1
                if soul_count % 4 == 0:
                    shield += 1
        "samira":
            style_meter = mini(10, style_meter + 1 + (1 if was_elite else 0))
        "viktor":
            if was_elite or passive_counter % 8 == 0:
                skill_power += 1
        "xayah":
            if was_elite:
                shield += 1 + _upgrade_count("xayah_root")
            elif passive_counter % 9 == 0:
                speed *= 1.01
        "mordekaiser":
            if was_elite:
                shield += 2 + _upgrade_count("morde_iron")
                heal(1)
                skill_power += 1 if _upgrade_count("morde_realm") > 0 else 0
        "teemo":
            if was_elite:
                gold += 4 + _upgrade_count("teemo_shrooms") * 2
            elif passive_counter % maxi(3, 7 - _upgrade_count("teemo_poison")) == 0:
                skill_power += 1
        "aurelion_sol":
            asol_stardust += 2 if was_elite else 1
            if was_elite:
                orbit_count = mini(8, orbit_count + 1)
                skill_power += 1
            elif passive_counter % 10 == 0:
                soul_count += 1
                if soul_count % 3 == 0:
                    damage += 1
    if enemy_kind.begins_with("boss_"):
        add_gold(30)
    stats_changed.emit()

func _apply_mystery_spice() -> void:
    var pool := ["mint_leaf", "ice_cube", "cinnamon_stick", "lime_zest", "almond_syrup", "bubble_water", "ember_spark", "tonic_splash", "glass_rim", "star_anise"]
    var hero_pool := get_hero_upgrade_ids()
    for id in hero_pool:
        pool.append(str(id))
    pool.shuffle()
    for i in range(2):
        add_upgrade(str(pool[i]))

func _check_recipe_synergies() -> void:
    if int(inventory.get("lime_zest", 0)) >= 2 and has_hextech_augment("chain_lightning"):
        _unlock_recipe("charged_hurricane", "电刀飓风", "额外弹道更容易带出连锁闪电，清屏更爽。")
    if int(inventory.get("almond_syrup", 0)) >= 2 and int(inventory.get("star_anise", 0)) >= 1:
        _unlock_recipe("rapid_crit", "攻速暴击流", "攻速和暴击继续提高，主武器开始接管战场。")
    if orbit_count >= 2 and shield >= 2:
        _unlock_recipe("shield_orbit", "护盾飞环流", "飞环围着护盾转，获得额外护盾和飞环。")
    if _upgrade_count("physical_hex") >= 2 and _upgrade_count("marksman_hex") >= 1:
        _unlock_recipe("route_ballistic_storm", "物理路线：弹链风暴", "穿透、暴击和额外弹道继续提高。")
    if _upgrade_count("magic_hex") >= 2 and _upgrade_count("summon_hex") >= 1:
        _unlock_recipe("route_arcane_engine", "法系路线：符文工坊", "技能威力、飞环数量和弹体体积一起成长。")
    if _upgrade_count("tank_hex") >= 2 and _upgrade_count("melee_hex") >= 1:
        _unlock_recipe("route_juggernaut_core", "坦克路线：巨像开团", "近身光环、最大生命和护盾一起强化。")
    if _upgrade_count("support_hex") >= 2 and _upgrade_count("summon_hex") >= 1:
        _unlock_recipe("route_soul_network", "支援路线：灵魂网络", "护盾、拾取范围和回复能力提高，适合稳扎稳打。")
    match character_id:
        "jinx":
            if _upgrade_count("jinx_rockets") >= 2 and _upgrade_count("jinx_fireworks") >= 1:
                _unlock_recipe("jinx_festival", "鱼骨头烟花节", "金克丝火箭更密，击杀后的疯狂时间更长。")
        "senna":
            if soul_count >= 8 and _upgrade_count("senna_laser") >= 1:
                _unlock_recipe("senna_tax", "灵魂到账提醒", "赛娜灵魂转化成额外伤害和穿透。")
        "samira":
            if _upgrade_count("samira_combo") >= 2 and _upgrade_count("samira_inferno") >= 1:
                _unlock_recipe("samira_audition", "全场最佳表演", "莎弥拉评分更容易满，旋风范围扩大。")
        "viktor":
            if _upgrade_count("viktor_hexcore") >= 2 and _upgrade_count("viktor_storm") >= 1:
                _unlock_recipe("viktor_audit", "海克斯审计风暴", "维克托周期重力场更快，技能威力提高。")
        "xayah":
            if _upgrade_count("xayah_recall") >= 1 and _upgrade_count("xayah_root") >= 1:
                _unlock_recipe("xayah_feather_bank", "羽毛银行倒闭", "霞回收羽毛时追加控制脉冲和穿透。")
        "mordekaiser":
            if _upgrade_count("morde_realm") >= 1 and _upgrade_count("morde_iron") >= 1:
                _unlock_recipe("morde_court", "铁男开庭成功", "莫德凯撒领域更大，护盾收益提高。")
        "teemo":
            if _upgrade_count("teemo_poison") >= 1 and _upgrade_count("teemo_shrooms") >= 1:
                _unlock_recipe("teemo_mushroom_market", "提莫蘑菇批发", "蘑菇毒云更频繁，毒镖追加清场脉冲。")
        "aurelion_sol":
            if _upgrade_count("asol_stars") >= 2 and _upgrade_count("asol_singularity") >= 1:
                _unlock_recipe("asol_galaxy_bar", "龙王银河吧台", "星轨数量和黑洞范围提高，后期弹幕更像小宇宙。")

func _unlock_recipe(recipe_id: String, recipe_name: String, desc: String) -> void:
    if recipe_synergies.has(recipe_id):
        return
    recipe_synergies[recipe_id] = {"name": recipe_name, "desc": desc}
    match recipe_id:
        "charged_hurricane":
            lime_level += 1
            skill_power += 1
        "rapid_crit":
            cooldown_mult = maxf(0.36, cooldown_mult * 0.88)
            crit_chance = minf(0.72, crit_chance + 0.08)
        "shield_orbit":
            shield += 3
            orbit_count = mini(8, orbit_count + 1)
        "route_ballistic_storm":
            pierce_bonus += 1
            lime_level += 1
            projectile_speed += 24.0
            crit_chance = minf(0.74, crit_chance + 0.08)
        "route_arcane_engine":
            skill_power += 2
            projectile_radius += 0.8
            orbit_count = mini(8, orbit_count + 1)
        "route_juggernaut_core":
            max_health += 3
            shield += 4
            aura_level += 1
            speed *= 1.03
        "route_soul_network":
            max_health += 1
            shield += 3
            magnet_radius += 36.0
            heal(2)
        "jinx_festival":
            skill_power += 2
            kill_haste_timer += 2.0
        "senna_tax":
            damage += 1
            pierce_bonus += 1
        "samira_audition":
            skill_power += 2
            crit_chance = minf(0.72, crit_chance + 0.06)
        "viktor_audit":
            skill_power += 3
        "xayah_feather_bank":
            pierce_bonus += 1
            skill_power += 1
        "morde_court":
            max_health += 2
            shield += 3
        "teemo_mushroom_market":
            skill_power += 2
            speed *= 1.05
        "asol_galaxy_bar":
            orbit_count = mini(8, orbit_count + 1)
            skill_power += 3
    recipe_unlocked.emit(recipe_name, desc)

func has_hextech_augment(augment_id: String) -> bool:
    return hextech_augments.has(augment_id)

func get_hextech_augment_ids() -> Array:
    var ids := []
    for key in hextech_augments.keys():
        ids.append(str(key))
    return ids

func get_hero_upgrade_ids() -> Array:
    if CHAMPIONS.has(character_id):
        return CHAMPIONS[character_id].get("upgrades", [])
    return []

func get_character_name() -> String:
    if CHAMPIONS.has(character_id):
        return str(CHAMPIONS[character_id].get("name", character_id))
    return character_id

func get_character_title() -> String:
    if CHAMPIONS.has(character_id):
        return str(CHAMPIONS[character_id].get("title", ""))
    return ""

func get_role_label() -> String:
    if CHAMPIONS.has(character_id):
        return str(CHAMPIONS[character_id].get("role", "英雄"))
    return "英雄"

func get_damage_type() -> String:
    if CHAMPIONS.has(character_id):
        return str(CHAMPIONS[character_id].get("damage_type", "混合"))
    return "混合"

func get_range_type() -> String:
    if CHAMPIONS.has(character_id):
        return str(CHAMPIONS[character_id].get("range_type", "远程"))
    return "远程"

func get_shop_tags() -> Array:
    if CHAMPIONS.has(character_id):
        return CHAMPIONS[character_id].get("shop_tags", [])
    return []

func get_shop_price_multiplier(item_tags: Array) -> float:
    var discount := get_shop_discount()
    var hero_tags := get_shop_tags()
    for tag in item_tags:
        if hero_tags.has(str(tag)):
            discount *= 0.88
            break
    return discount

func get_upgrade_summary() -> String:
    if inventory.is_empty():
        return "无"
    var parts := []
    for key in inventory.keys():
        var id := str(key)
        parts.append("%s x%d" % [UPGRADE_NAMES.get(id, id), int(inventory[key])])
    parts.sort()
    return _join_parts(parts)

func get_item_summary() -> String:
    if league_items.is_empty():
        return "无"
    var names := {
        "infinity_edge": "无尽之刃",
        "statikk_shiv": "斯塔缇克电刃",
        "bloodthirster": "饮血剑",
        "nashors_tooth": "纳什之牙",
        "rabadons_hat": "灭世者的帽子",
        "randuins_omen": "兰顿之兆",
        "runaans_hurricane": "卢安娜的飓风",
        "zhonyas_hourglass": "中娅沙漏",
        "black_cleaver": "黑色切割者",
        "guardian_angel": "守护天使",
        "future_market": "未来市场",
        "warmogs_armor": "狂徒铠甲"
    }
    var parts := []
    for key in league_items.keys():
        var id := str(key)
        parts.append("%s x%d" % [names.get(id, id), int(league_items[key])])
    parts.sort()
    return _join_parts(parts)

func get_hextech_summary() -> String:
    if hextech_augments.is_empty():
        return "无"
    var parts := []
    for key in hextech_augments.keys():
        parts.append(AugmentData.get_name(str(key)))
    parts.sort()
    return _join_parts(parts)

func get_recipe_summary() -> String:
    if recipe_synergies.is_empty():
        return "无"
    var parts := []
    for key in recipe_synergies.keys():
        var data: Dictionary = recipe_synergies[key]
        parts.append(str(data.get("name", key)))
    parts.sort()
    return _join_parts(parts)

func get_xp_fill() -> float:
    return clampf(float(xp) / float(maxi(1, xp_to_next)), 0.0, 1.0)

func _upgrade_count(upgrade_id: String) -> int:
    return int(inventory.get(upgrade_id, 0))

func _is_hero_upgrade(upgrade_id: String) -> bool:
    for id in get_hero_upgrade_ids():
        if str(id) == upgrade_id:
            return true
    return false

func _join_parts(parts: Array) -> String:
    var text := ""
    for i in range(parts.size()):
        if i > 0:
            text += "，"
        text += str(parts[i])
    return text

func _draw() -> void:
    if invincible_timer > 0.0 and int(invincible_timer * 18.0) % 2 == 0:
        return
    var outline := Color(0.018, 0.016, 0.026)
    var bob := sin(walk_timer * 12.0) * 2.0
    _draw_ellipse(Vector2(0, 19), 25.0, 8.0, Color(0.00, 0.00, 0.02, 0.38))
    _draw_hero_energy_ring(bob)
    if not using_external_sprite:
        match character_id:
            "jinx":
                _draw_jinx(outline, bob)
            "senna":
                _draw_senna(outline, bob)
            "samira":
                _draw_samira(outline, bob)
            "viktor":
                _draw_viktor(outline, bob)
            "xayah":
                _draw_xayah(outline, bob)
            "mordekaiser":
                _draw_mordekaiser(outline, bob)
            "teemo":
                _draw_teemo(outline, bob)
            "aurelion_sol":
                _draw_asol(outline, bob)
            _:
                _draw_base_hero(outline, bob)
    if shield > 0:
        draw_arc(Vector2.ZERO, 27.0, 0.0, TAU, 32, Color(0.70, 0.96, 1.0, 0.34), 3.0)
    if kill_haste_timer > 0.0:
        draw_arc(Vector2.ZERO, 33.0, -1.2, 1.2, 18, Color(1.0, 0.30, 0.72, 0.55), 3.0)
    if orbit_count > 0:
        var angle_base := Time.get_ticks_msec() / 1000.0 * 2.8
        for i in range(orbit_count):
            var angle := angle_base + TAU * float(i) / float(maxi(orbit_count, 1))
            draw_circle(Vector2(cos(angle), sin(angle)) * 48.0, 6.0, Color(0.44, 0.80, 1.0, 0.85))

func _draw_hero_energy_ring(bob: float) -> void:
    var pulse := 1.0 + sin(Time.get_ticks_msec() / 1000.0 * 3.0) * 0.06
    var base_col := accent_color
    base_col.a = 0.26
    draw_arc(Vector2(0, 12 + bob * 0.15), 29.0 * pulse, 0.0, TAU, 48, base_col, 2.5)
    var bright := accent_color.lightened(0.32)
    bright.a = 0.38
    draw_arc(Vector2(0, 12 + bob * 0.15), 20.0 * pulse, -0.45, PI + 0.45, 32, bright, 2.0)

func _draw_base_hero(outline: Color, bob: float) -> void:
    _draw_champion_core(bob, body_color, accent_color, hair_color, 1.0, false)
    _draw_weapon_line(bob, accent_color, 32.0)

func _draw_jinx(outline: Color, bob: float) -> void:
    var dir := _safe_facing()
    _draw_champion_core(bob, Color(0.26, 0.72, 0.98), Color(1.0, 0.26, 0.62), Color(0.18, 0.62, 1.0), 0.96, false)
    draw_line(Vector2(-12, -35 + bob), Vector2(-28, 12 + bob), Color(0.04, 0.08, 0.14), 8.0)
    draw_line(Vector2(12, -35 + bob), Vector2(28, 12 + bob), Color(0.04, 0.08, 0.14), 8.0)
    draw_line(Vector2(-12, -35 + bob), Vector2(-28, 12 + bob), Color(0.20, 0.72, 1.0), 5.0)
    draw_line(Vector2(12, -35 + bob), Vector2(28, 12 + bob), Color(0.20, 0.72, 1.0), 5.0)
    _draw_weapon_line(bob, Color(1.0, 0.28, 0.64), 29.0)
    var rocket := dir * 43.0 + Vector2(0, -8 + bob)
    var side := dir.rotated(PI * 0.5)
    draw_polygon([rocket + dir * 14.0, rocket + side * 8.0, rocket - dir * 12.0, rocket - side * 8.0], [outline])
    draw_polygon([rocket + dir * 10.0, rocket + side * 5.0, rocket - dir * 8.0, rocket - side * 5.0], [Color(0.15, 0.72, 1.0)])
    draw_line(rocket - side * 6.0, rocket + side * 6.0, Color(1.0, 0.32, 0.64), 3.0)
    _draw_pixel_star(rocket - dir * 17.0, Color(1.0, 0.78, 0.18), 5.5)

func _draw_senna(outline: Color, bob: float) -> void:
    var dir := _safe_facing()
    var side := dir.rotated(PI * 0.5)
    _draw_champion_core(bob, Color(0.08, 0.12, 0.12), Color(0.48, 1.0, 0.76), Color(0.92, 0.98, 0.92), 1.02, false)
    draw_line(Vector2(-17, -31 + bob), Vector2(-23, 10 + bob), Color(0.86, 0.96, 0.88), 5.0)
    var base := Vector2(0, -8 + bob)
    var muzzle := base + dir * 53.0
    draw_line(base - side * 6.0, muzzle - side * 6.0, outline, 12.0)
    draw_line(base - side * 6.0, muzzle - side * 6.0, Color(0.10, 0.17, 0.15), 8.0)
    draw_line(base - side * 8.0, muzzle - side * 8.0, Color(0.48, 1.0, 0.76, 0.55), 3.0)
    draw_circle(muzzle, 10.0, outline)
    draw_circle(muzzle, 6.2, Color(0.55, 1.0, 0.76))
    draw_circle(Vector2(-19, 8 + bob), 6.0, Color(0.55, 1.0, 0.76, 0.70))

func _draw_samira(outline: Color, bob: float) -> void:
    var dir := _safe_facing()
    _draw_cape(bob, Color(0.56, 0.05, 0.04), Color(0.12, 0.02, 0.02))
    _draw_champion_core(bob, Color(0.78, 0.20, 0.16), Color(1.0, 0.74, 0.24), Color(0.16, 0.10, 0.08), 1.0, false)
    draw_rect(Rect2(3, -38 + bob, 12, 20), Color(0.82, 0.12, 0.12))
    _draw_weapon_line(bob, Color(1.0, 0.76, 0.24), 28.0)
    draw_line(Vector2(0, -7 + bob), -dir * 25.0 + Vector2(0, -7 + bob), Color(0.04, 0.03, 0.03), 7.0)
    draw_line(Vector2(0, -7 + bob), -dir * 25.0 + Vector2(0, -7 + bob), Color(1.0, 0.76, 0.24), 4.0)
    if style_meter >= 5:
        draw_arc(Vector2.ZERO, 35.0, -1.9, 1.9, 24, Color(1.0, 0.22, 0.16, 0.55), 4.0)

func _draw_viktor(outline: Color, bob: float) -> void:
    var dir := _safe_facing()
    _draw_champion_core(bob, Color(0.42, 0.25, 0.66), Color(0.72, 0.94, 1.0), Color(0.72, 0.62, 0.34), 1.04, true)
    _draw_iso_block(Vector2(16, -13 + bob), Vector2(9, 25), 5.0, Color(0.22, 0.20, 0.34), outline)
    var claw := Vector2(25, -25 + bob)
    draw_line(Vector2(12, -9 + bob), claw, Color(0.72, 0.94, 1.0), 5.0)
    draw_line(claw, claw + dir.rotated(-0.55) * 18.0, Color(0.72, 0.94, 1.0), 3.0)
    draw_line(claw, claw + dir.rotated(0.55) * 18.0, Color(0.72, 0.94, 1.0), 3.0)
    draw_circle(Vector2(0, -18 + bob), 5.4, Color(0.72, 0.94, 1.0))
    _draw_weapon_line(bob, Color(0.72, 0.94, 1.0), 35.0)

func _draw_xayah(outline: Color, bob: float) -> void:
    _draw_wings(bob, Color(0.38, 0.08, 0.54), Color(1.0, 0.34, 0.62))
    _draw_champion_core(bob, Color(0.50, 0.18, 0.60), Color(1.0, 0.34, 0.62), Color(0.82, 0.18, 0.38), 0.98, false)
    _draw_weapon_line(bob, Color(1.0, 0.34, 0.62), 32.0)
    _draw_feather(Vector2(-27, -4 + bob), -0.7)
    _draw_feather(Vector2(27, -4 + bob), 0.7)

func _draw_mordekaiser(outline: Color, bob: float) -> void:
    var dir := _safe_facing()
    _draw_champion_core(bob, Color(0.18, 0.34, 0.28), Color(0.58, 1.0, 0.58), Color(0.50, 0.58, 0.52), 1.18, true)
    draw_rect(Rect2(-21, -32 + bob, 42, 8), Color(0.58, 1.0, 0.58, 0.42))
    _draw_iso_block(Vector2(-18, -6 + bob), Vector2(10, 24), 4.0, Color(0.10, 0.20, 0.16), outline)
    _draw_iso_block(Vector2(18, -6 + bob), Vector2(10, 24), 4.0, Color(0.10, 0.20, 0.16), outline)
    _draw_weapon_line(bob, Color(0.58, 1.0, 0.58), 33.0)
    var hammer := dir * 40.0 + Vector2(0, -8 + bob)
    _draw_iso_block(hammer, Vector2(22, 18), 5.0, Color(0.35, 0.64, 0.45), outline)

func _draw_teemo(outline: Color, bob: float) -> void:
    _draw_champion_core(bob, Color(0.34, 0.56, 0.28), Color(0.82, 0.62, 0.24), Color(0.72, 0.48, 0.25), 0.86, false)
    draw_rect(Rect2(-21, -38 + bob, 42, 9), outline)
    draw_rect(Rect2(-17, -40 + bob, 34, 8), Color(0.72, 0.48, 0.25))
    draw_rect(Rect2(-11, -32 + bob, 22, 5), Color(0.82, 0.62, 0.24))
    _draw_weapon_line(bob, Color(0.70, 1.0, 0.22), 27.0)
    draw_circle(Vector2(-18, -35 + bob), 5.0, Color(0.92, 0.82, 0.48))
    draw_circle(Vector2(18, -35 + bob), 5.0, Color(0.92, 0.82, 0.48))
    draw_circle(Vector2(-17, 8 + bob), 7.0, outline)
    draw_circle(Vector2(-17, 8 + bob), 5.0, Color(0.86, 0.20, 0.18))
    draw_rect(Rect2(-22, 7 + bob, 10, 4), Color(0.96, 0.86, 0.76))
    _draw_pixel_mushroom(Vector2(18, 13 + bob))

func _draw_asol(outline: Color, bob: float) -> void:
    var spine := [Vector2(-33, 14 + bob), Vector2(-16, -13 + bob), Vector2(9, -21 + bob), Vector2(31, 2 + bob)]
    for i in range(spine.size() - 1):
        draw_line(spine[i], spine[i + 1], outline, 14.0)
    for i in range(spine.size() - 1):
        draw_line(spine[i], spine[i + 1], Color(0.16, 0.28, 0.72), 9.0)
        draw_line(spine[i] + Vector2(-1, -2), spine[i + 1] + Vector2(-1, -2), Color(0.42, 0.82, 1.0, 0.55), 3.0)
    draw_polygon([Vector2(0, -43 + bob), Vector2(20, -16 + bob), Vector2(12, 17 + bob), Vector2(-12, 17 + bob), Vector2(-20, -16 + bob)], [outline])
    draw_polygon([Vector2(0, -36 + bob), Vector2(14, -14 + bob), Vector2(8, 11 + bob), Vector2(-8, 11 + bob), Vector2(-14, -14 + bob)], [Color(0.24, 0.40, 0.86)])
    draw_rect(Rect2(-7, -18 + bob, 14, 6), Color(0.92, 0.72, 1.0))
    draw_circle(Vector2(-6, -20 + bob), 3.0, Color(0.46, 0.82, 1.0))
    draw_circle(Vector2(6, -20 + bob), 3.0, Color(0.46, 0.82, 1.0))
    _draw_weapon_line(bob, Color(0.92, 0.72, 1.0), 34.0)
    for i in range(3):
        var angle := Time.get_ticks_msec() / 1000.0 * 1.8 + TAU * float(i) / 3.0
        _draw_pixel_star(Vector2(cos(angle), sin(angle)) * 31.0, Color(0.80, 0.92, 1.0, 0.88), 4.0)

func _draw_champion_core(bob: float, torso_color: Color, accent: Color, hair: Color, visual_scale: float, armored: bool) -> void:
    var outline := Color(0.018, 0.016, 0.026)
    var torso_size := Vector2(29.0, 35.0) * visual_scale
    if armored:
        torso_size = Vector2(35.0, 41.0) * visual_scale
    _draw_iso_block(Vector2(-7.0 * visual_scale, 6.0 + bob), Vector2(8.0, 18.0) * visual_scale, 3.5 * visual_scale, torso_color.darkened(0.34), outline)
    _draw_iso_block(Vector2(8.0 * visual_scale, 6.0 + bob), Vector2(8.0, 18.0) * visual_scale, 3.5 * visual_scale, torso_color.darkened(0.24), outline)
    _draw_iso_block(Vector2(0.0, -12.0 + bob), torso_size, 7.0 * visual_scale, torso_color, outline)
    draw_rect(Rect2(Vector2(-8.0, -21.0 + bob) * visual_scale, Vector2(16.0, 8.0) * visual_scale), accent)
    draw_line(Vector2(-10.0, -2.0 + bob) * visual_scale, Vector2(10.0, -2.0 + bob) * visual_scale, accent.lightened(0.25), 3.0 * visual_scale)
    _draw_3d_head(Vector2(0.0, -34.0 + bob), 13.0 * visual_scale, hair, accent, outline)
    _draw_iso_block(Vector2(-18.0 * visual_scale, -10.0 + bob), Vector2(8.0, 25.0) * visual_scale, 3.0 * visual_scale, torso_color.darkened(0.18), outline)
    _draw_iso_block(Vector2(18.0 * visual_scale, -10.0 + bob), Vector2(8.0, 25.0) * visual_scale, 3.0 * visual_scale, torso_color.lightened(0.05), outline)

func _draw_3d_head(center: Vector2, radius: float, hair: Color, accent: Color, outline: Color) -> void:
    draw_circle(center + Vector2(2.0, 3.0), radius + 2.5, outline)
    draw_circle(center, radius, Color(0.82, 0.64, 0.50))
    draw_circle(center + Vector2(-4.0, -4.0), radius * 0.34, Color(1.0, 0.84, 0.68, 0.65))
    draw_polygon([
        center + Vector2(-radius, -radius * 0.15),
        center + Vector2(-radius * 0.55, -radius * 0.95),
        center + Vector2(radius * 0.72, -radius * 0.88),
        center + Vector2(radius, -radius * 0.05),
        center + Vector2(radius * 0.38, radius * 0.18),
        center + Vector2(-radius * 0.40, radius * 0.08)
    ], [hair])
    draw_rect(Rect2(center + Vector2(-5.0, -1.0), Vector2(3.0, 3.0)), outline)
    draw_rect(Rect2(center + Vector2(4.0, -1.0), Vector2(3.0, 3.0)), outline)
    draw_line(center + Vector2(-radius * 0.60, radius * 0.55), center + Vector2(radius * 0.60, radius * 0.48), accent.darkened(0.10), 2.0)

func _draw_iso_block(center: Vector2, size: Vector2, depth: float, color: Color, outline: Color) -> void:
    var half := size * 0.5
    var pos := center - half
    var top_shift := Vector2(depth, -depth * 0.72)
    var p0 := pos
    var p1 := pos + Vector2(size.x, 0.0)
    var p2 := pos + size
    var p3 := pos + Vector2(0.0, size.y)
    draw_polygon([p0, p1, p1 + top_shift, p0 + top_shift], [outline])
    draw_polygon([p0 + Vector2(1.0, 1.0), p1 + Vector2(-1.0, 1.0), p1 + top_shift + Vector2(-1.0, 1.0), p0 + top_shift + Vector2(1.0, 1.0)], [color.lightened(0.22)])
    draw_polygon([p1, p2, p2 + top_shift, p1 + top_shift], [outline])
    draw_polygon([p1 + Vector2(-1.0, 1.0), p2 + Vector2(-1.0, -1.0), p2 + top_shift + Vector2(-1.0, -1.0), p1 + top_shift + Vector2(-1.0, 1.0)], [color.darkened(0.25)])
    draw_rect(Rect2(pos, size).grow(2.0), outline)
    draw_rect(Rect2(pos, size), color)
    draw_line(pos + Vector2(3.0, 4.0), pos + Vector2(size.x - 4.0, 2.0), color.lightened(0.30), 2.0)

func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
    var points := []
    var steps := 22
    for i in range(steps):
        var a := TAU * float(i) / float(steps)
        points.append(center + Vector2(cos(a) * rx, sin(a) * ry))
    draw_polygon(points, [color])

func _draw_cape(bob: float, color: Color, outline: Color) -> void:
    draw_polygon([Vector2(-12, -24 + bob), Vector2(-34, 22 + bob), Vector2(-2, 17 + bob), Vector2(9, -20 + bob)], [outline])
    draw_polygon([Vector2(-10, -22 + bob), Vector2(-29, 18 + bob), Vector2(-4, 13 + bob), Vector2(7, -18 + bob)], [color])
    draw_line(Vector2(-12, -16 + bob), Vector2(-26, 15 + bob), color.lightened(0.18), 2.0)

func _draw_wings(bob: float, base: Color, highlight: Color) -> void:
    var outline := Color(0.018, 0.016, 0.026)
    draw_polygon([Vector2(-4, -18 + bob), Vector2(-34, -11 + bob), Vector2(-42, 24 + bob), Vector2(-9, 11 + bob)], [outline])
    draw_polygon([Vector2(4, -18 + bob), Vector2(34, -11 + bob), Vector2(42, 24 + bob), Vector2(9, 11 + bob)], [outline])
    draw_polygon([Vector2(-5, -15 + bob), Vector2(-29, -8 + bob), Vector2(-35, 18 + bob), Vector2(-10, 8 + bob)], [base])
    draw_polygon([Vector2(5, -15 + bob), Vector2(29, -8 + bob), Vector2(35, 18 + bob), Vector2(10, 8 + bob)], [base])
    for i in range(3):
        var y := -7.0 + float(i) * 8.0 + bob
        draw_line(Vector2(-9, y), Vector2(-31, y + 8.0), highlight, 2.0)
        draw_line(Vector2(9, y), Vector2(31, y + 8.0), highlight, 2.0)

func _draw_weapon_line(bob: float, color: Color, length: float) -> void:
    var dir := _safe_facing()
    var start := Vector2(0, -8 + bob)
    var end := start + dir * length
    draw_line(start, end, Color(0.04, 0.03, 0.04), 7.0)
    draw_line(start, end, color, 4.0)

func _safe_facing() -> Vector2:
    var dir := facing.normalized()
    if dir.length() < 0.1:
        return Vector2.RIGHT
    return dir

func _draw_pixel_star(pos: Vector2, color: Color, size: float) -> void:
    draw_polygon([pos + Vector2(0, -size), pos + Vector2(size * 0.38, -size * 0.38), pos + Vector2(size, 0), pos + Vector2(size * 0.38, size * 0.38), pos + Vector2(0, size), pos + Vector2(-size * 0.38, size * 0.38), pos + Vector2(-size, 0), pos + Vector2(-size * 0.38, -size * 0.38)], [color])

func _draw_feather(pos: Vector2, tilt: float) -> void:
    var dir := Vector2(cos(tilt), sin(tilt))
    var side := dir.rotated(PI * 0.5)
    draw_line(pos - dir * 8.0, pos + dir * 11.0, Color(1.0, 0.34, 0.62), 3.0)
    draw_polygon([pos + dir * 8.0, pos - dir * 3.0 + side * 6.0, pos - dir * 1.0 - side * 4.0], [Color(1.0, 0.54, 0.72)])

func _draw_pixel_mushroom(pos: Vector2) -> void:
    draw_circle(pos + Vector2(0, -4), 8.0, Color(0.08, 0.03, 0.03))
    draw_circle(pos + Vector2(0, -4), 6.0, Color(0.86, 0.20, 0.18))
    draw_rect(Rect2(pos.x - 4, pos.y - 3, 8, 10), Color(0.96, 0.86, 0.76))
    draw_circle(pos + Vector2(-3, -6), 1.8, Color(1.0, 0.92, 0.80))
    draw_circle(pos + Vector2(4, -3), 1.6, Color(1.0, 0.92, 0.80))
