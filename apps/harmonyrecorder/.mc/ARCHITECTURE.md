# HarmonyRecorder 架构设计（mc 编码参考）

## 项目结构

```
harmonyrecorder/
├── AppScope/
│   ├── app.json5
│   └── resources/
├── entry/
│   ├── build-profile.json5
│   ├── oh-package.json5
│   └── src/
│       ├── main/
│       │   ├── module.json5
│       │   └── resources/
│       │       ├── base/
│       │       │   ├── element/
│       │       │   └── profile/
│       │       │       └── main_pages.json
│       │       └── zh_CN/
│       │           └── element/
│       └── main/ets/
│           ├── entryability/
│           │   └── EntryAbility.ets
│           ├── pages/
│           │   ├── HomePage.ets
│           │   ├── RecordingPage.ets
│           │   ├── RecordingListPage.ets
│           │   ├── RecordingPreviewPage.ets
│           │   ├── GifConvertPage.ets
│           │   └── SettingsPage.ets
│           ├── model/
│           │   ├── RecordingConfig.ts
│           │   ├── RecordingFile.ts
│           │   └── RecordingState.ts
│           ├── service/
│           │   ├── RecordingService.ets
│           │   ├── WindowManager.ets
│           │   └── GifConverter.ets
│           ├── utils/
│           │   ├── FileUtils.ets
│           │   ├── ThumbnailUtils.ets
│           │   └── PermissionUtils.ets
│           └── components/
│               ├── FloatingWindow.ets
│               ├── AnnotationCanvas.ets
│               ├── RecordingItem.ets
│               └── AnnotationToolbar.ets
├── privacy_statement.json
└── README.md
```

## 核心功能

### 1. 系统级屏幕录制
- 使用 ohos.screenCapture API
- 权限: ohos.permission.CAPTURE_SCREEN
- 支持倒计时（3s/5s/10s/无）
- 录制状态: idle → counting → recording → (paused) → idle

### 2. 画中画录制
- 录制时最小化为浮动窗口
- 圆形浮动按钮（开始/暂停/停止）
- 触摸拖动位置
- 录制时长显示

### 3. 录制标注
- Canvas 叠加在录制区域上
- 实时绘制：箭头、圆圈、矩形、自由画笔
- 颜色选择器
- 清除/撤销功能

### 4. GIF 导出
- 视频转 GIF
- 帧率可配置
- 进度显示

### 5. 录制管理
- 文件列表（按时间排序）
- 缩略图生成
- 预览播放
- 分享/删除

## 权限声明

- ohos.permission.CAPTURE_SCREEN
- ohos.permission.MICROPHONE (in-use, 录制音频)
- ohos.permission.READ_MEDIA
- ohos.permission.WRITE_MEDIA

## 数据模型

```typescript
enum RecordingState { IDLE, COUNTING, RECORDING, PAUSED }

interface RecordingConfig {
  resolution: '720p' | '1080p' | 'native';
  frameRate: 30 | 60;
  enableAudio: boolean;
  countdownSeconds: 3 | 5 | 10 | 0;
  enableAnnotation: boolean;
}

interface RecordingFile {
  id: string;
  name: string;
  path: string;
  thumbnailPath: string;
  duration: number;
  size: number;
  createdAt: string;
}
```

## 重要注意事项

1. screenCapture API 需要用户手动授权，startScreenCapture 会弹出系统授权对话框
2. 录制过程中不能直接操作 UI（UI 会被录制），浮窗需使用独立窗口
3. GIF 转换使用 AVPlayer 逐帧提取 + 编码
4. 所有文件操作使用 fs API，注意异步处理
5. 缩略图使用 AVMetadataExtractor 从视频提取
