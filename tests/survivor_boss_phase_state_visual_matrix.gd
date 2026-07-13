extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const EnemyScript := preload("res://scripts/survivor_enemy.gd")

const CASES := [
    {"kind": "boss_cho", "detail": "BossPhaseChoDevourState"},
    {"kind": "boss_velkoz", "detail": "BossPhaseVelkozFocusState"},
    {"kind": "boss_reksai", "detail": "BossPhaseReksaiBurrowState"},
    {"kind": "boss_belveth", "detail": "BossPhaseBelvethSwarmState"}
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var view = ViewScript.new()
    root.add_child(view)
    await process_frame

    for i in range(CASES.size()):
        if not _check_case(view, CASES[i], i):
            return
        await process_frame

    print("SURVIVOR_BOSS_PHASE_STATE_VISUAL_MATRIX_OK bosses=%d" % CASES.size())
    quit(0)

func _check_case(view: Node, data: Dictionary, index: int) -> bool:
    var boss_kind := str(data["kind"])
    var expected_detail := str(data["detail"])
    var enemy = EnemyScript.new()
    enemy.setup(boss_kind, 14, true)
    enemy.set("max_health", 100)
    enemy.set("health", 34)
    enemy.set("attack_timer", 0.08)
    enemy.set("dash_timer", 0.0)
    enemy.set("summon_timer", 9.0)
    if boss_kind == "boss_reksai":
        enemy.set("dash_timer", 2.88)
    if boss_kind == "boss_cho" or boss_kind == "boss_belveth":
        enemy.set("summon_timer", 0.12)

    var model: Node3D = view.call("_create_enemy_model", boss_kind, true, true, enemy.get("body_color"), float(enemy.get("hit_radius")), false, "")
    view.add_child(model)
    view.call("_sync_boss_phase_state_rig", model, enemy, boss_kind, 500 + index)
    view.call("_sync_priority_combat_backplate", model, enemy, boss_kind, true, "", 500 + index, float(model.get_meta("visual_radius", 0.5)))

    var rig := model.get_node_or_null("BossPhaseStateRig") as Node3D
    if rig == null:
        return _fail("missing BossPhaseStateRig for %s." % boss_kind)
    if not bool(rig.visible):
        return _fail("BossPhaseStateRig did not become visible for %s." % boss_kind)
    if str(rig.get_meta("boss_kind", "")) != boss_kind:
        return _fail("boss kind metadata mismatch for %s." % boss_kind)
    if str(rig.get_meta("detail_node", "")) != expected_detail:
        return _fail("detail metadata mismatch for %s." % boss_kind)

    for child_name in ["BossPhaseFrame", "BossPhaseMeter", "BossPhaseCastState", "BossPhaseEnrageState", expected_detail]:
        var child := rig.get_node_or_null(child_name) as Node3D
        if child == null:
            return _fail("missing %s for %s." % [child_name, boss_kind])
        if not bool(child.visible):
            return _fail("%s did not become visible for %s." % [child_name, boss_kind])
        if _count_mesh_instances(child) <= 0:
            return _fail("%s has no mesh content for %s." % [child_name, boss_kind])

    if not _require_priority_state_strip(model, boss_kind, true):
        return false

    model.queue_free()
    return true

func _require_priority_state_strip(model: Node3D, label: String, boss: bool) -> bool:
    var rig := model.find_child("PriorityCombatBackplateRig", true, false) as Node3D
    if rig == null:
        return _fail("missing PriorityCombatBackplateRig for %s." % label)
    if float(rig.get_meta("priority_urgency", 0.0)) < 0.60:
        return _fail("priority urgency too low for %s: %.2f." % [label, float(rig.get_meta("priority_urgency", 0.0))])
    var strip := rig.get_node_or_null("PriorityThreatStateStrip") as Node3D
    if strip == null or not bool(strip.visible):
        return _fail("priority threat state strip not visible for %s." % label)
    if bool(strip.get_meta("priority_class", "") == "boss") != boss:
        return _fail("priority state class mismatch for %s." % label)
    var meter := strip.get_node_or_null("PriorityThreatStateMeter") as MeshInstance3D
    if meter == null or not bool(meter.visible) or meter.scale.x < 0.55:
        return _fail("priority threat state meter not active enough for %s." % label)
    var pips := strip.get_node_or_null("PriorityThreatStagePips") as Node3D
    if pips == null:
        return _fail("missing priority stage pips for %s." % label)
    var visible_pips := 0
    for child in pips.get_children():
        if child is Node3D and bool((child as Node3D).visible):
            visible_pips += 1
    if visible_pips < (2 if boss else 1):
        return _fail("priority stage pips did not light for %s." % label)
    return true

func _count_mesh_instances(node: Node) -> int:
    var count := 0
    if node is MeshInstance3D:
        count += 1
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count

func _fail(message: String) -> bool:
    push_error("Boss phase state visual matrix: " + message)
    quit(1)
    return false
