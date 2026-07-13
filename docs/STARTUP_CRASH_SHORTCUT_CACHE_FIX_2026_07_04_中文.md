# 启动崩溃快捷方式与缓存修复记录

## 背景

用户截图显示 `Godot_v4.3-stable_win64.exe` 在 Windows 弹出访问违规错误，读取 `0x0000000000000060` 内存失败。项目 headless 主场景初始化可正常完成，说明当前问题更接近 Godot GUI 启动路径、旧 Vulkan/Forward+ 缓存或桌面入口参数问题，而不是 GDScript 启动硬错误。

## 修改

- 更新 `launch_stable_opengl.bat`
  - 固定 `--display-driver windows`。
  - 固定 `--rendering-driver opengl3`。
  - 固定 `--rendering-method gl_compatibility`。
  - 增加 `--disable-crash-handler`、`--single-window`、`--resolution 1280x720`、`--max-fps 60`。
  - 日志写入 `.godot-user\play_stable_opengl.log`，方便追踪下一次启动问题。
- 新增 `launch_editor_stable_opengl.bat`
  - 编辑器入口也使用同样的 OpenGL 稳定参数。
  - 日志写入 `.godot-user\editor_stable_opengl.log`。
- 更新 `tests/survivor_startup_stability_matrix.gd`
  - 检查项目渲染方法必须为 `gl_compatibility`。
  - 检查试玩和编辑器启动脚本必须包含稳定启动参数。
- 已将桌面快捷方式改为指向稳定脚本：
  - `CinnaCupQuest 试玩游戏.lnk` -> `launch_stable_opengl.bat`
  - `CinnaCupQuest 编辑器.lnk` -> `launch_editor_stable_opengl.bat`
- 已将 Godot 用户目录旧缓存重命名为备份：
  - `vulkan.disabled_20260704_025135`
  - `shader_cache.disabled_20260704_025135`

## 验证

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\survivor_startup_stability_matrix_crashfix.log --path . --script res://tests/survivor_startup_stability_matrix.gd
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\codex_crashfix_headless_init.log --path . --quit-after 3
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\survivor_headless_smoke_crashfix.log --path . --script res://tests/survivor_headless_smoke.gd
```

通过结果：

```text
SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility
SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=32
```

## 备注

headless 下仍会出现 Godot dummy renderer 的 `mesh_get_surface_count` 噪声，但退出码为 0，且目标测试输出正常。该噪声不等同于 GUI 启动崩溃。
