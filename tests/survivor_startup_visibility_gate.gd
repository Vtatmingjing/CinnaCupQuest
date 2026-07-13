extends SceneTree

const MainScene := preload("res://scenes/Main.tscn")

const EXPECTED_VIEWPORT := Vector2i(1280, 720)
const MIN_AMBIENT := 0.18
const MIN_EXPOSURE := 0.70
const MIN_KEY_LIGHT := 0.70
const MIN_FLOOR_TINT_LUMA := 0.82
const MAX_MENU_OVERLAY_ALPHA := 0.90
const MIN_MENU_OVERLAY_LUMA := 0.040
const MIN_VISIBLE_HERO_CARDS := 8
const MIN_VISIBLE_PORTRAITS := 8

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _require_project_window():
        return

    var main = MainScene.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame

    if str(main.get("game_state")) != "menu":
        push_error("Startup visibility expected first screen to stay on hero selection menu.")
        quit(1)
        return

    var visual3d = main.get("visual3d")
    if visual3d == null:
        push_error("Startup visibility expected 3D view.")
        quit(1)
        return
    if not _require_camera_and_lighting(visual3d):
        return
    if not _require_menu_ui(main):
        return

    print("SURVIVOR_STARTUP_VISIBILITY_OK viewport=%dx%d ambient=%.3f exposure=%.3f overlay_alpha=%.2f hero_cards=%d portraits=%d" % [
        EXPECTED_VIEWPORT.x,
        EXPECTED_VIEWPORT.y,
        _ambient_energy(visual3d),
        _exposure(visual3d),
        _menu_overlay_alpha(main),
        _visible_hero_cards(main),
        _visible_portraits(main)
    ])
    quit(0)

func _require_project_window() -> bool:
    var width := int(ProjectSettings.get_setting("display/window/size/viewport_width", 0))
    var height := int(ProjectSettings.get_setting("display/window/size/viewport_height", 0))
    if width != EXPECTED_VIEWPORT.x or height != EXPECTED_VIEWPORT.y:
        push_error("Startup visibility expected %dx%d viewport, got %dx%d." % [EXPECTED_VIEWPORT.x, EXPECTED_VIEWPORT.y, width, height])
        quit(1)
        return false
    return true

func _require_camera_and_lighting(visual3d: Node) -> bool:
    var camera := visual3d.get("camera") as Camera3D
    if camera == null or not camera.current:
        push_error("Startup visibility expected current 3D camera.")
        quit(1)
        return false
    if camera.projection != Camera3D.PROJECTION_ORTHOGONAL:
        push_error("Startup visibility expected orthogonal top-down camera.")
        quit(1)
        return false
    if absf(camera.rotation_degrees.x + 90.0) > 0.05:
        push_error("Startup visibility expected non-tilting top-down camera, got %s." % str(camera.rotation_degrees))
        quit(1)
        return false

    var env_node := visual3d.find_child("HextechVoidWorldEnvironment", true, false) as WorldEnvironment
    if env_node == null or env_node.environment == null:
        push_error("Startup visibility expected world environment.")
        quit(1)
        return false
    var environment := env_node.environment
    if environment.ambient_light_energy < MIN_AMBIENT:
        push_error("Startup visibility ambient too low: %.3f." % environment.ambient_light_energy)
        quit(1)
        return false
    if environment.tonemap_exposure < MIN_EXPOSURE:
        push_error("Startup visibility exposure too low: %.3f." % environment.tonemap_exposure)
        quit(1)
        return false

    var key_light := visual3d.find_child("HextechKeyLight", true, false) as DirectionalLight3D
    if key_light == null or key_light.light_energy < MIN_KEY_LIGHT:
        push_error("Startup visibility expected stronger key light.")
        quit(1)
        return false

    var floor := visual3d.find_child("ArenaPaintedFloor", true, false) as MeshInstance3D
    var floor_mat := floor.material_override as StandardMaterial3D if floor != null else null
    if floor_mat == null or floor_mat.albedo_texture == null:
        push_error("Startup visibility expected textured arena floor.")
        quit(1)
        return false
    if _luminance(floor_mat.albedo_color) < MIN_FLOOR_TINT_LUMA:
        push_error("Startup visibility floor tint too dark: %.3f." % _luminance(floor_mat.albedo_color))
        quit(1)
        return false
    return true

func _require_menu_ui(main: Node) -> bool:
    var hud = main.get("hud")
    if hud == null:
        push_error("Startup visibility expected HUD.")
        quit(1)
        return false
    var overlay_rect := hud.get("overlay_rect") as ColorRect
    if overlay_rect == null or not bool(overlay_rect.visible):
        push_error("Startup visibility expected visible menu overlay.")
        quit(1)
        return false
    if overlay_rect.color.a > MAX_MENU_OVERLAY_ALPHA:
        push_error("Startup visibility menu overlay is too opaque: %.2f." % overlay_rect.color.a)
        quit(1)
        return false
    if _luminance(overlay_rect.color) < MIN_MENU_OVERLAY_LUMA:
        push_error("Startup visibility menu overlay is too black: %.3f." % _luminance(overlay_rect.color))
        quit(1)
        return false

    var title := hud.get("overlay_title") as Label
    if title == null or not bool(title.visible) or title.text.find("海克斯虚空大乱斗") < 0:
        push_error("Startup visibility expected localized visible title.")
        quit(1)
        return false

    if _visible_hero_cards(main) < MIN_VISIBLE_HERO_CARDS:
        push_error("Startup visibility expected %d visible hero cards, got %d." % [MIN_VISIBLE_HERO_CARDS, _visible_hero_cards(main)])
        quit(1)
        return false
    if _visible_portraits(main) < MIN_VISIBLE_PORTRAITS:
        push_error("Startup visibility expected %d visible hero portraits, got %d." % [MIN_VISIBLE_PORTRAITS, _visible_portraits(main)])
        quit(1)
        return false

    var start_button := hud.get("start_button") as Button
    if start_button == null or not bool(start_button.visible) or start_button.text.find("开始游戏") < 0:
        push_error("Startup visibility expected visible localized start button.")
        quit(1)
        return false
    return true

func _visible_hero_cards(main: Node) -> int:
    var hud = main.get("hud")
    if hud == null:
        return 0
    var total := 0
    var choice_buttons: Array = hud.get("choice_buttons")
    for button in choice_buttons:
        if button is Button and bool(button.visible) and str(button.get_meta("card_layout_profile", "")) == "hero":
            total += 1
    return total

func _visible_portraits(main: Node) -> int:
    var hud = main.get("hud")
    if hud == null:
        return 0
    var total := 0
    var choice_icon_images: Array = hud.get("choice_icon_images")
    for image in choice_icon_images:
        if image is TextureRect and bool(image.visible) and image.texture != null:
            total += 1
    return total

func _menu_overlay_alpha(main: Node) -> float:
    var hud = main.get("hud")
    if hud == null:
        return 0.0
    var overlay_rect := hud.get("overlay_rect") as ColorRect
    return overlay_rect.color.a if overlay_rect != null else 0.0

func _ambient_energy(visual3d: Node) -> float:
    var env_node := visual3d.find_child("HextechVoidWorldEnvironment", true, false) as WorldEnvironment
    return env_node.environment.ambient_light_energy if env_node != null and env_node.environment != null else 0.0

func _exposure(visual3d: Node) -> float:
    var env_node := visual3d.find_child("HextechVoidWorldEnvironment", true, false) as WorldEnvironment
    return env_node.environment.tonemap_exposure if env_node != null and env_node.environment != null else 0.0

func _luminance(color: Color) -> float:
    return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
