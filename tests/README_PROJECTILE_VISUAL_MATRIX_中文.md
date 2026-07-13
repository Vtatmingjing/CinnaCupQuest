# 投射物 3D 视觉矩阵测试

运行命令：

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_projectile_visual_matrix.gd
```

通过标记：

```text
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK
```

覆盖范围：

- 玩家弹幕：`fishbones`、`death_rocket`、`senna`、`samira`、`viktor`、`xayah`、`teemo`、`comet`、`morde`
- 敌方弹幕：`A`、`E`、`C`、`R`、`Q`、`V`、`X`、`B`、`void_spit`
- 玩家 lite 弹幕分支
- 敌方 lite 弹幕分支

关键断言：

- 玩家弹幕必须有 `PlayerProjectileSignatureRig`
- 敌方弹幕必须有 `EnemyProjectileLane` 和 `EnemyProjectileDangerRig`
- 高威胁敌方弹幕 `A/E/C/R/Q/V/X/B` 必须有 `EnemyProjectileThreatBadge`

最近一次通过结果：

```text
SURVIVOR_PROJECTILE_VISUAL_MATRIX_OK player=9 enemy=9 meshes=482
```

用途：防止后续优化弹幕密度或视觉预算时，把英雄弹幕签名、敌方地面轨迹和高威胁徽记退化成普通发光球。
