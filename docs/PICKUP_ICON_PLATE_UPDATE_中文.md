# 掉落物奖励贴花更新

本轮目标是让高价值掉落物更接近参考图里的“奖励晶体/金币图标”质感，并且继续避免和敌方弹幕混在一起。

## 本轮改动

- 高价值 XP、金币、治疗、护盾新增 `PickupPremiumIconPlate`。
- 贴花复用 `art/textures/hextech_void_vfx_decal_atlas_v1.png`，不新增额外大图。
- 普通小 XP 不显示该贴花，避免怪潮后地面过亮。
- smoke test 增加 `PickupPremiumIconPlate` 断言。

## 视觉规则

- XP：蓝/绿晶体类贴花，强调成长奖励。
- 金币：金色海克斯阵贴花，强调价值。
- 治疗：警示徽记染红，和普通 XP 区分。
- 护盾：蓝色六边框贴花，和防御收益绑定。

## 后台验证

已通过：

```text
SURVIVOR_SMOKE_OK enemies=86 projectiles=57 pickups=47
SURVIVOR_VISUAL_BUDGET_OK enemies=66 meshes=8027 nodes=9861 projectiles=210 pickups=166 zones=31
```

说明：

- 166 个掉落物压力场景下，mesh 仍低于当前 8400 预算。
- 贴花只出现在高价值掉落上，后期不会让普通 XP 铺满地面。
