# 材质与光照质量分级更新

本轮不增加场内 mesh/node，专门强化现有 3D 资产的材质读感，让海克斯金属、虚空能量和地板材质更接近参考图里的“暗底、高光、发光边缘”。

## 改动

- 命名并微调主环境：
  - `HextechVoidWorldEnvironment`
  - `HextechKeyLight`
  - `HextechFillLight`
  - `VoidRimLight`
  - `HextechGoldRimLight`
- ACES tonemap 继续保留，略提高 glow 强度和 bloom，让技能、晶体、虚空核心更有能量感。
- 新增材质质量分级：
  - 金属/金币/镶边类提高 metallic，降低 roughness，并在支持时启用 clearcoat。
  - 虚空/能量/核心/晶体类启用 rim 边缘光倾向，强化顶视角剪影。
  - 地板/石材类保持高 roughness，避免整张地面变成油亮塑料。

## 验证

- 新增 `tests/survivor_material_quality_matrix.gd`：
  - 检查世界环境、光照命名、Glow、ACES。
  - 检查金属、纹理金属、虚空能量和地板材质分级。
- 2026-07-02 已完成 17 项 headless 回归：
  - `SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.38 metal=0.70 rough=0.90 rim=true`
  - `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=9 meshes=748`
  - `SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=6777 nodes=8619 projectiles=210 pickups=166 zones=31`
  - `FULL_SURVIVOR_REGRESSION_OK tests=17`

## 预算回收

- 完整回归第一次通过时预算只剩 17 个节点余量。
- 随后将密集状态下的玩家弹体 lite 签名压成单个清晰符号，保留 `PlayerProjectileSignatureRig` 和路线颜色，但减少重复小件。
- 密集敌方弹幕 lite 形态去掉重复地圈、额外核心、拖尾、双层外壳和双层威胁环，只保留危险核心、轨迹箭头、红紫地面警示与必要节点名。
- 最新预算从贴近 `9000` 节点上限回收到 `8619`，给后续美术继续加细节留下约 381 个节点余量。
