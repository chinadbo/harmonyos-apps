# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import reminderAgentManager from '@ohos.reminderAgentManager'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口（totalCount/getData/registerDataChangeListener/unregisterDataChangeListener）
- CanvasRenderingContext2D 构造必须传 RenderingContextSettings：`new CanvasRenderingContext2D(new RenderingContextSettings(true))`
- Canvas 绘制代码必须写在 onReady 回调内，不能写在 onAppear 或 build 中
- reminderAgentManager.publishReminder 返回 Promise<number>，必须保存 reminderId 用于后续 cancel
- FormExtensionAbility 必须同时实现 onCreate 和 onNewWant 两个生命周期方法
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- getContext() 不能强转为 Ability 实例
- Preferences.getSync/putSync 不存在，只有异步方法 get/put/flush
- LazyForEach keyGenerator 必须返回稳定唯一字符串（如 id.toString()）

## 项目必备文件
- AppScope/app.json5 + AppScope/resources/base/element/string.json + AppScope/resources/base/media/app_icon.png（用空占位即可）
- entry/src/main/module.json5（含 extensionAbilities 的 form 类型声明）
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- entry/src/main/resources/base/profile/form_config.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 本项目只需：ohos.permission.PUBLISH_AGENT_REMINDER
- 不需要 INTERNET、READ_MEDIA、CAMERA 等权限

## 本项目特定规范

### 数据库（DatabaseService.ets）
- RelationalStore 单例，init(context) 只调用一次
- 表名：sleep_records，字段：id, sleep_time, wake_time, duration, quality, note, created_at
- 所有操作 async/await，用 try/catch 包裹

### 提醒（ReminderService.ets）
- 使用 reminderAgentManager（import from '@ohos.reminderAgentManager'）
- REMINDER_TYPE_ALARM 类型，daysOfWeek: [1,2,3,4,5,6,7]
- publishReminder 返回的 reminderId 存入 Preferences 持久化

### Widget（SleepFormExtensionAbility.ets）
- 继承 FormExtensionAbility
- 同时实现 onCreate(want) 和 onNewWant(want)
- 通过 preferences.getSync 读取昨日摘要数据（用同步版本防止 Widget 超时）
  - 注意：preferences 有 getSync 方法，是 Preferences 对象的方法（不是 dataPreferences.getPreferences）
  - 正确用法：先 dataPreferences.getPreferencesSync(context, {name: 'xxx'}) 获取对象，再调用 .getSync(key, default)

### Canvas 图表
- TrendChart 和 BarChart 组件：Canvas 绘制在 onReady 内
- CanvasRenderingContext2D 构造：`private context = new CanvasRenderingContext2D(new RenderingContextSettings(true))`
- 折线图绘制逻辑：先 clearRect，再 strokeStyle + lineWidth，moveTo + lineTo，最后 stroke
