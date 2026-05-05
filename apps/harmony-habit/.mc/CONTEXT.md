# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import relationalStore from '@ohos.data.relationalStore'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- Widget 卡片内 @State 无法接收 FormBindingData → 改用静态数据或 LocalStorage
- form_config.json 的 supportDimensions 必须是数组格式 `[2]`，不是字符串
- NOTIFICATION_CONTROLLER 是系统权限，三方应用不可用，AppGallery 必拒 → 禁止声明
- reminderAgentManager 上限 30 个，超出时需先 cancelReminder 最早的再新建
- postCardAction params 直接传原生对象，不要 JSON.stringify
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string

## 项目必备文件
- AppScope/app.json5 + AppScope/resources/base/element/string.json
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- entry/src/main/resources/base/element/string.json
- build-profile.json5（根目录）
- entry/build-profile.json5
- oh-package.json5
- privacy_statement.json（隐私声明，AppGallery 上架必须）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 只申请实际用到的权限
- 本项目只需：ohos.permission.PUBLISH_AGENT_REMINDER
- 禁止声明：ohos.permission.NOTIFICATION_CONTROLLER

## 本项目特定规范

### Bundle 信息
- bundleName: com.chinadbo.harmonyhabit
- API Level: 12
- 入口 Ability: EntryAbility

### 数据库
- RDB 文件名: HarmonyHabit.db
- SecurityLevel: S1
- 两张表：habit（习惯） + checkin（打卡记录）

### Widget
- 使用 preferences 作为 App → Widget 数据桥（Widget 不能直接访问 RDB）
- Widget 模块名：widget
- FormAbility 类名：HabitFormAbility

### 路由
- 使用 NavPathStack + Navigation 路由
- main_pages.json、NavDestination 注册、页面文件三处必须一致

### 禁止使用
- 第三方库（oh-package.json5 中不添加任何外部依赖）
- Canvas 图表库（热力图用原生 Canvas API 手绘）
