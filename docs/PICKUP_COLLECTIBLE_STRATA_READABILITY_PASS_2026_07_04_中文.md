# 拾取物与危险弹幕分层可读性记录
日期：2026-07-04

## 问题

场内经验、金币和敌方弹幕都使用高亮小体积视觉时，玩家在高密度战斗中容易把奖励误判成危险弹幕，或把危险弹幕误判成掉落物。这个问题会直接影响生存挑战的公平性。

## 修改

- 拾取物模型增加 `pickup_collectible` 独立视觉层。
- 拾取物地面增加低眩光 `PickupCollectibleBackplate`，用暗色托底和小型价值缺口区分奖励。
- 拾取物高度和漂浮幅度降低，减少与空中弹幕的视觉重叠。
- 拾取物树增加 `pickup_confusion_safe` 标记，禁止使用 `enemy_hazard` 视觉通道。
- 自动化测试增加拾取物/危险弹幕通道隔离检查。

## 验证

已覆盖的目标测试：

- `SURVIVOR_PICKUP_VISUAL_MATRIX_OK`
- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK`
- `SURVIVOR_VISUAL_BUDGET_OK`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK`

## 结论

拾取物现在更像低位奖励标记，敌方弹幕继续保持高威胁形状语言，两者不会再共用同一套危险视觉通道。
