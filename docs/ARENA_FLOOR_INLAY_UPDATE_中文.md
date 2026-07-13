# 竞技场地板镶嵌更新

本轮继续朝参考图的“精致海克斯竞技场底盘”靠近，重点不是堆更多敌人或弹幕，而是在静态场地上增加更清晰的结构层次。

## 改动

- 新增 `ArenaFloorInlaySet` 独立节点组，方便后续继续打磨或回收预算。
- 中央战斗区新增 8 段 `FloorInlayOctagonSpan_` 八边形镶边，让主战斗区更像完整竞技场平台。
- 从中心向外新增 8 条 `FloorInlayRadialConduit_` 径向能量导线，连接海克斯蓝、虚空紫、金币金和奖励绿几种视觉语言。
- 增加 6 个 `FloorInlayRunicShard_` 小符文碎片，减少地面大面积空白。
- 四角新增 `FloorInlayCornerAnchor_` 和 `FloorInlayCornerCrystal`，把外围塔、地面纹路和参考图里的晶体节点视觉串起来。

## 验证

- 更新 `tests/survivor_arena_visual_matrix.gd`，覆盖新增地板镶嵌组、八边形镶边、径向导线、符文碎片和四角晶体。
- 单项竞技场矩阵：
  - `SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=1672x941 meshes=1154 citadel_nodes=8`
- 完整 17 项后台回归：
  - `SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=6718 nodes=8552 projectiles=210 pickups=167 zones=31`
  - `FULL_SURVIVOR_REGRESSION_OK tests=17`

## 性能

- 静态竞技场 mesh 从约 `1112` 增至 `1154`，新增约 42 个静态 mesh。
- 高压场景节点数仍低于 `9000` 上限，最新为 `8552`，保留约 448 个节点余量。
