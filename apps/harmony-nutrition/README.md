# HarmonyNutrition

HarmonyNutrition 是一个基于 HarmonyOS ArkTS（V1 装饰器）编写的营养追踪示例应用，包含首页总览、食物搜索、历史记录、统计页、设置页、表单卡片能力以及示例食物数据库。

## 目录结构

- `build-profile.json5`
- `oh-package.json5`
- `AppScope/`
- `entry/`
  - `src/main/ets/model/`
  - `src/main/ets/database/`
  - `src/main/ets/service/`
  - `src/main/ets/components/`
  - `src/main/ets/pages/`
  - `src/main/ets/entryability/`
  - `src/main/ets/formability/`
  - `src/main/resources/rawfile/foods.json`
- `privacy_statement.json`

## 功能说明

1. 首页展示当日热量环图、宏量营养分布、早餐/午餐/晚餐/加餐分组。
2. 支持手动新增食物记录。
3. 食物搜索页可按名称或类别检索内置食物数据。
4. 历史页展示日期、总热量和宏量营养汇总。
5. 统计页展示平均热量和 7 日趋势。
6. 设置页展示用户档案与提醒开关。
7. `foods.json` 内含 50 条基础食物营养数据。

## 说明

- 当前实现以本地内存数据结构模拟数据库访问。
- 通知服务与表单能力提供了演示级实现，便于后续接入真实系统能力。
- 所有 ETS 页面与组件均使用 V1 装饰器写法。

## 后续建议

1. 将 `DatabaseHelper` 替换为 Preferences 或 RDB 持久化。
2. 将 `FoodDatabase` 改为读取 `rawfile/foods.json` 实际内容。
3. 为食物新增图片、份量单位换算和扫码录入。
4. 为图表组件接入真实 Canvas 绘制。
