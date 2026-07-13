# 竞技场目标神龛更新

本批次新增 `ArenaObjectiveShrineSet`，用于强化竞技场边缘的海克斯/虚空装置感，让场景更接近参考图里“中心战斗区被装置、水晶和符文节点包围”的视觉结构。

## 更新内容

- 新增 6 个 `ObjectiveShrine_*`：
  - 2 个 `hextech` 蓝色海克斯神龛。
  - 2 个 `void` 紫色虚空神龛。
  - 2 个 `reward` 绿色奖励水晶神龛。
- 每个神龛包含：
  - `ObjectiveShrineBase`
  - `ObjectiveShrineFrame`
  - `ObjectiveShrineGlowRing`
  - `ObjectiveShrineCrystal`
  - `ObjectiveShrineSigil`
- 神龛只放在外围和边缘，不进入主战斗中心，避免和弹幕、经验、敌人预警混淆。

## 性能策略

- 不新增实时灯光。
- 单个神龛使用低段数几何体和已有材质系统。
- 同步循环只做水晶浮动、光环轻微缩放和符文轻旋转，不动画大面积地板。

## 自动化覆盖

- `tests/survivor_arena_visual_matrix.gd` 检查 `ArenaObjectiveShrineSet`、6 个神龛、三类 shrine metadata 和核心子节点。
- `tests/survivor_headless_smoke.gd` 增加主场景断言，确认实际运行路径会构建该场景层。
