# 3D 视觉预算测试

运行命令：

```powershell
New-Item -ItemType Directory -Force .godot-user | Out-Null
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --log-file .godot-user/survivor_visual_budget_smoke.log --path . --script res://tests/survivor_visual_budget_smoke.gd
```

通过标记：

```text
SURVIVOR_VISUAL_BUDGET_OK
```

这个测试会在后台构造一个高压场景：接近上限的敌人、130 个弹幕、约 110 个拾取物、16 个区域技能，然后统计 3D 视图里的 `MeshInstance3D` 和总节点数。

高压场景还会检查普通 XP 拾取物是否启用 `LitePickupCore`，避免密集掉落时每颗 XP 都使用完整高级装饰层。

当前阈值：

- `MAX_MESH_INSTANCES = 5600`
- `MAX_TOTAL_NODES = 7200`
- `EXPECTED_MAX_ENEMIES = 60`

最近一次通过结果：

```text
SURVIVOR_VISUAL_BUDGET_OK enemies=51 meshes=4564 nodes=5691 projectiles=84 pickups=55 zones=10
```

说明：这个测试不是精确 FPS 基准，因为 headless dummy renderer 不代表玩家机器的真实渲染性能。它用于防止后续继续加 3D 美术层时节点数量失控。
