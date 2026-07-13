# 肉鸽路线随机感更新记录

本轮目标是让每一局开局不再只是换一个小数值，而是让“命运”持续影响升级池、商店货架、海克斯品质和精英奖励。

## 新增开局命运

- `signature_draft` / 专属训练赛：开局获得一项当前英雄专属升级，后续升级池更偏向英雄专属技能。
- `black_market` / 地下装备局：商店更早出现，当前英雄路线装备获得额外折扣，推荐货架更稳定。
- `unstable_forge` / 不稳定海克斯炉：海克斯锻造品质提前一档，同时提高虚空压力和奖励。
- `void_rivalry` / 虚空宿敌悬赏：精英更早出现，首个精英强制为宝藏特质，精英奖励更高。
- 开局 3 张命运现在保证至少包含 1 张新增命运和 1 张基础命运，避免新增规则长期抽不到。

## 难度曲线

- Boss 登场时间从 360 秒提前到 330 秒，让 5 分半附近出现明确压轴目标。
- 330 秒和 420 秒后刷怪包额外增加一层，但仍受 `MAX_ENEMIES` 上限保护。
- 9 波后普通虚空单位的血量和速度继续小幅成长，前期难度不受影响。

## 玩法接入

- `scripts/survivor_main.gd` 新增命运运行时修正字段：
  - `fate_upgrade_bias_ids`
  - `fate_shop_focus_tags`
  - `fate_shop_discount_tags`
  - `fate_forced_elite_trait`
  - `fate_hextech_tier_bonus`
- 升级池现在会读取命运偏向，专属训练赛会更稳定地出现 2 个英雄专属选项。
- 商店推荐分现在同时考虑英雄标签和命运标签，地下装备局会把路线装备推到更靠前的位置并打折。
- 不稳定海克斯炉会让第一轮海克斯从白银提前到黄金。
- 虚空宿敌悬赏会让首个精英携带宝藏特质，击败收益更明确。

## 路线羁绊

- 物理路线：`physical_hex x2 + marksman_hex x1` 触发“弹链风暴”，提高穿透、暴击、弹速和额外弹道。
- 法系路线：`magic_hex x2 + summon_hex x1` 触发“符文工坊”，提高技能威力、弹体体积和飞环数量。
- 坦克路线：`tank_hex x2 + melee_hex x1` 触发“巨像开团”，提高近身光环、最大生命和护盾。
- 支援路线：`support_hex x2 + summon_hex x1` 触发“灵魂网络”，提高护盾、拾取范围和回复能力。
- 3D 玩家模型新增 `PlayerStatusRings/Recipes` 羁绊星环，触发配方后会在角色脚下点亮星标。
- 3D 玩家模型新增 `PlayerStatusRings/Items` 装备战利品环，购买联盟装备后会在角色脚下点亮金蓝徽章。

## 后台验证

- 新增 `tests/survivor_roguelike_route_matrix.gd`：
  - 校验专属训练赛会给英雄专属升级，并让升级选项偏向专属路线。
  - 校验地下装备局会展示完整商品货架，推荐路线装备上架靠前且有折扣。
  - 校验不稳定海克斯炉会提前海克斯品质，同时提高压力和奖励。
  - 校验虚空宿敌悬赏会提前精英，并强制首个精英为宝藏特质。
  - 校验开局命运抽卡强制包含新增命运和基础命运，且没有重复选项。
- 新增 `tests/survivor_route_synergy_matrix.gd`：
  - 校验物理、法系、坦克、支援四条路线羁绊都会触发。
  - 校验触发后确实修改角色关键属性，而不是只写进总结文本。
- `tests/survivor_champion_visual_matrix.gd` 现在会校验羁绊星环和装备战利品环存在，并在触发后点亮。
- 新增 `tests/survivor_difficulty_curve_matrix.gd`：
  - 校验 Boss 会在 330 秒后触发。
  - 校验后期刷怪包大于中期刷怪包。
  - 校验 9 波后的敌人血量和速度成长生效。
- 已通过：
  - `SURVIVOR_ROGUELIKE_ROUTE_MATRIX_OK fates=4 roll_mix=forced`
  - `SURVIVOR_ROUTE_SYNERGY_MATRIX_OK routes=4`
  - `SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=1590`
  - `SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=330 spawn_steps=late enemy_growth=late`
  - `SURVIVOR_SMOKE_OK enemies=85 projectiles=57 pickups=52`
  - `SURVIVOR_VISUAL_BUDGET_OK enemies=66 meshes=7764 nodes=9584 projectiles=210 pickups=166 zones=31`

## 性能边界

这轮主要增加的是数据和选择逻辑，没有在高频战斗循环中增加新的重型 3D 节点。高压视觉预算仍低于当前 `8400 meshes / 11000 nodes` 阈值。
