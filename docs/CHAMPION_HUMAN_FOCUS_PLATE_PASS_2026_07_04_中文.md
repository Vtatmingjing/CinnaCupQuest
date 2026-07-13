# 英雄人类视线聚焦层 - 2026-07-04

本批继续朝海克斯/虚空 3D 效果图方向打磨，但优先解决玩家实际游玩时“看不清自己在哪里、弹幕/经验/敌人混在一起”的问题。

## 改动

- 新增 `ChampionHumanFocusPlate`，挂在每个英雄 3D 模型脚下。
- 聚焦层包含：
  - `HumanFocusMatteDisc`：低透明度定位底板，让玩家位置在复杂场面中更稳定。
  - `HumanFocusSafeOrbit`：低亮度安全间距环，帮助判断走位空间。
  - `HumanFocusFacingArrow`：朝向箭头，降低战斗中方向感丢失。
  - `HumanFocusDodgeLaneRoot`：四个短走位刻度，辅助看清闪避方向。
  - `HumanFocusClassGlyph`：根据近战、远程、法师、召唤等不同定位显示不同职业提示。
- 新增 `_sync_champion_human_focus_plate()`：
  - 同步血量压力和攻击准备度。
  - 低血量时略微扩张，提醒玩家当前危险，但不额外加亮。
- `tests/survivor_champion_visual_matrix.gd` 加入硬约束：
  - 每个英雄必须有聚焦层。
  - 必须带低光污染材质等级。
  - 必须有玩家定位、朝向、走位、职业提示。
  - 必须通过透明度/发光预算检查。

## 验证

以下均为 Godot headless 验证，没有打开游戏 GUI。

- 初始化通过，无 GDScript 解析错误。
- `SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=3073 ability_atlas=1536x1024 archetype=role_silhouette`
- `SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=103 projectiles=35 pickups=44 visible=3277 bright=2719 max_luma=1.000 floor_avg=0.137 floor_max=1.000`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=40 pickups=33`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7977 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=89 meshes=6819 nodes=8886 projectiles=210 pickups=168 zones=31`

## 设计备注

- 这批不追求更亮，而是提升画面秩序和玩家定位。
- 聚焦层使用 `champion_focus_readability` 通道，和敌方危险弹幕、拾取物保持语义分离。
- 后续继续做美术提升时，应沿用这个规则：先让玩家能看清自己、敌人、危险弹幕，再考虑更复杂的特效。
