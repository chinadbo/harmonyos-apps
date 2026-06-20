# HarmonyWord

HarmonyWord 是一个基于 HarmonyOS 的中文词典与汉字学习应用，提供词语查询、成语学习、收藏分组、历史记录与汉字笔顺演示功能。

## 功能说明
- 首页实时搜索词语与成语
- 今日推荐词展示，并在应用启动时发送通知
- 词条详情展示拼音、释义、例句、近义词、反义词
- Canvas 笔顺动画演示常见汉字逐笔描绘
- 收藏页支持按默认/生僻字/成语分组筛选
- 历史页展示最近 50 条查询记录
- 成语页支持搜索与 AlphabetIndexer 索引跳转

## 项目架构
- `entry/src/main/ets/pages`：页面层
- `entry/src/main/ets/components`：通用 UI 组件
- `entry/src/main/ets/database`：RDB 初始化与 DAO
- `entry/src/main/ets/service`：搜索与通知服务
- `entry/src/main/ets/model`：数据模型
- `entry/src/main/ets/utils`：工具函数

## 技术点
- ArkUI V1 装饰器体系
- `@ohos.data.rdb` 本地数据库
- `@ohos.notification` 启动通知
- `CanvasRenderingContext2D` 汉字笔顺动画
- `AlphabetIndexer` 成语索引

## 构建方式
1. 使用 DevEco Studio 打开项目目录 `harmony-word`
2. 确认 SDK 目标版本为 API 11
3. 连接 HarmonyOS 模拟器或真机
4. 执行构建并运行 `entry` 模块

## 数据说明
词库与成语数据内嵌在 `DatabaseHelper.ets` 中，首次启动时自动写入本地数据库，不依赖网络。
