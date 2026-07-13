# 敌方威胁轮廓低眩光可读性记录

日期：2026-07-04

## 目标

继续处理当前试玩反馈里的三个核心问题：

- 敌人、经验、金币和弹幕在密集场景里容易混在一起。
- Boss 和精英怪的碰撞范围、体型压迫感不够明确。
- 画面不能再靠更亮的特效解决辨识度，否则会变成光污染。

本次改动给精英和 Boss 增加低眩光地面威胁轮廓，不给普通小怪添加，避免大规模刷怪时增加不必要的性能压力。

## 改动

新增 `EnemyThreatOcclusionPlate`，挂在精英和 Boss 的 3D 模型下，包含：

- `EnemyThreatOcclusionMatte`：低 alpha 暗色底片，用来把敌人与拾取物分层。
- `EnemyThreatOcclusionBodyMass`：身体占位提示，用来强调大型单位体积。
- `EnemyThreatOcclusionCollisionRing`：碰撞半径提示。
- `EnemyThreatOcclusionFacingCut`：朝向切口，帮助判断 Boss/精英的攻击方向。
- Boss 专用低成本方位刻痕，补足大型威胁的地面轮廓，不增加发光材质。
- 精英根据 trait 使用不同细节节点：`frenzy`、`bulwark`、`splitter`、`treasure` 都有独立轮廓语义。

关键元数据：

- `visual_stratum = enemy_floor_occlusion`
- `combat_visual_channel = enemy_occlusion_readability`
- `material_grade = low_glare_enemy_threat_occlusion`
- `pickup_confusion_guard = true`
- `collision_radius_readability = true`

## 眩光控制

本层材质全部保持 `emission = 0.0`，透明 alpha 压到 `0.36` 以下。它的目标是“暗色托底 + 形状分层”，不是做更亮的特效。

## 性能策略

- 普通小怪不携带 `EnemyThreatOcclusionPlate`。
- Lite 普通小怪不携带该层。
- Lite 精英只保留必要低成本轮廓。
- Boss 只增加少量方位刻痕，保证视觉预算仍在当前密集场景上限内。

## 验证

本批次只使用 Godot headless/console 验证，没有打开游戏 GUI。

- `SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2697`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=89 meshes=6242 nodes=8171 projectiles=210 pickups=168 zones=31`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7585 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=44 pickups=33`
- `SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility`
- `SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean`
- `SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=2851 ability_atlas=1536x1024 archetype=role_silhouette`
- `SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=90 timers=survival_pressure_v7 spawn_steps=challenge_v6 surge=elite_squad_v3 enemy_growth=harder_v5 attacks=pressure_v2`
- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1643`
- `SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=169`

## 结论

这次不是继续堆亮光，而是把敌方高威胁单位压到独立的暗色视觉层里。目标是在不增加光污染的前提下，让玩家更容易分清“这是敌人本体/碰撞范围”，而不是经验、金币或弹幕。
