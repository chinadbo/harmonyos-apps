# HarmonyFridge

HarmonyFridge 是一个基于 HarmonyOS ArkTS V1 装饰器体系实现的冰箱食材管理助手。

## 功能
- 食材管理：新增、编辑、删除、分类筛选
- 有效期预警：过期、3 天内、7 天内分级提示
- 购物清单：从食材一键加入并勾选管理
- 统计图表：Canvas 柱状图展示分类数量
- Widget：2×2 桌面卡片显示即将过期数量

## 目录
- `AppScope/`：应用级配置与资源
- `entry/`：主模块代码、页面、数据库与 Widget

## 说明
- 使用 `@ohos.*` 导入风格
- 使用 `Navigation + NavPathStack` 路由
- 通知权限通过运行时请求，不在 `module.json5` 中声明
- RDB 使用 `getRdbStore(context, config)` 两参数形式
