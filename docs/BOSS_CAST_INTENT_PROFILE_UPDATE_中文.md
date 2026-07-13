# Boss 出招意图识别层增强记录
日期：2026-07-03

## 本轮目标

继续强化虚空 Boss 的战斗读图，不只让 Boss 法阵形状不同，还让玩家能快速判断这次攻击的核心意图：吞噬/裂地、激光扇面、钻地冲锋、女王翼扫。该层只挂在 Boss 出招图案内，不给普通怪潮增加长期预算压力。

## 已完成

- 新增 `BossCastIntentProfile`
  - 挂在每个 `BossCastPattern*` 下。
  - 写入 `boss_kind`、`intent_type`、`detail_node` metadata，便于测试和后续维护。
  - 随 Boss 出招倒计时缩放、旋转和脉冲，倒计时越接近出手越醒目。
- 四个 Boss 的意图 detail
  - 科加斯：`BossCastIntentChoDevour`，对应 `devour_rupture`。
  - 维克兹：`BossCastIntentVelkozLaser`，对应 `laser_fan`。
  - 雷克塞：`BossCastIntentReksaiBurrow`，对应 `burrow_charge`。
  - 卑尔维斯：`BossCastIntentBelvethSweep`，对应 `royal_sweep`。

## 测试覆盖

- `tests/survivor_boss_cast_pattern_matrix.gd`
  - 每个 Boss 都必须存在 `BossCastIntentProfile`。
  - 校验 `boss_kind`、`intent_type`、`detail_node` metadata。
  - 校验 `BossCastIntentFrame`、`BossCastIntentPip` 和专属 detail 具备 mesh 内容。
- `tests/survivor_headless_smoke.gd`
  - 主场景强制 Vel'Koz Boss 进入出招窗口，并确认 `BossCastIntentProfile` 与 `BossCastIntentVelkozLaser` 可见。

## 当前验证

- Godot check-only：通过。
- Boss 出招矩阵：`SURVIVOR_BOSS_CAST_PATTERN_MATRIX_OK bosses=4 meshes=75`
- 主场景烟测：`SURVIVOR_SMOKE_OK enemies=90 projectiles=58 pickups=46`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=62 meshes=6940 nodes=8785 projectiles=210 pickups=166 zones=31`
- 完整回归：`FULL_SURVIVOR_REGRESSION_OK tests=18`

## 后续建议

- 下一步可以把同样的“意图识别”扩展到精英词缀实际攻击，例如宝藏精英的奖励预告、分裂精英的分裂预警、壁垒精英的护盾破口。
- Boss 出招层目前仍是低成本几何体，后续若要更接近效果图，应优先把这层替换为统一风格的图集贴花，而不是继续堆节点。
