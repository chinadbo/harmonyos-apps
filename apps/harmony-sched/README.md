# HarmonySched

HarmonySched 是一个 HarmonyOS NEXT (API 16+) ArkTS 课程表应用，用于管理多课表、课程信息、周视图展示和课程提醒。

## 功能

- 多课表管理与切换
- 本地 RDB 持久化存储课表与课程
- 周视图展示课程，使用 Grid + 绝对定位叠加课程块
- 课程列表与课程编辑
- AppStorage 保存当前课表 id、当前周次、当前编辑课程 id
- 课程提醒发布，权限仅申请 `ohos.permission.PUBLISH_AGENT_REMINDER`
- 12 种预设课程颜色

## 架构

```text
entry/src/main/ets/
├── data/
│   ├── CourseDataSource.ets
│   ├── CourseModel.ets
│   ├── ScheduleModel.ets
│   └── TimetableDatabase.ets
├── services/
│   ├── AppStateService.ets
│   ├── CourseService.ets
│   ├── ReminderService.ets
│   └── ScheduleService.ets
├── components/
│   ├── ColorPicker.ets
│   ├── CourseBlockCard.ets
│   ├── EmptyState.ets
│   └── WeekStrip.ets
├── pages/
│   ├── CourseEditPage.ets
│   ├── CourseListPage.ets
│   ├── Index.ets
│   ├── ScheduleManagePage.ets
│   ├── SettingsPage.ets
│   └── WeekSchedulePage.ets
└── entryability/
    └── EntryAbility.ets
```

## 约束落实

- 仅使用 V1 装饰器
- 仅使用 `@ohos.*` import 风格
- `relationalStore`、`notificationManager`、`reminderAgentManager` 使用指定导入方式
- 周视图使用 Grid + 绝对定位叠加课程块，不使用纯 Canvas
- 手写 `BasicDataSource` / `IDataSource`
- 全局状态使用 `AppStorage`
- 仅申请 `ohos.permission.PUBLISH_AGENT_REMINDER`

## 构建

1. 在 DevEco Studio 中打开本目录。
2. 安装 HarmonyOS NEXT API 16+ SDK。
3. 同步 `oh-package.json5` 依赖。
4. 构建并运行 `entry` 模块。

## 说明

- 当前提醒示例以相对当前时间的分钟数发布，用于项目结构完整演示。
- 如果你希望，我下一步可以继续把它细化为“按开学日期 + 周次 + 星期 + 节次”精确推导上课提醒时间的版本。
