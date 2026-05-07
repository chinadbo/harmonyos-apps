# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import media from '@ohos.multimedia.media'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- 不存在 media.fetchAVFileDescriptor，获取音频 metadata 用 media.createAVMetadataExtractor()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 MusicPlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例
- Form Widget 中 supportDimensions 格式必须是 ["2*2"]，不是 [2]
- Form Widget 数据绑定用 @LocalStorageProp，不用 @State
- postCardAction params 直接传原生对象，不要 JSON.stringify
- module.json5 中不声明 NOTIFICATION_CONTROLLER（系统权限），改用运行时 notificationManager.requestEnableNotification()
- PhotoViewPicker 选择器模式不需要 READ_IMAGEVIDEO 权限

## 项目信息
- App 名称：HarmonyRecipe
- Bundle ID：com.chinadbo.harmonyrecipe
- 目标 API：12 (HarmonyOS 5.0)
- 品类：食谱菜谱管理 App

## 功能范围
1. 菜谱列表（Grid 2列，分类筛选）
2. 菜谱详情（食材+步骤）
3. 收藏功能（RDB 持久化）
4. 全文搜索（FTS5）
5. 烹饪计时器（reminderAgentManager + 通知）
6. 预置 20 道家常菜数据
7. 服务卡片 Widget（2x2，今日推荐）

## 项目必备文件
- AppScope/app.json5 + resources
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 只申请 ohos.permission.NOTIFICATION（通知）
- PhotoViewPicker 无需声明 READ_IMAGEVIDEO 权限（选择器模式用户主动授权）

## 参考架构（来自 architecture.md）
- 数据层：DatabaseService.ts（RDB 单例 + FTS5）
- 通知层：NotificationService.ts（reminderAgentManager 封装）
- 数据源：RecipeDataSource.ts（BasicDataSource 自实现）
- 预置数据：PresetDataService.ts 读取 data/recipes.json，首次启动写入 RDB
- 页面：Index.ets（Tabs）/ RecipeDetail.ets / SearchPage.ets / CookingTimer.ets
- 组件：RecipeCard.ets / CategoryFilter.ets / StepItem.ets / StarButton.ets
