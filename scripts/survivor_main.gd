extends Node2D

const PlayerScene := preload("res://scripts/survivor_player.gd")
const EnemyScene := preload("res://scripts/survivor_enemy.gd")
const ProjectileScene := preload("res://scripts/survivor_projectile.gd")
const PickupScene := preload("res://scripts/survivor_pickup.gd")
const HUDScene := preload("res://scripts/survivor_hud.gd")
const BackgroundScene := preload("res://scripts/survivor_background.gd")
const Visual3DScene := preload("res://scripts/survivor_3d_view.gd")
const SoundScene := preload("res://scripts/sound_manager.gd")
const FloatingTextScene := preload("res://scripts/floating_text.gd")
const PulseScene := preload("res://scripts/survivor_pulse.gd")
const DeathBurstScene := preload("res://scripts/survivor_death_burst.gd")
const SpawnRiftScene := preload("res://scripts/survivor_spawn_rift.gd")
const HitSparkScene := preload("res://scripts/survivor_hit_spark.gd")
const ZoneScene := preload("res://scripts/survivor_zone.gd")
const AugmentData := preload("res://scripts/hextech_augment_data.gd")

const ARENA := Rect2(-1520, -900, 3040, 1800)
const BOSS_SPAWN_TIME := 90.0
const SPAWN_TIMER_BASE := 0.26
const SPAWN_TIMER_DECAY := 0.0058
const SPAWN_TIMER_MIN := 0.055
const ELITE_FIRST_TIMER := 2.20
const ELITE_TIMER_BASE := 2.85
const ELITE_TIMER_WAVE_DECAY := 0.56
const ELITE_TIMER_MIN := 0.82
const PRESSURE_SURGE_FIRST_TIMER := 74.0
const PRESSURE_SURGE_TIMER_BASE := 28.0
const PRESSURE_SURGE_TIMER_MIN := 15.0
const MAX_ENEMIES := 60
const MAX_PROJECTILES := 84
const MAX_ZONES := 10
const MAX_PULSES := 14
const MAX_DEATH_BURSTS := 4
const MAX_SPAWN_RIFTS := 3
const MAX_HIT_SPARKS := 3
const MAX_FLOATING_TEXTS := 12
const MAX_PICKUPS := 60
const PERF_GUARD_INTERVAL := 0.35
const SPAWN_MIN_RADIUS := 560.0
const SPAWN_MAX_RADIUS := 820.0
const CHAMPION_ORDER := ["jinx", "senna", "samira", "viktor", "xayah", "mordekaiser", "teemo", "aurelion_sol"]

const HEXTECH_FORGE_TIMES := [42.0, 108.0, 186.0, 286.0]
const SHOP_TIMES := [70.0, 150.0, 240.0, 330.0]
const RANDOM_EVENT_TIMES := [55.0, 132.0, 218.0, 310.0]

const RUN_FATES := {
	"prismatic_party": {
		"name": "棱彩乱斗局",
		"desc": "开局获得乱斗过载和一项随机英雄专属升级，但虚空压力更早抬头。",
		"message": "这局开局就很吵。"
	},
	"elite_contract": {
		"name": "虚空悬赏令",
		"desc": "开局获得精英猎手，精英怪更早出现，击败后掉落更多奖励。",
		"message": "看见紫色大个子就别手软。"
	},
	"market_day": {
		"name": "海克斯购物节",
		"desc": "开局金币 +60，商店更早出现，并获得购物折扣。",
		"message": "经济领先也是输出。"
	},
	"swarm_alarm": {
		"name": "虚空虫潮",
		"desc": "敌人更多，但经验和金币掉落更好，适合想快速成型的局。",
		"message": "怪多，升级也快。"
	},
	"starfall": {
		"name": "星界坠落",
		"desc": "开局获得轨道光束和一层飞环，技能流更容易启动。",
		"message": "屏幕会慢慢变成天文馆。"
	},
	"yordle_mischief": {
		"name": "约德尔恶作剧",
		"desc": "开局获得速度、随机金币和一个英雄专属升级，随机事件更容易给惊喜。",
		"message": "不一定强，但肯定有活。"
	}
}

const EXTRA_RUN_FATES := {
	"signature_draft": {
		"name": "专属训练赛",
		"desc": "本局升级池更偏向当前英雄的专属技能，开局立刻获得一项专属升级。",
		"message": "这一把先把英雄特色拉满。"
	},
	"black_market": {
		"name": "地下装备局",
		"desc": "商店更早出现，当前英雄路线装备获得额外折扣，推荐货架更稳定。",
		"message": "钱要花在能成型的地方。"
	},
	"unstable_forge": {
		"name": "不稳定海克斯炉",
		"desc": "海克斯锻造品质提前一档，但虚空压力和奖励都会提高。",
		"message": "赌一手大的，别站着发呆。"
	},
	"void_rivalry": {
		"name": "虚空宿敌悬赏",
		"desc": "精英更早出现，首个精英必定携带宝藏特质，击败精英的收益更高。",
		"message": "大个子身上真的有货。"
	}
}

const UPGRADES := {
	"mint_leaf": {"name": "轻灵之靴垫", "desc": "移动速度提高，拾取范围提高。", "color": Color(0.28, 1.0, 0.48)},
	"ice_cube": {"name": "多兰护盾贴纸", "desc": "获得护盾，多次选择会提高最大生命。", "color": Color(0.72, 0.96, 1.0)},
	"cinnamon_stick": {"name": "暴风大剑碎片", "desc": "基础伤害 +1。", "color": Color(0.92, 0.42, 0.20)},
	"lime_zest": {"name": "卢安娜小风扇", "desc": "增加额外侧射弹道。", "color": Color(0.78, 1.0, 0.16)},
	"almond_syrup": {"name": "攻速小瓶", "desc": "自动攻击冷却降低。", "color": Color(0.93, 0.78, 0.52)},
	"bubble_water": {"name": "纳沃利飞环", "desc": "增加一个环绕飞环，近身持续伤害。", "color": Color(0.45, 0.78, 1.0)},
	"ember_spark": {"name": "日炎余烬", "desc": "增加或强化近身范围脉冲。", "color": Color(1.0, 0.27, 0.08)},
	"honey_drop": {"name": "治疗宝珠", "desc": "最大生命 +1，并回复生命。", "color": Color(1.0, 0.72, 0.18)},
	"tonic_splash": {"name": "技能急速核心", "desc": "提高特殊技能威力，并让弹体稍微变大。", "color": Color(0.62, 0.88, 1.0)},
	"glass_rim": {"name": "穿甲杯沿", "desc": "主弹体额外穿透 1 个敌人。", "color": Color(0.70, 0.95, 1.0)},
	"star_anise": {"name": "暴击星星", "desc": "暴击率提高。", "color": Color(1.0, 0.72, 0.25)},
	"mystery_spice": {"name": "随机英雄梗", "desc": "随机获得两个基础或英雄升级。", "color": Color(0.92, 0.56, 1.0)},
	"physical_hex": {"name": "物理海克斯：破甲弹仓", "desc": "伤害、穿透和暴击提高，适合射手/物理近战。", "color": Color(1.0, 0.58, 0.22)},
	"magic_hex": {"name": "魔法海克斯：符文过载", "desc": "技能威力和弹体体积提高，后续可增强范围脉冲。", "color": Color(0.66, 0.48, 1.0)},
	"tank_hex": {"name": "坦克海克斯：巨像核心", "desc": "最大生命和护盾提高，适合近战抗压。", "color": Color(0.52, 0.90, 0.72)},
	"summon_hex": {"name": "召唤海克斯：自动工坊", "desc": "增加环绕单位和技能威力，适合陷阱/召唤流。", "color": Color(0.58, 0.92, 1.0)},
	"melee_hex": {"name": "近战海克斯：贴脸开团", "desc": "范围脉冲、护盾和移速提高。", "color": Color(1.0, 0.34, 0.30)},
	"marksman_hex": {"name": "射手海克斯：风暴弹链", "desc": "侧射、攻速和弹速提高。", "color": Color(1.0, 0.86, 0.25)},
	"support_hex": {"name": "支援海克斯：灵魂补给", "desc": "护盾、生命和回复提高，适合稳扎稳打。", "color": Color(0.62, 1.0, 0.78)}
}

const HERO_UPGRADES := {
	"jinx_rockets": {"name": "金克丝：鱼骨头营业", "desc": "鱼骨头火箭出现更频繁，爆炸半径和伤害提高。", "color": Color(1.0, 0.28, 0.64)},
	"jinx_fireworks": {"name": "金克丝：烟花别回头", "desc": "火箭追加散射烟花，击杀还会周期触发大火箭。", "color": Color(1.0, 0.72, 0.18)},
	"jinx_zoomies": {"name": "金克丝：罪恶快感续杯", "desc": "击杀后的加速更久，攻速更快。", "color": Color(0.42, 0.82, 1.0)},
	"senna_souls": {"name": "赛娜：灵魂收款码", "desc": "更容易收集灵魂，穿透提高。", "color": Color(0.55, 1.0, 0.78)},
	"senna_absolution": {"name": "赛娜：全场别倒", "desc": "周期护盾/治疗更强，并发射束缚黑雾。", "color": Color(0.75, 1.0, 0.88)},
	"senna_laser": {"name": "赛娜：大枪不讲理", "desc": "圣枪主射线更粗更穿透，后续可追加束缚射线。", "color": Color(0.66, 1.0, 0.86)},
	"samira_combo": {"name": "莎弥拉：S 级表演", "desc": "评分更快，暴击和攻速提高。", "color": Color(1.0, 0.62, 0.22)},
	"samira_inferno": {"name": "莎弥拉：炼狱扳机", "desc": "贴脸刀舞和满评分环形爆发范围提高。", "color": Color(1.0, 0.22, 0.16)},
	"samira_daredevil": {"name": "莎弥拉：悍勇本色", "desc": "半血以下更耐打，贴脸连招能获得护盾。", "color": Color(1.0, 0.42, 0.32)},
	"viktor_laser": {"name": "维克托：直线真理", "desc": "激光伤害和穿透提高。", "color": Color(0.72, 0.94, 1.0)},
	"viktor_storm": {"name": "维克托：重力场罚站", "desc": "周期生成重力场，持续减速并拉扯虚空虫群。", "color": Color(0.60, 0.68, 1.0)},
	"viktor_hexcore": {"name": "维克托：光荣进化", "desc": "技能威力提高，射线更快，重力场出现更勤。", "color": Color(0.92, 0.72, 1.0)},
	"xayah_feathers": {"name": "霞：羽毛库存爆仓", "desc": "普攻留下更多羽毛，羽刃伤害和穿透提高。", "color": Color(1.0, 0.34, 0.62)},
	"xayah_recall": {"name": "霞：倒钩回收", "desc": "羽毛会周期穿回身边，形成后撤反打线。", "color": Color(0.92, 0.28, 1.0)},
	"xayah_root": {"name": "霞：羽毛排队扎人", "desc": "回收羽毛会定身敌人，并追加身边控制脉冲。", "color": Color(1.0, 0.54, 0.72)},
	"morde_darkness": {"name": "莫德凯撒：黑暗起兮", "desc": "强化大锤近战范围，数次锤击后爆出暗域伤害。", "color": Color(0.58, 1.0, 0.58)},
	"morde_realm": {"name": "莫德凯撒：死亡领域", "desc": "周期生成领域，削弱敌人并给铁男护盾收益。", "color": Color(0.40, 1.0, 0.45)},
	"morde_iron": {"name": "莫德凯撒：铁皮更厚", "desc": "最大生命和护盾提高。", "color": Color(0.34, 0.62, 0.42)},
	"teemo_poison": {"name": "提莫：毒镖加料", "desc": "毒镖附加持续毒伤，毒性弹道更频繁。", "color": Color(0.70, 1.0, 0.22)},
	"teemo_shrooms": {"name": "提莫：蘑菇摊扩张", "desc": "定时布置实体蘑菇，踩中后生成毒云。", "color": Color(0.52, 1.0, 0.22)},
	"teemo_blind": {"name": "提莫：致盲吹箭", "desc": "周期发射致盲吹箭，削弱敌人接触伤害。", "color": Color(0.92, 0.84, 0.22)},
	"asol_stars": {"name": "龙王：星轨加班", "desc": "增加环绕星体，星轨半径和伤害随星尘成长。", "color": Color(0.46, 0.82, 1.0)},
	"asol_singularity": {"name": "龙王：星芒凝汇", "desc": "周期生成黑洞，吸引、减速并伤害虚空虫群。", "color": Color(0.64, 0.34, 1.0)},
	"asol_comet": {"name": "龙王：星天落瀑", "desc": "周期发射重型彗星，星尘越多威力越高。", "color": Color(1.0, 0.88, 0.42)}
}

const SHOP_ITEMS := {
	"infinity_edge": {"name": "无尽之刃", "desc": "伤害 +2，暴击率大幅提高。", "cost": 58, "type": "item", "item": "infinity_edge", "tags": ["physical", "crit", "marksman"]},
	"statikk_shiv": {"name": "斯塔缇克电刃", "desc": "获得连锁闪电，弹体速度提高。", "cost": 52, "type": "item", "item": "statikk_shiv", "tags": ["physical", "marksman", "haste"]},
	"bloodthirster": {"name": "饮血剑", "desc": "精英战后回复生命，最大生命提高。", "cost": 54, "type": "item", "item": "bloodthirster", "tags": ["physical", "melee", "support"]},
	"nashors_tooth": {"name": "纳什之牙", "desc": "攻击冷却降低，技能威力提高。", "cost": 48, "type": "item", "item": "nashors_tooth", "tags": ["magic", "haste", "summon"]},
	"rabadons_hat": {"name": "灭世者的帽子", "desc": "特殊技能威力大幅提高。", "cost": 62, "type": "item", "item": "rabadons_hat", "tags": ["magic"]},
	"randuins_omen": {"name": "兰顿之兆", "desc": "最大生命和护盾提高。", "cost": 46, "type": "item", "item": "randuins_omen", "tags": ["tank", "melee"]},
	"runaans_hurricane": {"name": "卢安娜的飓风", "desc": "额外弹道 +2，穿透提高。", "cost": 50, "type": "item", "item": "runaans_hurricane", "tags": ["physical", "marksman", "pierce"]},
	"zhonyas_hourglass": {"name": "中娅沙漏", "desc": "获得一次死里逃生和护盾。", "cost": 60, "type": "item", "item": "zhonyas_hourglass", "tags": ["magic", "tank"]},
	"black_cleaver": {"name": "黑色切割者", "desc": "伤害和穿透提高。", "cost": 44, "type": "item", "item": "black_cleaver", "tags": ["physical", "melee", "pierce"]},
	"guardian_angel": {"name": "守护天使", "desc": "获得一次死里逃生。", "cost": 64, "type": "item", "item": "guardian_angel", "tags": ["tank", "physical"]},
	"future_market": {"name": "未来市场", "desc": "立刻获得金币，金币收益和商店折扣提高。", "cost": 36, "type": "item", "item": "future_market", "tags": ["support"]},
	"warmogs_armor": {"name": "狂徒铠甲", "desc": "最大生命大量提高并回复。", "cost": 48, "type": "item", "item": "warmogs_armor", "tags": ["tank"]},
	"liandrys": {"name": "兰德里的折磨", "desc": "技能威力提高，范围/陷阱流更强。", "cost": 56, "type": "upgrade", "upgrade": "magic_hex", "tags": ["magic", "summon"]},
	"zekes": {"name": "基克的聚合", "desc": "护盾与团队式支援能力提高。", "cost": 40, "type": "upgrade", "upgrade": "support_hex", "tags": ["support", "tank"]},
	"titanic": {"name": "巨型九头蛇", "desc": "近战范围和坦度提高。", "cost": 52, "type": "upgrade", "upgrade": "melee_hex", "tags": ["melee", "tank"]},
	"shield_pack": {"name": "海克斯护盾包", "desc": "立刻获得 4 层护盾。", "cost": 24, "type": "shield", "amount": 4, "tags": ["tank", "support"]},
	"hextech_cache": {"name": "海克斯强化盲盒", "desc": "随机获得一项白银海克斯强化。", "cost": 45, "type": "hextech", "tier": "silver", "tags": ["support", "magic", "physical"]},
	"mystery_spice": {"name": "随机英雄梗", "desc": "随机获得两个升级。", "cost": 42, "type": "upgrade", "upgrade": "mystery_spice", "tags": ["support"]}
}

var player
var hud
var background
var visual3d
var sound
var camera: Camera2D
var use_3d_view := true

var game_state := "menu"
var selected_character_id := "jinx"
var elapsed := 0.0
var spawn_timer := 0.0
var elite_timer := ELITE_FIRST_TIMER
var pressure_surge_timer := PRESSURE_SURGE_FIRST_TIMER
var cull_timer := 1.0
var performance_guard_timer := 0.0
var wave := 1
var boss_spawned := false
var boss_alive := false
var current_upgrade_options: Array = []
var current_hextech_options: Array = []
var current_shop_options: Array = []
var current_fate_options: Array = []
var active_fate_id := ""
var hextech_offer_index := 0
var shop_offer_index := 0
var random_event_index := 0
var shop_time_shift := 0.0
var enemy_pressure_bonus := 0
var reward_bonus := 0
var last_pressure_surge_profile := ""
var last_pressure_surge_role_counts := {}
var last_pressure_surge_escort_kinds: Array = []
var fate_upgrade_bias_ids: Array = []
var fate_shop_focus_tags: Array = []
var fate_shop_discount_tags: Array = []
var fate_forced_elite_trait := ""
var fate_hextech_tier_bonus := 0
var chain_lightning_timer := 0.0
var impact_vfx_timer := 0.0
var shake_time := 0.0
var shake_strength := 0.0

func _ready() -> void:
	randomize()
	_ensure_input_map()
	_build_world()
	_show_menu()

func _process(delta: float) -> void:
	match game_state:
		"menu":
			_handle_menu_input()
		"fate":
			_handle_fate_input()
		"playing":
			_run_survivor_loop(delta)
			_handle_playing_input()
		"levelup":
			_handle_upgrade_input()
		"hextech":
			_handle_hextech_input()
		"shop":
			_handle_shop_input()
		"paused":
			_handle_pause_input()
		"summary":
			_handle_summary_input()
	_update_camera(delta)
	_update_camera_shake(delta)
	if hud != null and player != null and (game_state == "playing" or game_state == "levelup" or game_state == "hextech" or game_state == "shop" or game_state == "paused"):
		hud.update_run(player, elapsed, wave, get_tree().get_nodes_in_group("survivor_enemies").size(), boss_alive, BOSS_SPAWN_TIME - elapsed, _boss_health_ratio())

func _ensure_input_map() -> void:
	var defaults := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"restart": [KEY_R],
		"choice_1": [KEY_1],
		"choice_2": [KEY_2],
		"choice_3": [KEY_3],
		"choice_4": [KEY_4],
		"choice_5": [KEY_5],
		"choice_6": [KEY_6],
		"choice_7": [KEY_7],
		"choice_8": [KEY_8],
		"confirm": [KEY_ENTER, KEY_KP_ENTER],
		"pause": [KEY_P, KEY_ESCAPE],
		"back": [KEY_ESCAPE]
	}
	for action in defaults.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		if InputMap.action_get_events(action).size() == 0:
			for keycode in defaults[action]:
				var event := InputEventKey.new()
				event.keycode = keycode
				InputMap.action_add_event(action, event)

func _boss_health_ratio() -> float:
	var ratio := -1.0
	for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
		if not is_instance_valid(enemy) or not bool(enemy.get("boss")):
			continue
		var max_hp := maxf(1.0, float(enemy.get("max_health")))
		var hp := clampf(float(enemy.get("health")) / max_hp, 0.0, 1.0)
		ratio = maxf(ratio, hp)
	return ratio

func _build_world() -> void:
	background = BackgroundScene.new()
	background.z_index = -100
	add_child(background)
	background.visible = not use_3d_view

	if use_3d_view:
		visual3d = Visual3DScene.new()
		visual3d.setup(self, ARENA)
		add_child(visual3d)

	sound = SoundScene.new()
	add_child(sound)

	camera = Camera2D.new()
	camera.position = ARENA.get_center()
	camera.limit_left = int(ARENA.position.x)
	camera.limit_right = int(ARENA.end.x)
	camera.limit_top = int(ARENA.position.y)
	camera.limit_bottom = int(ARENA.end.y)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	add_child(camera)
	camera.make_current()

	player = PlayerScene.new()
	add_child(player)
	_hide_2d_canvas_item(player)
	player.died.connect(_on_player_died)
	player.damaged.connect(_on_player_damaged)
	player.leveled_up.connect(_on_player_leveled_up)
	player.recipe_unlocked.connect(_on_player_recipe_unlocked)
	player.projectile_requested.connect(_on_player_projectile_requested)
	player.pulse_requested.connect(_on_player_pulse_requested)
	player.effect_requested.connect(_on_player_effect_requested)
	player.zone_requested.connect(_on_player_zone_requested)

	hud = HUDScene.new()
	add_child(hud)
	hud.choice_selected.connect(_on_hud_choice_selected)
	hud.start_pressed.connect(_on_hud_start_pressed)
	hud.shop_closed.connect(_close_shop)
	hud.mute_pressed.connect(_toggle_mute)
	hud.return_select_pressed.connect(_return_to_select)

func _show_menu() -> void:
	game_state = "menu"
	_clear_arena()
	player.visible = false
	player.set_controls_enabled(false)
	camera.position = ARENA.get_center()
	hud.show_title(selected_character_id)
	hud.show_message("")
	queue_redraw()

func _start_new_run() -> void:
	_clear_arena()
	elapsed = 0.0
	spawn_timer = 0.0
	elite_timer = ELITE_FIRST_TIMER
	pressure_surge_timer = PRESSURE_SURGE_FIRST_TIMER
	cull_timer = 1.0
	performance_guard_timer = PERF_GUARD_INTERVAL
	wave = 1
	boss_spawned = false
	boss_alive = false
	active_fate_id = ""
	hextech_offer_index = 0
	shop_offer_index = 0
	random_event_index = 0
	shop_time_shift = 0.0
	enemy_pressure_bonus = 0
	reward_bonus = 0
	last_pressure_surge_profile = ""
	last_pressure_surge_role_counts = {}
	last_pressure_surge_escort_kinds.clear()
	fate_upgrade_bias_ids.clear()
	fate_shop_focus_tags.clear()
	fate_shop_discount_tags.clear()
	fate_forced_elite_trait = ""
	fate_hextech_tier_bonus = 0
	chain_lightning_timer = 0.0
	impact_vfx_timer = 0.0
	current_upgrade_options.clear()
	current_hextech_options.clear()
	current_shop_options.clear()
	current_fate_options = _roll_fate_options()
	game_state = "fate"
	player.visible = true
	player.reset_run(selected_character_id)
	player.set_controls_enabled(false)
	player.set_process(true)
	camera.position = player.global_position
	hud.show_fate_choices(current_fate_options)
	hud.show_message("先选这局的开局命运。", 3.0)
	_play_sound("start")
	queue_redraw()

func _run_survivor_loop(delta: float) -> void:
	elapsed += delta
	wave = maxi(1, int(elapsed / 30.0) + 1)
	spawn_timer -= delta
	elite_timer -= delta
	pressure_surge_timer -= delta
	cull_timer -= delta
	performance_guard_timer -= delta
	chain_lightning_timer = maxf(0.0, chain_lightning_timer - delta)
	impact_vfx_timer = maxf(0.0, impact_vfx_timer - delta)

	var enemy_count := get_tree().get_nodes_in_group("survivor_enemies").size()
	if spawn_timer <= 0.0 and enemy_count < MAX_ENEMIES:
		_spawn_pack(enemy_count)
		spawn_timer = maxf(SPAWN_TIMER_MIN, SPAWN_TIMER_BASE - elapsed * SPAWN_TIMER_DECAY - float(_director_pressure_step()) * 0.010)
	if elite_timer <= 0.0:
		elite_timer = maxf(ELITE_TIMER_MIN, ELITE_TIMER_BASE - wave * ELITE_TIMER_WAVE_DECAY - float(_director_pressure_step()) * 0.22)
		if enemy_count < MAX_ENEMIES - 4:
			var elite_enemy = _spawn_enemy(_random_spawn_position(), _elite_kind(), true)
			hud.show_message("%s虚空精英出现，击败它会爆奖励。" % _elite_trait_prefix(elite_enemy), 2.8)
			_shake(7.0, 0.22)
	if not boss_spawned and elapsed >= BOSS_SPAWN_TIME:
		_spawn_boss()
	if hextech_offer_index < HEXTECH_FORGE_TIMES.size() and elapsed >= float(HEXTECH_FORGE_TIMES[hextech_offer_index]):
		_start_hextech_offer()
	if shop_offer_index < SHOP_TIMES.size() and elapsed >= float(SHOP_TIMES[shop_offer_index]) + shop_time_shift:
		_start_shop_offer()
	if random_event_index < RANDOM_EVENT_TIMES.size() and elapsed >= float(RANDOM_EVENT_TIMES[random_event_index]):
		random_event_index += 1
		_trigger_random_event()
	if pressure_surge_timer <= 0.0:
		_trigger_pressure_surge()
		pressure_surge_timer = maxf(PRESSURE_SURGE_TIMER_MIN, PRESSURE_SURGE_TIMER_BASE - float(_director_pressure_step()) * 3.0)
	if cull_timer <= 0.0:
		cull_timer = 2.0
		_cull_far_entities()
	if performance_guard_timer <= 0.0:
		performance_guard_timer = PERF_GUARD_INTERVAL
		_enforce_runtime_budget()

func _handle_menu_input() -> void:
	if Input.is_action_just_pressed("choice_1"):
		_select_character(CHAMPION_ORDER[0])
	elif Input.is_action_just_pressed("choice_2"):
		_select_character(CHAMPION_ORDER[1])
	elif Input.is_action_just_pressed("choice_3"):
		_select_character(CHAMPION_ORDER[2])
	elif Input.is_action_just_pressed("choice_4"):
		_select_character(CHAMPION_ORDER[3])
	elif Input.is_action_just_pressed("choice_5"):
		_select_character(CHAMPION_ORDER[4])
	elif Input.is_action_just_pressed("choice_6"):
		_select_character(CHAMPION_ORDER[5])
	elif Input.is_action_just_pressed("choice_7"):
		_select_character(CHAMPION_ORDER[6])
	elif Input.is_action_just_pressed("choice_8"):
		_select_character(CHAMPION_ORDER[7])
	elif Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("restart"):
		_start_new_run()

func _handle_fate_input() -> void:
	if Input.is_action_just_pressed("choice_1"):
		_choose_fate(0)
	elif Input.is_action_just_pressed("choice_2"):
		_choose_fate(1)
	elif Input.is_action_just_pressed("choice_3"):
		_choose_fate(2)
	elif Input.is_action_just_pressed("restart"):
		_start_new_run()

func _select_character(character_id: String) -> void:
	selected_character_id = character_id
	hud.show_title(selected_character_id)
	_play_sound("menu")

func _handle_playing_input() -> void:
	if Input.is_action_just_pressed("pause"):
		_pause_run()
	elif Input.is_action_just_pressed("restart"):
		_start_new_run()

func _pause_run() -> void:
	if game_state != "playing":
		return
	game_state = "paused"
	player.set_controls_enabled(false)
	_set_arena_active(false)
	hud.show_pause()

func _resume_run() -> void:
	if game_state != "paused":
		return
	game_state = "playing"
	hud.hide_overlay()
	player.set_controls_enabled(true)
	_set_arena_active(true)

func _handle_pause_input() -> void:
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("back"):
		_resume_run()
	elif Input.is_action_just_pressed("restart"):
		_start_new_run()

func _handle_upgrade_input() -> void:
	if Input.is_action_just_pressed("choice_1"):
		_choose_upgrade(0)
	elif Input.is_action_just_pressed("choice_2"):
		_choose_upgrade(1)
	elif Input.is_action_just_pressed("choice_3"):
		_choose_upgrade(2)

func _handle_hextech_input() -> void:
	if Input.is_action_just_pressed("choice_1"):
		_choose_hextech_augment(0)
	elif Input.is_action_just_pressed("choice_2"):
		_choose_hextech_augment(1)
	elif Input.is_action_just_pressed("choice_3"):
		_choose_hextech_augment(2)

func _handle_shop_input() -> void:
	for i in range(mini(8, current_shop_options.size())):
		if Input.is_action_just_pressed("choice_%d" % [i + 1]):
			_choose_shop_item(i)
			return
	if Input.is_action_just_pressed("back") or Input.is_action_just_pressed("confirm"):
		_close_shop()

func _handle_summary_input() -> void:
	if Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("restart"):
		_start_new_run()

func _on_hud_choice_selected(index: int) -> void:
	match game_state:
		"menu":
			if index >= 0 and index < CHAMPION_ORDER.size():
				_select_character(CHAMPION_ORDER[index])
		"fate":
			_choose_fate(index)
		"levelup":
			_choose_upgrade(index)
		"hextech":
			_choose_hextech_augment(index)
		"shop":
			_choose_shop_item(index)

func _on_hud_start_pressed() -> void:
	if game_state == "menu" or game_state == "summary":
		_start_new_run()

func _toggle_mute() -> void:
	if sound == null:
		return
	var muted := false
	if sound.has_method("toggle_muted"):
		muted = sound.toggle_muted()
	hud.set_muted_display(muted)
	hud.show_message("音效已关闭。" if muted else "音效已开启。", 1.6)

func _return_to_select() -> void:
	_set_arena_active(false)
	_show_menu()

func _on_player_leveled_up() -> void:
	if game_state != "playing":
		return
	game_state = "levelup"
	player.set_controls_enabled(false)
	_set_arena_active(false)
	current_upgrade_options = _roll_upgrade_options()
	hud.show_upgrade_choices(current_upgrade_options)
	_play_sound("recipe")

func _on_player_recipe_unlocked(recipe_name: String, _desc: String) -> void:
	hud.show_message("构筑联动：%s" % recipe_name, 3.0)
	_spawn_floating_text(player.global_position + Vector2(-62, -74), recipe_name, Color(1.0, 0.78, 0.30), 20)
	_play_sound("recipe")

func _choose_upgrade(index: int) -> void:
	if index < 0 or index >= current_upgrade_options.size():
		return
	var option: Dictionary = current_upgrade_options[index]
	var upgrade_id := str(option.get("id", "cinnamon_stick"))
	player.add_upgrade(upgrade_id)
	player.consume_pending_level()
	hud.show_message("升级：%s" % option.get("name", upgrade_id), 2.0)
	_play_sound("rare")
	if player.pending_levels > 0:
		current_upgrade_options = _roll_upgrade_options()
		hud.show_upgrade_choices(current_upgrade_options)
		return
	game_state = "playing"
	hud.hide_overlay()
	player.set_controls_enabled(true)
	_set_arena_active(true)

func _start_hextech_offer() -> void:
	if game_state != "playing":
		return
	var tier := _hextech_tier_for_index(hextech_offer_index)
	hextech_offer_index += 1
	current_hextech_options = _roll_hextech_options(tier)
	if current_hextech_options.size() == 0:
		return
	game_state = "hextech"
	player.set_controls_enabled(false)
	_set_arena_active(false)
	hud.show_hextech_choices(current_hextech_options)
	_play_sound("recipe")

func _choose_hextech_augment(index: int) -> void:
	if index < 0 or index >= current_hextech_options.size():
		return
	var option: Dictionary = current_hextech_options[index]
	var augment_id := str(option.get("id", "swift_steps"))
	player.add_hextech_augment(augment_id)
	hud.show_message("获得海克斯：%s" % option.get("name", augment_id), 2.3)
	_play_sound("rare")
	game_state = "playing"
	hud.hide_overlay()
	player.set_controls_enabled(true)
	_set_arena_active(true)

func _roll_fate_options() -> Array:
	var ids := _all_fate_ids()
	var core_ids := []
	var extra_ids := []
	for id in RUN_FATES.keys():
		core_ids.append(str(id))
	for id in EXTRA_RUN_FATES.keys():
		extra_ids.append(str(id))
	core_ids.shuffle()
	extra_ids.shuffle()
	var result := []
	var picked_ids := []
	if extra_ids.size() > 0:
		picked_ids.append(str(extra_ids[0]))
	if core_ids.size() > 0:
		picked_ids.append(str(core_ids[0]))
	ids.shuffle()
	for id in ids:
		if picked_ids.size() >= 3:
			break
		var current_id := str(id)
		if not picked_ids.has(current_id):
			picked_ids.append(current_id)
	for raw_id in picked_ids:
		var id := str(raw_id)
		var data: Dictionary = _fate_data(id)
		result.append({"id": id, "name": data.get("name", id), "desc": data.get("desc", ""), "message": data.get("message", "")})
	return result

func _all_fate_ids() -> Array:
	var ids := []
	for id in RUN_FATES.keys():
		ids.append(str(id))
	for id in EXTRA_RUN_FATES.keys():
		ids.append(str(id))
	return ids

func _fate_data(fate_id: String) -> Dictionary:
	if RUN_FATES.has(fate_id):
		return RUN_FATES[fate_id]
	if EXTRA_RUN_FATES.has(fate_id):
		return EXTRA_RUN_FATES[fate_id]
	return {"name": fate_id, "desc": "", "message": ""}

func _choose_fate(index: int) -> void:
	if index < 0 or index >= current_fate_options.size():
		return
	var option: Dictionary = current_fate_options[index]
	active_fate_id = str(option.get("id", "prismatic_party"))
	_apply_fate(active_fate_id)
	game_state = "playing"
	hud.hide_overlay()
	hud.show_message("%s：%s" % [option.get("name", active_fate_id), option.get("message", "")], 3.0)
	player.set_controls_enabled(true)
	_set_arena_active(true)
	_play_sound("rare")

func _apply_fate(fate_id: String) -> void:
	match fate_id:
		"prismatic_party":
			player.add_hextech_augment("mayhem_overdrive")
			_grant_random_hero_upgrade()
			enemy_pressure_bonus = 1
			pressure_surge_timer = minf(pressure_surge_timer, 74.0)
		"elite_contract":
			player.add_hextech_augment("elite_hunter")
			elite_timer = 3.8
			reward_bonus = 1
			pressure_surge_timer = minf(pressure_surge_timer, 78.0)
		"market_day":
			player.add_gold(60)
			player.add_hextech_augment("golden_ticket")
			shop_time_shift = -34.0
		"swarm_alarm":
			enemy_pressure_bonus = 2
			reward_bonus = 1
			player.add_upgrade("almond_syrup")
			pressure_surge_timer = minf(pressure_surge_timer, 66.0)
		"starfall":
			player.add_hextech_augment("orbital_laser")
			player.add_upgrade("bubble_water")
		"yordle_mischief":
			player.add_upgrade("mint_leaf")
			player.add_gold(randi_range(24, 72))
			_grant_random_hero_upgrade()
		"signature_draft":
			fate_upgrade_bias_ids = player.get_hero_upgrade_ids().duplicate()
			_grant_random_hero_upgrade()
			reward_bonus = 1
		"black_market":
			player.add_gold(48)
			player.add_hextech_augment("golden_ticket")
			fate_shop_focus_tags = player.get_shop_tags().duplicate()
			fate_shop_discount_tags = player.get_shop_tags().duplicate()
			shop_time_shift = -48.0
		"unstable_forge":
			player.add_hextech_augment("quick_hands")
			fate_hextech_tier_bonus = 1
			enemy_pressure_bonus = 1
			reward_bonus = 1
			pressure_surge_timer = minf(pressure_surge_timer, 72.0)
		"void_rivalry":
			player.add_hextech_augment("treasure_sense")
			elite_timer = 3.6
			reward_bonus = 2
			enemy_pressure_bonus = 1
			fate_forced_elite_trait = "treasure"
			pressure_surge_timer = minf(pressure_surge_timer, 70.0)

func _grant_random_hero_upgrade() -> void:
	var ids: Array = player.get_hero_upgrade_ids()
	if ids.size() == 0:
		return
	player.add_upgrade(str(ids[randi() % ids.size()]))

func _start_shop_offer() -> void:
	if game_state != "playing":
		return
	shop_offer_index += 1
	current_shop_options = _roll_shop_options()
	if current_shop_options.size() == 0:
		return
	game_state = "shop"
	player.set_controls_enabled(false)
	_set_arena_active(false)
	hud.show_shop_choices(current_shop_options, player.gold)
	_play_sound("menu")

func _choose_shop_item(index: int) -> void:
	if index < 0 or index >= current_shop_options.size():
		return
	var option: Dictionary = current_shop_options[index]
	var price := int(option.get("price", option.get("cost", 0)))
	if not player.try_spend_gold(price):
		hud.show_message("金币不够，还差 %d。" % maxi(0, price - player.gold), 1.8)
		return
	_apply_shop_purchase(option)
	_spawn_shop_purchase_visual(option)
	_play_sound("rare")
	hud.show_message("购买成功：%s" % option.get("name", "商品"), 1.8)
	current_shop_options = _roll_shop_options()
	hud.show_shop_choices(current_shop_options, player.gold)

func _close_shop(message := "离开商店。") -> void:
	game_state = "playing"
	hud.hide_overlay()
	hud.show_message(message, 1.8)
	player.set_controls_enabled(true)
	_set_arena_active(true)

func _roll_shop_options() -> Array:
	var ids := SHOP_ITEMS.keys()
	ids.sort_custom(func(a, b):
		return _shop_recommend_score(SHOP_ITEMS[a]) > _shop_recommend_score(SHOP_ITEMS[b])
	)
	var result := []
	for i in range(ids.size()):
		var id := str(ids[i])
		var data: Dictionary = SHOP_ITEMS[id]
		var tags: Array = data.get("tags", [])
		var price := _shop_price(int(data.get("cost", 10)), tags)
		var recommend_score := _shop_recommend_score(data)
		var recommended := recommend_score > 0
		result.append({
			"id": id,
			"name": str(data.get("name", id)),
			"desc": data.get("desc", ""),
			"color": _shop_route_color(tags, recommended),
			"badge": _shop_route_badge(tags, recommend_score),
			"type": data.get("type", "upgrade"),
			"upgrade": data.get("upgrade", id),
			"item": data.get("item", id),
			"tier": data.get("tier", "silver"),
			"amount": int(data.get("amount", 0)),
			"cost": int(data.get("cost", 10)),
			"price": price,
			"tags": tags,
			"route_score": recommend_score,
			"recommended": recommended
		})
	return result

func _shop_recommend_score(data: Dictionary) -> int:
	if player == null:
		return 0
	var score := 0
	var hero_tags: Array = player.get_shop_tags()
	var item_tags: Array = data.get("tags", [])
	for tag in item_tags:
		var tag_id := str(tag)
		if hero_tags.has(tag_id):
			score += 1
		if fate_shop_focus_tags.has(tag_id):
			score += 1
	if active_fate_id == "black_market" and score > 0:
		score += 1
	return score

func _shop_route_badge(tags: Array, recommend_score: int) -> String:
	var label := ""
	if tags.has("marksman"):
		label = "射手"
	elif tags.has("magic"):
		label = "法系"
	elif tags.has("tank"):
		label = "坦克"
	elif tags.has("melee"):
		label = "近战"
	elif tags.has("summon"):
		label = "召唤"
	elif tags.has("support"):
		label = "辅助"
	elif tags.has("physical"):
		label = "物理"
	if label == "":
		label = "装备"
	if recommend_score >= 2:
		return "%s+%d" % [label, recommend_score]
	return label

func _shop_route_color(tags: Array, recommended: bool) -> Color:
	if tags.has("marksman"):
		return Color(1.0, 0.84, 0.24) if recommended else Color(0.72, 0.68, 0.34)
	if tags.has("magic"):
		return Color(0.66, 0.48, 1.0) if recommended else Color(0.48, 0.40, 0.78)
	if tags.has("tank"):
		return Color(0.52, 0.94, 0.72) if recommended else Color(0.36, 0.66, 0.54)
	if tags.has("melee"):
		return Color(1.0, 0.42, 0.32) if recommended else Color(0.72, 0.40, 0.36)
	if tags.has("summon"):
		return Color(0.58, 0.92, 1.0) if recommended else Color(0.42, 0.66, 0.74)
	if tags.has("support"):
		return Color(0.62, 1.0, 0.78) if recommended else Color(0.42, 0.70, 0.56)
	if tags.has("physical"):
		return Color(1.0, 0.58, 0.22) if recommended else Color(0.76, 0.50, 0.32)
	return Color(1.0, 0.76, 0.22) if recommended else Color(0.56, 0.78, 1.0)

func _shop_price(base_cost: int, tags: Array = []) -> int:
	var multiplier: float = player.get_shop_price_multiplier(tags)
	if active_fate_id == "black_market" and _tags_overlap(tags, fate_shop_discount_tags):
		multiplier *= 0.76
	elif active_fate_id == "market_day":
		multiplier *= 0.92
	return maxi(1, int(round(float(base_cost) * multiplier)))

func _tags_overlap(left: Array, right: Array) -> bool:
	for tag in left:
		if right.has(str(tag)):
			return true
	return false

func _apply_shop_purchase(option: Dictionary) -> void:
	match str(option.get("type", "upgrade")):
		"shield":
			player.add_shield(int(option.get("amount", 1)))
		"hextech":
			var ids := AugmentData.get_random_options(1, str(option.get("tier", "silver")), player.get_hextech_augment_ids())
			if ids.size() > 0:
				player.add_hextech_augment(str(ids[0]))
				_spawn_floating_text(player.global_position + Vector2(-36, -64), AugmentData.get_name(str(ids[0])), Color(0.82, 0.54, 1.0), 18)
		"item":
			player.add_item_purchase(str(option.get("item", option.get("id", "infinity_edge"))))
		_:
			player.add_upgrade(str(option.get("upgrade", option.get("id", "honey_drop"))))

func _spawn_shop_purchase_visual(option: Dictionary) -> void:
	if player == null:
		return
	var accent: Color = option.get("color", Color(1.0, 0.76, 0.22))
	var route_score := int(option.get("route_score", 0))
	var radius := 108.0 + float(route_score) * 18.0
	_spawn_pulse_visual(player.global_position, radius, Color(accent.r, accent.g, accent.b, 0.26))
	_spawn_pulse_visual(player.global_position, maxf(72.0, radius * 0.58), Color(1.0, 0.82, 0.28, 0.18))
	var tags: Array = option.get("tags", [])
	var badge := _shop_route_badge(tags, route_score)
	_spawn_floating_text(player.global_position + Vector2(-48, -82), badge, accent.lightened(0.18), 16)

func _roll_upgrade_options() -> Array:
	var weighted := []
	for id in UPGRADES.keys():
		weighted.append(str(id))
	var hero_upgrade_ids: Array = player.get_hero_upgrade_ids()
	for hero_id in hero_upgrade_ids:
		weighted.append(str(hero_id))
		weighted.append(str(hero_id))
	var hero_tags: Array = player.get_shop_tags()
	if hero_tags.has("physical"):
		weighted.append("physical_hex")
		weighted.append("physical_hex")
	if hero_tags.has("magic"):
		weighted.append("magic_hex")
		weighted.append("magic_hex")
	if hero_tags.has("tank"):
		weighted.append("tank_hex")
		weighted.append("tank_hex")
	if hero_tags.has("summon"):
		weighted.append("summon_hex")
		weighted.append("summon_hex")
	if hero_tags.has("melee"):
		weighted.append("melee_hex")
	if hero_tags.has("marksman"):
		weighted.append("marksman_hex")
		weighted.append("marksman_hex")
	if hero_tags.has("support"):
		weighted.append("support_hex")
	if active_fate_id == "prismatic_party":
		for hero_id in player.get_hero_upgrade_ids():
			weighted.append(str(hero_id))
	elif active_fate_id == "swarm_alarm":
		weighted.append("lime_zest")
		weighted.append("ember_spark")
		weighted.append("almond_syrup")
	elif active_fate_id == "starfall":
		weighted.append("bubble_water")
		weighted.append("tonic_splash")
	for bias_id in fate_upgrade_bias_ids:
		weighted.append(str(bias_id))
		weighted.append(str(bias_id))
	weighted.shuffle()

	var result := []
	var seen := {}
	var hero_pool := hero_upgrade_ids.duplicate()
	hero_pool.shuffle()
	if active_fate_id == "signature_draft":
		for i in range(mini(2, hero_pool.size())):
			var hero_id := str(hero_pool[i])
			_append_upgrade_option(hero_id, result, seen, _upgrade_route_badge(hero_id, ""))
	elif hero_pool.size() > 0 and randf() < 0.86:
		_append_upgrade_option(str(hero_pool[0]), result, seen, "专属")
	if active_fate_id == "signature_draft" and hero_pool.size() > 1:
		_append_upgrade_option(str(hero_pool[1]), result, seen, "专属")

	var route_pool := _route_upgrade_pool(hero_tags)
	route_pool.shuffle()
	for route_id in route_pool:
		if result.size() >= 3:
			break
		if _append_upgrade_option(str(route_id), result, seen, "路线"):
			break

	for raw_id in weighted:
		if result.size() >= 3:
			break
		var id := str(raw_id)
		_append_upgrade_option(id, result, seen, "升级")
	return result

func _append_upgrade_option(id: String, result: Array, seen: Dictionary, badge := "升级") -> bool:
	if seen.has(id):
		return false
	seen[id] = true
	var data := _get_upgrade_data(id)
	var route_badge := _upgrade_route_badge(id, badge)
	result.append({
		"id": id,
		"name": data.get("name", id),
		"desc": data.get("desc", ""),
		"color": data.get("color", Color.WHITE),
		"badge": route_badge,
		"recommended": badge == "专属" or badge == "路线"
	})
	return true

func _upgrade_route_badge(id: String, fallback: String) -> String:
	if HERO_UPGRADES.has(id):
		return "专属"
	match id:
		"physical_hex", "cinnamon_stick", "glass_rim", "star_anise", "black_cleaver":
			return "物理"
		"magic_hex", "tonic_splash", "bubble_water":
			return "法系"
		"tank_hex", "ice_cube", "honey_drop":
			return "坦克"
		"summon_hex":
			return "召唤"
		"melee_hex", "ember_spark":
			return "近战"
		"marksman_hex", "lime_zest", "almond_syrup":
			return "射手"
		"support_hex", "mint_leaf":
			return "支援"
		_:
			return fallback

func _route_upgrade_pool(hero_tags: Array) -> Array:
	var pool := []
	if hero_tags.has("physical"):
		pool.append_array(["physical_hex", "cinnamon_stick", "glass_rim", "star_anise"])
	if hero_tags.has("magic"):
		pool.append_array(["magic_hex", "tonic_splash", "bubble_water"])
	if hero_tags.has("tank"):
		pool.append_array(["tank_hex", "ice_cube", "honey_drop", "ember_spark"])
	if hero_tags.has("summon"):
		pool.append_array(["summon_hex", "bubble_water", "tonic_splash"])
	if hero_tags.has("melee"):
		pool.append_array(["melee_hex", "ember_spark", "ice_cube"])
	if hero_tags.has("marksman"):
		pool.append_array(["marksman_hex", "lime_zest", "almond_syrup", "star_anise"])
	if hero_tags.has("support"):
		pool.append_array(["support_hex", "ice_cube", "honey_drop", "mint_leaf"])
	return pool

func _get_upgrade_data(upgrade_id: String) -> Dictionary:
	if HERO_UPGRADES.has(upgrade_id):
		return HERO_UPGRADES[upgrade_id]
	if UPGRADES.has(upgrade_id):
		return UPGRADES[upgrade_id]
	return {"name": upgrade_id, "desc": "未知升级。", "color": Color.WHITE}

func _roll_hextech_options(tier: String) -> Array:
	var result := []
	var excluded: Array = player.get_hextech_augment_ids()
	var ids: Array = AugmentData.get_random_options(3, tier, excluded)
	var recommended_id := _recommended_hextech_id(tier, excluded, ids)
	if recommended_id != "":
		if ids.size() == 0:
			ids.append(recommended_id)
		elif not ids.has(recommended_id):
			ids[randi() % ids.size()] = recommended_id
	for augment_id in ids:
		var data := AugmentData.get_data(str(augment_id))
		var actual_tier := AugmentData.get_tier(str(augment_id))
		var tier_data := AugmentData.get_tier_data(actual_tier)
		result.append({
			"id": str(augment_id),
			"name": data.get("name", str(augment_id)),
			"desc": data.get("desc", ""),
			"tier": actual_tier,
			"tier_label": tier_data.get("zh", actual_tier),
			"color": tier_data.get("color", Color.WHITE),
			"recommended": str(augment_id) == recommended_id,
			"badge": "推荐" if str(augment_id) == recommended_id else tier_data.get("zh", actual_tier)
		})
	return result

func _recommended_hextech_id(tier: String, excluded: Array, current_ids: Array) -> String:
	if player == null:
		return ""
	if active_fate_id != "unstable_forge" and randf() > 0.78:
		return ""
	var candidates := _route_hextech_pool(player.get_shop_tags())
	candidates.shuffle()
	for augment_id in candidates:
		var current_id := str(augment_id)
		if not excluded.has(current_id) and current_ids.has(current_id) and AugmentData.get_tier(current_id) == tier:
			return current_id
	for augment_id in candidates:
		var id := str(augment_id)
		if excluded.has(id) or current_ids.has(id):
			continue
		if AugmentData.get_tier(id) == tier:
			return id
	return ""

func _route_hextech_pool(hero_tags: Array) -> Array:
	var pool := []
	if hero_tags.has("physical") or hero_tags.has("marksman"):
		pool.append_array(["lucky_find", "quick_hands", "chain_lightning", "rolling_pin", "mayhem_overdrive"])
	if hero_tags.has("magic") or hero_tags.has("summon"):
		pool.append_array(["quick_hands", "frostfire_combo", "orbital_laser", "rolling_pin", "mayhem_overdrive"])
	if hero_tags.has("tank") or hero_tags.has("melee"):
		pool.append_array(["sturdy_shell", "hextech_shield", "crystal_armor", "prismatic_body", "cheat_death"])
	if hero_tags.has("support"):
		pool.append_array(["minty_breeze", "hextech_shield", "vampiric_spoon", "golden_ticket", "cheat_death"])
	if hero_tags.has("haste"):
		pool.append_array(["quick_hands", "chain_lightning", "orbital_laser"])
	return pool

func _hextech_tier_for_index(index: int) -> String:
	var shifted_index := index + fate_hextech_tier_bonus
	if shifted_index <= 0:
		return "silver"
	if shifted_index <= 2:
		return "gold"
	return "prismatic"

func _trigger_random_event() -> void:
	if game_state != "playing":
		return
	var pool := ["gold_rain", "upgrade_cache", "shield_wave", "ambush", "hextech_spark"]
	if active_fate_id == "market_day":
		pool.append("gold_rain")
		pool.append("coupon_shop")
	elif active_fate_id == "elite_contract":
		pool.append("ambush")
		pool.append("ambush")
	elif active_fate_id == "yordle_mischief":
		pool.append("upgrade_cache")
		pool.append("gold_rain")
	elif active_fate_id == "swarm_alarm":
		pool.append("ambush")
	elif active_fate_id == "signature_draft":
		pool.append("upgrade_cache")
		pool.append("upgrade_cache")
	elif active_fate_id == "black_market":
		pool.append("coupon_shop")
		pool.append("coupon_shop")
	elif active_fate_id == "unstable_forge":
		pool.append("hextech_spark")
		pool.append("hextech_spark")
	elif active_fate_id == "void_rivalry":
		pool.append("ambush")
		pool.append("ambush")
		pool.append("gold_rain")
	pool.shuffle()
	match str(pool[0]):
		"gold_rain":
			_event_gold_rain()
		"upgrade_cache":
			_event_upgrade_cache()
		"shield_wave":
			_event_shield_wave()
		"ambush":
			_event_elite_ambush()
		"coupon_shop":
			_start_shop_offer()
		_:
			_event_hextech_spark()

func _event_gold_rain() -> void:
	hud.show_message("随机事件：魄罗金币雨！", 2.5)
	for i in range(9):
		_spawn_pickup(_random_near_player(220.0), "gold", randi_range(4, 9) + reward_bonus, Color(1.0, 0.76, 0.20))
	_play_sound("rare")

func _event_upgrade_cache() -> void:
	var weighted := []
	for id in UPGRADES.keys():
		weighted.append(str(id))
	for hero_id in player.get_hero_upgrade_ids():
		weighted.append(str(hero_id))
		weighted.append(str(hero_id))
	for bias_id in fate_upgrade_bias_ids:
		weighted.append(str(bias_id))
		weighted.append(str(bias_id))
		weighted.append(str(bias_id))
	weighted.shuffle()
	var upgrade_id := str(weighted[0])
	player.add_upgrade(upgrade_id)
	var data := _get_upgrade_data(upgrade_id)
	hud.show_message("随机事件：海克斯补给，获得 %s。" % data.get("name", upgrade_id), 2.8)
	_spawn_floating_text(player.global_position + Vector2(-40, -68), str(data.get("name", upgrade_id)), Color(1.0, 0.82, 0.30), 18)
	_play_sound("recipe")

func _event_shield_wave() -> void:
	var amount := 2 + int(wave / 4)
	player.add_shield(amount)
	hud.show_message("随机事件：防御塔余波，护盾 +%d。" % amount, 2.5)
	_spawn_pulse_visual(player.global_position, 112.0, Color(0.72, 0.95, 1.0, 0.24))
	_play_sound("skill")

func _event_elite_ambush() -> void:
	var elite_enemy = _spawn_enemy(_random_spawn_position(), _elite_kind(), true)
	hud.show_message("随机事件：%s虚空精英突袭！" % _elite_trait_prefix(elite_enemy), 2.8)
	_shake(7.0, 0.25)

func _event_hextech_spark() -> void:
	current_hextech_options = _roll_hextech_options("silver")
	if current_hextech_options.size() == 0:
		return
	game_state = "hextech"
	player.set_controls_enabled(false)
	_set_arena_active(false)
	hud.show_hextech_choices(current_hextech_options)
	hud.show_message("随机事件：海克斯火花。", 2.5)
	_play_sound("recipe")

func _trigger_pressure_surge() -> void:
	if player == null:
		return
	var current_enemy_count := get_tree().get_nodes_in_group("survivor_enemies").size()
	if current_enemy_count >= MAX_ENEMIES - 5:
		return
	var pressure_step := _director_pressure_step()
	var elite_count := 1
	if elapsed >= 150.0 and current_enemy_count < MAX_ENEMIES - 12:
		elite_count = 2
	var spawned_elites := 0
	for i in range(elite_count):
		if get_tree().get_nodes_in_group("survivor_enemies").size() >= MAX_ENEMIES - 3:
			break
		var elite_enemy = _spawn_enemy(_random_spawn_position(), _elite_kind(), true)
		if elite_enemy != null:
			spawned_elites += 1
	var escort_count := 5 + pressure_step + int(elapsed / 180.0)
	if boss_alive:
		escort_count += 3
	escort_count = mini(escort_count, MAX_ENEMIES - get_tree().get_nodes_in_group("survivor_enemies").size())
	var escort_kinds := _pressure_surge_escort_kinds(escort_count, pressure_step)
	last_pressure_surge_escort_kinds = escort_kinds.duplicate()
	last_pressure_surge_role_counts = _pressure_surge_role_counts(escort_kinds)
	last_pressure_surge_profile = _pressure_surge_profile_id(pressure_step)
	for i in range(escort_count):
		var escort_kind := str(escort_kinds[i]) if i < escort_kinds.size() else _weighted_enemy_kind()
		_spawn_enemy(_pressure_surge_spawn_position(escort_kind, i, escort_count), escort_kind, false)
	if spawned_elites > 0:
		hud.show_message("虚空压力波：精英小队逼近。", 2.2)
		_shake(5.2, 0.16)
		_spawn_pulse_visual(player.global_position, 132.0, Color(1.0, 0.10, 0.20, 0.11))
		_play_sound("skill")

func _pressure_surge_profile_id(pressure_step: int) -> String:
	if boss_alive:
		return "boss_escort_lockdown"
	if pressure_step >= 5 or elapsed >= 210.0:
		return "void_full_mix"
	if pressure_step >= 3 or elapsed >= 120.0:
		return "pincer_artillery_mix"
	return "early_pincer"

func _pressure_surge_escort_kinds(count: int, pressure_step: int) -> Array:
	var pattern: Array = []
	match _pressure_surge_profile_id(pressure_step):
		"boss_escort_lockdown":
			pattern = ["burrower", "void_eye", "carapace", "rift_crystal", "skitter", "spitter"]
		"void_full_mix":
			pattern = ["skitter", "burrower", "void_eye", "carapace", "rift_crystal", "spitter"]
		"pincer_artillery_mix":
			pattern = ["skitter", "burrower", "spitter", "void_eye", "carapace"]
		_:
			pattern = ["skitter", "spitter", "voidling", "burrower"]
	var kinds: Array = []
	for i in range(count):
		if i < pattern.size():
			kinds.append(pattern[i])
			continue
		if pressure_step >= 5 and i % 7 == 0:
			kinds.append("rift_crystal")
		elif pressure_step >= 4 and i % 5 == 0:
			kinds.append("void_eye")
		elif pressure_step >= 3 and i % 4 == 0:
			kinds.append("carapace")
		else:
			kinds.append(_weighted_enemy_kind())
	return kinds

func _pressure_surge_role_counts(kinds: Array) -> Dictionary:
	var counts := {}
	for kind_value in kinds:
		var role := _pressure_surge_role_for_kind(str(kind_value))
		counts[role] = int(counts.get(role, 0)) + 1
	return counts

func _pressure_surge_role_for_kind(kind: String) -> String:
	match kind:
		"skitter", "burrower":
			return "diver"
		"spitter", "void_eye":
			return "artillery"
		"carapace":
			return "tank"
		"rift_crystal":
			return "summoner"
		_:
			return "swarm"

func _pressure_surge_spawn_position(kind: String, index: int, total: int) -> Vector2:
	if player == null:
		return _random_spawn_position()
	var role := _pressure_surge_role_for_kind(kind)
	var angle := TAU * float(index) / maxf(1.0, float(total)) + float(_director_pressure_step()) * 0.17
	var dist_min := SPAWN_MIN_RADIUS
	var dist_max := SPAWN_MAX_RADIUS
	match role:
		"diver":
			dist_min = 500.0
			dist_max = 650.0
		"artillery":
			dist_min = 650.0
			dist_max = 850.0
		"tank":
			dist_min = 560.0
			dist_max = 720.0
		"summoner":
			dist_min = 700.0
			dist_max = 860.0
		_:
			pass
	var pos: Vector2 = player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(dist_min, dist_max)
	pos.x = clampf(pos.x, ARENA.position.x + 48.0, ARENA.end.x - 48.0)
	pos.y = clampf(pos.y, ARENA.position.y + 48.0, ARENA.end.y - 48.0)
	return pos

func _random_near_player(radius: float) -> Vector2:
	var angle := randf_range(0.0, TAU)
	var dist := randf_range(38.0, radius)
	var pos: Vector2 = player.global_position + Vector2(cos(angle), sin(angle)) * dist
	pos.x = clampf(pos.x, ARENA.position.x + 32.0, ARENA.end.x - 32.0)
	pos.y = clampf(pos.y, ARENA.position.y + 32.0, ARENA.end.y - 32.0)
	return pos

func _spawn_pack(current_enemy_count: int) -> void:
	var pressure_step := _director_pressure_step()
	var count := 10 + pressure_step * 2 + int(float(wave) * 0.75)
	count += int(maxf(0.0, elapsed - 30.0) / 55.0)
	if elapsed >= 50.0:
		count += 2
	if elapsed >= 100.0:
		count += 3
	if elapsed >= 160.0:
		count += 3
	if elapsed >= 210.0:
		count += 4
	if elapsed >= 320.0:
		count += 4
	if boss_spawned:
		count += 3
	if active_fate_id == "swarm_alarm":
		count += 3
	elif active_fate_id == "unstable_forge" or active_fate_id == "prismatic_party":
		count += 2
	var remaining := MAX_ENEMIES - current_enemy_count
	if remaining <= 0:
		return
	if current_enemy_count > int(MAX_ENEMIES * 0.72):
		count = mini(count, 8 + pressure_step)
	count = mini(count, remaining)
	for i in range(count):
		_spawn_enemy(_random_spawn_position(), _weighted_enemy_kind(), false)

func _director_pressure_step() -> int:
	var step := enemy_pressure_bonus
	if elapsed >= 35.0:
		step += 1
	if elapsed >= 75.0:
		step += 1
	if elapsed >= 120.0:
		step += 1
	if elapsed >= 180.0:
		step += 1
	if elapsed >= 250.0:
		step += 1
	if elapsed >= 330.0:
		step += 1
	if elapsed >= 430.0:
		step += 1
	if elapsed >= 540.0:
		step += 1
	if boss_spawned:
		step += 1
	return step

func _spawn_boss() -> void:
	boss_spawned = true
	boss_alive = true
	var bosses := ["boss_cho", "boss_velkoz", "boss_reksai", "boss_belveth"]
	var boss_kind := str(bosses[randi() % bosses.size()])
	_spawn_enemy(_random_spawn_position(), boss_kind, true, true)
	hud.show_message("%s 登场！" % _boss_name(boss_kind), 3.0)
	_shake(9.0, 0.45)
	_play_sound("victory")

func _boss_name(kind: String) -> String:
	match kind:
		"boss_velkoz":
			return "虚空之眼 维克兹"
		"boss_reksai":
			return "虚空遁地兽 雷克塞"
		"boss_belveth":
			return "虚空女皇 卑尔维斯"
		_:
			return "虚空恐惧 科加斯"

func _spawn_enemy(pos: Vector2, kind: String, elite := false, force_spawn := false):
	if not force_spawn and get_tree().get_nodes_in_group("survivor_enemies").size() >= MAX_ENEMIES:
		return null
	var enemy = EnemyScene.new()
	enemy.setup(kind, wave + (4 if elite else 0), kind.begins_with("boss_"))
	enemy.elite = elite
	if elite and not kind.begins_with("boss_"):
		enemy.elite_trait = _elite_trait(kind)
		if enemy.has_method("configure_elite_trait"):
			enemy.configure_elite_trait(enemy.elite_trait)
		enemy.max_health += 30 + int(wave * 2.8) + _director_pressure_step() * 5
		enemy.speed *= 1.04 + float(_director_pressure_step()) * 0.018
		enemy.score_value += 110
		enemy.xp_value += 4 + reward_bonus
		enemy.scale = Vector2(1.18, 1.18)
		enemy.hit_radius += 4.0
		match str(enemy.elite_trait):
			"frenzy":
				enemy.speed *= 1.24
				enemy.score_value += 30
			"bulwark":
				enemy.max_health += 16 + int(wave * 0.60)
				enemy.hit_radius += 2.0
				enemy.score_value += 45
			"splitter":
				enemy.xp_value += 2
				enemy.score_value += 35
			"treasure":
				enemy.xp_value += 2
				enemy.score_value += 60
			_:
				pass
		enemy.health = enemy.max_health
	enemy.position = pos
	_hide_2d_canvas_item(enemy)
	enemy.died.connect(_on_enemy_died)
	enemy.damaged.connect(_on_enemy_damaged)
	enemy.projectile_requested.connect(_on_enemy_projectile_requested)
	enemy.spawn_requested.connect(_on_enemy_spawn_requested)
	enemy.zone_requested.connect(_on_enemy_zone_requested)
	add_child(enemy)
	_spawn_enemy_spawn_rift(pos, kind, elite, kind.begins_with("boss_"))
	if elite:
		_spawn_elite_entry_visual(pos, kind.begins_with("boss_"))
	return enemy

func _spawn_enemy_spawn_rift(pos: Vector2, enemy_kind: String, was_elite: bool, was_boss: bool) -> void:
	if not _trim_spawn_rift_budget(was_elite or was_boss):
		return
	var color := Color(0.70, 0.20, 1.0, 0.40)
	match enemy_kind:
		"spitter":
			color = Color(0.52, 1.0, 0.28, 0.38)
		"burrower", "boss_reksai":
			color = Color(1.0, 0.44, 0.16, 0.42)
		"carapace", "boss_cho":
			color = Color(0.84, 0.38, 1.0, 0.44)
		"void_eye", "boss_velkoz":
			color = Color(0.94, 0.34, 1.0, 0.44)
		"rift_crystal":
			color = Color(0.34, 0.86, 1.0, 0.42)
		"boss_belveth":
			color = Color(0.78, 0.24, 1.0, 0.46)
		_:
			pass
	var radius := 72.0
	if was_boss:
		radius = 224.0
	elif was_elite:
		radius = 136.0
	elif enemy_kind == "rift_crystal" or enemy_kind == "void_eye":
		radius = 92.0
	var rift = SpawnRiftScene.new()
	rift.setup(pos, enemy_kind, was_elite, was_boss, radius, color)
	_hide_2d_canvas_item(rift)
	add_child(rift)

func _trim_spawn_rift_budget(priority: bool) -> bool:
	var rifts := get_tree().get_nodes_in_group("survivor_spawn_rifts")
	if rifts.size() < MAX_SPAWN_RIFTS:
		return true
	var removable = null
	for rift in rifts:
		if not is_instance_valid(rift):
			continue
		if not bool(rift.get("boss")) and not bool(rift.get("elite")):
			removable = rift
			break
	if removable == null and priority and rifts.size() > 0:
		removable = rifts[0]
	if removable != null and is_instance_valid(removable):
		removable.remove_from_group("survivor_spawn_rifts")
		removable.queue_free()
		return true
	return priority

func _on_enemy_spawn_requested(pos: Vector2, kind: String, count: int) -> void:
	var current_enemy_count := get_tree().get_nodes_in_group("survivor_enemies").size()
	var spawn_count := mini(count, MAX_ENEMIES - current_enemy_count)
	if spawn_count <= 0:
		return
	for i in range(spawn_count):
		var angle := TAU * (float(i) / float(maxi(1, spawn_count))) + randf_range(-0.22, 0.22)
		var dist := randf_range(46.0, 104.0)
		var spawn_pos := pos + Vector2(cos(angle), sin(angle)) * dist
		spawn_pos.x = clampf(spawn_pos.x, ARENA.position.x + 42.0, ARENA.end.x - 42.0)
		spawn_pos.y = clampf(spawn_pos.y, ARENA.position.y + 42.0, ARENA.end.y - 42.0)
		_spawn_enemy(spawn_pos, kind, false)

func _spawn_elite_entry_visual(pos: Vector2, boss_entry: bool) -> void:
	if boss_entry:
		_spawn_pulse_visual(pos, 260.0, Color(1.0, 0.14, 0.30, 0.26))
		_spawn_pulse_visual(pos, 184.0, Color(0.78, 0.22, 1.0, 0.22))
		_spawn_pulse_visual(pos, 96.0, Color(1.0, 0.76, 0.20, 0.18))
		return
	_spawn_pulse_visual(pos, 148.0, Color(0.82, 0.54, 1.0, 0.22))
	_spawn_pulse_visual(pos, 82.0, Color(1.0, 0.76, 0.20, 0.14))

func _random_spawn_position() -> Vector2:
	var center: Vector2 = player.global_position if player != null and player.visible else ARENA.get_center()
	for i in range(10):
		var angle := randf_range(0.0, TAU)
		var dist := randf_range(SPAWN_MIN_RADIUS, SPAWN_MAX_RADIUS)
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * dist
		if ARENA.has_point(pos):
			return pos
	var fallback: Vector2 = center + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * SPAWN_MIN_RADIUS
	fallback.x = clampf(fallback.x, ARENA.position.x + 48.0, ARENA.end.x - 48.0)
	fallback.y = clampf(fallback.y, ARENA.position.y + 48.0, ARENA.end.y - 48.0)
	return fallback

func _weighted_enemy_kind() -> String:
	var pool := ["voidling", "voidling", "skitter"]
	if elapsed >= 35.0:
		pool.append("spitter")
	if wave >= 2:
		pool.append("skitter")
		pool.append("skitter")
		pool.append("spitter")
	if wave >= 3:
		pool.append("burrower")
		pool.append("spitter")
	if wave >= 4:
		pool.append("carapace")
	if wave >= 5:
		pool.append("void_eye")
		pool.append("burrower")
	if wave >= 6:
		pool.append("rift_crystal")
	if wave >= 7:
		pool.append("burrower")
		pool.append("void_eye")
	if wave >= 8:
		pool.append("carapace")
		pool.append("rift_crystal")
	if wave >= 10:
		pool.append("spitter")
		pool.append("void_eye")
		pool.append("rift_crystal")
	if active_fate_id == "swarm_alarm":
		pool.append("voidling")
		pool.append("skitter")
	elif active_fate_id == "prismatic_party":
		pool.append("void_eye")
		pool.append("burrower")
	return pool[randi() % pool.size()]

func _elite_kind() -> String:
	var pool := ["skitter", "spitter", "burrower", "carapace", "void_eye", "rift_crystal"]
	return pool[randi() % pool.size()]

func _elite_trait(enemy_kind: String) -> String:
	if fate_forced_elite_trait != "":
		var forced_trait := fate_forced_elite_trait
		fate_forced_elite_trait = ""
		return forced_trait
	var pool := ["frenzy", "bulwark", "splitter", "treasure"]
	if enemy_kind == "carapace":
		pool.append("bulwark")
	elif enemy_kind == "skitter" or enemy_kind == "burrower":
		pool.append("frenzy")
	elif enemy_kind == "rift_crystal":
		pool.append("splitter")
	if active_fate_id == "void_rivalry":
		pool.append("treasure")
		pool.append("frenzy")
	return str(pool[randi() % pool.size()])

func _elite_trait_prefix(enemy) -> String:
	if enemy == null or not is_instance_valid(enemy):
		return ""
	match str(enemy.get("elite_trait")):
		"frenzy":
			return "狂暴"
		"bulwark":
			return "堡垒"
		"splitter":
			return "分裂"
		"treasure":
			return "宝藏"
		_:
			return ""

func _on_player_projectile_requested(pos: Vector2, vel: Vector2, damage: int, radius: float, color: Color, label: String, pierce: int, ttl: float) -> void:
	_spawn_projectile(pos, vel, damage, radius, color, label, pierce, ttl, true)
	_play_sound("attack")

func _on_enemy_projectile_requested(pos: Vector2, vel: Vector2, damage: int, radius: float, color: Color, label: String) -> void:
	_spawn_projectile(pos, vel, damage, radius, color, label, 0, 4.0, false)

func _spawn_projectile(pos: Vector2, vel: Vector2, damage: int, radius: float, color: Color, label: String, pierce: int, ttl: float, from_player: bool) -> void:
	if get_tree().get_nodes_in_group("survivor_projectiles").size() >= MAX_PROJECTILES:
		return
	var projectile = ProjectileScene.new()
	projectile.setup(pos, vel, damage, radius, color, label, pierce, ttl, from_player)
	_hide_2d_canvas_item(projectile)
	projectile.hit_something.connect(_on_projectile_hit)
	add_child(projectile)

func _on_player_pulse_requested(pos: Vector2, radius: float, damage: int, color: Color) -> void:
	for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
		if not is_instance_valid(enemy):
			continue
		if pos.distance_to(enemy.global_position) <= radius + enemy.hit_radius:
			enemy.take_damage(damage, pos, false)
	_spawn_pulse_visual(pos, radius, color)
	_play_sound("skill")

func _on_player_effect_requested(pos: Vector2, radius: float, color: Color) -> void:
	_spawn_pulse_visual(pos, radius, color)

func _on_player_zone_requested(pos: Vector2, kind: String, radius: float, damage: int, duration: float, tick_interval: float, color: Color, status: String, power: int) -> void:
	_spawn_zone(pos, kind, radius, damage, duration, tick_interval, color, status, power, true)

func _on_enemy_zone_requested(pos: Vector2, kind: String, radius: float, damage: int, duration: float, tick_interval: float, color: Color, status: String, power: int) -> void:
	_spawn_zone(pos, kind, radius, damage, duration, tick_interval, color, status, power, false)

func _spawn_zone(pos: Vector2, kind: String, radius: float, damage: int, duration: float, tick_interval: float, color: Color, status: String, power: int, from_player := true) -> void:
	var zones := get_tree().get_nodes_in_group("survivor_zones")
	if zones.size() >= MAX_ZONES:
		var oldest = zones[0]
		if is_instance_valid(oldest):
			oldest.queue_free()
	var zone = ZoneScene.new()
	zone.setup(pos, kind, radius, damage, duration, tick_interval, color, status, power, from_player)
	_hide_2d_canvas_item(zone)
	add_child(zone)

func _spawn_pulse_visual(pos: Vector2, radius: float, color: Color) -> void:
	_trim_pulse_budget()
	var pulse = PulseScene.new()
	pulse.name = "Pulse"
	pulse.setup(pos, radius, color)
	_hide_2d_canvas_item(pulse)
	add_child(pulse)

func _trim_pulse_budget() -> void:
	var pulses := get_tree().get_nodes_in_group("survivor_pulses")
	while pulses.size() >= MAX_PULSES:
		var oldest = pulses[0]
		pulses.remove_at(0)
		if is_instance_valid(oldest):
			oldest.queue_free()

func _on_projectile_hit(pos: Vector2, amount: int, projectile_color: Color, label: String) -> void:
	if impact_vfx_timer <= 0.0:
		impact_vfx_timer = 0.035
		var impact_color := _projectile_impact_color(label, projectile_color)
		var impact_radius := _projectile_impact_radius(label, amount)
		_spawn_hit_spark(pos, label, amount, impact_radius, impact_color)
		_spawn_pulse_visual(pos, impact_radius, Color(impact_color.r, impact_color.g, impact_color.b, 0.22))
	if player == null or not player.has_hextech_augment("chain_lightning") or chain_lightning_timer > 0.0:
		return
	if randf() > 0.38:
		return
	chain_lightning_timer = 0.22
	var jumps := 0
	var arc_damage := maxi(1, int(amount * 0.45) + 1)
	for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
		if not is_instance_valid(enemy):
			continue
		if pos.distance_to(enemy.global_position) <= 128.0:
			enemy.take_damage(arc_damage, pos, false)
			jumps += 1
			if jumps >= 3:
				break
	if jumps > 0:
		_spawn_pulse_visual(pos, 128.0, Color(0.58, 0.82, 1.0, 0.22))

func _spawn_hit_spark(pos: Vector2, label: String, amount: int, radius: float, color: Color) -> void:
	var important := amount >= 8 or label == "death_rocket" or label == "comet" or label == "fishbones"
	if not _trim_hit_spark_budget(important):
		return
	var spark = HitSparkScene.new()
	spark.setup(pos, label, _projectile_impact_family(label), amount, radius, Color(color.r, color.g, color.b, 0.48), important)
	_hide_2d_canvas_item(spark)
	add_child(spark)

func _trim_hit_spark_budget(priority: bool) -> bool:
	var sparks := get_tree().get_nodes_in_group("survivor_hit_sparks")
	if sparks.size() < MAX_HIT_SPARKS:
		return true
	var removable = null
	for spark in sparks:
		if not is_instance_valid(spark):
			continue
		if not bool(spark.get("priority")):
			removable = spark
			break
	if removable == null and priority and sparks.size() > 0:
		removable = sparks[0]
	if removable != null and is_instance_valid(removable):
		removable.remove_from_group("survivor_hit_sparks")
		removable.queue_free()
		return true
	return priority

func _projectile_impact_family(label: String) -> String:
	match label:
		"fishbones", "death_rocket":
			return "explosive"
		"senna", "senna_beam", "senna_snare", "viktor", "viktor_laser", "comet":
			return "magic"
		"teemo", "teemo_dart", "blind_dart":
			return "poison"
		"morde":
			return "void"
		"xayah", "xayah_feather", "xayah_recall", "samira", "samira_pistol", "powpow":
			return "physical"
		_:
			return "physical"

func _projectile_impact_color(label: String, fallback: Color) -> Color:
	match label:
		"fishbones":
			return Color(1.0, 0.62, 0.18)
		"death_rocket":
			return Color(1.0, 0.28, 0.24)
		"senna_beam", "senna_snare":
			return Color(0.58, 1.0, 0.78)
		"viktor_laser":
			return Color(0.62, 0.92, 1.0)
		"xayah_feather", "xayah_recall":
			return Color(1.0, 0.34, 0.68)
		"teemo_dart", "blind_dart":
			return Color(0.62, 1.0, 0.22)
		"samira_pistol":
			return Color(1.0, 0.58, 0.18)
		"powpow":
			return Color(0.42, 0.82, 1.0)
		"comet":
			return Color(0.92, 0.72, 1.0)
		_:
			return fallback

func _projectile_impact_radius(label: String, amount: int) -> float:
	var radius := 30.0 + minf(34.0, float(amount) * 3.2)
	match label:
		"death_rocket":
			radius += 48.0
		"fishbones", "comet":
			radius += 26.0
		"senna_beam", "senna_snare", "viktor_laser":
			radius += 14.0
		"xayah_recall", "blind_dart":
			radius += 10.0
		_:
			pass
	return radius

func _on_enemy_damaged(pos: Vector2, amount: int, critical: bool) -> void:
	if use_3d_view and not critical and amount < 7 and randf() > 0.07:
		return
	if amount < 5 and randf() > 0.14:
		return
	_spawn_floating_text(pos + Vector2(randf_range(-10, 10), -28), "%d%s" % [amount, "!" if critical else ""], Color(1.0, 0.92, 0.40), 14 if not critical else 18)

func _on_enemy_died(enemy) -> void:
	if not is_instance_valid(enemy):
		return
	var death_pos: Vector2 = enemy.global_position
	var was_elite := bool(enemy.elite)
	var enemy_kind := str(enemy.kind)
	var elite_trait := str(enemy.get("elite_trait"))
	player.add_score(enemy.score_value)
	player.notify_enemy_killed(was_elite, enemy_kind)
	_spawn_enemy_death_visual(death_pos, enemy_kind, was_elite)
	_spawn_pickup(death_pos, "xp", enemy.xp_value + reward_bonus, _xp_color(enemy.xp_value + reward_bonus))

	if was_elite and player.has_hextech_augment("vampiric_spoon"):
		player.heal(2)
		_spawn_floating_text(death_pos + Vector2(-16, -38), "+2 生命", Color(1.0, 0.38, 0.38), 15)
	if was_elite and not enemy_kind.begins_with("boss_"):
		if elite_trait == "splitter":
			_on_enemy_spawn_requested(death_pos, "voidling", 3)
			_spawn_pulse_visual(death_pos, 118.0, Color(0.78, 0.22, 1.0, 0.18))
		_drop_elite_reward(death_pos, elite_trait)

	var gold_chance := 0.10 + reward_bonus * 0.025
	var gold_amount := 1 + int(wave / 2) + reward_bonus
	if player.has_hextech_augment("lucky_find"):
		gold_chance += 0.06
	if player.has_hextech_augment("treasure_sense"):
		gold_chance += 0.12
		gold_amount += 1 + int(wave / 3)
	if randf() < gold_chance:
		_spawn_pickup(death_pos + Vector2(randf_range(-18, 18), randf_range(-18, 18)), "gold", gold_amount, Color(1.0, 0.76, 0.20))
	if randf() < 0.018:
		_spawn_pickup(death_pos + Vector2(randf_range(-18, 18), randf_range(-18, 18)), "heal", 1, Color(1.0, 0.30, 0.32))
	_play_sound("enemy_down")
	if enemy_kind.begins_with("boss_"):
		boss_alive = false
		_finish_run(true)

func _spawn_enemy_death_visual(pos: Vector2, enemy_kind: String, was_elite: bool) -> void:
	var color := Color(0.72, 0.20, 1.0, 0.18)
	match enemy_kind:
		"spitter":
			color = Color(0.54, 1.0, 0.28, 0.20)
		"burrower", "boss_reksai":
			color = Color(1.0, 0.46, 0.16, 0.20)
		"void_eye", "boss_velkoz":
			color = Color(0.96, 0.38, 1.0, 0.22)
		"rift_crystal":
			color = Color(0.44, 0.86, 1.0, 0.22)
		"boss_cho":
			color = Color(0.86, 0.34, 1.0, 0.24)
		"boss_belveth":
			color = Color(0.78, 0.26, 1.0, 0.24)
		_:
			pass
	var radius := 54.0
	if enemy_kind.begins_with("boss_"):
		radius = 230.0
	elif was_elite:
		radius = 136.0
	elif enemy_kind == "rift_crystal" or enemy_kind == "void_eye":
		radius = 74.0
	_spawn_enemy_death_burst(pos, enemy_kind, was_elite, enemy_kind.begins_with("boss_"), radius, color)
	_spawn_pulse_visual(pos, radius, color)
	if enemy_kind.begins_with("boss_"):
		_spawn_boss_clear_visual(pos)

func _spawn_enemy_death_burst(pos: Vector2, enemy_kind: String, was_elite: bool, was_boss: bool, radius: float, color: Color) -> void:
	if not _trim_death_burst_budget(was_elite or was_boss):
		return
	var burst = DeathBurstScene.new()
	burst.setup(pos, enemy_kind, was_elite, was_boss, radius, color)
	_hide_2d_canvas_item(burst)
	add_child(burst)

func _trim_death_burst_budget(priority: bool) -> bool:
	var bursts := get_tree().get_nodes_in_group("survivor_death_bursts")
	if bursts.size() < MAX_DEATH_BURSTS:
		return true
	var removable = null
	for burst in bursts:
		if not is_instance_valid(burst):
			continue
		if not bool(burst.get("boss")) and not bool(burst.get("elite")):
			removable = burst
			break
	if removable == null and priority and bursts.size() > 0:
		removable = bursts[0]
	if removable != null and is_instance_valid(removable):
		removable.remove_from_group("survivor_death_bursts")
		removable.queue_free()
		return true
	return priority

func _spawn_boss_clear_visual(pos: Vector2) -> void:
	_spawn_pulse_visual(pos, 260.0, Color(1.0, 0.76, 0.20, 0.22))
	_spawn_pulse_visual(pos, 190.0, Color(0.72, 0.95, 1.0, 0.18))
	_spawn_pulse_visual(pos, 132.0, Color(0.78, 0.22, 1.0, 0.18))

func _drop_elite_reward(pos: Vector2, elite_trait := "") -> void:
	_spawn_pulse_visual(pos, 168.0, Color(1.0, 0.76, 0.20, 0.20))
	_spawn_pulse_visual(pos, 112.0, Color(0.82, 0.54, 1.0, 0.22))
	_spawn_pulse_visual(pos, 74.0, Color(0.72, 0.95, 1.0, 0.16))
	var xp_amount := 3 + int(wave / 3) + reward_bonus
	var chunks := 4
	if player.has_hextech_augment("elite_hunter"):
		chunks += 2
		xp_amount += 1
	for i in range(chunks):
		var angle := TAU * float(i) / float(chunks)
		var offset := Vector2(cos(angle), sin(angle)) * randf_range(18.0, 48.0)
		_spawn_pickup(pos + offset, "xp", xp_amount, _xp_color(xp_amount))
	var gold_amount := 10 + wave * 2 + reward_bonus * 4
	if player.has_hextech_augment("elite_hunter"):
		gold_amount += 10
	if elite_trait == "treasure":
		gold_amount += 16 + wave
	_spawn_pickup(pos + Vector2(randf_range(-28, 28), randf_range(-28, 28)), "gold", gold_amount, Color(1.0, 0.76, 0.20))
	_spawn_pickup(pos + Vector2(randf_range(-28, 28), randf_range(-28, 28)), "shield", 1 + int(wave / 5), Color(0.72, 0.95, 1.0))
	if elite_trait == "treasure":
		_spawn_pickup(pos + Vector2(randf_range(-34, 34), randf_range(-34, 34)), "gold", maxi(8, int(gold_amount * 0.45)), Color(1.0, 0.76, 0.20))
	if randf() < 0.45:
		_spawn_pickup(pos + Vector2(randf_range(-28, 28), randf_range(-28, 28)), "heal", 1, Color(1.0, 0.30, 0.32))
	_spawn_floating_text(pos + Vector2(-42, -52), "精英战利品", Color(0.82, 0.54, 1.0), 18)

func _spawn_pickup(pos: Vector2, kind: String, amount: int, color: Color) -> void:
	_trim_pickup_budget()
	var pickup = PickupScene.new()
	pickup.setup(pos, kind, amount, color)
	_hide_2d_canvas_item(pickup)
	pickup.collected.connect(_on_pickup_collected)
	add_child(pickup)

func _trim_pickup_budget() -> void:
	var pickups := get_tree().get_nodes_in_group("survivor_pickups")
	while pickups.size() >= MAX_PICKUPS:
		var candidate = null
		var candidate_index := -1
		for i in range(pickups.size()):
			var pickup = pickups[i]
			if is_instance_valid(pickup) and str(pickup.get("kind")) == "xp":
				candidate = pickup
				candidate_index = i
				break
		if candidate == null and pickups.size() > 0:
			candidate = pickups[0]
			candidate_index = 0
		if candidate_index >= 0:
			pickups.remove_at(candidate_index)
		else:
			break
		if is_instance_valid(candidate):
			candidate.queue_free()

func _hide_2d_canvas_item(node: Node) -> void:
	if use_3d_view and node is CanvasItem:
		var item := node as CanvasItem
		item.modulate = Color(1.0, 1.0, 1.0, 0.0)
		if not (node is CinnaSurvivorPlayer):
			item.visible = false

func _enforce_runtime_budget() -> void:
	_trim_enemy_budget()
	_trim_projectile_budget()
	_trim_pickup_budget()
	_trim_group_budget("survivor_zones", MAX_ZONES)
	_trim_group_budget("survivor_pulses", MAX_PULSES)
	_trim_group_budget("survivor_spawn_rifts", MAX_SPAWN_RIFTS)
	_trim_group_budget("survivor_death_bursts", MAX_DEATH_BURSTS)
	_trim_group_budget("survivor_hit_sparks", MAX_HIT_SPARKS)

func _trim_enemy_budget() -> void:
	var enemies := get_tree().get_nodes_in_group("survivor_enemies")
	if enemies.size() <= MAX_ENEMIES or player == null:
		return
	var candidates: Array = []
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if bool(enemy.get("boss")) or bool(enemy.get("elite")):
			continue
		candidates.append(enemy)
	candidates.sort_custom(func(a, b): return player.global_position.distance_squared_to(a.global_position) > player.global_position.distance_squared_to(b.global_position))
	var over := enemies.size() - MAX_ENEMIES
	for enemy in candidates:
		if over <= 0:
			break
		if is_instance_valid(enemy):
			enemy.queue_free()
			over -= 1

func _trim_projectile_budget() -> void:
	var projectiles := get_tree().get_nodes_in_group("survivor_projectiles")
	if projectiles.size() <= MAX_PROJECTILES or player == null:
		return
	var candidates: Array = []
	for projectile in projectiles:
		if is_instance_valid(projectile):
			candidates.append(projectile)
	candidates.sort_custom(func(a, b): return player.global_position.distance_squared_to(a.global_position) > player.global_position.distance_squared_to(b.global_position))
	var over := projectiles.size() - MAX_PROJECTILES
	for projectile in candidates:
		if over <= 0:
			break
		if is_instance_valid(projectile):
			projectile.queue_free()
			over -= 1

func _trim_group_budget(group_name: String, cap: int) -> void:
	var nodes := get_tree().get_nodes_in_group(group_name)
	while nodes.size() > cap:
		var node = nodes[0]
		nodes.remove_at(0)
		if is_instance_valid(node):
			node.queue_free()

func _on_pickup_collected(kind: String, amount: int, pos: Vector2) -> void:
	match kind:
		"xp":
			player.add_xp(amount)
		"gold":
			player.add_gold(amount)
			player.add_score(amount * 25)
		"heal":
			player.heal(amount)
		"shield":
			player.add_shield(amount)
		_:
			player.add_xp(amount)
	var show_pickup_text := kind != "xp" or amount >= 3
	if use_3d_view:
		show_pickup_text = (kind == "xp" and amount >= 6) or (kind == "gold" and amount >= 8) or kind == "heal" or kind == "shield"
	if show_pickup_text:
		_spawn_floating_text(pos + Vector2(-8, -14), "+" + str(amount), Color(0.62, 1.0, 0.58), 13)
	_play_sound("pickup")

func _on_player_damaged(pos: Vector2, amount: int) -> void:
	if amount <= 0:
		_spawn_floating_text(pos + Vector2(-18, -34), "死里逃生", Color(0.82, 0.54, 1.0), 18)
		_spawn_pulse_visual(pos, 118.0, Color(0.82, 0.54, 1.0, 0.22))
	else:
		_spawn_floating_text(pos + Vector2(-12, -34), "-%d" % amount, Color(1.0, 0.32, 0.22), 18)
		_spawn_pulse_visual(pos, 92.0 + float(amount) * 12.0, Color(1.0, 0.16, 0.22, 0.20))
	_shake(6.0, 0.18)
	_play_sound("hurt")

func _on_player_died() -> void:
	_finish_run(false)

func _finish_run(won: bool) -> void:
	if game_state == "summary":
		return
	game_state = "summary"
	player.set_controls_enabled(false)
	_set_arena_active(false)
	hud.show_summary(won, player, elapsed)
	_play_sound("victory" if won else "defeat")

func _clear_arena() -> void:
	for group in ["survivor_enemies", "survivor_projectiles", "survivor_pickups", "survivor_zones", "survivor_spawn_rifts", "survivor_death_bursts", "survivor_hit_sparks"]:
		for node in get_tree().get_nodes_in_group(group):
			if is_instance_valid(node):
				node.queue_free()
	for child in get_children():
		if str(child.name).begins_with("Pulse") or str(child.name).begins_with("Float"):
			child.queue_free()

func _set_arena_active(active: bool) -> void:
	for group in ["survivor_enemies", "survivor_projectiles", "survivor_pickups", "survivor_zones", "survivor_spawn_rifts", "survivor_death_bursts", "survivor_hit_sparks"]:
		for node in get_tree().get_nodes_in_group(group):
			if is_instance_valid(node):
				node.set_process(active)

func _cull_far_entities() -> void:
	if player == null:
		return
	var center: Vector2 = player.global_position
	var far_enemy_dist_sq := 1120.0 * 1120.0
	for enemy in get_tree().get_nodes_in_group("survivor_enemies"):
		if not is_instance_valid(enemy):
			continue
		if bool(enemy.get("boss")):
			continue
		if center.distance_squared_to(enemy.global_position) > far_enemy_dist_sq:
			enemy.queue_free()
	var far_pickup_dist_sq := 1280.0 * 1280.0
	for pickup in get_tree().get_nodes_in_group("survivor_pickups"):
		if not is_instance_valid(pickup):
			continue
		if center.distance_squared_to(pickup.global_position) > far_pickup_dist_sq:
			pickup.queue_free()
	var far_zone_dist_sq := 1320.0 * 1320.0
	for zone in get_tree().get_nodes_in_group("survivor_zones"):
		if not is_instance_valid(zone):
			continue
		if center.distance_squared_to(zone.global_position) > far_zone_dist_sq:
			zone.queue_free()

func _spawn_floating_text(pos: Vector2, text: String, color: Color, size := 16) -> void:
	if use_3d_view and size < 18:
		return
	var floating_texts := get_tree().get_nodes_in_group("survivor_floating_text")
	if floating_texts.size() >= MAX_FLOATING_TEXTS:
		var oldest = floating_texts[0]
		if is_instance_valid(oldest):
			oldest.queue_free()
	var floating = FloatingTextScene.new()
	floating.name = "Float"
	floating.position = pos
	floating.setup(text, color, size)
	add_child(floating)

func _xp_color(amount: int) -> Color:
	if amount >= 5:
		return Color(0.38, 0.62, 0.86)
	if amount >= 3:
		return Color(0.46, 0.76, 0.34)
	return Color(0.30, 0.70, 0.38)

func _play_sound(key: String) -> void:
	if sound != null and sound.has_method("play_sfx"):
		sound.play_sfx(key)

func _shake(strength: float, duration: float) -> void:
	shake_strength = maxf(shake_strength, strength)
	shake_time = maxf(shake_time, duration)

func _update_camera(_delta: float) -> void:
	if camera == null:
		return
	if player != null and player.visible and game_state != "menu":
		camera.position = _clamp_camera_position(player.global_position)
	else:
		camera.position = ARENA.get_center()

func _clamp_camera_position(pos: Vector2) -> Vector2:
	var half := Vector2(640.0, 360.0)
	pos.x = clampf(pos.x, ARENA.position.x + half.x, ARENA.end.x - half.x)
	pos.y = clampf(pos.y, ARENA.position.y + half.y, ARENA.end.y - half.y)
	return pos

func _update_camera_shake(delta: float) -> void:
	if camera == null:
		return
	if use_3d_view:
		camera.offset = Vector2.ZERO
		return
	if shake_time <= 0.0:
		camera.offset = Vector2.ZERO
		return
	shake_time -= delta
	camera.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
	shake_strength = lerpf(shake_strength, 0.0, 8.0 * delta)

func _draw() -> void:
	if use_3d_view:
		return
	if game_state == "menu":
		return
	draw_rect(ARENA, Color(0.58, 0.38, 1.0, 0.035))
	draw_rect(ARENA, Color(0.58, 0.38, 1.0, 0.26), false, 4.0)
