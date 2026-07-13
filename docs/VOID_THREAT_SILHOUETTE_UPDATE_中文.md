# 虚空威胁剪影更新

本轮重点强化精英怪和 Boss 的压迫感，让它们不只是“更大的紫色怪”，而是有更明确的顶视角轮廓和攻击意图。

## 改动

- 新增 `VoidThreatSilhouetteRig`，只挂在精英和 Boss 身上，不给轻量小怪增加负担。
- 统一拆成三个子节点：
  - `VoidThreatGroundSigil`：脚下虚空/海克斯威胁纹。
  - `VoidThreatBackSpines`：背刺/轮廓刺，强化顶视角剪影。
  - `VoidThreatAttackTell`：攻击意图 motif。
- Boss 专属攻击意图：
  - `boss_cho`：`VoidThreatBossChoMaw`，突出裂地和巨口吞噬感。
  - `boss_velkoz`：`VoidThreatBossVelkozFan`，突出激光扇面。
  - `boss_reksai`：`VoidThreatBossReksaiLane`，突出地道冲刺线。
  - `boss_belveth`：`VoidThreatBossBelvethWings`，突出翼扫范围。
- 精英怪按特质生成 `VoidThreatEliteTraitMotif`，用于区分狂暴、壁垒、分裂、宝藏。
- 运行时同步已接入 `_sync_enemies()`，威胁剪影会轻微旋转和脉冲。

## 验证

- 更新 `tests/survivor_enemy_visual_matrix.gd`：
  - 精英和 Boss 必须有 `VoidThreatSilhouetteRig`。
  - 必须包含 `VoidThreatGroundSigil`、`VoidThreatBackSpines`、`VoidThreatAttackTell`。
  - Boss 必须包含对应的专属攻击意图节点。
  - 轻量小怪禁止携带 `VoidThreatSilhouetteRig`。
- 单项敌人矩阵：
  - `SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=1258`
- 完整 17 项后台回归：
  - `SURVIVOR_VISUAL_BUDGET_OK enemies=64 meshes=6785 nodes=8662 projectiles=210 pickups=167 zones=31`
  - `FULL_SURVIVOR_REGRESSION_OK tests=17`

## 性能

- 敌人视觉矩阵总 mesh 从约 `1181` 增至 `1258`，增量集中在精英和 Boss。
- 实战高压预算仍低于 `9000` 节点上限，最新为 `8662`，保留约 338 个节点余量。
