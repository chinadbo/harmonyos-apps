# HarmonyPlant

HarmonyPlant 是一个基于 HarmonyOS NEXT API 16 与 ArkTS V1 装饰器体系实现的花草养护 / 植物日记应用。

## 功能

- 植物档案管理：新增、编辑、删除植物
- 养护打卡：浇水、施肥、修剪、换盆记录
- 植物日记：图文记录植物成长
- 到期提醒：基于 reminderAgentManager 的浇水提醒
- 桌面小组件：展示今日待浇水植物（最多 3 株）

## 目录结构

- `AppScope/`：应用级配置与资源
- `entry/src/main/ets/model/`：数据模型
- `entry/src/main/ets/components/`：可复用组件
- `entry/src/main/ets/service/`：数据库、提醒与业务服务
- `entry/src/main/ets/pages/`：业务页面
- `entry/src/main/ets/widget/`：桌面卡片与 FormExtensionAbility

## 关键实现约束

- 统一使用 ArkTS V1 装饰器
- 使用 `@ohos.*` 风格 import
- `relationalStore.getRdbStore(context, config)` 使用 2 参数版本
- `PhotoViewPicker` 使用 `new picker.PhotoViewPicker()`
- `EntryAbility.onCreate` 初始化 `AppStorage.setOrCreate('plantCount', 0)`

## 核心页面

- `pages/Index`：Tab 首页
- `pages/PlantListPage`：植物列表
- `pages/PlantDetailPage`：植物详情与养护记录时间线
- `pages/AddPlantPage`：添加/编辑植物
- `pages/CareLogPage`：养护打卡
- `pages/DiaryListPage`：植物日志列表
- `pages/AddDiaryPage`：写日志
- `pages/RemindersPage`：提醒管理

## Widget

- 默认尺寸：2×2
- 可选尺寸：2×4
- 展示今日待浇水植物名称

## 数据存储

应用通过 RelationalStore 在本地创建以下表：

- `plants`
- `care_records`
- `plant_diary`

照片仅保存系统照片选择器返回的 `datashare://` URI，不拷贝原始文件。
