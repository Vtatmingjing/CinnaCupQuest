# 启动崩溃入口加固记录
日期：2026-07-04

## 问题

用户截图显示 `Godot_v4.3-stable_win64.exe` 发生 Windows 原生访问违规崩溃，读取 `0x0000000000000060` 内存失败。

最新用户日志显示本次实际启动路径为：

- `Vulkan 1.4.325 - Forward+`

这说明当时没有走项目的稳定 OpenGL 启动入口，或桌面快捷方式目标仍然指向了旧路径/错误路径。

## 修复

已加固两个项目内启动脚本：

- `launch_stable_opengl.bat`
- `launch_editor_stable_opengl.bat`

具体变更：

- Godot 入口从普通 GUI exe 改为 `D:\Godot\Godot_v4.3-stable_win64_console.exe`。
- 继续强制 `--rendering-driver opengl3`。
- 继续强制 `--rendering-method gl_compatibility`。
- 继续限制 `--max-fps 60`。
- 启动前自动隔离项目用户目录里的 `vulkan` 和 `shader_cache` 缓存。
- 启动窗口最小化，减少 console 入口对试玩的干扰。

## 需要确认

桌面 `.lnk` 必须指向真实项目路径：

- `C:\Users\zhzhe\Documents\game\CinnaCupQuest\launch_stable_opengl.bat`
- `C:\Users\zhzhe\Documents\game\CinnaCupQuest\launch_editor_stable_opengl.bat`

不要直接双击 `D:\Godot\Godot_v4.3-stable_win64.exe` 打开项目。直接打开会更容易回到 Vulkan / Forward+ 路径。

## 验证

已更新 `res://tests/survivor_startup_stability_matrix.gd`，要求启动脚本必须包含：

- console 版 Godot 入口。
- OpenGL/gl_compatibility 参数。
- Vulkan/Shader 缓存隔离逻辑。
- 最小化启动参数。

当前验证结果：

- `SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=40 pickups=32`
- headless 初始化：退出码 0

桌面快捷方式已重新写入真实目标路径：

- `C:\Users\zhzhe\Desktop\CinnaCupQuest 试玩游戏.lnk`
- `C:\Users\zhzhe\Desktop\CinnaCupQuest 编辑器.lnk`
- `C:\Users\zhzhe\Desktop\CinnaCupQuest 快捷方式\01 试玩游戏.lnk`
- `C:\Users\zhzhe\Desktop\CinnaCupQuest 快捷方式\02 打开Godot编辑工程.lnk`
