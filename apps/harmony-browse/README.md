# HarmonyBrowse

HarmonyOS 轻量浏览器

## 功能
- 多标签页浏览
- 地址栏 URL 输入与搜索
- 书签管理
- 浏览历史记录
- 导航控制（后退/前进/刷新/主页）
- 菜单系统（书签/历史/设置）

## 技术架构
- Web 组件（WebView）用于网页渲染
- RDB 数据库用于书签和历史记录持久化
- V1 装饰器体系

## 项目结构
```
entry/src/main/ets/
├── entryability/EntryAbility.ets
├── pages/
│   ├── MainPage.ets
│   ├── BookmarkListPage.ets
│   ├── HistoryPage.ets
│   ├── SettingsPage.ets
│   └── TabOverviewPage.ets
├── components/
│   ├── AddressBar.ets
│   ├── NavigationBar.ets
│   ├── TabCard.ets
│   └── BookmarkItem.ets
├── model/
│   ├── TabItem.ets
│   ├── Bookmark.ets
│   └── HistoryItem.ets
├── database/BrowserDatabase.ets
└── utils/Constants.ets
```

## 构建
```bash
hvigorw assembleApp
```

## 权限
- ohos.permission.INTERNET
- ohos.permission.WRITE_IMAGES

## 版本
1.0.0

## 作者
chinadbo
