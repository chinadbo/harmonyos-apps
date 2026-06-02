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
- 不存在 media.fetchAVFileDescriptor，获取音频 metadata 用 media.createAVMetadataExtractor()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 MusicPlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例
- getRdbStore 必须使用 2 参数版本（context, StoreConfig），不能用 3 参数回调版本
- 通知权限不在 module.json5 声明 NOTIFICATION_CONTROLLER，改用运行时 notificationManager.requestEnableNotification()
- Widget supportDimensions 格式为 ["2*2"]，不是 [[2,2]]
- FormExtensionAbility 必须同时实现 onCreate 和 onNewWant（热启动路由必须有 onNewWant）
- Widget 读数据用 getPreferencesSync（同步），避免 10s 超时
- postCardAction 参数必须为字符串类型
- NavPathStack 是 Navigation 内置能力，无需从 @ohos.router 或 @kit.ArkUI 显式导入
- Canvas 必须先 new RenderingContextSettings(true) 再 new CanvasRenderingContext2D(settings)，在 onReady 回调中绘制
- AppStorage.set/get 使用前须在 EntryAbility.onCreate 中初始化
- @Entry 装饰器只用于入口页面（main_pages.json 中注册的页面）
- @StorageLink 在子组件中需要赋值初始值

## 项目必备文件
- AppScope/app.json5 + resources/base/element/string.json + resources/base/media/app_icon.png
- entry/src/main/module.json5（含 mainElement, pages, abilities, extensionAbilities）
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json（只注册 pages/Index）
- entry/src/main/resources/base/profile/form_config.json（Widget 配置）
- entry/src/main/resources/base/element/string.json
- build-profile.json5
- oh-package.json5
- privacy_statement.json
- README.md

## 权限最小化
- 只申请实际用到的权限
- 通知权限运行时请求，不在 module.json5 的 requestPermissions 声明

## 本项目架构
App 名称：HarmonyFridge（冰箱食材管理助手）
品类：生活工具 / 食材追踪
核心功能：
1. 食材管理（RDB 存储）：添加/编辑/删除食材（名称/数量/单位/分类/有效期/存储区）
2. 有效期预警：过期=红，≤3天=橙，≤7天=黄，正常=绿
3. 分类管理：蔬果/肉类海鲜/奶制品/饮料/调味品/零食/其他 × 冷藏/冷冻/常温
4. 购物清单：从食材一键加入，勾选管理
5. 统计图表：Canvas 柱状图，各分类数量
6. Widget：2×2 桌面小组件，显示即将过期数量

页面结构：
- Index.ets（@Entry）：Tabs 底部导航 → FridgeHomePage/ShoppingListPage/StatsPage/SettingsPage
- ItemEditPage.ets：通过 NavPathStack push 进入
- 路由：Navigation + NavPathStack

数据层：
- DatabaseHelper.ets（RDB 单例，getRdbStore 2参数）
- FoodItemDao.ets（CRUD）
- ShoppingDao.ets（CRUD）
- FoodDataSource.ets（LazyForEach 用，自实现 IDataSource）

通知：NotificationService.ets 单例，运行时请求权限
Widget：FridgeWidgetCard.ets + FridgeFormExtensionAbility.ets（onCreate+onNewWant）
