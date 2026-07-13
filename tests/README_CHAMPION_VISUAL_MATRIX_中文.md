# 英雄 3D 视觉矩阵测试

运行命令：

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_champion_visual_matrix.gd
```

通过标记：

```text
SURVIVOR_CHAMPION_VISUAL_MATRIX_OK
```

这个测试会直接构建 8 个英雄的 3D 模型：

- `jinx`
- `senna`
- `samira`
- `viktor`
- `xayah`
- `mordekaiser`
- `teemo`
- `aurelion_sol`

每个英雄都会检查这些核心视觉节点：

- `ChampionIdentityProjection`
- `ChampionFanSignature`
- `ChampionPremiumBodyRig`
- `ChampionPainterlyDepthRig`
- `ChampionKitSilhouette`
- `ChampionCombatStanceRig`
- `ChampionArchetypeSilhouetteRig`
- `ChampionAbilityEmblems`
- `ChampionMechanicMeter`
- `ChampionLiveAura`
- `ChampionAttackBurst`
- `PlayerStatusRings`
- `ChampionUpgradeRoutes`
- `RoleRouteRings`

最近一次通过结果：

```text
SURVIVOR_CHAMPION_VISUAL_MATRIX_OK champions=8 meshes=2851 ability_atlas=1536x1024 archetype=role_silhouette
```

用途：防止只验证默认英雄，导致后续某个英雄的粉丝识别层、职业剪影层、升级路线层或战斗光环在重构中静默损坏。
