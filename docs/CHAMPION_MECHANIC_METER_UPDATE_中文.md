# 英雄机制标识更新

本轮重点解决“不同英雄玩起来和看起来都太像”的问题，在现有角色模型、技能图标和施法圈之外，新增一层轻量的英雄机制标识。

## 改动

- 新增 `ChampionMechanicMeter`，每个英雄都有自己的 `mechanic_type` 元数据。
- 新增统一子节点：
  - `MechanicMeterFrame`
  - `MechanicMeterPips`
  - `MechanicMeterHeroMotif`
- 8 个英雄分别对应不同机制读感：
  - 金克丝：蓝粉弹药切换和火箭 motif。
  - 赛娜：灵魂层数与穿透光束。
  - 莎弥拉：风格评级 pip 和连斩 motif。
  - 维克托：海克斯核心进化节点。
  - 霞：羽毛留场与召回 motif。
  - 莫德凯撒：死界锁链与夜陨锤影。
  - 提莫：蘑菇充能与毒雾孢子。
  - 铸星龙王：星轨、星核和彗星轨迹。
- `ChampionMechanicMeter` 已接入运行时同步，会轻微旋转、脉冲，避免角色脚下视觉完全静态。

## 验证

- 更新 `tests/survivor_champion_visual_matrix.gd`：
  - 检查 `ChampionMechanicMeter` 必须存在。
  - 检查 `mechanic_type` 不能是空或 `generic`。
  - 检查 frame、pips、hero motif 都有 mesh。
  - 检查每个英雄至少有 3 个机制 pip。
- 单项英雄矩阵：
  - `SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=1999 ability_atlas=1536x1024`
- 完整 17 项后台回归：
  - `SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=6769 nodes=8614 projectiles=210 pickups=166 zones=31`
  - `FULL_SURVIVOR_REGRESSION_OK tests=17`

## 性能

- 英雄视觉矩阵总 mesh 从约 `1919` 增至 `1999`，8 个英雄合计增加约 80 个 mesh。
- 实战高压预算仍低于 `9000` 节点上限，最新为 `8614`，保留约 386 个节点余量。
