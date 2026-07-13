# UI 媒体槽状态锁定记录

日期：2026-07-04

## 目标

针对“选人、海克斯升级时贴图没有对齐，旧文字/图层叠在一起影响游玩”的风险，本批修正 UI 卡片在界面切换时的状态清理逻辑：

- 不新增亮效，不增加战斗场景负担。
- 重点锁定媒体槽、贴图、文字 fallback、卡片元数据的 reset 状态。
- 防止从商店切回升级、从选人切到海克斯、或锻造界面只显示部分卡片时遗留旧图标/旧文字/旧 augment id。

## 修改文件

- `scripts/survivor_hud.gd`
  - `_reset_choice_media()` 现在会同步清理按钮、图标背板、图标贴图三者的媒体槽元数据。
  - 新增 `_clear_media_slot_meta()`，统一清理 `media_slot_rect`、`media_inner_rect`、`media_visual_rect`、`media_rect_locked`、`media_alignment_mode` 等字段。

- `tests/survivor_hud_visual_matrix.gd`
  - inactive 卡片现在必须证明贴图、文字 fallback、按钮、背板、贴图节点都没有残留媒体槽状态。

- `scripts/hextech_forge_ui.gd`
  - 隐藏锻造卡片时清理文字、贴图、augment id、tier 和媒体槽元数据。
  - 锻造 UI atlas 图标现在也写入 `ui_atlas_cell_rect`、`ui_atlas_safe_inset_px`、`ui_atlas_region_center_locked`，和 survivor HUD 保持一致。

- `tests/hextech_forge_ui_visual_matrix.gd`
  - 新增隐藏后 reset 检查。
  - 新增只显示 2 张卡片时第 3 张 inactive 卡片的贴图/文字/元数据清理检查。
  - 新增锻造图标 atlas center-lock 元数据检查。

## Headless 验证

以下验证均使用 Godot console/headless，没有打开游戏 GUI。

- `SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean`
- `CINNA_FORGE_UI_VISUAL_MATRIX_OK cards=3 icons=3 layout=aligned localized=clean reset=locked`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7689 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=32`

备注：Godot headless/dummy renderer 仍会输出 `Parameter "m" is null`，本批没有新增脚本错误或解析错误。
