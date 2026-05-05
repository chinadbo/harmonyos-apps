# HarmonyHabit

HarmonyHabit 是一个基于 HarmonyOS API 12 的习惯追踪与打卡应用，包含今日打卡、统计概览、习惯详情热力图、习惯创建编辑，以及 2×2 Widget。

## 功能
- 今日习惯列表与快速打卡
- 习惯新增、编辑、停用、删除
- RDB 本地持久化：habit + checkin 两张表
- reminderAgentManager 定时提醒
- 统计概览：完成率、连击、最近 7 天趋势
- 详情页原生 Canvas 热力图与历史记录
- FormExtensionAbility Widget，通过 preferences 同步今日摘要

## 工程结构
- `AppScope/`：应用级配置
- `entry/`：主应用模块，包含 Ability、页面、组件、数据库、服务
- `widget/`：桌面卡片模块，包含 FormExtensionAbility 与 Widget UI

## 架构要点
- 使用 ArkUI 装饰器 V1 体系
- 使用 `@ohos.data.relationalStore` 管理本地数据库
- 使用 `@ohos.reminderAgentManager` 发布定时提醒
- 使用 `@ohos.data.preferences` 在 App 与 Widget 之间共享今日统计
- 热力图使用原生 Canvas 绘制，不依赖第三方图表库

## 数据表
### habit
- `id`, `name`, `icon`, `colorIndex`, `targetDays`, `reminderTime`, `reminderId`, `createdAt`, `isActive`

### checkin
- `id`, `habitId`, `checkDate`, `note`, `createdAt`
- 唯一键：`(habitId, checkDate)`

## 构建
1. 使用 DevEco Studio 打开工程根目录。
2. 确认 SDK API Level 为 12。
3. 选择 `default` product 并构建运行。

## 权限
- `ohos.permission.PUBLISH_AGENT_REMINDER`

## Widget 数据桥
主应用每次新增、修改、打卡、删除后，都会刷新 preferences 中的 `today_total`、`today_done`、`today_quote`，Widget 在 `onAddForm` / `onUpdateForm` 中读取并刷新卡片。
