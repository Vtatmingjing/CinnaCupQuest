# 启动崩溃稳定性修复记录

## 问题

Windows 弹窗显示 `Godot_v4.3-stable_win64.exe` 原生崩溃，错误为读取 `0x0000000000000060` 内存。项目主场景在 headless 下可以正常初始化，未发现 GDScript 启动硬错误。

最近一次 Godot 用户日志显示 GUI 路径使用 `Vulkan / Forward+ / NVIDIA GeForce RTX 5060 Laptop GPU`，并且用户目录存在 Vulkan pipeline 与 shader cache。该类崩溃更接近 Godot 4.3 的 Vulkan/Forward+ 初始化或缓存路径问题。

## 修改

- `project.godot`
  - 默认渲染后端从 `Forward Plus` 切到 `GL Compatibility`。
  - 增加 `rendering/renderer/rendering_method="gl_compatibility"`。
  - 增加 `rendering/renderer/rendering_method.mobile="gl_compatibility"`。
- `launch_stable_opengl.bat`
  - 新增显式稳定启动脚本，固定使用 `--rendering-driver opengl3`。
- `tests/survivor_startup_stability_matrix.gd`
  - 新增 headless 启动稳定性测试，锁定 GL Compatibility 设置和主场景 3D 初始化。

## 验证方式

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\survivor_startup_stability_matrix.log --path . --script res://tests/survivor_startup_stability_matrix.gd
```

期望输出：

```text
SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility
```

## 备注

如果用户目录中的旧 Vulkan 缓存仍然影响手动启动，可清理：

- `%APPDATA%\Godot\app_userdata\Cinna Cup Quest\vulkan`
- `%APPDATA%\Godot\app_userdata\Cinna Cup Quest\shader_cache`

这属于用户目录缓存，不是项目源文件；正常优先使用 `launch_stable_opengl.bat` 或已更新后的项目设置启动。
