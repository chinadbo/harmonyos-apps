# HarmonySavings

HarmonySavings 是一个基于 HarmonyOS ArkTS 的个人储蓄目标追踪工具，支持创建储蓄目标、记录存款、查看进度与完成提醒。

## 功能

- 目标列表首页，采用 Grid 卡片布局展示储蓄目标
- 创建与编辑储蓄目标
- 目标详情页展示环形进度、金额摘要与存款时间线
- 快速新增存款记录
- 目标完成后显示庆祝提示，并可发送本地通知
- 设置页支持通知开关与权限申请
- 金额统一按“分”存储，展示时格式化为“元”

## 项目结构

- `AppScope/`：应用级配置与资源
- `entry/src/main/ets/pages/`：页面
- `entry/src/main/ets/components/`：可复用 UI 组件
- `entry/src/main/ets/model/`：数据模型
- `entry/src/main/ets/database/DatabaseHelper.ets`：RDB 数据库封装
- `entry/src/main/ets/viewmodel/`：业务逻辑层
- `entry/src/main/ets/utils/`：日期、通知等工具

## 数据设计

### goals

- `id`：主键
- `name`：目标名称
- `target_amount`：目标金额，单位分
- `current_amount`：当前累计金额，单位分
- `deadline`：截止日期，格式 `YYYY-MM-DD`
- `note`：备注
- `color`：主题色
- `created_at` / `updated_at`
- `completed_at`：完成时间，可为空

### deposits

- `id`：主键
- `goal_id`：所属目标
- `amount`：存款金额，单位分
- `deposit_date`：存款日期，格式 `YYYY-MM-DD`
- `note`：备注
- `created_at`

## 架构说明

- `EntryAbility` 在应用启动时初始化数据库
- `DatabaseHelper` 负责建表、CRUD、JOIN 查询与金额同步
- `GoalViewModel` 和 `DepositViewModel` 负责页面调用的业务逻辑
- 页面通过 `@ohos.router` 进行跳转
- `RingProgress` 使用 Canvas 手绘环形进度条，顶部起点为 `-Math.PI / 2`

## 构建方式

1. 使用 DevEco Studio 打开本项目目录
2. 确保 SDK 版本与 `build-profile.json5` 中配置兼容
3. 同步工程后执行构建
4. 运行 `entry` 模块到 HarmonyOS 设备或模拟器

## 使用说明

- 创建目标时输入金额单位为“分”
- 页面展示时会自动格式化为“元”
- 日期统一使用 `YYYY-MM-DD` 字符串格式
- 若开启通知并授予权限，目标完成时会发送本地提醒
