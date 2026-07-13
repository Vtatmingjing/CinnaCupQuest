# Zone 结算意图层更新

本批次把玩家区域技能补成更清晰的“结算/边界意图层”，目标是让技能圈不只是一层颜色，而是能看出它接下来会怎么生效。

## 更新内容

- `viktor_gravity` 新增 `containment_lock`：六边锁定框、夹具和倒计时针，强调机械控制场。
- `asol_singularity` 新增 `gravity_collapse`：星环、坍缩核心和星点，强调牵引坍缩。
- `morde_realm` 新增 `realm_execution`：铁域框、处决刃和锁链块，强调近战压迫。
- `teemo_mushroom` 新增 `poison_bloom`：毒爆花瓣和孢子核心，未触发时保持隐藏，触发后显示。

## 性能策略

- 结算层挂在已有 `Disc` 节点下，不改变战斗逻辑和碰撞逻辑。
- 每个区域只增加低段数 `Frame / Edge / TimerNeedle / Detail` 四个核心 mesh，避免在多区域场景里突破节点预算。
- 同时压缩 `ZoneSourceProfile` 的非核心小装饰，保留 `Ring / Badge / Detail` 三个识别点，让压力测试节点数有余量。
- Teemo 蘑菇沿用原来的未触发隐藏规则，避免陷阱待机时产生过多屏幕信息。

## 自动化覆盖

- `tests/survivor_zone_visual_matrix.gd` 检查每种区域的 `ZoneResolutionProfile`、类型 metadata、专属 detail 节点和 mesh 内容。
- `tests/survivor_headless_smoke.gd` 增加全局 smoke 断言，防止后续改动误删结算层。
