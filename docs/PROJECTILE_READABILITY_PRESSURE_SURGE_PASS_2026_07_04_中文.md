# 弹幕可读性与压力波更新
日期：2026-07-04

## 目标

针对试玩反馈继续处理三类问题：

- 敌方弹幕不够明显，容易和经验/奖励混淆。
- 场面光效多时容易变成光污染。
- 中后期缺少持续生存压力，玩家处理完一波后容易进入低挑战循环。

## 改动

### 敌方弹幕半径标尺

- 复用 `EnemyProjectileThreatOutline` 作为敌方弹幕碰撞半径标尺。
- 新增元数据：
  - `collision_radius_marker = true`
  - `material_grade = low_glare_enemy_collision_radius`
  - `hazard_shape_language = black_red_collision_radius`
  - `pickup_confusion_guard = true`
- 同步动画里给该标尺增加低幅度脉冲和旋转，让它能从经验晶体/奖励光点中分离出来。
- 没有额外增加 mesh，避免 210 弹幕场景预算爆掉。

### 高密度弹幕 LOD

- 删除高密度 lite 敌方弹幕里重复的菱形核心。
- lite 弹幕保留危险外轮廓、暗底、方向箭头、威胁等级和形状编码。
- 目标是让危险信息保留，但减少密集场景 mesh 数。

### 中后期压力波

- 新增 `pressure_surge_timer`。
- 118 秒后开始周期性触发虚空压力波。
- 每次压力波会刷出至少 1 个精英小队长和一组护卫。
- 260 秒后，如果敌人容量允许，压力波可升级为 2 个精英。
- Boss 存活时护卫数量额外增加，避免 Boss 战后半段过空。

## 测试覆盖

已更新：

- `res://tests/survivor_projectile_visual_matrix.gd`
  - 要求敌方弹幕的 `EnemyProjectileThreatOutline` 同时承担碰撞半径标尺职责。
  - 要求该标尺为低眩光、非发光、带拾取物混淆保护。
- `res://tests/survivor_difficulty_curve_matrix.gd`
  - 新增压力波导演检查。
  - 要求 150 秒压力波能生成精英小队和足够护卫。
- `res://tests/survivor_glare_budget_matrix.gd`
  - 将敌方弹幕威胁外框纳入危险 guard 材质检查。

## 当前验证

- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1668`
- `SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=90 timers=survival_pressure_v5 spawn_steps=challenge_v4 surge=elite_squad enemy_growth=harder_v4 attacks=pressure`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=90 meshes=7009 nodes=8955 projectiles=210 pickups=168 zones=31`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7371 models=46 emission=0.094 alpha=0.353`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=42 pickups=32`
- headless 初始化：退出码 0
