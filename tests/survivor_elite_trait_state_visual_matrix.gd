extends SceneTree

const ViewScript := preload("res://scripts/survivor_3d_view.gd")
const EnemyScript := preload("res://scripts/survivor_enemy.gd")

const CASES := [
    {"trait": "frenzy", "kind": "voidling", "state": "EliteTraitStateFrenzyDash", "tactical": "EliteTraitTacticalFrenzyRushLane"},
    {"trait": "bulwark", "kind": "carapace", "state": "EliteTraitStateBulwarkBreak", "tactical": "EliteTraitTacticalBulwarkBreakWindow"},
    {"trait": "splitter", "kind": "skitter", "state": "EliteTraitStateSplitterBloom", "tactical": "EliteTraitTacticalSplitterBloomRadius"},
    {"trait": "treasure", "kind": "spitter", "state": "EliteTraitStateTreasureFlee", "tactical": "EliteTraitTacticalTreasureFleeVector"}
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

    print("SURVIVOR_ELITE_TRAIT_STATE_VISUAL_MATRIX_OK traits=%d" % CASES.size())
    quit(0)

func _check_case(view: Node, data: Dictionary, index: int) -> bool:
    var trait_id := str(data["trait"])
    var kind := str(data["kind"])
    var expected_state := str(data["state"])
    var expected_tactical := str(data["tactical"])
    var enemy = EnemyScript.new()
    enemy.setup(kind, 10, false)
    enemy.elite = true
    enemy.configure_elite_trait(trait_id)
    enemy.set("max_health", 100)
    enemy.set("health", 100)
    enemy.set("dash_timer", 0.0)
    enemy.set("bulwark_guard", 0)
    enemy.set("bulwark_break_timer", 0.0)
    enemy.set("splitter_spawned", false)
    enemy.set("treasure_flee_timer", 0.0)
    enemy.set("attack_timer", 0.50)
    match trait_id:
        "frenzy":
            enemy.set("dash_timer", 0.58)
        "bulwark":
            enemy.set("bulwark_break_timer", 2.30)
        "splitter":
            enemy.set("health", 48)
        "treasure":
            enemy.set("treasure_flee_timer", 1.20)
        _:
            pass

    var model: Node3D = view.call("_create_enemy_model", kind, false, true, enemy.get("body_color"), float(enemy.get("hit_radius")), false, trait_id)
    view.add_child(model)
    var rig := model.find_child("EliteTraitTelegraphRig", true, false) as Node3D
    if rig == null:
        return _fail("missing EliteTraitTelegraphRig for %s." % trait_id)

    view.call("_sync_elite_trait_telegraph", rig, enemy, kind, trait_id, 300 + index)
    view.call("_sync_priority_combat_backplate", model, enemy, kind, false, trait_id, 300 + index, float(model.get_meta("visual_radius", 0.5)))
    var state := rig.get_node_or_null("EliteTraitBehaviorStateRig") as Node3D
    if state == null:
        return _fail("missing EliteTraitBehaviorStateRig for %s." % trait_id)
    if not bool(state.visible):
        return _fail("behavior state rig did not become visible for %s." % trait_id)
    var expected := state.get_node_or_null(expected_state) as Node3D
    if expected == null:
        return _fail("missing expected state node %s." % expected_state)
    if not bool(expected.visible):
        return _fail("expected state node %s did not become visible." % expected_state)
    if _count_mesh_instances(expected) <= 0:
        return _fail("expected state node %s has no mesh content." % expected_state)

    for child in state.get_children():
        var child_node := child as Node3D
        if child_node == null:
            continue
        if child_node.name.begins_with("EliteTraitState") and child_node.name != "EliteTraitStateHalo" and child_node.name != "EliteTraitStateMeter" and child_node.name != expected_state:
            if bool(child_node.visible):
                return _fail("unexpected state node %s visible for %s." % [child_node.name, trait_id])

    if not _require_priority_state_strip(model, trait_id):
        return false
    if not _require_tactical_readout(rig, trait_id, expected_tactical):
        return false

    model.queue_free()
    return true

func _require_tactical_readout(rig: Node3D, trait_id: String, expected_tactical: String) -> bool:
    var readout := rig.get_node_or_null("EliteTraitTacticalReadout") as Node3D
    if readout == null:
        return _fail("missing EliteTraitTacticalReadout for %s." % trait_id)
    if not bool(readout.visible):
        return _fail("tactical readout did not become visible for %s." % trait_id)
    if str(readout.get_meta("elite_trait", "")) != trait_id:
        return _fail("tactical readout trait metadata mismatch for %s." % trait_id)
    if float(readout.get_meta("tactical_urgency", 0.0)) < 0.30:
        return _fail("tactical urgency too low for %s: %.2f." % [trait_id, float(readout.get_meta("tactical_urgency", 0.0))])
    var detail := readout.get_node_or_null(expected_tactical) as Node3D
    if detail == null:
        return _fail("missing tactical detail %s for %s." % [expected_tactical, trait_id])
    if _count_mesh_instances(detail) <= 0:
        return _fail("tactical detail %s has no mesh content." % expected_tactical)
    var pockets := readout.get_node_or_null("EliteTraitTacticalSafePockets") as Node3D
    if pockets == null:
        return _fail("missing tactical safe pockets for %s." % trait_id)
    var visible_pockets := 0
    for child in pockets.get_children():
        if child is Node3D and bool((child as Node3D).visible):
            visible_pockets += 1
    if visible_pockets < 1:
        return _fail("tactical safe pockets did not become visible for %s." % trait_id)
    return true

func _require_priority_state_strip(model: Node3D, trait_id: String) -> bool:
    var priority := model.find_child("PriorityCombatBackplateRig", true, false) as Node3D
    if priority == null:
        return _fail("missing PriorityCombatBackplateRig for %s." % trait_id)
    if str(priority.get_meta("elite_trait", "")) != trait_id:
        return _fail("priority backplate trait metadata mismatch for %s." % trait_id)
    if float(priority.get_meta("priority_urgency", 0.0)) < 0.30:
        return _fail("priority urgency too low for %s: %.2f." % [trait_id, float(priority.get_meta("priority_urgency", 0.0))])
    var strip := priority.get_node_or_null("PriorityThreatStateStrip") as Node3D
    if strip == null or not bool(strip.visible):
        return _fail("priority threat state strip not visible for %s." % trait_id)
    var meter := strip.get_node_or_null("PriorityThreatStateMeter") as MeshInstance3D
    if meter == null or not bool(meter.visible) or meter.scale.x < 0.25:
        return _fail("priority threat state meter not active enough for %s." % trait_id)
    var pips := strip.get_node_or_null("PriorityThreatStagePips") as Node3D
    if pips == null:
        return _fail("missing priority stage pips for %s." % trait_id)
    var visible_pips := 0
    for child in pips.get_children():
        if child is Node3D and bool((child as Node3D).visible):
            visible_pips += 1
    if visible_pips < 1:
        return _fail("priority stage pips did not light for %s." % trait_id)
    return true

func _count_mesh_instances(node: Node) -> int:
    var count := 0
    if node is MeshInstance3D:
        count += 1
    for child in node.get_children():
        count += _count_mesh_instances(child)
    return count

func _fail(message: String) -> bool:
    push_error("Elite trait state visual matrix: " + message)
    quit(1)
    return false
