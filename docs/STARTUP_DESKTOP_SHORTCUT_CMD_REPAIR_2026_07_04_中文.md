# 桌面快捷方式二次修复记录

## 背景

用户截图显示直接启动时仍出现 Windows 原生崩溃：

```text
Godot_v4.3-stable_win64.exe - 应用程序错误
读取 0x0000000000000060 内存失败
```

项目本身的 headless 初始化和启动稳定矩阵均可通过，因此这次仍按启动入口问题处理，而不是按 GDScript 运行时错误处理。

## 排查结论

- 项目设置仍为 `gl_compatibility`。
- `launch_stable_opengl.bat` 和 `launch_editor_stable_opengl.bat` 仍强制使用：
  - `Godot_v4.3-stable_win64_console.exe`
  - `--display-driver windows`
  - `--rendering-driver opengl3`
  - `--rendering-method gl_compatibility`
  - `--single-window`
  - `--max-fps 60`
- 桌面快捷方式曾被 Windows COM 快捷方式写入逻辑映射到 `C:\Users\CodexSandboxOffline\...`，这个路径不是用户机器上的真实项目路径。

## 修复

将桌面根目录下的两个快捷方式改为通过 `cmd.exe /c` 显式调用真实脚本路径：

```text
CinnaCupQuest 试玩游戏.lnk
Target=C:\Windows\System32\cmd.exe
Arguments=/c ""C:\Users\zhzhe\Documents\game\CinnaCupQuest\launch_stable_opengl.bat""

CinnaCupQuest 编辑器.lnk
Target=C:\Windows\System32\cmd.exe
Arguments=/c ""C:\Users\zhzhe\Documents\game\CinnaCupQuest\launch_editor_stable_opengl.bat""
```

这样可以避免快捷方式目标再次被环境映射成沙盒目录。

## 验证

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\startup_stability_recheck_20260704.log --path . --script res://tests/survivor_startup_stability_matrix.gd
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\headless_init_recheck_20260704.log --path . --quit-after 3
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\survivor_headless_smoke_startup_recheck_20260704.log --path . --script res://tests/survivor_headless_smoke.gd
```

结果：

```text
SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility
SURVIVOR_SMOKE_OK enemies=104 projectiles=40 pickups=33
```

说明：headless 下的 `Parameter "m" is null` 来自 Godot dummy renderer 既有噪声；本轮以退出码 0 和上述 OK 标记作为通过依据。
