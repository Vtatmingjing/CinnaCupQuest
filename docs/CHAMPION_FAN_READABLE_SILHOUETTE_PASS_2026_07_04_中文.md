# 英雄粉丝向低眩光剪影层

## 目标

继续靠近参考图的“第一眼能读懂角色身份”的方向，但不再用更亮的特效堆光。该批次给 8 个英雄增加一层低透明、零发光的专属剪影件，用来强化远距离辨识度。

## 本批改动

- 新增 `ChampionFanReadableSilhouetteRig`
  - `combat_visual_channel = champion_readability`
  - `material_grade = low_glare_fan_readable_silhouette`
  - `silhouette_signature` 记录英雄身份关键词。
- 每个英雄都有独立细节节点：
  - 金克丝：`FanReadableJinxTwinRockets`
  - 赛娜：`FanReadableSennaRelicCannon`
  - 莎弥拉：`FanReadableSamiraBladePistolCross`
  - 维克托：`FanReadableViktorHexcoreSpine`
  - 霞：`FanReadableXayahFeatherFan`
  - 莫德凯撒：`FanReadableMordeIronMace`
  - 提莫：`FanReadableTeemoScoutMushroom`
  - 奥瑞利安·索尔：`FanReadableAsolCelestialOrbit`
- 同步支持程序模型和外部授权模型包装层。
- 玩家同步时增加轻微动态，但不使用屏幕抖动、倾斜视角或高亮 bloom。

## 视觉原则

- 低眩光：新增材质 emission 固定为 0。
- 不抢弹幕层级：剪影件贴近角色脚下/背后，主要作为身份底纹。
- 粉丝向辨识：用火箭/圣枪/刀枪交叉/海克斯核心/羽毛/铁锤/蘑菇/星轨这些轮廓元素表达角色。
- 性能可控：只增加少量 Box、Sphere、Cylinder 低面数几何，不增加实时灯光。

## 测试覆盖

- `tests/survivor_champion_visual_matrix.gd`
  - 检查 `ChampionFanReadableSilhouetteRig` 存在。
  - 检查 8 个英雄各自的专属细节节点。
  - 检查材质预算：emission 不超过 `0.02`，透明 alpha 不超过 `0.36`。
  - 检查最小 mesh 数，避免只有空节点。

## 验证命令

```powershell
& 'D:\Godot\Godot_v4.3-stable_win64_console.exe' --disable-crash-handler --headless --log-file tmp_headless_logs\survivor_champion_visual_matrix.log --path . --script res://tests/survivor_champion_visual_matrix.gd
```

期望输出：

```text
SURVIVOR_CHAMPION_VISUAL_MATRIX_OK
```
