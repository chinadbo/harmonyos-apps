# HarmonyFocus

HarmonyFocus 是一个基于 HarmonyOS ArkTS V1 装饰器体系实现的番茄钟 App，包含专注计时、任务管理、统计报表、设置与 Widget。

## 功能概览

- 番茄钟模式：专注 / 短休息 / 长休息
- `TimerService` 使用 `AppStorage + setInterval` 管理前台计时状态
- 任务管理：创建、选择、完成、删除任务
- 本地数据库：`tasks`、`pomodoro_records`、`settings` 三张 RDB 表
- 白噪音：通过 `AVPlayer` 播放 `rawfile/sounds` 下的音频文件
- 通知提醒：计时结束时发送本地通知
- 统计页：热力图与柱状图展示专注情况
- Widget：展示当前状态、模式和今日番茄数

## 目录结构

```text
AppScope/
entry/src/main/ets/
  common/
  components/
  entryability/
  model/
  pages/
  services/
  widget/
  widgetability/
entry/src/main/resources/
privacy_statement.json
build-profile.json5
oh-package.json5
```

## 关键实现说明

### 1. 计时逻辑

- `entry/src/main/ets/services/TimerService.ets`
- 通过 `AppStorage` 持久保存：
  - `timerStatus`
  - `remainingSeconds`
  - `currentTaskId`
  - `todayPomodoros`
  - `currentMode`
  - `totalSeconds`
- 提供 `start()`、`pause()`、`resume()`、`stop()`、`skip()`
- 按用户要求未使用 `backgroundTaskManager`，后台限制通过通知提醒补偿

### 2. 数据存储

- `entry/src/main/ets/services/DatabaseService.ets`
- 使用 `@ohos.data.relationalStore`
- 自动初始化三张表：
  - `tasks`
  - `pomodoro_records`
  - `settings`
- 包含任务 CRUD、记录保存、设置保存、按日期聚合统计

### 3. 白噪音资源

请自行把音频文件放到：

```text
entry/src/main/resources/rawfile/sounds/
```

推荐命名：

- `rain.mp3`
- `forest.mp3`
- `cafe.mp3`
- `waves.mp3`

### 4. Widget

Widget 通过 `FormExtensionAbility` 提供，页面位于：

- `entry/src/main/ets/widget/pages/WidgetCard.ets`
- `entry/src/main/ets/widgetability/FormAbility.ets`

## 构建方式

1. 使用 DevEco Studio 打开项目目录 `HarmonyFocus`
2. 检查并补齐签名文件到 `signature/` 目录
3. 如需白噪音，放入 `rawfile/sounds/` 目录
4. 连接 HarmonyOS 设备或模拟器
5. 执行构建并运行

## 运行前注意

- 如果系统版本对通知权限要求更严格，请在设备端允许通知权限
- 当前实现重点是完整代码结构与可维护的功能骨架
- 若要增强后台计时可靠性，可在后续版本接入 `backgroundTaskManager`
