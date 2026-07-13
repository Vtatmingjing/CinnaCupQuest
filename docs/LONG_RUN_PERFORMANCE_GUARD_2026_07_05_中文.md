# 120 秒长压测与卡死修复记录

## 背景

玩家反馈实际试玩会卡死。之前的测试主要覆盖启动、短时间 smoke、可读性和静态高压预算，但没有覆盖“持续玩一段时间后是否还稳”。

## 本批修复

- 将 3D 实战实体预算收紧：
  - 敌人上限从 `104` 降到 `76`。
  - 弹体上限从 `210` 降到 `130`。
  - 掉落上限从 `170` 降到 `110`。
  - 区域技能上限从 `30` 降到 `16`。
  - 脉冲、死亡爆发、出生裂隙、命中特效和飘字同步降档。
- 刷怪不再快速顶满上限：
  - 基础刷怪间隔放慢。
  - 单波刷怪数量降低。
  - 压力波护卫数量降低。
  - 高占用时单次补怪进一步缩小。
- 新增运行时性能守卫：
  - 每 `0.35` 秒强制检查敌人、弹体、掉落、区域技能和短生命周期 VFX。
  - 超预算时优先清理远离玩家的低优先级实体。
  - 远处敌人、掉落和区域技能清理距离收紧。
- 3D LOD 更早触发：
  - 普通敌人更早切轻量模型。
  - 敌方弹幕、玩家弹幕、XP 掉落和区域技能更早切轻量表现。
  - 同屏只保留前 `2` 个玩家弹幕使用完整高精识别层，其余使用轻量形状。
- 3D 模式下隐藏的 2D 敌人/子弹/掉落不再继续绘制：
  - 非玩家 CanvasItem 在 3D 模式下直接 `visible = false`。
  - 玩家节点保留可见状态供逻辑和 3D 同步判断，但透明显示。

## 新增测试

新增 `tests/survivor_long_run_performance_guard.gd`：

- 模拟 120 秒持续战斗。
- 自动跳过升级、海克斯和商店弹窗。
- 禁用 Boss 胜利提前结算，专注持续压力。
- 统计平均单步耗时、最慢单步、全程峰值敌人/弹体/掉落/区域技能、mesh 和 node。
- 失败条件包括实体超预算、mesh/node 超预算、平均耗时过高或单步尖峰过高。

## 本批验证结果

```text
SURVIVOR_LONG_RUN_PERFORMANCE_OK seconds=120 avg_ms=9.00 worst_ms=363.41 enemies=76/76 projectiles=1/6 pickups=3/3 zones=0/0 meshes=2657/2964 nodes=3108/3596
SURVIVOR_SMOKE_OK enemies=76 projectiles=43 pickups=32
SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=5674 nodes=7224 projectiles=130 pickups=107 zones=16
SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=76 projectiles=54 pickups=44 visible=2694 bright=1770 max_luma=1.158 floor_avg=0.137 floor_max=1.000
SURVIVOR_STARTUP_VISIBILITY_OK viewport=1280x720 ambient=0.240 exposure=0.820 overlay_alpha=0.88 hero_cards=8 portraits=8
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1929
```

## 注意

Godot headless 的 dummy renderer 仍会输出大量 `Parameter "m" is null`，这批判断以 `SURVIVOR_*_OK` 标记和进程退出码为准。
