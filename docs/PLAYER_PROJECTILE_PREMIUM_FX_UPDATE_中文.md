# 玩家弹体高级 FX 本体层更新

日期：2026-07-03

## 目标

继续提升技能弹体质感，对应参考效果图右侧的技能特效板。之前玩家弹体已有路径、职业、命中意图和拖尾层，但弹体本体仍偏基础。本批新增 `PlayerProjectilePremiumFxRig`，让非 lite 玩家弹体具备更清楚的弹头、能量包边、材质分层和英雄家族细节。

## 新增内容

- 新增 `PlayerProjectilePremiumFxRig`。
- 只挂在非 lite 玩家弹体上。
- 写入 `label`、`family`、`source_champion`、`detail_node`、`material_grade`、`combat_visual_channel` metadata。
- `material_grade` 固定为 `premium_projectile_fx`。
- 通用子节点：
  - `PlayerProjectilePremiumCoreShell`：弹体核心壳与中心高光。
  - `PlayerProjectilePremiumEnergyRim`：前端能量包边。
  - `PlayerProjectilePremiumMaterialBands`：材质条与海克斯金属嵌边。
- 英雄/家族 detail：
  - `PlayerProjectilePremiumRocketWarhead`
  - `PlayerProjectilePremiumSoulFocusLens`
  - `PlayerProjectilePremiumDuelistEdge`
  - `PlayerProjectilePremiumHexcorePrism`
  - `PlayerProjectilePremiumFeatherInlay`
  - `PlayerProjectilePremiumPoisonVial`
  - `PlayerProjectilePremiumStarCore`
  - `PlayerProjectilePremiumIronHead`
  - `PlayerProjectilePremiumGenericHead`

## 性能边界

- lite 玩家弹体明确禁止生成该层。
- 高密度玩家弹幕仍由 `PLAYER_PROJECTILE_DETAIL_LIMIT` 切换到 lite，只保留低成本签名层。
- 新层不新增实时灯光，只使用缓存材质、低段数几何和少量 MeshInstance3D。

## 测试

- `tests/survivor_projectile_visual_matrix.gd`
  - 非 lite 玩家弹体必须有 `PlayerProjectilePremiumFxRig`。
  - 校验 `material_grade`、`combat_visual_channel`、`detail_node` 和英雄来源 metadata。
  - 校验通用子节点与专属 detail 都有 mesh 内容。
  - lite 玩家弹体必须禁止该层。
- `tests/survivor_headless_smoke.gd`
  - 主场景真实战斗循环必须生成 `PlayerProjectilePremiumFxRig`。
