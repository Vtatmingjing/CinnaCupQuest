# 敌方弹幕威胁形状编码更新

日期：2026-07-04

## 目标

继续解决敌方弹幕和经验/奖励混淆的问题，同时让不同虚空来源的弹幕不再只是“一团亮光”。

本批把敌方弹幕拆成更明确的低眩光危险通道：保留红黑危险底板，同时增加按弹幕来源区分的剪影编码。

## 改动

新增 `EnemyProjectileThreatShapeCode`，挂在 `EnemyProjectileReadabilityShell` 内。

每个敌弹会记录：

- `shape_type`
- `detail_node`
- `threat_tier`
- `combat_visual_channel = enemy_hazard`
- `pickup_confusion_guard = true`
- `material_grade = low_glare_enemy_projectile_shape_code`
- `hazard_shape_language = enemy_projectile_intent_silhouette`

当前形状映射：

- `acid_spit`：酸液弹/虚空喷吐，点状酸滴剪影
- `void_eye_focus`：虚空眼，眼裂剪影
- `crystal_shard`：裂隙晶体，晶刺剪影
- `burrow_lance`：遁地突刺，长矛/倒刺剪影
- `rupture_maw`：Cho 风格裂地咬合，双颚剪影
- `disintegration_ray`：Vel 风格射线，细长聚焦剪影
- `royal_blade`：Bel 风格王刃，双翼刃剪影
- `split_spore` / `swarm_seed` / `trap_spore`：孢子/虫群/陷阱，点阵或三角陷阱剪影
- `void_orb`：虚空球体，核心加环形剪影
- `minor_bolt`：普通小弹，菱形短划剪影

普通和 lite 敌弹都会保留该编码，确保弹幕数量多时仍能区分危险来源。

## 性能与眩光约束

- 每个编码控制在 2-7 个 Mesh。
- 材质沿用 `enemy_projectile` 低眩光预算，避免提高亮度。
- 形状编码跟随敌弹同步轻微旋转/脉冲，但幅度低于主危险壳。

## 验证

已更新 `res://tests/survivor_projectile_visual_matrix.gd`：

- 普通敌弹必须包含 `EnemyProjectileThreatShapeCode`
- lite 敌弹也必须包含 `EnemyProjectileThreatShapeCode`
- 校验 `shape_type`、`detail_node`、通道、拾取物混淆保护、低眩光材质等级和 Mesh 数量

当前验证结果：

- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1681`
