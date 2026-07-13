# Boss 专属领域层更新

日期：2026-07-03

## 目标

Boss 之前已有施法图案、阶段状态和模型标识，但场地层面的压迫感仍偏通用。本轮在 `BossPressureRig` 内新增 Boss 专属领域层，让 Boss 出场时不仅角色模型不同，脚下大范围领域也能对应到该 Boss 的机制。

## 已完成

- `scripts/survivor_3d_view.gd`
  - 新增 `BossDomainProfileRig`，挂在 `ArenaRitual` 下，只在 Boss 存在时显示。
  - 每个 Boss 预建一个领域节点，同步时只显示当前 Boss，防止视觉串台。
  - 固定子节点：
    - `BossDomainFrame`
    - `BossDomainPressureCore`
    - `BossDomainThreatMeter`
  - Boss 映射：
    - 科加斯：`BossDomainChoRupture` / `BossDomainChoRuptureMaw`
    - 维克兹：`BossDomainVelkozFocus` / `BossDomainVelkozFocusFan`
    - 雷克塞：`BossDomainReksaiBurrow` / `BossDomainReksaiTunnelLane`
    - 卑尔维斯：`BossDomainBelvethSwarm` / `BossDomainBelvethWingCrown`
  - 领域会根据 Boss 血量压力和施法进度做轻量脉冲，不改变伤害、碰撞或刷怪逻辑。

## 测试覆盖

- `tests/survivor_boss_cast_pattern_matrix.gd`
  - 检查 `BossDomainProfileRig` 可见。
  - 检查当前 Boss 的领域节点、`domain_type`、`detail_node` metadata。
  - 检查其它 Boss 的领域节点不会在当前 Boss 测试里泄漏显示。
- `tests/survivor_headless_smoke.gd`
  - 在真实主场景 Velkoz Boss 施法过程中确认领域层可见。

## 验证结果

- Godot check-only：通过。
- Boss 施法/领域矩阵：`SURVIVOR_BOSS_CAST_PATTERN_MATRIX_OK bosses=4 meshes=151`
- 主场景 smoke：`SURVIVOR_SMOKE_OK enemies=88 projectiles=59 pickups=44`
- 高压预算复跑：`SURVIVOR_VISUAL_BUDGET_OK`，节点区间约 `8700-8763 / 9000`
- 完整回归：`FULL_SURVIVOR_REGRESSION_OK tests=21`
