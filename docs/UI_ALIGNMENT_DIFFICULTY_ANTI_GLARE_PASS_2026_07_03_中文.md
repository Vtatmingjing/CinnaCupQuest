# UI 对齐 / 生存压力 / 低光污染修正记录 - 2026-07-03

## 本批处理的问题

- 选人、升级、海克斯、商店界面的贴图插槽不稳定，部分图标与文字层存在错位或残留。
- 游戏难度偏低，前中期缺少真正的生存压力。
- 3D 画面发光过强，敌人、敌方弹幕、XP 和技能特效容易混在一起。
- 需要继续保持性能预算，不能靠无上限堆怪和堆光效解决体验问题。

## 已修改

- `scripts/survivor_hud.gd`
  - 为选人、升级/海克斯/命运、商店卡片统一加入媒体插槽 profile。
  - 每张卡片记录 `media_slot_profile`、`media_slot_center`、`media_inner_rect`，测试可直接断言贴图是否进入正确区域。
  - 切页时清理隐藏卡片的贴图位置、尺寸、旧文字和插槽元数据，避免旧图层叠到新界面。
  - 选人肖像改为覆盖式裁切，升级/海克斯/商店图标改为居中适配。
  - 4x4 图集取图时加入内缩，避免相邻格子的边缘串色。

- `scripts/survivor_main.gd`
  - 刷怪间隔改为更快衰减，后期最小间隔收紧到更高压状态。
  - 精英怪首次出现和后续刷新提前，波次越高刷新窗口越短。
  - 单次刷怪包数量提高，但仍通过 `MAX_ENEMIES` 上限保护性能。

- `scripts/survivor_enemy.gd`
  - 普通敌人的生命、速度、伤害随波次成长更明显。
  - Boss 的生命、速度、伤害和奖励重新上调，避免只像普通怪的大号版本。

- `scripts/survivor_3d_view.gd`
  - 降低环境光、曝光、Glow、Bloom、主光、补光和边缘光。
  - 降低拾取物、玩家弹道、区域技能、贴花、死亡爆发的发光预算。
  - 普通 XP 缩小并降亮，让敌方弹幕比奖励物更容易被优先识别。
  - 敌方弹幕保留暗芯、地面分离和危险轮廓，不再靠过亮发光提示危险。

## 验证结果

本批没有启动游戏 GUI，只使用 Godot headless。关键矩阵和 smoke 测试全部退出码为 0：

```text
SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean
SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=105 timers=survival_pressure_plus spawn_steps=challenge_hard enemy_growth=hard
SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.01 ambient=0.10 key=0.84 metal=0.74 rough=0.90 rim=true family=metal/energy/stone
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1449
SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=159
SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=38
SURVIVOR_VISUAL_BUDGET_OK enemies=85 meshes=6734 nodes=8572 projectiles=210 pickups=168 zones=31
```

备注：Godot 4.3 headless dummy renderer 仍会输出 `Parameter "m" is null` 噪声；本批以脚本退出码 0 和上述 `SURVIVOR_*_OK` 标记为准。
