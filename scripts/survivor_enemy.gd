extends Node2D
class_name CinnaSurvivorEnemy

signal died(enemy: CinnaSurvivorEnemy)
signal damaged(position: Vector2, amount: int, critical: bool)
signal projectile_requested(position: Vector2, velocity: Vector2, damage: int, radius: float, color: Color, label: String)
signal spawn_requested(position: Vector2, kind: String, count: int)
signal zone_requested(position: Vector2, kind: String, radius: float, damage: int, duration: float, tick_interval: float, color: Color, status: String, power: int)

var kind := "voidling"
var max_health := 3
var health := 3
var speed := 70.0
var damage := 1
var score_value := 30
var xp_value := 1
var hit_radius := 16.0
var boss := false
var elite := false
var elite_trait := ""
var body_color := Color(0.54, 0.28, 0.82)
var contact_timer := 0.0
var attack_timer := 0.0
var attack_cycle := 0
var hurt_flash := 0.0
var wobble := 0.0
var dash_timer := 0.0
var dash_dir := Vector2.ZERO
var pounce_timer := 0.0
var summon_timer := 0.0
var wave_level := 1
var player_ref: Node2D = null
var slow_timer := 0.0
var slow_factor := 1.0
var root_timer := 0.0
var poison_timer := 0.0
var poison_tick_timer := 0.0
var poison_damage := 0
var weakened_timer := 0.0
var elite_trait_cooldown := 0.0
var bulwark_guard := 0
var bulwark_break_timer := 0.0
var splitter_spawned := false
var treasure_flee_timer := 0.0
var combat_role := ""
var last_attack_profile := ""
var last_special_profile := ""
var last_elite_trait_profile := ""
var last_zone_profile := ""

func setup(new_kind: String, new_wave: int, is_boss := false) -> void:
    kind = new_kind
    wave_level = new_wave
    boss = is_boss or kind.begins_with("boss_")
    match kind:
        "voidling":
            max_health = 2; speed = 62; damage = 1; score_value = 24; xp_value = 1; body_color = Color(0.54, 0.30, 0.82)
        "skitter":
            max_health = 3; speed = 104; damage = 1; score_value = 42; xp_value = 2; body_color = Color(0.78, 0.34, 0.94)
        "spitter":
            max_health = 4; speed = 48; damage = 1; score_value = 58; xp_value = 3; body_color = Color(0.36, 0.92, 0.46)
        "burrower":
            max_health = 6; speed = 74; damage = 1; score_value = 68; xp_value = 3; hit_radius = 18; body_color = Color(0.70, 0.42, 0.22)
        "carapace":
            max_health = 11; speed = 32; damage = 2; score_value = 88; xp_value = 4; hit_radius = 23; body_color = Color(0.34, 0.22, 0.52)
        "void_eye":
            max_health = 5; speed = 52; damage = 1; score_value = 80; xp_value = 4; body_color = Color(0.88, 0.38, 1.0)
        "rift_crystal":
            max_health = 8; speed = 18; damage = 1; score_value = 96; xp_value = 4; hit_radius = 22; body_color = Color(0.42, 0.78, 1.0)
        "boss_cho":
            _setup_boss(330 + new_wave * 26, 50, 5, 46, Color(0.48, 0.22, 0.76), 1700, 38)
        "boss_velkoz":
            _setup_boss(276 + new_wave * 24, 42, 4, 42, Color(0.90, 0.36, 1.0), 1650, 36)
        "boss_reksai":
            _setup_boss(304 + new_wave * 25, 82, 5, 44, Color(0.74, 0.38, 0.22), 1750, 37)
        "boss_belveth":
            _setup_boss(318 + new_wave * 25, 66, 4, 45, Color(0.62, 0.26, 0.92), 1800, 40)
        _:
            max_health = 3; speed = 62; damage = 1; score_value = 30; xp_value = 1; body_color = Color(0.54, 0.30, 0.82)
    combat_role = _combat_role_for_kind(kind)
    if not boss:
        max_health += int(new_wave * 5.20)
        speed += minf(130.0, new_wave * 4.90)
        if new_wave >= 5:
            max_health += int(float(new_wave - 4) * 7.40)
            speed += minf(96.0, float(new_wave - 4) * 3.90)
        if new_wave >= 7:
            max_health += int(float(new_wave - 6) * 4.80)
            speed += minf(58.0, float(new_wave - 6) * 2.70)
        if new_wave >= 11:
            max_health += int(float(new_wave - 10) * 5.25)
            speed += minf(42.0, float(new_wave - 10) * 2.10)
        if new_wave >= 2 and kind != "voidling":
            damage += 1
        if new_wave >= 3:
            damage += 1
        if new_wave >= 5:
            damage += 1
        if new_wave >= 8:
            damage += 1
        if new_wave >= 10:
            damage += 1
        if new_wave >= 12:
            damage += 1
        score_value += new_wave * 3
    health = max_health

func _setup_boss(new_health: int, new_speed: float, new_damage: int, new_radius: float, new_color: Color, new_score: int, new_xp: int) -> void:
    boss = true
    max_health = new_health
    speed = new_speed
    damage = new_damage
    hit_radius = new_radius
    body_color = new_color
    score_value = new_score
    xp_value = new_xp

func _ready() -> void:
    add_to_group("survivor_enemies")
    attack_timer = randf_range(1.2, 3.2)
    pounce_timer = randf_range(0.8, 2.2)
    summon_timer = randf_range(5.0, 8.0)
    if elite and elite_trait != "":
        _prime_elite_trait_state()
    player_ref = _find_player()
    queue_redraw()

func _process(delta: float) -> void:
    contact_timer = maxf(0.0, contact_timer - delta)
    attack_timer = maxf(0.0, attack_timer - delta)
    hurt_flash = maxf(0.0, hurt_flash - delta)
    dash_timer = maxf(0.0, dash_timer - delta)
    pounce_timer = maxf(0.0, pounce_timer - delta)
    summon_timer = maxf(0.0, summon_timer - delta)
    elite_trait_cooldown = maxf(0.0, elite_trait_cooldown - delta)
    bulwark_break_timer = maxf(0.0, bulwark_break_timer - delta)
    treasure_flee_timer = maxf(0.0, treasure_flee_timer - delta)
    wobble += delta
    _tick_statuses(delta)
    if health <= 0:
        return
    if player_ref == null or not is_instance_valid(player_ref):
        player_ref = _find_player()
    if player_ref == null:
        return
    _try_elite_trait_special(player_ref)
    _move_toward_player(delta, player_ref)
    _try_attack(player_ref)
    _try_special(player_ref)
    _check_contact(player_ref)
    queue_redraw()

func configure_elite_trait(new_trait: String) -> void:
    elite_trait = new_trait
    if elite_trait != "":
        _prime_elite_trait_state()

func _prime_elite_trait_state() -> void:
    match elite_trait:
        "frenzy":
            pounce_timer = randf_range(0.45, 0.90) if pounce_timer <= 0.0 else minf(pounce_timer, randf_range(0.45, 0.90))
            elite_trait_cooldown = minf(elite_trait_cooldown, 0.35)
        "bulwark":
            bulwark_guard = maxi(bulwark_guard, 3)
            bulwark_break_timer = 0.0
        "splitter":
            splitter_spawned = false
        "treasure":
            treasure_flee_timer = randf_range(0.85, 1.35)
            elite_trait_cooldown = randf_range(1.8, 2.8)
        _:
            pass

func _move_toward_player(delta: float, player: Node2D) -> void:
    if root_timer > 0.0:
        return
    var to_player := player.global_position - global_position
    if to_player.length() < 1.0:
        return
    var dir := to_player.normalized()
    match kind:
        "skitter":
            var dist := to_player.length()
            if dash_timer > 0.0 and dash_dir.length() > 0.01:
                dir = dash_dir
            else:
                if pounce_timer <= 0.0 and dist > 96.0 and dist < 440.0:
                    dash_dir = dir.rotated(randf_range(-0.28, 0.28)).normalized()
                    dash_timer = 0.34 if not elite else 0.44
                    pounce_timer = randf_range(1.9, 3.0) * (0.84 if elite else 1.0)
                    dir = dash_dir
                else:
                    dir = dir.rotated(sin(wobble * 7.0) * 0.55)
        "spitter", "void_eye":
            var dist := global_position.distance_to(player.global_position)
            if dist < 240.0:
                dir = -dir
            elif dist < 330.0:
                dir = dir.rotated(PI * 0.5)
        "burrower":
            if dash_timer > 0.0 and dash_dir.length() > 0.01:
                dir = dash_dir
            else:
                dir = dir.rotated(sin(wobble * 3.2) * 0.25)
        "carapace":
            dir = dir.rotated(sin(wobble * 1.8) * 0.16)
        "rift_crystal":
            if global_position.distance_to(player.global_position) < 300.0:
                dir = -dir.rotated(0.4)
            else:
                dir = dir.rotated(PI * 0.5)
        "boss_velkoz":
            if global_position.distance_to(player.global_position) < 310.0:
                dir = -dir
            else:
                dir = dir.rotated(sin(wobble * 1.4) * 0.65)
        "boss_reksai":
            if dash_timer > 2.42 and dash_dir.length() > 0.01:
                dir = dash_dir
            else:
                dir = dir.rotated(sin(wobble * 2.8) * 0.24)
        "boss_belveth":
            dir = dir.rotated(sin(wobble * 3.4) * 0.36)
        _:
            pass
    if elite_trait == "frenzy" and dash_timer > 0.0 and dash_dir.length() > 0.01:
        dir = dash_dir
    elif elite_trait == "treasure" and treasure_flee_timer > 0.0:
        dir = -to_player.normalized().rotated(sin(wobble * 4.0) * 0.42)
    var move_speed := speed
    if slow_timer > 0.0:
        move_speed *= slow_factor
    if _boss_enraged():
        move_speed *= 1.12
    if kind == "skitter" and dash_timer > 0.0:
        move_speed *= 2.45
    if kind == "burrower" and dash_timer > 0.0:
        move_speed *= 2.20
    if kind == "boss_reksai" and dash_timer > 2.42:
        move_speed *= 2.05
    if elite_trait == "frenzy":
        move_speed *= 1.18
        if dash_timer > 0.0:
            move_speed *= 1.58
    elif elite_trait == "bulwark":
        move_speed *= 0.92
    elif elite_trait == "treasure" and treasure_flee_timer > 0.0:
        move_speed *= 1.36
    position += dir * move_speed * delta

func _try_attack(player: Node2D) -> void:
    if attack_timer > 0.0:
        return
    var to_player := player.global_position - global_position
    if to_player.length() < 1.0:
        to_player = Vector2.DOWN
    var dir := to_player.normalized()
    attack_cycle += 1
    last_attack_profile = _attack_profile_for_kind(kind)
    match kind:
        "spitter":
            attack_timer = randf_range(1.85, 2.55)
            projectile_requested.emit(global_position + dir * 23.0, dir * 210.0, damage, 7.0, Color(0.46, 1.0, 0.36), "A")
        "void_eye":
            attack_timer = randf_range(2.25, 2.95)
            for side in [-1, 0, 1]:
                var beam_dir := dir.rotated(float(side) * 0.17)
                projectile_requested.emit(global_position + beam_dir * 24.0, beam_dir * 230.0, damage, 6.8, Color(0.92, 0.36, 1.0), "E")
        "rift_crystal":
            attack_timer = randf_range(2.65, 3.35)
            _radial_burst(7, 158.0, Color(0.46, 0.82, 1.0), "C")
        "burrower":
            attack_timer = randf_range(2.10, 2.85)
            dash_dir = dir
            dash_timer = 0.54 if not elite else 0.68
            projectile_requested.emit(global_position + dir * 24.0, dir * 240.0, damage, 7.5, Color(0.88, 0.50, 0.20), "R")
        "boss_cho":
            if attack_cycle % 3 == 0:
                attack_timer = 3.10
                _cone_burst(dir, 7, 0.86, 218.0, 12.0, Color(0.92, 0.62, 1.0), "Q")
                _radial_burst(6, 132.0, Color(0.70, 0.32, 1.0), "Q")
                _emit_boss_zone(dir, "boss_cho_rupture", 154.0, 3.6, 0.72, Color(0.82, 0.34, 1.0, 0.30), "rupture_devour")
            else:
                attack_timer = 2.45
                _radial_burst(10, 178.0, Color(0.70, 0.32, 1.0), "Q")
                for side in [-1, 1]:
                    var spike_dir := dir.rotated(float(side) * 0.32)
                    projectile_requested.emit(global_position + spike_dir * 42.0, spike_dir * 245.0, damage, 10.0, Color(0.92, 0.62, 1.0), "Q")
                _emit_boss_zone(dir, "boss_cho_rupture", 132.0, 2.8, 0.82, Color(0.78, 0.28, 1.0, 0.26), "rupture_spikes")
        "boss_velkoz":
            if attack_cycle % 3 == 0:
                attack_timer = 2.70
                _cone_burst(dir.rotated(sin(wobble) * 0.10), 7, 0.34, 330.0, 7.4, Color(1.0, 0.42, 1.0), "V")
                for side in [-1, 1]:
                    var focus_dir := dir.rotated(float(side) * 0.72)
                    projectile_requested.emit(global_position + focus_dir * 42.0, focus_dir * 255.0, damage, 7.2, Color(0.96, 0.38, 1.0), "V")
                _emit_boss_zone(dir, "boss_velkoz_focus", 126.0, 2.7, 0.46, Color(1.0, 0.32, 1.0, 0.28), "focus_laser_lock")
            else:
                attack_timer = 2.05
                for side in [-2, -1, 0, 1, 2]:
                    var laser_dir := dir.rotated(float(side) * 0.18 + sin(wobble) * 0.08)
                    projectile_requested.emit(global_position + laser_dir * 42.0, laser_dir * 280.0, damage, 7.6, Color(0.96, 0.38, 1.0), "V")
                _emit_boss_zone(dir, "boss_velkoz_focus", 108.0, 2.2, 0.52, Color(0.96, 0.32, 1.0, 0.24), "focus_laser_sweep")
        "boss_reksai":
            dash_dir = dir
            dash_timer = 3.0
            if attack_cycle % 2 == 0:
                attack_timer = 3.15
                _line_spikes(dir, 5, 46.0, 168.0, 9.0, Color(0.96, 0.50, 0.22), "X")
                for side in [-1, 1]:
                    var tremor_dir := dir.rotated(float(side) * 0.52)
                    projectile_requested.emit(global_position + tremor_dir * 42.0, tremor_dir * 210.0, damage, 8.4, Color(0.90, 0.46, 0.20), "X")
                _emit_boss_zone(dir, "boss_reksai_tunnel", 136.0, 3.2, 0.68, Color(1.0, 0.42, 0.18, 0.28), "burrow_tremor_field")
            else:
                attack_timer = 2.85
                projectile_requested.emit(global_position + dir * 40.0, dir * 255.0, damage, 9.0, Color(0.90, 0.46, 0.20), "X")
                projectile_requested.emit(global_position + dir.rotated(0.28) * 36.0, dir.rotated(0.28) * 220.0, damage, 8.0, Color(0.90, 0.46, 0.20), "X")
                projectile_requested.emit(global_position + dir.rotated(-0.28) * 36.0, dir.rotated(-0.28) * 220.0, damage, 8.0, Color(0.90, 0.46, 0.20), "X")
                _emit_boss_zone(dir, "boss_reksai_tunnel", 118.0, 2.6, 0.74, Color(1.0, 0.42, 0.18, 0.24), "burrow_charge_lane")
        "boss_belveth":
            if attack_cycle % 3 == 0:
                attack_timer = 2.60
                _cone_burst(dir, 11, 1.28, 244.0, 7.6, Color(0.92, 0.58, 1.0), "B")
                _radial_burst(12, 164.0, Color(0.78, 0.34, 1.0), "B")
                _emit_boss_zone(dir, "boss_belveth_swarm", 148.0, 2.7, 0.62, Color(0.82, 0.22, 1.0, 0.28), "royal_swarm_nest")
            else:
                attack_timer = 1.85
                _radial_burst(8, 205.0, Color(0.78, 0.34, 1.0), "B")
                for side in [-1, 1]:
                    var slash_dir := dir.rotated(float(side) * 0.55)
                    projectile_requested.emit(global_position + slash_dir * 36.0, slash_dir * 260.0, damage, 8.0, Color(0.92, 0.58, 1.0), "B")
                _emit_boss_zone(dir, "boss_belveth_swarm", 124.0, 2.2, 0.70, Color(0.78, 0.20, 1.0, 0.24), "royal_swarm_slash")
        _:
            attack_timer = randf_range(2.0, 3.2)
    if not boss:
        var attack_pressure := clampf(float(wave_level - 2) * 0.052, 0.0, 0.42)
        if elite:
            attack_pressure += 0.11
        attack_timer *= maxf(0.54, 1.0 - attack_pressure)
    if _boss_enraged():
        attack_timer *= 0.76
    if elite_trait == "frenzy":
        attack_timer *= 0.78
    elif elite_trait == "bulwark":
        attack_timer *= 1.08
        if bulwark_break_timer > 0.0:
            attack_timer *= 1.18
    elif elite_trait == "splitter":
        attack_timer *= 0.94
    elif elite_trait == "treasure":
        attack_timer *= 1.12

func _try_elite_trait_special(player: Node2D) -> void:
    if boss or not elite or elite_trait == "" or elite_trait_cooldown > 0.0:
        return
    var to_player := player.global_position - global_position
    var dist := to_player.length()
    if dist < 1.0:
        to_player = Vector2.DOWN
        dist = 1.0
    var dir := to_player.normalized()
    match elite_trait:
        "frenzy":
            if pounce_timer <= 0.0 and dist > 88.0 and dist < 540.0:
                dash_dir = dir.rotated(randf_range(-0.18, 0.18)).normalized()
                dash_timer = 0.58
                pounce_timer = randf_range(2.0, 3.0)
                elite_trait_cooldown = randf_range(1.10, 1.55)
                attack_timer = minf(attack_timer, 0.18)
                last_elite_trait_profile = "frenzy_rush_claw"
                _cone_burst(dir, 3, 0.44, 238.0, 6.4, Color(1.0, 0.24, 0.42), "F")
        "bulwark":
            if bulwark_guard <= 0 and bulwark_break_timer <= 0.0 and health > int(max_health * 0.35):
                bulwark_guard = 1
                elite_trait_cooldown = randf_range(4.2, 5.8)
                last_elite_trait_profile = "bulwark_reguard"
                _radial_burst(4, 104.0, Color(0.64, 0.88, 1.0), "U")
        "splitter":
            if not splitter_spawned and health <= int(max_health * 0.52):
                splitter_spawned = true
                elite_trait_cooldown = 6.0
                var spawn_kind := _splitter_spawn_kind()
                spawn_requested.emit(global_position, spawn_kind, 2)
                last_elite_trait_profile = "splitter_bloom_" + spawn_kind
                _radial_burst(5, 144.0, Color(0.78, 0.22, 1.0), "S")
        "treasure":
            if dist < 470.0:
                treasure_flee_timer = randf_range(1.05, 1.55)
                elite_trait_cooldown = randf_range(3.8, 5.2)
                attack_timer = maxf(attack_timer, 0.90)
                last_elite_trait_profile = "treasure_flee_decoy"
                _cone_burst(-dir, 3, 0.66, 118.0, 6.4, Color(1.0, 0.74, 0.22), "T")
        _:
            pass

func _try_special(_player: Node2D) -> void:
    match kind:
        "rift_crystal":
            if summon_timer <= 0.0:
                summon_timer = randf_range(7.0, 10.0) * (0.72 if elite else 1.0)
                spawn_requested.emit(global_position, "voidling", 3 if elite else 2)
                last_special_profile = "crystal_voidling_summon"
                _radial_burst(6 if elite else 4, 132.0, Color(0.34, 0.88, 1.0), "C")
        "boss_belveth":
            if summon_timer <= 0.0:
                summon_timer = randf_range(8.0, 11.0)
                spawn_requested.emit(global_position, "skitter", 5 if _boss_enraged() else 3)
                last_special_profile = "royal_swarm_summon"
        "boss_cho":
            if summon_timer <= 0.0 and _boss_enraged():
                summon_timer = randf_range(9.0, 12.0)
                spawn_requested.emit(global_position, "carapace", 1)
                last_special_profile = "devour_carapace_guard"
        _:
            pass

func _radial_burst(shots: int, velocity: float, color: Color, label: String) -> void:
    var offset := wobble * 0.35
    for i in range(shots):
        var angle := TAU * float(i) / float(shots) + offset
        var v := Vector2(cos(angle), sin(angle)) * velocity
        projectile_requested.emit(global_position + v.normalized() * (hit_radius + 6.0), v, damage, 7.5, color, label)

func _cone_burst(dir: Vector2, shots: int, spread: float, velocity: float, radius: float, color: Color, label: String) -> void:
    var count := maxi(1, shots)
    for i in range(count):
        var t := 0.0 if count == 1 else (float(i) / float(count - 1) - 0.5)
        var shot_dir := dir.rotated(t * spread)
        projectile_requested.emit(global_position + shot_dir * (hit_radius + radius + 4.0), shot_dir * velocity, damage, radius, color, label)

func _line_spikes(dir: Vector2, count: int, spacing: float, velocity: float, radius: float, color: Color, label: String) -> void:
    var side := Vector2(-dir.y, dir.x)
    for i in range(count):
        var step := float(i + 1)
        var side_offset := side * ((-1.0 if i % 2 == 0 else 1.0) * 18.0)
        var spawn_pos := global_position + dir * (hit_radius + step * spacing) + side_offset
        var shot_dir := dir.rotated((-0.10 if i % 2 == 0 else 0.10))
        projectile_requested.emit(spawn_pos, shot_dir * velocity, damage, radius, color, label)

func _emit_boss_zone(dir: Vector2, zone_kind: String, zone_radius: float, duration: float, tick_interval: float, color: Color, profile: String) -> void:
    if not boss:
        return
    var safe_dir := dir.normalized() if dir.length() > 0.01 else Vector2.DOWN
    var zone_pos := global_position + safe_dir * (hit_radius + zone_radius * 0.62)
    last_zone_profile = profile
    zone_requested.emit(zone_pos, zone_kind, zone_radius, damage, duration, tick_interval, color, "", maxi(1, damage))

func _boss_enraged() -> bool:
    return boss and health > 0 and health <= int(max_health * 0.45)

func _combat_role_for_kind(enemy_kind: String) -> String:
    match enemy_kind:
        "skitter", "burrower", "boss_reksai":
            return "diver"
        "spitter", "void_eye", "boss_velkoz":
            return "artillery"
        "carapace", "boss_cho":
            return "tank"
        "rift_crystal", "boss_belveth":
            return "summoner"
        _:
            return "swarm"

func _attack_profile_for_kind(enemy_kind: String) -> String:
    match enemy_kind:
        "spitter":
            return "acid_pick"
        "void_eye":
            return "eye_fan"
        "rift_crystal":
            return "crystal_orbit"
        "burrower":
            return "burrow_lance"
        "boss_cho":
            return "devour_rupture"
        "boss_velkoz":
            return "focus_laser"
        "boss_reksai":
            return "burrow_charge"
        "boss_belveth":
            return "royal_swarm"
        _:
            return "contact_pressure"

func _splitter_spawn_kind() -> String:
    match kind:
        "rift_crystal", "void_eye":
            return "spitter"
        "burrower", "skitter":
            return "voidling"
        "carapace":
            return "voidling"
        _:
            return "voidling"

func _check_contact(player: Node2D) -> void:
    var player_radius := 16.0
    var player_hit_radius = player.get("hit_radius")
    if player_hit_radius != null:
        player_radius = float(player_hit_radius)
    if global_position.distance_to(player.global_position) <= hit_radius + player_radius:
        if contact_timer <= 0.0:
            contact_timer = 0.78 if not boss else 0.56
            if player.has_method("take_damage"):
                var final_damage := damage
                if weakened_timer > 0.0:
                    final_damage = maxi(0, final_damage - 1)
                player.take_damage(final_damage, global_position)

func take_damage(amount: int, _source_pos := Vector2.ZERO, critical := false) -> void:
    var final_amount := amount
    if kind == "carapace":
        final_amount = maxi(1, amount - (2 if elite else 1))
    elif kind == "boss_cho" and _boss_enraged():
        final_amount = maxi(1, amount - 1)
    if elite_trait == "bulwark":
        if bulwark_break_timer > 0.0:
            final_amount += 1
        elif bulwark_guard > 0:
            final_amount = maxi(1, final_amount - 2)
            bulwark_guard -= 1
            if bulwark_guard <= 0:
                bulwark_break_timer = 2.60
                root_timer = maxf(root_timer, 0.16)
                last_elite_trait_profile = "bulwark_break"
                _radial_burst(5, 126.0, Color(0.64, 0.88, 1.0), "U")
        else:
            final_amount = maxi(1, final_amount - 1)
    health -= final_amount
    hurt_flash = 0.10
    damaged.emit(global_position, final_amount, critical)
    if health <= 0:
        remove_from_group("survivor_enemies")
        died.emit(self)
        queue_free()
    else:
        queue_redraw()

func apply_slow(duration: float, factor := 0.55) -> void:
    slow_timer = maxf(slow_timer, duration)
    slow_factor = minf(slow_factor, clampf(factor, 0.25, 1.0))

func apply_root(duration: float) -> void:
    root_timer = maxf(root_timer, duration)

func apply_poison(duration: float, amount: int) -> void:
    poison_timer = maxf(poison_timer, duration)
    poison_damage = maxi(poison_damage, amount)
    if poison_tick_timer <= 0.0:
        poison_tick_timer = 0.28

func apply_weaken(duration: float) -> void:
    weakened_timer = maxf(weakened_timer, duration)

func _tick_statuses(delta: float) -> void:
    if slow_timer > 0.0:
        slow_timer = maxf(0.0, slow_timer - delta)
        if slow_timer <= 0.0:
            slow_factor = 1.0
    root_timer = maxf(0.0, root_timer - delta)
    weakened_timer = maxf(0.0, weakened_timer - delta)
    if poison_timer > 0.0:
        poison_timer = maxf(0.0, poison_timer - delta)
        poison_tick_timer -= delta
        if poison_tick_timer <= 0.0:
            poison_tick_timer = 0.72
            take_damage(maxi(1, poison_damage), global_position, false)
        if poison_timer <= 0.0:
            poison_damage = 0

func _find_player() -> Node2D:
    var players := get_tree().get_nodes_in_group("survivor_player")
    if players.size() == 0:
        return null
    return players[0]

func _draw() -> void:
    var outline := Color(0.035, 0.026, 0.048)
    var color := Color.WHITE if hurt_flash > 0.0 else body_color
    _draw_ellipse(Vector2(0, hit_radius * 0.70), hit_radius * 1.08, hit_radius * 0.34, Color(0.0, 0.0, 0.02, 0.32))
    if boss:
        _draw_boss(outline, color)
        return
    var s := 20.0 + sin(wobble * 6.0) * 1.5 if elite else 16.0 + sin(wobble * 6.0) * 1.3
    if attack_timer < 0.48 and (kind == "spitter" or kind == "void_eye" or kind == "rift_crystal" or kind == "burrower"):
        _draw_attack_warning(s + 13.0, Color(1.0, 0.18, 0.44, 0.50))
    match kind:
        "spitter":
            _draw_spitter(outline, color, s)
        "burrower":
            _draw_burrower(outline, color, s)
        "carapace":
            _draw_carapace(outline, color, s)
        "void_eye":
            _draw_eye(outline, color, s)
        "rift_crystal":
            _draw_crystal(outline, color, s)
        _:
            _draw_voidling(outline, color, s)
    if elite:
        draw_arc(Vector2.ZERO, s + 10.0, 0.0, TAU, 32, Color(0.92, 0.54, 1.0, 0.60), 3.0)
    if poison_timer > 0.0:
        draw_arc(Vector2.ZERO, s + 7.0, 0.0, TAU, 28, Color(0.52, 1.0, 0.22, 0.68), 2.5)
    if root_timer > 0.0:
        draw_arc(Vector2.ZERO, s + 12.0, 0.0, TAU, 24, Color(1.0, 0.38, 0.74, 0.72), 3.5)
    elif slow_timer > 0.0:
        draw_arc(Vector2.ZERO, s + 11.0, 0.0, TAU, 24, Color(0.56, 0.82, 1.0, 0.62), 2.5)
    if weakened_timer > 0.0:
        draw_line(Vector2(-s * 0.70, -s * 0.92), Vector2(s * 0.70, s * 0.92), Color(0.92, 0.84, 0.22, 0.78), 3.0)
    if health < max_health or elite:
        _draw_health_bar(42 if elite else 34, -30)

func _draw_voidling(outline: Color, color: Color, s: float) -> void:
    _draw_lit_sphere(Vector2.ZERO, s, color, outline)
    draw_circle(Vector2(-6, -4), 3.0, Color(1.0, 0.70, 1.0))
    draw_circle(Vector2(7, -4), 3.0, Color(1.0, 0.70, 1.0))
    if kind == "skitter":
        draw_line(Vector2(-18, 8), Vector2(-30, 16), outline, 4.0)
        draw_line(Vector2(18, 8), Vector2(30, 16), outline, 4.0)

func _draw_spitter(outline: Color, color: Color, s: float) -> void:
    _draw_lit_sphere(Vector2.ZERO, s, color, outline)
    draw_circle(Vector2(0, -2), 6.0, Color(0.16, 0.05, 0.18))
    draw_circle(Vector2(0, -2), 3.0, Color(0.72, 1.0, 0.40))

func _draw_burrower(outline: Color, color: Color, s: float) -> void:
    draw_polygon([Vector2(0, -s - 4.0), Vector2(s + 12.0, 0), Vector2(0, s + 4.0), Vector2(-s - 12.0, 0)], [outline])
    draw_polygon([Vector2(0, -s), Vector2(s + 6.0, 0), Vector2(0, s), Vector2(-s - 6.0, 0)], [color])
    draw_rect(Rect2(-8, -5, 16, 10), Color(0.12, 0.05, 0.04))

func _draw_carapace(outline: Color, color: Color, s: float) -> void:
    _draw_lit_sphere(Vector2.ZERO, s + 2.0, color, outline)
    draw_arc(Vector2.ZERO, s - 2.0, -0.7, PI + 0.7, 18, Color(0.82, 0.64, 1.0, 0.55), 4.0)

func _draw_eye(outline: Color, color: Color, s: float) -> void:
    _draw_lit_sphere(Vector2.ZERO, s, color, outline)
    draw_circle(Vector2.ZERO, 8.0, Color(1.0, 0.78, 1.0))
    draw_circle(Vector2.ZERO, 3.5, Color(0.14, 0.02, 0.18))

func _draw_crystal(outline: Color, color: Color, s: float) -> void:
    draw_polygon([Vector2(0, -s - 8.0), Vector2(s, -4), Vector2(s * 0.65, s + 8.0), Vector2(-s * 0.65, s + 8.0), Vector2(-s, -4)], [outline])
    draw_polygon([Vector2(0, -s - 2.0), Vector2(s - 4.0, -2), Vector2(s * 0.50, s + 2.0), Vector2(-s * 0.50, s + 2.0), Vector2(-s + 4.0, -2)], [color])
    draw_line(Vector2(0, -s), Vector2(0, s), Color(0.82, 0.94, 1.0, 0.45), 3.0)

func _draw_boss(outline: Color, color: Color) -> void:
    if attack_timer < 0.62:
        _draw_attack_warning(74.0 + sin(wobble * 8.0) * 4.0, Color(1.0, 0.14, 0.36, 0.62))
    match kind:
        "boss_velkoz":
            _draw_lit_sphere(Vector2.ZERO, 45.0, color, outline)
            draw_circle(Vector2.ZERO, 18.0, Color(1.0, 0.82, 1.0))
            draw_circle(Vector2.ZERO, 7.0, Color(0.14, 0.02, 0.16))
            for i in range(5):
                var angle := wobble * 1.2 + TAU * float(i) / 5.0
                draw_line(Vector2.ZERO, Vector2(cos(angle), sin(angle)) * 66.0, color.lightened(0.25), 5.0)
        "boss_reksai":
            draw_polygon([Vector2(0, -62), Vector2(58, -10), Vector2(42, 42), Vector2(0, 58), Vector2(-42, 42), Vector2(-58, -10)], [outline])
            draw_polygon([Vector2(0, -52), Vector2(48, -8), Vector2(35, 34), Vector2(0, 48), Vector2(-35, 34), Vector2(-48, -8)], [color])
            draw_polygon([Vector2(-10, -42), Vector2(30, -9), Vector2(14, -1), Vector2(-22, -30)], [color.lightened(0.25)])
            draw_rect(Rect2(-18, -16, 36, 12), Color(0.12, 0.05, 0.04))
        "boss_belveth":
            draw_polygon([Vector2(0, -66), Vector2(54, -20), Vector2(68, 24), Vector2(20, 58), Vector2(-20, 58), Vector2(-68, 24), Vector2(-54, -20)], [outline])
            draw_polygon([Vector2(0, -56), Vector2(44, -16), Vector2(56, 20), Vector2(16, 48), Vector2(-16, 48), Vector2(-56, 20), Vector2(-44, -16)], [color])
            draw_polygon([Vector2(0, -48), Vector2(30, -15), Vector2(18, 14), Vector2(-4, 4)], [color.lightened(0.22)])
            draw_circle(Vector2(0, -8), 11.0, Color(1.0, 0.72, 1.0))
        _:
            _draw_lit_sphere(Vector2.ZERO, 50.0, color, outline)
            draw_rect(Rect2(-34, -62, 68, 18), outline)
            draw_rect(Rect2(-25, -56, 50, 11), Color(0.70, 0.40, 1.0))
            draw_circle(Vector2(-18, -12), 5.0, Color(1.0, 0.68, 1.0))
            draw_circle(Vector2(18, -12), 5.0, Color(1.0, 0.68, 1.0))
            draw_rect(Rect2(-24, 20, 48, 9), Color(0.16, 0.04, 0.18))
    _draw_health_bar(96, -76)

func _draw_health_bar(width: int, y: int) -> void:
    draw_rect(Rect2(-width / 2, y, width, 5), Color(0.08, 0.04, 0.10))
    draw_rect(Rect2(-width / 2, y, width * float(maxi(0, health)) / float(max_health), 5), Color(0.95, 0.28, 0.86))

func _draw_lit_sphere(center: Vector2, radius: float, color: Color, outline: Color) -> void:
    draw_circle(center, radius + 3.0, outline)
    draw_circle(center + Vector2(2.0, 3.0), radius, color.darkened(0.18))
    draw_circle(center, radius, color)
    draw_circle(center + Vector2(-radius * 0.32, -radius * 0.36), radius * 0.30, color.lightened(0.34))
    draw_arc(center, radius * 0.82, -2.65, -0.55, 18, color.lightened(0.22), 2.0)

func _draw_attack_warning(radius: float, color: Color) -> void:
    var t := 1.0 - clampf(attack_timer / 0.62, 0.0, 1.0)
    var col := color
    col.a *= 0.45 + t * 0.55
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 42, col, 3.0 + t * 2.0)
    draw_arc(Vector2.ZERO, radius * 0.72, 0.0, TAU, 36, Color(col.r, col.g, col.b, col.a * 0.45), 2.0)
    for i in range(6):
        var angle := TAU * float(i) / 6.0 + wobble * 1.8
        draw_line(Vector2(cos(angle), sin(angle)) * radius * 0.70, Vector2(cos(angle), sin(angle)) * radius, col, 2.0)

func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
    var points := []
    for i in range(20):
        var a := TAU * float(i) / 20.0
        points.append(center + Vector2(cos(a) * rx, sin(a) * ry))
    draw_polygon(points, [color])
