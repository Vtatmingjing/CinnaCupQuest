# HUD、难度与可读性修正记录

日期：2026-07-03

## 本批目标

- 修复选人、升级、海克斯和商店界面的贴图/文字对齐问题。
- 避免旧错码文本继续出现在 HUD，可见界面改为正常中文。
- 降低英雄地面特效和身份特效亮度，减少光污染。
- 提高生存挑战，避免前中期过于简单。

## 已修改

- `scripts/survivor_hud.gd`
  - 新增 HUD 本地化展示层，覆盖选人、升级、命运、海克斯、商店、结算和战斗状态栏。
  - 商店卡片改用干净布局：图标、标题、描述、价格牌、路线标签分区显示。
  - 图标匹配支持正常中文关键字，避免升级/海克斯/装备卡片拿错图。

- `scripts/survivor_3d_view.gd`
  - 新增 `ChampionIdentityBackplateRig`：低亮度英雄身份背板、方向箭头、射程提示和专属符号。
  - 降低英雄地面标记、光环、标记球等表现的自发光强度，减少和弹幕/经验掉落混淆。

- `scripts/survivor_main.gd`
  - Boss 出场从 240 秒提前到 210 秒。
  - 刷怪间隔更短，精英刷新更频繁。
  - 中后期每波敌人数量提高，但仍保留 `MAX_ENEMIES` 性能上限。

- `scripts/survivor_enemy.gd`
  - 中后期普通敌人的生命、速度、伤害成长提高。

- `tests/survivor_hud_visual_matrix.gd`
  - 增加 HUD 可见文本错码检查。
  - 继续检查头像、升级、海克斯、商店图标居中和不压文字列。

- `tests/survivor_champion_visual_matrix.gd`
  - 增加英雄身份背板结构、元数据和低光污染材质检查。

- `tests/survivor_difficulty_curve_matrix.gd`
  - 更新 Boss 时间、刷怪间隔和波次压力门槛。

## 验证

- `HEADLESS_INIT_OK`
- `SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=9 shop_cards=3`
- `SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=2515 ability_atlas=1536x1024`
- `SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=210 timers=survival_pressure spawn_steps=challenge enemy_growth=late`
- `SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.18 ambient=0.40 key=2.18 metal=0.74 rough=0.90 rim=true family=metal/energy/stone`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=68 meshes=5812 nodes=7454 projectiles=210 pickups=167 zones=31`
- `SURVIVOR_SMOKE_OK enemies=92 projectiles=61 pickups=40`

备注：Godot dummy/headless renderer 仍会输出 `Parameter "m" is null` 和一次资源清理警告，但本批验证 exit code 均为 0。
