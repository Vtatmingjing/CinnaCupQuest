# 玩家弹道职业识别层增强记录

日期：2026-07-03

## 本轮目标

继续把玩家攻击效果从“同一种发光弹丸”拆成更清晰的英雄/职业读法。重点不是改数值，而是让玩家在场内看到弹道时能更快判断这是射手爆破、支援炮击、近战连斩、法师控制、陷阱召唤或星界法术。

## 已完成

- 新增 `PlayerProjectileRoleProfile`
  - 只挂在非 lite 玩家弹道上，高弹幕密度下仍走已有 lite 逻辑。
  - 写入 `family`、`role`、`source_champion`、`detail_node` metadata，便于测试和后续维护。
  - 在同步中加入轻量脉冲和旋转，不改变弹道速度、伤害、碰撞或生成数量。
- 角色/职业细分
  - 金克丝/爆破射手：`PlayerProjectileProfileRocketArtillery`
  - 赛娜/支援炮击：`PlayerProjectileProfileSoulPiercer`
  - 莎弥拉/近战决斗：`PlayerProjectileProfileDuelistBlades`
  - 维克托/控制法师：`PlayerProjectileProfileHexcoreCircuit`
  - 霞/羽刃回收射手：`PlayerProjectileProfileFeatherRecall`
  - 提莫/陷阱召唤：`PlayerProjectileProfilePoisonTrap`
  - 奥瑞利安·索尔/星界法师：`PlayerProjectileProfileStarForge`
  - 莫德凯撒/近战坦克：`PlayerProjectileProfileJuggernautSlam`

## 测试覆盖

- `tests/survivor_projectile_visual_matrix.gd`
  - 普通玩家弹道必须存在 `PlayerProjectileRoleProfile`。
  - 检查 `family`、`role`、`source_champion` metadata。
  - 检查每个家族对应的专属 detail 节点。
  - lite 玩家弹道禁止出现 `PlayerProjectileRoleProfile`，避免密集弹幕下超预算。
- `tests/survivor_headless_smoke.gd`
  - 真实主场景烟测检查 `PlayerProjectileRoleProfile` 能在实际战斗循环中生成。

## 验证结果

- Godot check-only：通过。
- 弹道视觉矩阵：`SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=9 meshes=813`
- 主场景烟测：`SURVIVOR_SMOKE_OK enemies=89 projectiles=57 pickups=49`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=6891 nodes=8798 projectiles=210 pickups=167 zones=31`
- 完整回归：`FULL_SURVIVOR_REGRESSION_OK tests=17`

## 后续建议

- 下一步可以把同一套职业 profile 延伸到命中爆点和范围技能，让“弹道 - 命中 - 地面区域”形成同一英雄的连续视觉语言。
- 如果后续继续加场内细节，需要优先压缩长期存在节点，避免视觉预算逼近 7200 mesh / 9000 node 上限。
