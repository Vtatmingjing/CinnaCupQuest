# 竞技场战术 Hex 网格更新

本批次针对效果图里的清晰 hextech 棋盘感继续打磨中心战斗区。目标是让玩家一眼看到“这是一块海克斯/虚空竞技场地砖”，同时保持低眩光，不影响弹幕和敌人可读性。

## 已改内容

- 新增 `ArenaTacticalHexGridSet`，挂在 3D 竞技场静态场景内。
- 中心战斗区新增低眩光 tactical hex 单元：
  - `ArenaTacticalHexCell_*`
  - `ArenaTacticalHexEdge_*`
  - `ArenaTacticalHexMajorPip`
  - `ArenaTacticalCenterHex`
  - `ArenaTacticalCenterSpoke_*`
- 材质统一走 `material_grade = low_glare_hex_floor_guides`，使用非发光、低 alpha 的黑色沟槽、暗金、海克斯蓝和虚空紫。
- 网格只作为地面结构和方位参考，不进入 `enemy_hazard` 或 `pickup_*` 视觉频道，避免和战斗信息抢层级。

## 测试覆盖

- `tests/survivor_arena_visual_matrix.gd`：检查 tactical hex 网格存在、metadata 正确、至少 25 个 hex 单元、150 条边线、主要节点和中心 hex/spoke 完整。
- `tests/survivor_arena_visual_matrix.gd`：检查 tactical hex edge 和 major pip 都是低眩光材质。
- `tests/survivor_material_quality_matrix.gd`：确认全局低眩光参数仍有效。
- `tests/survivor_visual_budget_smoke.gd`：高压场景通过，最新结果为 `SURVIVOR_VISUAL_BUDGET_OK enemies=80 meshes=6736 nodes=8590 projectiles=210 pickups=168 zones=31`。

## 性能说明

- 新增内容是静态 MeshInstance3D，不参与敌人/弹幕/拾取物动态同步。
- 当前高压预算仍低于阈值：
  - `MAX_MESH_INSTANCES = 7200`
  - `MAX_TOTAL_NODES = 9000`
- 后续如果继续加场景装饰，应优先替换/合并静态地面细节，而不是继续无上限叠加。
