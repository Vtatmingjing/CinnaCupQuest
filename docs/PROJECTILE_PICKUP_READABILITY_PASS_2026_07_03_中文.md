# 敌方弹幕与拾取物区分更新

本批次继续处理“敌人弹幕不明显、容易和经验混淆”的问题。改动方向不是继续加亮弹幕，而是给敌方弹幕增加固定的红黑危险形状语言。

## 已改内容

- `EnemyProjectileReadabilityShell` 新增 `pickup_confusion_guard = true` 和 `hazard_shape_language = red_black_triangle`。
- 所有敌方弹幕，包括 lite 弹幕，新增：
  - `EnemyProjectileDangerBackplate`：黑色三角危险背板。
  - `EnemyProjectileDangerNeedle`：红色针形方向轮廓。
- 同步动画中让背板和针形轮廓轻微旋转/脉冲，保持低成本可读性。
- 敌方弹幕材质发光缩放从 `0.18` 降到 `0.15`，发光上限从 `0.28` 降到 `0.24`，避免用亮度硬压画面。

## 测试覆盖

- `tests/survivor_projectile_visual_matrix.gd`：full/lite 敌方弹幕必须带危险背板、危险针形轮廓和 `pickup_confusion_guard` metadata。
- `tests/survivor_headless_smoke.gd`：实战 smoke 场景必须能找到 `EnemyProjectileDangerBackplate` 和 `EnemyProjectileDangerNeedle`。
- `tests/survivor_material_quality_matrix.gd`：继续确认全局低眩光参数。
- `tests/survivor_visual_budget_smoke.gd`：高压场景通过，最新结果为 `SURVIVOR_VISUAL_BUDGET_OK enemies=80 meshes=6432 nodes=8243 projectiles=210 pickups=168 zones=31`。

## 设计约束

- 经验/金币保持拾取物频道；敌方弹幕保持 `enemy_hazard` 频道。
- 敌方弹幕通过红黑三角/针形语言区分，拾取物通过晶体/金币/宝箱语言区分。
- lite 弹幕也必须有基础危险背板，保证怪潮密集时不会丢失危险识别。
