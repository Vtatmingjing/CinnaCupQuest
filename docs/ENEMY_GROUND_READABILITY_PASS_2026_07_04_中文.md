# 普通敌人地面辨识度加固

本轮目标是继续解决“怪物、经验、弹幕混在一起”的问题，但不再靠提高亮度堆光污染。

## 改动

- 普通敌人的 `EnemyGroundSilhouettePlate` 增加 `pickup_confusion_guard` 与 `collision_radius_readability` 元数据。
- 新增 `EnemyGroundSilhouettePickupGap`：黑色低眩光分隔圈，用来把敌人占位和经验/金币拾取物分开。
- 新增 `EnemyGroundSilhouetteFacingNotch`：朝向缺口，帮助玩家从俯视角判断敌人的面向和威胁方向。
- 轻量 LOD 敌人也补了同名分隔圈与朝向缺口，避免怪物数量变多时又和经验点混在一起。
- 所有新增材质都使用 0 发光、低透明度的 matte 处理，避免重新变成光污染。

## 验证门槛

- `res://tests/survivor_enemy_visual_matrix.gd` 会检查普通敌人地面轮廓的元数据、分隔圈和朝向缺口。
- `res://tests/survivor_playability_readability_gate.gd` 会在实战模拟中要求出现 `EnemyGroundSilhouettePickupGap`。
- 后续每批视觉改动仍然必须通过可玩性、光污染和性能预算测试。
