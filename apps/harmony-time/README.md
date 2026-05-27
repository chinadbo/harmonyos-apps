# HarmonyTime - 时间追踪应用

一款基于 HarmonyOS NEXT (API 16) 的时间追踪应用，帮助你高效管理每日工作时间。

## 功能介绍

### 计时器
- 选择项目一键开始计时
- 支持暂停/恢复/停止
- 后台持续计时（KEEP_BACKGROUND_RUNNING）
- 通知栏实时显示计时状态

### 统计分析
- 饼图展示项目时间分布（Canvas 绘制）
- 柱状图展示每日时间趋势（Canvas 绘制）
- 支持今日/本周/本月维度切换
- 项目时长排行列表

### 历史记录
- LazyForEach 高性能列表
- 按日期分组展示
- 左滑快速删除（swipeAction）
- 支持手动添加历史记录

### 项目管理
- 创建/编辑/删除项目
- 自定义 12 种颜色和 12 种图标
- 项目总计时间统计

### 桌面卡片
- 2x2 桌面小组件
- 实时显示当前计时状态
- 点击快速跳转应用

## 技术架构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets              # UIAbility 入口
├── pages/
│   ├── Index.ets                      # 首页 Tabs 导航
│   ├── TimerPage.ets                  # 计时 Tab
│   ├── HistoryPage.ets                # 历史 Tab（LazyForEach）
│   ├── StatsPage.ets                  # 统计 Tab（Canvas 图表）
│   ├── ProjectsPage.ets              # 项目管理（CustomDialog）
│   └── AddEntryPage.ets              # 手动添加记录
├── components/
│   ├── TimerCard.ets                  # 计时器卡片
│   ├── ProjectItem.ets                # 项目列表项
│   ├── EntryItem.ets                  # 记录列表项
│   ├── PieChart.ets                   # 饼图（Canvas）
│   ├── BarChart.ets                   # 柱状图（Canvas）
│   └── ColorPicker.ets               # 颜色选择器（Grid）
├── service/
│   ├── TimerService.ets               # 计时服务单例
│   └── NotificationService.ets        # 通知服务单例
├── model/                             # 数据模型
├── database/
│   └── DatabaseHelper.ets             # Preferences 数据持久化
└── widget/
    ├── pages/WidgetCard.ets           # 卡片 UI
    └── formextension/
        └── TimerFormExtensionAbility.ets  # 卡片 Extension
```

## 全局状态（AppStorage）

| Key | Type | 说明 |
|-----|------|------|
| runningProjectId | number | 当前计时项目 ID，-1 表示无 |
| runningEntryId | number | 当前计时条目 ID，-1 表示无 |
| timerStartTime | number | 计时开始时间戳 |
| isTimerRunning | boolean | 是否正在计时 |
| elapsedSeconds | number | 已计时秒数 |

## 构建与运行

### 环境要求
- DevEco Studio 4.1+
- HarmonyOS SDK API 16
- Node.js 16+

### 构建步骤
1. 使用 DevEco Studio 打开项目根目录
2. File > Project Structure 确认 SDK 版本为 API 16
3. Build > Build Hap(s)/APP(s) > Build Hap(s)
4. 连接设备或启动模拟器
5. Run > Run 'entry'

### 权限声明
- `ohos.permission.KEEP_BACKGROUND_RUNNING` - 后台持续计时
- `ohos.permission.PUBLISH_AGENT_REMINDER` - 通知提醒

## 设计规范
- V1 装饰器体系（@Component/@State/@Prop/@Link/@StorageProp）
- @ohos.* 模块导入风格
- NavPathStack 路由管理
- Canvas 自绘图表
- 完整 IDataSource 实现（LazyForEach）
