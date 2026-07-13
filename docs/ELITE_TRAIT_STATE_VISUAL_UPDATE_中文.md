# 精英词缀行为状态反馈层记录
日期：2026-07-03

## 本轮目标

上一批已经让四类精英词缀拥有真实行为差异。本轮继续把这些行为转成更清晰的 3D 状态反馈，让玩家能在战斗中读到“它现在正在做什么”，而不是只看到静态词缀标识。

## 已完成

- 新增 `EliteTraitBehaviorStateRig`
  - 挂在已有 `EliteTraitTelegraphRig` 下，默认隐藏。
  - 写入 `elite_trait` 和 `state_node` metadata，方便测试和后续维护。
  - 复用低面数盒体、圆柱和球体，不增加敌人、投射物或粒子对象。
- 狂暴状态
  - 新增 `EliteTraitStateFrenzyDash`。
  - 当 `dash_timer` 激活时显示冲刺斩痕和前冲尖刺，配合 `ChargeLane` 表达冲脸压力。
- 壁垒状态
  - 新增 `EliteTraitStateBulwarkGuardPips` 和 `EliteTraitStateBulwarkBreak`。
  - 护盾层存在时显示守护 pip；破口窗口中显示裂盾标识。
- 分裂状态
  - 新增 `EliteTraitStateSplitterBloom`。
  - 半血临界或已经孵化后显示种子爆开结构，提示额外小怪压力。
- 宝藏状态
  - 新增 `EliteTraitStateTreasureFlee`。
  - 逃逸状态中显示金币核心和撤退箭头，提示这是高价值追逐目标。

## 测试覆盖

- `tests/survivor_enemy_visual_matrix.gd`
  - 校验每类精英都具备 `EliteTraitBehaviorStateRig`。
  - 校验 `EliteTraitStateHalo`、`EliteTraitStateMeter` 和专属状态节点存在并具备 mesh 内容。
- 新增 `tests/survivor_elite_trait_state_visual_matrix.gd`
  - 强制四种运行时状态：狂暴冲刺、壁垒破口、分裂半血、宝藏逃逸。
  - 校验状态层会变为可见，并且只有对应状态节点可见。
- `tests/survivor_headless_smoke.gd`
  - 在真实主场景 smoke 中确认 `EliteTraitBehaviorStateRig` 存在。

## 当前验证

- Godot check-only：`survivor_3d_view.gd` 通过。
- 敌人视觉矩阵：`SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=1354`
- 精英状态视觉矩阵：`SURVIVOR_ELITE_TRAIT_STATE_VISUAL_MATRIX_OK traits=4`
- 主场景 smoke：`SURVIVOR_SMOKE_OK enemies=90 projectiles=56 pickups=46`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=6957 nodes=8826 projectiles=210 pickups=167 zones=31`
- 完整后台回归：`FULL_SURVIVOR_REGRESSION_OK tests=20`

## 后续建议

- 下一步可以把这些状态反馈接入音效和短文本提示，例如“壁垒破口”“宝藏逃跑”，但要限制浮字频率，避免重新造成画面混乱。
- 如果继续向效果图质量推进，后续优先把这类状态符号统一成一张图集贴花，能明显提升质感，同时比继续堆几何体更省预算。
