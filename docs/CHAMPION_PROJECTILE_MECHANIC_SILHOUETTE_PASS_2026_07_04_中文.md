# 英雄投射物机制剪影迭代记录 - 2026-07-04

## 本次目标

提升英雄攻击辨识度，减少“所有英雄都在丢普通光球”的感觉，同时不增加光污染，也不破坏大量投射物时的 lite 性能保护。

## 修改内容

- 给详细玩家投射物新增 `ChampionProjectileMechanicSilhouetteRig`。
- 每个英雄体系都有独立机制剪影节点：
  - 金克丝：`ChampionProjectileMechanicJinxRocketRack`
  - 赛娜：`ChampionProjectileMechanicSennaRelicBeam`
  - 莎弥拉：`ChampionProjectileMechanicSamiraBladeArc`
  - 维克托：`ChampionProjectileMechanicViktorLaserCircuit`
  - 霞：`ChampionProjectileMechanicXayahFeatherRecall`
  - 提莫：`ChampionProjectileMechanicTeemoPoisonDart`
  - 龙王：`ChampionProjectileMechanicAsolOrbitComet`
  - 莫德凯撒：`ChampionProjectileMechanicMordeIronWake`
- 新剪影层包含暗底、方向轨、命中锚点和英雄机制细节，用形状区分火箭、光束、刀弧、激光线路、羽毛回收、毒镖、星体轨道和重锤冲击。
- 新材质统一走 `player_projectile_mechanic_*` 低眩光规则，避免继续增加场内亮斑。
- `lite_player_projectile` 分支不加载该 rig，保持高投射物数量时的性能保护。
- `tests/survivor_projectile_visual_matrix.gd` 增加对应节点、元数据、低眩光等级和 lite 禁用断言。

## 已验证

```text
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1598
```

Godot headless dummy renderer 仍会输出既有 `mesh_get_surface_count` 噪声；本项目以脚本退出码和 `SURVIVOR_*_OK` 标记作为 headless 验证结果。
