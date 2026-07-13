# UI 对齐、挑战强度与低眩光修正记录

日期：2026-07-03

## 本轮目标

针对试玩反馈修正三个问题：

- 角色选择、升级、海克斯选择、商店卡片上的贴图和文字间距不稳定。
- 生存压力不足，后期仍然偏简单。
- 场内特效、拾取物和弹幕整体过亮，敌人和危险弹幕不够清楚。

## 已修改内容

### UI 对齐

- 英雄选择头像改为 `AtlasTexture` 焦点裁切，保留原 PNG，不破坏素材文件。
- 英雄头像槽从 70x70 调整为 76x76，优先显示角色上半身和武器特征。
- 升级和海克斯卡图标槽从 64x64 调整为 68x68。
- 卡片标题、描述、徽章、商店价格区域增加安全间距，避免贴图压字或徽章贴到标题。
- HUD 测试新增头像焦点裁切和媒体、标题、描述、徽章间距校验。

### 难度曲线

- 敌人刷新基础间隔从 `0.30` 降为 `0.26`。
- 最小刷新间隔从 `0.042` 降为 `0.034`。
- 首个精英计时从 `5.2` 降为 `4.4`。
- 精英刷新基础间隔和最小间隔同步收紧。
- 敌人中后期生命、速度、伤害成长提高。
- 刷怪包基础数量从 14 提到 16，并加入 11、13 波和 360 秒后的压力阶梯。
- 敌人总上限仍保持 104，避免靠无上限堆怪制造卡顿。

### 低眩光与可读性

- 3D 环境 glow、环境光、主光、补光、轮廓光整体下调。
- 透明材质、区域技能、脉冲、拾取物、玩家弹体、敌方弹体的 alpha 和 emission 上限下调。
- 敌方弹幕保留红黑危险形状，降低紫色核心和拖尾泛光，避免与 XP、金币混淆。
- 2D fallback 敌弹同步降低泛光强度。

## 验证结果

```text
SURVIVOR_HUD_VISUAL_MATRIX_OK portraits=8 icons=27 shop_cards=18 layout=aligned reset=clean
SURVIVOR_DIFFICULTY_CURVE_MATRIX_OK boss=105 timers=survival_pressure_plus spawn_steps=challenge_harder enemy_growth=harder
SURVIVOR_MATERIAL_QUALITY_MATRIX_OK glow=0.01 ambient=0.09 key=0.76 metal=0.74 rough=0.90 rim=true family=metal/energy/stone
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1449
SURVIVOR_SMOKE_OK enemies=104 projectiles=41 pickups=37
SURVIVOR_VISUAL_BUDGET_OK enemies=85 meshes=6753 nodes=8599 projectiles=210 pickups=168 zones=31
```

说明：Godot headless dummy renderer 仍会输出 `Parameter "m" is null`，本轮以退出码和 `SURVIVOR_*_OK` 标记为通过依据。
