# 敌方弹幕暗底剪影护栏记录

日期：2026-07-04

## 目标

继续降低敌方弹幕与 XP/金币拾取物混淆的问题。此前弹幕已有红黑三角、碰撞轮廓和地面暗缝，但高密度时仍可能依赖颜色区分。本批加入非发光暗底剪影护栏，让弹幕在经验晶体和奖励光效上方仍有明确危险轮廓。

## 修改

- `scripts/survivor_3d_view.gd`
  - 新增 `EnemyProjectileSilhouetteGuard`。
  - 子层：
    - `EnemyProjectileSilhouetteGuardMatte`
    - `EnemyProjectileSilhouetteDirectionalCut`
    - `EnemyProjectileNoPickupConfusionBand`
  - 材质策略：
    - 全部非发光。
    - alpha 控制在 `0.24-0.34`。
    - `material_grade=low_glare_enemy_projectile_silhouette_guard`。
    - `hazard_shape_language=black_matte_outer_silhouette`。
  - 普通敌弹和高密度 lite 敌弹都会保留该护栏。
  - 同步逻辑接入 `_sync_projectiles()`，随敌弹危险优先级轻微缩放/旋转，但不增加亮度。

- `tests/survivor_projectile_visual_matrix.gd`
  - 普通敌弹和 lite 敌弹均要求存在 `EnemyProjectileSilhouetteGuard`。
  - 验证：
    - enemy hazard 通道。
    - pickup confusion guard 元数据。
    - 低眩光材质等级。
    - 三个必备子节点。
    - mesh 数固定为 3，防止高密度弹幕预算失控。
    - 材质不发光，透明 alpha 不超过 `0.35`。
    - 不允许泄漏到 pickup 视觉通道。

## 验证

仅使用 Godot console/headless，未打开 GUI：

```text
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1721
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7689 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6
SURVIVOR_VISUAL_BUDGET_OK enemies=89 meshes=6443 nodes=8457 projectiles=210 pickups=168 zones=31
SURVIVOR_SMOKE_OK enemies=104 projectiles=46 pickups=32
```

## 结论

本批没有提高眩光预算，密集场景仍低于视觉预算上限。敌方弹幕现在多了一层稳定的暗底剪影，和经验/金币拾取物的视觉语言进一步拉开。
