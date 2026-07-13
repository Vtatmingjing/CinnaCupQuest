# 竞技场外圈高台更新

本次更新给战斗场地新增一圈海克斯虚空外圈高台，目标是让画面更接近参考图里的“完整竞技场/装甲平台”感觉，而不是只有一张平面地板。

## 新增内容

- 新增 `ArenaPerimeterCitadelSet` 场景层。
- 外圈包含：
  - 4 段 `PerimeterWallSpan` 装甲外墙。
  - 4 个 `PerimeterCitadelTower` 角塔。
  - 8 个 `PerimeterEnergyNode` 能量节点。
  - 4 条 `PerimeterShieldRail` 护栏光带。
  - 4 个 `PerimeterDiagonalButtress` 斜向支撑。
- 能量节点和护栏光带接入 `_sync_arena_motion`，只做轻微脉冲，不影响战斗读图。

## 性能策略

- 外圈高台只在场景初始化时构建一次。
- 使用低成本几何和现有材质缓存，不引入新的运行时纹理加载。
- 动态部分只同步少量节点，避免大量怪物/弹幕时增加明显 CPU 开销。

## 验证

`tests/survivor_arena_visual_matrix.gd` 现在会检查外圈高台、角塔、能量节点、护栏光带和斜向支撑是否存在，并继续限制静态网格预算。
