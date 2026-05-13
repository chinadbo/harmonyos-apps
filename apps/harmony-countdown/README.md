# HarmonyCountdown

HarmonyCountdown 是一个基于 HarmonyOS API 12 的倒计时/纪念日管理应用，包含本地事件存储、系统级提醒、桌面卡片、月历视图和分享卡片功能。

## 功能特性

- 倒计时事件 CRUD：基于 RDB 数据库 `countdown.db` 与 `countdown_events` 表
- 系统提醒：使用 `reminderAgentManager` 创建 `REMINDER_TYPE_CALENDAR` 提醒
- 桌面卡片：支持 2×2 与 4×4 两种尺寸，使用 `@LocalStorageProp` 绑定数据
- 日历月视图：展示当月事件分布并按日期查看事件
- 分享卡片：使用 `OffscreenCanvas` 绘制图像并通过系统分享面板发送

## 工程结构

```text
AppScope/
  app.json5
entry/
  src/main/module.json5
  src/main/ets/entryability/EntryAbility.ets
  src/main/ets/pages/
    MainPage.ets
    CalendarPage.ets
    EditPage.ets
    DetailPage.ets
    SettingPage.ets
  src/main/ets/model/CountdownEvent.ets
  src/main/ets/service/
    DatabaseService.ets
    ReminderService.ets
    WidgetUpdateService.ets
  src/main/ets/viewmodel/
    MainViewModel.ets
    EditViewModel.ets
  src/main/ets/utils/
    DateUtils.ets
    ShareUtils.ets
    IconConstants.ets
widget/
  src/main/module.json5
  src/main/ets/widgets/
    WidgetAbility.ets
    Widget2x2Card.ets
    Widget4x4Card.ets
  src/main/resources/base/profile/form_config.json
build-profile.json5
oh-package.json5
privacy_statement.json
```

## 架构说明

- `pages/`：页面与交互入口
- `viewmodel/`：页面状态装配与业务编排
- `service/`：数据库、提醒、桌面卡片刷新等系统能力封装
- `utils/`：日期计算、分享图绘制、图标映射
- `widget/`：桌面卡片扩展模块与 FormExtensionAbility

## 构建要求

- Bundle ID: `com.chinadbo.harmonycountdown`
- API: 12
- Ability: `EntryAbility`
- 权限：`ohos.permission.PUBLISH_AGENT_REMINDER`

## 构建方式

1. 使用 DevEco Studio 打开工程目录。
2. 确认 SDK 版本为 HarmonyOS API 12。
3. 选择 `default` product 构建并运行 `entry` 模块。
4. 安装后可在桌面添加 2×2 或 4×4 卡片。

## 注意事项

- `getRdbStore()` 只传 `context + config`
- `publishReminder()` 不传 `context`
- 所有页面均带 `@Entry`
- Widget 页面数据使用 `@LocalStorageProp`
