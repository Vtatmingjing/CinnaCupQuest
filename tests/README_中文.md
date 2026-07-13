# 后台测试说明

常规加载验证：

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --quit-after 3
```

生存模式 smoke test：

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_headless_smoke.gd
```

通过标记：

```text
SURVIVOR_SMOKE_OK
```

说明：Godot 4.3 在 headless dummy renderer 下大量生成 3D primitive mesh 时，可能输出 `mesh_get_surface_count` 噪音；只要脚本退出码为 0 且出现 `SURVIVOR_SMOKE_OK`，说明生存模式流程、3D 同步、敌人/弹体/掉落组的后台 smoke test 已通过。

当前 smoke test 还会强制覆盖裂隙水晶召唤、钻地/冲锋预警、召唤法阵节点、敌方弹幕贴地轨迹线、英雄身份投影节点、精英词缀徽记、Boss 压迫层/血量刻印和敌人数量上限，避免关键 3D 表现层与性能保护在后续优化中丢失。

其中裂隙水晶召唤段会冻结普通刷怪/精英计时，并直接推进目标水晶敌人的 `_process(0.06)`，用于避免 headless 环境真实帧 delta 过小导致机制触发断言不稳定。
