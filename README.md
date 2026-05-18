# Harmony Express

一个基于 HarmonyOS NEXT / ArkTS 的快递追踪演示应用，支持新增快递、查看在途列表、查看物流时间线、已签收归档和状态更新通知。

## 功能概览

- 新增快递单号并自动识别快递公司
- 优先读取 `rawfile/mock_data.json` 中的预置物流数据
- 未命中预置数据时自动生成随机运输轨迹
- 使用 relationalStore 持久化包裹信息和时间线事件
- 首页查看在途包裹，历史页查看已签收归档
- 详情页支持刷新轨迹，并在状态变化时发送本地通知
- 提供基础 FormExtensionAbility 服务卡片配置

## 项目结构

```text
AppScope/
entry/src/main/ets/
├── components/
├── entryability/
├── entryformability/
├── model/
├── pages/
├── service/
├── utils/
└── views/
entry/src/main/resources/
├── base/profile/
└── rawfile/
```

## 技术选型

- UI：ArkTS V1 装饰器（`@Component` / `@State` / `@Prop` / `@Link` / `@Provide` / `@Consume`）
- 导入风格：统一 `@ohos.*`
- 导航：`Index.ets` 中创建 `NavPathStack` 并向下传递，子页面通过 `@Consume('navStack')` 触发导航
- 数据持久化：`@ohos.data.relationalStore`
- 通知：`@ohos.notificationManager`
- Mock 查询：读取 `entry/src/main/resources/rawfile/mock_data.json`

## 主要页面

当前源码已按要求创建全部页面文件，并以 `NavPathStack` 为核心维持页面跳转状态；若在 DevEco Studio 中接入更完整的路由映射，可在此基础上继续增强多目标路由注册。


- `HomeIndex.ets`：在途列表
- `AddPackage.ets`：添加快递表单
- `TrackingDetail.ets`：物流详情与时间线
- `HistoryList.ets`：已签收归档
- `SettingsPage.ets`：通知开关与说明

## 构建方式

1. 使用 DevEco Studio 打开项目根目录。
2. 确保本地 HarmonyOS NEXT SDK 与签名配置可用。
3. 选择 `entry` 模块并执行构建 / 运行。

## Mock 数据说明

`mock_data.json` 当前内置三条演示数据：

- `SF1234567890`
- `JDVA12345678901`
- `YT202605190001`

可按如下结构扩展：

```json
{
  "TRACKING_NO": {
    "courierCode": "SF",
    "courierName": "顺丰速运",
    "status": 3,
    "events": [
      {
        "time": "2026-05-19 09:18",
        "location": "深圳市南山区",
        "description": "快件已签收",
        "eventType": "SIGNED"
      }
    ]
  }
}
```

## 后续可扩展方向

- 接入真实快递查询 API
- 添加网络状态检测与失败重试
- 增加服务卡片实时刷新逻辑
- 引入自定义 `IDataSource` 以支持更复杂的大列表优化
