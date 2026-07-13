# 敌人战术职责铭牌整改记录

日期：2026-07-04

## 目标

继续改善“怪物千篇一律、混战中不容易分辨”的问题。本批不靠提高亮度或增加粒子，而是在非 lite 敌人模型上增加低眩光战术职责铭牌：

- `diver`：突进/钻地类，例如 skitter、burrower、Rek'Sai 风格 Boss。
- `artillery`：远程炮台/射线类，例如 spitter、void_eye、Vel'Koz 风格 Boss。
- `tank`：肉盾/甲壳类，例如 carapace、Cho'Gath 风格 Boss。
- `summoner`：召唤/场地节点类，例如 rift_crystal、Bel'Veth 风格 Boss。
- `swarm`：基础虫群。

铭牌使用暗色底板、低透明职责 glyph、面向刻度和小型职责 detail。lite 敌人在高密度场景中不携带该层，避免同屏怪多时增加性能压力。

## 修改文件

- `scripts/survivor_3d_view.gd`
  - 新增 `EnemyTacticalReadabilityPlaque`。
  - 新增 `enemy_role`、`detail_node`、`material_grade=low_glare_enemy_tactical_plaque`、`pickup_confusion_guard=true` 元数据。
  - 在 `_sync_enemies()` 中加入极轻量的旋转/呼吸同步，增强俯视角识别。
  - lite 敌人不创建该节点。

- `tests/survivor_enemy_visual_matrix.gd`
  - 普通怪、精英怪、Boss、Boss 变体都必须拥有战术职责铭牌。
  - lite 敌人必须不携带该铭牌。
  - 铭牌必须包含 `EnemyTacticalPlaqueBackplate`、`EnemyTacticalPlaqueRoleGlyph`、`EnemyTacticalPlaqueFacingTick` 和职责 detail 节点。
  - 材质预算限制为低眩光：最大 emission `0.01`，透明 alpha `0.31`。

## Headless 验证

以下验证均使用 Godot console/headless，没有打开游戏 GUI。

- `SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2824`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7759 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=5819 nodes=7652 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=32`

备注：Godot headless/dummy renderer 仍会输出 `Parameter "m" is null` 和退出清理噪声；本批没有新增脚本错误或解析错误。
