# HarmonySolar · 二十四节气

一个完全离线的 HarmonyOS ArkTS 应用，以二十四节气为主线，提供节气进度环、节气时间轴、节气详情、农历公历换算、节气提醒与收藏功能。所有数据内置，无网络请求，无敏感权限。

## 功能说明

| 模块 | 说明 |
| --- | --- |
| 首页 HomeView | Canvas 2D 绘制的节气进度环（当前节气行进进度、四季刻度、24 节气刻度），展示当前节气三候、宜忌、下一节气预告与应节诗词 |
| 节气轴 TimelineView | 按年份、四季分组的节气长列表，使用 LazyForEach 按需渲染，可快速跳转任意节气详情 |
| 节气详情 TermDetailView | 节气简介、三候、民俗、养生、诗词、宜忌，支持收藏 / 取消收藏 |
| 历法换算 LunarConvertView | 公历 → 农历（干支、生肖、星期）与农历 → 公历双向换算，支持 1901—2099 年及闰月 |
| 节气提醒 RemindView | 本地通知开关与提醒时机（当天 / 提前 1 天 / 提前 3 天），应用启动时检查节气日并发送本地通知，可发送测试通知 |
| 我的收藏 FavoritesView | 收藏节气列表，展示交节时刻与收藏日期，可打开详情或移除收藏 |
| Index 容器 | Tabs 四页导航（今日 / 节气轴 / 换算 / 我的），详情页以覆盖层方式呈现 |

- 首页在应用启动时载入当日节气、进度与农历信息。
- 收藏状态通过 AppStorage 版本号在详情页、收藏页之间实时同步。
- 所有交节时刻、三候、民俗、养生、诗词、宜忌均来自内置数据，离线可查。

## 架构设计

```
HarmonySolar/
├── AppScope/                          # 应用级配置与图标
│   ├── app.json5                      # bundleName / 版本 / 图标 / 名称
│   └── resources/
├── entry/                             # 主模块
│   ├── build-profile.json5
│   ├── oh-package.json5
│   └── src/main/
│       ├── module.json5               # UIAbility 配置，无敏感权限
│       ├── ets/
│       │   ├── entryability/
│       │   │   └── EntryAbility.ets   # 启动时初始化节气数据、恢复提醒状态
│       │   ├── model/
│       │   │   ├── SolarTerm.ets      # 节气数据模型与空对象工厂
│       │   │   ├── LunarDate.ets      # 农历日期 / 月选项 / 公历结果模型
│       │   │   └── Favorite.ets       # 收藏记录与展示项模型
│       │   ├── engine/
│       │   │   ├── LunarCalendar.ets  # 纯 ArkTS 农历算法（1900—2100 历表）
│       │   │   └── SolarTermData.ets  # 读取 rawfile/terms.json，提供查询接口
│       │   ├── common/
│       │   │   ├── Constants.ets      # 配色 Palette 与工具方法 Utils
│       │   │   ├── DbHelper.ets       # relationalStore 收藏表、Preferences 提醒设置
│       │   │   └── ReminderService.ets# 通知权限、本地通知发布与节气日检查
│       │   ├── components/
│       │   │   ├── SolarRing.ets      # Canvas 环形进度组件
│       │   │   ├── TermCard.ets       # 节气卡片
│       │   │   └── SeasonHeader.ets   # 季节分组头
│       │   ├── views/
│       │   │   ├── HomeView.ets
│       │   │   ├── TimelineView.ets
│       │   │   ├── TermDetailView.ets
│       │   │   ├── LunarConvertView.ets
│       │   │   ├── RemindView.ets
│       │   │   └── FavoritesView.ets
│       │   └── pages/
│       │       └── Index.ets          # @Entry，Tabs 容器与详情覆盖层
│       └── resources/
│           ├── base/element/          # 字符串、颜色
│           ├── base/profile/main_pages.json
│           └── rawfile/
│               ├── terms.json         # 2026—2027 二十四节气数据
│               └── privacy_statement.json
├── build-profile.json5                # API 16 / 5.0.4(16)
├── oh-package.json5
├── hvigorfile.ts
├── privacy_statement.json
└── README.md
```

### 数据流

1. `EntryAbility.onCreate` 与 `Index.aboutToAppear` 调用 `SolarTermData.init(context)`，通过 `resourceManager.getRawFileContent('terms.json')` 读取内置数据，构建按时间排序的节气列表与 id / 名称索引。
2. 各视图通过 `SolarTermData` 的查询接口（`getAll` / `getByYear` / `getById` / `getNext` / `getProgress` 等）获取数据。
3. 收藏写入 `relationalStore`（`favorites` 表，term_id 主键 + saved_at），提醒设置写入 `Preferences`。
4. 收藏变更通过 `AppStorage` 的 `favVersion` 版本号通知收藏页与详情页刷新。

## 数据与算法

### 二十四节气数据

`entry/src/main/resources/rawfile/terms.json` 内置：

- 2026—2027 两个年度共 48 条节气交节时刻（精确到分钟）；
- 24 个节气详条目：简介、三候、民俗、养生、诗词（标题 / 作者 / 正文）、宜、忌。

`SolarTermData` 解析后生成 `SolarTerm` 模型，id 采用「年份-节气名」形式，保证跨年同名的节气可区分。

### 农历算法

`engine/LunarCalendar.ets` 为纯 ArkTS 实现，无第三方依赖：

- 1900—2100 年农历历表（闰月月份、大小月、闰月天数）；
- 公历 ↔ 农历双向换算，支持闰月；
- 年、月、日天干地支推算，年干支与生肖；
- 农历月选项（含「闰 X 月」标注）与当月天数查询。

应用内可换算范围为 1901—2099 年，与日期选择器范围一致。

## 技术要点

- **状态管理**：统一使用 V1 装饰器（`@Component`、`@State`、`@Prop`、`@StorageLink`、`@Watch`、`@Builder`），未引入任何 V2 装饰器。
- **模块导入**：统一使用 `@ohos.*` 风格（如 `@ohos.data.relationalStore`、`@ohos.notificationManager`），未使用 `@kit.*`。
- **列表渲染**：`TimelineView` 自行实现 `IDataSource` 与 `DataChangeListener`，配合 `LazyForEach` 按需渲染。
- **Canvas 绘制**：`SolarRing` 使用 `RenderingContextSettings(true)` + `CanvasRenderingContext2D`，在 `onReady` 后绘制刻度、四季标记、轨道与渐变进度弧。
- **权限最小化**：`module.json5` 不声明任何权限；通知权限在用户开启提醒时通过 `notificationManager.requestEnableNotification(context)` 运行时申请，拒绝后自动回退开关状态。
- **离线优先**：无网络请求、无位置读取、无三方 SDK。

## 构建方式

### 环境要求

- DevEco Studio 5.0.4 Release 及以上；
- HarmonyOS SDK API 16（5.0.4(16)）；
- 工程使用 Stage 模型，`compatibleSdkVersion` / `targetSdkVersion` 均为 `5.0.4(16)`。

### DevEco Studio

1. 使用 DevEco Studio 打开工程根目录；
2. 等待 `hvigor` 同步完成（无需额外依赖安装）；
3. 选择真机或模拟器，点击 Run 运行 `entry` 模块。

### 命令行（hvigor）

```bash
# 安装依赖（工程无三方依赖，仅初始化）
ohpm install

# 构建 HAP
hvigorw assembleHap --mode module -p product=default -p module=entry@default -p buildMode=debug --no-daemon

# 产物位置
entry/build/default/outputs/default/entry-default-signed.hap
```

> 若使用 DevEco Studio 自带工具链，可直接在 IDE 的 Build 菜单执行 Build Hap(s) / Build App(s)。

## 隐私说明

本应用完全离线运行：

- 不收集、不上传任何个人数据；
- 不申请定位、通讯录、相册、麦克风等敏感权限；
- 收藏与提醒设置仅保存在设备本地（RDB / Preferences）；
- 通知为本地通知，不依赖网络推送。

完整声明见根目录 `privacy_statement.json` 与 `entry/src/main/resources/rawfile/privacy_statement.json`。

## 说明

内置节气交节时刻为 2026—2027 年数据，内容仅供传统文化参考。农历换算覆盖 1901—2099 年。
