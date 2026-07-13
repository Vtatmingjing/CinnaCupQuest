# 敌人受伤状态、降眩光与挑战压力更新

本批次针对试玩反馈中的三个问题继续收敛：UI/贴图对齐已有 HUD 矩阵保护，本次重点补强战斗内敌人状态辨识、降低光污染、提高前中期生存压力。

## 已改内容

- 新增 `EnemyDamageStateRig`：非 lite 敌人会带低眩光受伤状态层，满血隐藏，受伤或低血量时显示裂纹条、伤口核心、破甲碎片和阶段点。
- `EnemyDamageStateRig` 使用 `combat_visual_channel = enemy_damage_state` 和 `material_grade = low_glare_matte_damage`，材质不启用高发光，避免继续加重光污染。
- lite 怪模型不挂受伤状态层，密集怪潮仍优先保护性能。
- 全局 3D 光照继续下调：降低 ambient、ACES exposure、glow、补光和边缘光，降低饱和度，让敌人和弹幕不再被场景光效淹没。
- 拾取物发光/透明权重下调，经验和金币退到第二视觉层，减少和敌方弹幕混淆。
- 前中期难度上调：首个精英更早出现，精英刷新间隔更紧，刷怪包数量从更早时间点开始增长。
- 相关开局命运中的精英计时器同步调整，避免选到特定命运后难度回到旧的宽松节奏。

## 测试覆盖

- `tests/survivor_enemy_visual_matrix.gd`：检查受伤状态层结构、metadata、低眩光材质、满血隐藏、残血显示、阶段点亮；同时确认 lite 怪不会挂该层。
- `tests/survivor_difficulty_curve_matrix.gd`：确认 120 秒 Boss、7.6 秒内首个精英、更紧的中期刷怪/精英节奏，以及更高的中后期刷怪包。
- `tests/survivor_material_quality_matrix.gd`：锁定更低的 glow、ambient、exposure、key/fill/rim light 和饱和度上限。
- `tests/survivor_pickup_visual_matrix.gd`：确认拾取物视觉层仍完整，且高压拾取物继续走 lite LOD。
- `tests/survivor_visual_budget_smoke.gd`：高压场景通过，最新结果为 `SURVIVOR_VISUAL_BUDGET_OK enemies=80 meshes=6382 nodes=8196 projectiles=210 pickups=168 zones=31`。

## 后续建议

- 下一批优先做敌方弹幕的“危险轮廓线”和经验球的形状区分，进一步减少混淆。
- Boss 可继续增加阶段性招式组合，而不是继续单纯增加血量。
- 如果继续加 3D 美术层，必须同步更新视觉预算测试，保持 `MeshInstance3D` 和节点数在当前阈值内。
