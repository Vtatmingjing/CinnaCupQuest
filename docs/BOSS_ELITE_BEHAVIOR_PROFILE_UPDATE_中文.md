# Boss/精英行为差异批次记录

日期：2026-07-03

## 本批目标

把“像英雄/像虚空怪”的差异继续往实战推进，而不是只停留在模型或特效上。本批新增可测试的战斗 profile，让精英词缀和 Boss 的行为输出能被 headless 测试直接验证。

## 改动内容

- 精英词缀新增实际战斗输出：
  - 狂暴：触发冲刺时会打出 `F` 标签的短扇形爪击弹幕。
  - 壁垒：护盾被打破时会释放 `U` 标签的低速护盾碎片，并写入破防 profile。
  - 分裂：半血孵化时写入 `splitter_bloom_*` profile，并释放 `S` 标签分裂弹幕。
  - 宝藏：靠近玩家后进入逃逸状态，并向逃跑方向打出 `T` 标签的诱饵弹幕。
- Boss 新增战斗 profile 字段：
  - 科加斯风格：`devour_rupture`，坦克/范围压制。
  - 维克兹风格：`focus_laser`，远程激光压制。
  - 雷克塞风格：`burrow_charge`，潜地冲锋。
  - 卑尔维斯风格：`royal_swarm`，召唤/虫群压制。
- 3D 弹幕危险层补充分级：
  - `F`、`T` 进入普通危险层。
  - `U`、`S` 进入特殊危险层。
  - 它们会继续使用现有敌方弹幕地面车道、危险徽章和读图外壳。

## 测试覆盖

- `tests/survivor_elite_trait_behavior_matrix.gd`
  - 检查四类精英词缀的 profile、弹幕标签、召唤和移动状态。
- `tests/survivor_boss_behavior_matrix.gd`
  - 检查四个 Boss 的职业 role、攻击 profile、签名弹幕标签、弹幕速度/半径，以及卑尔维斯召唤。
- `tests/survivor_projectile_visual_matrix.gd`
  - 新敌方弹幕标签加入视觉矩阵，防止新机制退回不可读的普通弹体。

## 性能边界

这批没有新增常驻场景节点，只有在精英/Boss 实际触发技能时产生少量弹体；仍受现有 `MAX_PROJECTILES`、`MAX_ENEMIES` 和 3D LOD 预算约束。
