# 敌方弹幕意图轮廓层更新

日期：2026-07-03

## 本轮目标

继续解决敌方弹幕和掉落物、经验光点混淆的问题，同时让不同虚空阵营攻击更有辨识度。之前敌方弹幕已经有地面轨迹、箭头、威胁徽记和分离环，本批新增 `EnemyProjectileIntentProfile`，让玩家能从弹体周围的符号直接读到“酸液、眼束、晶体、钻地、Boss 招式”等攻击意图。

## 新增内容

- 新增 `EnemyProjectileIntentProfile`。
  - 只挂在非 lite 敌方弹幕上。
  - 写入 `label`、`intent_type`、`detail_node`、`threat_tier`、`combat_visual_channel`、`readability_priority` metadata。
  - 所有子节点标记为 `enemy_hazard` 通道，和 XP、金币、玩家技能保持视觉语义分离。
- 通用子节点：
  - `EnemyProjectileIntentFrame`：贴地危险轮廓框。
  - `EnemyProjectileIntentCore`：弹幕意图中心点。
- 专属意图节点：
  - `EnemyProjectileIntentAcidDrops`：酸液/普通吐息。
  - `EnemyProjectileIntentEyeFocus`：虚空眼聚焦。
  - `EnemyProjectileIntentCrystalArray`：裂隙水晶弹。
  - `EnemyProjectileIntentBurrowLance`：钻地突刺弹。
  - `EnemyProjectileIntentRuptureMaw`：Boss 撕裂咬击。
  - `EnemyProjectileIntentDisintegrationRay`：Boss 激光瓦解。
  - `EnemyProjectileIntentRoyalBlade`：Boss 翼刃扫击。
  - `EnemyProjectileIntentSplitSpore`、`EnemyProjectileIntentSwarmSeed`、`EnemyProjectileIntentTrapSpore`、`EnemyProjectileIntentVoidOrb`：精英/特殊弹幕变体。

## 性能边界

- lite 敌方弹幕明确禁止生成 `EnemyProjectileIntentProfile`。
- 高密度弹幕仍由已有 `ENEMY_PROJECTILE_DETAIL_LIMIT` 切换到 lite，保留地面轨迹和基础危险核心，不额外堆专属意图几何。
- 本层不新增实时灯光，使用已有低成本几何和材质通道。

## 测试覆盖

- `tests/survivor_projectile_visual_matrix.gd`
  - 非 lite 敌方弹幕必须存在 `EnemyProjectileIntentProfile`。
  - 校验 `intent_type`、`detail_node`、`readability_priority` 和 `enemy_hazard` 通道。
  - 校验通用 frame/core 与各 label 的专属 detail 节点具备 mesh。
  - lite 敌方弹幕必须禁止该重型层。
- `tests/survivor_headless_smoke.gd`
  - 主场景 smoke 必须能找到真实生成的 `EnemyProjectileIntentProfile`。
