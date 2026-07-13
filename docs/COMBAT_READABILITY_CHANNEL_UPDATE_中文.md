# 战斗读图通道更新

本批目标是减少敌方弹幕、玩家技能、经验/金币掉落之间的视觉混淆，同时不增加场内节点和 Mesh。

## 调整内容

- 弹体模型新增 `combat_visual_channel` 和 `readability_priority` metadata。
- 玩家技能弹体通道：
  - `player_skill`
  - `player_skill_lite`
- 敌方弹幕通道：
  - `enemy_hazard_*`
  - `enemy_hazard_lite_*`
- 敌方弹幕在 3D 中略微上抬，危险圈、路径箭头、VFX 贴花和读取外壳会按威胁等级增强脉冲。
- 敌方弹幕关键部件写入 `enemy_hazard` channel：
  - `EnemyProjectileLane`
  - `EnemyProjectileTrajectoryMarks`
  - `EnemyProjectileHeadingArrow`
  - `EnemyProjectileReadabilityShell`
  - `EnemyProjectilePickupSeparationRing`
  - `EnemyProjectileHazardChevron`
- 普通 lite XP 掉落降低高度、浮动幅度和发光强度，通道为 `pickup_xp_lite`。
- 高价值 XP、金币、治疗、护盾继续保持 `pickup_reward` 通道和醒目奖励表现。

## 验证

- `tests/survivor_projectile_visual_matrix.gd` 增加弹体通道和子节点通道断言。
- `tests/survivor_pickup_visual_matrix.gd` 增加 pickup 通道断言。
- 继续用 `survivor_headless_smoke.gd` 和 `survivor_visual_budget_smoke.gd` 做真实路径和预算回归。
