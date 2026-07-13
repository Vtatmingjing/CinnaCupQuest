# Boss 电影化阶段状态更新

本次更新目标是增强 Boss/精英战斗的辨识度和压迫感，同时控制节点预算，不再追加大批 Mesh。

## 调整内容

- Boss 压迫层新增统一状态：`steady`、`pressuring`、`enraged`、`windup`、`casting`。
- `BossPressureRig`、`ArenaRitual`、`BossFocus`、Boss 专属签名、领域画像、施法焦点、施法图案都会写入 `cinematic_state` 和 `cinematic_intensity`。
- Boss 中血量会进入 `pressuring`，领域威胁条会显现，避免只有施法瞬间才有反馈。
- Boss 残血会进入 `enraged`，专属签名和领域细节会有更强缩放与旋转反馈。
- Boss 施法前/施法中会进入 `windup` / `casting`，倒计时框、施法焦点、专属施法图案会同步增强。
- Boss 本体的 `BossPhaseStateRig` 同步接入同一状态，地面提示和 Boss 模型状态保持一致。

## 自动化覆盖

- 新增 `tests/survivor_boss_cinematic_state_matrix.gd`。
- 覆盖 4 个 Boss：Cho、Velkoz、RekSai、BelVeth。
- 每个 Boss 验证 5 个状态：稳态、中血压迫、残血狂暴、预警、施法。
- 验证根节点、Boss 焦点、专属签名、领域画像、威胁条、施法焦点、施法图案的状态 metadata。

## 性能约束

- 本批主要复用已有节点，不增加新视觉 Mesh。
- 状态变化通过 metadata、显隐、缩放、旋转和现有材质完成。
- 高密度场景下进一步降低玩家弹体、敌方弹体、普通 XP 掉落的详细模型保留数量，把节点预算让给 Boss/精英和关键提示。
- 继续用 `survivor_visual_budget_smoke.gd` 验证密集场景节点/网格预算。
