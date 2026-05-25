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

## 项目特定信息

### App：HarmonySpeed — 网速测试工具

#### 目录结构
```
harmony-speed/
├── AppScope/
│   ├── app.json5
│   └── resources/base/element/string.json
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/EntryAbility.ets
│   │   │   ├── entryformability/EntryFormAbility.ets
│   │   │   ├── pages/Index.ets          # Navigation 根页面
│   │   │   ├── views/
│   │   │   │   ├── HomeView.ets         # 主测速仪表盘
│   │   │   │   ├── HistoryView.ets      # 历史记录 + 折线图
│   │   │   │   └── SettingsView.ets     # 设置页
│   │   │   ├── components/
│   │   │   │   ├── SpeedometerCanvas.ets  # 仪表盘 Canvas
│   │   │   │   ├── LineChartCanvas.ets    # 折线图 Canvas
│   │   │   │   ├── NetworkInfoCard.ets    # 网络信息卡片
│   │   │   │   └── SpeedResultCard.ets    # 测速结果卡片
│   │   │   ├── service/
│   │   │   │   ├── SpeedTestService.ets   # 测速逻辑
│   │   │   │   └── NetworkService.ets     # 网络信息获取
│   │   │   ├── database/
│   │   │   │   └── SpeedDatabase.ets      # RDB 操作封装
│   │   │   ├── model/
│   │   │   │   └── SpeedRecord.ets        # 数据模型
│   │   │   └── widget/
│   │   │       └── WidgetCard.ets         # Form 卡片 UI
│   │   ├── resources/
│   │   │   ├── base/element/string.json
│   │   │   ├── base/element/color.json
│   │   │   └── base/profile/
│   │   │       ├── main_pages.json
│   │   │       └── form_config.json
│   │   └── module.json5
│   ├── build-profile.json5
│   └── oh-package.json5
├── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```

#### 核心技术点
- 测速：@ohos.net.http requestInStream，onDataReceive 累积字节数计算 Mbps
- 网络信息：@ohos.net.connection getDefaultNet() + getNetInfo()
- Canvas 仪表盘：CanvasRenderingContext2D 半圆弧形，@ohos.animator 指针动画
- RDB：@ohos.data.relationalStore，表 speed_records
- Widget：Form Kit，supportDimensions: ['2*2']

#### 权限
- ohos.permission.INTERNET
- ohos.permission.GET_WIFI_INFO
- ohos.permission.GET_NETWORK_INFO

#### 关键陷阱
- Canvas 只在 onReady 回调内绘制，禁止在外部调用
- Widget 用 @LocalStorageProp 不用 @State 接 FormBindingData
- RDB 操作用 try-finally 确保 close()
- http.HttpRequest 用完调 destroy() 释放资源
- @ohos.animator PlayMode 枚举与自定义枚举命名冲突，自定义用 SpeedTestPhase 等不同名字
