# 英雄施法读招与启动防崩加固记录

日期：2026-07-04

## 本次处理的问题

用户截图显示 Windows 原生弹窗：

```text
Godot_v4.3-stable_win64.exe - 应用程序错误
0x00007FF7FBF9131D 指令引用了 0x0000000000000060 内存。该内存不能为 read。
```

项目当前 headless 初始化和矩阵测试均可通过，说明这次截图更符合 Godot GUI/渲染初始化阶段原生崩溃，不是当前 GDScript 解析错误。桌面现有快捷方式指向项目内稳定 bat，而截图标题是原始 GUI exe，因此优先判断为没有走稳定入口，或走了旧的固定项/旧入口。

## 修改内容

- `scripts/survivor_3d_view.gd`
  - 新增并同步 `ChampionSignatureCastPatternFloor` 的动态表现。
  - 8 个英雄使用不同低眩光地面读招逻辑：
    - Jinx：炮击直线与落点。
    - Senna：穿透光束与侧向锚点。
    - Samira：近战连斩弧线。
    - Viktor：海克斯射线格。
    - Xayah：羽毛扇形与回收线。
    - Mordekaiser：领域重击圈。
    - Teemo：蘑菇陷阱半径。
    - Aurelion Sol：星轨与星落。
  - 补齐 Senna、Xayah 的 `ChampionCastPatternAnchorPips`，避免读招层存在空锚点节点。

- `tests/survivor_champion_visual_matrix.gd`
  - 覆盖 `ChampionSignatureCastPatternFloor` 的必备子节点、英雄元数据、专属读招类型、命中点数量、低眩光材质预算和同步可见性。
  - 验证升级为“有节点还不够，必须有专属读招内容并能随攻击准备度同步”。

- `launch_stable_opengl.bat`
  - 保持 console 版 Godot、`opengl3_angle`、`gl_compatibility`、`--render-thread safe`、`--max-fps 60`。
  - 增加启动参数记录：
    - `Launcher`
    - `StartedAt`
    - `SafeEntry`
    - `ExitCode`
  - 使用 `start /wait /min`，便于 Godot 退出或崩溃后记录退出码。

- `launch_editor_stable_opengl.bat`
  - 同步增加安全入口记录和退出码记录。

- `tests/survivor_startup_stability_matrix.gd`
  - 启动稳定性测试现在要求 bat 包含 `/wait`、`SafeEntry=`、`ExitCode=%ERRORLEVEL%`，避免后续回退。

## 验证结果

未打开游戏 GUI，仅使用 Godot console/headless：

```text
SURVIVOR_STARTUP_STABILITY_OK renderer=gl_compatibility feature=GL_Compatibility
SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=2916 ability_atlas=1536x1024 archetype=role_silhouette
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=13 meshes=1643
SURVIVOR_GLARE_BUDGET_MATRIX_OK materials=7650 models=46 emission=0.078 alpha=0.326 enemy=0.067 player=0.035 pickup=0.012 danger=0.246 profile=low_glare_v6
SURVIVOR_VISUAL_BUDGET_OK enemies=104 meshes=5766 nodes=7578 projectiles=210 pickups=169 zones=31
SURVIVOR_SMOKE_OK enemies=104 projectiles=42 pickups=31
```

另执行纯 headless 初始化：

```text
D:\Godot\Godot_v4.3-stable_win64_console.exe --disable-crash-handler --headless --rendering-driver opengl3 --rendering-method gl_compatibility --path . --quit-after 3
```

退出码：`0`

## 使用判断

如果再次出现同类 Windows 原生弹窗，先检查：

```text
.godot-user\play_stable_angle_args.txt
.godot-user\editor_stable_angle_args.txt
```

如果文件没有更新，说明没有走项目稳定入口。优先使用桌面 `CinnaCupQuest 试玩游戏.lnk`，不要直接双击 `D:\Godot\Godot_v4.3-stable_win64.exe`。

headless 日志中的 `Parameter "m" is null` 来自 Godot dummy renderer，在本批测试中退出码仍为 0，并且通过标记已输出，不等同于 GUI 启动崩溃。
