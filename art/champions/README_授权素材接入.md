# 授权角色精灵接入说明

把你已经获得授权的角色素材放在本目录。游戏会按下面优先级自动加载：

1. 动画图集：`<角色id>_sheet.png` + `<角色id>_sheet.json`
2. 静态单图：`<角色id>.png`，可选 `<角色id>.json`
3. 如果找不到素材，自动回退到内置 2.5D 绘制

当前角色 id：

- `jinx`
- `senna`
- `samira`
- `viktor`
- `xayah`
- `mordekaiser`
- `teemo`
- `aurelion_sol`

## 动画图集格式

例如金克丝：

- `jinx_sheet.png`
- `jinx_sheet.json`

JSON 示例：

```json
{
  "frame_width": 96,
  "frame_height": 96,
  "fps": 8,
  "target_height": 78,
  "offset": [0, -12],
  "flip_with_facing": true,
  "animations": {
    "idle": [0, 1, 2, 3],
    "walk": [4, 5, 6, 7],
    "attack": [8, 9, 10, 11]
  }
}
```

图集从左到右、从上到下编号。第一格是 `0`，第二格是 `1`。

`attack` 是可选的；没有 `attack` 时会用 `idle/walk`。

## 静态单图格式

例如提莫：

- `teemo.png`
- 可选 `teemo.json`

可选 JSON：

```json
{
  "target_height": 74,
  "offset": [0, -12],
  "flip_with_facing": true
}
```

## 注意

请只放你有明确授权使用的图片或图集。不要把未授权的官方资源直接提交到仓库。
