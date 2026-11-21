# HarmonyMama 孕期伴侣

准妈妈孕期全程管理应用：孕周追踪、胎动计数、产检管理、体重监控。纯离线运行，数据仅存储在本机。

- **Bundle Name**：`com.chinadbo.harmonymama`
- **版本**：1.0.0（versionCode 1）
- **平台**：HarmonyOS（Stage 模型），支持 phone / tablet
- **隐私**：无网络权限，不采集、不上传任何数据

## 功能

| 模块 | 功能 |
| --- | --- |
| 首页 | 孕周大卡片（孕周+天、孕期阶段、距预产期倒计时）、本周胎儿发育提示、未完成产检待办 |
| 胎动 | 开始/结束计数会话（计时）、大按钮点击计数、会话列表、今日汇总；1 小时不足 3 次给出就医提示 |
| 产检 | 月历标记产检日、待办/已完成列表、添加产检（名称/日期/备注）、标记完成、内置 12 次常规产检模板一键导入 |
| 体重 | Canvas 折线图（实测曲线 + 参考区间带）、添加记录（日期/体重）、历史列表、删除 |
| 我的 | 预产期设置（末次月经日期或直接输入预产期）、数据统计、隐私声明展示 |

孕周计算：以预产期 280 天为基准，展示孕周 + 天，并划分早孕（<14 周）、中孕（14~27 周）、晚孕（≥28 周）阶段。

## 架构

```
HarmonyMama/
├── AppScope/
│   ├── app.json5                       # 应用级配置（bundleName/版本/图标/名称）
│   └── resources/base/
│       ├── element/string.json         # app_name
│       └── media/                      # 分层应用图标
├── entry/
│   ├── build-profile.json5
│   ├── hvigorfile.ts
│   ├── oh-package.json5
│   └── src/main/
│       ├── module.json5                # EntryAbility、requestPermissions: []
│       ├── ets/
│       │   ├── entryability/EntryAbility.ets
│       │   ├── pages/Index.ets         # Tabs：首页/胎动/产检/体重/我的
│       │   ├── components/             # WeekCard、CalendarView、LineChart
│       │   ├── model/                  # CheckupItem、WeightRecord、KickSession、WeeklyInfo
│       │   ├── database/DbHelper.ets   # RDB 三表 + profile KV
│       │   ├── utils/                  # PregnancyCalc、NotifyUtil
│       │   └── data/WeeklyKnowledge.ets# 40 周内置发育知识
│       └── resources/
│           ├── base/
│           │   ├── element/            # string.json、color.json（主色 #E91E63）
│           │   ├── media/              # 图标、启动图标
│           │   └── profile/main_pages.json
│           └── rawfile/privacy_statement.json
├── build-profile.json5                 # 产品与模块构建配置
├── oh-package.json5
├── hvigorfile.ts
└── hvigor/hvigor-config.json5
```

### 数据层

- **RDB**（`@ohos.data.relationalStore`）：`checkup` 产检表、`weight` 体重表、`kick_session` 胎动会话表。
- **Preferences**：以 profile KV 形式保存末次月经日期/预产期。
- **通知**（`@ohos.notificationManager`）：`requestEnableNotification` 后 `publish`，用于产检当日提醒。
- **知识数据**：`data/WeeklyKnowledge.ets` 内置 40 周胎儿发育文案，无需联网。

### 编码规范

- 统一使用 ArkTS **V1** 状态管理：`@Component` + `@State/@Prop/@Link/@StorageProp/@StorageLink`。
- 禁止 `@ComponentV2`、`@ObservedV2`、`@Trace`、`@Param`、`@Local`、`@Monitor`、`@Computed`，不混用 V1/V2。
- 统一 `@ohos.*` 导入风格，不使用 `@kit.*`。
- 权限最小化：`requestPermissions` 为空数组，无网络、无媒体、无位置权限。

## 构建与运行

### 环境要求

- DevEco Studio 5.0.0 及以上（HarmonyOS NEXT）
- HarmonyOS SDK API 12（`compatibleSdkVersion: 5.0.0(12)`）
- ohpm / hvigor 随 DevEco Studio 提供

### 步骤

1. 用 DevEco Studio 打开项目根目录，等待工程同步（或执行 `ohpm install`）。
2. 在 **File > Project Structure > Signing Configs** 中配置自动签名。
3. 启动模拟器或连接真机，点击 Run。

命令行构建（需已配置 `hvigorw` 与签名）：

```bash
ohpm install
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

产物位于 `entry/build/default/outputs/default/`。

## 隐私声明

完整内容见 `entry/src/main/resources/rawfile/privacy_statement.json`：应用不申请任何权限、不联网，产检/体重/胎动/孕期档案全部仅保存在设备本地的 RDB 与 Preferences 中，卸载或清除应用数据即可彻底删除。

## 项目状态

当前阶段：项目骨架（应用配置、模块配置、入口 Ability、构建脚本、基础资源、隐私声明）。业务页面与数据层按批次实现。
