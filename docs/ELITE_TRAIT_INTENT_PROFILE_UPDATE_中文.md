# 精英词缀意图识别层增强记录
日期：2026-07-03

## 本轮目标

继续把非 Boss 精英怪从“有特效标签”推进到“玩家能读懂威胁/奖励意图”。这轮没有增加新的怪物数量，而是在现有 `EliteTraitTelegraphRig` 内补一层低成本几何识别符，让狂暴、壁垒、分裂、宝藏四类精英在混战中更容易区分。

## 已完成

- 新增 `EliteTraitIntentProfile`
  - 挂在每个 `EliteTraitTelegraphRig` 下面。
  - 写入 `elite_trait`、`intent_type`、`detail_node` metadata，方便自动化测试和后续维护。
  - 包含 `EliteTraitIntentFrame` 与 `EliteTraitIntentPip`，用于统一读法。
  - 跟随精英前摇 urgency 做缩放、旋转和亮度脉冲。
- 四类词缀专属意图节点
  - `EliteTraitIntentFrenzyRush`：用冲刺斩痕表达高速近身压力。
  - `EliteTraitIntentBulwarkBreak`：用六边盾面与裂线表达护盾破口。
  - `EliteTraitIntentSplitterBloom`：用中心种子和侧向分裂种子表达死亡后分裂压力。
  - `EliteTraitIntentTreasureReward`：用金色宝匣结构表达高价值奖励目标。
- 性能处理
  - 只复用低面数 Cylinder/Sphere/Box 几何体，不引入贴图加载。
  - 节点挂在已有精英前摇结构内，不扩大刷怪数量或长期粒子预算。

## 测试覆盖

- `tests/survivor_enemy_visual_matrix.gd`
  - 校验四类精英均生成 `EliteTraitIntentProfile`。
  - 校验 `elite_trait`、`intent_type`、`detail_node` metadata。
  - 校验 `EliteTraitIntentFrame`、`EliteTraitIntentPip` 与专属 detail 节点具备 mesh 内容。
- `tests/survivor_headless_smoke.gd`
  - 在真实主场景 smoke 中确认精英词缀意图层存在。
- `tests/survivor_visual_budget_smoke.gd`
  - 在高压场景下确认新增节点仍在视觉预算内。

## 验证结果

- Godot check-only：通过。
- 敌人视觉矩阵：`SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=1314`
- 主场景 smoke：`SURVIVOR_SMOKE_OK enemies=87 projectiles=58 pickups=49`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=6947 nodes=8796 projectiles=210 pickups=166 zones=31`
- 完整后台回归：`FULL_SURVIVOR_REGRESSION_OK tests=18`

## 后续建议

- 下一批优先把这套“意图识别”继续接到真实精英攻击行为上，例如狂暴精英的短突进、壁垒精英的护盾破裂窗口、分裂精英的死亡分裂轨迹、宝藏精英的逃跑/诱导机制。
- 当前仍是程序几何表现，优势是稳定和低成本；若继续向效果图质量靠近，后续更值得投入统一图集贴花、材质渐变和少量精简骨骼动画，而不是单纯继续堆节点。
