# 可读性与生存压力修正记录

本批针对当前试玩反馈处理三类问题：选择界面贴图错位、整体难度偏低、场内光污染导致敌人和弹幕不清楚。

## HUD 贴图对齐

- 英雄选择头像固定为 `70x70` 媒体槽。
- 升级、命运和海克斯选择固定为 `64x64` 媒体槽。
- 商店装备图标固定为 `54x54` 媒体槽。
- 卡片切换时会清理旧纹理、旧 fallback 文本、旧缩放和旧可见状态，避免上一页的贴图残留到下一页。
- `tests/survivor_hud_visual_matrix.gd` 新增媒体槽尺寸、中心点和布局类型断言。

## 生存压力

- Boss 出场时间从 `120s` 继续提前到 `105s`。
- 首个精英计时收紧到 `6.2s`，精英相关命运会进一步提前到 `4.6s-4.8s`。
- 刷怪间隔改为 `max(0.05, 0.34 - elapsed * 0.0046)`，但 `MAX_ENEMIES` 仍保持 `104`，避免靠无上限堆怪制造卡顿。
- 中后期刷怪批次增加，普通敌人血量、速度和伤害成长提高。
- 精英怪生命提高，出现频率更高，仍保留现有精英特质和奖励。

## 降低光污染

- 全局环境泛光压到 `glow_intensity 0.018 / strength 0.075 / bloom 0.004`，环境光和主灯强度同步降低。
- 拾取物、玩家弹体、区域技能和脉冲特效的透明度/发光上限进一步压低。
- 敌方弹幕保留黑芯、红色危险轮廓、地面轨迹和威胁标记，减少被 XP/金币/技能光效混淆。

## 本批新增防残留测试

- `tests/survivor_hud_visual_matrix.gd` 增加“商店 18 格 -> 升级 3 选项”的页面切换回归。
- 非商店页面现在会强制断言没有价格牌、路线标签和路线 pips 残留。
- 隐藏卡片会强制断言旧标题、旧描述、旧 fallback 图标、旧徽章和旧纹理全部清空。

## 验证结果

```text
SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean
SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=105 timers=survival_pressure spawn_steps=challenge_plus enemy_growth=late
SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.02 ambient=0.13 key=0.98 metal=0.74 rough=0.90 rim=true family=metal/energy/stone
SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=1672x941 meshes=1391 citadel_nodes=8 strata=8
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1449
SURVIVOR_SMOKE_OK enemies=104 projectiles=41 pickups=38
SURVIVOR_VISUAL_BUDGET_OK enemies=80 meshes=6698 nodes=8521 projectiles=210 pickups=168 zones=31
```

Godot headless 在当前受限环境中需要加 `--log-file` 指向项目内路径，否则默认 `user://logs` 可能因无写权限触发引擎崩溃。
