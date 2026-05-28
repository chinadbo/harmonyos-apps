# HarmonySleep

> 好的睡眠，从记录开始

HarmonySleep 是一款专为 HarmonyOS NEXT 设计的睡眠记录与健康管理 App，帮助用户追踪睡眠规律、分析睡眠质量、养成良好作息习惯。

## 功能特性

- 🌙 **一键记录** — 入睡/起床打卡，自动计算睡眠时长
- ⭐ **质量评分** — 起床后 1-5 星评分 + 文字备注
- 📊 **数据可视化** — Canvas 折线图/柱状图，周/月趋势分析
- ⏰ **智能提醒** — 基于 reminderAgentManager，进程被杀后仍有效的每日睡前/起床提醒
- 🎯 **目标管理** — 设置每日目标睡眠时长，统计达标率
- 🪟 **桌面 Widget** — 2×2 卡片展示昨晚睡眠时长、质量和本周均值

## 技术栈

| 技术点 | 说明 |
|--------|------|
| 装饰器体系 | V1（@Component + @State/@Prop/@Link/@StorageProp） |
| 本地数据库 | RelationalStore（@ohos.data.relationalStore） |
| 后台提醒 | reminderAgentManager ALARM 类型，每天重复 |
| 数据持久化 | dataPreferences（睡眠状态 + 用户设置） |
| Canvas 图表 | CanvasRenderingContext2D，onReady 内绘制 |
| 桌面卡片 | FormExtensionAbility + LocalStorage 数据绑定 |
| 列表渲染 | LazyForEach + 自实现 IDataSource |
| Import 风格 | @ohos.* 统一风格 |

## 项目结构

```
HarmonySleep/
├── AppScope/                          # 应用全局资源
├── entry/src/main/ets/
│   ├── entryability/EntryAbility.ets  # 主 Ability，初始化 DB
│   ├── entryformability/              # Widget FormExtensionAbility
│   ├── model/                         # SleepRecord + SleepDataSource
│   ├── service/                       # DatabaseService + ReminderService
│   ├── components/                    # UI 组件（卡片/图表/评分）
│   ├── pages/                         # 4 个页面（今日/记录/统计/设置）
│   └── widget/                        # Widget 卡片 UI
└── entry/src/main/resources/
    └── base/profile/
        ├── main_pages.json            # 页面路由
        └── form_config.json           # Widget 配置
```

## 权限说明

| 权限 | 用途 |
|------|------|
| `ohos.permission.PUBLISH_AGENT_REMINDER` | 设置每日睡前/起床提醒 |

## 构建方式

1. 使用 DevEco Studio 5.0+ 打开项目根目录
2. 确保目标设备/模拟器运行 HarmonyOS API 12+
3. 点击 Build → Build Hap(s)/APP(s) 编译
4. 通过 hdc 或 DevEco Studio 安装到设备

## 开发规范

- 统一使用 V1 装饰器体系（禁止混用 @ComponentV2）
- Canvas 绘制代码在 `onReady` 回调内执行
- 所有异步操作用 `try/catch` 包裹
- 数据库 ResultSet 操作后必须调用 `rs.close()`

## 版本历史

- v1.0.0 (2026-05-29) — 初始版本，包含核心睡眠记录、提醒、统计功能
