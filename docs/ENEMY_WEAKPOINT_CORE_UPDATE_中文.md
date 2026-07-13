# 虚空敌人弱点核心更新

本轮继续强化怪物辨识度，给关键虚空怪、精英和 Boss 增加一层轻量 3D 弱点核心，让玩家在混战里更容易看出“这个怪是什么、该不该优先处理”。

## 改动

- 新增 `EnemyWeakpointCore`：
  - 喷吐怪：绿色酸液三角弱点。
  - 钻地怪 / Rek'Sai：橙色纵向裂缝弱点。
  - 精英甲壳怪 / Cho'Gath：紫色破甲裂纹。
  - 虚空眼 / Vel'Koz：发光眼核。
  - 裂隙水晶：六角晶核。
  - Bel'Veth：翼冠核心。
- 精英和 Boss 必带弱点核心，普通 lite 怪不挂这层；精英弱点使用统一轻量核心，具体词缀差异继续交给 `EliteTraitMarker`，避免高压场景节点数贴边。
- `_sync_enemies()` 会让弱点核心轻微呼吸和浮动，但不新增实时灯光。

## 验证

- `tests/survivor_enemy_visual_matrix.gd` 检查 `EnemyWeakpointCore`、`EnemyWeakpointLens`、`EnemyWeakpointMark`。
- `tests/survivor_headless_smoke.gd` 新增实战断言。
- 本批通过完整 16 项 headless 回归：
  - `SURVIVOR_ENEMY_VISUAL_MATRIX_OK enemies=7 bosses=4 boss_emblems=4 meshes=1181`
  - `SURVIVOR_SMOKE_OK enemies=89 projectiles=58 pickups=44`
  - `SURVIVOR_VISUAL_BUDGET_OK enemies=63 meshes=7044 nodes=8882 projectiles=210 pickups=166 zones=31`
