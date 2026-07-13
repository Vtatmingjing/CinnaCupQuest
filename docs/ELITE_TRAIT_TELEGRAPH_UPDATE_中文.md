# 精英特质前摇层增强记录

日期：2026-07-02

## 本轮目标

继续把战斗表现往“海克斯虚空效果图”方向推进。Boss 已经有施法倒计时和专属图案，这一轮补齐非 Boss 精英怪的特质读法，让玩家能更快分辨“狂暴、壁垒、分裂、宝藏”四类精英。

## 已完成

- 新增 `EliteTraitTelegraphRig`
  - 只挂在非 Boss 精英怪身上。
  - 包含 `EliteTraitTelegraphCore`、地面 pip 和 `EliteTraitTelegraphPattern`。
  - 会根据攻击前摇、冲锋、召唤和血量压力增强脉冲。
- 狂暴精英
  - 新增 `EliteTraitFrenzyClaws`。
  - 用三道爪痕表达高速压迫。
- 壁垒精英
  - 新增 `EliteTraitBulwarkShield`。
  - 用六边形盾面表达高血量和防御感。
- 分裂精英
  - 新增 `EliteTraitSplitterSeeds`。
  - 用四个分裂种子提示死亡后可能带来额外压力。
- 宝藏精英
  - 新增 `EliteTraitTreasureCache`。
  - 用金色缓存/晶核提示高价值掉落。

## 测试覆盖

- `tests/survivor_enemy_visual_matrix.gd`
  - 检查四类精英都生成 `EliteTraitTelegraphRig`。
  - 检查特质 metadata、核心、pip、特质专属 detail 节点。
  - 检查 lite 敌人不会携带这套重节点。
- `tests/survivor_headless_smoke.gd`
  - 在真实主场景烟测中检查精英特质前摇节点可见。

## 验证结果

- Godot check-only：通过。
- 敌人视觉矩阵：`SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=1295`
- 主场景烟测：`SURVIVOR_SMOKE_OK`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=6908 nodes=8795 projectiles=210 pickups=167 zones=31`
- 完整后台回归：`FULL_SURVIVOR_REGRESSION_OK tests=17`

## 后续建议

- 下一轮可以继续打磨“英雄技能释放瞬间”的 fan-service 识别度，让每个角色技能不是只靠弹体颜色区分。
- 当前预算仍然健康，但精英和 Boss 已经有多层读法，后续新增表现要优先放在玩家技能和商店/装备反馈上。
