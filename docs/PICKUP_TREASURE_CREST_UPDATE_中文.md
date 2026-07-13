# 高价值拾取物战利品冠标

本次继续贴近参考图里“晶石、金币、奖励图标一眼可读”的方向，只给高价值掉落增加一层轻量 3D 战利品轮廓。

## 改动

- 新增 `PickupTreasureCrest`：
  - 大经验、金币宝箱、治疗、护盾会出现悬浮冠标。
  - 每类掉落有不同造型：金币冠环、治疗十字晶体、护盾徽章、大经验晶簇。
  - 普通小 XP 不显示该层，密集掉落仍使用 `LitePickupCore`。
- `_sync_pickups()` 会驱动冠标旋转和轻微呼吸，提升战利品存在感。
- `PickupRewardBeacon` 的高价值判定抽成 `_is_high_value_pickup()`，避免后续不同奖励层阈值不一致。

## 验证

- 新增 `tests/survivor_pickup_visual_matrix.gd`，覆盖普通 XP、高价值 XP、金币、治疗、护盾和密集 lite XP。
- `tests/survivor_headless_smoke.gd` 新增 `PickupTreasureCrest` 实战断言。
- 本批通过完整 16 项 headless 回归：
  - `SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=160`
  - `SURVIVOR_SMOKE_OK enemies=87 projectiles=57 pickups=48`
  - `SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=7020 nodes=8850 projectiles=210 pickups=167 zones=31`
