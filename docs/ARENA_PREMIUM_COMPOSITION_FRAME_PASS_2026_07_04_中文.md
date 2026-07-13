# 竞技场高级构图边框层更新 - 2026-07-04

本批继续朝参考图里的“英雄、虚空怪、技能、奖励资产板围绕中心战斗场”的构图推进。实现方式不是把 UI 面板盖到游戏画面上，而是在 3D 竞技场边缘加入低眩光、低成本的静态资产陈列层，让第一眼读感更接近海克斯/虚空主题图板，同时保持中心战斗区清爽。

## 新增内容

- `scripts/survivor_3d_view.gd`
  - 新增 `ArenaPremiumCompositionFrameSet`。
  - 元数据固定为：
    - `art_role = reference_board_hextech_void_composition`
    - `combat_visual_channel = arena_readability`
    - `material_grade = low_glare_static_composition_frame`
    - `performance_profile = static_no_lights`
  - 顶部新增 `ArenaCompositionHeroGallerySlot_*`：对应参考图上方英雄资产陈列。
  - 左侧新增 `ArenaCompositionVoidGallerySlot_*`：对应参考图左侧虚空怪物资产陈列。
  - 右侧新增 `ArenaCompositionVfxPanel_*`：对应参考图右侧弹体/技能效果陈列。
  - 右下新增 `ArenaCompositionMaterialSwatch_*`：对应奖励晶体/材质球陈列。
  - 中心新增 `ArenaCompositionCombatWindow_0` 与 `ArenaCompositionPanelRail_*`：强调中心战斗窗口，但不遮挡玩家、敌人、弹幕和掉落物。

## 约束

- 不新增任何实时灯光。
- 不新增动态同步逻辑。
- 所有材质走无发光、低 alpha 的静态可读性通道。
- 中心战斗区域只增加低透明边框，不把装饰压进实际战斗核心。
- 静态 mesh 数从 `1420` 增加到 `1496`，仍低于 arena 测试上限 `1800`。

## 测试更新

- `tests/survivor_arena_visual_matrix.gd`
  - 新增对 `ArenaPremiumCompositionFrameSet` 的存在性、元数据和无实时灯光断言。
  - 检查英雄槽、虚空怪槽、技能面板、奖励材质块、中心战斗窗口、角标和边框轨道数量。
  - 检查关键边框和中心窗口材质保持低眩光。

## 本批验证

已通过 Godot headless targeted 验证：

```text
SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=1672x941 meshes=1496 citadel_nodes=8 strata=8
SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.00 ambient=0.08 key=0.68 metal=0.74 rough=0.90 rim=true family=metal/energy/stone
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7034 models=46 emission=0.128 alpha=0.372 enemy=0.102 player=0.057 pickup=0.025 danger=0.266
SURVIVOR_VISUAL_BUDGET_OK enemies=86 meshes=6909 nodes=8761 projectiles=210 pickups=168 zones=31
SURVIVOR_SMOKE_OK enemies=104 projectiles=40 pickups=35
```

下一步建议继续处理两个方向：

- 英雄和敌人本体的“粉丝一眼认出是谁”的大轮廓，优先补模型 silhouette 与技能起手差异。
- Boss/精英攻击预警可以继续从“几何提示”向“独特机制提示”推进，避免只靠颜色区分。
