# HarmonyBaby · 鸿蒙婴儿日常记录

一款纯本地、0 权限的 HarmonyOS（ArkTS）婴儿日常记录应用：喂养、换尿布、睡眠、成长、月历回顾一站式记录，帮助新手爸妈轻松掌握宝宝的一天。

## 功能说明

| Tab | 页面 | 功能 |
| --- | --- | --- |
| 今日 | `Index` | 今日看板：宝宝档案卡（姓名/性别/出生日期/月龄）、喂养次数、奶量、尿布、睡眠时长四格统计、近 7 天喂养柱状图、今日动态时间线、睡眠中提醒 |
| 喂养 | `FeedPage` | 母乳左右侧独立计时卡（计时满 5 秒才入库，误触可取消）、奶瓶毫升滑杆 + 快捷奶量、辅食打卡（食物 + 份量备注）、今日喂养列表（可删除） |
| 尿布 | `DiaperPage` | 小便/大便/混合/干爽四类状态、备注、今日统计（次数/湿/便）、今日列表（可删除） |
| 睡眠 | `SleepPage` | 入睡/醒来打卡自动计算时长、睡眠质量（睡得香/一般/易醒）、实时计时显示、今日总睡眠/次数/最长一觉、睡眠列表（可删除） |
| 成长 | `GrowthPage` | 体重/身高/头围测量录入、Canvas 平滑成长曲线（体重 + 身高两条）、较上次趋势提示、测量记录列表（可删除） |
| 月历 | `HistoryPage` | Canvas 月历热力视图（颜色深浅 = 当天记录条数，支持点击选日）、月份切换、当月汇总、选中日期四类记录明细（可删除） |

## 架构

```
HarmonyBaby/
├── AppScope/                     应用级配置与资源
│   ├── app.json5
│   └── resources/base/            (element/string.json, media/app_icon.png)
├── build-profile.json5            构建配置
├── oh-package.json5               项目级依赖
├── hvigorfile.ts                  构建脚本
├── hvigor/hvigor-config.json5
├── privacy_statement.json         隐私声明（0 权限 / 纯本地数据）
└── entry/
    ├── hvigorfile.ts
    ├── oh-package.json5
    └── src/main/
        ├── module.json5           0 权限，requestPermissions: []
        ├── resources/base/
        │   ├── element/           (string.json, color.json)
        │   ├── media/icon.png
        │   └── profile/main_pages.json
        └── ets/
            ├── entryability/EntryAbility.ets   UIAbility 入口，初始化 DB 与档案
            ├── pages/                          6 个页面
            │   ├── Index.ets                   今日看板 + Tab 容器（@Entry）
            │   ├── FeedPage.ets                喂养
            │   ├── DiaperPage.ets              换尿布
            │   ├── SleepPage.ets               睡眠打卡
            │   ├── GrowthPage.ets              成长记录
            │   └── HistoryPage.ets            月历热力
            ├── components/                     4 个公共组件
            │   ├── NursingTimerCard.ets        母乳计时卡（左右侧）
            │   ├── StatChart.ets               统计图表（Canvas 柱状/平滑曲线）
            │   ├── RecordCard.ets              通用记录卡片
            │   └── CalendarHeat.ets            月历热力图（Canvas + 点击选日）
            ├── database/
            │   ├── DatabaseHelper.ets           RDB 单例：feeds/diapers/sleeps/growth
            │   └── BabyProfileStore.ets         Preferences：宝宝档案
            ├── model/Models.ets                 数据模型 / 枚举 / 记录合并展示
            └── utils/                           TimeUtils(毫秒时间戳) / Theme
```

### 数据设计

- RDB 表（`harmonybaby.db`，S1 安全等级）：

| 表 | 字段 | 说明 |
| --- | --- | --- |
| `feeds` | id, type(nursing_left/nursing_right/bottle/solid), amount, duration, note, startTime, endTime | 喂养 |
| `diapers` | id, type(wet/dirty/mixed/dry), note, changeTime | 换尿布 |
| `sleeps` | id, startTime, endTime(0=进行中), quality, note | 睡眠（时长自动计算） |
| `growth` | id, measureTime, weight, height, headCirc, note | 成长 |

- 宝宝档案（Preferences `baby_profile`）：`name` / `birthday`(毫秒) / `gender`，同步到 AppStorage 供各页面读取。
- 所有时间字段统一为毫秒时间戳（Number）。
- 跨页联动：任何写操作后 `AppStorage.dataVersion++`，各页面通过 `@StorageLink + @Watch` 自动刷新。

## 编码规范遵循

- 状态管理：V1 装饰器体系（`@Entry/@Component/@State/@Prop/@Watch/@StorageLink/@StorageProp`），未使用任何 V2 装饰器。
- Import：统一 `@ohos.*` 风格（`@ohos.data.relationalStore`、`@ohos.data.preferences`、`@ohos.window`、`@ohos.hilog`、`@ohos.app.ability.*`）。
- Canvas：`StatChart` / `CalendarHeat` 均在 `onReady` 回调中首次绘制，数据更新时通过 `@Watch` 重绘。
- 权限：0 权限，`requestPermissions` 为空数组，无网络、无任何敏感权限。

## 构建方式

1. 使用 DevEco Studio（配套 HarmonyOS SDK，API 12 / 5.0.0(12) 及以上）打开本工程目录。
2. 执行 `File > Sync and Refresh Project` 同步 hvigor 依赖。
3. 连接鸿蒙设备或启动模拟器，点击 `Run 'entry'` 即可安装运行（调试签名由 IDE 自动生成）。
4. 命令行构建：`hvigorw assembleHap --mode module -p product=default`，产物位于 `entry/build/default/outputs/default/`。

无任何第三方依赖，无需额外签名配置即可调试运行。
