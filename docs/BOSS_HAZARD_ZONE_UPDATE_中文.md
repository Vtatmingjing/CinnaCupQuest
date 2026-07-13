# Boss 危险地面批次记录

日期：2026-07-03

## 本批目标

让 Boss 不只是“发一圈弹幕”，而是能在场地上制造需要玩家走位处理的危险区域。这样四个虚空 Boss 会更接近肉鸽弹幕战里的阶段压力：看预警、判断地面、绕开核心危险区。

## 改动内容

- `survivor_zone.gd`
  - 新增 `from_player` 字段。
  - 默认保持玩家技能区逻辑：只伤敌人。
  - Boss 危险区使用 `from_player=false`：只伤玩家，不误伤敌人。
- `survivor_enemy.gd`
  - Boss 攻击会额外发出专属危险地面：
    - 科加斯风格：`boss_cho_rupture`，裂地吞噬区。
    - 维克兹风格：`boss_velkoz_focus`，激光锁定区。
    - 雷克塞风格：`boss_reksai_tunnel`，潜地震线区。
    - 卑尔维斯风格：`boss_belveth_swarm`，女皇虫群区。
  - 新增 `last_zone_profile`，测试可以确认 Boss 实际生成了对应地面压力。
- `survivor_main.gd`
  - 新增敌方区域入口 `_on_enemy_zone_requested()`。
  - 玩家区域和敌方区域共用 `_spawn_zone()`，统一走 `MAX_ZONES` 预算。
- `survivor_3d_view.gd`
  - Boss 危险地面写入 `zone_threat_channel="boss_hazard_zone"`。
  - 新增 `BossHazardZoneFrame` 红紫危险外框。
  - 四种 Boss 区域拥有独立 source/resolution 图案，不再落到 generic 区域图案。

## 测试覆盖

- `tests/survivor_boss_behavior_matrix.gd`
  - 检查四个 Boss 的危险地面 kind、半径和 `last_zone_profile`。
- `tests/survivor_zone_behavior_matrix.gd`
  - 检查 Boss 危险区只伤玩家。
  - 检查玩家技能区只伤敌人。
- `tests/survivor_zone_visual_matrix.gd`
  - 覆盖四个 Boss 危险地面的 3D source/resolution 节点和危险通道 metadata。

## 性能边界

Boss 区域复用现有 `MAX_ZONES` 和 3D zone LOD/预算路径，没有新增常驻全局节点。视觉层新增的是每个活跃 Boss 危险区的局部低多边形读图框和专属图案。
