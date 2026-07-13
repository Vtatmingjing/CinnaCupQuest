# 电影化光照分级更新

本批更新目标：在不增加场内节点和网格的前提下，提高海克斯/虚空 3D 画面的商业感，向参考图里的暗底、高对比、蓝紫能量、金色描边方向靠近。

## 环境调整

- `HextechVoidWorldEnvironment` 背景更暗。
- 降低 ambient light，减少整场“灰亮平铺”的感觉。
- 保留 ACES tonemap，并略提高 exposure。
- 提高 glow intensity、strength、bloom，让技能、晶体、虚空核心和弹幕能量更明显。
- 如果当前 Godot 环境支持 adjustment 属性，则启用：
  - contrast 1.12
  - saturation 1.08

## 光照调整

- `HextechKeyLight`：提高主光能量，强化模型体积。
- `HextechFillLight`：降低填充光，避免把暗面洗平。
- `VoidRimLight`：增强紫色边缘光。
- `HextechGoldRimLight`：增强金色边缘光。

每个灯光增加 `cinematic_role` 元数据，方便测试和后续定位。

## 性能约束

- 不新增运行时节点。
- 不新增 Mesh。
- 只调整已有 Environment 和 Light3D 参数。
- 密集场景下普通敌人更早切到 lite 模型：`ENEMY_DETAIL_LIMIT` 从 62 调到 58，`ENEMY_DETAIL_RECOVER_LIMIT` 从 54 调到 50，用来回收视觉预算。

## 验证

需要通过：

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_material_quality_matrix.gd
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_visual_budget_smoke.gd
```
