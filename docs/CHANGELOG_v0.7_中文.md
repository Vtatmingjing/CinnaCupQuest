# CHANGELOG v0.7：路线节点、区域 Boss 与设置版

## 核心新增

### 1. 真正路线节点界面

- 新增 `scripts/route_overlay.gd`。
- 清房后弹出全屏路线选择界面。
- 显示当前节点、3 个候选路线、出口节点和每种房间的简短说明。
- 选择路线后才恢复玩家控制，并打开右侧大门。

### 2. 酒瓶货架区域 Boss

- 新增敌人类型：`shelf_boss`。
- 中段强制进入“瓶塞升降机长”Boss 房。
- 击败后掉落两件奖励，并继续进入酒瓶货架阶段。
- `main.gd` 现在区分区域 Boss 与最终 Boss，区域 Boss 不会直接结算胜利。

### 3. 区域 Boss 招式

瓶塞升降机长拥有三种攻击：

- `shelf_cork_rain`：从玩家附近上方落下软木塞雨。
- `shelf_elevator_slam`：跳起并在玩家附近制造糖浆危险区。
- `shelf_bottle_beam`：发射双层紫色瓶光弹道。

### 4. 设置菜单

- 新增 `settings` 输入，默认按键 `S`。
- 主菜单、暂停、结算和游戏中都可进入设置。
- 可切换：
  - 音效开关
  - 镜头抖动开关
  - 难度
- 设置写入 `user://cinna_progress.cfg`。

### 5. 难度系统

新增三档难度：

- Cozy：玩家开局 +1 最大生命和 +1 护盾，敌人更软。
- Normal：标准体验。
- Spicy：敌人更硬更快，后期伤害更高，但给更多分数。

### 6. 更多事件房

新增事件：

- 青柠合唱团
- 打火机彩排
- 货架审计员
- 装饰喷泉

这些事件提供道具、金币、分数、治疗或小代价奖励。

## 调整

- 总房间数从 12 调整为 13。
- 进入酒瓶货架前会强制经过区域 Boss。
- HUD 帮助文字加入 `S settings`。
- 主菜单显示当前设置状态。
- 暂停页和结算页加入设置入口提示。
- `README_中文.md` 更新到 v0.7。

## 主要变更文件

- `scripts/main.gd`
- `scripts/enemy.gd`
- `scripts/hud.gd`
- `scripts/meta_progress.gd`
- `scripts/route_map.gd`
- `scripts/route_overlay.gd`
- `README_中文.md`
