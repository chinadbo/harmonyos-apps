# HarmonyWardrobe 衣橱穿搭

基于 HarmonyOS ArkTS（Stage 模型）的本地衣柜穿搭管理应用。零权限（不申请任何 `ohos.permission`），全部数据存于应用本地沙箱，不上传任何信息。

## 功能说明

| 页面 | 说明 |
| ---- | ---- |
| Index（衣柜总览） | 分类筛选 + 双列瀑布卡片浏览全部衣物，点击卡片进入编辑，右上角添加衣物 |
| OutfitBuilder（穿搭搭配） | 按上衣/下装/外套/鞋靴/配饰五个槽位从衣柜中点选单品组合搭配并保存，下方展示已有搭配列表 |
| CalendarPage（穿搭日历） | Canvas 自绘月历，已记录穿搭的日期带圆点标记，点选日期可为该天记录/删除穿搭 |
| StatsPage（统计） | 衣物/搭配/穿着记录总数 + Canvas 自绘饼图（分类占比）与条形图（穿着排行前 6） |
| ClothingEdit（衣物编辑） | 添加/编辑衣物：名称、分类、颜色、季节，系统 PhotoViewPicker 选图并复制到沙箱 |
| OutfitDetail（穿搭详情） | 查看搭配构成与累计穿着次数，一键记录今日穿着，查看历史穿着记录，删除搭配 |

## 架构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets     # UIAbility 入口，初始化 RDB
├── model/WardrobeModels.ets          # 数据模型、枚举（WardrobeCategory/WardrobeSeason）、日期工具
├── common/
│   ├── ClothingDataSource.ets        # 自实现 IDataSource，配合 LazyForEach 使用
│   ├── ImageHelper.ets               # PhotoViewPicker 选图并复制到 filesDir/wardrobe/
│   └── UiUtils.ets                   # Toast 工具
├── data/WardrobeDb.ets               # RDB 封装（单例），clothing / outfit / outfit_log 三表
├── components/
│   ├── WardrobeCard.ets              # 衣物卡片
│   ├── OutfitCard.ets                 # 搭配卡片（单品缩略图 + 穿着次数）
│   ├── CalendarGrid.ets              # Canvas 自绘月历（点击选择日期，含今日/选中/已记录高亮）
│   └── StatChart.ets                 # Canvas 自绘环形饼图 / 条形图（含图例）
└── pages/                            # 六个路由页面
```

### 数据库（relationalStore RDB，wardrobe.db）

- **clothing**：id、name、category、color_name、season、image_path、favorite、created_at
- **outfit**：id、name、top_id、bottom_id、outer_id、shoes_id、accessory_id、created_at
- **outfit_log**：id、outfit_id、log_date（YYYY-MM-DD）、created_at（log_date / outfit_id 建索引；同一天仅保留一条记录）

### 技术要点

- 统一 V1 装饰器体系：`@Component` + `@State` / `@Prop`（含 `@Watch`），未使用任何 V2 装饰器
- 统一 `@ohos.*` import 风格（`@ohos.data.relationalStore`、`@ohos.file.photoAccessHelper`、`@ohos.file.fs`、`@ohos.router` 等）
- 选图通过系统 `photoAccessHelper.PhotoViewPicker`，**0 权限**，图片复制到 `context.filesDir/wardrobe/` 后使用 `file://` URI 展示
- `LazyForEach` + 自实现 `IDataSource`（框架不内置 BasicDataSource，本项目的 `ClothingDataSource` 自行实现并通知刷新）
- 月历与图表全部 Canvas 手绘（`CanvasRenderingContext2D`），无任何三方图表库
- 枚举命名避开系统冲突（`WardrobeCategory` / `WardrobeSeason`）
- 页面间传参：`router.pushUrl` + `Record<string, string>`；主页面间切换用 `router.replaceUrl`

## 构建方式

1. 使用 DevEco Studio（HarmonyOS 5.0 及以上）打开项目根目录；
2. `File > Project Structure > Signing Configs` 配置或自动生成签名；
3. 连接真机或启动模拟器，点击 `Run 'entry'` 构建 HAP 并安装；
4. 命令行构建：项目根目录执行
   ```
   hvigorw assembleHap
   ```
   产物位于 `entry/build/default/outputs/default/`。

## 隐私说明

见 `entry/src/main/resources/base/profile/privacy_statement.json`：本应用不申请任何权限、不联网、不采集个人信息，所有数据仅存储在应用沙箱内，卸载应用即随之删除。
