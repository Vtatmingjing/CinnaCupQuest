# Boss 阶段状态反馈层记录
日期：2026-07-03

## 本轮目标

Boss 已经有专属模型、施法图案和全局压力仪式，但模型本体对“当前阶段状态”的表达还不够直接。本轮新增 Boss 阶段状态反馈层，让玩家能从 Boss 身上读到低血狂暴、施法窗口和专属压力类型。

## 已完成

- 新增 `BossPhaseStateRig`
  - 挂在 Boss 模型本体上，默认隐藏。
  - 写入 `boss_kind` 和 `detail_node` metadata。
  - 只复用低面数几何体，不增加敌人、投射物、粒子或贴图加载。
- 通用状态节点
  - `BossPhaseFrame`：Boss 状态框架。
  - `BossPhaseMeter`：根据当前压力强度缩放。
  - `BossPhaseCastState`：Boss 即将出招时显示。
  - `BossPhaseEnrageState`：低血狂暴阶段显示。
- 四个 Boss 专属状态节点
  - `BossPhaseChoDevourState`：科加斯吞噬/裂地压力。
  - `BossPhaseVelkozFocusState`：维克兹聚焦激光压力。
  - `BossPhaseReksaiBurrowState`：雷克塞钻地冲锋压力。
  - `BossPhaseBelvethSwarmState`：卑尔维斯女皇群翼/召唤压力。

## 测试覆盖

- `tests/survivor_enemy_visual_matrix.gd`
  - 校验四个 Boss 模型都具备 `BossPhaseStateRig`。
  - 校验通用状态节点和 Boss 专属状态节点具备 mesh 内容。
- 新增 `tests/survivor_boss_phase_state_visual_matrix.gd`
  - 强制四个 Boss 进入低血、施法和专属压力状态。
  - 校验 `BossPhaseStateRig`、`BossPhaseCastState`、`BossPhaseEnrageState` 和专属 detail 节点都会变为可见。
- `tests/survivor_headless_smoke.gd`
  - 在真实主场景 smoke 中确认 `BossPhaseStateRig` 存在。

## 当前验证

- Godot check-only：`survivor_3d_view.gd` 通过。
- 敌人视觉矩阵：`SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=1426`
- Boss 阶段状态视觉矩阵：`SURVIVOR_BOSS_PHASE_STATE_VISUAL_MATRIX_OK bosses=4`
- 主场景 smoke：`SURVIVOR_SMOKE_OK enemies=83 projectiles=66 pickups=48`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=6961 nodes=8818 projectiles=210 pickups=166 zones=31`
- 完整后台回归：`FULL_SURVIVOR_REGRESSION_OK tests=21`

## 后续建议

- 下一批可以把 Boss 阶段状态和实际攻击节奏继续联动，例如科加斯低血更偏吞噬压迫、维克兹低血激光更聚焦、雷克塞低血更频繁钻地、卑尔维斯低血更偏召唤与扇形扫击。
- 若继续追求效果图质量，Boss 状态层适合后续替换成统一图集贴花和少量动画材质，比继续堆几何体更接近商业手绘质感。
