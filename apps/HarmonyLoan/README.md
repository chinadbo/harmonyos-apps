# HarmonyLoan · 鸿蒙房贷计算器

基于 HarmonyOS ArkTS（Stage 模型，API 12，V1 装饰器体系）的纯本地房贷计算器。所有计算在设备端完成，零敏感权限、零网络请求。

## 功能

- **首页实时试算**：贷款金额、年限、利率（LPR + 基点 / 直接输入）、贷款类型（商业 / 公积金 / 组合）、还款方式（等额本息 / 等额本金），任意输入变化即时刷新月供、总利息与本息占比。
- **还款方式对比**：等额本息 vs 等额本金的月供、总利息、逐月本金/利息明细对比，Canvas 逐年曲线。
- **还款计划**：逐月还款表（期数 / 月供 / 本金 / 利息 / 剩余本金），`LazyForEach` + 自实现 `IDataSource`。
- **提前还款试算**：输入提前还款金额与时点，选择「缩短年限」或「减少月供」，输出新计划与节省利息。
- **历史方案**：RDB 本地保存方案，多选对比（自动标记利息最低方案）、单条/批量删除。
- **Canvas 图表**：本息占比环形图（RatioPie）与逐年本金/利息曲线（CurveChart）。

## 架构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets   # 入口，初始化 Preferences，加载首页
├── model/
│   ├── LoanTypes.ets               # LoanInput / PaymentRow / LoanPlan / PrepayResult
│   └── LoanCalculator.ets          # 纯函数计算引擎（金额以“分”为整数运算）
├── service/
│   ├── PlanService.ets             # relationalStore：plans 表 CRUD
│   └── PrefsService.ets            # Preferences：lpr_bp / gjj_rate_bp / last_input
├── views/
│   ├── Index.ets                   # 首页表单 + 实时结果
│   ├── ComparePage.ets             # 两种还款方式对比
│   ├── SchedulePage.ets            # 逐月还款计划
│   ├── PrepayPage.ets              # 提前还款试算
│   └── HistoryPage.ets             # 历史方案列表 / 多选对比 / 删除
└── components/
    ├── ResultCard.ets              # 月供 / 总利息 / 总额结果卡
    ├── CurveChart.ets              # Canvas 逐年曲线
    └── RatioPie.ets                # Canvas 本息占比环形图
```

## 计算引擎

- 金额单位统一为「分」（number 整数），仅在展示时转换为元；避免浮点累计误差。
- **等额本息**：月利率 `r = 年利率 / 12`，月供 `M = P·r·(1+r)^n / ((1+r)^n − 1)`；逐期利息 `round(剩余本金·r)`，本金 = 月供 − 利息，尾差归入最后一期。
- **等额本金**：月本金 `floor(P/n)`，尾差摊入首期，利息 `round(剩余本金·r)`。
- **提前还款**：第 m 期后偿还本金 B：
  - 缩期：月供不变，反推可覆盖的新期数 `n' = ceil(ln(M/(M−P'·r)) / ln(1+r))`；
  - 减月供：剩余期数不变，按剩余本金重算月供。
  - 节省利息 = 原总利息 − 已付利息 − 新方案总利息。
- **组合贷**：商贷与公积金分别计算后按期合并展示。

## 存储

- RDB（`relationalStore`，数据库 `loan.db`）：
  `plans(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, input TEXT, monthly INTEGER, total_interest INTEGER, created_at INTEGER)`
- Preferences（`loan_prefs`）：`lpr_bp`（默认 350）、`gjj_rate_bp`（默认 285）、`last_input`（上次输入 JSON）。

## 权限与隐私

- `module.json5` 不声明 `requestPermissions`，不申请任何 `ohos.permission`。
- 无网络请求，RDB / Preferences 均位于应用沙箱内。
- 详见根目录 `privacy_statement.json`。

## 构建

1. 使用 DevEco Studio（HarmonyOS NEXT / API 12+）打开项目根目录。
2. 执行 `ohpm install`（项目无第三方运行时依赖）。
3. 配置签名后，选择 `entry` 模块运行到真机或模拟器。
4. 命令行构建：`hvigorw assembleHap`。

## 编码约束

- 统一 V1 装饰器（`@Component` + `@State/@Prop/@Link`），未使用任何 V2 装饰器。
- 统一 `@ohos.*` 风格 import，未使用 `@kit.*`。
- Canvas 使用 ArkUI 内置 `Canvas` + `CanvasRenderingContext2D`。
- 计划表数据源为自实现 `IDataSource`（`BasicDataSource` 并非框架内置类）。
