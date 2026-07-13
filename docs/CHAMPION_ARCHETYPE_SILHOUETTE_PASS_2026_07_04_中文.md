# 英雄职业剪影 3D 表现层

日期：2026-07-04

## 目标

继续解决“英雄进场后差异不够明显”的问题。已有模型层能表达英雄身份、姿态、技能徽记和攻击预警，但缺少一个更直接的职业定位剪影：玩家应能从俯视角快速读出谁是射手、法师、近战、坦克、召唤/陷阱角色。

## 改动

- `scripts/survivor_3d_view.gd`
  - 新增 `ChampionArchetypeSilhouetteRig`。
  - 程序化模型和外部授权模型 wrapper 都会挂载该层。
  - 新增统一子节点：
    - `ChampionArchetypeBasePlate`
    - `ChampionArchetypeRoleTotem`
    - `ChampionArchetypeRouteGlyphs`
    - 每个英雄一个专属 detail 节点
  - 该层使用 `material_grade = low_glare_archetype_silhouette`。
  - 该层使用 `combat_visual_channel = champion_archetype_readability`。
  - 同步时根据攻击准备度写入 `attack_readiness`，并轻微缩放/旋转，不加实时灯光。

## 英雄职业族群

- 金克丝：`physical_artillery_marksman`
- 赛娜：`support_piercing_marksman`
- 莎弥拉：`melee_physical_duelist`
- 维克托：`magic_control_mage`
- 霞：`physical_feather_marksman`
- 莫德凯撒：`magic_melee_tank`
- 提莫：`magic_trap_summoner`
- 奥瑞利安·索尔：`cosmic_scaling_mage`

## 验证

只使用 Godot headless，没有打开游戏窗口。

通过项：

- `SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=2851 ability_atlas=1536x1024 archetype=role_silhouette`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7533 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=6386 nodes=8176 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.00 ambient=0.05 key=0.48 metal=0.74 rough=0.90`

## 取舍

- 这不是替代真正授权 3D 模型的方案，而是让当前程序化/外部模型都获得一致的低成本职业读图层。
- 该层只增加少量几何，不突破敌人、弹幕、掉落和区域预算。
