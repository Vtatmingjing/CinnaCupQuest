# 敌方弹幕航向读图更新

本轮继续强化敌方弹幕的 3D 可读性，重点解决高速混战中“弹幕方向不够明确”的问题。

## 新增内容

- `EnemyProjectileTrajectoryMarks`：挂在 `EnemyProjectileLane` 下的弹道标记组，跟随弹体方向和贴地轨迹一起移动。
- `EnemyProjectileHeadingArrow`：每发敌弹都有一个轻量航向箭头，提示危险推进方向。
- `EnemyProjectileRangeNotch`：完整敌弹额外显示分段刻度，Boss/特殊弹幕远看更像“危险技能轨迹”，不再像普通掉落物。
- lite 敌弹只保留航向箭头，不显示分段刻度，保证怪多弹多时不会把节点预算顶穿。

## 性能处理

- 航向箭头直接使用 mesh 节点命名，避免额外空节点。
- 完整敌弹保留更多刻度和侧翼，密集弹幕自动走 lite 分支。
- 本轮预算回测中，视觉预算为 `meshes=6930 nodes=8735`，低于 `7200/9000` 上限。

## 验证

- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=9 meshes=811`
- `SURVIVOR_SMOKE_OK enemies=83 projectiles=62 pickups=52`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=6930 nodes=8735 projectiles=210 pickups=167 zones=31`
