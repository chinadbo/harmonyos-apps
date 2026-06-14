# HarmonyBill

HarmonyBill 是一个基于 HarmonyOS ArkUI（V1 装饰器体系）的多人账单分摊应用，适用于聚餐、旅行、合租等 AA 场景。

## 功能特性

- 创建分摊群组并维护成员列表
- 记录共同消费，支持等额分摊与自定义分摊
- 所有金额以“分”存储，避免浮点误差
- 使用本地 RDB 持久化 5 张表：groups、members、bills、bill_splits、settlements
- 基于贪心算法生成最优还款路径
- 支持标记已还 / 未还
- 使用 Canvas 绘制消费占比饼图
- 全程本地运行，无需任何权限

## 技术栈

- ArkUI V1：`@Component` + `@State/@Prop`
- 路由：`@ohos.router`
- 数据库：`@ohos.data.relationalStore`
- Stage 模型：`UIAbility`

## 目录结构

```text
HarmonyBill/
├── AppScope/
├── entry/
│   └── src/main/
│       ├── ets/
│       │   ├── components/
│       │   ├── database/
│       │   ├── entryability/
│       │   ├── model/
│       │   ├── pages/
│       │   └── utils/
│       └── resources/
├── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```

## 核心数据模型

- Group：分摊群组
- Member：群组成员
- Bill：账单主表
- BillSplit：账单分摊明细
- Settlement：结算路径与还款状态

## 金额规则

- 存储：整数分
- 显示：`(amount / 100).toFixed(2)`
- 输入：`Math.round(parseFloat(input) * 100)`

## 运行说明

1. 使用 DevEco Studio 打开项目根目录。
2. 确保 SDK 版本兼容 HarmonyOS API 12 及以上。
3. 同步依赖并构建 `entry` 模块。
4. 运行到手机或模拟器。

## 页面说明

- `pages/MainPage`：群组列表
- `pages/AddGroupPage`：新建群组
- `pages/GroupDetailPage`：群组详情与账单列表
- `pages/AddBillPage`：新增账单
- `pages/SettlementPage`：结算路径
- `pages/BillDetailPage`：账单详情

## 说明

本项目遵循 `.mc/CONTEXT.md` 约束：

- 仅使用 ArkUI V1 装饰器
- 使用 `@ohos.*` 风格导入
- `requestPermissions: []`
- 删除账单使用 `AlertDialog` 二次确认
- 空列表与空数据状态均提供友好提示
