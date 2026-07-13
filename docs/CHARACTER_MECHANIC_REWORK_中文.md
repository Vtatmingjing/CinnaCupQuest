# 角色机制重构说明

本轮目标：让粉丝不看名字也能从战斗节奏猜出角色，而不是所有英雄都自动朝最近敌人丢弹体。

参考来源使用 Riot Data Dragon 的官方英雄技能数据：
- `Jinx.json`：Get Excited、Switcheroo、Zap、Flame Chompers、Super Mega Death Rocket
- `Senna.json`：Absolution、Piercing Darkness、Last Embrace、Dawning Shadow
- `Samira.json`：Daredevil Impulse、Flair、Blade Whirl、Wild Rush、Inferno Trigger
- `Viktor.json`：Glorious Evolution、Gravity Field、Hextech Ray、Arcane Storm
- `Xayah.json`：Clean Cuts、Double Daggers、Bladecaller、Featherstorm
- `Mordekaiser.json`：Darkness Rise、Obliterate、Indestructible、Death's Grasp、Realm of Death
- `Teemo.json`：Guerrilla Warfare、Blinding Dart、Move Quick、Toxic Shot、Noxious Trap
- `AurelionSol.json`：Cosmic Creator、Breath of Light、Astral Flight、Singularity、Falling Star / The Skies Descend

## 角色落地

| 角色 | 定位 | 当前实现重点 |
| --- | --- | --- |
| 金克丝 | 远程物理射手 | 机枪快射与鱼骨头火箭交替；火箭命中有范围爆炸；击杀触发罪恶快感和周期大火箭。 |
| 赛娜 | 支援型远程成长射手 | 慢速粗线圣枪、长距离穿透；灵魂永久成长；周期护盾/治疗和束缚黑雾。 |
| 莎弥拉 | 近中距离收割 | 远处短程双枪，贴脸变刀舞范围伤害；评分满触发炼狱扳机环形爆发。 |
| 维克托 | 中远程法师控场 | 海克斯射线切线；重力场作为实体区域，持续减速和拉扯敌人。 |
| 霞 | 羽毛布阵射手 | 普攻留下羽毛；倒钩从羽毛位置穿回玩家并定身敌人。 |
| 莫德凯撒 | 近战魔法坦克 | 远程弹体基本移除；主输出是大锤范围打击、黑暗起兮、死亡领域。 |
| 提莫 | 陷阱/毒伤/风筝 | 毒镖附加持续毒伤；实体蘑菇布雷，触发后生成毒云；致盲吹箭削弱敌人。 |
| 龙王 | 星界控场法师 | 星轨环绕是主要输出；黑洞吸引和减速；星尘成长放大星轨、黑洞和彗星。 |

## 路线验收

- 物理路线：强化金克丝、霞、莎弥拉的攻速、暴击、穿透、额外弹道。
- 魔法路线：强化维克托、龙王、提莫、莫德凯撒的区域、技能威力、冷却收益。
- 坦克路线：让莫德凯撒和莎弥拉能贴脸换收益，不只是血量变多。
- 召唤路线：明确作用在蘑菇、星轨、黑洞、重力场等可持续对象上。
- 支援路线：围绕赛娜的护盾、治疗、灵魂成长和容错。

## 性能约束

- 区域实体统一走 `survivor_zone.gd`，数量由主场景限制为 `MAX_ZONES`。
- 区域伤害按 tick 合并，不逐帧生成大量新节点。
- 霞的羽毛数量有上限，龙王星轨只做周期检测。
- 3D 同步层只为区域生成轻量 primitive 标识，不加载额外重模型。
