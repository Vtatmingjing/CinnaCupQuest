# 敌人威胁阶级轮廓更新记录

## 目标

继续降低战斗画面的光污染，同时提升混战时的敌人辨识度。普通怪、精英怪、Boss 不能只靠颜色和亮光区分，需要有稳定的低眩光轮廓语言，避免和经验、金币、弹幕混在一起。

## 修改

- `scripts/survivor_3d_view.gd`
  - 新增 `EnemyThreatRankSilhouetteRig`。
  - 普通怪使用 `EnemyThreatRankNormalPips`，以低透明度小点和短箭头表示基础威胁。
  - 精英怪使用 `EnemyThreatRankEliteSpikes`，增加尖刺和奖励提示点，保留精英词缀元数据。
  - Boss 使用 `EnemyThreatRankBossCrown`，增加冠状齿和危险条，强化远距离识别。
  - 所有材质均为低眩光透明材质，发光强度为 0。
  - 不添加到 lite 敌人，避免密集场景下增加无谓节点和网格预算。
- `tests/survivor_enemy_visual_matrix.gd`
  - 新增普通怪、精英怪、Boss、Boss 变体的威胁阶级轮廓断言。
  - 新增 lite 敌人禁止携带 `EnemyThreatRankSilhouetteRig` 的断言。
  - 新增材质预算检查：`max_emission=0.02`，`max_transparent_alpha=0.36`。

## 验证

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\survivor_enemy_visual_matrix_threat_rank.log --path . --script res://tests/survivor_enemy_visual_matrix.gd
```

通过结果：

```text
SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2575
```

## 设计约束

- 优先使用形状语言区分威胁等级，不继续堆强光。
- 不影响已有的 `PriorityCombatBackplateRig` 规则：普通怪仍不携带精英/Boss 专用背板。
- 不影响 lite 敌人路径，保证大量怪物出现时仍有预算余量。
