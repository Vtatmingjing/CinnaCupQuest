# 敌人入场裂隙更新

本次新增怪物刷出瞬间的短生命周期 3D 表现层，让虚空单位不再像突然弹到场上，而是从贴地裂隙、图集法阵和物种标记中“钻出来”。

## 新增内容

- `scripts/survivor_spawn_rift.gd`
  - 新增 `CinnaSurvivorSpawnRift`，加入 `survivor_spawn_rifts` 分组。
  - 保存敌人类型、是否精英、是否 Boss、半径、颜色和生命周期。
  - 2D 兜底会绘制简单裂隙；3D 模式下仍然隐藏 2D 绘制。

- `scripts/survivor_main.gd`
  - `_spawn_enemy()` 会同步生成入场裂隙事件。
  - 普通怪、喷吐虫、遁地虫、甲壳虫、虚空眼、水晶、Boss 使用不同颜色和半径。
  - 新增 `MAX_SPAWN_RIFTS = 6`，同屏只保留少量重点入场裂隙，精英和 Boss 优先。
  - 裁剪时会立刻移出分组，防止同一帧大量刷怪绕过预算。

- `scripts/survivor_3d_view.gd`
  - 新增 `EnemySpawnRiftSignature` 贴地裂隙环。
  - 新增 `EnemySpawnRiftPortalDecal`，复用海克斯虚空 VFX 图集。
  - 新增 `EnemySpawnRiftSpeciesMark`，按敌人类型显示不同入场符号。
  - 新增 `EnemySpawnRiftPillarRig`，提供短暂升腾碎片。
  - 精英/Boss 新增 `EnemySpawnRiftPriorityCrown`，强化重点敌人登场感。

## 测试覆盖

- `tests/survivor_spawn_rift_visual_matrix.gd`
  - 覆盖普通怪、精英水晶、Boss 维克兹三类入场裂隙。
  - 断言裂隙签名、图集贴花、物种标记、碎片组和精英/Boss 冠环。

- `tests/survivor_headless_smoke.gd`
  - 真实刷怪后确认 3D 场景出现 `EnemySpawnRiftSignature` 和 `EnemySpawnRiftPortalDecal`。

## 性能约束

- 高压预算测试通过：
  - `SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=6755 nodes=8501 projectiles=210 pickups=167 zones=31`

这样可以保留入场质感，同时避免怪潮阶段把 CPU/GPU 压力推高。
