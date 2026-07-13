# Boss 占场、密集精英 LOD 与压力波调整记录

## 目标

针对当前反馈：

- 场内光效过亮，敌人与弹幕容易混淆。
- 游戏整体压力不足，缺少生存挑战。
- 高密度怪物时需要保护 CPU/GPU，不允许靠堆节点解决表现。
- Boss/精英需要更有辨识度，不能只是普通怪放大。

## 改动

### Boss 场地封锁层

新增 `BossArenaLockdownRig`：

- 只在 Boss 出现后懒加载。
- 绑定当前 Boss 类型，只显示对应的专属图案：
  - `BossArenaLockdownChoMaw`
  - `BossArenaLockdownVelkozEye`
  - `BossArenaLockdownReksaiTunnel`
  - `BossArenaLockdownBelvethCrown`
- 材质使用 `low_glare_boss_arena_lockdown`，低发光、低透明度，避免增加光污染。
- 包含四角锚点、四条封锁链、中心封印，让 Boss 战场更像被虚空占领的区域。

### 密集精英轻量 LOD

高敌人数量时，普通精英从完整模型切换到 `dense_elite_lod`：

- 保留精英特性标记、特性读条、战斗意图、血条和奖励提示。
- 去掉完整高阶装饰层，显著降低节点数量。
- 普通低密度精英仍使用完整模型，保留展示质量。

### 难度压力波

调整压力波节奏：

- 第一波压力波从 86 秒提前到 74 秒。
- 压力波基础间隔从 30 秒降到 28 秒，最低 15 秒。
- 150 秒后压力波改为双精英小队。
- Boss 存活期间压力波护卫数量增加。
- 敌人接近上限时不再过度削弱刷怪包，保持生存压力。

### 性能保护

仍保留硬上限：

- `MAX_ENEMIES = 104`
- `MAX_PROJECTILES = 210`
- `MAX_PICKUPS = 170`

密集场景通过 LOD 降节点，不提高硬上限。

## 验证

已通过的关键标记：

```text
SURVIVOR_BOSS_CAST_PATTERN_MATRIX_OK bosses=4 meshes=403
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7533 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6
SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2619
SURVIVOR_ELITE_TRAIT_STATE_VISUAL_MATRIX_OK traits=4
SURVIVOR_VISUAL_BUDGET_OK enemies=90 meshes=5945 nodes=7684 projectiles=210 pickups=168 zones=31
SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=90 timers=survival_pressure_v7 spawn_steps=challenge_v6 surge=elite_squad_v3 enemy_growth=harder_v5 attacks=pressure_v2
```

后续完整 smoke 与启动稳定性验证仍需在最终回归批次中持续执行。
