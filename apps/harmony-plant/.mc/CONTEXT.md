# HarmonyOS 编码规范（必须遵守）

## 项目信息
- App 名称：HarmonyPlant（花草养护/植物日记）
- 包名：com.example.harmonyplant
- API Level：16（HarmonyOS NEXT）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import relationalStore from '@ohos.data.relationalStore'`）
- 不使用 @kit.* 风格
- NavPathStack 是 Navigation 内置能力，不需要显式 import

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- getRdbStore 必须使用 2 参数版本：getRdbStore(context, config)
- PhotoViewPicker 构造函数不传 context 参数：new picker.PhotoViewPicker()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- AppStorage 使用前必须初始化：AppStorage.setOrCreate('key', defaultValue)
- @StorageLink 在子组件中需赋值初始值
- Widget postCardAction 参数必须为字符串类型
- FormExtensionAbility 必须同时实现 onCreate 和 onNewWant
- @kit.ArkUI 不存在，禁止 import @kit.ArkUI（NavPathStack 内置无需导入）

## 项目必备文件
- AppScope/app.json5 + AppScope/resources/base/element/string.json
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- entry/src/main/resources/base/profile/form_config.json
- entry/src/main/resources/base/element/string.json
- build-profile.json5
- oh-package.json5
- privacy_statement.json
- README.md

## 权限最小化
- ohos.permission.PUBLISH_AGENT_REMINDER（reminderAgentManager 需要）
- ohos.permission.READ_IMAGEVIDEO（读取已保存照片 URI 需要）
- 不需要 WRITE_MEDIA、READ_MEDIA、CAMERA 等宽泛权限

## 架构说明
参见 architecture.md 中的模块划分和数据模型定义。
实现所有文件，确保代码完整可编译，不留 TODO 占位。
