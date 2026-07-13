# 玩家弹体命中意图层更新

日期：2026-07-03

## 目标

上一轮 `PlayerProjectileRoleProfile` 已经把玩家弹体按英雄/职业拆开，但飞行末端的“打到人会发生什么”仍然不够明确。本轮新增命中意图层，让粉丝能从弹体前端读出爆破、灵魂贯穿、近战斩击、海克斯灼烧、羽刃回收、毒孢爆开、星落坍缩或重锤压制。

## 已完成

- `scripts/survivor_3d_view.gd`
  - 新增 `PlayerProjectileImpactIntentProfile`，只挂在非 lite 玩家弹体上。
  - 写入 `label`、`family`、`source_champion`、`detail_node` metadata，方便测试和后续维护。
  - 固定子节点：
    - `PlayerProjectileImpactIntentFrame`
    - `PlayerProjectileImpactIntentCore`
  - 英雄家族细分节点：
    - 金克丝：`PlayerProjectileImpactRocketBurst`
    - 赛娜：`PlayerProjectileImpactSoulPierce`
    - 莎弥拉：`PlayerProjectileImpactDuelistCut`
    - 维克托：`PlayerProjectileImpactHexcoreBurn`
    - 霞：`PlayerProjectileImpactFeatherRecall`
    - 提莫：`PlayerProjectileImpactPoisonBloom`
    - 奥瑞利安·索尔：`PlayerProjectileImpactStarFall`
    - 莫德凯撒：`PlayerProjectileImpactIronCrush`
  - 同步阶段加入轻量旋转和脉冲，不改变弹道速度、伤害、碰撞或生成数量。

## 性能策略

- 高弹幕密度下的玩家弹体仍然走 lite 路径。
- lite 玩家弹体明确禁止生成 `PlayerProjectileImpactIntentProfile`，避免密集场景长期常驻节点膨胀。
- 新层主要服务近景/低密度读法，高密度时保留已有 `PlayerProjectileSignatureRig`。

## 测试覆盖

- `tests/survivor_projectile_visual_matrix.gd`
  - 非 lite 玩家弹体必须存在 `PlayerProjectileImpactIntentProfile`。
  - 检查 `family`、`source_champion`、`detail_node` metadata。
  - 检查每个英雄家族对应的专属 detail 节点。
  - lite 玩家弹体禁止出现该 profile。
- `tests/survivor_headless_smoke.gd`
  - 主场景 smoke test 检查真实战斗循环里能生成该节点。

## 验证结果

- Godot check-only：通过。
- 拾取物视觉矩阵：`SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=159`
- 弹体视觉矩阵：`SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=9 meshes=867`
- 主场景 smoke：`SURVIVOR_SMOKE_OK enemies=87 projectiles=58 pickups=47`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=6832 nodes=8710 projectiles=210 pickups=167 zones=31`

