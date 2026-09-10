# HarmonyInsight 架构设计

## 模块划分

### 1. 数据层 (Data)
- **CSVParser** — CSV 文件解析，返回二维数组
- **ChartDataModel** — 统一数据模型，支持数值型/类别型/日期型
- **RDBHelper** — 关系型数据库操作（图表历史、配置）

### 2. 图表引擎 (Chart Engine)
- **ChartRenderer** — Canvas 基础绘制上下文封装
- **BarChart** — 柱状图
- **LineChart** — 折线图
- **PieChart** — 饼图/环形图
- **ScatterChart** — 散点图
- **RadarChart** — 雷达图
- **AreaChart** — 面积图

### 3. 页面层 (Pages)
- **HomePage** — 首页（图表历史列表 + 新建按钮）
- **DataInputPage** — 数据输入（手动表格 + CSV 导入）
- **ChartConfigPage** — 图表配置（类型选择、主题、标签等）
- **ChartViewPage** — 图表预览与交互（缩放、点击高亮）
- **ExportPage** — 导出（截图保存、CSV 导出）

### 4. 工具层 (Utils)
- **ThemeManager** — 暗色/浅色主题切换
- **FileHelper** — 文件读写辅助
- **ShareHelper** — 图片分享

## 页面路由

```
HomePage (main_pages.json) → DataInputPage → ChartConfigPage → ChartViewPage → ExportPage
HomePage → ChartViewPage (点击历史记录)
ChartViewPage → ChartConfigPage (编辑)
```

## 数据模型

```typescript
// 图表记录
interface ChartRecord {
  id: string;
  name: string;
  type: ChartType;  // BAR, LINE, PIE, SCATTER, RADAR, AREA
  data: string;     // JSON 序列化的图表数据
  config: string;   // JSON 序列化的配置（颜色、主题等）
  createdAt: number;
  updatedAt: number;
}

// 图表数据
interface ChartData {
  title: string;
  xAxis: string[];
  series: {
    name: string;
    data: number[];
    color?: string;
  }[];
}
```

## API 使用规范

### Canvas 绘制
```typescript
import canvas from '@ohos.graphics.canvas';

// 使用 CanvasRenderingContext2D 进行图表绘制
const ctx = canvasRenderingContext2D;
ctx.beginPath();
ctx.moveTo(x1, y1);
ctx.lineTo(x2, y2);
ctx.stroke();
```

### 文件操作
```typescript
import fs from '@ohos.file.fs';

// CSV 读取
const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
const buffer = new ArrayBuffer(65536);
const readLen = fs.readSync(file.fd, buffer);
const text = new TextDecoder().decode(buffer.slice(0, readLen));
```

### 数据库
```typescript
import relationalStore from '@ohos.data.relationalStore';

// RDB 初始化
const store = await relationalStore.getRdbStore(context, { name: 'harmonyInsight.db', securityLevel });
```

### 照片权限
```typescript
import photoAccessHelper from '@ohos.file.photoAccessHelper';

// 保存截图到相册
const phAccessHelper = photoAccessHelper.create(photoAccessHelper.AlbumType.SYSTEM,
  photoAccessHelper.AlbumSubtype.SCREENSHOT, context);
```

## 权限声明

```json
// module.json5
"requestPermissions": [
  {"name": "ohos.permission.READ_MEDIA"},
  {"name": "ohos.permission.WRITE_MEDIA"},
  {"name": "ohos.permission.FILE_ACCESS_MANAGER"}
]
```

## 项目结构

```
harmonyinsight/
├── AppScope/
│   ├── app.json5
│   └── resources/
├── entry/
│   ├── src/main/
│   │   ├── module.json5
│   │   ├── resources/
│   │   │   └── base/profile/main_pages.json
│   │   └── ets/
│   │       ├── entryability/EntryAbility.ets
│   │       ├── pages/
│   │       │   ├── HomePage.ets
│   │       │   ├── DataInputPage.ets
│   │       │   ├── ChartConfigPage.ets
│   │       │   ├── ChartViewPage.ets
│   │       │   └── ExportPage.ets
│   │       ├── data/
│   │       │   ├── CSVParser.ets
│   │       │   ├── ChartDataModel.ets
│   │       │   └── RDBHelper.ets
│   │       ├── chart/
│   │       │   ├── ChartRenderer.ets
│   │       │   ├── BarChart.ets
│   │       │   ├── LineChart.ets
│   │       │   ├── PieChart.ets
│   │       │   ├── ScatterChart.ets
│   │       │   ├── RadarChart.ets
│   │       │   └── AreaChart.ets
│   │       └── utils/
│   │           ├── ThemeManager.ets
│   │           ├── FileHelper.ets
│   │           └── ShareHelper.ets
│   └── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```
