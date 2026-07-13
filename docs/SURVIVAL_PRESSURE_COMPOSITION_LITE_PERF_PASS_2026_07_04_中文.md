# 生存压力路线与轻量性能批次

本批次目标是继续处理用户反馈的三个核心问题：场内压力不明显、敌人/弹幕/掉落在高密度场景里互相混淆、以及 3D 节点过多带来的 CPU/GPU 风险。

## 改动

- `SurvivalDirectorPressureRig` 增加压力波队形读图层：
  - 左右护送路线：`PressureSurgeEscortLaneLeft` / `PressureSurgeEscortLaneRight`
  - 前排近战压力线：`PressureSurgeMeleeLaneFront`
  - 后排远程压力线：`PressureSurgeRangedLaneBack`
  - Boss 护送桥：`PressureSurgeBossEscortBridge`
  - 高风险高收益提示：`PressureSurgeRiskRewardBadge`
  - 近战/远程威胁点各 3 个，用于表示下一波压力结构。
- 压力路线层改为按需创建：
  - 平时只保留基础压力预警 rig。
  - 进入压力波预警窗口后才创建路线/威胁点/奖励标识。
  - 这样能保留读图能力，同时避免非预警阶段常驻节点挤占预算。
- 普通小怪 lite 3D 模型改用 `LiteEnemyReadabilityPlate`：
  - 用 1 个低眩光地面读图板替代旧的威胁环加双层接触阴影。
  - 保留不同种类颜色：喷吐、虚空眼、水晶、甲壳、钻地怪仍有不同地面识别色。
  - 精英和 Boss 不受影响，仍保留完整身体细节、优先级背板、血条和阶段表现。

## 结果

- UI 贴图对齐矩阵仍通过，选人头像、升级/海克斯/商店图标没有出现残留或偏移。
- 难度曲线矩阵仍保持当前挑战版：Boss 90 秒、压力波 v6、精英小队压力与后期成长均启用。
- 低眩光预算仍保持 v6：全局 emission `0.078`，透明 alpha `0.326`。
- 密集场景预算回归到安全线内：`meshes=6762 / 7200`，`nodes=8708 / 9000`。

## 验证

```text
CINNA_FORGE_UI_VISUAL_MATRIX_OK cards=3 icons=3 layout=aligned localized=clean
SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean
SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=90 timers=survival_pressure_v6 spawn_steps=challenge_v5 surge=elite_squad_v2 enemy_growth=harder_v5 attacks=pressure_v2
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7533 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6
SURVIVOR_PRESSURE_DIRECTOR_VISUAL_MATRIX_OK meshes=18 nodes=20 readiness=0.400 routes=composition_lanes
SURVIVOR_VISUAL_BUDGET_OK enemies=90 meshes=6762 nodes=8708 projectiles=210 pickups=168 zones=31
```
