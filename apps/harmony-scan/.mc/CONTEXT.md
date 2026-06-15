# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import camera from '@ohos.multimedia.camera'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- 不存在 media.fetchAVFileDescriptor，获取音频 metadata 用 media.createAVMetadataExtractor()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 MusicPlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例

## 项目必备文件
- AppScope/app.json5 + resources
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 只申请实际用到的权限
- READ_MEDIA 范围太大，优先用 READ_AUDIO/READ_IMAGES 等细分权限

## 本项目特定规范（HarmonyScan）

### 项目概述
文档扫描 App：拍照 → 边缘裁剪调整 → 图像增强 → PDF生成 → 文档管理

### 核心架构文件
参考架构设计：~/.openclaw/harmony-daily-app/today/architecture.md

### 目录结构（严格按此实现）
```
HarmonyScan/
├── AppScope/app.json5
├── AppScope/resources/base/element/string.json
├── AppScope/resources/base/media/（默认图标）
├── entry/src/main/ets/
│   ├── entryability/EntryAbility.ets
│   ├── pages/
│   │   ├── Index.ets          （首页：文档列表）
│   │   ├── ScanPage.ets       （扫描页：Camera预览+拍照）
│   │   ├── CropPage.ets       （裁剪页：四角调整+模式选择）
│   │   └── DocumentDetail.ets （文档详情：多页管理+导出）
│   ├── components/
│   │   ├── DocumentCard.ets
│   │   └── EmptyView.ets
│   ├── model/
│   │   └── DocumentModel.ets
│   ├── database/
│   │   └── DocumentDB.ets
│   └── utils/
│       ├── ImageProcessor.ets
│       ├── PdfGenerator.ets
│       └── PermissionHelper.ets
├── entry/src/main/module.json5
├── entry/src/main/resources/base/profile/main_pages.json
├── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```

### Camera API 注意事项
- 使用 XComponent 获取 surfaceId，传给 Camera预览输出
- import camera from '@ohos.multimedia.camera'
- cameraManager.createPreviewOutput(profile, surfaceId)
- 拍照结果通过 photoOutput.on('photoAvailable') 回调获取

### 图像处理注意事项
- import image from '@ohos.multimedia.image'
- PixelMap 裁剪用 pixelMap.crop(region) 方法
- 保存图片用 ImagePacker：imagePacker.packing(pixelMap, options)
- 灰度/黑白处理：readPixelsToBuffer → 处理 RGBA → writeBufferToPixels

### PDF 生成策略（简化版）
- 实现最小化 PDF：每页一张 JPEG 图片，按 PDF 1.4 规范手写字节流
- 如 PDF 实现遇到障碍，降级方案：生成包含所有页面的长图，或提供图片打包方案

### RDB 数据库
- import relationalStore from '@ohos.data.relationalStore'
- 表：documents（文档元数据）+ pages（页面路径）
- DB 初始化在 EntryAbility.onCreate() 中完成

### 文件存储
- 扫描图片存储路径：context.filesDir + '/scans/' + docId + '/'
- PDF 路径：context.filesDir + '/pdfs/'

### 页面路由
- @ohos.router 风格
- router.pushUrl({ url: 'pages/ScanPage' })
- 参数通过 router.getParams() 获取

### 必须实现的 BasicDataSource（如使用 LazyForEach）
```typescript
class DocumentDataSource implements IDataSource {
  private data: DocumentModel[] = [];
  private listeners: DataChangeListener[] = [];
  
  totalCount(): number { return this.data.length; }
  getData(index: number): DocumentModel { return this.data[index]; }
  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.push(listener);
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx >= 0) this.listeners.splice(idx, 1);
  }
  notifyDataReload(): void { this.listeners.forEach(l => l.onDataReloaded()); }
  notifyDataAdd(index: number): void { this.listeners.forEach(l => l.onDataAdd(index)); }
  notifyDataDelete(index: number): void { this.listeners.forEach(l => l.onDataDelete(index)); }
}
```
