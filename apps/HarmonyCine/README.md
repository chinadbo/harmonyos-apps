# HarmonyCine 影视追踪与片单管理

一款纯本地、零权限、零联网的 HarmonyOS 影视追踪应用：三态片单（在看 / 想看 / 看过）、10 星评分、剧集进度、观影统计与成就徽章。首次启动自动灌入 49 条热门影视推荐库，开箱即有数据可玩。

## 功能

| 页面 | 说明 |
|------|------|
| Index（片单主页） | 三态 Tab 片单、关键字搜索（300ms 防抖）、渐变海报墙（2 列网格）、FAB 快速添加、统计 / 成就 / 设置入口 |
| AddMoviePage（快速添加） | 热门种子库 3 列网格多选批量加入 + 自定义表单（片名 / 类型 / 状态 / 评分 / 总集数 / 备注） |
| MovieDetailPage（详情） | 状态三按钮流转（确认弹窗）、评分即时生效、进度与总集数步进、标题 / 短评编辑保存、删除确认、观看记录时间线 |
| StatsPage（统计） | 总数四宫格、已看平均分（rating>0 参与均分）、类型分布环形图（Canvas 自绘）、近 6 个月观影柱状图 |
| AchievementsPage（成就） | 里程碑徽章：看完 10 / 30 / 50 / 100 部，含解锁时间与当前进度条 |
| SettingsPage（设置） | 海报色板偏移（0-3 全局换色）、清空全部数据（确认）、关于与隐私说明 |

## 技术要点

- **Stage Model + ArkTS（V1 装饰器体系）**：统一 `@Component + @State/@Prop/@Link/@StorageLink`，不使用任何 V2 装饰器；Import 统一 `@ohos.*` 风格。
- **纯离线存储**：`@ohos.data.relationalStore` 单例（`dbReady()` Promise 就绪）+ `@ohos.data.preferences`（最后选中 Tab、海报色偏移），`module.json5` 零 `requestPermissions`。
- **RDB 3 表**：`movie_item`（条目）、`watch_record`（状态流转 / 评分历史）、`achievement`（里程碑解锁时间）。
- **程序化海报**：不做图片资源，12 组渐变色板 + 标题首字 + 类型符号生成海报卡，色板索引由 `id + 用户偏移` 哈希决定，设置页可全局换色。
- **Canvas 统计图**：`StatRingChart`（环形图，@Watch 重绘）与 `StatBarChart`（柱状图）均用 `CanvasRenderingContext2D` + `RenderingContextSettings(true)` 在 `onReady` 中自绘。
- **时序安全**：EntryAbility `onCreate` 注入上下文，各页面 `aboutToAppear` 中 `await dbReady()` 后加载；`loadContent` 为 promise 版本并以 `try/catch` 捕获 `BusinessError`。
- **定时器清理**：所有 `setTimeout` 均保存 id，并在 `aboutToDisappear` 中 `clearTimeout`。

## 目录结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets   # 入口 Ability
├── model/Movie.ets                 # 枚举 + 数据模型 + 成就定义 + 色板工具
├── data/
│   ├── DbService.ets               # RDB/Preferences 单例 + 建表 + 种子灌入
│   ├── SeedData.ets                # 49 条热门影视种子
│   └── MovieRepository.ets         # CRUD / 筛选 / 统计 / 成就查询
├── components/
│   ├── RatingStars.ets             # 10 星评分（可编辑）
│   ├── MovieCard.ets               # 渐变海报卡
│   ├── StatRingChart.ets           # 类型分布环形图
│   └── StatBarChart.ets            # 月度观影柱状图
└── pages/                          # Index / AddMoviePage / MovieDetailPage /
                                    # StatsPage / AchievementsPage / SettingsPage
```

## 构建方式

1. 使用 DevEco Studio（API 12+）打开工程根目录。
2. File > Sync and Refresh Project 同步 hvigor 依赖。
3. 连接设备或启动模拟器，Run 'entry'。
4. 命令行：`hvigorw assembleHap --mode module -p product=default` 生成 HAP。

## 隐私声明

应用不申请任何系统权限，不联网、不上传、不收集任何个人数据；所有数据保存在设备本地，可在设置页一键清空，详见 `entry/src/main/resources/base/profile/privacy_statement.json`。
