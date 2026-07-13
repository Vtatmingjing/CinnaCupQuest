# 敌人物种贴花更新

本轮目标是让普通虚空小怪在近景时更有“物种剪影”和粉丝向辨识度，同时不牺牲密集怪潮性能。

## 本轮改动

- 普通详细敌人、精英、Boss 新增 `EnemySpeciesDecal`。
- 贴花复用 `art/textures/hextech_void_vfx_decal_atlas_v1.png`，按敌人类型抽取不同格子：
  - 迅捷虫：紫色虚空框。
  - 喷吐虫：染绿晶体/腐蚀感贴花。
  - 钻地虫和 Rek'Sai 类 Boss：橙色危险徽记。
  - 甲壳虫和 Cho 类 Boss：紫色重甲框。
  - 虚空眼和 Vel'Koz 类 Boss：紫色漩涡。
  - 裂隙水晶：蓝色晶体。
  - Bel'Veth 类 Boss：紫色晶体爆发。
- lite 敌人不生成该节点，密集怪潮仍保持轻量模型。

## 后台验证

已通过：

```text
SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 meshes=1098
SURVIVOR_SMOKE_OK enemies=84 projectiles=58 pickups=46
SURVIVOR_VISUAL_BUDGET_OK enemies=64 meshes=8049 nodes=9896 projectiles=210 pickups=168 zones=31
```

说明：

- 敌人矩阵要求普通详细怪、精英、Boss 都有 `EnemySpeciesDecal`。
- lite 怪会被测试强制确认不携带该节点。
- 大量敌人和掉落物场景下，整体 mesh 仍低于当前 8400 预算。
