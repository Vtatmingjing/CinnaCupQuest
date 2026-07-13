# 场地装备战利品展示层更新

## 目标

继续向参考效果图里的“英雄、怪物、弹幕、奖励材料同屏展示”的高级图集感靠近，同时不重新引入光污染和卡顿风险。

## 本批改动

- 新增 `ArenaRelicShowcaseSet`：
  - 6 个装备剪影槽：刀刃、火炮、法球、盾牌、法杖、虚空面具。
  - 5 条出装路线连接，作为后续商店/装备 build 的视觉语言基底。
  - 5 个奖励晶体色板，对应 XP、金币/奖励、虚空、危险和海克斯材质语言。
- 展示层全部为静态几何：
  - 不新增实时灯光。
  - 不挂到怪潮、弹幕或拾取物循环里。
  - 复用全局低眩光 `_mat` / `_texture_mat` 材质管线。
- `survivor_arena_visual_matrix.gd` 新增断言：
  - 必须存在 `ArenaRelicShowcaseSet`。
  - 必须是 `low_glare_static_relic_showcase`。
  - 必须是 `static_no_lights`。
  - 必须包含 6 个装备槽、6 个装备剪影、5 个路线连接和 5 个奖励色板。

## 验证结果

```text
SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=1672x941 meshes=1571 citadel_nodes=8 strata=8
SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=5726 nodes=7286 projectiles=130 pickups=107 zones=16
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=8293 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6
SURVIVOR_STARTUP_VISIBILITY_OK viewport=1280x720 ambient=0.240 exposure=0.820 overlay_alpha=0.88 hero_cards=8 portraits=8
SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=75 projectiles=47 pickups=46 visible=2598 bright=1771 max_luma=1.158 floor_avg=0.137 floor_max=1.000
SURVIVOR_LONG_RUN_PERFORMANCE_OK seconds=120 avg_ms=14.05 worst_ms=674.34 enemies=76/76 projectiles=57/57 pickups=49/58 zones=0/0 meshes=4659/5429 nodes=5916/6333
SURVIVOR_SMOKE_OK enemies=76 projectiles=44 pickups=31
```

## 注意

这批是静态美术层，主要提升场地边缘的装备/奖励语义和参考图式构成。它不会让角色模型本身直接达到商业级模型质量，但会让整体画面更像一个完整的海克斯虚空战斗图集，而不是单纯把单位丢在空场地里。
