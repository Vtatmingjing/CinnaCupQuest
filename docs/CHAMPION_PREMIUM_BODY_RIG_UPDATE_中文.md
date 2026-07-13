# 英雄高级本体轮廓层更新

日期：2026-07-03

## 本轮目标

继续解决“角色模型本体过于简陋，只靠脚下 UI 识别”的问题。此前英雄已经有身份投影、技能徽记、职业站位和升级路线，但模型身体部分仍偏基础几何。本批新增 `ChampionPremiumBodyRig`，把职业材质、肩甲、胸口核心、背部轮廓和英雄专属细节挂到角色本体上，让玩家从角色身上也能读到是谁、是什么战斗定位。

## 新增内容

- 新增 `ChampionPremiumBodyRig`。
  - 过程生成模型和外部授权模型 wrapper 都会自动叠加该层。
  - 写入 `champion`、`silhouette_family`、`detail_node`、`material_grade` metadata。
  - `material_grade` 固定为 `premium_fan_3d`，便于测试和后续替换资产。
- 通用子节点：
  - `ChampionPremiumArmorPlating`：肩部、胸口、核心高光和金属镶边。
  - `ChampionPremiumMaterialSwatches`：金属、能量、主色三类材质分层标记。
  - `ChampionPremiumChestCore`：身体中线核心高光。
- 专属本体细节：
  - 金克丝：`ChampionPremiumJinxGraffitiRig`
  - 赛娜：`ChampionPremiumSennaRelicMantle`
  - 莎弥拉：`ChampionPremiumSamiraDuelistMantle`
  - 维克托：`ChampionPremiumViktorHexcoreHarness`
  - 霞：`ChampionPremiumXayahFeatherMantle`
  - 莫德凯撒：`ChampionPremiumMordeIronCitadelPlate`
  - 提莫：`ChampionPremiumTeemoScoutGear`
  - 奥瑞利安·索尔：`ChampionPremiumAsolCelestialCrown`

## 性能边界

- 该层只挂在玩家英雄模型上，场上同一时间通常只有一个实例。
- 没有新增实时灯光，全部使用已有材质缓存和低成本 MeshInstance3D。
- 外部模型接入时不改源模型，只在 wrapper 上叠加同一套 fan 向识别层，方便后续替换或关闭。

## 测试覆盖

- `tests/survivor_champion_visual_matrix.gd`
  - 每个英雄必须存在 `ChampionPremiumBodyRig`。
  - 校验 `silhouette_family`、`detail_node`、`material_grade` metadata。
  - 校验 `ChampionPremiumArmorPlating`、`ChampionPremiumMaterialSwatches`、`ChampionPremiumChestCore` 和专属 detail 节点具备 mesh。
  - 调用 `_sync_champion_premium_body_rig()`，防止运行时同步函数缺失或产生非法缩放。
- `tests/survivor_headless_smoke.gd`
  - 主场景必须能找到真实生成的 `ChampionPremiumBodyRig`。
