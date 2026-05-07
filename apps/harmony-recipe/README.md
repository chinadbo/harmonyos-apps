# HarmonyRecipe

HarmonyRecipe 是一个基于 HarmonyOS 5.0 / API 12 的食谱菜谱管理 App，包含菜谱发现、收藏、全文搜索、烹饪计时与 2x2 今日推荐服务卡片。

## 功能特性

- 发现页：2 列 Grid 展示预置菜谱，支持分类筛选
- 收藏页：本地持久化收藏状态
- 搜索页：基于 RDB + FTS5 的菜谱全文搜索
- 菜谱详情：展示食材、步骤与做法信息
- 烹饪计时器：按步骤倒计时，结束后触发本地提醒
- 首次启动导入 20 道家常菜预置数据
- 服务卡片：2x2 今日推荐菜谱小组件

## 项目结构

- `AppScope/`：应用级配置与资源
- `entry/`：主模块，包含页面、组件、模型与服务
- `widget/`：服务卡片模块
- `privacy_statement.json`：隐私声明
- `build-profile.json5` / `oh-package.json5`：工程配置

## 核心架构

### 数据层
- `entry/src/main/ets/service/DatabaseService.ts`
  - 单例封装 RDB Store
  - 建立 `recipes` 主表与 `recipes_fts` FTS5 虚表
  - 提供列表、详情、收藏、搜索等数据接口

### 数据源层
- `entry/src/main/ets/model/RecipeDataSource.ts`
  - 自实现 `IDataSource`
  - 为 `LazyForEach` 提供可刷新的列表数据

### 业务服务层
- `entry/src/main/ets/service/PresetDataService.ts`
  - 首次启动导入 `recipes.json` 预置数据
- `entry/src/main/ets/service/NotificationService.ts`
  - 封装通知权限与 `reminderAgentManager` 计时提醒

### UI 层
- `Index.ets`：发现 / 收藏 / 我的三栏 Tabs
- `RecipeDetail.ets`：菜谱详情
- `SearchPage.ets`：全文搜索
- `CookingTimer.ets`：步骤倒计时
- `RecipeCard.ets` / `CategoryFilter.ets` / `StarButton.ets`：复用组件

## 构建说明

1. 使用 DevEco Studio 打开项目目录
2. 确认 SDK 为 HarmonyOS 5.0，目标 API 为 12
3. 连接设备或启动模拟器
4. 运行 `entry` 模块进行主应用调试
5. 将 `widget` 模块随工程一起构建，以启用服务卡片

## 隐私与权限

- 仅声明 `ohos.permission.NOTIFICATION`
- 收藏、检索索引与预置菜谱全部保存在本地数据库中
- 不依赖网络服务，不上传用户数据
