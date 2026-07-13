# 敌方弹幕辨识度更新

本次更新重点解决敌方弹幕在混战中容易和经验/金币拾取物混淆的问题。

## 新增内容

- 敌方弹幕新增 `EnemyProjectileReadabilityShell`。
- 每个敌弹现在都有：
  - `EnemyProjectileBlackCore`：暗色黑芯，让敌弹和亮绿色/蓝色经验晶体明显区分。
  - `EnemyProjectileHotCore`：危险能量核心，保留虚空弹幕的高亮轮廓。
  - `EnemyProjectilePickupSeparationRing`：红色地面分离环，强调这是伤害物，不是奖励物。
- 完整敌弹额外新增 `EnemyProjectileDangerTick` 刻度，远看更像弹幕威胁而不是掉落物。
- 低配敌弹保留黑芯和分离环，但不加载额外刻度，保证怪多、弹多时仍然省节点。

## 验证

`tests/survivor_projectile_visual_matrix.gd` 现在会检查：

- 玩家弹幕不会误挂敌方危险识别层。
- 完整敌弹必须包含黑芯、分离环和危险刻度。
- 低配敌弹必须保留黑芯与分离环，但不能加载重型危险刻度。
