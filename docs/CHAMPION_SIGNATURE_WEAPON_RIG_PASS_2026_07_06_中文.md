# 英雄专属武器轮廓更新

## 目标

继续解决“角色太像、粉丝一眼认不出来”的问题。上一批强化了场地装备展示层，这批把识别重点放回 8 个可选英雄本体，让俯视 3D 模型拥有更明确的专属武器/背部大轮廓。

## 本批改动

- 新增 `ChampionSignatureWeaponRig`：
  - 金克丝：火箭架 + 机枪管。
  - 赛娜：圣物巨枪 + 灵魂环。
  - 莎弥拉：双刃与手枪交叉轮廓。
  - 维克托：海克斯机械爪与核心。
  - 霞：羽刃扇形轮廓。
  - 莫德凯撒：夜陨战锤与尖刺。
  - 提莫：斥候背包、吹箭和蘑菇组。
  - 龙王：星环、星核和龙形尾迹。
- 普通过程模型和外部授权模型 wrapper 都会挂载该 rig。
- 新 rig 使用 `low_glare_signature_weapon` 材质等级：
  - 不新增实时灯光。
  - 不使用高发光材质制造辨识度。
  - 通过大轮廓、武器体块和职业色彩提高识别。
- `survivor_champion_visual_matrix.gd` 新增断言：
  - 8 个英雄都必须有 `ChampionSignatureWeaponRig`。
  - 每个英雄必须有自己的专属 detail 节点。
  - 检查 `weapon_signature`、`detail_node`、材质亮度和同步后的 scale。

## 验证结果

```text
SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=3149 ability_atlas=1536x1024 archetype=role_silhouette
SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=5734 nodes=7302 projectiles=130 pickups=108 zones=16
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=8369 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6
SURVIVOR_SMOKE_OK enemies=76 projectiles=40 pickups=32
SURVIVOR_STARTUP_VISIBILITY_OK viewport=1280x720 ambient=0.240 exposure=0.820 overlay_alpha=0.88 hero_cards=8 portraits=8
SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=76 projectiles=31 pickups=42 visible=2249 bright=1674 max_luma=1.158 floor_avg=0.137 floor_max=1.000
SURVIVOR_LONG_RUN_PERFORMANCE_OK seconds=120 avg_ms=8.84 worst_ms=267.77 enemies=76/76 projectiles=2/5 pickups=2/2 zones=0/0 meshes=3203/3297 nodes=3718/4011
```

## 注意

这批仍是过程 3D 风格强化，不是导入官方高精模型。它的价值是让英雄在当前低成本 3D 管线里更像“有专属武器和身份的角色”，并为后续接入授权模型时保留同一套粉丝可读轮廓层。
