# 卡死修复与性能护栏 2026-07-06

## 问题确认

用户反馈“玩着卡死”。本批没有打开 GUI，只使用 Godot headless 验证。

第一次复测结果：

```text
SURVIVOR_SMOKE_OK enemies=76 projectiles=40 pickups=31
Long-run worst step spike too slow: 1845.34 ms > 850.00 ms.
Long-run mesh budget failed: 5761 > 5600.
```

结论：基础流程能跑，但长局压力下会出现明显卡顿尖峰，主要风险来自动态 3D 模型数量过高，以及敌人/弹幕 LOD 在同一帧集中重建。

## 修复内容

- 运行时上限收紧：敌人 `60`、弹幕 `84`、掉落 `60`、区域 `10`、脉冲 `14`、死亡爆点 `4`、命中特效 `3`、飘字 `12`。
- 3D LOD 更早介入：普通敌人超过 `18` 后进入 lite 模型，弹幕和 XP 掉落更早使用轻量模型。
- LOD 重建分帧执行：敌人每帧最多重建 `2` 个模型，弹幕每帧最多重建 `4` 个模型，避免一次性爆建 mesh。
- 视觉预算门槛收紧：`survivor_visual_budget_smoke.gd` 从 `7200/9000` 收紧到 `5600 mesh / 7200 node`。
- smoke 测试夹具调整：降低初始塞怪数量，并给强制测试水晶临时加高生命，避免自动攻击和低上限干扰“裂隙水晶召唤”断言。

## 回归结果

```text
SURVIVOR_SMOKE_OK enemies=60 projectiles=42 pickups=34
SURVIVOR_VISUAL_BUDGET_OK enemies=51 meshes=4564 nodes=5691 projectiles=84 pickups=55 zones=10
SURVIVOR_LONG_RUN_PERFORMANCE_OK seconds=120 avg_ms=17.30 worst_ms=525.18 enemies=60/60 projectiles=63/65 pickups=24/27 zones=0/0 meshes=4744/4744 nodes=6009/6009
SURVIVOR_STARTUP_VISIBILITY_OK viewport=1280x720 ambient=0.240 exposure=0.820 overlay_alpha=0.88 hero_cards=8 portraits=8
SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=60 projectiles=46 pickups=44 visible=2392 bright=1578 max_luma=1.158 floor_avg=0.137 floor_max=1.000
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=8369 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6
```

## 后续注意

- 后续新增角色、敌人、弹幕美术时，必须先跑视觉预算和 120 秒长压测。
- 新增动态 3D 层优先挂在 Boss、精英和玩家身上，普通怪潮默认走 lite 或共享低成本轮廓。
- 如果继续提升难度，优先提高敌人行为、精英词缀、Boss 招式和数值压力，不优先堆同屏实体数量。
