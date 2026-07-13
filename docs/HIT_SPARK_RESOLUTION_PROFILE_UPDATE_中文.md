# 命中终结爆点层更新

日期：2026-07-03

## 本轮目标

继续提升战斗瞬间的 3D 质感。已有命中火花能表达“打中了”，但缺少效果图里那种清晰的地面爆点、落点徽记和技能结果形状。本批新增 `HitSparkResolutionProfile`，让不同英雄/技能命中后留下更明确的短生命周期落点读图。

## 新增内容

- 新增 `HitSparkResolutionProfile`。
  - 只挂在非 dense LOD 命中火花上。
  - 写入 `label`、`impact_family`、`resolution_family`、`source_champion`、`detail_node` metadata。
- 通用子节点：
  - `HitSparkResolutionFloorSeal`：地面爆点底印。
  - `HitSparkResolutionCore`：命中中心高光。
- 专属终结形态：
  - 金克丝/爆炸：`HitSparkResolutionRocketCrater`
  - 赛娜/灵魂炮：`HitSparkResolutionSoulPierceLine`
  - 莎弥拉/决斗：`HitSparkResolutionDuelistCutMark`
  - 维克托/激光：`HitSparkResolutionHexcoreBurnSeal`
  - 霞/羽刃：`HitSparkResolutionFeatherPinFan`
  - 提莫/毒性：`HitSparkResolutionPoisonBloomPool`
  - 奥瑞利安·索尔/星体：`HitSparkResolutionStarCollapseWell`
  - 莫德凯撒/领域重击：`HitSparkResolutionRealmCrushSeal`

## 性能边界

- 该层属于命中火花短生命周期模型，不是常驻场景物。
- dense LOD 明确禁止生成 `HitSparkResolutionProfile`，高攻速和怪潮场景仍走轻量火花。
- 继续依赖 `MAX_HIT_SPARKS` 和现有 `hit_spark_models.size() >= 3` dense 切换逻辑。

## 测试覆盖

- `tests/survivor_hit_spark_visual_matrix.gd`
  - 非 dense 命中火花必须存在 `HitSparkResolutionProfile`。
  - 检查 `HitSparkResolutionFloorSeal`、`HitSparkResolutionCore` 和每个英雄/技能的专属 detail 节点。
  - dense LOD 明确禁止出现该重型层。
- `tests/survivor_headless_smoke.gd`
  - 真实主场景 smoke 要求实际战斗循环里出现 `HitSparkResolutionProfile`。
