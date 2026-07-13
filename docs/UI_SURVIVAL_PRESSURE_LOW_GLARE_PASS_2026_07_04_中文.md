# UI 对齐、生存压力与低光污染修正记录 - 2026-07-04

本轮针对试玩反馈继续收敛三个问题：选人/海克斯/升级界面贴图错位，整体缺少生存压力，场内发光过强导致敌人、弹幕、经验混在一起。

## UI 贴图对齐

- `scripts/survivor_hud.gd`
  - 英雄、升级/海克斯、商店卡片媒体槽改为更保守的固定尺寸：
    - 英雄：`72x72`
    - 升级/海克斯：`64x64`
    - 商店：`48x48`
  - 媒体槽现在写入 `media_slot_rect`、`media_inner_rect`、`media_slot_padding`、`media_alignment_mode` 和 `media_visual_rect`。
  - 英雄头像使用居中覆盖裁切，升级/海克斯/商店图标使用居中等比显示，避免贴图压住标题和描述。
  - 英雄卡片略微加高，选人页行距同步增加，减少头像、标题、徽章互相挤压。

- `tests/survivor_hud_visual_matrix.gd`
  - 更新槽位尺寸断言。
  - 新增 padding、对齐模式、可视矩形 metadata 断言。
  - 继续验证选人、升级、海克斯、商店、从商店返回升级页时不会残留旧图层。

## 生存压力

- `scripts/survivor_main.gd`
  - Boss 时间从 `105s` 提前到 `90s`。
  - 首个精英时间从 `3.0s` 提前到 `2.2s`。
  - 刷怪基础间隔、最小间隔和时间衰减都改得更紧。
  - 180 秒后新增一档刷怪压力，200 秒中期包围感更明显。
  - 保持 `MAX_ENEMIES = 104`，不靠无限堆数量制造难度。

- `scripts/survivor_enemy.gd`
  - 普通敌人波次生命、速度成长提高。
  - 11 波后追加后期成长。
  - 远程和精英攻击节奏进一步压缩，后期弹幕压力更明显。

- `tests/survivor_difficulty_curve_matrix.gd`
  - Boss 断言更新为 `90s`。
  - 中期刷怪包、后期刷怪包、精英计时、敌人成长和攻击节奏断言同步收紧。

## 低光污染

- `scripts/survivor_3d_view.gd`
  - 环境光、曝光、glow、bloom、主光、补光和边缘光继续下调。
  - 材质发光最低夹取从 `0.025` 降到 `0.008`，避免小特效被强行抬亮。
  - 玩家弹体、区域技能、脉冲、拾取物、贴花的 alpha 和 emission 上限继续降低。
  - 敌方弹幕保留暗芯、红黑危险轮廓和地面分离层，不再靠高发光提示危险。

- `tests/survivor_material_quality_matrix.gd`
  - 收紧环境光、曝光、glow、灯光、能量材质、贴花 emission 断言。

- `tests/survivor_glare_budget_matrix.gd`
  - 全局发光阈值收紧到 `0.126`。
  - 敌方弹幕发光阈值收紧到 `0.096`。
  - 玩家弹体发光阈值收紧到 `0.063`。
  - 拾取物发光阈值收紧到 `0.039`。

## Headless 验证注意

Godot 4.3 本机命令行不支持 `--user-data-dir`，如果不指定 log 位置会尝试写 `user://logs`，在当前沙盒环境下可能失败并弹出 Windows 崩溃框。

后续后台测试统一使用：

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\test.log --path . --script res://tests/survivor_headless_smoke.gd
```

`mesh_get_surface_count` 的大量输出来自 Godot dummy/headless 渲染器，当前只作为噪声处理；测试是否通过以 `SURVIVOR_*_OK` 行和进程退出码为准。

## 已通过 targeted 验证

```text
SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean
SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=90 timers=survival_pressure_v4 spawn_steps=challenge_v4 enemy_growth=harder_v4 attacks=pressure
SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.00 ambient=0.06 key=0.56 metal=0.74 rough=0.90 rim=true family=metal/energy/stone
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7034 models=46 emission=0.094 alpha=0.353 enemy=0.082 player=0.041 pickup=0.012 danger=0.252
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1449
SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=32
```
