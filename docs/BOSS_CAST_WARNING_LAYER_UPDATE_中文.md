# Boss 施法预警层增强记录

日期：2026-07-02

## 本轮目标

继续把战斗表现往“海克斯虚空效果图”方向推进，重点增强 Boss 技能释放前的危险读法。之前 Boss 已经有专属攻击图案，但整体偏薄，这一轮补上倒计时预警框和四种 Boss 的专属危险细节。

## 已完成

- `BossCastWarningFrame`
  - 新增共享 Boss 施法倒计时框。
  - 带 4 个 `BossCastCountdownPip`，随施法进度逐步亮起。
  - 用旋转、缩放和闪烁强调“马上释放”的读法。
- BossPressureRig 懒加载
  - 无 Boss 的高压小怪/弹幕场景不再常驻整套 Boss 仪式节点。
  - 出现活 Boss 后再构建 `BossPressureRig`，保留 Boss 战表现，同时降低普通战斗预算压力。
- `boss_cho`
  - 新增 `BossCastChoImpactTeeth`。
  - 让击飞/地裂类攻击更像从地面咬合爆开。
- `boss_velkoz`
  - 新增 `BossCastVelkozEyeCore`。
  - 强化扇形激光前的眼核聚焦感。
- `boss_reksai`
  - 新增 `BossCastReksaiTremorWake`。
  - 让冲锋/潜地路线两侧有震波裂纹。
- `boss_belveth`
  - 新增 `BossCastBelvethRoyalNeedles`。
  - 强化双翼横扫和女皇感的针刺轮廓。

## 测试覆盖

- `tests/survivor_boss_cast_pattern_matrix.gd`
  - 检查无 Boss 时 `BossPressureRig` 不会提前构建。
  - 检查 `BossCastWarningFrame` 和倒计时 pip。
  - 检查四个 Boss 的专属 detail 节点。
  - 检查非当前 Boss 图案不会泄漏显示。
- `tests/survivor_arena_visual_matrix.gd`
  - 检查静态 arena 不常驻 `BossPressureRig`。
- `tests/survivor_headless_smoke.gd`
  - 在真实主场景烟测中检查 Vel'Koz 施法时的倒计时框和眼核。

## 验证结果

- Godot check-only：通过。
- Boss 施法专项：`SURVIVOR_BOSS_CAST_PATTERN_MATRIX_OK bosses=4 meshes=55`
- 主场景烟测：`SURVIVOR_SMOKE_OK`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=6868 nodes=8725 projectiles=210 pickups=166 zones=31`
- 完整后台回归：`FULL_SURVIVOR_REGRESSION_OK tests=17`

## 后续建议

- 下一轮可以继续打磨精英怪非 Boss 的特殊招式前摇，例如分裂怪、护盾怪、宝藏精英分别有自己的地面警告。
- 如果继续增加常驻 3D 节点，需要同步做 LOD 或压缩旧节点，保持 `nodes < 9000`。
