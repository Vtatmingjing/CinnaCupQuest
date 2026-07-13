# 敌方弹幕运动对比层检查

日期：2026-07-04

本轮目标：减少敌方弹幕和经验/金币掉落混淆，让玩家在密集战斗里先读到“危险形状”和“飞行方向”，而不是只看到一堆彩色亮点。

## 改动

- 给所有敌方弹幕和 lite 敌方弹幕新增 `EnemyProjectileMotionContrastRig`。
- 新增非发光暗芯 `EnemyProjectileMotionShadowCore`，强化弹幕主体轮廓。
- 新增非发光尾迹隔离条 `EnemyProjectileMotionTailSeparator`，让飞行方向更容易判断。
- 新增前端危险缺口 `EnemyProjectileMotionHeadNotch`，把弹幕头部和经验/金币拾取物区分开。
- 所有新增节点使用 `enemy_hazard` 通道，并带 `pickup_confusion_guard` 与 `motion_contrast_layer` 元数据。
- 运行时只做轻微拉伸同步，不增加镜头抖动，不使用高频闪烁。

## 验证

- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1799`
- `SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=103 projectiles=57 pickups=45 visible=2743 bright=1879 max_luma=1.000 floor_avg=0.137 floor_max=1.000`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=46 pickups=32`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7820 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=6137 nodes=8014 projectiles=210 pickups=169 zones=31`

说明：Godot 4.3 headless dummy renderer 仍会输出 `Parameter "m" is null` 噪声。本轮以测试 OK 标记、无脚本/解析错误、光污染与视觉预算通过为准。
