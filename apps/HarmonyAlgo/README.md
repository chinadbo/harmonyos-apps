# HarmonyAlgo

HarmonyAlgo 是一个基于 HarmonyOS（ArkTS + Stage 模型）的**本地算法刷题与学习** App。内置 6 大分类共 84 道经典算法题，支持分类/难度筛选、搜索、收藏、错题本、学习笔记、代码语法高亮、Canvas 统计图表与每日推荐。

应用**纯本地运行、无任何网络请求、不申请任何权限**，所有数据保存在设备本地关系型数据库（RDB）中。

---

## 功能特性

- **题库浏览**：6 个分类（数组 / 字符串 / 链表与树 / 动态规划 / 贪心与双指针 / 其他经典），支持按分类、难度筛选与关键字搜索。
- **题目详情**：题目标题、难度、分类、题目描述、解题思路，以及 **ArkTS 与 Python 两版参考代码**，切换语言实时渲染。
- **语法高亮**：自研轻量词法分析器，识别关键字 / 字符串 / 注释 / 数字 / 函数名，并通过 `RichText` 混排着色。
- **刷题状态**：可将题目标记为「已做」「已掌握」「记错题」，错题会计入错题本并累计错误次数。
- **收藏**：在详情页点击星标收藏 / 取消收藏。
- **学习笔记**：每道题可记录个人思路、易错点，持久化保存。
- **错题本**：汇集所有未掌握的题目，展示错误次数，方便重点巩固。
- **学习统计**：Canvas 环形进度图展示总体完成度，柱状图展示近 7 日刷题趋势，并给出各分类完成进度。
- **每日推荐**：按日期稳定推荐一道未做题目，支持一键换题与快速跳转。

---

## 技术栈

| 方向 | 选型 |
| --- | --- |
| 语言 / 框架 | ArkTS + ArkUI（**V1 装饰器**：`@Component/@State/@Prop/@Link/@Watch` 等） |
| 应用模型 | Stage 模型 |
| 本地存储 | `@ohos.data.relationalStore`（RDB，4 张表） |
| 页面路由 | `@ohos.router` |
| 图表 | ArkUI `Canvas`（环形进度图 + 柱状图） |
| 代码着色 | 自研 `Tokenizer` + `RichText` |
| 权限 | **无**（纯本地应用，`module.json5` 不申请任何权限） |

> 全部使用 `@ohos.*` 风格的 import，且仅使用 V1 装饰器，未使用任何 V2 装饰器（`@ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed`）。

---

## 项目结构

```
HarmonyAlgo/
├── AppScope/
│   ├── app.json5                       # 应用级配置（bundleName / icon / version）
│   └── resources/base/
│       ├── element/string.json         # app_name、隐私声明文案
│       └── media/app_icon.png          # 应用图标
├── build-profile.json5                 # 工程构建配置
├── oh-package.json5                    # 根依赖
├── hvigorfile.ts
├── hvigor/hvigor-config.json5
└── entry/
    ├── build-profile.json5
    ├── oh-package.json5
    ├── hvigorfile.ts
    └── src/main/
        ├── module.json5                # 模块配置（无 requestPermissions）
        ├── ets/
        │   ├── entryability/
        │   │   └── EntryAbility.ets    # 应用入口：初始化 RDB + 导入题库
        │   ├── model/
        │   │   ├── Problem.ets         # 题目实体 + 难度工具函数
        │   │   ├── Record.ets          # 刷题记录实体 + 状态常量
        │   │   └── Database.ets        # RDB 封装（4 表 CRUD + 统计）
        │   ├── data/
        │   │   └── problemset.ts       # 内置题库（84 题，6 分类）
        │   ├── highlight/
        │   │   ├── Tokenizer.ets       # 轻量词法分析
        │   │   └── CodeView.ets        # 语法高亮渲染组件
        │   ├── components/
        │   │   ├── ProblemCard.ets     # 题目卡片
        │   │   ├── DiffBadge.ets       # 难度徽章
        │   │   ├── CategoryChip.ets    # 分类 / 难度筛选胶囊
        │   │   ├── RingProgress.ets    # Canvas 环形进度
        │   │   ├── BarChart.ets        # Canvas 近 7 日柱状图
        │   │   └── EmptyView.ets       # 空状态
        │   ├── common/
        │   │   ├── Theme.ets           # 全局配色常量
        │   │   └── RouterUtil.ets      # 页面跳转工具
        │   └── pages/
        │       ├── Index.ets           # 首页：Tabs 容器 + 题库浏览
        │       ├── ProblemDetail.ets   # 题目详情（独立路由页）
        │       ├── Favorites.ets       # 收藏 Tab 内容
        │       ├── Mistakes.ets        # 错题 Tab 内容
        │       ├── Stats.ets           # 统计 Tab 内容
        │       └── Daily.ets           # 每日 Tab 内容
        └── resources/
            ├── base/
            │   ├── element/{string,color}.json
            │   ├── media/{app_icon,startIcon}.png
            │   └── profile/main_pages.json
            └── dark/element/color.json
```

底部导航使用单个 `Tabs` 组件承载 5 个 Tab：题库 / 收藏 / 错题 / 统计 / 每日；题目详情通过 `router.pushUrl` 跳转到独立页面 `ProblemDetail`。

---

## 数据模型（RDB 4 表）

```sql
-- 题目
problems(id INTEGER PRIMARY KEY, title TEXT, category TEXT, difficulty INTEGER,
         description TEXT, analysis TEXT, code_arkts TEXT, code_python TEXT, tags TEXT)

-- 刷题记录（每道题一条，problem_id 唯一）
records(id INTEGER PRIMARY KEY AUTOINCREMENT, problem_id INTEGER UNIQUE,
        status INTEGER,        -- 0 未做 / 1 已做 / 2 掌握
        wrong_count INTEGER, updated_at INTEGER)

-- 收藏
favorites(problem_id INTEGER PRIMARY KEY, created_at INTEGER)

-- 笔记
notes(problem_id INTEGER PRIMARY KEY, content TEXT, updated_at INTEGER)
```

- 首次启动时 `EntryAbility` 调用 `Database.init()` 建表；若 `problems` 为空，则在事务中批量导入 `data/problemset.ts` 中的内置题库。
- `Database` 为单例，并对并发初始化做了 Promise 复用保护。
- 近 7 日趋势基于 `records.updated_at` 统计每日活跃题数。

---

## 关键实现说明

- **语法高亮**：`Tokenizer.tokenize(code, language)` 逐字符扫描，产出带类型的 token（关键字/字符串/注释/数字/函数名/普通文本）；`CodeView` 将 token 转义并包裹为带颜色的 `<span>`，交由 `RichText` 渲染，代码块采用深色背景。
- **Canvas 图表**：`RingProgress` 通过 `CanvasRenderingContext2D.arc` 绘制渐变进度环；`BarChart` 读取 `ctx.width/height` 自适应绘制带圆角与渐变的柱状图，并通过 `@Prop + @Watch` 在数据变化时重绘。
- **状态刷新**：从详情页返回首页时 `Index.onPageShow` 递增 `refreshTick`，各 Tab 通过 `@Prop @Watch('onTick')` 监听并重新拉取数据，保证收藏/错题/统计实时同步。

---

## 构建与运行

### 环境要求
- DevEco Studio 5.0 及以上（对应 HarmonyOS SDK API 12，`compatibleSdkVersion: 5.0.0(12)`）
- Node.js（DevEco 自带）

### 步骤
1. 使用 **DevEco Studio** 打开本项目根目录 `HarmonyAlgo`。
2. 等待 `hvigor` 自动同步（或在工程目录执行 `ohpm install` 安装依赖）。
3. 在 `File > Project Structure > Signing Configs` 中配置调试签名（自动签名）。
4. 选择模拟器或真机（手机 / 平板均可），点击运行。

也可使用命令行构建：

```bash
# 安装依赖
ohpm install

# 构建 HAP
hvigorw assembleHap
```

产物位于 `entry/build/default/outputs/default/` 下。

---

## 隐私说明

HarmonyAlgo 为纯本地应用：不联网、不上传、不采集任何个人数据。题库、收藏、错题、笔记均存储于设备本地数据库，卸载应用即全部清除。`module.json5` 未申请任何权限。
