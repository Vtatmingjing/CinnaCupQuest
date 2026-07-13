extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const EnemyScript := preload("res://scripts/survivor_enemy.gd")

const CASES := [
    {"kind": "boss_cho", "signature": "SigCho", "domain": "BossDomainChoRupture", "pattern": "BossCastPatternCho"},
    {"kind": "boss_velkoz", "signature": "SigVelkoz", "domain": "BossDomainVelkozFocus", "pattern": "BossCastPatternVelkoz"},
    {"kind": "boss_reksai", "signature": "SigReksai", "domain": "BossDomainReksaiBurrow", "pattern": "BossCastPatternReksai"},
    {"kind": "boss_belveth", "signature": "SigBelveth", "domain": "BossDomainBelvethSwarm", "pattern": "BossCastPatternBelveth"}
]

const STATE_CASES := [
    {"state": "steady", "attack_timer": 0.68, "health_ratio": 1.00, "cast_visible": false},
    {"state": "pressuring", "attack_timer": 0.68, "health_ratio": 0.50, "cast_visible": false},
    {"state": "enraged", "attack_timer": 0.68, "health_ratio": 0.28, "cast_visible": false},
    {"state": "windup", "attack_timer": 0.42, "health_ratio": 1.00, "cast_visible": true},
    {"state": "casting", "attack_timer": 0.08, "health_ratio": 1.00, "cast_visible": true}
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    var checked := 0
    for case in CASES:
        _clear_bosses()
        var kind := str(case["kind"])
        var enemy = EnemyScript.new()
        enemy.setup(kind, 12, true)
        enemy.position = Vector2.ZERO
        root.add_child(enemy)
        await process_frame
        for state_case in STATE_CASES:
            var ok := _expect_cinematic_state(view, enemy, case, state_case)
            if not ok:
                return
            checked += 1
        enemy.remove_from_group("survivor_enemies")
        enemy.queue_free()
        await process_frame

    print("SURVIVOR_BOSS_CINEMATIC_STATE_MATRIX_OK bosses=%d states=%d" % [CASES.size(), checked])
    quit(0)

func _expect_cinematic_state(view: Node, enemy: Node, case: Dictionary, state_case: Dictionary) -> bool:
    var max_health := maxf(1.0, float(enemy.get("max_health")))
    var expected_state := str(state_case["state"])
    enemy.set("attack_timer", float(state_case["attack_timer"]))
    enemy.set("health", max_health * float(state_case["health_ratio"]))
    view.call("_sync_boss_pressure")
    view.call("_sync_boss_pressure")

    var rig := view.find_child("BossPressureRig", true, false) as Node3D
    if rig == null or not bool(rig.visible):
        push_error("Boss cinematic matrix expected visible BossPressureRig for %s/%s." % [case["kind"], expected_state])
        quit(1)
        return false
    if str(rig.get_meta("cinematic_state", "")) != expected_state:
        push_error("Boss cinematic matrix expected root state %s for %s, got %s." % [expected_state, case["kind"], str(rig.get_meta("cinematic_state", ""))])
        quit(1)
        return false
    var intensity := float(rig.get_meta("cinematic_intensity", -1.0))
    if expected_state == "steady" and intensity != 0.0:
        push_error("Boss cinematic matrix expected zero steady intensity for %s, got %.3f." % [case["kind"], intensity])
        quit(1)
        return false
    if expected_state != "steady" and intensity <= 0.0:
        push_error("Boss cinematic matrix expected active intensity for %s/%s." % [case["kind"], expected_state])
        quit(1)
        return false

    var focus := view.find_child("BossFocus", true, false) as Node3D
    if focus == null or str(focus.get_meta("cinematic_state", "")) != expected_state:
        push_error("Boss cinematic matrix expected focus state %s for %s." % [expected_state, case["kind"]])
        quit(1)
        return false
    var signature := focus.get_node_or_null(str(case["signature"])) as Node3D
    if signature == null or not bool(signature.visible):
        push_error("Boss cinematic matrix expected active signature %s for %s." % [case["signature"], case["kind"]])
        quit(1)
        return false
    if str(signature.get_meta("cinematic_state", "")) != expected_state:
        push_error("Boss cinematic matrix expected signature state %s for %s." % [expected_state, case["kind"]])
        quit(1)
        return false

    var domain := view.find_child(str(case["domain"]), true, false) as Node3D
    if domain == null or not bool(domain.visible):
        push_error("Boss cinematic matrix expected active domain %s for %s." % [case["domain"], case["kind"]])
        quit(1)
        return false
    if str(domain.get_meta("cinematic_state", "")) != expected_state:
        push_error("Boss cinematic matrix expected domain state %s for %s." % [expected_state, case["kind"]])
        quit(1)
        return false
    var meter := domain.get_node_or_null("BossDomainThreatMeter") as Node3D
    if expected_state != "steady" and (meter == null or not bool(meter.visible)):
        push_error("Boss cinematic matrix expected threat meter for %s/%s." % [case["kind"], expected_state])
        quit(1)
        return false

    var cast_focus := view.find_child("BossCastFocus", true, false) as Node3D
    var cast_should_show := bool(state_case["cast_visible"])
    if cast_focus == null or bool(cast_focus.visible) != cast_should_show:
        push_error("Boss cinematic matrix expected cast focus visible=%s for %s/%s." % [str(cast_should_show), case["kind"], expected_state])
        quit(1)
        return false
    if cast_focus != null and str(cast_focus.get_meta("cinematic_state", "")) != expected_state:
        push_error("Boss cinematic matrix expected cast focus state %s for %s." % [expected_state, case["kind"]])
        quit(1)
        return false

    var pattern_rig := view.find_child("BossCastPatternRig", true, false) as Node3D
    if pattern_rig == null or bool(pattern_rig.visible) != cast_should_show:
        push_error("Boss cinematic matrix expected pattern rig visible=%s for %s/%s." % [str(cast_should_show), case["kind"], expected_state])
        quit(1)
        return false
    if cast_should_show:
        var pattern := pattern_rig.get_node_or_null(str(case["pattern"])) as Node3D
        if pattern == null or not bool(pattern.visible):
            push_error("Boss cinematic matrix expected visible cast pattern %s for %s/%s." % [case["pattern"], case["kind"], expected_state])
            quit(1)
            return false
        if str(pattern.get_meta("cinematic_state", "")) != expected_state:
            push_error("Boss cinematic matrix expected pattern state %s for %s." % [expected_state, case["kind"]])
            quit(1)
            return false

    return true

func _clear_bosses() -> void:
    for enemy in get_nodes_in_group("survivor_enemies"):
        if not is_instance_valid(enemy):
            continue
        enemy.remove_from_group("survivor_enemies")
        enemy.queue_free()
