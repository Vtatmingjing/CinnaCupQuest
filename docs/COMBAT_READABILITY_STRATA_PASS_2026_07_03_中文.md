# 战斗阅读层与敌弹遮罩更新记录

本批继续针对“场景光污染、弹幕和经验混淆、画面没有生存阅读层”的问题做低眩光改动，不打开 GUI，只使用 Godot headless 验证。

## 场景阅读层

- 新增 `ArenaCombatReadabilityStrataSet`，用于把战斗区域拆成可读的安全/危险/移动层。
- 新增 `ArenaSafeKitePocket_*`：四个低亮度安全走位口袋，帮助玩家理解横向移动空间。
- 新增 `ArenaDangerApproachWedge_*`：四个暗红危险靠近楔形区，给虚空压力一个地面轮廓。
- 新增 `ArenaThreatLaneMatte_*`：敌人流向分隔线，降低满屏单位时的视觉糊成一片。
- 新增 `ArenaBossSightlineMatte_*`：Boss 视线/攻击方向底层，不使用 emissive 材质。
- 新增 `ArenaPickupReservationBand_*`：掉落物预留带，减少奖励和危险弹幕在地面语言上的混淆。

## 敌方弹幕

- 敌方弹幕新增 `EnemyProjectileOcclusionMatte`。
- 该遮罩是非发光暗底，挂在 `EnemyProjectileReadabilityShell` 下，并带 `pickup_confusion_guard=true`。
- 目的不是增加亮度，而是用黑底和红黑危险形状把敌弹从 XP、金币、玩家技能特效里分出来。
- `tests/survivor_projectile_visual_matrix.gd` 已强制检查普通和 lite 敌弹都保留该遮罩。

## 性能边界

- 新增场景层后 arena 静态 mesh 为 `1391`，仍低于 `1800` 上限。
- 高压预算为 `meshes=6698 / 7200`、`nodes=8521 / 9000`，仍在保护线内。
- 这些层全部是低透明/非发光材质，没有新增实时灯光。

## 验证结果

```text
headless init: PASS
SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=1672x941 meshes=1391 citadel_nodes=8 strata=8
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1449
SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.02 ambient=0.13 key=0.98 metal=0.74 rough=0.90 rim=true family=metal/energy/stone
SURVIVOR_SMOKE_OK enemies=104 projectiles=41 pickups=38
SURVIVOR_VISUAL_BUDGET_OK enemies=80 meshes=6698 nodes=8521 projectiles=210 pickups=168 zones=31
```

Godot headless dummy renderer 仍会输出 `mesh_get_surface_count` 噪音；本批判断以退出码和上述 OK 标记为准。
