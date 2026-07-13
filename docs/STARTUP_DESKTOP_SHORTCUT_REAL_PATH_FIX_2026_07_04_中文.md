# 桌面快捷方式真实路径修复记录

## 问题

用户启动游戏时出现 Windows 原生崩溃弹窗：

```text
Godot_v4.3-stable_win64.exe - 应用程序错误
0x00007FF7FBF9131D 指令引用了 0x0000000000000060 内存。该内存不能为 read。
```

项目 headless 启动稳定性测试通过，说明当前问题不属于主场景 GDScript 初始化失败。

## 定位

桌面存在旧的 `CinnaCupQuest 快捷方式` 文件夹，其中部分 `.lnk` 的目标仍指向：

```text
C:\Users\CodexSandboxOffline\Documents\game\CinnaCupQuest\...
```

这是 Codex 沙盒路径，不是用户真实项目路径。该路径会导致启动入口不稳定或失效。

## 修复

已将桌面上 CinnaCupQuest 相关快捷方式统一修正为真实项目路径：

```text
C:\Users\zhzhe\Documents\game\CinnaCupQuest
```

试玩入口统一通过以下脚本启动：

```text
launch_stable_opengl.bat
```

编辑器入口统一通过以下脚本启动：

```text
launch_editor_stable_opengl.bat
```

这两个脚本会强制使用 Godot console 版和 OpenGL 兼容渲染参数，避免直接走 Godot GUI/Vulkan 初始化路径。

## 验证

已运行：

```powershell
D:\Godot\Godot_v4.3-stable_win64_console.exe --disable-crash-handler --headless --path . --script res://tests/survivor_startup_stability_matrix.gd
D:\Godot\Godot_v4.3-stable_win64_console.exe --disable-crash-handler --headless --path . --script res://tests/survivor_headless_smoke.gd
```

通过标记：

```text
SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility
SURVIVOR_SMOKE_OK enemies=104 projectiles=40 pickups=32
```

## 使用建议

优先点击桌面上的：

```text
CinnaCupQuest 试玩游戏.lnk
```

不要直接双击 `D:\Godot\Godot_v4.3-stable_win64.exe` 打开项目。
