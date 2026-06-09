# HarmonyPill

HarmonyPill 是一个基于 HarmonyOS NEXT ArkTS 的用药提醒应用，用于管理药品、配置服药计划、接收系统提醒并记录服药历史。

## 功能
- 今日待服药列表与进度环
- 药品管理与编辑
- 服药计划配置与系统提醒创建
- 日历视图查看服药记录与遗漏
- 本周依从率、柱状图、连续服药天数统计

## 架构
- `entry/src/main/ets/pages`：页面层
- `entry/src/main/ets/components`：可复用组件
- `entry/src/main/ets/services`：数据库、提醒、统计服务
- `entry/src/main/ets/models`：数据模型

## 构建
1. 使用 DevEco Studio 打开项目目录。
2. 确认 HarmonyOS SDK 已安装。
3. 同步依赖后构建 `entry` 模块。
4. 运行到 HarmonyOS NEXT 设备或模拟器。

## 关键约束
- 仅使用 ArkTS V1 装饰器体系
- 所有 import 使用 `@ohos.*`
- RDB 使用 `@ohos.data.relationalStore`
- 提醒使用 `REMINDER_TYPE_CALENDAR + dateTime`
- 权限仅声明 `ohos.permission.PUBLISH_AGENT_REMINDER`
