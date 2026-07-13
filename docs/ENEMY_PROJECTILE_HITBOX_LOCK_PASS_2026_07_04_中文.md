# 敌方弹幕命中半径锁 - 2026-07-04

本轮目标是继续解决“敌人弹幕不明显，容易和经验/掉落物混淆”的问题，同时不增加光污染和密集场景性能压力。

## 修改内容

- 在 `EnemyProjectileReadabilityShell` 内新增 `EnemyProjectileHitboxLock`。
- 所有敌方弹幕都会获得黑红低眩光的碰撞半径锁：
  - `EnemyProjectileHitboxLockShadow`
  - `EnemyProjectileHitboxLockRing`
  - `EnemyProjectileHitboxLockDirectionTab`
- 非 lite 敌方弹幕额外获得 `EnemyProjectileHitboxLockTierTicks`，用刻度数量区分普通危险、特殊弹幕和 Boss 级弹幕。
- lite 敌方弹幕只保留 3 个核心网格，不挂 tier ticks，避免密集弹幕场景超预算。
- 所有新增节点都标记为 `enemy_hazard`，并带有 `pickup_confusion_guard` 与 `collision_radius_marker`，防止后续被误归类成拾取物视觉层。
- 同步逻辑中新增轻微呼吸和旋转，危险等级越高读图越明确，但材料仍保持非发光/低透明度。

## 覆盖测试

`tests/survivor_projectile_visual_matrix.gd` 新增了对 `EnemyProjectileHitboxLock` 的断言：

- 普通版和 lite 版都必须存在命中半径锁。
- 必须保留敌方危险通道、拾取物混淆保护、碰撞半径标识和低眩光材料等级。
- 威胁等级必须与运行时代码一致。
- lite 版本不得生成 tier ticks。
- 普通版本必须生成 tier ticks，但总网格数受控。
- 不允许泄漏到 pickup 视觉通道。

## Headless 验证

本轮未打开游戏 GUI，只使用 Godot headless 验证。

- 初始化：通过，无 GDScript 解析错误。
- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1929`
- `SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=103 projectiles=34 pickups=45 visible=3168 bright=2633 max_luma=1.000 floor_avg=0.137 floor_max=1.000`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=32`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=8187 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=6287 nodes=8209 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility`

## 结论

这批修改让敌方弹幕在混战里多了一层明确的“危险命中边界”，更容易和 XP/金币等掉落物区分。验证结果显示它没有破坏启动、可玩性、光污染预算或密集场景性能预算。
