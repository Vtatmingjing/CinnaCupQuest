# 玩家弹体英雄徽记更新

本轮目标是强化不同英雄攻击弹体的第一眼差异，减少“所有人都在丢同一种球”的感觉。

## 本轮改动

- 非 lite 玩家弹体新增 `PlayerProjectileHeroGlyph`。
- 徽记复用 `art/textures/hextech_void_vfx_decal_atlas_v1.png`。
- 火箭/子弹、赛娜/维克托光束、霞羽毛、提莫毒镖、龙王彗星分别使用不同图集格子和染色。
- lite 玩家弹体不生成该节点，后期弹体过多时自动保留轻量签名 rig，避免预算被击穿。

## 后台验证

已通过：

```text
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=9 meshes=509
SURVIVOR_SMOKE_OK enemies=86 projectiles=56 pickups=49
SURVIVOR_VISUAL_BUDGET_OK enemies=65 meshes=7808 nodes=9624 projectiles=210 pickups=166 zones=31
```

说明：

- full 玩家弹体必须有 `PlayerProjectileHeroGlyph`。
- lite 玩家弹体被测试强制确认不携带该节点，也不携带重型 `ProjectileVfxDecal`。
- 210 个弹体压力场景下，整体 mesh 仍明显低于当前 8400 预算。
