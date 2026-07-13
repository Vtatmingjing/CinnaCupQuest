# 敌人战斗意图层更新

日期：2026-07-03

## 目标

敌人已经有弱点、剪影、Boss 阶段和精英特质提示，但普通虚空单位在顶视角下仍容易只被看成“不同颜色的小怪”。本轮新增统一的战斗意图层，让玩家能更快判断敌人接下来偏向扑击、喷吐、钻地、护甲压迫、激光聚焦或召唤。

## 已完成

- `scripts/survivor_3d_view.gd`
  - 新增 `EnemyCombatIntentProfile`，只挂在非 lite 敌人模型上。
  - 写入 `kind`、`boss`、`elite`、`combat_family`、`detail_node` metadata。
  - 固定子节点：
    - `EnemyCombatIntentFrame`
    - `EnemyCombatIntentCore`
    - `EnemyCombatIntentMeter`
  - 敌人类型映射：
    - `voidling`：`EnemyCombatIntentSwarmBite`
    - `skitter`：`EnemyCombatIntentPounceClaws`
    - `spitter`：`EnemyCombatIntentAcidSpit`
    - `burrower` / `boss_reksai`：`EnemyCombatIntentBurrowCharge`
    - `carapace`：`EnemyCombatIntentArmorGuard`
    - `void_eye` / `boss_velkoz`：`EnemyCombatIntentVoidFocus`
    - `rift_crystal`：`EnemyCombatIntentRiftSummon`
    - `boss_cho`：`EnemyCombatIntentDevourRupture`
    - `boss_belveth`：`EnemyCombatIntentSwarmWings`
  - 同步阶段根据攻击、冲锋、召唤计时轻量脉冲 `EnemyCombatIntentMeter`，不改变战斗数值。

## 性能策略

- 密集场景下普通小怪走 lite 模型，明确禁止携带 `EnemyCombatIntentProfile`。
- Boss 和精英仍保留该层，因为它们是战斗决策重点。
- 为补回新增敌人意图层的预算，lite 敌方弹体保留黑核、轨迹和分离环，但不再生成内部 `EnemyProjectileHotCore` 小球。
- 本轮不提高 `survivor_visual_budget_smoke.gd` 的预算阈值。

## 测试覆盖

- `tests/survivor_enemy_visual_matrix.gd`
  - 普通非 lite 敌人、精英和 Boss 必须存在 `EnemyCombatIntentProfile`。
  - 检查 metadata 和每个敌人对应的 detail 节点。
  - lite 小怪必须禁止出现该层。
- `tests/survivor_headless_smoke.gd`
  - 主场景真实初始化后必须能找到 `EnemyCombatIntentProfile`。

## 验证结果

- Godot check-only：通过。
- 敌人视觉矩阵：`SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=1540`
- 弹体视觉矩阵：`SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=9 meshes=858`
- 主场景 smoke：`SURVIVOR_SMOKE_OK enemies=89 projectiles=58 pickups=46`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=67 meshes=6834 nodes=8717 projectiles=210 pickups=167 zones=31`
- 完整回归：`FULL_SURVIVOR_REGRESSION_OK tests=21`
