# 英雄专属施法提示更新

本批更新目标：让 8 个可选英雄在出手前就能被看出不同攻击模式，减少“所有角色都在丢同一种东西”的感觉。

## 新增表现层

在 `ChampionSignatureCastRig` 下新增：

- `ChampionSignatureCastRoleTelegraph`
- `ChampionCastTelegraphFrame`
- `ChampionCastTelegraphMeter`

每个英雄还会挂一个专属细节节点：

- 金克丝：`ChampionCastTelegraphJinxArtillery`，火箭/炮击提示
- 赛娜：`ChampionCastTelegraphSennaSoulBeam`，灵魂长线光束
- 莎弥拉：`ChampionCastTelegraphSamiraDuelist`，近身连斩扇形
- 维克托：`ChampionCastTelegraphViktorHexRay`，海克斯射线
- 霞：`ChampionCastTelegraphXayahFeathers`，羽毛回拉轨迹
- 莫德凯撒：`ChampionCastTelegraphMordeRealm`，领域重击
- 提莫：`ChampionCastTelegraphTeemoPoison`，蘑菇/毒圈陷阱
- 奥瑞利安·索尔：`ChampionCastTelegraphAsolStarfall`，星落轨迹

## 玩法意义

- 远程炮击、光束、弹道、陷阱、近战连斩和领域重击现在在视觉上有独立提示。
- 这些节点会随攻击冷却接近完成而显示，玩家能提前理解“这个角色下一次攻击是什么类型”。
- 当前实现只改变表现层，不改数值，避免一次性影响难度曲线。

## 性能约束

- 只在玩家模型的施法 Rig 中增加少量低面数 Mesh。
- 不给每颗弹幕或每个敌人添加额外复杂节点。
- 继续用 `survivor_visual_budget_smoke.gd` 监控总节点和总网格预算。

## 验证

需要通过：

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_champion_visual_matrix.gd
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_headless_smoke.gd
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_visual_budget_smoke.gd
```
