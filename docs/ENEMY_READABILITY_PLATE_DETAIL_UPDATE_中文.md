# 敌人读图底牌细化更新

本批次把已有 `EnemyReadabilityPlate` 从单纯的底部光圈升级为“虚空怪物俯视识别底牌”，目标是让玩家在俯视角下更快读出怪物类型，同时不增加额外 mesh 预算。

## 更新内容

- 追击虫：`pounce`，底牌 detail 为 `EnemyReadabilityPounceLegs`。
- 喷吐虫：`acid`，底牌 detail 为 `EnemyReadabilityAcidSpit`。
- 钻地虫：`burrow`，底牌 detail 为 `EnemyReadabilityBurrowSpine`。
- 龟壳虫：`armor`，底牌 detail 为 `EnemyReadabilityArmorPlates`。
- 虚空眼：`focus`，底牌 detail 为 `EnemyReadabilityFocusEye`。
- 裂隙水晶：`summon`，底牌 detail 为 `EnemyReadabilityRiftCrystal`。
- 普通虚空虫：`swarm`，底牌 detail 为 `EnemyReadabilitySwarmBite`。

## 性能策略

- 不新增一套新模型，直接给现有底牌上的主要 mesh 命名并添加 metadata。
- 同步循环只对 detail 做轻量缩放、浮动和少量旋转。
- lite 怪不挂 `EnemyReadabilityPlate`，怪潮密集时仍优先保护性能。

## 自动化覆盖

- `tests/survivor_enemy_visual_matrix.gd` 检查普通怪和精英怪的底牌 metadata、detail 节点和 mesh 内容。
- `tests/survivor_headless_smoke.gd` 增加主场景断言，确认实际同步场景中存在敌人读图底牌。
