# 英雄技能释放身份层增强记录

日期：2026-07-02

## 本轮目标

继续把战斗表现往“海克斯虚空效果图”方向推进。敌人、Boss、精英读法已经增强，这一轮重点补玩家英雄的技能释放瞬间，让每个英雄的攻击前摇更有粉丝向辨识度。

## 已完成

- 新增 `ChampionSignatureCastIdentity`
  - 挂在已有 `ChampionSignatureCastRig` 内，不新增运行时对象池。
  - 随攻击 readiness 同步缩放、旋转和脉冲。
  - 每个英雄带 `identity_signature` metadata，便于测试和后续维护。
- 金克丝
  - 新增 `ChampionSignatureJinxRocketFuse`，强调火箭引信和爆炸火花。
- 赛娜
  - 新增 `ChampionSignatureSennaSoulGate`，强调灵魂门和长枪贯穿。
- 莎弥拉
  - 新增 `ChampionSignatureSamiraStyleRank`，强调连招评分和环形刀光。
- 维克托
  - 新增 `ChampionSignatureViktorHexcoreBeam`，强调海克斯核心和激光线。
- 霞
  - 新增 `ChampionSignatureXayahFeatherRecall`，强调羽毛回收轨迹。
- 莫德凯撒
  - 新增 `ChampionSignatureMordeRealmSeal`，强调领域封印和铁锤轮廓。
- 提莫
  - 新增 `ChampionSignatureTeemoMushroomTrap`，强调蘑菇陷阱和孢子环。
- 奥瑞利安·索尔
  - 新增 `ChampionSignatureAsolStarForge`，强调星铸轨道和星体粒子。

## 测试覆盖

- `tests/survivor_champion_visual_matrix.gd`
  - 检查 `ChampionSignatureCastIdentity` 存在。
  - 检查 champion metadata 与 identity signature。
  - 检查 8 个英雄各自的专属 detail 节点。
- `tests/survivor_headless_smoke.gd`
  - 在真实主场景烟测中检查玩家模型存在 `ChampionSignatureCastIdentity`。

## 验证结果

- Godot check-only：通过。
- 冠军视觉矩阵：`SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=2061 ability_atlas=1536x1024`
- 主场景烟测：`SURVIVOR_SMOKE_OK`
- 高压预算：`SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=6845 nodes=8725 projectiles=210 pickups=167 zones=31`
- 完整回归：`FULL_SURVIVOR_REGRESSION_OK tests=17`

## 后续建议

- 下一轮可以把英雄技能实际 projectile/zone 的外形进一步和这些释放身份层对齐。
- 当前预算仍健康，后续可以优先打磨商店/装备购买反馈和升级选择的“海克斯装置感”。
