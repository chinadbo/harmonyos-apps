# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import sensor from '@ohos.sensor'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- 不存在 media.fetchAVFileDescriptor，获取音频 metadata 用 media.createAVMetadataExtractor()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 MusicPlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例
- Canvas 绘制必须在 onReady 回调中执行，不能在 build() 中直接调用
- sensor.on() 的 interval 参数单位是纳秒（ns），1秒 = 1000000000
- preferences.getPreferences() 是异步的，必须 await
- RelationalStore.getRdbStore() 必须 await 完成后才能调用 insert/query
- FormProvider.updateForm() 需要 formId，从 onAddForm 中获取并持久化

## 项目必备文件
- AppScope/app.json5 + resources/base/element/string.json + resources/base/media/app_icon.png（占位符）
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 只申请 ohos.permission.ACTIVITY_MOTION（计步传感器）
- READ_MEDIA 范围太大，优先用 READ_AUDIO/READ_IMAGES 等细分权限

## 本项目架构（HarmonyFit）

### 功能概述
健康运动记录 App：实时计步仪 + 运动记录管理 + 数据可视化 + 桌面 Widget

### 文件清单
```
HarmonyFit/
├── AppScope/
│   ├── app.json5
│   └── resources/base/element/string.json
├── entry/src/main/ets/
│   ├── entryability/EntryAbility.ets
│   ├── entryformability/EntryFormAbility.ets
│   ├── model/
│   │   ├── WorkoutRecord.ets
│   │   └── WorkoutType.ets
│   ├── service/
│   │   ├── DatabaseService.ets
│   │   ├── SensorService.ets
│   │   └── PreferencesService.ets
│   ├── viewmodel/
│   │   ├── HomeViewModel.ets
│   │   └── WorkoutDataSource.ets
│   ├── pages/
│   │   ├── Index.ets
│   │   ├── HomePage.ets
│   │   ├── WorkoutListPage.ets
│   │   ├── StatsPage.ets
│   │   └── SettingsPage.ets
│   ├── components/
│   │   ├── RingProgressChart.ets
│   │   ├── BarChart.ets
│   │   ├── WorkoutCard.ets
│   │   └── AddWorkoutDialog.ets
│   └── widget/pages/WidgetCard.ets
├── entry/src/main/
│   ├── module.json5
│   └── resources/base/
│       ├── element/string.json
│       └── profile/
│           ├── main_pages.json
│           └── form_config.json
├── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```

### 核心 API
- `import sensor from '@ohos.sensor'` — 计步传感器
- `import relationalStore from '@ohos.data.relationalStore'` — RDB
- `import preferences from '@ohos.data.preferences'` — 轻量存储
- `import formProvider from '@ohos.app.form.formProvider'` — Widget 刷新
- `import formInfo from '@ohos.app.form.formInfo'` — Widget 信息

### IDataSource 实现（必须）
```typescript
// WorkoutDataSource.ets - 必须自行实现，不能用 BasicDataSource
export class WorkoutDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private data: WorkoutRecord[] = [];
  totalCount(): number { return this.data.length; }
  getData(index: number): WorkoutRecord { return this.data[index]; }
  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) this.listeners.push(listener);
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx !== -1) this.listeners.splice(idx, 1);
  }
  notifyDataReload(): void { this.listeners.forEach(l => l.onDataReloaded()); }
  setData(records: WorkoutRecord[]): void { this.data = records; this.notifyDataReload(); }
  addRecord(record: WorkoutRecord): void {
    this.data.unshift(record);
    this.listeners.forEach(l => l.onDataAdd(0));
  }
}
```
