# UI 贴图对齐、低眩光与生存压力 v6

日期：2026-07-04

## 目标

针对试玩反馈继续处理三类问题：

- 选人、升级、海克斯和商店界面贴图容易偏位。
- 3D 画面过亮，敌人、弹幕和掉落在高亮特效里不够清楚。
- 当前难度偏低，后期缺少真正的生存压力。

## 改动

### HUD 贴图对齐

- `scripts/survivor_hud.gd`
  - 英雄头像裁切改为正方形聚焦区域，避免放进 72x72 槽位后再次被 `TextureRect` 二次裁切。
  - `AtlasTexture` 运行时写入 `ui_atlas_grid`、`ui_atlas_cell_rect`、`ui_atlas_safe_inset_px`、`ui_atlas_region_center_locked`。
  - 每个媒体槽写入 `media_rect_locked`，测试会确认贴图、底板和槽位矩形保持一致。

### 低眩光 v6

- `scripts/survivor_3d_view.gd`
  - 环境光从 `0.056` 降到 `0.048`。
  - 曝光从 `0.42` 降到 `0.36`。
  - glow 强度继续降低。
  - 主光、补光和边缘光能量下调。
  - 玩家弹幕、区域、pulse、decal 和通用透明材质 emission 再收紧。
  - 敌方危险轮廓增加 alpha 上下限：最低保持可见，最高不继续形成亮面光污染。

### 生存压力 v6

- `scripts/survivor_main.gd`
  - 首次压力波从 `118s` 提前到 `86s`。
  - 压力波基础间隔从 `34s` 缩短到 `30s`，最低间隔从 `21s` 缩短到 `17.5s`。
  - 压力波护卫数量提高，Boss 存活时额外增加护卫。
  - 压力阶梯提前进入，90 秒后不再长时间低压。

- `scripts/survivor_enemy.gd`
  - 后期非 Boss 敌人攻击冷却缩短更明显。
  - 精英额外攻击压力提高。
  - Boss 低血量激怒后攻击节奏更紧。

## 测试

只使用 Godot headless，没有打开游戏窗口。

通过项：

- `SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7377 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=90 timers=survival_pressure_v6 spawn_steps=challenge_v5 surge=elite_squad_v2 enemy_growth=harder_v5 attacks=pressure_v2`
- `SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.00 ambient=0.05 key=0.48 metal=0.74 rough=0.90`
- `SURVIVOR_PRESSURE_DIRECTOR_VISUAL_MATRIX_OK meshes=6 nodes=7 readiness=0.400`
- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1643`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=6343 nodes=8130 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=45 pickups=31`
- headless 初始化退出码 `0`

## 当前取舍

- 敌方弹幕没有继续降 alpha，因为需要和经验、金币保持区分；这批主要降 emission 和非危险透明层亮度。
- 压力提高优先用时间导演、精英、护卫和攻击节奏实现，没有突破 `MAX_ENEMIES=104`。
- 商业级效果图仍不是一次脚本修改能直接达到，后续应继续补高质量模型/贴图接入和角色专属动作表现。
