# 美术方向参考

`hex_void_art_direction.png` 是当前项目的基础美术参考板，用于统一后续场景、角色、怪物、弹幕和拾取物的视觉方向。

`hextech_void_premium_asset_board_v1.png` 是后续打磨用的原创高质感参考板，包含竞技场、虚空怪、弹幕、拾取物和海克斯边框元素；不要当成官方素材使用，也不要直接覆盖游戏运行贴图。

`hextech_void_vfx_atlas_v1.png` 是进一步对齐效果图的原创 VFX/掉落/敌人拆解板，优先用于拆分弹幕颜色、奖励物读图、虚空虫群剪影和小型场景装置。

`champion_identity_board_v1.png` 是 8 名可选英雄的原创身份参考板，用于继续打磨程序化 3D 模型、武器剪影和技能 VFX 符号。

`art/textures/hextech_void_arena_floor_painted_v2.png` 是当前 3D 生存模式优先加载的横屏主地面贴图，`v1` 保留为兜底。

`art/textures/void_carapace_tile_v2.png` 是当前虚空敌人优先使用的甲壳材质，`v1` 保留为兜底。

`art/textures/hextech_metal_tile_v2.png` 是当前海克斯金属、金色边框、场景装置和拾取物金属件优先使用的材质，`v1` 保留为兜底。

`art/textures/void_corruption_tile_v2.png` 是当前虚空腐化地面叠层优先使用的材质，`v1` 保留为兜底。

`art/textures/hextech_warning_rune_tile_v1.png` 是当前冲锋线、召唤法阵和危险预警优先使用的原创海克斯符文贴图。

`art/champions/portraits/*_identity_v1.png` 是从原创英雄身份参考板裁出的局内身份投影贴图，用于强化当前程序化/外部模型的英雄辨识度。

执行原则：

- 战斗区域使用暗色六边形地面和少量发光边界，避免调试网格感。
- 怪物用紫红色威胁色和底部威胁环，尺寸必须明显大于经验/金币。
- 经验和金币保持小而亮，不和敌方弹幕混淆。
- 敌方弹幕使用高亮红紫色，玩家弹幕使用英雄主题色。
- 没有授权模型时，用清晰剪影和轮廓表达角色，不追求复杂人体细节。
- 有本地授权模型时，优先放入 `art/champions/models/` 并用 `model_config.json` 调整大小和朝向。
