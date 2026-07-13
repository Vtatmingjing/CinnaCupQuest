# 持续区域英雄来源识别层增强记录
日期：2026-07-03

## 本轮目标

把范围持续技能从普通地面光圈继续拆成更容易识别的英雄来源效果，让玩家能区分维克托重力场、奥瑞利安·索尔奇点、莫德凯撒领域和提莫蘑菇陷阱。实现时同步控制节点预算，避免高压场景中长期存在的 Zone 视觉对象把 CPU/GPU 负担推高。

## 已完成

- 新增 `ZoneSourceProfile`
  - 挂在 Zone 的 `Disc` 节点下，随 `ZoneRunePlate`、`ZonePulseCore` 和 `ZoneProgressSigils` 一起受生命周期同步控制。
  - 写入 `kind`、`source_champion`、`profile_family`、`profile_role`、`detail_node` metadata，方便测试和后续维护。
  - 提莫蘑菇未触发时继续隐藏持续区域来源层，触发后才显示，避免陷阱预警和爆发区域混在一起。
- 新增专属 detail 节点
  - 维克托重力场：`ZoneSourceProfileHexcoreField`
  - 奥瑞利安·索尔奇点：`ZoneSourceProfileStarForgeField`
  - 莫德凯撒领域：`ZoneSourceProfileRealmSeal`
  - 提莫蘑菇陷阱：`ZoneSourceProfileMushroomTrap`
- 预算修正
  - 初版 profile 在 31 个 Zone 同屏压力下导致节点数 `9146 > 9000`。
  - 已压缩为轻量结构：保留来源环、职业徽记和专属 detail，但每个 Zone 的长期驻留节点数量明显下降。
  - 进一步减少 `ZoneProgressSigils` 的进度刻度数量，每个 Zone 少两个刻度，保留来源识别层并换取更稳定的高压预算余量。

## 测试覆盖

- `tests/survivor_zone_visual_matrix.gd`
  - 覆盖 4 类持续区域。
  - 检查 `ZoneSourceProfile`、来源 metadata、`ZoneSourceProfileRing`、`ZoneSourceClassBadge` 和对应 detail 节点。
  - 检查提莫蘑菇未触发/已触发的显隐状态。
- `tests/survivor_headless_smoke.gd`
  - 主场景烟测要求实际战斗循环中 Zone 具备 `ZoneSourceProfile`。
- `tests/survivor_visual_budget_smoke.gd`
  - 高压场景继续约束 mesh/node/projectile/pickup/zone 数量。

## 验证结果

- Godot check-only：通过。
- Zone 视觉矩阵：`SURVIVOR_ZONE_VISUAL_MATRIX_OK zones=4 meshes=230`
- 主场景烟测：`SURVIVOR_SMOKE_OK enemies=88 projectiles=57 pickups=49`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=6926 nodes=8784 projectiles=210 pickups=167 zones=31`
- 完整回归：`FULL_SURVIVOR_REGRESSION_OK tests=18`

## 后续建议

- 继续把英雄来源识别层贯穿到召唤物、Boss 技能预警和商店装备特效，避免技能表现只停留在弹道阶段。
- 后续新增长期驻留场景物时优先复用材质和节点结构。完整回归中的节点预算距离 9000 上限剩 216，继续加常驻节点前仍应先做 LOD 或删减旧节点。
