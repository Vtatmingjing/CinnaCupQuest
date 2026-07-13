# 区域技能 LOD 性能更新

日期：2026-07-03

## 背景

视觉预算测试会同时生成 30 个以上区域技能。完整区域技能包含贴图盘面、边缘环、进度刻度、来源档案、结算档案和技能专属 Marker，每个区域大约 60 到 90 个节点；当区域数量过多时，节点数会超过 3D 预算。

## 修改

- 新增 `ZONE_DETAIL_LIMIT = 12` 和 `ZONE_DETAIL_RECOVER_LIMIT = 8`。
- 玩家区域数量超过阈值后，区域模型自动重建为 lite 版本。
- 区域数量回落到恢复阈值以下后，再恢复完整版本，避免 12 附近反复重建。
- Boss 危险区域不使用 lite，继续保留完整危险读图。

## lite 区域保留内容

- 保留 `Disc` 根盘面，继续按真实半径缩放。
- 保留 `Marker`，不同区域仍有不同的简化形状。
- 保留 `ZonePulseCore`，同步循环仍能做基础脉冲动画。
- 提莫蘑菇 lite 版本保留 `ZoneArmedSigils`，未触发陷阱仍可读。

## lite 区域移除内容

- 移除高密度场景里的 `ZoneProgressSigils`。
- 移除 `ZoneSourceProfile`。
- 移除 `ZoneResolutionProfile`。
- 减少盘面边缘、符文和中心环的段数与 mesh 数。

## 测试

- `tests/survivor_headless_smoke.gd` 仍在低区域数量下验证完整区域表现。
- `tests/survivor_visual_budget_smoke.gd` 在高区域数量下断言必须存在 `lite_zone_model`，确保性能保护实际生效。
