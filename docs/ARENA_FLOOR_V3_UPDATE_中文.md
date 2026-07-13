# 竞技场地板 v3 美术接入

本轮目标是继续向参考图里的“暗色海克斯竞技场 + 虚空侵蚀边缘 + 清晰战斗中心”靠近，同时不增加大量动态节点，不打开游戏窗口，只做后台验证。

## 本轮改动

- 新增原创横屏竞技场地板贴图：`art/textures/hextech_void_arena_floor_painted_v3.png`。
- 3D 主地面优先使用 v3，找不到时回退到 v2，再回退到 v1，最后才回退到程序化石板。
- 主地板节点命名为 `ArenaPaintedFloor`，方便测试和后续调试。
- 新增后台视觉矩阵测试：`tests/survivor_arena_visual_matrix.gd`。

## 美术方向

- 中心区域保留大块干净的六边形石板，给玩家、敌人、弹幕和掉落物留出读图空间。
- 外圈使用金色斜角、蓝色海克斯能量槽、角落水晶和紫色虚空侵蚀来接近效果图的完整竞技场构图。
- 不包含官方 logo、角色、UI 字样或不可控版权标记，只保留粉丝向可理解的视觉语言。

## 后台验证

已通过：

```text
SURVIVOR_ARENA_VISUAL_MATRIX_OK texture=1672x941 meshes=762
```

测试会检查：

- v3 贴图可以被 Godot 加载。
- 贴图尺寸不低于 1280x720。
- 3D 视图实际选择 v3，而不是意外回退。
- `ArenaPaintedFloor` 材质已经绑定纹理。
- `ArenaPremiumSetDressing`、`ArenaMotionRig`、`BossPressureRig` 等关键场景层仍然存在。
- 静态场景 mesh 数量保持在预算内。

## 生成提示词记录

使用内置图像生成工具生成项目资产，关键约束为：

```text
Top-down 16:9 dark hextech-vs-void battleground floor plate, original fan-inspired fantasy MOBA style, central octagonal hex-tile platform, gold beveled trim, blue crystal channels, violet void corruption from edges, empty playable arena, no characters, no monsters, no projectiles, no UI, no text, no logos, no official symbols, readable center, high-polish hand-painted game asset.
```
