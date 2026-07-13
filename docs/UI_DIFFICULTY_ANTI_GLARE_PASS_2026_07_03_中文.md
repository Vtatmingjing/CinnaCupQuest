# UI / 难度 / 低光污染修正记录 - 2026-07-03

## 本批目标

- 修正选人、升级、海克斯、商店卡片里贴图和文字列不稳定的问题。
- 让商店真正能把全部 18 个商品挂出来，同时不压到底部按钮和提示。
- 提高生存压力，避免前几分钟过于无脑站桩。
- 降低 3D 场景光污染，让敌方弹幕靠危险轮廓和暗芯区分，而不是靠更亮的发光。

## 已修改

- `scripts/survivor_hud.gd`
  - 新增统一卡片布局函数：选人、升级/海克斯/命运、商店分别从同一个 1280x720 面板坐标推导。
  - 新增非活跃卡片清理逻辑：切换选人、升级、海克斯、命运和商店页面时，会清空隐藏卡片的贴图、徽章、价格和旧文字，避免上一页残留图层叠到当前选择项上。
  - 选人卡片标题给右侧徽章预留空间，文字超出时裁切省略，避免压到肖像或徽章。
  - 商店卡片改为 3 列 6 行容量，支持 18 个商品同时显示。
  - 商店页把离开商店、音效、返回选人按钮和提示移到顶部，底部留给商品列表。

- `scripts/survivor_main.gd`
  - Boss 时间进一步提前到 150 秒。
  - 开局精英计时从 16 秒压到 13 秒，中期精英刷新窗口也缩短。
  - 刷怪间隔和每波数量继续提高，120 秒后进入更明确的生存压力段。
  - 敌人硬上限从 `MAX_ENEMIES = 92` 提高到 `104`，同时继续由统一刷怪入口保护性能预算。
  - 随机治疗掉落率降低，减少靠掉落硬扛的无脑容错。

- `scripts/survivor_enemy.gd`
  - 非 Boss 敌人的生命、速度、伤害随波次成长更明显。
  - 接触伤害冷却缩短，让贴身怪潮更接近生存肉鸽压力。

- `scripts/survivor_3d_view.gd`
  - 降低环境光、曝光、Glow、补光和边缘光强度。
  - 继续压低拾取物、玩家技能、区域效果、贴花的发光预算。
  - 敌方弹幕新增 `EnemyProjectileDarkGroundGap` 和 `EnemyProjectileThreatOutline`，用暗芯、地面分离和红色危险轮廓提高辨识度。
  - 修复玩家弹道签名/职业轮廓材质没有进入玩家弹道低眩光预算的问题。
  - 修复高价值拾取物顶部徽章里默认 `crystal_*` 材质过亮的问题，统一改为 `pickup_treasure_*` 前缀。

- 测试更新
  - `tests/survivor_hud_visual_matrix.gd` 扩展到 18 个商店商品，并检查卡片在面板内、不重叠、贴图居中、文字/价格/路线不越界；现在还会断言页面切换后非活跃卡片不残留贴图或旧文字。
  - `tests/survivor_difficulty_curve_matrix.gd` 改为 Boss 150 秒、精英和刷怪压力更严格。
  - `tests/survivor_material_quality_matrix.gd` 固化更低的 Glow / 灯光阈值。
  - `tests/survivor_projectile_visual_matrix.gd` 要求敌方弹幕有暗芯、分离圈和危险轮廓。
  - `tests/survivor_pickup_visual_matrix.gd` 收紧拾取物发光预算。

## 当前验证状态

- 全量 Godot headless survivor 回归 24 项已通过。
- Godot headless 测试已启动过，先后抓到并修复：
  - 英雄选择第 8 张卡标题与徽章重叠。
  - 商店价格标签越界。
  - 商店路线标签越界。
- 本批复跑完整 Godot headless 回归，全部退出码为 0：
  - `SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=24 shop_cards=18 layout=aligned`
  - `SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=150 timers=survival_pressure spawn_steps=challenge enemy_growth=late`
  - `SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.05 ambient=0.24 key=1.42 metal=0.74 rough=0.90 rim=true family=metal/energy/stone`
  - `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1371`
  - `SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=159`
  - `SURVIVOR_VISUAL_BUDGET_OK enemies=80 meshes=6235 nodes=8000 projectiles=210 pickups=168 zones=31`
  - `SURVIVOR_SMOKE_OK enemies=101 projectiles=62 pickups=38`
  - `FULL_SURVIVOR_REGRESSION_OK tests=24`
- 备注：Godot 4.3 headless dummy renderer 仍会输出 `Parameter "m" is null` 噪声；本批以脚本退出码 0 和上述 `SURVIVOR_*_OK` 标记为准。
