# 藏集阁 HarmonyCollect

一个纯本地、离线优先的 **HarmonyOS（ArkTS / ArkUI）收藏品管理 App**。用于登记手办、邮票、钱币、球鞋、卡牌、模型等收藏，管理心愿清单，并用自绘图表展示收藏资产结构。

> 本应用不联网、不上传、无账号、无支付、无广告。全部数据保存在本机应用沙箱内。

---

## 功能特性

### 1. 藏品库（Tab 1）
- 网格 / 列表两种展示形态，一键切换
- 关键词搜索：匹配名称、标签、编号、备注
- 多维筛选：品类、成色、估值区间、排序方式（最近添加 / 入手日期 / 估值 / 名称）
- 卡片展示估值、成色、盈亏标记、品类配色
- 右下角浮动按钮快速新增藏品

### 2. 心愿单（Tab 2）
- 记录想收藏的好物，设定目标价格与期待程度（1-3 星）
- “已入手”一键操作：自动在藏品库生成对应藏品，并将心愿标记为已入手（保留历史）
- 可切换是否在列表中显示已入手记录

### 3. 统计（Tab 3）
- 概览指标：藏品数量、总投入、总估值、浮动盈亏（含盈亏率）
- **Canvas 自绘环形图**：品类价值分布（中心显示总估值）+ 图例
- **Canvas 自绘柱状图**：成色件数分布（按成色配色）
- 高价值藏品 Top 榜

### 4. 设置（Tab 4）
- 显示偏好：列表形态、默认排序、心愿单是否含已入手
- 品类管理：预置品类 + 自定义品类（可增删）
- 数据管理：一键导出全部数据为本地 JSON（写入 `filesDir/export/`）；清空藏品与心愿
- 关于与隐私说明

### 5. 详情 / 编辑页
- **ItemDetail**：大图 + 全字段 + 估值/盈亏 + 标签 + 备注 + 编辑/删除
- **ItemEdit**：图片选择、名称、品类、成色、日期（DatePicker）、价格、编号、标签、备注
- **WishEdit**：心愿表单 + “已入手”入库 + 删除

---

## 架构

```
HarmonyCollect/
├── AppScope/
│   ├── app.json5
│   └── resources/base/{element/string.json, media/app_icon.png}
├── entry/src/main/
│   ├── module.json5                     # requestPermissions 为空
│   ├── ets/
│   │   ├── entryability/EntryAbility.ets # 初始化 DB/偏好，就绪后加载首页
│   │   ├── model/
│   │   │   ├── CollectItem.ets           # 藏品实体
│   │   │   ├── WishItem.ets              # 心愿实体
│   │   │   ├── Category.ets              # 品类实体
│   │   │   ├── StatsModel.ets            # 统计聚合模型
│   │   │   └── Db.ets                    # RDB 初始化 + ItemDao/WishDao/CategoryDao
│   │   ├── common/
│   │   │   ├── Constants.ets             # 枚举/配色/筛选/偏好键
│   │   │   ├── Format.ets                # 日期/金额/标签格式化
│   │   │   ├── ImageStore.ets            # Picker 图片拷贝到沙箱
│   │   │   ├── Logger.ets                # hilog 封装
│   │   │   ├── Prefs.ets                 # Preferences 设置持久化
│   │   │   └── Exporter.ets              # 导出 JSON 序列化
│   │   ├── service/
│   │   │   ├── ItemService.ets           # 藏品校验/增删改查/图片清理
│   │   │   ├── WishService.ets           # 心愿逻辑 + 已入手入库
│   │   │   ├── StatsService.ets          # 统计聚合
│   │   │   └── BackupService.ets         # 导出文件 / 清空
│   │   ├── components/                   # 可复用组件
│   │   │   ├── ItemCard / WishCard
│   │   │   ├── RingChart / BarChart / StatCharts
│   │   │   ├── FilterSheet / TagEditor / ImagePicker
│   │   │   ├── CategoryPicker / ConditionPicker / PriorityPicker
│   │   │   └── PageHeader / EmptyView / SegmentBar / SummaryCard
│   │   ├── views/                        # Tab 内容视图
│   │   │   ├── CollectionTab / WishlistTab / StatsView / SettingsView
│   │   └── pages/                        # 路由页面
│   │       ├── Index / ItemDetail / ItemEdit / WishEdit / Stats
│   └── resources/base/
│       ├── element/{string.json, color.json}
│       ├── media/{app_icon.png, start_icon.png}
│       └── profile/{main_pages.json, privacy_statement.json}
├── build-profile.json5 / oh-package.json5 / hvigorfile.ts
├── entry/{build-profile.json5, oh-package.json5, hvigorfile.ts}
├── privacy_statement.json
└── README.md
```

### 分层说明
- **model**：实体 + `Db.ets` 中的三表 DAO（参数化 ValuesBucket / RdbPredicates）
- **service**：业务编排、校验、错误处理（try/catch + hilog）
- **components / views / pages**：纯 V1 装饰器 UI，通过 service 读写数据
- 跨页刷新：`AppStorage` 的 `refreshTick` 信号 + 各 Tab 的 `@Watch` 重新加载

---

## 数据模型（RDB 三表）

### items（藏品）
`id, name, category, condition, acquireDate, acquirePrice, estValue, serial, tags, imageUri, remark, createdAt`

### wishlist（心愿）
`id, name, category, targetPrice, priority(1-3), remark, createdAt, status(0 想要 / 1 已入手)`

### categories（品类）
`key(主键), name, icon, sortOrder, custom`

预置品类：手办 / 邮票 / 钱币 / 球鞋 / 卡牌 / 模型 / 其他
成色枚举：全新 / 95新 / 9成新 / 有使用痕迹 / 仅配件

---

## 技术要点

- **装饰器**：统一 V1（`@Component/@State/@Prop/@Link/@StorageProp/@StorageLink/@Watch/@Builder`），不混用 V2
- **Import**：统一 `@ohos.*` 风格（如 `@ohos.data.relationalStore`、`@ohos.file.picker`、`@ohos.file.fs`）
- **图片**：`PhotoViewPicker.select()` 仅获得临时读取授权，选图后立即用 `fs.copyFileSync` 拷贝到 `context.filesDir/images/`，展示时补 `file://` 前缀
- **统计图**：`Canvas` + `CanvasRenderingContext2D` 自绘环形图与柱状图，随数据 `@Watch` 重绘
- **隐私**：不申请任何敏感权限，`requestPermissions: []`

---

## 构建方式

1. 使用 **DevEco Studio**（建议 5.0 / API 12 及以上）打开本工程根目录。
2. 等待 Sync 完成（hvigor 拉取 `@ohos/hvigor-ohos-plugin`）。
3. 配置签名（Project Structure → Signing Configs，自动生成调试证书）。
4. 连接设备 / 模拟器，点击 Run。

命令行（已配置好 hvigor 环境时）：
```bash
hvigorw --mode module -p product=default assembleHap
```

> 说明：仓内 `build-profile.json5` 未内置签名配置，正式打包请在 DevEco Studio 中配置签名后构建。

---

## 隐私与合规

- 无账号体系、无网络请求、无第三方 SDK、无广告与支付
- 全部数据仅存储于应用沙箱（`relationalStore` 数据库 + `filesDir`）
- 导出文件亦写入本机沙箱 `filesDir/export/`
- 详见根目录 `privacy_statement.json` 与 `entry/src/main/resources/base/profile/privacy_statement.json`

低风险，适合 AppGallery 上架（无敏感权限、无联网）。
