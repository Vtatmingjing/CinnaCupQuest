# 精英词缀战斗行为增强记录
日期：2026-07-03

## 本轮目标

上一轮已经给四类精英加了意图识别层，但实际战斗差异还偏薄。这轮把“狂暴、壁垒、分裂、宝藏”从视觉标签推进到可验证的行为差异，让玩家在战斗中能更快感到这只精英到底危险在哪里、值不值得优先处理。

## 已完成

- 狂暴精英
  - 新增短冲刺状态，触发后会压缩攻击前摇并沿玩家方向突进。
  - 3D 视图中复用 `ChargeLane`，非冲刺类怪物获得狂暴词缀时也能显示冲刺路线。
- 壁垒精英
  - 新增 `bulwark_guard` 护盾层。
  - 护盾被打穿后进入 `bulwark_break_timer` 破口窗口，期间承受更高伤害。
  - 3D 意图层会读取破口窗口并提高脉冲强度。
- 分裂精英
  - 半血时触发一次 `splitter_spawned` 孵化，额外请求 2 只虚空小怪。
  - 死亡时仍保留原有分裂奖励/压力，形成“半血一次、死亡一次”的清晰节奏。
  - 3D 意图层会在半血前后提高分裂读法。
- 宝藏精英
  - 新增 `treasure_flee_timer`，靠近玩家时会进入短逃逸状态。
  - 逃逸期间移动方向远离玩家，攻击节奏略保守，更像高价值追逐目标。
  - 3D 意图层会读取逃逸状态，强化宝藏目标提示。

## 测试覆盖

- 新增 `tests/survivor_elite_trait_behavior_matrix.gd`
  - 验证狂暴精英会启动冲刺、写入冲刺方向并压缩攻击前摇。
  - 验证壁垒精英会消耗护盾层、打开破口窗口，并在破口期间提高受伤。
  - 验证分裂精英半血会请求 2 只 `voidling`。
  - 验证宝藏精英靠近玩家会进入逃逸状态，并实际拉开距离。
- 保留 `tests/survivor_enemy_visual_matrix.gd`
  - 继续验证精英意图节点和敌人视觉结构完整。

## 当前验证

- Godot check-only：`survivor_enemy.gd`、`survivor_main.gd`、`survivor_3d_view.gd` 通过。
- 精英行为矩阵：`SURVIVOR_ELITE_TRAIT_BEHAVIOR_MATRIX_OK traits=4`
- 敌人视觉矩阵：`SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=1314`
- 主场景 smoke：`SURVIVOR_SMOKE_OK enemies=89 projectiles=60 pickups=47`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=6918 nodes=8764 projectiles=210 pickups=167 zones=31`
- 完整后台回归：`FULL_SURVIVOR_REGRESSION_OK tests=19`

## 后续建议

- 下一批可以把这些行为进一步接到更清晰的 HUD/音效反馈，例如“壁垒破口”“分裂孵化”“宝藏逃跑”的短提示。
- 目前分裂半血会增加少量敌人压力，已通过 smoke 和预算；后续若继续加强分裂词缀，需要同步检查 `MAX_ENEMIES` 和低端设备预算。
