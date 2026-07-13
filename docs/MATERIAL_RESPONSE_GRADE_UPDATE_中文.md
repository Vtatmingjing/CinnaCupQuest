# 材质响应分级更新

本批目标是在不增加场内节点和 Mesh 的前提下，提高海克斯/虚空 3D 画面的质感，让金属、虚空能量、地面石材在同一光照下有更明确的层次。

## 调整内容

- `StandardMaterial3D` 新增统一材质家族 metadata：
  - `cinematic_material_family`
  - `cinematic_material_grade`
  - `cinematic_material_emission`
- 金属类材质强化：
  - 更高 metallic。
  - 更低 roughness。
  - 更强 clearcoat。
  - 若 Godot 当前属性支持，则启用 anisotropy。
- 虚空/能量类材质强化：
  - 更低 roughness。
  - 更强 rim light。
  - 透明或高发光材质获得更高 rim/tint。
- 石材/地板类材质保持哑光：
  - metallic 归零。
  - roughness 提高，避免地面抢角色和弹幕亮度。

## 验证

- 更新 `tests/survivor_material_quality_matrix.gd`：
  - 检查金属、能量、地板三类材质 metadata。
  - 检查 metal clearcoat/anisotropy。
  - 检查 void/energy rim。
  - 检查地板 roughness。
- 不新增运行时节点，不改变 Mesh 数量；继续用 `survivor_visual_budget_smoke.gd` 做预算回归。
