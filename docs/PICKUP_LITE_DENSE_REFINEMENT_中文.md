# 密集 XP Lite 压缩更新

日期：2026-07-03

## 目标

高压预算场景在新增多批 3D 标识层后接近 `9000` 节点上限。本轮不提高预算阈值，而是压缩密集 XP 的 lite 表现，保留可读性并释放后续美术空间。

## 已完成

- `scripts/survivor_3d_view.gd`
  - `LitePickupCore` 继续保留，保证密集 XP 仍然可见。
  - 低值 lite XP 不再生成地面细环，减少场面噪声，也降低与敌方弹幕地面警示的混淆。
  - `amount >= 8` 的 lite XP 保留 `LitePickupValueRing`。
  - `amount >= 10` 的 lite XP 保留 `LitePickupValueTick`。
  - 金币、治疗、护盾和高值 XP 仍走完整高级表现。

## 性能结果

- 调整前高压预算失败：`Visual budget exceeded node count: 9040 > 9000`
- 调整后通过：`SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=6832 nodes=8710 projectiles=210 pickups=167 zones=31`

## 测试覆盖

- `tests/survivor_pickup_visual_matrix.gd`
  - lite XP 继续要求存在 `LitePickupCore`。
  - 高值 XP、金币、治疗、护盾继续禁止降级。
- `tests/survivor_visual_budget_smoke.gd`
  - 高压场景继续检查 `LitePickupCore`。
  - 总节点数必须低于 `MAX_TOTAL_NODES = 9000`。

