# HarmonyGoal

HarmonyGoal 是一个基于 HarmonyOS ArkUI 的个人目标管理 / OKR 追踪应用，支持目标管理、关键结果追踪、每日回顾、趋势统计与每日提醒。

## 功能说明

- 目标（Objective）CRUD：标题、描述、周期、颜色、截止日期、状态
- 关键结果（Key Result）CRUD：支持数值型与布尔型 KR
- 目标进度自动计算：按 KR 权重进行加权平均
- 每日回顾（Check-in）：记录当天复盘文字与进度快照
- 可视化：首页环形进度卡片、统计页折线图
- 每日提醒：使用 reminderAgentManager 发布每日提醒

## 技术实现

- UI：ArkUI V1 装饰器体系（`@Component` + `@State/@Prop/@StorageProp`）
- 路由：`@ohos.router`
- 数据存储：`@ohos.data.relationalStore`
- 提醒能力：`@ohos.reminderAgentManager`
- 全局状态：`AppStorage` + `GoalViewModel`

## 工程结构

```text
AppScope/
  app.json5
  resources/base/element/string.json
entry/
  src/main/module.json5
  src/main/ets/
    entryability/EntryAbility.ets
    model/
      GoalModel.ets
      DatabaseHelper.ets
    viewmodel/
      GoalViewModel.ets
    utils/
      DateUtils.ets
      NotificationHelper.ets
    components/
      RingProgress.ets
      GoalCard.ets
      KRItem.ets
      LineChart.ets
      EmptyState.ets
    pages/
      HomePage.ets
      GoalDetailPage.ets
      CreateGoalPage.ets
      CreateKRPage.ets
      CheckInPage.ets
      StatisticsPage.ets
      SettingsPage.ets
  src/main/resources/
    base/element/
    base/profile/main_pages.json
privacy_statement.json
build-profile.json5
oh-package.json5
hvigorfile.ts
```

## 数据库设计

### goals
- `id`
- `title`
- `description`
- `period`
- `color`
- `status`
- `deadline`
- `created_at`
- `updated_at`

### key_results
- `id`
- `goal_id`
- `title`
- `kr_type`
- `target_value`
- `current_value`
- `unit`
- `weight`
- `created_at`

### checkins
- `id`
- `goal_id`
- `note`
- `progress`
- `date`
- `created_at`

## 进度计算

```text
progress = sum(min(kr.currentValue/kr.targetValue, 1) * kr.weight) / sum(kr.weight) * 100
boolean KR: currentValue = 1 => 100%, currentValue = 0 => 0%
```

## 构建与运行

1. 使用 DevEco Studio 打开工程目录。
2. 确认本地 SDK 与 Hvigor 环境可用。
3. 同步 `oh-package.json5` 依赖。
4. 选择 `entry` 模块并运行到 HarmonyOS 设备或模拟器。

## 使用流程

1. 在首页创建一个目标。
2. 进入目标详情，为目标补充一个或多个 KR。
3. 每天更新 KR 进度或记录回顾。
4. 在统计页查看趋势，在设置页开启每日提醒。
