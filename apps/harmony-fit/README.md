# HarmonyFit

HarmonyFit 是一个基于 HarmonyOS ArkTS 的健康运动记录 App，提供实时计步、运动记录管理、数据可视化和桌面 Widget 能力。

## 功能介绍

- 实时计步仪：基于 `@ohos.sensor` 订阅 PEDOMETER，失败时回退 STEP_DETECTOR
- 运动记录管理：基于 `@ohos.data.relationalStore` 持久化运动记录
- 数据可视化：首页圆环进度图 + 统计页最近 7 天柱状图
- 桌面 Widget：2x2 卡片显示今日步数、目标步数和进度百分比
- 设置管理：支持保存步数目标和卡路里目标

## 技术架构

- UI：ArkUI V1 `@Component`
- 数据模型：`model/WorkoutType.ets`、`model/WorkoutRecord.ets`
- 服务层：
  - `service/SensorService.ets`
  - `service/DatabaseService.ets`
  - `service/PreferencesService.ets`
- ViewModel：
  - `viewmodel/HomeViewModel.ets`
  - `viewmodel/WorkoutDataSource.ets`
- 页面：
  - `pages/HomePage.ets`
  - `pages/WorkoutListPage.ets`
  - `pages/StatsPage.ets`
  - `pages/SettingsPage.ets`
- Widget：`entryformability/EntryFormAbility.ets` + `widget/pages/WidgetCard.ets`

## 构建方式

1. 使用 DevEco Studio 打开项目根目录 `HarmonyFit`
2. 配置签名信息
3. 选择 HarmonyOS 设备或模拟器
4. 执行 Build 或 Run

## 截图说明

- 首页：待添加
- 记录页：待添加
- 统计页：待添加
- Widget：待添加

## 权限说明

应用仅申请以下权限：

- `ohos.permission.ACTIVITY_MOTION`：用于读取计步传感器数据，统计今日步数

## 隐私说明

- 步数与运动记录仅保存在本地
- 不上传到服务器
- 不与第三方共享
