# HarmonyPlant 架构设计

## 技术栈
- **平台：** HarmonyOS NEXT API 16（ArkTS）
- **装饰器：** V1 体系（@Component/@State/@Prop/@Link/@StorageProp/@StorageLink）
- **路由：** NavPathStack（Navigation 组件内置，无需显式 import）
- **数据库：** RelationalStore（@ohos.data.relationalStore）
- **通知：** reminderAgentManager（@ohos.reminderAgentManager）
- **Widget：** FormExtensionAbility + ArkTS 卡片（2×2）
- **图片：** PhotoViewPicker（无需额外权限）

## 模块划分

```
HarmonyPlant/
├── AppScope/
│   ├── app.json5
│   └── resources/base/element/string.json
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets
│   │   │   ├── pages/
│   │   │   │   ├── Index.ets              (Tab 导航 + Navigation)
│   │   │   │   ├── PlantListPage.ets      (植物列表)
│   │   │   │   ├── PlantDetailPage.ets    (植物详情)
│   │   │   │   ├── AddPlantPage.ets       (添加/编辑植物)
│   │   │   │   ├── CareLogPage.ets        (养护打卡记录)
│   │   │   │   ├── DiaryListPage.ets      (植物日志列表)
│   │   │   │   ├── AddDiaryPage.ets       (写日志)
│   │   │   │   └── RemindersPage.ets      (提醒管理)
│   │   │   ├── model/
│   │   │   │   ├── Plant.ets              (植物数据模型)
│   │   │   │   ├── CareRecord.ets         (养护记录模型)
│   │   │   │   └── PlantDiary.ets         (日志模型)
│   │   │   ├── service/
│   │   │   │   ├── DatabaseService.ets    (RDB 单例)
│   │   │   │   ├── ReminderService.ets    (reminderAgentManager 封装)
│   │   │   │   └── PlantService.ets       (植物 CRUD 业务逻辑)
│   │   │   └── components/
│   │   │       ├── PlantCard.ets          (@Reusable 可复用卡片)
│   │   │       ├── CareButton.ets         (浇水/施肥快捷按钮)
│   │   │       └── BasicDataSource.ets    (IDataSource 实现)
│   │   ├── resources/
│   │   │   └── base/profile/
│   │   │       ├── main_pages.json
│   │   │       └── form_config.json
│   │   └── module.json5
│   └── src/main/ets/widget/
│       ├── pages/
│       │   └── WidgetCard.ets             (桌面小组件)
│       └── formextensionability/
│           └── PlantFormExtensionAbility.ets
├── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```

## 数据模型

### 植物表（plants）
```
id: INTEGER PRIMARY KEY AUTOINCREMENT
name: TEXT NOT NULL
species: TEXT
photoUri: TEXT
addedDate: TEXT (ISO 8601)
waterInterval: INTEGER (天数, 默认 3)
fertilizeInterval: INTEGER (天数, 默认 30)
lastWateredAt: TEXT
lastFertilizedAt: TEXT
reminderId: INTEGER (reminderAgentManager id)
notes: TEXT
```

### 养护记录表（care_records）
```
id: INTEGER PRIMARY KEY AUTOINCREMENT
plantId: INTEGER NOT NULL
careType: TEXT ('water' | 'fertilize' | 'prune' | 'repot')
careDate: TEXT
note: TEXT
```

### 植物日志表（plant_diary）
```
id: INTEGER PRIMARY KEY AUTOINCREMENT
plantId: INTEGER NOT NULL
title: TEXT
content: TEXT
photoUri: TEXT
createdAt: TEXT
```

## API 使用规范

### RDB
```typescript
import relationalStore from '@ohos.data.relationalStore'
// getRdbStore 必须 2 参数版本
const store = await relationalStore.getRdbStore(context, config)
```

### reminderAgentManager
```typescript
import reminderAgentManager from '@ohos.reminderAgentManager'
// 使用 REMINDER_TYPE_ALARM 类型，设置浇水提醒
// 单个植物注册一个 reminder，保存 reminderId 到 DB
const reminderId = await reminderAgentManager.publishReminder(reminder)
```

### PhotoViewPicker（无需权限）
```typescript
import picker from '@ohos.file.picker'
const photoPicker = new picker.PhotoViewPicker()
const result = await photoPicker.select(options)
```

### FormExtensionAbility Widget
- Widget 数据通过 formProvider.updateForm 推送
- Widget 互动通过 postCardAction 回调处理
- onNewWant 和 onCreate 都需实现

## 权限声明（最小化）
```json
"requestPermissions": [
  { "name": "ohos.permission.PUBLISH_AGENT_REMINDER" },
  { "name": "ohos.permission.READ_IMAGEVIDEO" }
]
```
> 注：PhotoViewPicker 选图无需权限；仅读取已保存 URI 时需 READ_IMAGEVIDEO

## 路由注册
- main_pages.json: 所有页面路径
- Index.ets: NavPathStack 入口
- 各页面: @Builder 注册

## Widget 配置
- 尺寸：2×2（默认）、2×4（可选）
- 更新间隔：到期提醒时自动刷新
- formConfig: `form_config.json` 声明

## 关键设计决策

1. **浇水计算逻辑**：`nextWaterDate = lastWateredAt + waterInterval`，当天或已过期显示"今日待浇水"
2. **Widget 数据**：仅展示今日待浇水的植物名称（最多 3 株），通过 formProvider.updateForm 更新
3. **照片存储**：存 PhotoViewPicker 返回的 datashare:// URI，不拷贝文件（节省空间）
4. **BasicDataSource**：手动实现 IDataSource，供 LazyForEach 使用
5. **AppStorage 初始化**：在 EntryAbility.onCreate 中初始化 AppStorage.setOrCreate('plantCount', 0)
