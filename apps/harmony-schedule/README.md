# HarmonySchedule

HarmonySchedule 是一个基于 HarmonyOS ArkUI（V1 装饰器体系）构建的日历与智能日程管理应用，提供月视图、周视图、日视图、标签管理、提醒通知和 JSON 数据导入导出能力。

## 功能特性

- 月视图：展示当月日历和有日程的日期标记
- 日视图：06:00-24:00 时间线，支持长按空白时段快速创建
- 周视图：展示一周 7 天日程概览
- 日程详情：支持标题、描述、时间、全天、地点、标签、颜色、重复与多提醒
- 标签管理：内置工作/学习/生活/健康/其他，支持自定义标签增删改
- 设置：默认提醒时间、深色模式跟随系统、JSON 导入导出、关于信息
- 数据持久化：基于 `@ohos.data.relationalStore`
- 通知提醒：基于 `@ohos.notification`

## 项目结构

```text
harmony-schedule/
├── AppScope/
│   ├── app.json5
│   └── resources/
├── entry/
│   ├── src/main/
│   │   ├── module.json5
│   │   ├── privacy_statement.json
│   │   ├── ets/
│   │   │   ├── entryability/
│   │   │   ├── pages/
│   │   │   ├── models/
│   │   │   ├── data/
│   │   │   └── utils/
│   │   └── resources/
│   │       └── base/
│   ├── build-profile.json5
│   └── oh-package.json5
├── build-profile.json5
└── README.md
```

## 架构说明

### 页面层

- `HomePage.ets`：月历首页和底部导航
- `DayViewPage.ets`：单日时间线
- `WeekViewPage.ets`：周概览
- `EventDetailPage.ets`：日程新建/编辑
- `TagManagePage.ets`：标签管理
- `SettingsPage.ets`：应用设置

### 数据层

- `StorageManager.ets`：RDB 初始化、表创建、标签种子数据、事件/标签 CRUD、JSON 导入导出
- `NotificationManager.ets`：日程提醒创建与取消

### 模型与工具

- `EventModel.ets`：日程模型
- `TagModel.ets`：标签模型
- `Constants.ets`：主题、标签、提醒、重复等常量
- `DateUtils.ets`：月/周/日范围计算与格式化工具

## 数据库表结构

### events

- `id`
- `title`
- `description`
- `start_time`
- `end_time`
- `is_all_day`
- `location`
- `tag_id`
- `reminder_times`
- `repeat_type`
- `repeat_end`
- `color`
- `created_at`
- `updated_at`

### tags

- `id`
- `name`
- `color`
- `sort_order`

## 构建说明

1. 使用 DevEco Studio 打开项目根目录。
2. 确认 HarmonyOS SDK 与签名文件配置可用。
3. 同步 `oh-package.json5` 后执行构建。
4. 运行 `entry` 模块到 HarmonyOS 设备或模拟器。

## 说明

- 项目统一使用 `@ohos.*` import 风格。
- 项目统一使用 ArkUI V1 装饰器：`@Component`、`@State`、`@Prop`、`@Link`、`@StorageProp`、`@StorageLink`。
- 设置页当前以页面文本框方式展示导入导出 JSON 内容，便于在不同设备和权限条件下完成手动备份恢复。
- 通知和数据库 API 在不同 HarmonyOS SDK 版本中可能存在轻微差异，若本地 SDK 报类型差异，请以当前 SDK 文档调整对应 manager 内部调用签名。
