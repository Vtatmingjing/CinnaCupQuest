# 敌人/Boss 3D 视觉矩阵测试

运行命令：

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path . --script res://tests/survivor_enemy_visual_matrix.gd
```

通过标记：

```text
SURVIVOR_ENEMY_VISUAL_MATRIX_OK
```

覆盖范围：

- 普通怪：`voidling`、`skitter`、`spitter`、`burrower`、`carapace`、`void_eye`、`rift_crystal`
- Boss：`boss_cho`、`boss_velkoz`、`boss_reksai`、`boss_belveth`
- 精英词缀：`frenzy`、`bulwark`、`splitter`、`treasure`
- lite 普通怪模型：确认不会挂 `EnemySpeciesRoleBanner` 这类高成本读图层

关键断言：

- 详细普通怪必须有 `EnemySpeciesRoleBanner` 和 `EnemyReadabilityPlate`
- 详细普通怪、精英和 Boss 必须有 `VoidCreaturePremiumBodyRig` 与 `VoidCreaturePainterlyDepthRig`
- 精英必须有 `EliteTraitMarker`、`EliteBossCrest`、`ThreatHalo` 和 `HealthBar`
- Boss 必须有 `EnemySpeciesRoleBanner`、`EliteBossCrest`、`ThreatHalo`、`HealthBar`、`EnrageAura` 和 `WindupAura`
- 遁地/召唤类怪物必须保留 `ChargeLane` 或 `SummonAura`
- lite 普通怪必须禁止高成本本体层和手绘深度层

最近一次通过结果：

```text
SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=2124
```

用途：防止后续只优化怪潮性能时，把精英、Boss 或普通怪的职责读图层误删。
