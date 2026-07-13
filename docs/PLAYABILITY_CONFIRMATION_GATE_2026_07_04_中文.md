# 可玩性与人类可读性确认 - 2026-07-04

本轮先暂停继续堆新效果，优先确认当前版本是否能正常进入、能持续游玩，并且不会出现“黑七麻糊看不清”或“光污染太亮分不清”的状态。

## 修复

- 修复 `scripts/survivor_3d_view.gd` 中 `signal` 关键字变量导致的 GDScript 解析失败，项目重新可以无窗口初始化。
- 将 `ChampionCombatLoopReadout` 纳入玩家 3D 模型同步，避免新增视觉层只创建不更新。
- 为赛娜补充低亮度灵魂端点，使英雄战斗循环标识达到测试要求的可读信息量。
- 在 `tests/survivor_champion_visual_matrix.gd` 增加英雄战斗循环标识约束，要求每个英雄都有独立的战斗节奏/机制标识，并且材质保持低光污染。

## 当前确认结果

以下均使用 `D:\Godot\Godot_v4.3-stable_win64_console.exe` 的 headless 模式执行，没有打开游戏 GUI。

- 初始化：通过，无 GDScript 解析错误。
- `SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=103 projectiles=50 pickups=46 visible=2524 bright=1808 max_luma=1.000 floor_avg=0.137 floor_max=1.000`
- `SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=2980 ability_atlas=1536x1024 archetype=role_silhouette`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=33`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7884 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=6138 nodes=8011 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility`

## 后续硬门槛

- 每次继续改动后，至少先跑初始化、`survivor_playability_readability_gate.gd`、`survivor_headless_smoke.gd`、`survivor_glare_budget_matrix.gd` 和 `survivor_visual_budget_smoke.gd`。
- 如果可玩性门或光污染预算失败，优先修“能玩、能看清”，不继续添加新视觉特效。
- Godot headless/dummy renderer 会输出大量 `Parameter "m" is null` 噪声；判断结果以 `SURVIVOR_*_OK` 标记和是否存在脚本/测试失败为准。
