# 低光污染与生存压力 V2 调整记录

日期：2026-07-03

## 本轮目标

针对试玩反馈继续处理三类问题：

- 场内特效过亮，敌人、弹幕、经验球容易混在一起。
- 人物选择、升级、海克斯选择和商店卡片贴图需要保持对齐验证。
- 当前难度偏低，5 分钟后缺少持续生存挑战。

## 修改内容

### 低光污染

- 下调 3D 环境光、曝光、glow、主光、补光和轮廓光强度。
- 下调透明材质 alpha 与 emission 预算，重点覆盖拾取物、区域技能、玩家弹体、敌方弹幕和死亡爆发。
- 新增 `tests/survivor_glare_budget_matrix.gd`，批量生成英雄、敌人、Boss、玩家弹体、敌方弹幕和拾取物，检查全局发光、透明层、拾取物发光、敌方危险背板可见度。
- 修正测试分类：敌方弹幕的 `EnemyProjectilePickupSeparationRing` 用于区分弹幕和拾取物，不再被误算为拾取物本体。

### 生存压力

- 首个精英到场时间从 4.4 秒收紧到 3.8 秒。
- 精英循环计时从 `4.2 - wave * 0.66` 收紧到 `3.9 - wave * 0.70`，最低间隔从 1.65 秒收紧到 1.35 秒。
- 刷怪基础间隔从 0.26 秒收紧到 0.24 秒，最低间隔从 0.034 秒收紧到 0.030 秒。
- 新增导演压力阶梯：90 秒、150 秒、240 秒、360 秒和 Boss 出现后逐段提高刷怪包数量与精英压力。
- 保持 `MAX_ENEMIES = 104`，不靠无限堆实体制造难度，继续保护 CPU/GPU。
- 中后期普通敌人的生命和速度成长提高；精英敌人的额外生命、速度随导演压力继续抬升。

### UI 与素材对齐

- 保留上一轮 HUD 对齐修复，并继续用 `survivor_hud_visual_matrix.gd` 验证英雄头像、升级卡、海克斯卡、商店卡的媒体槽、标题、描述、价格和路线标签不会叠层。

## 验证结果

已顺序运行全部 `tests/*.gd`，未打开游戏 GUI。

```text
SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=1672x941 meshes=1420 citadel_nodes=8 strata=8
SURVIVOR_BOSS_BEHAVIOR_MATRIX_OK bosses=4
SURVIVOR_BOSS_CAST_PATTERN_MATRIX_OK bosses=4 meshes=151
SURVIVOR_BOSS_CINEMATIC_STATE_MATRIX_OK bosses=4 states=20
SURVIVOR_BOSS_PHASE_STATE_VISUAL_MATRIX_OK bosses=4
SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=2610 ability_atlas=1536x1024
SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=105 timers=survival_pressure_v2 spawn_steps=challenge_v2 enemy_growth=harder_v2
SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2444
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=6958 models=46 emission=0.155 alpha=0.392 enemy=0.112 player=0.068 pickup=0.025 danger=0.280
SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean
SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.00 ambient=0.08 key=0.68 metal=0.74 rough=0.90 rim=true family=metal/energy/stone
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1449
SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=33
SURVIVOR_VISUAL_BUDGET_OK enemies=86 meshes=6830 nodes=8682 projectiles=210 pickups=168 zones=31
```

说明：Godot 4.3 headless dummy renderer 仍会输出 `mesh_get_surface_count` 噪声。本轮以退出码 0 和 `SURVIVOR_*_OK` 标记作为通过依据。
