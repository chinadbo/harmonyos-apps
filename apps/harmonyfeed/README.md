# HarmonyFeed — RSS/Atom 智能阅读器

> 纯血鸿蒙原生 RSS 阅读器，AppGallery 生态空白填补。

[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-5.0.4%20API16-blue)](https://developer.huawei.com/consumer/cn/)
[![ArkTS](https://img.shields.io/badge/Language-ArkTS-green)](https://developer.huawei.com/consumer/cn/arkts/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](./LICENSE)

## 功能特性

- 📡 **多格式支持** — RSS 2.0 / Atom 1.0 / JSON Feed 全兼容
- 📖 **沉浸式阅读** — 自定义字体大小、夜间模式、横屏重排
- 📦 **离线缓存** — 文章本地持久化（RelationalStore），无网络可读
- 🔖 **智能收藏** — 左滑收藏/已读，收藏文章永久保存
- 🔍 **全文搜索** — 实时搜索文章标题、正文（防抖 300ms）
- 🌐 **OPML 支持** — 导入/导出订阅源列表，轻松迁移
- 🔔 **智能推送** — 重要订阅源新文章本地通知
- 🤝 **跨设备流转** — 手机阅读位置实时同步到平板（Continuation）
- 📱 **桌面卡片** — 2×4 最新文章卡片（AtomicService Widget）
- 🎙️ **语音指令** — InsightIntent 支持"打开 HarmonyFeed 读科技新闻"

## 技术架构

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (ArkUI)                       │
│  FeedListPage  ArticleListPage  ArticleReaderPage  ...   │
│  FeedItem      ArticleCard      EmptyState                │
└──────────────────────┬──────────────────────────────────┘
                       │ @State / @Observed / @ObjectLink
┌──────────────────────▼──────────────────────────────────┐
│              ViewModel / Service Layer                     │
│  FeedService    ArticleService    RssParser               │
│  HttpService    DatabaseService   OpmlUtils               │
└──────────────────────┬──────────────────────────────────┘
                       │ async/await + try/catch
┌──────────────────────▼──────────────────────────────────┐
│                   Data Layer                               │
│  RelationalStore (SQLite)   @ohos.net.http   FileKit      │
│  feeds / articles / categories tables                      │
└─────────────────────────────────────────────────────────┘
```

## HarmonyOS 特色能力

| 能力 | API 版本 | 用途 |
|------|---------|------|
| ArkUI LazyForEach + @Reusable | API 9+ | 高性能文章列表 |
| RelationalStore | API 9+ | 本地文章数据库 |
| @ohos.net.http | API 6+ | RSS Feed 拉取 |
| Web 组件 + loadData | API 8+ | 沉浸式文章渲染 |
| bindSheet / bindContentCover | API 11+ | 弹窗体验 |
| WorkScheduler | API 9+ | 后台定时刷新 |
| ContinuationManager | API 9+ | 跨设备流转 |
| InsightIntent | API 11+ | 语音指令 |
| AtomicServiceWidget | API 12+ | 桌面卡片 |

## 项目结构

```
harmonyfeed/
├── AppScope/                    # 应用配置
│   ├── app.json5               # 包名/版本
│   └── resources/              # 应用级资源
├── entry/                       # 主模块
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/   # EntryAbility（初始化）
│       │   ├── pages/          # 8 个页面
│       │   ├── components/     # 可复用组件
│       │   ├── model/          # 数据模型
│       │   ├── service/        # 业务服务层
│       │   └── utils/          # 工具类
│       └── resources/          # 模块资源
├── build-profile.json5          # 构建配置
└── README.md
```

## 快速开始

### 环境要求

- DevEco Studio 5.0+
- HarmonyOS SDK API 16
- 目标设备：HarmonyOS 5.0.4+（手机/平板）

### 构建步骤

```bash
# 1. 克隆仓库
git clone https://github.com/chinadbo/harmonyos-harmonyfeed.git

# 2. 用 DevEco Studio 打开项目

# 3. 同步依赖
ohpm install

# 4. 构建调试包
hvigor assembleHap --mode module -p module=entry@default
```

### 权限说明

| 权限 | 用途 |
|------|------|
| `ohos.permission.INTERNET` | 拉取 RSS Feed 内容 |
| `ohos.permission.GET_NETWORK_INFO` | 检测网络状态 |

## 隐私声明

- ✅ **不收集** 任何个人身份信息
- ✅ **不上传** 用户阅读记录到任何服务器
- ✅ **网络访问** 仅用于拉取用户主动订阅的 RSS 源
- ✅ **本地存储** 所有数据存储在用户设备本地

## 截图

> _截图将在设备测试完成后更新_

| 订阅列表 | 文章列表 | 阅读器 | 发现页 |
|---------|---------|--------|--------|
| ![订阅列表](./screenshots/feeds.png) | ![文章列表](./screenshots/articles.png) | ![阅读器](./screenshots/reader.png) | ![发现](./screenshots/discover.png) |

## 开发计划

- [ ] OPML 完整导入/导出
- [ ] 全文缓存（离线正文）
- [ ] 桌面卡片 Widget
- [ ] InsightIntent 语音指令实现
- [ ] 跨设备流转（Continuation）完整实现
- [ ] 性能优化（图片懒加载、预加载）
- [ ] iPad 多栏布局

## 贡献

欢迎 Issue 和 PR！HarmonyOS 生态建设需要大家一起努力。

## License

MIT © 2026 chinadbo
