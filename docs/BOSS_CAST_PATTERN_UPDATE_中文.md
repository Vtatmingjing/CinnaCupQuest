# Boss 专属施法图案更新

本轮强化 Boss 出招预警，让四个虚空 Boss 不再共用同一套泛红法阵，而是在脚下显示不同的危险形状。

## 新增内容

- `BossCastPatternRig`：挂在 `BossFocus` 下的专属图案组，只有 Boss 即将出手时显示。
- `BossCastPatternCho`：五边形裂地环和外圈尖牙，读感偏 Cho'Gath 的撕裂/击飞。
- `BossCastPatternVelkoz`：多线激光扇形，读感偏 Vel'Koz 的几何射线。
- `BossCastPatternReksai`：长条钻地轨迹和交错地刺，读感偏 Rek'Sai 的突进裂隙。
- `BossCastPatternBelveth`：左右翼刃扫掠，读感偏 Bel'Veth 的翼形斩击。

## 设计取舍

- 图案贴地显示，不再增加相机倾斜或抖动，避免玩家头晕。
- 四套图案常驻构建但只显示当前 Boss 的一套，切换成本低。
- 使用低高度 mesh 和已有材质，不额外引入大贴图。

## 验证

- `SURVIVOR_BOSS_CAST_PATTERN_MATRIX_OK bosses=4 meshes=30`
- `SURVIVOR_SMOKE_OK enemies=90 projectiles=60 pickups=45`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=67 meshes=6910 nodes=8718 projectiles=210 pickups=166 zones=31`
