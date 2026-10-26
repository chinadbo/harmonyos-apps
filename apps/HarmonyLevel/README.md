# HarmonyLevel - 水平仪 / 倾角测量 App

HarmonyOS ArkTS 水平仪应用：利用设备加速度传感器实现**气泡水平仪（2D 双轴）**与**角度尺（单轴 0-360°）**双模式测量，支持三步校准、0°/45°/90° 目标判定、声音提示、测量历史记录。纯本地运行、**零权限**（加速度传感器 / Preferences / Canvas / AVPlayer(rawfile) 均无需 ohos.permission）。

## 功能特性

- **气泡水平仪** — Canvas 自绘深色表盘，双轴倾角驱动气泡移动，中心环即水平判定（±1°），支持锁定/置零/记录
- **角度尺** — 单轴 0-360° 大数字 + 滚动刻度尺，横竖姿态自动切换（|pitch|>|roll| 判定主轴）
- **目标角度判定** — 0°/45°/90° 目标环可视化，接近/命中双级色彩状态（黄/绿）
- **校准向导** — 三步置零（放置→读取基准→确认偏移），偏移写入 Preferences，全局生效
- **声音提示** — 接近水平/命中目标角时 AVPlayer 播放 rawfile 短音频，可在设置中关闭
- **保持亮屏** — 测量页 `window.setWindowKeepScreenOn`，可开关
- **历史记录** — 测量点（时间/模式/角度）存 Preferences，上限 200 条 FIFO，支持滑动删除与清空
- **灵敏度设置** — 一阶低通滤波系数 10 级可调（响应速度 vs 抖动抑制）

## 技术架构

- **语言/UI**：ArkTS，Stage 模型，Component V1 装饰器体系（@Component/@State/@Prop/@Watch）
- **传感器**：`@ohos.sensor` 加速度计（`sensor.on(sensor.SensorId.ACCELEROMETER, cb, { interval: 20000000 })`，20ms ≈ 50Hz）
- **角度解算**：`pitch = atan2(-y, z)`、`roll = atan2(x, sqrt(y²+z²))`，弧度→角度 ×180/π，归一化 [-180,180] / [0,360]
- **滤波**：一阶低通（alpha 0.1-0.55），原始轴分量先滤波、再解算、再 30ms 节流回调；Canvas 重绘另有 16ms 节流
- **存储**：`@ohos.preferences`（`level_store`：history_list JSON / calib_offset / settings）
- **音效**：`@ohos.multimedia.media` AVPlayer 播放 `rawfile/beep.wav`（fdSrc = resourceManager.getRawFd），播完即 release，内置 400ms 节流
- **权限**：无（module.json5 不含 requestPermissions）

## 项目结构

```
HarmonyLevel/
├── AppScope/                          # 应用级配置（app.json5 / 图标 / 名称）
├── entry/src/main/
│   ├── module.json5                   # 模块配置（0 权限，phone/tablet/2in1）
│   ├── ets/
│   │   ├── entryability/EntryAbility.ets
│   │   ├── pages/
│   │   │   ├── Index.ets              # 首页：模式卡片 + 最近 3 条测量
│   │   │   ├── BubblePage.ets         # 气泡水平仪
│   │   │   ├── RulerPage.ets          # 角度尺
│   │   │   ├── CalibratePage.ets      # 校准向导（三步置零）
│   │   │   ├── HistoryPage.ets        # 测量记录（自实现 IDataSource + LazyForEach）
│   │   │   └── SettingsPage.ets       # 灵敏度 / 声音 / 亮屏保持
│   │   ├── components/
│   │   │   ├── BubbleDial.ets         # Canvas 气泡表盘
│   │   │   ├── AngleRuler.ets         # Canvas 滚动刻度尺
│   │   │   ├── AngleBadge.ets         # 角度数字徽章（大字号 + 状态色）
│   │   │   └── TargetRing.ets         # 目标角度环（0/45/90 判定）
│   │   ├── data/
│   │   │   ├── SensorEngine.ets       # 订阅/解算/滤波/节流回调
│   │   │   ├── AngleSolver.ets        # 重力分量 → pitch/roll
│   │   │   ├── Filter.ets             # 一阶低通滤波器
│   │   │   ├── PrefsHelper.ets        # Preferences 封装
│   │   │   └── SoundHelper.ets        # 提示音（AVPlayer 短音）
│   │   └── model/Measure.ets          # MeasureRecord / CalibOffset / AppSettings
│   └── resources/
│       ├── base/                      # 主题色、字符串、图标、main_pages
│       └── rawfile/beep.wav           # 提示音
├── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```

## 数据模型

```ts
interface MeasureRecord { id: number; mode: string; angleX: number; angleY: number; ts: number }
interface CalibOffset  { x: number; y: number }        // 校准基准角（度）
interface AppSettings  { sensitivity: number; sound: boolean; keepScreenOn: boolean }
```

存储键（Preferences `level_store`）：`history_list`（JSON 数组，上限 200 条 FIFO）、`calib_offset`、`settings`。

## 传感器生命周期

- 测量页 `onPageShow` 读取设置/校准后订阅传感器；`onPageHide` 与 `aboutToDisappear` 均执行 `sensor.off(sensor.SensorId.ACCELEROMETER)`，确保退订清理
- 原始高频回调不直接触发 build：`SensorEngine` 内先低通滤波（三轴各自持有 `LowPassFilter`），解算后按 30ms 节流回调页面；组件 Canvas 重绘再按 16ms 节流

## 构建方式

```bash
# DevEco Studio
导入工程目录 → Build → Build Hap(s)/APP(s)

# 命令行（hvigor）
hvigorw assembleHap --mode module -p product=default
```

运行设备：phone / tablet / 2in1（API 10+）。

## 隐私说明

纯传感器应用：不联网、不采集个人数据、不申请任何权限。Preferences 仅存储用户本地测量记录与偏好。
