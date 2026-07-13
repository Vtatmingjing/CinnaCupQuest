# 场景层次与敌人剪影修正记录 - 2026-07-03

## 本批目标

- 继续往参考图的暗色高对比、中心战斗盘、低眩光金属/虚空风格推进。
- 让敌人在密集掉落、弹幕和技能特效中更容易被看出来。
- 不通过提高发光强度解决辨识度问题，保持 CPU/GPU 预算可控。
- 不启动游戏窗口，只用 Godot headless 验证。

## 已修改

- `scripts/survivor_3d_view.gd`
  - 新增 `ArenaDepthPlatformSet`：在战斗区底层加入暗色八边形中心地台、内层战斗盘、核心焦点、低亮金边、虚空/海克斯阵营嵌线、弹幕/拾取物隔离暗缝。
  - 新增 `EnemyGroundSilhouettePlate`：非 LOD 敌人、精英和 Boss 都获得低眩光地面剪影牌。
  - 地面剪影按敌人职责区分形态：扑击爪痕、酸液囊、潜地轨迹、装甲壳、聚焦眼、召唤晶体、吞噬巨口、翼群扫击。
  - 剪影牌只使用低 alpha、无发光材质，目的是把敌人从 XP、弹幕和技能特效里分离出来，而不是继续加亮。
  - LOD 简化敌人不携带剪影牌，避免高密度怪潮时节点数失控。

- `tests/survivor_arena_visual_matrix.gd`
  - 新增对 `ArenaDepthPlatformSet` 的结构、元数据、地台组件数量和低眩光材质断言。

- `tests/survivor_enemy_visual_matrix.gd`
  - 新增对 `EnemyGroundSilhouettePlate` 的结构、敌人类型元数据、职责形态、低眩光材质预算断言。
  - 断言 LOD 敌人不能携带该剪影牌。

## 验证结果

```text
SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=1672x941 meshes=1420 citadel_nodes=8 strata=8
SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2444
SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.01 ambient=0.10 key=0.84 metal=0.74 rough=0.90 rim=true family=metal/energy/stone
SURVIVOR_SMOKE_OK enemies=104 projectiles=42 pickups=38
SURVIVOR_VISUAL_BUDGET_OK enemies=85 meshes=6838 nodes=8691 projectiles=210 pickups=168 zones=31
```

headless 初始化退出码为 0。Godot 4.3 headless dummy renderer 仍会输出 `Parameter "m" is null` 噪声，本批仍以退出码和 `SURVIVOR_*_OK` 标记为准。
