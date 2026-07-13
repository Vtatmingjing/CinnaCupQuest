# 低眩光手绘深度层更新

日期：2026-07-03

## 本轮目标

继续改善“模型像基础几何玩具”的问题，但不再用更亮的发光堆效果。本批给英雄和非 lite 虚空单位增加低眩光的手绘深度层，用暗部接触、轮廓笔触和材质分层块强化俯视角读感，向参考图里“暗底、金属边、局部能量点”的资产风格靠近。

## 新增内容

- 英雄新增 `ChampionPainterlyDepthRig`。
  - 过程生成模型和外部授权模型 wrapper 都会叠加。
  - metadata：`champion`、`silhouette_family`、`detail_node`、`material_grade`、`combat_visual_channel`。
  - 通用子节点：`ChampionPainterlyValueShadow`、`ChampionPainterlyRimStroke`、`ChampionPainterlyMaterialSteps`。
  - 8 个英雄都有专属 detail，例如 `ChampionPainterlyJinxRocketDepth`、`ChampionPainterlyTeemoScoutDepth`、`ChampionPainterlyAsolStarDepth`。
- 虚空单位新增 `VoidCreaturePainterlyDepthRig`。
  - 只挂在非 lite 普通怪、精英、Boss 和 Boss 变体上。
  - metadata：`kind`、`body_family`、`detail_node`、`boss`、`elite`、`material_grade`、`combat_visual_channel`。
  - 通用子节点：`VoidCreatureAmbientOcclusionPlate`、`VoidCreatureCarapaceRimStroke`、`VoidCreatureValueShardSteps`。
  - 不同虚空家族有专属 detail，例如 `VoidPainterlySkitterBladeDepth`、`VoidPainterlyEyeFocusDepth`、`VoidPainterlyBelvethWingDepth`。

## 性能边界

- 新层不新增实时灯光。
- 材质使用低 alpha、低 emission，并由测试限制发光预算。
- lite 普通怪明确禁止 `VoidCreaturePainterlyDepthRig`，怪潮密集时仍走轻量模型。

## 验证结果

```text
SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=2610 ability_atlas=1536x1024
SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2124
SURVIVOR_VISUAL_BUDGET_OK enemies=67 meshes=5881 nodes=7563 projectiles=210 pickups=168 zones=31
SURVIVOR_SMOKE_OK enemies=92 projectiles=66 pickups=37
FULL_SURVIVOR_REGRESSION_OK tests=24
```

备注：Godot 4.3 headless dummy renderer 仍会输出 `Parameter "m" is null` 噪声；本批以脚本退出码 0 和上述 `SURVIVOR_*_OK` 标记为准。
