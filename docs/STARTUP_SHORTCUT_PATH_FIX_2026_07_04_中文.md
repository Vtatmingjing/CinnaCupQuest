# 启动崩溃与快捷方式路径修复记录

日期：2026-07-04

## 问题

用户启动 Godot 后出现 Windows 原生应用程序错误：

- `Godot_v4.3-stable_win64.exe - 应用程序错误`
- 内存读取失败，进程被系统终止。

排查时发现桌面新建的两个快捷方式目标路径错误地指向了沙盒用户目录：

- `C:\Users\CodexSandboxOffline\Documents\game\CinnaCupQuest\launch_stable_opengl.bat`
- `C:\Users\CodexSandboxOffline\Documents\game\CinnaCupQuest\launch_editor_stable_opengl.bat`

同时 Godot 用户日志里仍有 Vulkan / Forward+ 启动记录，说明存在直接打开 Godot 可执行文件或旧入口的情况。

## 修复

已将桌面入口统一修正到真实项目路径：

- `C:\Users\zhzhe\Desktop\CinnaCupQuest 试玩游戏.lnk`
- `C:\Users\zhzhe\Desktop\CinnaCupQuest 编辑器.lnk`
- `C:\Users\zhzhe\Desktop\CinnaCupQuest 快捷方式\01 试玩游戏.lnk`
- `C:\Users\zhzhe\Desktop\CinnaCupQuest 快捷方式\02 打开Godot编辑工程.lnk`
- `C:\Users\zhzhe\Desktop\CinnaCupQuest 快捷方式\旧快捷方式备份\CinnaCupQuest 试玩.lnk`

所有试玩/编辑器入口现在都指向项目内的稳定启动脚本：

- `launch_stable_opengl.bat`
- `launch_editor_stable_opengl.bat`

启动脚本会强制使用：

- `--display-driver windows`
- `--rendering-driver opengl3`
- `--rendering-method gl_compatibility`
- `--single-window`
- `--resolution 1280x720`
- `--max-fps 60`

## 验证

已在不打开 GUI 的条件下完成后台验证：

- headless 初始化：通过，退出码 0
- `res://tests/survivor_headless_smoke.gd`：通过，输出 `SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=32`

日志中的 `mesh_get_surface_count` 来自 Godot headless dummy renderer，是当前测试环境的已知噪声，不代表这次 Windows 原生崩溃。

## 使用建议

优先使用桌面上的：

- `CinnaCupQuest 试玩游戏`

不要直接双击 `D:\Godot\Godot_v4.3-stable_win64.exe` 进入项目，因为直接启动可能走 Vulkan / Forward+ 路径，复现显卡驱动或缓存层面的 native 崩溃。
