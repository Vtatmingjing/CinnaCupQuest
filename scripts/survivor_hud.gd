extends CanvasLayer
class_name CinnaSurvivorHUD

var title_label: Label
var stats_label: Label
var wave_label: Label
var weapon_label: Label
var message_label: Label
var help_label: Label
var xp_back: ColorRect
var xp_fill: ColorRect
var overlay_rect: ColorRect
var overlay_title: Label
var overlay_body: Label
var overlay_hint: Label

var message_timer := 0.0
var current_choices: Array = []

func _ready() -> void:
    title_label = _make_label(Vector2(12, 8), 25, Color(1.0, 0.82, 0.32))
    title_label.text = "CINNA CUP QUEST: SURVIVOR"
    stats_label = _make_label(Vector2(12, 42), 17, Color(1.0, 0.92, 0.66))
    wave_label = _make_label(Vector2(12, 68), 16, Color(0.82, 1.0, 0.70))
    weapon_label = _make_label(Vector2(12, 94), 15, Color(0.74, 0.95, 1.0))
    message_label = _make_label(Vector2(12, 126), 20, Color(1.0, 0.86, 0.36))
    help_label = _make_label(Vector2(12, 920), 15, Color(0.88, 0.84, 0.66))
    help_label.text = "WASD/Arrows move | Auto attack | 1/2/3 choose upgrade | P pause | R restart"

    xp_back = ColorRect.new()
    xp_back.position = Vector2(12, 116)
    xp_back.size = Vector2(516, 7)
    xp_back.color = Color(0.04, 0.03, 0.025, 0.90)
    add_child(xp_back)

    xp_fill = ColorRect.new()
    xp_fill.position = xp_back.position
    xp_fill.size = Vector2(0, 7)
    xp_fill.color = Color(0.40, 1.0, 0.46, 0.88)
    add_child(xp_fill)

    _build_overlay()

func _process(delta: float) -> void:
    if message_timer > 0.0:
        message_timer -= delta
        if message_timer <= 0.0:
            message_label.text = ""

func _make_label(pos: Vector2, font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.position = pos
    label.size = Vector2(520, 32)
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.02, 0.01, 0.0))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    add_child(label)
    return label

func _build_overlay() -> void:
    overlay_rect = ColorRect.new()
    overlay_rect.position = Vector2(30, 176)
    overlay_rect.size = Vector2(480, 610)
    overlay_rect.color = Color(0.05, 0.035, 0.03, 0.95)
    overlay_rect.visible = false
    add_child(overlay_rect)

    overlay_title = Label.new()
    overlay_title.position = Vector2(54, 202)
    overlay_title.size = Vector2(432, 56)
    overlay_title.add_theme_font_size_override("font_size", 29)
    overlay_title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.32))
    overlay_title.add_theme_color_override("font_shadow_color", Color.BLACK)
    overlay_title.add_theme_constant_override("shadow_offset_x", 3)
    overlay_title.add_theme_constant_override("shadow_offset_y", 3)
    overlay_title.visible = false
    add_child(overlay_title)

    overlay_body = Label.new()
    overlay_body.position = Vector2(54, 264)
    overlay_body.size = Vector2(432, 414)
    overlay_body.add_theme_font_size_override("font_size", 17)
    overlay_body.add_theme_color_override("font_color", Color(0.94, 0.91, 0.76))
    overlay_body.add_theme_color_override("font_shadow_color", Color.BLACK)
    overlay_body.add_theme_constant_override("shadow_offset_x", 2)
    overlay_body.add_theme_constant_override("shadow_offset_y", 2)
    overlay_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    overlay_body.visible = false
    add_child(overlay_body)

    overlay_hint = Label.new()
    overlay_hint.position = Vector2(54, 696)
    overlay_hint.size = Vector2(432, 72)
    overlay_hint.add_theme_font_size_override("font_size", 18)
    overlay_hint.add_theme_color_override("font_color", Color(0.62, 1.0, 0.62))
    overlay_hint.add_theme_color_override("font_shadow_color", Color.BLACK)
    overlay_hint.add_theme_constant_override("shadow_offset_x", 2)
    overlay_hint.add_theme_constant_override("shadow_offset_y", 2)
    overlay_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    overlay_hint.visible = false
    add_child(overlay_hint)

func update_run(player, elapsed: float, wave: int, enemies: int, boss_active: bool, boss_time: float) -> void:
    var hp := ""
    for i in range(player.max_health):
        hp += "#" if i < player.health else "-"
    stats_label.text = "HP[%s]  Shield:%d  Lv:%d  Score:%05d" % [hp, player.shield, player.level, player.score]
    var boss_text := "  |  Aroma Boss is here" if boss_active else "  |  Beacon %.0fs" % maxf(0.0, boss_time)
    wave_label.text = "TIME %s  |  WAVE %02d  |  ENEMIES %02d%s" % [_format_time(elapsed), wave, enemies, boss_text]
    weapon_label.text = "Spoon Dmg:%d  CD:%.2fs  Lime:%d  Aura:%d  Bubbles:%d  Upgrades: %s" % [
        player.damage,
        player.attack_cooldown * player.cooldown_mult,
        player.lime_level,
        player.aura_level,
        player.orbit_count,
        player.get_upgrade_summary()
    ]
    xp_fill.size = Vector2(516.0 * player.get_xp_fill(), 7)

func show_message(text: String, duration := 2.2) -> void:
    message_label.text = text
    message_timer = duration

func show_title(selected_character: String) -> void:
    _show_overlay()
    overlay_title.text = "Cinna Cup Quest: Survivor"
    overlay_body.text = "The tiny bartender is still trapped on a giant bar top. The genre has changed: survive the ingredient storm, auto-fire your bar tools, collect flavor drops, choose upgrades, and light the final Aroma Beacon.\n\nCharacter:\n1. Bartender - balanced spoon survivor\n2. Ice Knight - sturdier with piercing ice\n3. Mint Ninja - fast, wider magnet, crit leaning\n4. Lemon Gunner - starts with lime side shots\n\nCurrent: %s" % selected_character.replace("_", " ").capitalize()
    overlay_hint.text = "Press 1-4 to pick a character. Press Enter or R to start."

func show_pause() -> void:
    _show_overlay()
    overlay_title.text = "Paused"
    overlay_body.text = "The bar top holds its breath. Your spoon, lime seeds, cinnamon sparks, ice shields, and bubble orbitals are all frozen in mid-air."
    overlay_hint.text = "P / Enter: resume    R: restart    Esc: resume"

func show_upgrade_choices(options: Array) -> void:
    current_choices = options
    _show_overlay()
    overlay_title.text = "Mix A New Drink"
    var text := "Choose one ingredient upgrade. This is the survivor-style build moment: your tiny bartender gets stronger while the bar top gets louder.\n"
    for i in range(options.size()):
        var option: Dictionary = options[i]
        text += "\n%d. %s\n   %s" % [i + 1, option.get("name", "Upgrade"), option.get("desc", "")]
    overlay_body.text = text
    overlay_hint.text = "Press 1 / 2 / 3 to choose."

func show_summary(won: bool, player, elapsed: float) -> void:
    _show_overlay()
    overlay_title.text = "AROMA BEACON LIT!" if won else "RUN ENDED"
    var result := "You survived the bar-top bullet storm and lit the final Aroma Beacon." if won else "The tiny hero fell, but the recipe notes were rescued."
    overlay_body.text = "%s\n\nTime: %s\nLevel: %d\nScore: %05d\nUpgrades: %s\n\nThe theme stayed: glass cup, golden drink, mint, cinnamon, ice, lime, bubbles, torch sparks. The game loop is now auto-attack survival roguelike." % [
        result,
        _format_time(elapsed),
        player.level,
        player.score,
        player.get_upgrade_summary()
    ]
    overlay_hint.text = "Enter / R: new run"

func hide_overlay() -> void:
    overlay_rect.visible = false
    overlay_title.visible = false
    overlay_body.visible = false
    overlay_hint.visible = false

func _show_overlay() -> void:
    overlay_rect.visible = true
    overlay_title.visible = true
    overlay_body.visible = true
    overlay_hint.visible = true

func _format_time(value: float) -> String:
    var seconds := int(value)
    return "%02d:%02d" % [int(seconds / 60), seconds % 60]
