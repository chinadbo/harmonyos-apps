# HarmonyChrono 秒表应用 — 完整编码任务

请在工作目录 `~/.openclaw/code/harmonyos-apps/apps/HarmonyChrono/` 下实现一个完整的 HarmonyOS 秒表应用。

## 项目结构（必须严格按以下结构创建所有文件）

```
HarmonyChrono/
├── AppScope/
│   ├── app.json5
│   └── resources/
│       └── base/
│           └── element/
│               ├── string.json
│               └── color.json
├── entry/
│   ├── src/main/
│   │   ├── module.json5
│   │   ├── ets/
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets
│   │   │   ├── model/
│   │   │   │   ├── SessionModel.ets
│   │   │   │   ├── DataStore.ets
│   │   │   │   └── TimerServiceModel.ets
│   │   │   ├── services/
│   │   │   │   └── TimerService.ets
│   │   │   ├── pages/
│   │   │   │   ├── StopwatchPage.ets
│   │   │   │   ├── HistoryPage.ets
│   │   │   │   ├── SessionDetailPage.ets
│   │   │   │   ├── SettingsPage.ets
│   │   │   │   └── WorkoutModePage.ets
│   │   │   ├── components/
│   │   │   │   ├── CircularProgress.ets
│   │   │   │   ├── LapItem.ets
│   │   │   │   ├── TimerDisplay.ets
│   │   │   │   └── SessionCard.ets
│   │   │   └── common/
│   │   │       ├── constants.ts
│   │   │       ├── utils.ts
│   │   │       └── styles.ts
│   │   └── resources/
│   │       └── base/
│   │           ├── profile/
│   │           │   └── main_pages.json
│   │           └── element/
│   │               ├── string.json
│   │               └── color.json
│   ├── build-profile.json5
│   └── oh-package.json5
├── privacy_statement.json
└── README.md
```

## 编码规范

1. **装饰器统一 V1 体系**：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
2. **Import 风格**：@ohos.* 风格（如 `import timer from '@ohos.timer'`）
3. **禁止** @ComponentV2/@ObservedV2 等 V2 装饰器
4. **权限最小化**：只申请实际用到的权限
5. 所有文件必须创建，不允许跳过

## 功能详细要求

### 1. 秒表核心功能
- 启动/暂停/继续/重置（同一按钮不同状态）
- 毫秒级精确计时，显示格式：MM:SS.mmm（分钟:秒.毫秒）
- 分段计时（Lap）：点击记录当前时间并继续计时
- 分段对比：最快圈速绿色高亮，最慢圈速红色高亮

### 2. 数据层（RDB 存储）
- DataStore.ets 封装所有 CRUD 操作
- sessions 表：id(pk), name, startTime, endTime, duration, createdAt
- laps 表：id(pk), sessionId(fk), lapNumber, lapTime, totalTime, createdAt
- settings 表：id(pk), key, value（键值对存储设置）
- 会话自动保存，应用重启后可通过 SessionModel 恢复

### 3. 后台服务
- 使用 @ohos.timer 的 createTimer 实现 10ms 精度计时
- 应用切后台后计时继续运行
- 使用系统通知显示当前计时状态

### 4. UI 页面

#### StopwatchPage.ets（主页）
- 顶部：圆形进度条（CircularProgress 组件）显示当前时间进度
- 中间：大数字计时显示（TimerDisplay 组件），颜色根据状态变化（运行=绿色，暂停=橙色）
- 底部：控制按钮行（Start/Pause/Reset/Lap）
- 下方可滚动分段列表（LapItem 组件）

#### HistoryPage.ets
- 历史会话列表（倒序排列，最新在前）
- 每个会话用 SessionCard 组件展示
- 点击卡片进入 SessionDetailPage

#### SessionDetailPage.ets
- 显示分段时间详情列表
- 统计信息：总时长、圈数、平均圈速、最快/最慢圈速
- 分段对比高亮

#### SettingsPage.ets
- 声音开关、振动开关、主题选择（浅色/深色）、计时精度选择

#### WorkoutModePage.ets
- 训练模式：预设训练计划（如间歇训练）
- 预设模板：1分钟快/30秒慢、400米间歇等
- 自定义训练计划

### 5. 组件

#### CircularProgress.ets
- Canvas 绘制圆形进度条，外圈灰色背景 + 内圈彩色进度弧
- 使用 animateTo 实现平滑动画
- 属性：size(尺寸), progress(0-1), color(进度颜色)

#### LapItem.ets
- 分段列表项，显示序号、分段耗时、累计耗时
- 最快圈绿色，最慢圈红色

#### TimerDisplay.ets
- 大数字显示组件，格式：MM:SS.mmm
- 颜色根据状态变化

#### SessionCard.ets
- 会话卡片，显示会话名称、日期、时长、圈数

### 6. 模型层

#### SessionModel.ets
- 管理当前会话状态（运行/暂停/停止）
- 管理分段列表
- 与 DataStore 交互

#### TimerServiceModel.ets
- 封装计时器逻辑，使用 @ohos.timer 的 createTimer，10ms 精度

#### DataStore.ets
- RDB 数据库初始化，三张表的 CRUD，异步操作

### 7. 服务层

#### TimerService.ets
- 后台计时服务，通知管理，持久化定时器

### 8. 公共代码

#### constants.ts
- 应用常量定义（颜色、尺寸、键名等）

#### utils.ts
- 时间格式化、毫秒转时分秒等工具函数

#### styles.ts
- 全局样式定义

### 9. 配置类文件

#### app.json5 / module.json5 / main_pages.json / string.json / color.json
- 标准 HarmonyOS 配置文件

#### build-profile.json5 / oh-package.json5 / privacy_statement.json / README.md
- 构建配置、包依赖、隐私声明、文档

## 注意事项
- 所有 .ets 文件必须使用 V1 装饰器体系
- 所有导入使用 @ohos.* 风格
- RDB 数据库操作使用异步方式
- 计时器使用 @ohos.timer 模块
- 通知使用 @ohos.notificationManager
- 确保所有文件都被创建，不允许遗漏
