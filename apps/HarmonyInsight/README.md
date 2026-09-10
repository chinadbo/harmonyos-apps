# HarmonyInsight - 数据可视化图表工具

一款轻量级 HarmonyOS 数据可视化工具，支持导入 CSV/手动输入数据，生成交互式图表。

## 功能特性

- 📊 **多种图表类型**：柱状图、折线图、饼图/环形图、散点图、雷达图、面积图
- 📥 **数据导入**：手动输入表格、CSV 文件导入、示例数据
- 🎨 **图表配置**：颜色主题切换、标签显示、图例开关、数据点标记
- 👆 **交互操作**：图表缩放、数据点点击高亮、长按查看详情
- 💾 **导出分享**：截图保存到相册、分享为图片、导出数据为 CSV
- 📋 **历史记录**：最近查看的图表列表，支持重新编辑
- 🌙 **暗色/浅色主题**

## 架构

```
├── 数据层 (data/)
│   ├── CSVParser.ets      — CSV 文件解析
│   ├── ChartDataModel.ets — 统一数据模型
│   └── RDBHelper.ets      — 数据库操作
├── 图表引擎 (chart/)
│   ├── ChartRenderer.ets  — Canvas 基础绘制封装
│   ├── BarChart.ets       — 柱状图
│   ├── LineChart.ets      — 折线图
│   ├── PieChart.ets       — 饼图/环形图
│   ├── ScatterChart.ets   — 散点图
│   ├── RadarChart.ets     — 雷达图
│   └── AreaChart.ets      — 面积图
├── 页面层 (pages/)
│   ├── HomePage.ets       — 首页（历史列表 + 新建）
│   ├── DataInputPage.ets  — 数据输入
│   ├── ChartConfigPage.ets— 图表配置
│   ├── ChartViewPage.ets  — 图表预览与交互
│   └── ExportPage.ets     — 导出与分享
└── 工具层 (utils/)
    ├── ThemeManager.ets   — 暗色/浅色主题切换
    ├── FileHelper.ets     — 文件读写辅助
    └── ShareHelper.ets    — 图片分享
```

## 技术亮点

- **Canvas 自定义图表渲染**：纯前端绘制，不依赖第三方图表库
- **文件管理**：fs API 读取 CSV
- **照片权限**：保存图表截图到相册
- **数据持久化**：RDB 存储图表历史
- **响应式布局**：适配不同屏幕尺寸
- **主题切换**：暗色/浅色主题

## 构建方式

```bash
# 使用 DevEco Studio 打开项目根目录
# 选择 "Build" → "Build Hap(s)"
```

## 页面路由

```
HomePage → DataInputPage → ChartConfigPage → ChartViewPage → ExportPage
HomePage → ChartViewPage (点击历史记录)
ChartViewPage → ChartConfigPage (编辑)
```

## API Level

- 最低支持：API Level 16
- 目标版本：API Level 16
