# VFX 贴花图集接入记录

本轮目标是把冲击波、技能爆点从“纯几何发光圈”推进到更接近参考效果图的手绘质感：蓝金海克斯符文、紫色虚空旋涡、危险警示符号和晶体爆点都放进一张可复用图集里，再由 3D 视图按技能颜色家族选择不同子图。

## 新增资源

- `art/textures/hextech_void_vfx_decal_atlas_v1.png`
- 资源来源：使用内置 `imagegen` 生成的原创 fan-inspired VFX 图集。
- 约束：黑底、无文字、无水印、无官方角色/Logo，用于 Godot 加法混合贴花。

## 代码接入

- `scripts/survivor_3d_view.gd` 新增 `HEXTECH_VOID_VFX_DECAL_TEXTURE_PATH` 和回退路径。
- `Pulse` 模型新增 `PulseVfxDecal`，按 `pulse_family` 选择图集子格：
  - 海克斯/护盾：蓝金符文与机械六边框。
  - 虚空/毒/铁男：紫色旋涡、虚空晶体和暗能量圈。
  - 危险/火箭/刀刃：警示符号和拖尾爆点。
- `_texture_mat` 增加 `uv_offset`，让一张 atlas 可以稳定裁切不同子图。
- 新增 `_vfx_decal_mat`，设置无阴影、无深度写入、无光照、加法混合，避免黑底在场景里变成实体平面。

## 投射物贴花

- 详细玩家弹幕新增 `ProjectileVfxDecal`，给火箭、激光、羽毛、毒镖、子弹和星体弹幕补上贴图拖尾。
- 详细敌方弹幕新增 `EnemyProjectileVfxDecal`，让紫色虚空弹、蓝色晶体弹、橙色突袭弹和危险 Boss 弹幕在移动中更容易被玩家辨认。
- lite 玩家/敌方弹幕不挂载贴花，怪潮密度过高时仍走轻量模型。
- 同步循环会给贴花做轻微呼吸缩放，但不增加粒子系统和物理负担。

## Boss 出招贴花

- `BossCastSigils` 新增 `BossCastVfxDecal`，在 Boss 出手窗口给竞技场中心叠一层危险法阵。
- `BossCastFocus` 新增 `BossCastFocusVfxDecal`，贴在 Boss 脚下作为近身危险焦点。
- 同步逻辑区分贴花节点和 6 个倒计时刻印，避免新增贴花影响原有刻印逐步点亮逻辑。

## HUD 卡片图标

- 升级、海克斯和商店卡片左侧新增 `TextureRect` 图标层，复用同一张 atlas 的不同子格。
- 原来的文字小图标保留为 fallback；当 atlas 成功加载时隐藏，避免文字叠在图片上。
- HUD 侧使用 `ResourceLoader` 加 `Image.load()` 回退，避免新复制 PNG 还没有 `.import` 文件时 UI 读不到图。
- 选人界面现在会把 `art/champions/portraits/*_identity_v1.png` 接到 8 张英雄卡左侧，替代小号通用图标，提升英雄识别度。

## 竞技场中心贴花

- 中央竞技场新增 `ArenaCenterVfxDecal`，复用蓝金符文子图作为低透明度能量盘。
- 该贴花只是一张 textured plane，跟随场景做极慢旋转和呼吸，不引入粒子或额外物理。
- `tests/survivor_headless_smoke.gd` 会断言该节点存在，防止中心地台回退成纯几何圆环。

## 虚空甲壳材质 v3

- 新增 `art/textures/void_carapace_tile_v3.png`，作为敌人和 Boss 甲壳材质的优先路径。
- `VOID_CARAPACE_FALLBACK_TEXTURE_PATH` 调整为 v2，保留上一个版本作为回退。
- v3 的目标是让小虫、精英和 Boss 的身体表面有更清楚的紫黑甲片、粉紫裂隙和湿润高光，而不是单色塑料感。

## 海克斯金属材质 v3

- 新增 `art/textures/hextech_metal_tile_v3.png`，作为海克斯金属件、边框、柱体、金币/护盾金属部分的优先材质。
- `HEXTECH_METAL_FALLBACK_TEXTURE_PATH` 调整为 v2，继续保留上一版作为回退。
- v3 强化了蓝色晶体镶嵌、金色倒角、深色钢板和细电路线，用于把场景边缘装置从“纯色金属”推进到更接近参考图的机械贴图质感。

## 测试覆盖

- `tests/survivor_headless_smoke.gd` 会强制生成一次冲击波，并断言 `PulseVfxDecal` 存在。
- `tests/survivor_headless_smoke.gd` 会强制 Boss 进入出招窗口，并断言 `BossCastVfxDecal` 与 `BossCastFocusVfxDecal` 可见。
- `tests/survivor_projectile_visual_matrix.gd` 会断言详细玩家/敌方弹幕拥有贴花，同时反向断言 lite 弹幕不包含该重视觉层。
- `tests/survivor_hud_visual_matrix.gd` 会断言升级、海克斯、商店卡片都拥有 atlas 图标，并确认文字 fallback 没有叠加显示。
- `tests/survivor_hud_visual_matrix.gd` 会断言 8 张选人卡都加载大头像。
- Godot headless 初始化通过。
- `tests/survivor_projectile_visual_matrix.gd` 通过：`SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=9 meshes=500`。
- `tests/survivor_hud_visual_matrix.gd` 通过：`SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=9`。
- `tests/survivor_champion_visual_matrix.gd` 通过：`SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=1422`。
- `tests/survivor_enemy_visual_matrix.gd` 通过：`SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 meshes=1083`。
- `tests/survivor_headless_smoke.gd` 通过：`SURVIVOR_SMOKE_OK enemies=85 projectiles=59 pickups=50`。
- `tests/survivor_visual_budget_smoke.gd` 通过：`SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=7670 nodes=9475 projectiles=210 pickups=166 zones=31`。

## 性能边界

这次只给每个活动冲击波、详细投射物和 Boss 出招预警增加低成本 textured plane。高压预算仍低于当前阈值 `8400 meshes / 11000 nodes`，所以这一层属于“高画面收益、低节点成本”的增强，适合继续扩展到高价值掉落爆点和商店/升级界面的视觉资产。
