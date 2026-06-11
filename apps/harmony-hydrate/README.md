# HarmonyHydrate（饮水追踪）

HarmonyHydrate 是一个 HarmonyOS NEXT 饮水追踪应用，用于记录每日饮水量、查看历史与统计，并在用户开启后发送日内喝水提醒。

## 功能说明

- 首页展示今日饮水进度环、快捷加水按钮、连续达标天数、最近记录
- 历史页按日期分组展示饮水记录，支持编辑与删除
- 统计页展示近 7 天柱状图、周平均饮水量、达标率
- 设置页支持调整每日目标、提醒开关、提醒时段、提醒间隔、清空数据
- 桌面卡片扩展包含 FormExtensionAbility 与 WaterWidgetCard

## 项目架构

```text
AppScope/
  app.json5
  resources/base/
    element/string.json
    media/app_icon.png
entry/src/main/
  module.json5
  resources/base/
    element/string.json
    profile/main_pages.json
  ets/
    entryability/EntryAbility.ets
    pages/
    components/
    model/
    service/
    widget/
privacy_statement.json
build-profile.json5
oh-package.json5
hvigorfile.ts
```

### 主要模块

- `entry/src/main/ets/pages/Index.ets`：应用主页与 `NavPathStack` 入口
- `entry/src/main/ets/service/DatabaseService.ets`：基于 RDB 的本地数据存储
- `entry/src/main/ets/service/WaterService.ets`：饮水记录 CRUD、日累计、连续达标
- `entry/src/main/ets/service/ReminderService.ets`：按设置批量发布日内提醒
- `entry/src/main/ets/service/StatsService.ets`：近 7 天统计聚合
- `entry/src/main/ets/components/*.ets`：首页与统计页 UI 组件
- `entry/src/main/ets/widget/*`：服务卡片相关实现

## 构建方式

1. 使用 DevEco Studio 打开当前项目目录。
2. 确保 SDK 版本与 `build-profile.json5` 中 `compatibleSdkVersion` 匹配。
3. 连接 HarmonyOS NEXT 设备或启动模拟器。
4. 执行构建并运行 `entry` 模块。

## 开发约束

- 统一使用 ArkUI V1 装饰器：`@Component`、`@State`、`@Prop`、`@Watch`
- 统一使用 `@ohos.*` 风格导入
- 页面跳转使用 `NavPathStack`，不使用 Router
- 数据库使用 `relationalStore.getRdbStore`、`executeSql`、`querySql`
- 提醒使用 `ReminderType.REMINDER_TYPE_CALENDAR` 与 `dateTime`

## 隐私说明

应用仅在本地保存饮水记录与设置，不上传到任何服务器。详细内容见 `privacy_statement.json`。
