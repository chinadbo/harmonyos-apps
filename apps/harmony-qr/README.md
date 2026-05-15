# HarmonyQR

HarmonyQR 是一个基于 HarmonyOS ArkTS 与 ArkUI V1 装饰器体系实现的二维码工具应用，包含扫码、生成、历史记录与结果解析四大模块。

## 功能特性

- 扫码页：基于 `@ohos.customScan` 的扫码流程，自定义扫描框四角装饰与扫描线动画，支持手电筒控制。
- 生成页：`TextArea` 输入、ArkUI 原生 `QRCode` 实时预览、前景色/背景色预设与尺寸滑块调节。
- 历史页：扫描历史、生成历史、收藏三类标签页，`IDataSource + LazyForEach` 列表渲染，支持搜索与左滑删除。
- 结果页：解析 URL、WiFi、vCard、文本四种二维码结果，支持复制与收藏。
- 数据层：`RelationalStore` 单例数据库，统一持久化 `qr_records` 表。

## 项目结构

```text
HarmonyQR/
├── AppScope/
├── entry/src/main/ets/
│   ├── entryability/
│   ├── pages/
│   ├── components/
│   ├── model/
│   ├── service/
│   └── utils/
├── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```

## 核心实现说明

### ScanPage
- 使用 `@ohos.customScan` 初始化与启动扫码。
- 扫码回调不直接写入 `@State`，而是通过 `AppStorage.setOrCreate` 中转到页面监听。
- 在 `onPageShow` 中申请相机权限并启动扫码，在 `onPageHide` 中停止并释放资源。

### GeneratePage
- 使用 ArkUI 原生 `QRCode` 组件进行实时预览。
- 提供 6 种预设颜色，可分别设置前景色与背景色。
- 使用 `Slider` 控制二维码尺寸范围 150px-300px。
- 通过 `componentSnapshot` + `photoAccessHelper` 实现保存到相册。

### HistoryPage
- 本地实现 `QRDataSource implements IDataSource`，包含 `totalCount/getData/registerDataChangeListener/unregisterDataChangeListener`。
- 搜索框输入直接触发 RDB 查询，而非前端本地过滤。
- 使用 `HistoryItem` 统一列表项渲染，支持左滑删除和收藏切换。

### ResultPage
- 通过路由参数接收序列化后的 `QRRecord`。
- `ResultParser` 解析 URL / WiFi / vCard / 文本四种内容类型。
- 支持复制原始内容、复制解析结果、收藏/取消收藏。

## 数据表

```sql
CREATE TABLE IF NOT EXISTS qr_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,
  content TEXT NOT NULL,
  contentType TEXT DEFAULT 'text',
  color TEXT DEFAULT '#000000',
  bgColor TEXT DEFAULT '#FFFFFF',
  isFavorite INTEGER DEFAULT 0,
  createdAt INTEGER NOT NULL
)
```

## 构建说明

1. 使用 DevEco Studio 打开项目根目录 `HarmonyQR`。
2. 确认 SDK 中包含 `@ohos.customScan`、`@ohos.data.relationalStore`、`@ohos.pasteboard`、`@ohos.arkui.componentSnapshot` 等系统能力。
3. 连接 HarmonyOS 真机或模拟器。
4. 执行构建并运行 `entry` 模块。

## 权限说明

项目仅申请以下最小权限：

- `ohos.permission.CAMERA`
- `ohos.permission.READ_IMAGEVIDEO`
- `ohos.permission.WRITE_IMAGEVIDEO`

所有权限均为 `inuse` 场景声明。
