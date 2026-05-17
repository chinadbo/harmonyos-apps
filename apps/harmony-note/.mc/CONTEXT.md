# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import fs from '@ohos.file.fs'`）
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
- entry/src/main/resources/base/profile/main_pages.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 只申请实际用到的权限
- READ_MEDIA 范围太大，优先用 READ_AUDIO/READ_IMAGES 等细分权限

## 本项目特定规范

### 文件存储
- 使用 @ohos.file.fs（import fs from '@ohos.file.fs'）
- fs.listFileSync(dirPath) 返回 string[]，直接遍历
- 原子写入：先写 .tmp，再 fs.renameSync(tmpPath, finalPath)
- 沙箱路径：getContext(this).filesDir

### Markdown 渲染
- 使用 Web 组件 + loadData() 加载本地 HTML 字符串
- rawfile 中放 marked.min.js（最小化版本）
- HTML 通过 resource://rawfile/marked.min.js 引用本地脚本
- ArkTS 向 Web 传数据：this.webController.runJavaScript(...)

### 数据层
- IDataSource 接口需自行实现（totalCount + getData + registerDataChangeListener + unregisterDataChangeListener）
- 元数据存 index.json，笔记内容存独立 .md 文件
- UUID 用 Date.now().toString(36) + Math.random().toString(36).substr(2)

### 路由
- Navigation + NavPathStack
- 页面参数通过 NavPathInfo.param 传递
- 每个子页面 build() 返回 NavDestination 包裹

### 状态管理
- 全局：@StorageProp/@StorageLink + AppStorage
- 页面内：@State + @Prop + @Link
- 禁止 V2 装饰器
