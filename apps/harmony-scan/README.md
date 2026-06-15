# HarmonyScan

HarmonyScan 是一个基于 HarmonyOS ArkTS 的文档扫描应用示例，覆盖拍照、裁剪、图像增强、文档管理与 PDF 导出全流程。

## 功能

- 首页文档列表，按日期分组展示
- 扫描页使用 Camera + XComponent surfaceId 进行预览与拍照
- 裁剪页支持四角拖拽，提供彩色 / 灰度 / 黑白模式
- 文档详情页查看所有页面缩略图，支持继续扫描、导出 PDF、分享入口
- 本地 RDB 数据库存储 documents / pages 元数据
- 本地文件目录保存扫描图片和导出的 PDF

## 项目结构

```text
HarmonyScan/
├── AppScope/
├── entry/src/main/ets/
│   ├── entryability/
│   ├── pages/
│   ├── components/
│   ├── model/
│   ├── database/
│   └── utils/
├── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```

## 架构说明

- `EntryAbility.ets`：应用入口，初始化数据库与沙箱目录
- `Index.ets`：读取 RDB 文档数据并按日期分组展示
- `ScanPage.ets`：申请相机权限，创建 Camera session、preview output 与 photo output
- `CropPage.ets`：展示拍摄图片，基于四角控制点确定矩形裁剪区域，并调用 `ImageProcessor`
- `DocumentDetail.ets`：读取文档详情，生成 PDF，并显示分享入口
- `DocumentDB.ets`：封装 documents / pages 的建表和常用 CRUD
- `ImageProcessor.ets`：PixelMap 裁剪、灰度 / 黑白处理、JPEG 保存
- `PdfGenerator.ets`：使用最简 PDF 1.4 字节流拼装 JPEG 页面

## 构建方式

1. 使用 DevEco Studio 打开项目根目录。
2. 确认 SDK 为 HarmonyOS 5.0，API Level 12。
3. 补齐签名材料或替换 `build-profile.json5` 中的调试签名配置。
4. 连接设备后构建并运行 entry 模块。

## 存储说明

- 扫描原图与处理后图片：`context.filesDir/scans/<docId>/`
- 导出 PDF：`context.filesDir/pdfs/`
- 数据库：应用沙箱内 `harmonyscan.db`

## 已知简化

- 裁剪采用四角确定 bounding box 的矩形裁剪，不做透视矫正
- 分享按钮当前提供系统分享接入提示，实际项目可继续接入系统分享面板
- PDF 生成器为最简图片型 PDF，不支持文字识别与检索
