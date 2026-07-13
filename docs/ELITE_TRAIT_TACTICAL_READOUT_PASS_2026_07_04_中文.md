# 精英词缀战术读招低眩光记录

日期：2026-07-04

## 目标

继续解决“怪物千篇一律、弹幕肉鸽缺少公平读招”的问题。Boss 已经增加安全缝读招后，本批次把同样的思路下放到精英怪：

- 玩家需要能快速看出精英词缀的战斗含义。
- 精英行为不是只靠颜色区分，而是有对应的走位/交互提示。
- 不提高亮度，不把精英特效做成新的光污染。

## 改动

在 `EliteTraitTelegraphRig` 下新增 `EliteTraitTacticalReadout`。

公共元数据：

- `combat_visual_channel = elite_trait_tactical_readability`
- `material_grade = low_glare_elite_trait_tactical_readout`
- `elite_tactical_readout_layer = true`
- `safe_pocket_count` 按词缀区分

每个词缀的战术读招：

- `frenzy`：`rush_lane`，用 `EliteTraitTacticalFrenzyRushLane` 标出冲刺路线和侧向躲避口袋。
- `bulwark`：`break_window`，用 `EliteTraitTacticalBulwarkBreakWindow` 标出破盾窗口和可输出时机。
- `splitter`：`bloom_radius`，用 `EliteTraitTacticalSplitterBloomRadius` 标出分裂爆点和外围安全口袋。
- `treasure`：`flee_vector`，用 `EliteTraitTacticalTreasureFleeVector` 标出宝藏精英逃跑方向和追击路径。

## 同步逻辑

`_sync_elite_trait_telegraph` 会同步新读招层：

- frenzy 根据 `dash_timer` 提升冲刺路线强度。
- bulwark 根据 `bulwark_break_timer` 显示破盾窗口。
- splitter 根据半血/已分裂状态显示爆点半径。
- treasure 根据 `treasure_flee_timer` 显示逃跑向量。

## 眩光与性能

本层只使用低 alpha、低 emission 材质：

- 暗色底片负责和地面/拾取物分离。
- 暗青安全口袋负责走位提示。
- 低亮金色刻度负责边界提示。

普通小怪和 lite 普通怪不会携带该层。

## 自动化验证

本批次只使用 Godot headless/console 验证，没有打开游戏 GUI。

- `SURVIVOR_ELITE_TRAIT_STATE_VISUAL_MATRIX_OK traits=4`
- `SURVIVOR_ELITE_TRAIT_BEHAVIOR_MATRIX_OK traits=4`
- `SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2724`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=5788 nodes=7595 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7585 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=44 pickups=32`

## 结论

精英词缀现在不只是“带颜色的强化怪”，而是带有明确战术读招的单位。后续可以在这个基础上继续提高精英组合压力，因为玩家已经能更公平地读出冲刺、破盾、分裂和逃跑信息。
