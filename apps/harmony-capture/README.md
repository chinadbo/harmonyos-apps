# HarmonyCapture

HarmonyOS NEXT 截图标注应用，使用 ArkTS V1 装饰器与 `@ohos.*` API 实现。

## 功能
- 从系统相册选择图片
- 画笔、橡皮、箭头、矩形、马赛克、文字六种标注工具
- 撤销最近一步标注
- 使用 `SaveButton` 导出并保存到相册
- 使用 RDB 持久化历史记录

## 目录结构
- `AppScope/`：应用级配置与资源
- `entry/src/main/ets/pages/`：首页、编辑页、历史页
- `entry/src/main/ets/components/`：底部工具栏、颜色选择面板
- `entry/src/main/ets/model/`：工具与历史记录模型
- `entry/src/main/ets/service/`：RDB 历史服务、图片导出服务

## 核心实现
- `AnnotateEditor.ets`：在 `Stack` 中将 `Canvas` 叠加到 `Image` 上，通过 `onTouch` 处理六种工具绘制
- `HistoryDbService.ets`：创建并维护 `annotate_history` 表
- `ImageExportService.ets`：封装组件快照导出、媒体库保存、历史记录写入
- `HistoryPage.ets`：自定义 `IDataSource` 驱动历史列表

## 权限说明
- `PhotoViewPicker` 选图不申请权限
- `SaveButton` 保存不申请权限
- 模块 `requestPermissions` 为空数组

## 构建
1. 使用 DevEco Studio 打开项目根目录
2. 同步 `oh-package.json5`
3. 选择 HarmonyOS NEXT 目标设备运行
4. 若 SDK 版本接口签名存在差异，按本地 SDK 实际类型微调
