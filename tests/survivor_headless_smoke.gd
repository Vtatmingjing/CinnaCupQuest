extends SceneTree

const MainScene := preload("res://scenes/Main.tscn")
const EXPECTED_MAX_ENEMIES := 60

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    seed(20260703)
    var main = MainScene.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame

    if not main.has_method("_start_new_run"):
        push_error("Main scene does not expose survivor start flow.")
        quit(1)
        return

    main._start_new_run()
    await process_frame
    main._choose_fate(0)
    await process_frame

    var player = main.get("player")
    if player == null:
        push_error("Survivor smoke test could not find player.")
        quit(1)
        return
    player.set("max_health", 999)
    player.set("health", 999)
    player.set("shield", 999)
    player.set("invincible_timer", 999.0)
    main.set("spawn_timer", 999.0)
    main.set("elite_timer", 999.0)

    var center: Vector2 = player.global_position
    var spawn_rift_was_visible := false
    var enemy_kinds := ["voidling", "skitter", "spitter", "burrower", "carapace", "void_eye", "rift_crystal"]
    for i in range(32):
        var angle := TAU * float(i) / 32.0
        var ring := 180.0 + float(i % 6) * 38.0
        var pos := center + Vector2(cos(angle), sin(angle)) * ring
        main._spawn_enemy(pos, str(enemy_kinds[i % enemy_kinds.size()]), i % 17 == 0)
    await process_frame
    var visual_after_initial_spawn = main.get("visual3d")
    if visual_after_initial_spawn != null:
        spawn_rift_was_visible = (
            visual_after_initial_spawn.find_child("EnemySpawnRiftSignature", true, false) != null
            and visual_after_initial_spawn.find_child("EnemySpawnRiftPortalDecal", true, false) != null
        )

    var forced_crystal: Node = null
    var forced_burrower: Node = null
    for enemy in get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        if str(enemy.get("kind")) == "rift_crystal" and forced_crystal == null:
            forced_crystal = enemy
            enemy.set("summon_timer", 0.85)
        elif str(enemy.get("kind")) == "burrower" and forced_burrower == null:
            forced_burrower = enemy
            enemy.set("attack_timer", 0.05)
        if forced_crystal != null and forced_burrower != null:
            break
    forced_crystal = main._spawn_enemy(center + Vector2(520, -260), "rift_crystal", false, true)
    if forced_crystal != null:
        forced_crystal.set("max_health", 999)
        forced_crystal.set("health", 999)
        forced_crystal.set("summon_timer", 0.85)
    forced_burrower = main._spawn_enemy(center + Vector2(-520, 240), "burrower", false, true)
    if forced_burrower != null:
        forced_burrower.set("max_health", 999)
        forced_burrower.set("health", 999)
        forced_burrower.set("attack_timer", 0.05)
    var enemy_count_before_specials := get_nodes_in_group("survivor_enemies").size()
    main.set("spawn_timer", 999.0)
    main.set("elite_timer", 999.0)
    var forced_crystal_id := forced_crystal.get_instance_id() if forced_crystal != null else 0
    var forced_burrower_id := forced_burrower.get_instance_id() if forced_burrower != null else 0
    var summon_aura_was_visible := false
    var charge_lane_was_visible := false

    for frame in range(4):
        main._run_survivor_loop(0.05)
        await process_frame
        var visual_during_specials = main.get("visual3d")
        if visual_during_specials != null:
            if forced_crystal_id != 0 and visual_during_specials.get("enemy_models").has(forced_crystal_id):
                var crystal_model = visual_during_specials.get("enemy_models")[forced_crystal_id]
                var summon_aura = crystal_model.get_node_or_null("SummonAura")
                summon_aura_was_visible = summon_aura_was_visible or (summon_aura != null and bool(summon_aura.visible))
            if forced_burrower_id != 0 and visual_during_specials.get("enemy_models").has(forced_burrower_id):
                var burrower_model = visual_during_specials.get("enemy_models")[forced_burrower_id]
                var charge_lane = burrower_model.get_node_or_null("ChargeLane")
                charge_lane_was_visible = charge_lane_was_visible or (charge_lane != null and bool(charge_lane.visible))
    var forced_summon_added := false
    if forced_crystal != null and is_instance_valid(forced_crystal):
        for attempt in range(3):
            var count_before_attempt := get_nodes_in_group("survivor_enemies").size()
            forced_crystal.set("summon_timer", 0.0)
            forced_crystal.call("_try_special", player)
            if get_nodes_in_group("survivor_enemies").size() > count_before_attempt:
                forced_summon_added = true
                break
            main._run_survivor_loop(0.05)
            await process_frame
            if get_nodes_in_group("survivor_enemies").size() > enemy_count_before_specials:
                forced_summon_added = true
                break
    for frame in range(8):
        main._run_survivor_loop(0.05)
        await process_frame
        var visual_during_summon = main.get("visual3d")
        if visual_during_summon != null and forced_crystal_id != 0 and visual_during_summon.get("enemy_models").has(forced_crystal_id):
            var crystal_model = visual_during_summon.get("enemy_models")[forced_crystal_id]
            var summon_aura = crystal_model.get_node_or_null("SummonAura")
            summon_aura_was_visible = summon_aura_was_visible or (summon_aura != null and bool(summon_aura.visible))
    forced_summon_added = forced_summon_added or get_nodes_in_group("survivor_enemies").size() > enemy_count_before_specials
    var smoke_boss = main._spawn_enemy(center + Vector2(360, 0), "boss_velkoz", true, true)
    if smoke_boss != null:
        smoke_boss.set("attack_timer", 0.38)
    var boss_cast_was_visible := false
    for frame in range(4):
        main._run_survivor_loop(0.05)
        await process_frame
        var visual_during_boss_cast = main.get("visual3d")
        if visual_during_boss_cast != null:
            var cast_sigils = visual_during_boss_cast.find_child("BossCastSigils", true, false)
            var cast_focus = visual_during_boss_cast.find_child("BossCastFocus", true, false)
            var cast_decal = visual_during_boss_cast.find_child("BossCastVfxDecal", true, false)
            var focus_decal = visual_during_boss_cast.find_child("BossCastFocusVfxDecal", true, false)
            var warning_frame = visual_during_boss_cast.find_child("BossCastWarningFrame", true, false)
            var cast_pattern = visual_during_boss_cast.find_child("BossCastPatternVelkoz", true, false)
            var cast_pattern_signature = visual_during_boss_cast.find_child("BossCastVelkozLaserFan", true, false)
            var cast_pattern_detail = visual_during_boss_cast.find_child("BossCastVelkozEyeCore", true, false)
            var cast_intent = visual_during_boss_cast.find_child("BossCastIntentProfile", true, false)
            var cast_intent_detail = visual_during_boss_cast.find_child("BossCastIntentVelkozLaser", true, false)
            var domain_profile = visual_during_boss_cast.find_child("BossDomainProfileRig", true, false)
            var domain_pattern = visual_during_boss_cast.find_child("BossDomainVelkozFocus", true, false)
            var domain_detail = visual_during_boss_cast.find_child("BossDomainVelkozFocusFan", true, false)
            var lockdown = visual_during_boss_cast.find_child("BossArenaLockdownRig", true, false)
            var lockdown_anchor = visual_during_boss_cast.find_child("BossArenaLockdownAnchor_0", true, false)
            var lockdown_detail = visual_during_boss_cast.find_child("BossArenaLockdownVelkozEye", true, false)
            boss_cast_was_visible = boss_cast_was_visible or (
                cast_sigils != null and bool(cast_sigils.visible)
                and cast_focus != null and bool(cast_focus.visible)
                and cast_decal != null and bool(cast_decal.visible)
                and focus_decal != null and bool(focus_decal.visible)
                and warning_frame != null and bool(warning_frame.visible)
                and cast_pattern != null and bool(cast_pattern.visible)
                and cast_pattern_signature != null
                and cast_pattern_detail != null
                and cast_intent != null and bool(cast_intent.visible)
                and cast_intent_detail != null
                and domain_profile != null and bool(domain_profile.visible)
                and domain_pattern != null and bool(domain_pattern.visible)
                and domain_detail != null
                and lockdown != null and bool(lockdown.visible)
                and lockdown_anchor != null
                and lockdown_detail != null and bool(lockdown_detail.visible)
            )

    for i in range(34):
        var angle := TAU * float(i) / 34.0
        var pos := center + Vector2(cos(angle), sin(angle)) * (74.0 + float(i % 5) * 18.0)
        var kind := "xp"
        var amount := 2 + i % 7
        var color: Color = main._xp_color(amount)
        if i % 11 == 0:
            kind = "gold"
            amount = 12
            color = Color(1.0, 0.76, 0.20)
        main._spawn_pickup(pos, kind, amount, color)

    for i in range(48):
        var angle := TAU * float(i) / 48.0
        var dir := Vector2(cos(angle), sin(angle))
        var from_player := i % 4 != 0
        var color := Color(1.0, 0.42, 0.18) if from_player else Color(1.0, 0.10, 0.38)
        var label := "fishbones" if from_player else "void_spit"
        if not from_player:
            var enemy_labels := ["A", "V", "X", "B"]
            label = str(enemy_labels[int(i / 4) % enemy_labels.size()])
        main._spawn_projectile(center + dir * 60.0, dir * (260.0 if from_player else 180.0), 3, 8.0, color, label, 1, 1.2, from_player)

    main._spawn_hit_spark(center + Vector2(36, -18), "fishbones", 12, 72.0, Color(1.0, 0.62, 0.20))
    var hit_spark_was_visible := false
    for frame in range(142):
        main._run_survivor_loop(0.05)
        await process_frame
        var visual_during_hits = main.get("visual3d")
        if visual_during_hits != null:
            hit_spark_was_visible = hit_spark_was_visible or (
                visual_during_hits.find_child("HitSparkImpactSignature", true, false) != null
                and visual_during_hits.find_child("HitSparkVfxDecal", true, false) != null
                and visual_during_hits.find_child("HitSparkSourceProfile", true, false) != null
                and visual_during_hits.find_child("HitSparkResolutionProfile", true, false) != null
                and _has_visible_hit_spark_severity(visual_during_hits)
            )

    main._spawn_enemy_death_burst(center + Vector2(96, -54), "boss_velkoz", true, true, 176.0, Color(0.96, 0.38, 1.0, 0.52))
    var premium_death_reward_was_visible := false
    for frame in range(5):
        main._run_survivor_loop(0.05)
        await process_frame
        var visual_during_death = main.get("visual3d")
        if visual_during_death != null:
            premium_death_reward_was_visible = premium_death_reward_was_visible or (
                visual_during_death.find_child("EnemyDeathPremiumRewardRelic", true, false) != null
                and visual_during_death.find_child("EnemyDeathRewardRelicCore", true, false) != null
                and visual_during_death.find_child("EnemyDeathRewardEyeRelic", true, false) != null
            )

    main._on_player_zone_requested(center + Vector2(128, 76), "viktor_gravity", 132.0, 4, 8.0, 0.54, Color(0.58, 0.82, 1.0, 0.26), "slow", 3)
    main._on_player_zone_requested(center + Vector2(-138, 82), "asol_singularity", 148.0, 5, 8.0, 0.58, Color(0.64, 0.34, 1.0, 0.25), "slow", 3)
    main._on_player_zone_requested(center + Vector2(0, -144), "morde_realm", 138.0, 4, 8.0, 0.62, Color(0.40, 1.0, 0.45, 0.22), "weaken", 2)
    main._on_player_zone_requested(center + Vector2(176, -118), "teemo_mushroom", 96.0, 3, 12.0, 0.58, Color(0.52, 1.0, 0.22, 0.24), "poison", 2)
    _clear_enemy_projectiles()
    await process_frame
    var intent_labels := ["A", "V", "X", "B"]
    for i in range(intent_labels.size()):
        var angle := TAU * float(i) / float(intent_labels.size())
        var dir := Vector2(cos(angle), sin(angle))
        main._spawn_projectile(center + dir * 88.0, dir * 160.0, 3, 10.0, Color(1.0, 0.10, 0.38), str(intent_labels[i]), 1, 4.0, false)
    main._spawn_pulse_visual(center + Vector2(-92, -96), 148.0, Color(0.72, 0.95, 1.0, 0.26))
    for frame in range(5):
        main._run_survivor_loop(0.05)
        await process_frame

    var enemy_count := get_nodes_in_group("survivor_enemies").size()
    var projectile_count := get_nodes_in_group("survivor_projectiles").size()
    var pickup_count := get_nodes_in_group("survivor_pickups").size()
    var visual3d = main.get("visual3d")
    if visual3d == null:
        push_error("3D survivor view was not created.")
        quit(1)
        return
    if visual3d.find_child("ArenaPremiumSetDressing", true, false) == null:
        push_error("Smoke test expected premium arena set dressing.")
        quit(1)
        return
    if visual3d.find_child("ArenaObjectiveShrineSet", true, false) == null:
        push_error("Smoke test expected objective shrine arena set dressing.")
        quit(1)
        return
    if visual3d.find_child("ArenaCenterVfxDecal", true, false) == null:
        push_error("Smoke test expected atlas-backed arena center VFX decal.")
        quit(1)
        return
    if enemy_count <= 0:
        push_error("Smoke test expected active survivor enemies.")
        quit(1)
        return
    if forced_crystal == null or not forced_summon_added:
        push_error("Smoke test expected rift crystal summon behavior to add enemies.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("ChampionIdentityProjection", true, false) == null:
        push_error("Smoke test expected champion identity projection node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("ChampionFanSignature", true, false) == null:
        push_error("Smoke test expected champion fan signature node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("ChampionPremiumBodyRig", true, false) == null:
        push_error("Smoke test expected champion premium body rig node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("ChampionCombatStanceRig", true, false) == null:
        push_error("Smoke test expected champion combat stance rig node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("ChampionSignatureCastRig", true, false) == null:
        push_error("Smoke test expected champion signature cast rig node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("ChampionSignatureCastIdentity", true, false) == null:
        push_error("Smoke test expected champion signature cast identity node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("ChampionSignatureCastRoleTelegraph", true, false) == null:
        push_error("Smoke test expected champion signature cast role telegraph node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("PlayerProjectileRoleProfile", true, false) == null:
        push_error("Smoke test expected player projectile role profile node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("PlayerProjectileImpactIntentProfile", true, false) == null:
        push_error("Smoke test expected player projectile impact intent profile node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("PlayerProjectileSpellTrailProfile", true, false) == null:
        push_error("Smoke test expected player projectile spell trail profile node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("PlayerProjectilePremiumFxRig", true, false) == null:
        push_error("Smoke test expected player projectile premium FX rig node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("EliteTraitMarker", true, false) == null:
        push_error("Smoke test expected elite trait marker node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("EliteTraitTelegraphRig", true, false) == null:
        push_error("Smoke test expected elite trait telegraph node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("EliteTraitIntentProfile", true, false) == null:
        push_error("Smoke test expected elite trait intent profile node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("EliteTraitBehaviorStateRig", true, false) == null:
        push_error("Smoke test expected elite trait behavior state rig node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("EnemySpeciesRoleBanner", true, false) == null:
        push_error("Smoke test expected enemy species role banner node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("EnemyWeakpointCore", true, false) == null:
        push_error("Smoke test expected enemy weakpoint core node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("EnemyCombatIntentProfile", true, false) == null:
        push_error("Smoke test expected enemy combat intent profile node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("VoidCreaturePremiumBodyRig", true, false) == null:
        push_error("Smoke test expected void creature premium body rig node.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("EnemyReadabilityPlate", true, false) == null and visual3d.find_child("LiteEnemyReadabilityPlate", true, false) == null:
        push_error("Smoke test expected enemy readability floor plates or lite readability plates.")
        quit(1)
        return
    if visual3d != null and visual3d.find_child("EnemyFootprintScaleRig", true, false) == null:
        push_error("Smoke test expected enemy footprint scale readability rigs.")
        quit(1)
        return
    if not spawn_rift_was_visible:
        push_error("Smoke test expected visible enemy spawn rift signature and portal decal.")
        quit(1)
        return
    if not summon_aura_was_visible or not charge_lane_was_visible:
        push_error("Smoke test expected visible 3D summon and charge telegraphs.")
        quit(1)
        return
    var boss_pressure = visual3d.find_child("BossPressureRig", true, false)
    if boss_pressure == null or not bool(boss_pressure.visible):
        push_error("Smoke test expected visible boss pressure rig.")
        quit(1)
        return
    if visual3d.find_child("BossPhaseStateRig", true, false) == null:
        push_error("Smoke test expected boss phase state rig node.")
        quit(1)
        return
    if visual3d.find_child("BossHealthSigils", true, false) == null:
        push_error("Smoke test expected boss health sigils.")
        quit(1)
        return
    if not boss_cast_was_visible:
        push_error("Smoke test expected visible boss cast sigils, countdown frame, focus, unique pattern, intent profile, domain profile, and arena lockdown.")
        quit(1)
        return
    if visual3d.find_child("EnemyProjectileLane", true, false) == null:
        push_error("Smoke test expected enemy projectile floor lanes.")
        quit(1)
        return
    if visual3d.find_child("EnemyProjectileHeadingArrow", true, false) == null:
        push_error("Smoke test expected enemy projectile heading arrows.")
        quit(1)
        return
    if visual3d.find_child("EnemyProjectileThreatBadge", true, false) == null:
        push_error("Smoke test expected enemy projectile threat badges.")
        quit(1)
        return
    if visual3d.find_child("EnemyProjectileIntentProfile", true, false) == null:
        push_error("Smoke test expected enemy projectile intent profiles.")
        quit(1)
        return
    if visual3d.find_child("EnemyProjectileThreatShapeCode", true, false) == null:
        push_error("Smoke test expected enemy projectile threat shape code silhouettes.")
        quit(1)
        return
    if visual3d.find_child("EnemyProjectileHazardChevron", true, false) == null:
        push_error("Smoke test expected enemy projectile hazard chevrons.")
        quit(1)
        return
    if visual3d.find_child("EnemyProjectileDangerBackplate", true, false) == null:
        push_error("Smoke test expected red/black enemy projectile danger backplates.")
        quit(1)
        return
    if visual3d.find_child("EnemyProjectileDangerNeedle", true, false) == null:
        push_error("Smoke test expected enemy projectile danger needles.")
        quit(1)
        return
    if visual3d.find_child("PickupRewardBeacon", true, false) == null:
        push_error("Smoke test expected high-value pickup reward beacons.")
        quit(1)
        return
    if visual3d.find_child("PickupPremiumIconPlate", true, false) == null:
        push_error("Smoke test expected atlas-backed pickup icon plates.")
        quit(1)
        return
    if visual3d.find_child("PickupTreasureCrest", true, false) == null:
        push_error("Smoke test expected high-value pickup treasure crests.")
        quit(1)
        return
    if visual3d.find_child("ZoneRunePlate", true, false) == null:
        push_error("Smoke test expected textured zone rune plates.")
        quit(1)
        return
    if visual3d.find_child("ZoneProgressSigils", true, false) == null:
        push_error("Smoke test expected zone duration sigils.")
        quit(1)
        return
    if visual3d.find_child("ZonePulseCore", true, false) == null:
        push_error("Smoke test expected zone pulse cores.")
        quit(1)
        return
    if visual3d.find_child("ZoneSourceProfile", true, false) == null:
        push_error("Smoke test expected zone source profile nodes.")
        quit(1)
        return
    if visual3d.find_child("ZoneResolutionProfile", true, false) == null:
        push_error("Smoke test expected zone resolution profile nodes.")
        quit(1)
        return
    if visual3d.find_child("ZoneArmedSigils", true, false) == null:
        push_error("Smoke test expected Teemo armed mushroom sigils.")
        quit(1)
        return
    if visual3d.find_child("PulseVfxDecal", true, false) == null:
        push_error("Smoke test expected atlas-backed pulse VFX decals.")
        quit(1)
        return
    if visual3d.find_child("PulseImpactSignature", true, false) == null:
        push_error("Smoke test expected pulse impact signatures.")
        quit(1)
        return
    if not hit_spark_was_visible:
        push_error("Smoke test expected visible hit spark signatures during projectile impacts.")
        quit(1)
        return
    if not premium_death_reward_was_visible:
        push_error("Smoke test expected visible premium death reward relic for boss/elite kills.")
        quit(1)
        return

    for i in range(48):
        var angle := TAU * float(i) / 48.0
        main._spawn_enemy(center + Vector2(cos(angle), sin(angle)) * 420.0, "voidling", false)
    await process_frame
    var capped_enemy_count := get_nodes_in_group("survivor_enemies").size()
    if capped_enemy_count > EXPECTED_MAX_ENEMIES:
        push_error("Smoke test expected enemy cap <= %d, got %d." % [EXPECTED_MAX_ENEMIES, capped_enemy_count])
        quit(1)
        return

    print("SURVIVOR_SMOKE_OK enemies=%d projectiles=%d pickups=%d" % [capped_enemy_count, projectile_count, pickup_count])
    quit(0)

func _has_visible_hit_spark_severity(node: Node) -> bool:
    if node is Node3D and str(node.name) == "HitSparkSeverityRig":
        var rig := node as Node3D
        var meter := rig.get_node_or_null("HitSparkSeverityMeter") as MeshInstance3D
        if (
            bool(rig.visible)
            and float(rig.get_meta("severity", 0.0)) >= 0.60
            and meter != null
            and bool(meter.visible)
            and meter.scale.x >= 0.60
        ):
            return true
    for child in node.get_children():
        if _has_visible_hit_spark_severity(child):
            return true
    return false

func _clear_enemy_projectiles() -> void:
    for projectile in get_nodes_in_group("survivor_projectiles"):
        if not is_instance_valid(projectile):
            continue
        if not bool(projectile.get("from_player")):
            projectile.remove_from_group("survivor_projectiles")
            projectile.queue_free()
