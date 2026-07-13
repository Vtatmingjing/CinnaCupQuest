# 优先级威胁状态条更新

## 目标

- 在不增加光污染的前提下，让 Boss 和精英怪在混战中更容易被玩家读出来。
- 把已有 `PriorityCombatBackplateRig` 从静态低眩光底板升级为动态状态层。
- 保留 lite 普通怪的轻量路径，避免怪潮阶段增加预算压力。

## 已修改

- `scripts/survivor_3d_view.gd`
  - 新增 `PriorityThreatStateStrip`，只挂在 Boss 和精英怪的 `PriorityCombatBackplateRig` 下。
  - 状态条包含暗底、低眩光 meter、金色 trim 和阶段 pip。
  - 新增 `_sync_priority_combat_backplate()`：
    - Boss 会根据血量、攻击准备、激怒、召唤/冲锋状态提高 `priority_urgency`。
    - 精英会根据词缀状态提高 `priority_urgency`：狂暴冲锋、堡垒破盾、分裂低血量、宝藏逃离都会点亮状态条。
    - 状态条只使用非 emissive 低透明材质，避免重新制造光污染。

- `tests/survivor_enemy_visual_matrix.gd`
  - 检查 Boss/精英必须拥有 `PriorityThreatStateStrip`、`PriorityThreatStateMeter` 和 `PriorityThreatStagePips`。
  - 继续断言优先级背板材质不能使用 emissive，透明度不能超过低眩光阈值。

- `tests/survivor_boss_phase_state_visual_matrix.gd`
  - 构造低血量 Boss 后同步优先级状态条，断言 `priority_urgency`、meter 和阶段 pip 生效。

- `tests/survivor_elite_trait_state_visual_matrix.gd`
  - 构造四类精英词缀状态后同步优先级状态条，断言每类词缀都能点亮动态状态层。

## 验证

```text
SURVIVOR_BOSS_PHASE_STATE_VISUAL_MATRIX_OK bosses=4
SURVIVOR_ELITE_TRAIT_STATE_VISUAL_MATRIX_OK traits=4
SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2183
SURVIVOR_VISUAL_BUDGET_OK enemies=80 meshes=6288 nodes=8066 projectiles=210 pickups=168 zones=31
SURVIVOR_SMOKE_OK enemies=101 projectiles=66 pickups=37
FULL_SURVIVOR_REGRESSION_OK tests=24
```

备注：Godot 4.3 headless dummy renderer 仍会输出 `Parameter "m" is null` 噪声；本批以退出码 0 和 `SURVIVOR_*_OK` 标记为准。
