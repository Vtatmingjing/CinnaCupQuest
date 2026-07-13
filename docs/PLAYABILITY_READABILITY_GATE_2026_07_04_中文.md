# 可玩性与可读性门禁

本轮先不继续堆新美术和新机制，而是把“能不能玩、能不能看清”设成固定门槛。

新增测试：`res://tests/survivor_playability_readability_gate.gd`

它会在 Godot headless 环境中检查：

- 项目视口必须保持 `1280x720` 横屏。
- 主场景能启动，能从命运选择进入正式游玩。
- 3D 模式必须启用，玩家可见，键盘控制处于启用状态。
- 模拟开局前 `10` 秒，玩家不能直接死亡或进入结算。
- 场内必须存在敌人、弹幕、经验/金币掉落，避免“空场假通过”。
- HUD 选择层、开始按钮、卡片层在游玩时不能盖住战斗画面。
- 3D 摄像机必须是稳定俯视正交视角，不能倾斜、不能抖动。
- 世界环境、主光、补光、轮廓光不能被调到过暗。
- 地面贴图必须可加载，并且采样亮度不能低到黑糊。
- 英雄、敌人、敌方弹幕、拾取物、竞技场可读性层都必须有可见材质。
- 拾取物不能混入敌方危险弹幕的视觉通道，避免经验和弹幕混淆。

后续每批修改至少先跑：

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --rendering-driver opengl3 --rendering-method gl_compatibility --path . --script res://tests/survivor_playability_readability_gate.gd
```

如果这个测试不过，就先修“能玩、能看清”，再继续加内容。
