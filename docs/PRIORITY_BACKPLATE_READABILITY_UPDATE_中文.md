# 精英与 Boss 优先级暗底板更新

本轮继续处理“场内信息不清楚、精英和 Boss 不够突出、光污染过亮”的问题。方向是给高优先级目标增加暗底和低发光标记，而不是继续叠亮光。

## 主要改动

- 精英和 Boss 新增 `PriorityCombatBackplateRig`。
- 暗底层包含：
  - `PriorityCombatMatteBackplate`：脚下暗色底板，用来把高优先级目标从地面特效和拾取物里分离出来。
  - `PriorityCombatBodySilhouetteBacker`：模型主体背后的低亮轮廓底。
  - `PriorityCombatFocusBracket*`：四角低亮度定位括号。
- Boss 额外包含：
  - `BossPriorityThreatBacker`
  - `BossPriorityPhaseTrim`
- 精英额外包含：
  - `EliteRewardReadabilityPip`
  - `ElitePriorityTraitHint`
- 普通敌人和 lite 敌人不会带这套层，避免满场怪物时无意义增加网格数量。
- 所有新增材质都要求非 emissive，避免继续制造光污染。

## 设计目的

- Boss/精英在大量小怪、经验、金币和弹幕中更容易被识别。
- 用暗色底板提升对比度，而不是用更亮的发光环解决问题。
- 保持精英奖励感，但不让奖励提示和敌方弹幕混淆。
- 控制新增成本，只作用于高优先级目标。

## Headless 验证

已通过：

- `SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=1949`
- `SURVIVOR_ELITE_TRAIT_STATE_VISUAL_MATRIX_OK traits=4`
- `SURVIVOR_BOSS_PHASE_STATE_VISUAL_MATRIX_OK bosses=4`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=66 meshes=5689 nodes=7311 projectiles=210 pickups=167 zones=31`
- `SURVIVOR_SMOKE_OK enemies=92 projectiles=62 pickups=41`

说明：本轮没有打开游戏 GUI，只使用 Godot headless。Godot dummy renderer 仍会输出 `Parameter "m" is null`，退出码为 0 且 OK 标记存在时按通过处理。
