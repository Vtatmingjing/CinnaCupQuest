# 脉冲生存压力轮廓更新

日期：2026-07-04

## 目标

继续解决场内光污染、敌人与弹幕混淆、精英和 Boss 压力不明显的问题。

本批不通过提高亮度来制造反馈，而是给关键事件脉冲增加低眩光轮廓层，让玩家能用形状快速识别危险等级。

## 改动

新增 `PulseSurvivalPressureSilhouette` 3D 层，仅用于三类关键脉冲：

- `danger`：Boss / 高危红色预警，增加 `PulsePressureBossDangerCrown`
- `void`：虚空精英/裂隙压力，增加 `PulsePressureVoidEliteSpikes`
- `hextech`：海克斯事件/机制提示，增加 `PulsePressureHextechEventCircuit`

该层包含：

- `PulsePressureShadowPlate`：暗底轮廓，避免和 XP、金币、普通弹幕混在一起
- `PulsePressureOuterBracket`：外框识别形状
- `PulsePressureDirectionNeedle`：方向针，强化入场/危险来源
- 按事件类型区分的专属细节节点

所有新增材质均使用：

- `combat_visual_channel = survival_pressure_readability`
- `material_grade = low_glare_pulse_pressure_silhouette`
- `pickup_confusion_guard = true`
- `anti_glare = true`

## 约束

- 只给危险、虚空、海克斯脉冲加轮廓，不污染金币、护盾、毒、星界等普通反馈。
- 每个压力轮廓限制在 6-10 个 Mesh，避免大量事件时拖垮性能。
- 材质仍走现有 `pulse_` 低眩光压制逻辑，发光上限保持在测试预算内。

## 验证

已更新 `res://tests/survivor_pulse_visual_matrix.gd`：

- 强制检查三类压力脉冲必须有 `PulseSurvivalPressureSilhouette`
- 强制检查普通脉冲不能误用压力轮廓
- 检查专属 detail 节点、低眩光元数据、网格数量和发光/透明度预算

当前验证结果：

- `SURVIVOR_PULSE_VISUAL_MATRIX_OK pulses=7 meshes=333`
