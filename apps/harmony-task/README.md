# HarmonyTask（鸿蒙待办）

一款基于 HarmonyOS ArkUI 开发的待办任务管理应用，支持任务分类、优先级、提醒、统计等完整功能。

## 功能特性

### 核心功能
- ✅ **任务管理**：创建、编辑、删除、完成任务
- 🏷️ **分类管理**：自定义分类（名称 + 颜色），按分类筛选
- 🔴🟡🟢 **优先级**：高/中/低三级优先级，视觉标识
- 🔍 **搜索**：按标题搜索任务
- ⏰ **提醒**：基于 reminderAgentManager 的日历提醒
- 📊 **统计**：今日/本周/本月完成率、分类占比饼图、7天趋势折线图

### 页面结构
| 页面 | 功能 |
|------|------|
| Index | 首页，全部任务列表 + 分类筛选 + 搜索 |
| TodayPage | 今日到期任务，支持滑动延期 |
| TaskEditPage | 新建/编辑任务表单 |
| CategoryPage | 分类增删改，颜色选择 |
| StatsPage | 统计图表（Canvas 饼图 + 折线图） |
| SettingsPage | 设置：提醒开关、清除数据 |

### Widget
- 2×2 小尺寸卡片：显示待办数量 + 今日概览
- 2×4 大尺寸卡片：显示待办数量 + 最多3条任务

## 技术架构

```
┌─────────────────────────────────────┐
│              Pages                  │
│  Index / Today / Edit / Stats / ... │
├─────────────────────────────────────┤
│            Components               │
│  TaskCard / ProgressRing / ...      │
├─────────────────────────────────────┤
│             Services                │
│  TaskService / ReminderService /    │
│  StatsService                       │
├─────────────────────────────────────┤
│             Database                │
│  TaskDatabase (RDB Singleton)       │
│  TaskModel / CategoryModel          │
└─────────────────────────────────────┘
```

## 技术栈
- **框架**：HarmonyOS ArkUI (V1 装饰器体系)
- **语言**：ArkTS
- **数据库**：@ohos.data.relationalStore (RDB)
- **提醒**：@ohos.reminderAgentManager
- **存储**：@ohos.data.preferences
- **最低 API**：12

## 数据模型

### tasks 表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| title | TEXT | 任务标题 |
| description | TEXT | 任务描述 |
| category_id | INTEGER | 分类ID |
| priority | INTEGER | 0=低 1=中 2=高 |
| status | INTEGER | 0=待办 1=进行中 2=已完成 |
| due_date | INTEGER | 截止时间戳 |
| reminder_time | INTEGER | 提前提醒分钟数 |
| reminder_id | INTEGER | 系统提醒ID |
| created_at | INTEGER | 创建时间 |
| updated_at | INTEGER | 更新时间 |
| completed_at | INTEGER | 完成时间 |

### categories 表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| name | TEXT UNIQUE | 分类名称 |
| color | TEXT | 颜色值 |
| sort_order | INTEGER | 排序 |
| created_at | INTEGER | 创建时间 |

## 权限声明
- `ohos.permission.NOTIFICATION_CONTROLLER`：用于发布任务提醒通知

## 构建方式

1. 使用 DevEco Studio 打开项目
2. 选择目标设备（Phone/Tablet）
3. 点击 Build > Build Hap(s)/APP(s)
4. 或使用命令行：`hvigorw assembleHap`

## 项目结构
```
harmony-task/
├── AppScope/                    # 应用级配置
├── entry/src/main/
│   ├── ets/
│   │   ├── entryability/       # UIAbility 入口
│   │   ├── database/           # 数据模型 + RDB
│   │   ├── services/           # 业务服务层
│   │   ├── components/         # 通用组件
│   │   ├── pages/              # 页面
│   │   ├── formability/        # Widget 能力
│   │   └── widget/             # Widget UI
│   ├── resources/              # 资源文件
│   └── module.json5            # 模块配置
├── build-profile.json5
├── oh-package.json5
└── README.md
```
