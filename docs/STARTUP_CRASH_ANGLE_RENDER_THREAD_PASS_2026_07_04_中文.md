# 启动崩溃 ANGLE 稳定化记录
日期：2026-07-04

## 问题

用户截图显示 `Godot_v4.3-stable_win64.exe` 发生 Windows 原生访问违规，读取 `0x0000000000000060` 内存失败。当前 headless 启动稳定测试可以通过，因此优先判断为 Godot 4.3 的 Windows GUI 渲染/线程路径风险，而不是 GDScript 主场景直接启动失败。

## 修改

- `launch_stable_opengl.bat`
  - 保留 Godot 4.3 console 入口。
  - 渲染驱动从原生 `opengl3` 改为 `opengl3_angle`，仍使用 `gl_compatibility`。
  - 增加 `--render-thread safe`，降低渲染线程路径触发原生崩溃的概率。
  - 启动前写入 `.godot-user\play_stable_angle_args.txt`，便于确认实际参数。
- `launch_editor_stable_opengl.bat`
  - 同步使用 `opengl3_angle` 和 `--render-thread safe`。
  - 启动前写入 `.godot-user\editor_stable_angle_args.txt`。
- `tests/survivor_startup_stability_matrix.gd`
  - 增加对 ANGLE 驱动变量和安全渲染线程参数的检查。

## 结论

这次改动不改变项目默认的 GL Compatibility 渲染方法，只把 Windows 上更容易出问题的原生 OpenGL 路径换成 ANGLE 路径。桌面快捷方式仍然指向原有稳定启动脚本，不需要重新创建。
