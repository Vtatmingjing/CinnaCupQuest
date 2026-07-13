# 夜间美术打磨检查点

本检查点记录本轮“接近参考效果图”的后台修改，不启动游戏窗口，只用 Godot headless 验证。

## 已完成方向

- 主竞技场地板升级到原创高质感 v3 横屏地板。
- 高价值掉落物新增图集贴花，普通小 XP 保持克制。
- 普通详细敌人、精英和 Boss 新增物种贴花，lite 敌人不携带。
- 非 lite 玩家弹体新增英雄家族徽记，lite 玩家弹体不携带，保护后期弹幕性能。

## 完整后台回归

已通过：

```text
SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=1672x941 meshes=762
SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=9
SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=1590
SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 meshes=1098
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=9 meshes=509
SURVIVOR_ROGUELIKE_ROUTE_MATRIX_OK fates=4 roll_mix=forced
SURVIVOR_ROUTE_SYNERGY_MATRIX_OK routes=4
SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=330 spawn_steps=late enemy_growth=late
SURVIVOR_SMOKE_OK enemies=86 projectiles=56 pickups=46
SURVIVOR_VISUAL_BUDGET_OK enemies=64 meshes=8003 nodes=9839 projectiles=210 pickups=167 zones=31
```

## 性能边界

- 当前预算上限：`MAX_MESH_INSTANCES = 8400`，`MAX_TOTAL_NODES = 11000`。
- 最新压力结果：`8003` meshes，`9839` nodes。
- 玩家弹体和普通敌人都有 LOD/轻量路径，密集场景会自动去掉部分手绘贴花或高细节节点。

## 后续重点

- 如果继续提升到参考图级别，下一步优先做“英雄主体贴图/授权模型接入流程”或“商店装备图标图集”，而不是无节制给战斗场景加透明贴花。
- 任何新动态视觉层都应继续跑 `survivor_visual_budget_smoke.gd`，避免长期怪潮时 GPU/CPU 压力失控。
