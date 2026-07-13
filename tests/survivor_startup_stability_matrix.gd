extends SceneTree

const MainScene := preload("res://scenes/Main.tscn")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var render_method := str(ProjectSettings.get_setting("rendering/renderer/rendering_method", ""))
    if render_method != "gl_compatibility":
        push_error("Startup stability expected gl_compatibility renderer, got %s." % render_method)
        quit(1)
        return

    var mobile_render_method := str(ProjectSettings.get_setting("rendering/renderer/rendering_method.mobile", ""))
    if mobile_render_method != "gl_compatibility":
        push_error("Startup stability expected mobile gl_compatibility renderer, got %s." % mobile_render_method)
        quit(1)
        return

    var features: PackedStringArray = ProjectSettings.get_setting("application/config/features", PackedStringArray())
    if not features.has("GL Compatibility"):
        push_error("Startup stability expected project feature GL Compatibility.")
        quit(1)
        return

    if not _require_launch_script("res://launch_stable_opengl.bat", false):
        quit(1)
        return

    if not _require_launch_script("res://launch_editor_stable_opengl.bat", true):
        quit(1)
        return

    var main = MainScene.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame

    if not main.has_method("_start_new_run"):
        push_error("Startup stability expected survivor main scene.")
        quit(1)
        return

    var visual3d = main.get("visual3d")
    if visual3d == null:
        push_error("Startup stability expected the 3D view to initialize.")
        quit(1)
        return

    if visual3d.find_child("HextechVoidWorldEnvironment", true, false) == null:
        push_error("Startup stability expected named world environment.")
        quit(1)
        return

    main.queue_free()
    await process_frame
    print("SURVIVOR_STARTUP_STABILITY_OK renderer=%s feature=GL_Compatibility" % render_method)
    quit(0)

func _require_launch_script(path: String, editor: bool) -> bool:
    if not FileAccess.file_exists(path):
        push_error("Startup stability expected %s." % path)
        return false

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Startup stability could not read %s." % path)
        return false

    var text := file.get_as_text()
    var required_args := [
        "Godot_v4.3-stable_win64_console.exe",
        "PROJECT_DIR=%PROJECT_DIR:~0,-1%",
        "LOG_DIR=%PROJECT_DIR%\\.godot-user",
        "--disable-crash-handler",
        "--display-driver windows",
        "--rendering-driver %RENDERING_DRIVER%",
        "RENDERING_DRIVER=opengl3",
        "--rendering-method gl_compatibility",
        "--render-thread safe",
        "--single-window",
        "--max-fps 60",
        "--log-file",
        "vulkan.disabled_",
        "shader_cache.disabled_",
        "CONSOLE_LOG=",
        "SafeEntry=",
        "ExitCode=%ERRORLEVEL%"
    ]
    for arg in required_args:
        if text.find(arg) == -1:
            push_error("Startup stability expected %s to include %s." % [path, arg])
            return false

    if editor and text.find("--editor") == -1:
        push_error("Startup stability expected editor script to include --editor.")
        return false

    if not editor and text.find("--resolution 1280x720") == -1:
        push_error("Startup stability expected play script to force 1280x720.")
        return false

    return true
