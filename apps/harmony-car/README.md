# HarmonyCar

HarmonyCar 是一个面向 HarmonyOS NEXT 的车辆保养管理应用，支持多车管理、保养记录、到期提醒、统计图表和桌面卡片。

## 功能
- 车辆档案管理
- 保养记录管理
- 到期提醒（reminderAgentManager）
- 费用统计图表（Canvas）
- Widget 卡片（2×2 / 2×4）

## 架构
- ArkTS + V1 装饰器体系
- NavPathStack + Navigation 路由
- relationalStore 本地数据库
- 分层服务：DatabaseService / CarService / MaintenanceService / ReminderService
- Canvas 图表组件：BarChart / PieChart / LineChart
- CarFormExtensionAbility 承载卡片

## 构建
1. 使用 DevEco Studio 打开项目根目录。
2. 同步 HarmonyOS SDK 与签名配置。
3. 构建并运行 `entry` 模块。
4. 如需正式发布，请先替换 `privacy_statement.json` 中的真实隐私政策地址。
