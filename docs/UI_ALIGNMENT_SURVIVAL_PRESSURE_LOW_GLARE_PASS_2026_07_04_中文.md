# UI 对齐、生存压力与低光污染修正记录 - 2026-07-04

本批针对试玩反馈里的三个直接问题处理：

- 选人、升级、海克斯和商店界面贴图/按钮/提示文字错位。
- 场内生存压力不足，5 分钟后仍缺少挑战。
- 3D 画面和技能/拾取物发光偏亮，敌人、弹幕、经验容易混在一起。

## UI 对齐

- `scripts/survivor_hud.gd`
  - 给英雄头像、升级/海克斯图标、商店装备图标写入明确的 `media_slot_rect` 元数据。
  - 底部提示文字改为单行裁剪和省略，避免长文本撑开后叠到旧图层。
  - 默认按钮行整体上移，避开底部提示。
  - 商店提示缩到左侧说明区，商店按钮保持右上，18 张商品卡整体下移，避免提示/按钮压住第一排商品。

- `tests/survivor_hud_visual_matrix.gd`
  - 新增媒体槽矩形断言：英雄头像、升级/海克斯图标、商店装备图标必须锁在固定槽位。
  - 新增商店布局和非商店布局断言，防止从商店返回升级界面后继续残留商店按钮位置。

## 生存压力

- `scripts/survivor_main.gd`
  - 刷怪节奏从 `0.24/0.0068/0.030` 收紧到 `0.20/0.0075/0.026`。
  - 首个精英从 `3.8s` 提前到 `3.0s`，精英刷新下限从 `1.35s` 收紧到 `1.05s`。
  - 刷怪包改为分段压力曲线：45/90/135/210/300/390 秒逐步加压。
  - 早期怪池加入更多小冲锋怪，中期更早混入远程/钻地/坦型/召唤型虚空怪。
  - 保留 `MAX_ENEMIES = 104` 上限，高占用时自动缩小单次补包，避免靠无限堆数量制造难度。

- `scripts/survivor_enemy.gd`
  - 中后期普通怪生命、速度继续成长。
  - 非 Boss 敌人随波次提高攻击频率，远程怪后期会更频繁制造走位压力。

- `tests/survivor_difficulty_curve_matrix.gd`
  - 收紧开局精英、刷怪计时、中后期刷怪包和后期远程攻击频率断言。
  - 清理测试敌人改为即时释放，避免不同用例之间残留 group 计数污染。

## 低光污染

- `scripts/survivor_3d_view.gd`
  - 玩家技能、玩家弹体、区域/脉冲、拾取物和贴花材质的 alpha 与 emission 再下调。
  - 敌方弹幕保留暗红危险轮廓和暗芯，减少和 XP/金币/技能光效混淆，但不再靠高亮泛光提示危险。

- `tests/survivor_glare_budget_matrix.gd`
  - 全局发光阈值收紧到 `0.161`。
  - 敌方弹幕发光阈值收紧到 `0.121`。
  - 玩家弹体发光阈值收紧到 `0.086`。
  - 拾取物发光阈值收紧到 `0.053`。

- `tests/survivor_projectile_visual_matrix.gd`
  - 玩家弹体和敌方弹体的材质预算同步收紧。

- `tests/survivor_pickup_visual_matrix.gd`
  - XP、金币、治疗、护盾和高价值奖励的材质预算同步收紧。

## 本批验证

已通过 Godot headless targeted 验证：

```text
SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean
SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=105 timers=survival_pressure_v3 spawn_steps=challenge_v3 enemy_growth=harder_v3 attacks=pressure
SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.00 ambient=0.08 key=0.68 metal=0.74 rough=0.90 rim=true family=metal/energy/stone
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=6958 models=46 emission=0.128 alpha=0.372 enemy=0.102 player=0.057 pickup=0.025 danger=0.266
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1449
SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=159
SURVIVOR_VISUAL_BUDGET_OK enemies=87 meshes=6675 nodes=8508 projectiles=210 pickups=168 zones=31
SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=32
```

下一步建议继续看两件事：

- 在不打开 GUI 的前提下继续加强敌人/Boss 行为差异测试，避免所有英雄和怪潮仍然玩起来像同一种攻击节奏。
- 后续如果要进一步逼近参考图，需要接入更高质量的角色/怪物授权图集或外部模型资产；当前程序化 3D 已经继续压低光污染和锁住性能预算。
