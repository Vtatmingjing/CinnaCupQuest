# 场地低光污染构图层更新

本轮继续处理“场景乱、光污染、敌人与弹幕不清楚”的方向，不增加动态战斗负担，优先提升 3D 场地的构图和可读性。

## 主要改动

- 新增 `ArenaReadabilityVignetteSet` 静态场地层。
- 场地四边新增 `ArenaDepthEdgeShadow_*`，用低透明黑色材质压暗边缘。
- 四角新增 `ArenaDepthCornerOccluder_*`，让画面边框更收束，减少外围装饰抢视线。
- 中央战斗区域新增 `ArenaCombatFocusBoundary_*`，弱化但保留战斗区域边界。
- 中央区域新增 `ArenaCombatLaneMatte_*`，用低对比暗线辅助判断走位空间。
- 这些新增层全部为非发光材质，不使用高亮 bloom。

## 设计目的

- 让视线集中到中心战斗棋盘，接近参考图里“中央战斗区清晰、外围收边”的构图。
- 给敌人、Boss 技能、弹幕和拾取物留出更干净的背景。
- 避免继续靠发光线条堆视觉质量，降低玩家看不清敌人与弹幕的概率。
- 保持静态网格量可控，不增加每帧动态同步压力。

## Headless 验证

已通过：

- `SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=1672x941 meshes=1069 citadel_nodes=8`
- `SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.18 ambient=0.40 key=2.18 metal=0.74 rough=0.90 rim=true family=metal/energy/stone`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=69 meshes=5660 nodes=7295 projectiles=210 pickups=168 zones=31`
- `SURVIVOR_SMOKE_OK enemies=92 projectiles=62 pickups=40`

说明：本轮没有打开游戏 GUI，只使用 Godot headless。Godot dummy renderer 仍会输出 `Parameter "m" is null` 噪声，退出码为 0 且 OK 标记存在时按通过处理。
