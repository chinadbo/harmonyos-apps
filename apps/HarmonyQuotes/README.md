# HarmonyQuotes 行情助手

基于 HarmonyOS ArkTS（ArkUI V1 装饰器体系）的自选行情应用。行情数据由本地模拟引擎（几何布朗运动）生成，全部数据仅存本地，不上传、不采集个人信息。

## 功能

| 页面 | 功能 |
| --- | --- |
| 首页 Index | 总资产卡片（总市值/总盈亏/当日盈亏）、顶部 3 指数迷你卡、自选列表（名称/代码/现价/涨跌幅/迷你走势线），下拉刷新 + 长按删除 |
| 行情详情 QuoteDetail | Canvas 分时图（240 分钟折线+均价线+昨收基准+渐变填充）与日 K 线图（蜡烛+MA5/MA10+成交量副图，捏合缩放/拖拽平移/点击十字光标）Tab 切换，五档关键指标（开/高/低/量/振幅），价格提醒（高低阈值存 RDB，触发本地通知+震动） |
| 持仓管理 PositionsPage | 持仓列表（成本/现价/收益率/盈亏额），弹窗表单添加/编辑，删除（二次确认） |
| 统计 StatsPage | 总资产收益曲线（Canvas 折线+渐变）、持仓分布条形图、当日涨跌家数与比例条、最佳/最差标的 |
| 添加自选 AddQuotePage | 搜索过滤 32 只内置标的（股票 SH/SZ、基金 OF、指数 IDX），按类型 Tab 过滤，点击添加/移除 |
| 设置 SettingsPage | 涨跌色主题切换（红涨绿跌/绿涨红跌，@StorageLink 全局实时换肤）、提醒开关、清空数据（二次确认） |

首次启动自动预置演示数据：8 个自选 + 3 个指数 + 2 条持仓 + 30 日净值曲线，打开即有内容。

## 架构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets   # UIAbility，编排 AppInit
├── model/                          # 数据模型
│   ├── Quote.ets                   #   Quote/Candle/NavPoint 及涨跌幅计算
│   ├── Position.ets                #   持仓与盈亏计算
│   └── WatchItem.ets               #   自选项
├── db/
│   ├── QuoteDB.ets                 # RDB 封装（watchlist/positions/nav_history 三表）
│   │                               #   初始化失败自动降级内存模式，不崩溃
│   └── DemoData.ets                # 首次启动演示数据种子
├── market/
│   ├── MarketEngine.ets            # 模拟行情引擎（GBM，分钟 tick + 120 日 K 线）
│   ├── CandleGenerator.ets         # 确定性随机序列/K线/分时/净值曲线生成
│   └── MarketSource.ets            # IMarketSource 接口 + MockMarketSource（预留真实 API）
├── chart/
│   ├── CandleChart.ets             # K 线图：缩放/平移/十字光标/成交量副图
│   ├── TimeLineChart.ets           # 分时图：均价线+基准线+渐变填充
│   └── SparkLine.ets               # 卡片迷你走势线
├── components/                     # QuoteCard/IndexBar/PositionCard/NumberRoll/BottomNav
├── common/
│   ├── Theme.ets                   # 涨跌色主题（AppStorage "themeMode" 全局）
│   ├── Fmt.ets                     # 数字格式化
│   ├── Prefs.ets                   # @ohos.data.preferences 封装
│   ├── Notify.ets                  # 本地通知 + 震动
│   ├── AppContext.ets              # Context 持有
│   └── AppInit.ets                 # 初始化编排（引擎→Prefs→RDB→种子数据）
└── pages/                          # 6 个页面（单页导航 router.pushUrl）
```

### RDB 表结构

- `watchlist(id, symbol UNIQUE, name, type, sort, alert_high, alert_low, added_at)`
- `positions(id, symbol UNIQUE, name, type, cost, shares, created_at)`
- `nav_history(id, symbol, date, close, UNIQUE(symbol, date))` — `__TOTAL__` 存总资产净值

### 行情引擎

- 每个标的以 `hash(symbol) ^ 当日日期` 为种子（mulberry32），保证同一天内数据稳定可复现
- 日线：120 根 K 线，`close = prev * exp(σ·z)`（几何布朗运动）
- 分时：240 分钟随机游走，启动时按墙钟时间（9:30-11:30 / 13:00-15:00）定位进度，至少 96 分钟保证首屏有内容
- 刷新：每次 `IMarketSource.getQuotes` 调用推进 1 个 tick，价格微幅随机游走，高低量随之更新

### 技术要点

- V1 装饰器体系：@Component/@State/@Prop/@Link/@StorageProp/@StorageLink，未使用任何 V2 装饰器
- import 统一 @ohos.* 风格（@ohos.data.relationalStore / @ohos.data.preferences / @ohos.router / @ohos.notificationManager / @ohos.vibrator / @ohos.promptAction）
- Canvas 手势按规范使用 GestureGroup(GestureMode.Parallel) 组合 PinchGesture + PanGesture，十字光标用 onClick
- 涨跌色由 Theme.ets 统一提供，themeMode 存 Preferences 并经 @StorageLink 全局同步，切换后卡片/图表/详情即时换肤
- 权限最小化：仅 INTERNET（预留真实行情源）+ VIBRATOR（提醒反馈）

## 构建

1. DevEco Studio 打开工程根目录
2. File → Project Structure → Signing Configs 配置自动签名
3. 点击 Run 或执行 hvigor 构建：

```bash
hvigorw assembleHap --mode module -p product=default
```

产物：`entry/build/default/outputs/default/entry-default-signed.hap`

## 截图

| 首页 | 详情-K线 | 详情-分时 | 持仓 | 统计 | 设置 |
| --- | --- | --- | --- | --- | --- |
| ![Index](docs/screenshot-index.png) | ![K线](docs/screenshot-kline.png) | ![分时](docs/screenshot-timeline.png) | ![持仓](docs/screenshot-positions.png) | ![统计](docs/screenshot-stats.png) | ![设置](docs/screenshot-settings.png) |

（截图待补充）

## 免责声明

行情数据为本地模拟生成，仅供学习演示 ArkTS/Canvas/RDB 等 HarmonyOS 能力，不构成任何投资建议。
