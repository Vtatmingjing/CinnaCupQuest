# 首屏黑屏与可见性修复记录

## 背景

用户反馈“进去游戏什么都看不见”。这次排查确认桌面快捷方式已经能正常启动，实际日志显示：

- OpenGL 兼容渲染初始化成功。
- 真实启动退出码为 0。
- 没有脚本解析错误或运行时崩溃。

因此本轮优先处理真实窗口里过暗、首屏 UI 黑底过重、headless 测试没有覆盖首屏可见性的缺口。

## 修改内容

- 提高 3D 场景基础可见性：
  - 环境背景从近黑色提高到深蓝灰。
  - 环境光从 `0.048` 提到 `0.240`。
  - 曝光从 `0.36` 提到 `0.820`。
  - 主光、补光、边缘光同步增强。
  - 地板材质 tint 提亮，避免真实 OpenGL 窗口里地板和角色被压成黑块。
- 降低首屏 HUD 黑底压迫感：
  - 菜单 overlay alpha 从 `0.97` 降到 `0.88`。
  - 选人/升级卡片底色略提亮，避免文本和头像被暗底吞掉。
- 新增 `tests/survivor_startup_visibility_gate.gd`：
  - 检查 1280x720 横屏。
  - 检查首屏停在选人菜单。
  - 检查 3D 相机、环境光、曝光、主光和地板材质亮度。
  - 检查菜单 overlay 不再接近全黑。
  - 检查 8 张英雄卡、8 个头像、中文标题和开始按钮可见。
- 收紧 `tests/survivor_playability_readability_gate.gd`：
  - 提高环境光、曝光、主光和地板材质亮度门槛，防止以后再次把画面调成“数值过线但人眼看不见”。
- 性能保护：
  - 玩家弹幕高密度 LOD 阈值从 `96` 收紧到 `80`，大量弹幕时更早切 lite 版本。
  - 高密度预算回到 `meshes=6340 / nodes=8271`，低于 `9000` 节点保护线。

## 验证结果

以下均为 Godot headless 后台验证，未主动打开游戏 GUI：

- `SURVIVOR_STARTUP_VISIBILITY_OK viewport=1280x720 ambient=0.240 exposure=0.820 overlay_alpha=0.88 hero_cards=8 portraits=8`
- `SURVIVOR_PLAYABILITY_READABILITY_GATE_OK viewport=1280x720 alive=true enemies=103 projectiles=63 pickups=45 visible=2715 bright=1838 max_luma=1.158 floor_avg=0.137 floor_max=1.000`
- `SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility`
- `SURVIVOR_SMOKE_OK enemies=104 projectiles=45 pickups=32`
- `SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=8224 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=6340 nodes=8271 projectiles=210 pickups=169 zones=31`
- `SURVIVOR_PICKUP_VISUAL_MATRIX_OK cases=6 meshes=206`
- `SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1929`

## 备注

Godot headless dummy renderer 仍会输出大量 `Parameter "m" is null`，这是 headless 渲染后端噪声。本次判断以 `SURVIVOR_*_OK` 标记和是否存在脚本错误为准。
