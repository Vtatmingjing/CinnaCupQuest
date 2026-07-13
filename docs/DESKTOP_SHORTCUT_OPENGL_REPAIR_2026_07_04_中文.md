# 桌面快捷方式 OpenGL 启动修复 - 2026-07-04

## 问题

桌面上的 `CinnaCupQuest 试玩游戏.lnk` 本身存在，目标也确实指向项目里的 `launch_stable_opengl.bat`。  
用户点击后，脚本会运行并写入参数文件，但 Godot 没有生成项目日志：

- `.godot-user/play_stable_opengl_args.txt` 更新
- `ExitCode=1`
- `.godot-user/play_stable_opengl.log` 未生成

这说明失败发生在 Godot 写项目日志之前，主要集中在启动参数解析阶段。

## 修复

- `launch_stable_opengl.bat` 从 `RENDERING_DRIVER=opengl3_angle` 改为 `RENDERING_DRIVER=opengl3`。
- `launch_editor_stable_opengl.bat` 同步改为 `RENDERING_DRIVER=opengl3`。
- 去掉 `/min`，避免点击快捷方式后窗口被最小化，看起来像没有反应。
- 修剪 `%~dp0` 生成的项目目录尾反斜杠，避免传入 `--path "...\CinnaCupQuest\"` 时 Windows 参数解析把闭合引号吃掉。
- 不再通过 `start /wait` 间接启动 Godot，改为直接运行 Godot 并捕获控制台输出。
- 桌面快捷方式保留 `cmd.exe /c` 入口，参数明确指向 `C:\Users\zhzhe\Documents\game\CinnaCupQuest\launch_stable_opengl.bat`，避免 `.lnk` 直接指向 `.bat` 时被解析到错误用户路径。
- 如果 Godot 在写项目日志前退出，会额外留下：
  - `.godot-user/play_stable_opengl_console.log`
  - `.godot-user/editor_stable_opengl_console.log`

## 验证

未主动打开游戏 GUI，只使用 headless 后台验证。

- 桌面快捷方式目标存在。
- 快捷方式工作目录存在。
- 快捷方式指向的启动脚本存在。
- 快捷方式读回结果确认未指向 `C:\Users\CodexSandboxOffline\...`。
- Godot 路径存在：`D:\Godot\Godot_v4.3-stable_win64_console.exe`
- `SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility`
- `SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=206`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=6340 nodes=8271 projectiles=210 pickups=169 zones=31`

## 结论

桌面快捷方式本身没有丢。此前不能用的主要原因是启动脚本里的旧 `opengl3_angle` 参数，以及带尾反斜杠的 `--path` 引号风险。现在快捷方式仍然指向同一个脚本，但脚本已经改为后台验证通过的稳定 OpenGL 参数，并会在失败时保留控制台错误日志。
