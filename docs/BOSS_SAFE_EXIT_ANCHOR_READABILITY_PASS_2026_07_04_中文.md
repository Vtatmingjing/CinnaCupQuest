# Boss 安全出口锚点可读性检查

日期：2026-07-04

本轮目标：继续降低 Boss 弹幕预警的误读风险，让玩家在乱战里能看懂“哪里危险、哪里能躲”，同时不增加光污染。

## 改动

- 每个 Boss 安全出口箭头新增暗色底托 `BossCastSafeExitAnchorMatte`。
- 新增入口短横 `BossCastSafeExitEntranceBar`，让安全路径的入口更明确。
- 新增前端对比缺口 `BossCastSafeExitContrastNotch`，帮助玩家区分安全提示和危险弹幕。
- 所有新增部件标记为 `boss_cast_safety_readability`，并加入 `pickup_confusion_guard`，避免和经验、金币、敌方弹幕共用视觉语义。
- Boss 施法同步阶段会轻微缩放安全箭头，但不引入镜头抖动或高频闪烁。

## 验证

- `SURVIVOR_BOSS_CAST_PATTERN_MATRIX_OK bosses=4 meshes=539`
- `SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=104 projectiles=28 pickups=44 visible=3496 bright=2951 max_luma=1.000 floor_avg=0.137 floor_max=1.000`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=43 pickups=32`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7781 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=90 meshes=6533 nodes=8522 projectiles=210 pickups=168 zones=31`

说明：headless dummy renderer 仍会输出 `Parameter "m" is null` 的 Godot 4.3 渲染后端噪声。本轮检查以脚本测试 OK 标记和无解析/脚本错误为准。
