# HarmonyTune 🎵

本地音乐播放器 for HarmonyOS。

HarmonyTune 是一个面向 HarmonyOS API 16 的完整本地音乐播放器示例工程，采用 ArkTS / ArkUI 构建，覆盖从入口能力、页面导航、播放核心、数据库持久化到媒体会话集成的完整结构，适合作为 AppGallery 上架前的产品原型或正式项目基础骨架。

## 功能特性
- 本地音乐扫描（MP3/FLAC/AAC/WAV）
- 完整播放控制（顺序/随机/单曲循环）
- 自定义歌单管理
- 媒体控制中心集成（锁屏控制）
- 跨设备流转（手机→平板）
- InsightIntent 语音控制
- 精致旋转碟片动效
- 常驻 MiniPlayer 与全屏播放器页联动
- 最近播放、收藏歌曲、专辑与艺术家浏览
- RelationalStore 数据持久化建表与 DAO 抽象

## 技术栈
- HarmonyOS API 16
- ArkTS / ArkUI
- AVPlayer（播放内核）
- AVSessionManager（媒体控制）
- RelationalStore（数据持久化）
- Continuation（跨设备）

## 项目结构

```text
harmonytune/
├── AppScope/
│   ├── app.json5
│   └── resources/base/
│       ├── media/app_icon.png
│       └── element/string.json
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── abilities/
│   │   │   │   └── EntryAbility.ets
│   │   │   ├── pages/
│   │   │   │   ├── Index.ets
│   │   │   │   ├── MainPage.ets
│   │   │   │   ├── LibraryPage.ets
│   │   │   │   ├── PlayerPage.ets
│   │   │   │   ├── PlaylistPage.ets
│   │   │   │   └── SettingsPage.ets
│   │   │   ├── components/
│   │   │   │   ├── MiniPlayer.ets
│   │   │   │   ├── SongListItem.ets
│   │   │   │   ├── DiscCover.ets
│   │   │   │   └── LyricsView.ets
│   │   │   ├── model/
│   │   │   │   ├── SongEntity.ets
│   │   │   │   └── PlaylistEntity.ets
│   │   │   ├── service/
│   │   │   │   ├── PlayerService.ets
│   │   │   │   ├── MediaScanService.ets
│   │   │   │   └── AVSessionService.ets
│   │   │   ├── database/
│   │   │   │   ├── DatabaseHelper.ets
│   │   │   │   ├── SongDao.ets
│   │   │   │   └── PlaylistDao.ets
│   │   │   └── utils/
│   │   │       ├── FormatUtils.ets
│   │   │       └── PermissionUtils.ets
│   │   └── resources/
│   │       └── base/
│   │           ├── element/string.json
│   │           ├── media/
│   │           └── profile/main_pages.json
│   └── module.json5
├── oh-package.json5
├── build-profile.json5
├── hvigorfile.ts
└── README.md
```

## 架构图

```text
EntryAbility
  ├─ DatabaseHelper
  ├─ PermissionUtils
  ├─ PlayerService
  │   ├─ AVPlayer
  │   ├─ AVSessionService
  │   └─ AppStorage
  └─ MediaScanService
      └─ SongDao / RelationalStore

Index
  ├─ MainPage
  ├─ LibraryPage
  ├─ PlaylistPage
  ├─ SettingsPage
  ├─ MiniPlayer
  └─ PlayerPage
      ├─ DiscCover
      └─ LyricsView
```

## 页面说明

### 首页 MainPage
- 展示欢迎卡片、快捷入口、最近播放
- 当没有音乐数据时，引导用户执行扫描
- 可一键快速播放首首歌曲并更新最近播放

### 音乐库 LibraryPage
- Tabs 切换：全部歌曲 / 专辑 / 艺术家
- 提供搜索输入框，按歌曲名、专辑名、艺术家名过滤
- 列表项复用 `SongListItem`，支持快速播放与收藏切换

### 播放页 PlayerPage
- 深色沉浸式背景
- `DiscCover` 实现旋转碟片视觉
- 进度滑块、时间显示、模式切换、上一首 / 播放暂停 / 下一首 / 收藏
- `LyricsView` 提供占位歌词滚动与高亮行展示

### 歌单页 PlaylistPage
- 横向歌单卡片与详情列表联动
- 提供体验歌单自动生成功能
- 支持按歌单顺序播放列表曲目

### 设置页 SettingsPage
- 重新扫描音乐
- 清空最近播放
- 深色模式、InsightIntent、跨设备流转等开关
- 应用与权限状态说明

## 核心实现说明

### 1. PlayerService
`entry/src/main/ets/service/PlayerService.ets`

- 使用 `@ohos.multimedia.media` 的 `AVPlayer`
- 维护 `Idle / Prepared / Playing / Paused / Stopped` 状态
- 提供 `play / pause / resume / stop / next / prev / seekTo`
- 提供 `SEQUENCE / SHUFFLE / REPEAT_ONE` 三种播放模式
- 通过 `AppStorage` 暴露当前歌曲、播放状态、时间进度、队列、最近播放
- 监听：
  - `stateChange`
  - `timeUpdate`
  - `endOfStream`

### 2. DatabaseHelper
`entry/src/main/ets/database/DatabaseHelper.ets`

使用 `@ohos.data.relationalStore` 建立本地数据库：

- `songs`
  - `id`
  - `title`
  - `artist`
  - `album`
  - `duration`
  - `path`
  - `cover_path`
  - `added_at`
  - `play_count`
  - `is_favorite`
- `playlists`
  - `id`
  - `name`
  - `created_at`
- `playlist_songs`
  - `playlist_id`
  - `song_id`
  - `position`

### 3. MediaScanService
- 封装本地目录扫描流程
- 支持递归扫描常见音频扩展名
- 在真实环境没有可读媒体时，自动降级到示例数据，保证页面与播放链路可以完整体验

### 4. AVSessionService
- 初始化音频 AVSession
- 更新媒体元数据与播放状态
- 预留锁屏控制、系统媒体中心与未来跨设备控制入口

## 资源与国际化
- `AppScope/resources/base/element/string.json`：应用级名称与说明
- `entry/src/main/resources/base/element/string.json`：页面、按钮、状态文案
- 所有页面优先使用 `$r('app.string.xxx')` 读取资源
- `AppScope/resources/base/media/app_icon.png` 为自动生成的 64x64 PNG 占位图标

## 构建
需要 DevEco Studio 5.0+，配置 API 16 SDK。

### 环境要求
- DevEco Studio 5.0+
- HarmonyOS SDK API 16
- hvigor 构建环境
- 已安装 ArkTS / ArkUI 支持

### 导入步骤
1. 打开 DevEco Studio
2. 选择 **Open Project**
3. 打开 `harmonytune/` 目录
4. 等待索引完成并自动同步依赖
5. 检查 `build-profile.json5` 中的 `compatibleSdkVersion` 是否已安装
6. 配置签名后即可运行到模拟器或真机

### 建议构建流程
1. Sync Project
2. Build > Make Module 'entry'
3. Run > Select Device
4. 首次运行后授予媒体读取权限

## 权限说明
在 `entry/module.json5` 中声明：
- `ohos.permission.READ_MEDIA`
- `ohos.permission.READ_AUDIO`

用途：
- 读取本地媒体资源
- 扫描音频文件并建立音乐库索引
- 调用 AVPlayer 播放本地音频

## 截图
[占位]

建议在真机运行后补充以下截图：
- 首页欢迎卡片
- 音乐库歌曲列表
- 播放页旋转碟片
- 歌单管理页
- 设置页

## AppGallery 上架建议
- 将示例扫描逻辑切换为正式媒体库访问实现
- 补充隐私政策、用户协议与权限用途说明
- 为应用图标、启动页、截图、介绍文案准备正式素材
- 补充真实封面图与歌词解析能力
- 增加崩溃采集、性能监控与埋点
- 完善跨设备流转与 InsightIntent 的真实业务逻辑

## 后续可扩展方向
- LRC 歌词解析与逐字高亮
- 播放历史页与智能推荐
- 文件夹视图 / 文件系统浏览
- 本地均衡器与音效预设
- 深度接入 AVSession 多设备控制
- DataShare 或云同步歌单
- Widget / 服务卡片展示当前播放

## 说明
本工程强调“结构完整、功能链路完整、可继续工程化扩展”。若要用于正式商业发布，建议基于当前骨架继续完善：
- 真实媒体扫描与索引策略
- 错误恢复与异常埋点
- UI 资源精修
- 签名、发布与合规材料
- 实机联调与性能优化
