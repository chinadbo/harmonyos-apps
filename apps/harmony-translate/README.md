# HarmonyTranslate - 鸿蒙翻译

一款轻量级多语言翻译工具，支持文本翻译、剪贴板快速翻译、翻译历史管理、收藏夹。聚焦离线词典 + 在线翻译双模式，突出鸿蒙剪贴板监听和分享能力。

## 功能特性

- 🌐 **多语言翻译** — 支持中/英/日/韩/法/德/西/俄等主流语言互译
- 📋 **剪贴板翻译** — 监听剪贴板变化，自动弹出翻译提示
- 📋 **翻译历史** — 自动保存翻译记录，支持搜索、删除
- ⭐ **收藏夹** — 标记重要翻译结果，方便回顾
- 📴 **离线词典** — 内置 500+ 常用中英词对，无网络时可用
- 🔗 **一键分享** — 翻译结果通过系统分享发送
- 🌙 **深色模式** — 支持亮色/暗色主题切换

## 技术架构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets              # UIAbility 入口
├── pages/
│   └── Index.ets                     # 主页面（Tabs 容器）
├── views/
│   ├── TranslateView.ets             # 翻译主界面
│   ├── HistoryView.ets               # 翻译历史列表
│   ├── FavoritesView.ets             # 收藏夹列表
│   └── SettingsView.ets              # 设置页面
├── components/
│   ├── LanguageSelector.ets          # 语言选择器组件
│   ├── TranslateResultCard.ets       # 翻译结果卡片
│   ├── HistoryItem.ets               # 历史记录列表项
│   └── EmptyState.ets                # 空状态占位组件
├── model/
│   ├── TranslateRecord.ets           # 翻译记录数据模型
│   ├── Language.ets                  # 语言枚举与配置
│   └── DictEntry.ets                 # 离线词典条目模型
├── service/
│   ├── TranslateService.ets          # 翻译服务（在线 API + 离线词典）
│   ├── DatabaseService.ets           # RDB 数据库服务
│   └── ClipboardService.ets          # 剪贴板监听服务
└── utils/
    ├── HttpUtil.ets                  # HTTP 网络请求封装
    └── TimeUtil.ets                  # 时间格式化工具
```

## 技术亮点

- **@ohos.pasteboard** — 剪贴板读写与监听
- **@ohos.net.http** — HTTP 网络请求调用 MyMemory 翻译 API
- **@ohos.data.relationalStore** — RDB 关系型数据库存储翻译历史和收藏
- **List + LazyForEach** — 高性能列表渲染翻译历史
- **Tabs + TabContent** — 多 Tab 页面布局（翻译/历史/收藏/设置）
- **动画** — 翻译结果展示动画（淡入 + 滑动）
- **深色模式** — 通过 @StorageProp('currentColorMode') 适配

## 构建方式

1. 使用 DevEco Studio 打开项目
2. 确保 SDK 版本为 API 16
3. 构建并运行到 HarmonyOS 设备或模拟器

## 权限

- `ohos.permission.INTERNET` — 用于调用在线翻译 API

## 数据来源

- 在线翻译：MyMemory Translation API（免费，无需 API Key）
- 离线词典：内置 500+ 常用中英词对

## 版本

v1.0.0 — 2026-07-11

## 作者

chinadbo
