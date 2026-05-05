# HarmonyHabit 架构设计

**API Level:** 12  
**Bundle Name:** com.chinadbo.harmonyhabit  
**App Name:** HarmonyHabit

---

## 工程结构

```
HarmonyHabit/
├── AppScope/
│   ├── app.json5
│   └── resources/base/element/string.json
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets
│   │   │   ├── pages/
│   │   │   │   ├── Index.ets              # 首页（今日打卡列表）
│   │   │   │   ├── StatisticsPage.ets     # 统计概览
│   │   │   │   ├── HabitDetailPage.ets    # 习惯详情+热力图
│   │   │   │   └── HabitEditPage.ets      # 创建/编辑习惯
│   │   │   ├── components/
│   │   │   │   ├── HabitCard.ets          # 习惯卡片组件
│   │   │   │   ├── HeatMapCanvas.ets      # 热力图 Canvas 组件
│   │   │   │   └── StreakBadge.ets        # 连续打卡徽章
│   │   │   ├── model/
│   │   │   │   ├── HabitModel.ets         # 习惯数据模型
│   │   │   │   └── CheckInModel.ets       # 打卡记录模型
│   │   │   ├── database/
│   │   │   │   ├── DatabaseHelper.ets     # RDB 初始化与迁移
│   │   │   │   ├── HabitRepository.ets    # 习惯 CRUD
│   │   │   │   └── CheckInRepository.ets  # 打卡记录 CRUD
│   │   │   ├── service/
│   │   │   │   ├── ReminderService.ets    # reminderAgentManager 封装
│   │   │   │   └── StatsService.ets       # 统计计算服务
│   │   │   └── common/
│   │   │       ├── Constants.ets          # 常量定义
│   │   │       └── DateUtils.ets          # 日期工具函数
│   │   ├── resources/
│   │   │   └── base/
│   │   │       ├── profile/main_pages.json
│   │   │       └── element/string.json
│   │   └── module.json5
│   └── build-profile.json5
├── widget/                                # FormExtensionAbility
│   └── src/main/
│       ├── ets/
│       │   ├── widget/
│       │   │   └── HabitWidget.ets        # 2×2 Widget UI
│       │   └── formability/
│       │       └── HabitFormAbility.ets   # FormExtensionAbility
│       └── resources/
│           └── base/profile/form_config.json
├── oh-package.json5
├── build-profile.json5
├── privacy_statement.json
└── README.md
```

---

## 数据模型

### HabitModel（习惯）
```typescript
interface HabitModel {
  id: number           // 自增主键
  name: string         // 习惯名称
  icon: string         // 图标 emoji
  colorIndex: number   // 颜色索引（0-7）
  targetDays: string   // 目标频率 "1111111" = 每天，位代表周一到周日
  reminderTime: string // 提醒时间 "HH:mm" 或空串
  reminderId: number   // reminderAgentManager publishReminder 返回的 id
  createdAt: number    // 时间戳
  isActive: number     // 1=激活 0=停用
}
```

### CheckInModel（打卡记录）
```typescript
interface CheckInModel {
  id: number
  habitId: number
  checkDate: string    // "YYYY-MM-DD"
  note: string         // 打卡备注（可选）
  createdAt: number
}
```

---

## RDB 设计

### 建表 SQL
```sql
-- 习惯表
CREATE TABLE IF NOT EXISTS habit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  icon TEXT DEFAULT '✅',
  colorIndex INTEGER DEFAULT 0,
  targetDays TEXT DEFAULT '1111111',
  reminderTime TEXT DEFAULT '',
  reminderId INTEGER DEFAULT -1,
  createdAt INTEGER NOT NULL,
  isActive INTEGER DEFAULT 1
);

-- 打卡记录表
CREATE TABLE IF NOT EXISTS checkin (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  habitId INTEGER NOT NULL,
  checkDate TEXT NOT NULL,
  note TEXT DEFAULT '',
  createdAt INTEGER NOT NULL,
  UNIQUE(habitId, checkDate),
  FOREIGN KEY(habitId) REFERENCES habit(id) ON DELETE CASCADE
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_checkin_date ON checkin(checkDate);
CREATE INDEX IF NOT EXISTS idx_checkin_habit ON checkin(habitId);
```

---

## API 使用规范

### RelationalStore
```typescript
import relationalStore from '@ohos.data.relationalStore';

const config: relationalStore.StoreConfig = {
  name: 'HarmonyHabit.db',
  securityLevel: relationalStore.SecurityLevel.S1
};
```

### reminderAgentManager
```typescript
import reminderAgentManager from '@ohos.reminderAgentManager';

// 创建每日重复提醒（CALENDAR 类型）
const reminder: reminderAgentManager.ReminderRequestCalendar = {
  reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
  dateTime: { year: 2026, month: 1, day: 1, hour: 8, minute: 0 },
  repeatMonths: [],
  repeatDays: [],
  actionButton: [{
    title: '打卡',
    buttonType: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CUSTOM
  }],
  wantAgent: { pkgName: 'com.chinadbo.harmonyhabit', abilityName: 'EntryAbility' },
  title: '${habitName}',
  content: '该打卡了！',
  ringDuration: 5
};
// ⚠️ 系统上限 30 个，超出时取消最早创建的提醒（evictOldest 策略）
```

### FormExtensionAbility（Widget）
```typescript
import formBindingData from '@ohos.app.form.formBindingData';
import formProvider from '@ohos.app.form.formProvider';

// ⚠️ Widget 卡片内不能直接访问 RDB，需通过 preferences 共享数据
// Widget UI 不使用 @State 接收 FormBindingData，改用 LocalStorage 或静态方式
// postCardAction params 必须是原生对象（不能 JSON.stringify）
```

### notificationManager（习惯完成通知）
```typescript
import notificationManager from '@ohos.notificationManager';
// ⚠️ 不声明 NOTIFICATION_CONTROLLER（三方应用不可用）
// 仅使用 notificationManager.publish() 基础通知
```

---

## 权限声明（最小化）

```json
"requestPermissions": [
  { "name": "ohos.permission.PUBLISH_AGENT_REMINDER" },
  { "name": "ohos.permission.NOTIFICATION_CONTROLLER" }  // ❌ 禁止！仅系统应用
]
```

**正确权限：**
```json
"requestPermissions": [
  { "name": "ohos.permission.PUBLISH_AGENT_REMINDER" }
]
```

---

## Widget 数据共享方案

由于 FormExtensionAbility 无法直接访问 RDB，使用 `@ohos.data.preferences` 作为 Widget 数据桥：
1. 用户打卡后，App 写入 preferences：`today_total`、`today_done`
2. FormExtensionAbility onUpdateForm 时读取 preferences
3. 通过 formProvider.updateForm 刷新卡片

---

## 路由注册（三处必须同步）

```
main_pages.json → pages 数组
Index.ets → Navigation 路由
页面文件 → 对应路径
```

---

## 已知陷阱与规避

| 陷阱 | 规避方案 |
|------|----------|
| Widget @State 无法接收 FormBindingData | 改用 LocalStorage 或静态数据初始化 |
| form_config.json supportDimensions 格式 | 使用数组格式 `[2]` 而非字符串 |
| NOTIFICATION_CONTROLLER 三方不可用 | 不声明此权限，仅用 PUBLISH_AGENT_REMINDER |
| reminderAgentManager 上限 30 个 | 创建前检查数量，超出时删除最早的 |
| postCardAction params 不可 JSON.stringify | 直接传原生对象 |
| BasicDataSource 非框架内置 | 自行实现 IDataSource 接口 |
