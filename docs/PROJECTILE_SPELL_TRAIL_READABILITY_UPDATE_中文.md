# 弹幕尾焰与危险辨识更新

本批更新目标：提升海克斯/虚空战斗表现里“弹幕像效果图一样有方向、有尾焰、有落点信息”的观感，同时避免密集弹幕拖垮性能。

## 玩家弹幕

非 lite 玩家弹幕新增：

- `PlayerProjectileSpellTrailProfile`
- `PlayerProjectileTrailSpine`
- `PlayerProjectileTrailBloom`

每类英雄弹幕有独立细节节点：

- 金克丝/火箭：`PlayerProjectileTrailRocketExhaust`
- 赛娜/灵魂光束：`PlayerProjectileTrailSoulBeam`
- 莎弥拉/连斩弹道：`PlayerProjectileTrailDuelistSlice`
- 维克托/海克斯射线：`PlayerProjectileTrailHexCircuit`
- 霞/羽毛回拉：`PlayerProjectileTrailFeatherReturn`
- 提莫/毒素孢子：`PlayerProjectileTrailPoisonSpores`
- 奥瑞利安·索尔/星体弹道：`PlayerProjectileTrailStarWake`
- 莫德凯撒/铁铠重击：`PlayerProjectileTrailIronWake`

密集场景下玩家弹幕会切到 lite 模型，lite 模型不会挂 `PlayerProjectileSpellTrailProfile`。

## 敌方弹幕

敌方弹幕新增：

- `EnemyProjectileHazardChevron`

这个标记挂在 `EnemyProjectileReadabilityShell` 下，用来把敌方危险弹幕和 XP/金币拾取物拉开视觉差异。

性能回归后调整：非 lite 敌方弹幕全部保留 `EnemyProjectileHazardChevron`；lite 敌方弹幕不挂该节点，继续依赖已有的黑芯、拾取物分离环、轨迹箭头和高威胁徽章。

## 性能约束

- 高质量玩家尾焰只挂在非 lite 玩家弹幕上。
- 敌方危险标记只增加一个低面数 Mesh，并且只出现在非 lite 敌方弹幕上。
- 继续用 `survivor_visual_budget_smoke.gd` 验证密集场景节点和网格预算。

## 验证

需要通过：

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_projectile_visual_matrix.gd
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_headless_smoke.gd
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_visual_budget_smoke.gd
```
