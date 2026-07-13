# 压力波战术构成整改记录

日期：2026-07-04

## 目标

针对“游戏普遍太简单、缺少生存挑战”的反馈，本批不继续粗暴提高总怪物数量，也不增加额外高亮特效，而是强化压力波的敌人组合：

- 压力波会记录并使用战术 profile。
- 每次压力波稳定混入突进、远程炮台、肉盾等职责。
- Boss 存活时压力波切换为护卫封锁型构成。
- 不突破现有敌人、子弹、节点、mesh 和光污染预算。

## 修改文件

- `scripts/survivor_main.gd`
  - 新增 `last_pressure_surge_profile`、`last_pressure_surge_role_counts`、`last_pressure_surge_escort_kinds`，用于测试和回归检查。
  - `_trigger_pressure_surge()` 不再完全依赖随机敌人池，而是通过 profile 生成 escort 阵容。
  - 新增压力波 profile、敌人职责分类、按职责控制出生距离的辅助函数。

- `tests/survivor_difficulty_curve_matrix.gd`
  - 增加压力波 tactical escort 记录检查。
  - 增加 diver / artillery / tank 职责必须出现的断言。
  - 标记更新为 `surge=tactical_mix_v1`。

## Headless 验证

以下验证均使用 `D:\Godot\Godot_v4.3-stable_win64_console.exe`，没有打开游戏 GUI。

- `SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=90 timers=survival_pressure_v7 spawn_steps=challenge_v6 surge=tactical_mix_v1 enemy_growth=harder_v5 attacks=pressure_v2`
- `SURVIVOR_PRESSURE_DIRECTOR_VISUAL_MATRIX_OK meshes=18 nodes=20 readiness=0.400 routes=composition_lanes`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7689 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=89 meshes=6498 nodes=8510 projectiles=210 pickups=168 zones=31`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=42 pickups=31`

备注：Godot headless/dummy renderer 仍会输出大量 `Parameter "m" is null` 和退出清理噪声；本批以脚本 OK 标记和无脚本错误为准。
