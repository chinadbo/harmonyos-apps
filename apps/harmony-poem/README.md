# HarmonyPoem

HarmonyPoem 是一个基于 HarmonyOS ArkUI（V1 装饰器体系）实现的古诗词赏析原生应用，提供每日一诗、分类探索、全文搜索、详情赏析、收藏与阅读记录能力。

## 功能特性

- 首页：底部 Tabs 导航 + 每日一诗推荐
- 探索：按朝代 / 作者 / 体裁分类浏览
- 搜索：支持标题、作者、内容、标签检索
- 详情：全文、注释、赏析、收藏、朗读按钮 UI
- 收藏：基于 RDB 存储收藏列表并支持删除
- 数据：内置 rawfile/poems.json，包含 30 首经典古诗词

## 项目结构

```text
AppScope/
entry/src/main/ets/
  ├── entryability/
  ├── pages/
  ├── components/
  ├── model/
  ├── database/
  ├── service/
  └── datasource/
entry/src/main/resources/base/
  ├── element/
  ├── profile/
  └── rawfile/
```

## 技术说明

- UI：ArkUI V1（@Component + @State/@Prop）
- 数据读取：`context.resourceManager.getRawFileContent('poems.json')`
- 每日一诗：基于 `dayOfYear % poems.length` 的确定性算法
- 数据库：`@ohos.data.relationalStore`
- 页面路由：`@ohos.router`

## 构建方式

1. 使用 DevEco Studio 打开 `harmony-poem` 工程目录。
2. 选择 HarmonyOS SDK 并同步工程配置。
3. 编译并运行 `entry` 模块到模拟器或真机。

## 注意事项

- 全项目遵循 `@ohos.*` import 风格。
- 全项目使用 ArkUI V1 装饰器体系，未使用 V2。
- 收藏与阅读历史均保存在本地，不涉及网络权限。
