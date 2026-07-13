# 技能爆点视觉更新

本次更新强化了短促技能脉冲 `Pulse` 的落地反馈，让爆炸、星落、虚空裂隙、护盾等瞬间效果更接近参考图右侧的高对比技能特效。

## 新增内容

- `Pulse` 新增 `PulseImpactSignature` 爆点签名层。
- 每个爆点签名包含：
  - `PulseImpactShockRing`：外圈冲击波。
  - `PulseImpactCore`：中心高光核心。
  - `PulseImpactGlyphTick`：按技能家族变化的冲击刻度。
- 爆点签名会随 pulse 生命周期扩散、旋转并淡出。
- pulse 材质淡出从“一层子节点”改为递归处理，后续嵌套特效不会残留得太硬。

## 覆盖家族

新增测试覆盖金色奖励、危险爆炸、护盾、虚空、毒、星体、海克斯等 pulse 家族。

## 验证

- `tests/survivor_pulse_visual_matrix.gd` 会直接生成多类 pulse 并检查爆点签名节点。
- `tests/survivor_headless_smoke.gd` 会在真实主场景流程里检查 `PulseImpactSignature` 是否出现。
