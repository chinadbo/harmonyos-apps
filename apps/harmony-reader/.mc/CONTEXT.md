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
- 不存在 media.fetchAVFileDescriptor
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例
- DocumentViewPicker 选择文件后需用 fs.copyFileSync 拷贝到沙箱，之后用沙箱路径访问
- relationalStore.getRdbStore 回调方式已废弃，使用 Promise 方式

## 项目必备文件
- AppScope/app.json5 + resources/base/element/string.json
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 本项目使用 DocumentViewPicker，不需要 READ_MEDIA 权限
- module.json5 中 requestPermissions 数组留空

## 项目说明（architecture.md 摘要）

### 应用功能
电子书阅读器，支持导入 txt 文件、章节解析、翻页动画、书签、阅读进度持久化、三主题切换。

### 技术要点
1. DocumentViewPicker 选择 txt 文件 → fs.copyFileSync 到沙箱 → 读取内容
2. ChapterParser 用正则解析章节：支持"第X章"/"Chapter N"/数字序号三种格式
3. RDB 存储：books/chapters/bookmarks/reading_progress 四张表
4. 主题：@StorageProp('readerTheme') 跨组件同步，preferences 持久化
5. 翻页：Swiper 组件 + 自定义 PageContent 组件渲染当前章节文本
6. 章节大文件（>500KB）分批处理

### 页面列表
- Index.ets：书架首页（NavDestination）
- ReaderPage.ets：阅读器（NavDestination，接收 bookId）
- BookmarkPage.ets：书签列表（NavDestination，接收 bookId）
- ChapterListPage.ets：章节目录（NavDestination，接收 bookId）

### 数据流
- BookshelfViewModel.ets：管理书架状态（书籍列表、导入操作）
- ReaderViewModel.ets：管理阅读状态（当前章节、进度、书签）
