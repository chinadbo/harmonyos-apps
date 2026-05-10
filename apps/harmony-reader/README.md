# HarmonyReader

HarmonyReader 是一个基于 HarmonyOS ArkUI V1 的电子书阅读器示例工程，支持导入 txt 书籍、章节解析、阅读进度持久化、书签与主题切换。

## 功能
- 书架首页 2 列书籍网格与空状态提示
- 通过 DocumentViewPicker 导入 txt 文件
- 自动解析章节并保存到 RDB
- Swiper 横向切换章节，自动保存与恢复阅读进度
- 章节目录、书签列表、日间/护眼/夜间主题、字体大小调节

## 架构
- `entry/src/main/ets/service`：数据访问、偏好设置、章节解析与书籍导入
- `entry/src/main/ets/viewmodel`：书架与阅读状态管理
- `entry/src/main/ets/components`：卡片、阅读正文、工具栏、主题面板
- `entry/src/main/ets/pages`：书架页、阅读页、目录页、书签页

## 数据存储
- RDB 表：`books`、`chapters`、`bookmarks`、`reading_progress`
- Preferences：`readerTheme`、`readerFontSize`

## 构建
1. 使用 DevEco Studio 打开工程目录。
2. 配置 HarmonyOS SDK 12。
3. 选择 `entry` 模块运行到模拟器或真机。

## 路由
应用使用 `Navigation + NavPathStack` 管理页面跳转，避免使用 `router.pushUrl`。
