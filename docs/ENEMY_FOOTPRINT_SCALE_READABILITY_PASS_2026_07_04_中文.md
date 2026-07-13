# 敌人体型占地可读性更新
日期：2026-07-04

## 目标

继续解决敌人、经验晶体、奖励、弹幕在密集场景里混在一起的问题。
本批不提高亮度，而是给高优先级敌人增加低眩光“占地等级轮廓”，让玩家从俯视视角快速判断：

- 这是高威胁敌人，不是经验或奖励。
- 精英和 Boss 的体量明显高于普通怪。
- 怪物身体区域和拾取物区域有暗色隔离。

普通怪不再携带该层。普通怪继续依赖 `EnemyGroundSilhouettePlate` 和 `EnemyThreatRankSilhouetteRig`，避免大规模刷怪时 mesh 预算溢出。

## 改动

新增并保留 `EnemyFootprintScaleRig`，但只挂在精英和 Boss 模型上。
该节点包含：

- `EnemyFootprintScaleMatte`：暗色占地底板。
- `EnemyFootprintBodyBounds`：身体边界占位。
- `EnemyFootprintPickupClearanceGap`：与拾取物区分的暗色间隙。
- `EnemyFootprintRankBracket`：朝向/等级短括号。
- 等级细节节点：
  - `EnemyFootprintEliteMassSpikes`
  - `EnemyFootprintBossMassFrame`

关键元数据：

- `combat_visual_channel = enemy_body_readability`
- `material_grade = low_glare_enemy_footprint_scale`
- `pickup_confusion_guard = true`
- `scale_readability = true`

## 性能策略

- 只给精英、Boss 等高优先级非 lite 敌人添加该层。
- 普通怪不携带该层，防止大规模刷怪时预算不稳定。
- 每个高优先级 footprint 控制在 6-8 个 Mesh。
- 材质不使用高发光，主要靠暗底轮廓和边界形状提升辨识度。

## 验证

已更新：

- `res://tests/survivor_enemy_visual_matrix.gd`
- `res://tests/survivor_headless_smoke.gd`

当前验证结果：

- `SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2633`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=6430 nodes=8214 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7371 models=46 emission=0.094 alpha=0.353`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=40 pickups=32`
- headless 初始化：退出码 0
