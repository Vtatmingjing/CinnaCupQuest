# UI 对齐、难度与低眩光可读性更新

日期：2026-07-03

## 目标

本轮针对试玩反馈集中处理三类问题：

- 选人、升级、海克斯、商店卡片的贴图没有对齐。
- 当前难度偏低，缺少持续生存压力。
- 画面光污染过强，敌人、敌弹和 XP 掉落容易混在一起。

## 已完成

- `scripts/survivor_hud.gd`
  - 选人头像和卡片图标统一使用 `TextureRect.EXPAND_IGNORE_SIZE` 与 `STRETCH_KEEP_ASPECT_CENTERED`。
  - 选人卡片加宽，头像列和标题列分离。
  - 升级、海克斯、命运选择卡片加高加宽，图标尺寸按卡片高度动态适配。
  - 商店图标继续使用装备 atlas，并保留价格、路线标签与推荐标识。

- `scripts/survivor_main.gd`
  - 波次推进从 34 秒缩短到 30 秒。
  - 刷怪间隔改为 `maxf(0.22, 1.06 - elapsed * 0.0032)`。
  - 精英间隔改为 `maxf(12.5, 23.0 - wave * 0.75)`。
  - 中后期刷怪包新增 wave 8、180 秒压力阶梯。
  - 敌人池减少普通 `voidling` 占比，更早加入远程、冲锋、坦克和召唤型虚空敌人。
  - XP 颜色从高荧光绿/青改为更收敛的绿蓝梯度。

- `scripts/survivor_enemy.gd`
  - 非 Boss 敌人中后期血量、速度、伤害增长提高。
  - `spitter`、`void_eye`、`rift_crystal`、`burrower` 攻击节奏加快。

- `scripts/survivor_3d_view.gd`
  - 降低透明能量材质 emission、rim、clearcoat，减少发光边缘糊成一片。
  - 敌方弹体保留黑芯、红色危险环、轨迹箭头，但降低泛光和贴花亮度。
  - XP、金币、治疗、护盾与高价值奖励降低光柱、地面 halo 和 hover glyph 亮度。
  - 通用晶体 glow 降低，减少同屏拾取物过多时的亮面噪声。

## 验证

已通过 Godot headless，无 GUI：

- `SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=270 timers=pressure spawn_steps=pressure enemy_growth=late`
- `SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.24 ambient=0.46 key=2.40 metal=0.74 rough=0.90 rim=true family=metal/energy/stone`
- `SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=9 shop_cards=3`
- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1319`
- `SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=159`
- `SURVIVOR_SMOKE_OK enemies=88 projectiles=62 pickups=48`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=5489 nodes=7079 projectiles=210 pickups=167 zones=31`
- `D:\Godot\Godot_v4.3-stable_win64_console.exe --headless --path . --quit`

说明：Godot 4.3 headless dummy renderer 仍会输出 `Parameter "m" is null` 噪音。本轮按退出码 0 和上述 OK 标记判定通过。
