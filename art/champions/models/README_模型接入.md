# 3D 英雄模型接入

把本地可用的英雄模型放到这个目录，游戏会优先加载同名文件；没有对应模型时，会自动使用程序化风格化模型。

支持命名：

- `jinx.glb` / `jinx.gltf` / `jinx.tscn`
- `senna.glb` / `senna.gltf` / `senna.tscn`
- `samira.glb` / `samira.gltf` / `samira.tscn`
- `viktor.glb` / `viktor.gltf` / `viktor.tscn`
- `xayah.glb` / `xayah.gltf` / `xayah.tscn`
- `mordekaiser.glb` / `mordekaiser.gltf` / `mordekaiser.tscn`
- `teemo.glb` / `teemo.gltf` / `teemo.tscn`
- `aurelion_sol.glb` / `aurelion_sol.gltf` / `aurelion_sol.tscn`

推荐使用 `.glb`。放入文件后，用 Godot 打开项目让它完成导入，再运行游戏。

## 调整大小和朝向

如果模型太大、太小、朝向不对，改同目录下的 `model_config.json`：

```json
"jinx": {"scale": 0.72, "yaw": 180, "pitch": 0, "roll": 0, "x": 0, "y": 0, "z": 0}
```

- `scale`：模型整体大小。
- `yaw`：左右旋转，常用来修正面朝方向。
- `pitch` / `roll`：俯仰和侧倾，一般保持 0。
- `x` / `y` / `z`：模型在角色脚底圆环上的偏移。

## 关于官方模型

项目已经支持加载你本地放入的模型文件，但请只放你有权使用的模型资源。个人试玩通常风险更低，但不代表自动拥有官方模型的复制、转换或分发权。
