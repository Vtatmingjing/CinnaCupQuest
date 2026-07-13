# 虚空怪物高级本体轮廓层更新

日期：2026-07-03

## 本轮目标

继续提升虚空怪物的本体质感。之前敌人已有种族地面牌、弱点核心、精英词缀、Boss 威胁轮廓和出招预警，但身体本体仍偏基础几何。本批新增 `VoidCreaturePremiumBodyRig`，把甲壳板、发光核心、材质分层和种族专属身体轮廓直接挂到怪物本体上，向参考图左侧虚空怪物资产板的读感靠近。

## 新增内容

- 新增 `VoidCreaturePremiumBodyRig`。
- 写入 `kind`、`body_family`、`detail_node`、`boss`、`elite`、`light_boss_variant`、`material_grade` metadata。
- `material_grade` 固定为 `void_premium_carapace`，方便后续替换授权贴图或模型。
- 通用子节点：
  - `VoidCreaturePremiumCarapacePlating`：身体甲壳板。
  - `VoidCreaturePremiumGlowCore`：正面发光核心。
  - `VoidCreaturePremiumMaterialBands`：完整非 lite 模型的材质分层。
  - `VoidCreaturePremiumCoreLens`：核心镜片。
- 种族/Boss 专属 detail：
  - `VoidCreaturePremiumSwarmMandibles`
  - `VoidCreaturePremiumSkitterBladeLegs`
  - `VoidCreaturePremiumSpitterAcidCrown`
  - `VoidCreaturePremiumBurrowSpineArmor`
  - `VoidCreaturePremiumCarapaceShellStack`
  - `VoidCreaturePremiumEyeCrownLenses`
  - `VoidCreaturePremiumRiftCrystalConduit`
  - `VoidCreaturePremiumChoDevourCrown`
  - `VoidCreaturePremiumBelvethRoyalWings`

## 性能边界

- lite 普通怪明确禁止生成 `VoidCreaturePremiumBodyRig`。
- 高密度怪潮仍由 `ENEMY_DETAIL_LIMIT` / `ENEMY_DETAIL_RECOVER_LIMIT` 切换到 lite，保留基础轮廓和预警，不加载高级本体层。
- 正式 Boss 种类继续使用完整高级本体层。
- 压力场景中，普通种类被标记为 Boss 时使用轻量高级本体分支：保留甲壳板、核心镜片和种族 detail，但跳过材质环、额外边缘条和高段数核心环，避免大量 Boss 变体同时存在时打穿节点预算。
- 该层不新增实时灯光，只使用缓存材质和低成本几何。

## 测试覆盖

- `tests/survivor_enemy_visual_matrix.gd`
  - 普通非 lite 怪、精英、正式 Boss 都必须存在 `VoidCreaturePremiumBodyRig`。
  - 校验 `body_family`、`detail_node`、`material_grade`、`boss`、`elite`、`light_boss_variant` metadata。
  - 校验通用子节点、`VoidCreaturePremiumCoreLens` 和专属 detail 具备 mesh。
  - lite 普通怪必须禁止该层。
  - 普通种类 Boss 变体必须走轻量分支，并限制高级本体 mesh 数。
- `tests/survivor_headless_smoke.gd`
  - 主场景必须能找到真实生成的 `VoidCreaturePremiumBodyRig`。
- `tests/survivor_visual_budget_smoke.gd`
  - 在 92 只以内敌人、230 个弹体、190 个掉落和 32 个区域技能的压力场景中，节点数和 mesh 数必须留在预算内。
