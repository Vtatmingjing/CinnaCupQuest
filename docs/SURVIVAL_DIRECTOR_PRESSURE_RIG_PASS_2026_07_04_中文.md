# 生存压力导演层更新
日期：2026-07-04

## 目标

继续处理“中后期不够紧张”和“玩家不知道下一波压力什么时候来”的问题。
本批没有继续给单个怪物堆模型，而是在场地层增加一个低眩光压力波预警，让玩家在强度提升前看到明确的战斗读秒。

## 改动

### 场地级压力波预警

新增 `SurvivalDirectorPressureRig`：

- 平时隐藏。
- 压力波倒计时进入 10 秒内显示。
- Boss 存活时预警窗口扩大到 14 秒。
- 显示压力波环、倒计时指针、精英小队标记和 Boss 升级条。
- 使用低发光/暗底材质，不参与光污染。

关键元数据：

- `combat_visual_channel = survival_pressure_warning`
- `material_grade = low_glare_survival_director`
- `elite_squad_warning = true`
- `boss_escalation_warning = true`
- `surge_readiness`
- `next_surge_timer`

### 高密度弹幕预算保护

高密度 lite 敌方弹幕继续保留：

- 危险外轮廓
- 暗底区分
- 方向箭头
- 威胁形状编码

但 `EnemyProjectileDangerRig` 和 `EnemyProjectileThreatBadge` 在 lite 模式下改为语义节点，不再生成额外 mesh。
这样不会削弱危险信息，但能让 210 弹幕压力场景回到预算内。

## 测试覆盖

新增：

- `res://tests/survivor_pressure_director_visual_matrix.gd`

验证内容：

- 压力波倒计时临近时 `SurvivalDirectorPressureRig` 必须显示。
- readiness 元数据必须正确。
- 必须包含压力波环、倒计时指针、精英标记和 Boss 升级条。
- 该层固定为 6 mesh / 7 node。
- 材质必须低眩光。

## 当前验证

- `SURVIVOR_PRESSURE_DIRECTOR_VISUAL_MATRIX_OK meshes=6 nodes=7 readiness=0.400`
- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1643`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=6371 nodes=8159 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7377 models=46 emission=0.094 alpha=0.353`
- `SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=90 timers=survival_pressure_v5 spawn_steps=challenge_v4 surge=elite_squad enemy_growth=harder_v4 attacks=pressure`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=40 pickups=31`
- headless 初始化：退出码 0
