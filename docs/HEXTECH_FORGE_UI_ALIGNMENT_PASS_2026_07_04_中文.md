# 海克斯锻造 UI 对齐迭代记录 - 2026-07-04

## 本次目标

修正旧主线房间使用的海克斯锻造界面过于简陋、没有贴图槽、缺少鼠标交互和无法自动验证对齐的问题。这个界面不同于 survivor 模式 HUD，但仍会在 `main.gd` 的 `hextech_forge` 房间中使用。

## 修改内容

- 重做 `scripts/hextech_forge_ui.gd` 的卡片结构：
  - 固定 56x56 图标背板。
  - 固定 46x46 内部贴图区域。
  - 使用 `hextech_void_vfx_decal_atlas_v1.png` 生成 inset `AtlasTexture`，避免贴图贴到相邻格。
  - 卡片、按钮、图标背板、图标贴图共享 `media_slot_rect`、`media_inner_rect`、`media_slot_center` 等布局元数据。
- 新增鼠标点击选择：
  - 每张强化卡都有透明 `Button` 热区。
  - 点击卡片和键盘 `1 / 2 / 3` 都会触发 `augment_chosen`。
- 增加 Forge UI 的中文显示映射：
  - 强化名、描述、白银/黄金/棱彩等级文本使用中文。
  - 避免旧界面继续显示乱码文本。
- 新增 `tests/hextech_forge_ui_visual_matrix.gd`：
  - 验证 overlay、标题、提示、3 张卡片、图标槽、图标裁切、文本列、等级标签、鼠标选择信号和隐藏重置。

## 已验证

```text
CINNA_FORGE_UI_VISUAL_MATRIX_OK cards=3 icons=3 layout=aligned localized=clean
SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean
```

后续如果再调整海克斯卡片尺寸、图标图集或商店卡片布局，需要同步更新对应视觉矩阵，避免贴图再次漂移。
