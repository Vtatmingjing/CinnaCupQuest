# 玩家弹体轨迹签名层更新

本轮目标是提升战斗表现：让不同英雄的攻击在飞行路径和命中预感上更有区别，而不是只看发光弹本体。

## 新增内容

- 完整玩家弹体新增 `PlayerProjectilePathSignature`。
- 子节点包括：
  - `PlayerProjectileLaneRibbon`：贴地轨迹带，强化弹体方向和攻击路线。
  - `PlayerProjectileImpactMark`：前方命中印记，提前暗示伤害落点。
  - `PlayerProjectileRoleGlyph`：职业/英雄家族符号，帮助区分攻击类型。

## 英雄家族表现

- 金克丝/砰砰枪：火箭尾焰、弹道爆闪、弹药火花。
- 赛娜：灵魂光束、赦除门环、魂火粒子。
- 莎弥拉：近战连斩轨迹、风格环。
- 维克托：海克斯激光、电路刻线。
- 霞：扇形羽毛轨迹。
- 提莫：毒雾孢子和陷阱半径感。
- 奥瑞利安·索尔：星轨、彗星尾迹和星点。
- 莫德凯撒：巨锤落点、死亡领域重击痕迹。

## 性能策略

该层只挂在非 lite 的玩家弹体上。弹幕密度超过 `PLAYER_PROJECTILE_DETAIL_LIMIT` 后，玩家弹体会切到 lite 模型，不生成该高质感轨迹层，避免密集场景下网格数量失控。

## 测试覆盖

`tests/survivor_projectile_visual_matrix.gd` 已新增断言：

- 完整玩家弹体必须存在 `PlayerProjectilePathSignature`。
- 必须包含轨迹带、命中印记、职业符号三个子节点。
- lite 玩家弹体必须不包含该高成本轨迹层。
