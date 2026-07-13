# 敌方弹幕低眩光危险刀锋层

## 目标

继续处理“敌人弹幕容易和经验/掉落混淆”的问题。该批次不增加高亮 glow，而是在敌方弹幕的 full 与 lite LOD 中都加入红黑危险刀锋轮廓，让密集场景下的敌弹边界更硬、更容易和 XP/金币区分。

## 本批改动

- 新增 `EnemyProjectileDangerBladeRig`
  - 挂在 `EnemyProjectileReadabilityShell` 下。
  - full 与 lite 敌方弹幕都会生成。
  - `combat_visual_channel = enemy_hazard`
  - `pickup_confusion_guard = true`
  - `hazard_shape_language = red_black_directional_blade`
- 子节点：
  - `EnemyProjectileDangerBladeBlackLeft`
  - `EnemyProjectileDangerBladeBlackRight`
  - `EnemyProjectileDangerBladeRedLeft`
  - `EnemyProjectileDangerBladeRedRight`

## 视觉原则

- 低眩光：新增材质 emission 为 0。
- 高辨识：用红黑侧向刀锋表达“这是敌方危险物”，不使用 XP/金币常见的晶体/宝石形状。
- LOD 友好：lite 弹幕也保留刀锋层，避免怪物多时危险信息被降级删掉。
- 性能可控：每个敌方弹幕增加 4 个低面数 BoxMesh，不增加实时灯光、粒子或贴图读取。

## 测试覆盖

- `tests/survivor_projectile_visual_matrix.gd`
  - 检查 full 与 lite 敌方弹幕都存在 `EnemyProjectileDangerBladeRig`。
  - 检查 4 个刀锋子节点都存在且有 mesh 内容。
  - 检查 `enemy_hazard` 通道、`pickup_confusion_guard` 和 `red_black_directional_blade` 元数据。
- 后续回归使用：
  - `tests/survivor_glare_budget_matrix.gd`
  - `tests/survivor_visual_budget_smoke.gd`
  - `tests/survivor_headless_smoke.gd`

## 验证命令

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\survivor_projectile_visual_matrix.log --path . --script res://tests/survivor_projectile_visual_matrix.gd
```

期望输出：

```text
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK
```
