# HarmonyNote

HarmonyNote 是一个 HarmonyOS 原生 Markdown 笔记应用示例，支持以下能力：

- Markdown 笔记创建、编辑、删除
- 本地文件存储与索引管理
- 笔记本（分类）管理
- 关键字搜索
- Markdown HTML 预览
- 基于 Navigation + NavPathStack 的页面路由
- 基于 ArkUI V1 装饰器体系实现

## 项目结构

- `AppScope/` 应用级配置与资源
- `entry/` 主模块代码与资源
- `entry/src/main/ets/model/` 数据模型、存储与数据源
- `entry/src/main/ets/components/` 公共组件
- `entry/src/main/ets/pages/` 页面代码
- `entry/src/main/resources/rawfile/marked.min.js` 内联 Markdown 解析脚本

## 主要功能

### 1. 首页与分类
首页展示统计信息、最近笔记、分类入口，并支持快速创建默认分类与新笔记。

### 2. 笔记列表
支持按笔记本查看笔记列表，显示标题、预览、更新时间和字数信息。

### 3. 编辑器
提供常用 Markdown 工具栏，一键插入标题、粗体、斜体、列表、代码块等语法。

### 4. 预览
通过内置 HTML 模板与 rawfile 中的精简 Markdown 解析器完成本地预览，不依赖网络。

### 5. 搜索
支持按标题与摘要内容进行关键字搜索。

## 本地数据结构

应用启动后会在沙箱目录下初始化：

- `index.json`：保存笔记本与笔记索引
- `notes/{id}.md`：保存每篇笔记正文

## 技术说明

- UI 框架：ArkUI（V1 装饰器）
- 路由方式：`Navigation + NavPathStack`
- 数据存储：`@ohos.file.fs`
- 能力入口：`UIAbility`
- 解析方案：内联精简版 `marked.min.js`

## 运行说明

1. 使用 DevEco Studio 打开项目目录。
2. 确认 SDK 版本为 HarmonyOS API 12。
3. 选择 `entry` 模块进行构建与运行。
4. 首次启动会自动初始化本地笔记目录与索引文件。

## 默认行为

- 若没有笔记本，应用会在需要时引导创建默认笔记本。
- 新笔记默认归类到当前笔记本；若无分类则归类到 `默认笔记本`。
- 删除笔记时会同步移除索引。

## 说明

本项目为完整示例代码，便于直接导入后继续扩展，例如：标签、置顶、导出、导入和主题切换等。
