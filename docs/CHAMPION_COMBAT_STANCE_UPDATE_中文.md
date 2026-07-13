# 英雄战斗姿态层更新

日期：2026-07-03

## 本轮目标

继续把 3D 英雄表现往“粉丝一眼能读懂角色和职业”的方向推进。上一批已经有武器剪影、技能徽章和施法读图，本批新增常驻战斗姿态层，让每个英雄不只靠颜色区分，而是有明确的战斗距离、职业分类和出手轮廓。

## 新增内容

- 新增 `ChampionCombatStanceRig`。
  - 同时挂在程序生成模型和外部授权模型 wrapper 上。
  - metadata 写入 `champion`、`combat_class`、`range_band`、`detail_node`。
  - 主场景同步时写入 `attack_readiness`，用于表现攻击准备度。
- 新增通用子节点：
  - `ChampionStanceBase`：脚下职业姿态底座。
  - `ChampionStanceFacingMarker`：面向和出手方向提示。
  - `ChampionStanceRangeBand`：近战、远程、法师、召唤型的距离读图。
- 每个英雄新增专属 detail 节点：
  - 金克丝：`ChampionStanceJinxBacklineRocket`
  - 赛娜：`ChampionStanceSennaAnchoredBeam`
  - 莎弥拉：`ChampionStanceSamiraMeleeDash`
  - 维克托：`ChampionStanceViktorControlGrid`
  - 霞：`ChampionStanceXayahKitingFan`
  - 莫德凯撒：`ChampionStanceMordeFrontlineSlam`
  - 提莫：`ChampionStanceTeemoTrapScout`
  - 奥瑞利安·索尔：`ChampionStanceAsolOrbitCaster`

## 职业区分

- 远程炮台：金克丝、赛娜。
- 近战决斗/重装：莎弥拉、莫德凯撒。
- 控制/星界法师：维克托、奥瑞利安·索尔。
- 陷阱召唤：提莫。
- 风筝射手：霞。

## 测试覆盖

- `tests/survivor_champion_visual_matrix.gd`
  - 检查 8 个英雄都有 `ChampionCombatStanceRig`。
  - 检查职业、距离类型、专属 detail 节点 metadata。
  - 检查通用子节点都包含实际 Mesh。
  - 调用同步函数并确认 `attack_readiness` 写入。
- `tests/survivor_headless_smoke.gd`
  - 在真实主场景 smoke 中检查玩家 3D 模型存在 `ChampionCombatStanceRig`。

## 性能边界

该层使用低面数 Godot 原生网格，只在玩家模型上常驻，不随弹幕、怪物数量增长。后续如果继续增加玩家模型细节，应优先复用该姿态层的 metadata 和同步入口，不再额外堆多套常驻提示层。
