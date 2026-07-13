# 反光污染与生存压力修正记录

日期：2026-07-03

## 目标

- 降低 3D 场景、弹幕、拾取物和技能 FX 的整体亮度，减少光污染。
- 让敌方弹幕优先级高于 XP 和金币掉落，避免玩家把危险弹幕看成奖励物。
- 提高生存挑战，避免前中期过于简单。
- 保持性能预算，不通过无限堆怪制造难度。

## 修改

- `scripts/survivor_3d_view.gd`
  - 降低环境光、曝光、bloom、主光、填充光和边缘光。
  - 新增材质发光上限：敌方弹幕、玩家技能、拾取物、区域效果和 decal 分组限幅。
  - 将普通 XP 水晶改为 `pickup_xp_crystal` 材质前缀，使其走拾取物降亮规则。
  - 将 Senna、Viktor、Xayah、Teemo、火箭、子弹、彗星等英雄技能弹体归入玩家技能材质预算，避免漏限幅。

- `scripts/survivor_main.gd`
  - Boss 首次出现从 210 秒提前到 180 秒。
  - 开局和重开后的精英计时统一为 22 秒。
  - 刷怪间隔缩短，波次和时间阈值更早增加刷怪数量。
  - 保留 `MAX_ENEMIES = 92`，继续用上限保护性能。

- `scripts/survivor_enemy.gd`
  - 普通敌人的中后期生命、速度和伤害成长提高。
  - 伤害成长节点提前，让生存压力更早出现。

- `tests/survivor_projectile_visual_matrix.gd`
  - 新增弹幕材质预算断言，限制玩家技能和敌方弹幕的发光强度及透明 alpha。

- `tests/survivor_pickup_visual_matrix.gd`
  - 新增拾取物材质预算断言，限制普通 XP 和高价值奖励的发光强度。

- `tests/survivor_material_quality_matrix.gd`
  - 收紧环境光、曝光、bloom、灯光和 VFX decal 的上限。

- `tests/survivor_difficulty_curve_matrix.gd`
  - 更新 Boss 180 秒、精英计时、刷怪间隔和刷怪数量断言。

- `tests/survivor_headless_smoke.gd`
  - 固定随机种子。
  - smoke 测试玩家使用高血量/护盾，避免视觉结构测试被真实战斗伤害随机打断。

## 验证

Godot headless 小回归通过：

```text
SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.13 ambient=0.34 key=1.86 metal=0.74 rough=0.90 rim=true family=metal/energy/stone
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1319
SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=159
SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=180 timers=survival_pressure spawn_steps=challenge enemy_growth=late
SURVIVOR_VISUAL_BUDGET_OK enemies=67 meshes=5766 nodes=7420 projectiles=210 pickups=167 zones=31
SURVIVOR_SMOKE_OK enemies=92 projectiles=62 pickups=40
```

备注：Godot 4.3 headless dummy renderer 仍会输出 `Parameter "m" is null` 噪声；本批以脚本退出码 0 和上述 `SURVIVOR_*_OK` 标记为准。
