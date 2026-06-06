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

## 项目必备文件
- AppScope/app.json5 + resources
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/ets/pages/Index.ets（Tab 主界面）
- entry/src/main/resources/base/profile/main_pages.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 只申请实际用到的权限
- READ_MEDIA 范围太大，优先用 READ_AUDIO/READ_IMAGES 等细分权限
- PhotoViewPicker 通常不需要权限即可选择图片

## Canvas 绘制规范
- 构造顺序：先 `new RenderingContextSettings(true)` 再 `new CanvasRenderingContext2D(settings)`
- 在 onReady 回调中绘制初始内容
- 数据变化需配合 @Watch 触发重绘

## RDB 规范
- 使用 relationalStore.getRdbStore() 2 参数版本（storeConfig + callback）
- 建表用 executeSql()，不用过时的 4 参数 getRdbStore
- 数据库操作封装在 DatabaseHelper 中

## 当前 App 信息
- App 名称：HarmonyPalette（配色助手）
- 核心功能：色轮选色、图片取色、配色方案生成、颜色收藏
- 页面结构：Tab 主界面（4 个 Tab：色轮、图片取色、配色方案、收藏）
- 技术栈：Canvas + PhotoViewPicker + PixelMap + RDB + pasteboard
