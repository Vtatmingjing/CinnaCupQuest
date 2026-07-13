# 敌人死亡爆光层更新

本轮目标是补齐“击杀瞬间”的视觉反馈：敌人死亡不再只是普通脉冲，而是出现短暂的虚空碎裂、种族色裂隙和奖励冠层，让战斗反馈更接近参考图里的高对比技能/掉落表现。

## 新增内容

- 新增 `scripts/survivor_death_burst.gd`，死亡爆光会加入 `survivor_death_bursts` 分组并自动释放。
- `scripts/survivor_main.gd` 的 `_spawn_enemy_death_visual()` 现在会生成死亡爆光，同时保留原有 `Pulse` 与掉落逻辑。
- `scripts/survivor_3d_view.gd` 新增 `death_burst_models` 同步层。

## 3D 节点

- `EnemyDeathBurstSignature`：死亡位置的主裂隙/法阵。
- `EnemyDeathBurstCore`：中心爆点核心。
- `EnemyDeathShardRig`：向外飞散的虚空甲壳/晶体碎片。
- `EnemyDeathBurstVfxDecal`：图集贴花，强化地面法阵感。
- `EnemyDeathRewardCrown`：精英和 Boss 死亡时额外出现的金色奖励冠层。

## 种族表现

- 虚空水晶会额外喷出小晶体。
- 虚空眼/Boss 维克兹会出现眼形裂环。
- 钻地怪/Boss 雷克塞会出现地刺碎裂。
- Boss 卑尔维斯会出现双翼残影。

## 性能策略

死亡爆光是短生命周期对象，随 `life` 自动释放，不会常驻场景。3D 视图按 `survivor_death_bursts` 分组同步并在对象消失后清理模型。

## 测试覆盖

新增 `tests/survivor_death_burst_visual_matrix.gd`：

- 检查普通怪、精英水晶、Boss 死亡爆光。
- 普通怪必须没有奖励冠层。
- 精英和 Boss 必须有 `EnemyDeathRewardCrown`。
- 检查死亡爆光场景会进入 `survivor_death_bursts` 分组。
