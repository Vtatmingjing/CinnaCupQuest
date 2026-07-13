# Boss 技能安全缝低眩光读招记录

日期：2026-07-04

## 目标

继续向“海克斯/虚空 3D 弹幕肉鸽”的方向推进。上一批已经加强了敌方本体和碰撞范围，这一批处理 Boss 技能预警：

- 玩家需要能看懂哪里危险、哪里可以走位。
- 不靠更亮的特效制造可读性，避免继续光污染。
- 每个 Boss 的技能预警要有不同形状语义，不能只是同一圈红光。

## 改动

在 `BossCastPatternRig` 的每个 Boss 技能预警下新增 `BossCastSafetyProfile`。

公共元数据：

- `combat_visual_channel = boss_cast_safety_readability`
- `material_grade = low_glare_boss_cast_safety_profile`
- `boss_cast_safe_gap_layer = true`
- `safe_pocket_count` 根据 Boss 类型不同

每个 Boss 的读招语义：

- `boss_cho`：`ring_gap`，用 `BossCastSafetyChoBiteGaps` 标出吞噬/破裂环之间的可走缝。
- `boss_velkoz`：`laser_between_lanes`，用 `BossCastSafetyVelkozLaserGaps` 标出激光扇之间的空档。
- `boss_reksai`：`side_dodge_pocket`，用 `BossCastSafetyReksaiSidePockets` 标出冲锋线两侧躲避口袋。
- `boss_belveth`：`sweep_center_seam`，用 `BossCastSafetyBelvethSweepSeam` 标出翼刃横扫中的中心缝和短窗口。

## 眩光与性能

本层使用低 alpha、低 emission 材质：

- 安全缝主材质：暗青低透明层。
- 危险边界刻度：低亮金色薄线。
- 底层遮罩：暗色非发光底片。

它不是奖励特效，也不是敌方弹幕本体，而是专门给 Boss 技能读招用的信息层。

## 自动化验证

本批次只使用 Godot headless/console 验证，没有打开游戏 GUI。

- `SURVIVOR_BOSS_CAST_PATTERN_MATRIX_OK bosses=4 meshes=443`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=5616 nodes=7376 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7585 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=47 pickups=33`
- `SURVIVOR_BOSS_BEHAVIOR_MATRIX_OK bosses=4`
- `SURVIVOR_BOSS_PHASE_STATE_VISUAL_MATRIX_OK bosses=4`

## 结论

Boss 技能现在多了一层“可躲区域”的低眩光读招语言。它不会直接降低难度，但能让高压弹幕更公平，后续可以在此基础上继续提高 Boss 攻击频率和组合压力。
