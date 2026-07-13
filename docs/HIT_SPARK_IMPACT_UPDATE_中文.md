# 命中火花视觉层更新

本轮新增 `survivor_hit_spark.gd` 和 3D 同步层，用更明确的命中火花把英雄攻击、敌人弹幕、经验掉落和范围脉冲区分开。

## 视觉目标

- 普通物理命中使用短促交叉斩线，读感更像近战/射手打击。
- 魔法命中加入六边形符文、十字能量线和悬浮符点，服务 Viktor、Aurelion Sol 等法系路线。
- 毒性命中加入孢子点和绿色环形扩散，服务 Teemo 路线。
- 虚空命中加入眼核、裂纹和紫绿碎片，服务 Mordekaiser/虚空怪物反馈。
- 爆炸命中加入金色优先环和放射碎片，服务 Jinx 火箭等高优先级技能。

## 运行约束

- `MAX_HIT_SPARKS` 控制同屏上限，避免高攻速时无限堆节点。
- 命中火花复用 VFX decal 图集，不额外引入大贴图。
- 主循环仍保留 `impact_vfx_timer` 节流，火花和冲击脉冲同步触发。
- 3D 节点使用独立 group `survivor_hit_sparks`，清场和测试都能直接追踪。

## 验证

- `SURVIVOR_HIT_SPARK_VISUAL_MATRIX_OK cases=4 meshes=68`
- `SURVIVOR_SMOKE_OK enemies=88 projectiles=60 pickups=45`
- `SURVIVOR_VISUAL_BUDGET_OK enemies=62 meshes=6845 nodes=8601 projectiles=210 pickups=167 zones=31`

## 后续方向

- 给每名英雄的专属技能增加独立命中火花纹样，而不是只按物理/魔法/毒/虚空分类。
- 为 Boss 弹幕加入更醒目的预警落点，让红紫弹幕和 XP 宝石彻底分层。
- 把高优先级命中火花接入更完整的音效和屏幕边缘反馈，但保持相机稳定不抖动。
