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

## 本项目特定规范（HarmonyFiles 文件管理器）

### 架构
- Navigation + NavPathStack 多级路由（路径见 architecture.md）
- 页面：Index（根）/ FileBrowserPage / FilePreviewPage / SearchPage / FavoritesPage
- 弹窗：FileDetailSheet / RenameDialog / NewFolderDialog / DeleteConfirmDialog
- 服务：FileService（fs API）/ FavoritesService（Preferences）
- 工具：FileIconMapper / FileSizeFormatter / DateFormatter

### 关键 API
- `import fs from '@ohos.file.fs'` — 文件操作
- `import dataPreferences from '@ohos.data.preferences'` — 收藏夹持久化
- `import picker from '@ohos.file.picker'` — 文件选择器
- `import media from '@ohos.multimedia.media'` — 音视频预览

### 数据模型（已在 architecture.md 定义，严格遵守）
- FileItem: { name, path, isDirectory, size, mtime, extension, mimeType, iconResource }
- FavoriteItem: { id, name, path, addedAt }
- ViewMode enum: LIST / GRID
- SortMode enum: NAME_ASC / NAME_DESC / DATE_DESC / SIZE_DESC

### LazyForEach 数据源
- 必须自定义 FileDataSource 实现 IDataSource 接口（totalCount + getData + 监听器管理）

### 性能规范
- 目录列出用 fs.listFileSync() 同步批量获取 string[]
- 每个文件 stat 用 fs.statSync() 
- 大目录（>500项）分批加载：首屏 50 项，滚动到底追加
- 搜索递归深度限制 5 层

### 导航规范
- NavPathStack.pushPathByName('FileBrowserPage', { path: '...' } as Record<string, string>)
- 返回用 NavPathStack.pop()
- 面包屑路径从 navStack 路径参数中重建
