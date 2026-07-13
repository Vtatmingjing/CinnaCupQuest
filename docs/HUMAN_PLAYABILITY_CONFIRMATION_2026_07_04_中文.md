# 人类可玩与可读确认 - 2026-07-04

本次先把“能不能玩、能不能看清”作为最高优先级确认，未打开游戏 GUI，只使用 Godot headless/console 验证。

## 结论

当前版本通过可玩性、可读性、启动稳定性、光污染预算和视觉性能预算门槛。  
也就是说：工程能加载，战斗循环能跑，玩家没有开局死亡，场上敌人/弹幕/掉落物数量正常，画面亮度没有进入“黑七麻糊”或“光污染过曝”状态。

## 本次验证命令范围

Godot 路径：

`D:\Godot\Godot_v4.3-stable_win64_console.exe`

执行方式：

headless + `gl_compatibility`，未打开可视化游戏窗口。

## 通过结果

- `SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=104 projectiles=46 pickups=44 visible=2547 bright=1817 max_luma=1.000 floor_avg=0.137 floor_max=1.000`
- `SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=3039`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=40 pickups=32`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=8096 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=6190 nodes=8070 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility`

## 后续硬规则

- 每次继续改视觉、玩法、怪物或 UI 后，先跑 `survivor_playability_readability_gate.gd` 和 `survivor_headless_smoke.gd`。
- 涉及发光、弹幕、掉落物、敌人轮廓时，必须再跑 `survivor_glare_budget_matrix.gd`。
- 涉及增加模型、节点、场景装饰或大批量对象时，必须再跑 `survivor_visual_budget_smoke.gd`。
- 如果任何一项失败，先修“能玩、能看清、不卡顿”，再继续做美术或玩法增强。

备注：Godot headless/dummy renderer 在日志里会输出大量 `Parameter "m" is null` 噪声；本项目判断结果以 `SURVIVOR_*_OK` 标记和脚本错误/测试失败为准。
