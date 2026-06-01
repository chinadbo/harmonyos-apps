# HarmonyPack

HarmonyPack 是一个面向 HarmonyOS NEXT（API 16）的旅行打包清单 / 行李管理应用，帮助用户管理行程、快速套用打包模板、查看打包完成度，并通过桌面卡片与出发提醒减少漏带。

## 功能概览

- 行程管理：新建、编辑、删除旅行行程，并按状态分组展示。
- 打包清单：为每个行程维护物品列表，按分类折叠展示，支持勾选进度。
- 模板中心：提供商务出差、休闲度假、海外游、背包客 4 个内置模板，并支持自定义模板扩展。
- 提醒服务：出发前 24 小时和 2 小时自动创建系统提醒。
- 桌面卡片：2*2 和 4*2 两种尺寸，展示最近行程与打包进度。
- 统计分析：查看近 6 次出行完成率趋势、常漏带物品 Top5、本月出行次数。

## 项目结构

```text
AppScope/
entry/src/main/
├── ets/
│   ├── entryability/
│   ├── formability/
│   ├── pages/
│   ├── components/
│   ├── model/
│   ├── database/
│   ├── service/
│   └── widget/pages/
└── resources/
```

## 技术实现

- ArkTS V1 装饰器体系：仅使用 `@Component`、`@State`、`@Prop`、`@Provide`、`@Consume`。
- `@ohos.*` 风格系统模块导入。
- `relationalStore` 本地数据库保存行程、物品与模板。
- `reminderAgentManager` 创建系统提醒。
- `FormExtensionAbility` + ArkTS Widget 提供桌面卡片。
- `CanvasRenderingContext2D` 绘制进度圆环和统计折线图。

## 构建说明

1. 使用 DevEco Studio 打开本工程目录。
2. 安装 HarmonyOS NEXT API 16 SDK。
3. 配置签名信息后执行构建。
4. 运行 `entry` 模块到支持 HarmonyOS NEXT 的设备或模拟器。

## 数据说明

- 所有业务数据默认保存在本地数据库 `harmonypack.db`。
- 内置模板定义于 `entry/src/main/resources/rawfile/templates.json`。
- 应用不依赖网络，不会将用户行程或清单上传到外部服务。
