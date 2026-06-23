# HarmonyMind

HarmonyMind 是一个基于 HarmonyOS ArkTS 的本地脑图应用，支持创建、搜索、编辑与删除脑图，并提供画布拖拽、缩放、节点编辑和颜色标记能力。

## 功能

- 首页脑图卡片列表
- 按标题搜索脑图
- 新建与删除脑图
- 左到右树形脑图编辑
- 节点新增、编辑、删除、颜色切换
- 画布平移与缩放
- 主题切换
- 本地持久化保存

## 目录结构

- `AppScope/`：应用级配置与资源
- `entry/src/main/ets/pages/`：页面
- `entry/src/main/ets/components/`：组件
- `entry/src/main/ets/models/`：数据模型
- `entry/src/main/ets/utils/`：常量与存储工具

## 存储方案

- Preferences：保存主题设置和脑图元数据列表
- 文件系统：每个脑图独立保存为一个 JSON 文件

## 构建说明

1. 使用 DevEco Studio 打开项目目录
2. 同步 HarmonyOS SDK
3. 选择 `entry` 模块运行到设备或模拟器

## 架构说明

- `HomePage`：脑图列表、搜索、新建、删除
- `EditorPage`：编辑器页面状态与操作编排
- `MindCanvas`：画布绘制、命中测试、拖拽、缩放
- `FileStorage`：本地 Preferences 与 JSON 文件读写

## 说明

- 全部界面文案为中文
- 严格使用 ArkTS V1 装饰器与 `@ohos.*` 导入风格
