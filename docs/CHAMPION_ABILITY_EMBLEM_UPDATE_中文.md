# 英雄技能徽记更新

这次把英雄辨识度往“粉丝一眼能懂”方向推进了一步。

## 新增资产

- 新增 `art/textures/champion_ability_emblem_atlas_v1.png`。
- 这是一张 6x4 原创技能徽记图集，共 24 个图标。
- 每个英雄占 3 个格子，对应自己的 3 条专属升级/技能路线：
  - 金克丝：火箭、烟花、速度过载。
  - 赛娜：灵魂、圣枪光束、护盾黑雾。
  - 莎弥拉：连招刀痕、炼狱旋风、悍勇护心。
  - 维克托：激光、重力场、海克斯核心。
  - 霞：羽毛、倒钩、禁锢。
  - 莫德凯撒：铁锤、死亡领域、铁甲。
  - 提莫：毒镖、蘑菇、致盲吹箭。
  - 龙王：星轨、黑洞、彗星。

## 3D 接入

- `scripts/survivor_3d_view.gd`
  - 新增 `ChampionAbilityEmblems`。
  - 每个英雄模型旁边固定显示 3 个图集徽记。
  - 徽记使用小幅呼吸和轻微摆动，不移动镜头、不强旋转。
  - 外部授权模型接入路径也会自动挂上这套徽记，避免替换模型后丢失英雄技能识别。

## 验证

- `tests/survivor_champion_visual_matrix.gd`
  - 检查技能徽记图集能加载，尺寸不低于 1200x800。
  - 检查 8 个英雄都拥有 `ChampionAbilityEmblems`。
  - 检查每个英雄都有 3 个图集纹理徽记。
- `tests/survivor_visual_budget_smoke.gd`
  - 高压场景下仍满足 mesh/node 预算。

