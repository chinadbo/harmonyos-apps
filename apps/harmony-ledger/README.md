# HarmonyLedger

HarmonyLedger 是一个基于 HarmonyOS ArkTS V1 装饰器体系实现的本地记账与预算管理应用。

## 功能
- 首页：本月收支概览、最近账单、FAB 快速记账
- 记账：新增、编辑、删除账单
- 统计：30 天折线图、分类支出占比饼图
- 预算：分类月预算、进度展示、超支提醒
- 分类管理：内置分类 + 自定义分类
- 设置：货币单位、CSV 导出、关于
- 桌面卡片：显示本月结余、今日支出、快速记账入口

## 实现约束
- 统一使用 ArkUI V1 装饰器：`@Component`、`@State`、`@Prop`、`@Link`
- 统一使用 `@ohos.*` import 风格
- `TransactionDataSource` 手动实现 `IDataSource`
- Canvas 图表只在 `onReady` 中绘制
- `postCardAction` 的 `params` 使用原生对象
- `LazyForEach` 的 key 使用 `transaction.id`
- RDB 操作全部通过 `async/await` 异步执行

## 工程结构
- `AppScope/`：应用级配置与资源
- `entry/`：主模块、页面、组件、数据层、卡片能力

## 说明
本项目为本地存储应用，首次启动会自动初始化数据库并写入默认分类和默认货币配置。
