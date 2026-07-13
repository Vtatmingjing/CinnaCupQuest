# 英雄专属施法准备层更新

本轮给玩家英雄新增 `ChampionSignatureCastRig`，让不同英雄在下一次攻击/技能即将就绪时显示不同的贴地专属图案。

## 新增内容

- `ChampionSignatureCastCore`：每个英雄都有轻量核心环，提示攻击节奏。
- `ChampionSignatureCastLane`：显示当前英雄攻击方向或攻击范围的基础形状。
- `ChampionSignatureCastMotif`：专属英雄 motif。
  - Jinx：火箭导轨和蓝粉弹药珠。
  - Senna：灵魂长枪光束和门环。
  - Samira：近战圆舞和多段斩线。
  - Viktor：海克斯核心和激光轨道。
  - Xayah：羽毛扇形。
  - Mordekaiser：死亡领域环和锤形印记。
  - Teemo：毒镖轨迹和孢子环。
  - Aurelion Sol：星轨和彗星预备线。

## 同步方式

- 使用 `attack_timer / attack_cooldown` 计算攻击准备度。
- 攻击接近就绪时才显示，不常驻占画面。
- 只存在于当前玩家模型，怪多弹多时不会放大成本。

## 验证

- `SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=1919 ability_atlas=1536x1024`
- `SURVIVOR_SMOKE_OK enemies=81 projectiles=60 pickups=55`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=64 meshes=6886 nodes=8690 projectiles=210 pickups=166 zones=31`
