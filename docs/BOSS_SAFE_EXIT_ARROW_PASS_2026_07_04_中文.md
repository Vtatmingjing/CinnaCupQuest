# Boss 安全出口箭头打磨

本轮继续推进海克斯/虚空 3D 战斗表现，重点不是堆更多亮光，而是让 Boss 技能预警更像战术地面提示。

## 改动

- 在 `BossCastSafetyProfile` 中新增 `BossCastSafeExitArrowRoot`。
- 每个 Boss 的安全口都会生成对应的 `BossCastSafeExitArrow_*`：
  - 科加斯风格 Boss：环形撕裂安全缺口箭头。
  - 维克兹风格 Boss：激光夹缝安全通道箭头。
  - 雷克塞风格 Boss：侧向躲避口箭头。
  - 卑尔维斯风格 Boss：扫击中心安全线箭头。
- 箭头使用低眩光安全 tick 材质，不提升整体光污染。

## 验证

- `res://tests/survivor_boss_cast_pattern_matrix.gd` 现在会检查安全出口箭头根节点、数量、元数据和网格内容。
- 后续 Boss 技能视觉改动必须继续通过可玩性、低眩光和性能预算门槛。
