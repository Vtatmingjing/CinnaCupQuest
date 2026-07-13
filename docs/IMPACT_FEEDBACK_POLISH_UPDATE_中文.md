# 打击反馈质感增强记录

日期：2026-07-02

## 本轮目标

继续把战斗表现往“海克斯虚空效果图”方向推进，重点处理命中、击杀和脉冲三类短生命周期特效，让它们更像带材质层次的 3D 战斗反馈，而不是简单几何体闪一下。

## 已完成

- 命中火花新增 `HitSparkDirectionalShock`：
  - 增加方向性冲击核心，让玩家更容易看出攻击命中方向。
  - 完整模式下带左右冲击翼，爆炸/魔法命中会更饱满。
- 命中火花新增 `HitSparkMaterialShardRig`：
  - 爆炸命中带金色碎片与余烬。
  - 魔法命中带六边形切面与小晶体。
  - 毒性命中带孢子与拖尾。
  - 虚空命中带暗色裂片与紫色裂纹。
- 击杀爆发新增 `EnemyDeathAfterimageRig`：
  - 死亡后留下短暂残影环、魂核和余烬。
  - 精英/Boss 击杀保留奖励皇冠，并额外强化金色回响。
  - Boss 死亡新增 `EnemyDeathBossEcho`，视觉上更像高价值目标被击破。
- 脉冲冲击新增 `PulseImpactFacetRig`：
  - 地面脉冲从纯环形升级为带符文切面的冲击效果。
  - 不同脉冲类型使用不同切面：虚空裂片、星体尖刺、毒性孢子、危险爆发等。
- 高压场景加入命中火花自适应 LOD：
  - 前 6 个普通命中火花保留完整碎片层。
  - 命中火花过多时，后续普通火花自动切到轻量碎片，保留读法并降低节点压力。
  - 精英/高优先级命中仍保留完整效果。

## 测试覆盖

- `tests/survivor_hit_spark_visual_matrix.gd`
  - 新增对 `HitSparkDirectionalShock`、`HitSparkMaterialShardRig`、`HitSparkMaterialShard0` 的检查。
  - 新增 dense LOD 路径检查，防止高压优化失效。
- `tests/survivor_death_burst_visual_matrix.gd`
  - 新增对 `EnemyDeathAfterimageRig`、`EnemyDeathAfterimageRing`、`EnemyDeathSoulCore`、`EnemyDeathEmber0` 的检查。
  - Boss 额外检查 `EnemyDeathBossEcho`。
- `tests/survivor_pulse_visual_matrix.gd`
  - 新增对 `PulseImpactFacetRig`、`PulseImpactFacet0` 的检查。

## 验证结果

- Godot check-only：通过。
- 命中专项：`SURVIVOR_HIT_SPARK_VISUAL_MATRIX_OK cases=4 meshes=121`
- 死亡专项：`SURVIVOR_DEATH_BURST_VISUAL_MATRIX_OK cases=3 meshes=124`
- 脉冲专项：`SURVIVOR_PULSE_VISUAL_MATRIX_OK pulses=7 meshes=311`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=66 meshes=6982 nodes=8895 projectiles=210 pickups=167 zones=31`
- 完整后台回归：`FULL_SURVIVOR_REGRESSION_OK tests=17`

## 后续建议

- 下一轮可以继续打磨“攻击前摇/技能施法读条”，让每个英雄的释放瞬间更有专属识别度。
- 场地中央和边缘装饰已经有基础，可以继续做更强的高度层次和材质分区。
- 目前节点预算接近上限，后续每次加特效都应同步考虑 LOD 或对象合批。
