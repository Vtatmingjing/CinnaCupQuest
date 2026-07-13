# 命中来源识别层增强记录

日期：2026-07-03

## 本轮目标

上一轮已经把玩家弹道拆出职业/英雄识别层。本轮把同一套识别继续延伸到命中爆点，减少“打出去能分辨，命中后又变成同一种光效”的割裂感。

## 已完成

- 新增 `HitSparkSourceProfile`
  - 只挂在非 dense LOD 命中模型上。
  - dense LOD 命中火花继续保持轻量，不生成该重节点。
  - 写入 `source_champion`、`profile_family`、`profile_role`、`detail_node` metadata。
  - 在同步阶段随命中生命周期做轻量缩放、旋转和脉冲。
- 命中来源 detail
  - 金克丝爆破：`HitSparkProfileRocketBurst`
  - 赛娜灵魂炮击：`HitSparkProfileSoulPierce`
  - 莎弥拉决斗斩击：`HitSparkProfileDuelistCut`
  - 维克托海克斯灼痕：`HitSparkProfileHexcoreBurn`
  - 霞羽刃钉刺：`HitSparkProfileFeatherPin`
  - 提莫毒性绽放：`HitSparkProfilePoisonBloom`
  - 奥瑞利安·索尔星体坍缩：`HitSparkProfileStarCollapse`
  - 莫德凯撒领域重击：`HitSparkProfileRealmCrush`

## 测试覆盖

- `tests/survivor_hit_spark_visual_matrix.gd`
  - 覆盖 7 类命中来源。
  - 检查 `HitSparkSourceProfile`、metadata、profile ring、class mark 和专属 detail 节点。
  - dense LOD 明确禁止出现 `HitSparkSourceProfile`。
- `tests/survivor_headless_smoke.gd`
  - 真实战斗循环中要求命中火花同时出现 `HitSparkImpactSignature`、`HitSparkVfxDecal` 和 `HitSparkSourceProfile`。

## 验证结果

- Godot check-only：通过。
- 命中视觉矩阵：`SURVIVOR_HIT_SPARK_VISUAL_MATRIX_OK cases=7 meshes=262`
- 主场景烟测：`SURVIVOR_SMOKE_OK enemies=89 projectiles=58 pickups=46`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=66 meshes=6845 nodes=8729 projectiles=210 pickups=167 zones=31`
- 完整回归：`FULL_SURVIVOR_REGRESSION_OK tests=17`

## 后续建议

- 下一步可以处理范围区域 `Zone` 的英雄来源识别，让提莫蘑菇、维克托重力场、龙王奇点、莫德领域在地面持续效果上继续保持差异。
- 现有预算仍有空间，但节点上限更紧，后续新增长期存在视觉物时应优先做 LOD 或复用材质/节点。
