# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import media from '@ohos.multimedia.media'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- 不存在 media.fetchAVFileDescriptor，获取音频 metadata 用 media.createAVMetadataExtractor()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 MusicPlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例
- backgroundTaskManager.startBackgroundRunning 需要在 UIAbility 中调用，参数需要 WantAgent

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

## 本项目特殊说明（HarmonyFocus）
- App 类型：番茄钟/专注计时器
- 后台计时使用 backgroundTaskManager（申请 TASK_TYPE_SHORT_TASK 或 continuousTask）
- 白噪音使用 AVPlayer 循环播放 rawfile 音频
- Widget 使用 FormExtensionAbility（简单版，显示今日番茄数 + 当前状态）
- 数据库使用 relationalStore（RDB）
- 通知使用 notificationManager（带操作按钮）
- Canvas 绘制圆环进度条

## 架构参考
见 architecture.md（父目录）
- 页面：Index.ets（主计时器）、TaskList.ets、Statistics.ets、Settings.ets
- 组件：TimerRing.ets（Canvas圆环）、HeatmapChart.ets、BarChart.ets、TaskItem.ets
- 服务：TimerService.ets、AudioService.ets、NotifyService.ets、DatabaseService.ets
- 模型：Task.ets、PomodoroRecord.ets、AppSettings.ets
- 通用：Constants.ets、Utils.ets
