# 夜间区域特效打磨记录

本轮目标是把英雄区域技能从“地上一圈颜色”继续推进到更接近海克斯/虚空效果图的分层表现，同时保持怪物多时的性能边界。

## 已完成

- 区域技能新增贴地符文板 `ZoneRunePlate`，优先复用 `art/textures/hextech_warning_rune_tile_v1.png`，让重力场、奇点、死亡领域等技能不再只靠纯色几何。
- 区域技能新增中心脉冲层 `ZonePulseCore`，按技能类型使用不同呼吸速度和旋转方向：维克托偏机械回路，龙王偏反向星体收缩，铁男偏低频沉重压迫。
- 区域技能新增倒计时符文 `ZoneProgressSigils`，会随着区域剩余寿命减少而逐步熄灭，玩家能在场内直接读到技能持续时间。
- 提莫蘑菇新增未触发布防标记 `ZoneArmedSigils`，和触发后的毒圈视觉分开，减少“陷阱”和“持续范围伤害”混淆。
- 后台 smoke test 增加区域技能断言，覆盖 `ZoneRunePlate`、`ZoneProgressSigils`、`ZonePulseCore` 和 `ZoneArmedSigils`。
- smoke test 前半段刷怪量下调，给裂隙水晶召唤行为留出敌人上限空间；敌人上限压力测试仍保留在后半段。

## 验证

- Godot headless 初始化通过。
- `tests/survivor_headless_smoke.gd` 通过，输出 `SURVIVOR_SMOKE_OK enemies=86 projectiles=62 pickups=52`。

## 后续方向

- 继续把区域技能的“英雄身份”做得更强：比如维克托重力场加入更明显的六角机械电路，龙王奇点加入星轨吸入层，铁男领域加入更厚重的暗绿色铁幕。
- 给 Boss 技能也做同样的寿命/危险等级读图层，让玩家一眼区分普通弹幕、Boss 大招、地面持续区。
- 如果后续接入授权素材，可把这些程序化层作为官方模型/贴图的底座，而不是被替换掉。

## 敌方弹幕威胁层

- 敌方弹幕新增 `EnemyProjectileThreatBadge`，Boss 招式标签 `Q/V/X/B` 使用更大的红紫金六角威胁徽记，特殊敌弹 `E/C/R/A` 使用较轻的专属危险符号。
- 威胁徽记在 3D 同步中独立呼吸和旋转，Boss 弹幕脉冲更强，普通弹幕保持克制，避免所有敌弹都变成同一种发光球。
- smoke test 主动生成 `A/V/X/B` 敌方弹幕，并新增 `EnemyProjectileThreatBadge` 断言，避免后续性能优化误删这层读图信息。
- 本批验证：Godot headless 初始化通过；`tests/survivor_headless_smoke.gd` 通过，输出 `SURVIVOR_SMOKE_OK enemies=85 projectiles=57 pickups=50`。

## Boss 出招刻印

- Boss 场地压迫层新增 `BossCastSigils`，会在 Boss 即将出招时围绕场地中心逐个点亮，和已有 `BossHealthSigils` 区分开：血量刻印读阶段，出招刻印读危险窗口。
- Boss 脚下焦点新增 `BossCastFocus`，由 `attack_timer` 驱动；Boss 快出手时焦点放大并旋转，玩家不用只盯 Boss 模型本体也能读到即将施法。
- smoke test 强制 Boss 进入短出招窗口，并确认 `BossCastSigils` 与 `BossCastFocus` 可见，避免后续改动让 Boss 预警层静默消失。
- 本批验证：Godot headless 初始化通过；`tests/survivor_headless_smoke.gd` 通过，输出 `SURVIVOR_SMOKE_OK enemies=85 projectiles=59 pickups=47`。

## 竞技场边缘摆件

- 新增 `ArenaPremiumSetDressing` 根节点，用来集中管理更高质感的边缘装饰，后续需要性能裁剪或替换授权资产时可以单独定位。
- 新增海克斯塔摆件：蓝金机械底座、发光核心、水晶尖顶和侧向能量轨道，放在战斗区域边缘，不遮挡中心弹幕。
- 新增虚空巢摆件：紫黑甲壳、虚空晶核、尖刺和地面腐化环，用于强化虚空阵营氛围。
- smoke test 增加 `ArenaPremiumSetDressing` 断言，确认场景质感层不会被后续重构误删。
- 本批验证：Godot headless 初始化通过；`tests/survivor_headless_smoke.gd` 通过，输出 `SURVIVOR_SMOKE_OK enemies=86 projectiles=58 pickups=48`。

## 英雄粉丝识别徽记

- 玩家模型新增 `ChampionFanSignature`，每个英雄都有一个高位剪影徽记：金克丝双火箭、赛娜魂光炮环、莎弥拉连斩轮、维克托海克斯核心、霞羽扇、莫德凯撒铁锤、提莫蘑菇毒圈、龙王星轨。
- 该徽记会轻微旋转和呼吸，挂在玩家模型上方，不依赖官方资产，也不会增加怪潮阶段的批量节点成本。
- 外部授权模型接入时也会自动挂载同一层徽记，避免替换模型后丢失场内角色读图。
- smoke test 增加 `ChampionFanSignature` 断言，确认英雄身份层不会在后续重构中被误删。
- 本批验证：Godot headless 初始化通过；`tests/survivor_headless_smoke.gd` 通过，输出 `SURVIVOR_SMOKE_OK enemies=87 projectiles=57 pickups=50`。

## 3D 视觉预算测试

- 新增 `tests/survivor_visual_budget_smoke.gd`，在 headless 后台构造高压场景：接近上限的敌人、210 个弹幕、约 170 个拾取物、30 个区域技能。
- 测试会统计 3D 视图中的 `MeshInstance3D` 和总节点数，当前阈值为 `MAX_MESH_INSTANCES = 8400`、`MAX_TOTAL_NODES = 11000`。
- 新增 `tests/README_VISUAL_BUDGET_中文.md`，说明该测试不是 FPS 基准，而是防止美术层继续增加时节点数量失控。
- 本批验证：`tests/survivor_visual_budget_smoke.gd` 通过，输出 `SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=7632 nodes=9432 projectiles=210 pickups=167 zones=31`。

## 高价值掉落信标

- 高价值拾取物新增 `PickupRewardBeacon`：大金币、大经验、治疗和护盾会显示低成本竖向光柱、金色外环和小型能量点。
- 普通小 XP 不会生成该层，避免怪潮后期满地小水晶都冒光，保持奖励事件和普通掉落的视觉层级。
- smoke test 增加 `PickupRewardBeacon` 断言，确认精英/Boss 奖励读图层不会被后续优化误删。
- 本批验证：Godot headless 初始化通过；`tests/survivor_headless_smoke.gd` 输出 `SURVIVOR_SMOKE_OK enemies=85 projectiles=57 pickups=49`；`tests/survivor_visual_budget_smoke.gd` 输出 `SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=7973 nodes=9816 projectiles=210 pickups=167 zones=31`，仍低于 8400/11000 阈值。

## 敌人职责旗标

- 详细敌人模型新增 `EnemySpeciesRoleBanner`，在已有种族地面符号之外增加高位职责剪影：追击虫、喷吐虫、遁地虫、甲壳虫、虚空眼、水晶召唤物和 Boss 都有不同符号。
- lite 敌人模型不挂该层，后期怪潮密度升高时仍然走轻量模型，保留性能保护。
- smoke test 增加 `EnemySpeciesRoleBanner` 断言，确保敌人职责读图层不会在后续优化中丢失。
- 本批验证：Godot headless 初始化通过；`tests/survivor_headless_smoke.gd` 输出 `SURVIVOR_SMOKE_OK enemies=84 projectiles=58 pickups=48`；`tests/survivor_visual_budget_smoke.gd` 输出 `SURVIVOR_VISUAL_BUDGET_OK enemies=64 meshes=8011 nodes=9854 projectiles=210 pickups=167 zones=31`，仍低于 8400/11000 阈值。

## 预算回收

- 将 XP 掉落的 `PickupRewardBeacon` 触发阈值从 `amount >= 10` 收紧到 `amount >= 12`，金币、治疗、护盾的信标不受影响。
- 这样普通偏大的 XP 不再频繁冒光，把视觉预算留给真正稀有奖励、精英奖励和 Boss 表现。
- 本批验证：`tests/survivor_headless_smoke.gd` 输出 `SURVIVOR_SMOKE_OK enemies=86 projectiles=58 pickups=50`；`tests/survivor_visual_budget_smoke.gd` 输出 `SURVIVOR_VISUAL_BUDGET_OK enemies=64 meshes=7654 nodes=9456 projectiles=210 pickups=166 zones=31`，相对上一批回收了约 350 个 mesh。

## 英雄视觉矩阵测试

- 新增 `tests/survivor_champion_visual_matrix.gd`，直接构建 8 个英雄的 3D 模型，避免只靠默认英雄验证导致其他角色分支静默损坏。
- 每个英雄都会检查 `ChampionIdentityProjection`、`ChampionFanSignature`、`ChampionLiveAura`、`ChampionAttackBurst`、`PlayerStatusRings`、`ChampionUpgradeRoutes` 和 `RoleRouteRings`。
- 新增 `tests/README_CHAMPION_VISUAL_MATRIX_中文.md`，记录运行命令、通过标记和覆盖范围。
- 本批验证：`tests/survivor_champion_visual_matrix.gd` 输出 `SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=1422`；`tests/survivor_headless_smoke.gd` 输出 `SURVIVOR_SMOKE_OK enemies=87 projectiles=59 pickups=48`；`tests/survivor_visual_budget_smoke.gd` 输出 `SURVIVOR_VISUAL_BUDGET_OK enemies=67 meshes=7730 nodes=9542 projectiles=210 pickups=167 zones=31`。

## 敌人/Boss 视觉矩阵测试

- 新增 `tests/survivor_enemy_visual_matrix.gd`，直接构建 7 类普通怪、4 个 Boss、4 类精英词缀和 lite 普通怪模型。
- 测试会确认详细普通怪存在 `EnemySpeciesRoleBanner` 和 `EnemyReadabilityPlate`，精英存在 `EliteTraitMarker`、`EliteBossCrest`、`ThreatHalo`、`HealthBar`，Boss 存在 `EnemySpeciesRoleBanner`、`EliteBossCrest`、`ThreatHalo`、`HealthBar`、`EnrageAura`、`WindupAura`。
- lite 普通怪会反向确认不携带 `EnemySpeciesRoleBanner`，防止后期怪潮性能保护被重节点破坏。
- 新增 `tests/README_ENEMY_VISUAL_MATRIX_中文.md`，记录运行命令、覆盖范围和关键断言。
- 本批验证：`tests/survivor_enemy_visual_matrix.gd` 输出 `SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 meshes=1083`；`tests/survivor_headless_smoke.gd` 输出 `SURVIVOR_SMOKE_OK enemies=85 projectiles=58 pickups=48`；`tests/survivor_visual_budget_smoke.gd` 输出 `SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=7838 nodes=9664 projectiles=210 pickups=167 zones=31`。

## 投射物视觉矩阵测试

- 新增 `tests/survivor_projectile_visual_matrix.gd`，直接构建 9 类玩家弹幕、9 类敌方弹幕，并覆盖玩家 lite 与敌方 lite 分支。
- 玩家弹幕必须有 `PlayerProjectileSignatureRig`，敌方弹幕必须有 `EnemyProjectileLane` 和 `EnemyProjectileDangerRig`，高威胁敌方弹幕 `A/E/C/R/Q/V/X/B` 必须有 `EnemyProjectileThreatBadge`。
- 新增 `tests/README_PROJECTILE_VISUAL_MATRIX_中文.md`，记录运行命令、覆盖范围和关键断言。
- 本批验证：`tests/survivor_projectile_visual_matrix.gd` 输出 `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=9 meshes=482`；`tests/survivor_headless_smoke.gd` 输出 `SURVIVOR_SMOKE_OK enemies=83 projectiles=56 pickups=47`；`tests/survivor_visual_budget_smoke.gd` 输出 `SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=7785 nodes=9604 projectiles=210 pickups=167 zones=31`。
