# 虚空 Boss 徽记图集更新

本次更新给虚空 Boss 和精英怪补了一层更清晰的顶部身份视觉，目标是让玩家在混战里更快看出“这是谁、危险等级是什么”。

## 新增内容

- 新增原创图集 `art/textures/void_boss_emblem_atlas_v1.png`。
- 4 个 Boss 现在会显示专属 `BossIdentityIconTexture`：
  - `boss_cho`：吞噬巨口徽记。
  - `boss_velkoz`：单眼触须徽记。
  - `boss_reksai`：地底爪牙徽记。
  - `boss_belveth`：女王翼冠徽记。
- 精英怪新增 `VoidPriorityEmblem` 和 `ElitePriorityIcon`，分别表现狂暴、护盾、分裂、宝藏等精英词缀。
- 普通怪和低配怪物模型不加载这层额外视觉，避免怪物数量多时增加不必要负担。

## 验证

`tests/survivor_enemy_visual_matrix.gd` 现在会检查：

- Boss 徽记图集是否存在且尺寸达标。
- 每个 Boss 是否挂载 `VoidPriorityEmblem` 与 `BossIdentityIconTexture`。
- 每个精英怪是否挂载 `VoidPriorityEmblem` 与 `ElitePriorityIcon`。
- 低配普通怪不会错误加载 Boss/精英优先级图层。
