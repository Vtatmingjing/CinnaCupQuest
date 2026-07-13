# 可读性、贴图对齐与生存压力更新

本轮针对试玩反馈里的三个问题做了收敛：选择界面/升级界面贴图不齐、场内光污染过亮、整体难度缺少生存挑战。

## 贴图与 UI 对齐

- 英雄选择、升级/海克斯选择、商店卡片现在统一走 `_layout_choice_media()` 布局。
- 切换不同卡片类型时会先清理 `TextureRect` 的旧最小尺寸，避免头像尺寸残留把升级图标撑偏。
- HUD 视觉矩阵新增图片中心、背景框中心、越界检查，防止后续改 UI 再出现贴图错位。

## 3D 可读性

- 全局环境亮度下调：
  - glow intensity：`0.24 -> 0.18`
  - ambient energy：`0.46 -> 0.40`
  - tonemap exposure：`0.96 -> 0.90`
  - 主光、补光、虚空边缘光、金色边缘光同步压低。
- 透明发光材质整体降亮，敌方弹幕、拾取物、区域特效、贴花的 emission 都进一步收敛。
- 单位模型新增可测试的 `GroundedContactShadow` 和 `GroundedContactCore`，让英雄、普通敌人、精英和 Boss 更有接地感，不再像漂在发光贴片上。
- 敌方弹幕仍保留黑芯、红色分离环和危险轮廓，用来和 XP/金币做视觉区分。

## 难度曲线

- Boss 出场时间从 `270s` 提前到 `240s`。
- 刷怪间隔从 `max(0.22, 1.06 - elapsed * 0.0032)` 调整为 `max(0.18, 0.92 - elapsed * 0.0035)`。
- 精英间隔从 `max(12.5, 23.0 - wave * 0.75)` 调整为 `max(10.5, 19.0 - wave * 0.75)`。
- 刷怪包基础数量提升，中后期波次额外增压。
- 普通敌人中后期生命、速度、伤害成长提高，Boss 生命和伤害提高。

## Headless 验证

已通过以下 Godot headless 验证：

- `SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=9 shop_cards=3`
- `SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.18 ambient=0.40 key=2.18 metal=0.74 rough=0.90 rim=true family=metal/energy/stone`
- `SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=1877`
- `SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=2424 ability_atlas=1536x1024`
- `SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=240 timers=survival_pressure spawn_steps=challenge enemy_growth=late`
- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1319`
- `SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=159`
- `SURVIVOR_ROGUELIKE_ROUTE_MATRIX_OK fates=4 roll_mix=forced`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=66 meshes=5640 nodes=7264 projectiles=210 pickups=167 zones=31`
- `SURVIVOR_SMOKE_OK enemies=92 projectiles=65 pickups=42`

说明：本轮没有打开游戏 GUI，只使用 Godot headless 初始化和测试。headless dummy renderer 仍会输出 `Parameter "m" is null`，只要退出码为 0 且 OK 标记存在，就按通过处理。
