# HarmonyMath 口算小达人

一款纯离线的 HarmonyOS（ArkTS，ArkUI 声明式 V1 装饰器体系）小学生数学口算训练应用。

## 功能

- **四种练习模式**：加减法 / 乘除法 / 混合运算 / 错题重练
- **三档难度**：简单（10 以内）、普通（100 以内）、困难（乘法口诀 + 两步带括号运算）
- **限时模式**：不限时 / 60 秒 / 120 秒，倒计时进度条实时展示
- **答题反馈**：自定义数字键盘输入；答对绿色放大动画 + 短震动，答错红色提示 + 长震动，并给出正确答案
- **结果页**：得分 / 正确率 / 用时 / 错题摘要，自动写入练习记录、更新连续打卡、判断成就解锁（6 枚徽章：首次练习、连击 3 天、连击 7 天、百题斩、千题王、全对一轮）
- **错题本**：错题列表（题干 / 正确答案 / 错误次数 / 上次作答），支持重练、标记已掌握、清空
- **统计页**：近 7 天练习量 Canvas 柱状图 + 正确率折线、当月打卡日历、累计轮数 / 题数 / 正确率 / 连续打卡
- **乘法口诀表**：9×9 网格，点击单元格高亮整行整列，并展示对应口诀
- 每日目标进度、音效 / 震动开关（偏好设置本地持久化）

## 架构

```
HarmonyMath/
├── AppScope/                        # 应用级配置与资源
├── entry/src/main/
│   ├── module.json5                 # 模块配置（仅申请 ohos.permission.VIBRATE）
│   ├── ets/
│   │   ├── entryability/EntryAbility.ets     # Ability 入口，onCreate 初始化 RDB 与 Preferences
│   │   ├── pages/                           # 6 个页面（均注册于 main_pages.json）
│   │   │   ├── Index.ets                    # 首页：打卡天数、模式/难度/限时选择、底部导航
│   │   │   ├── PracticePage.ets             # 练习页：出题、判分、震动反馈、限时
│   │   │   ├── ResultPage.ets               # 结果页：成绩、错题入库、打卡、成就
│   │   │   ├── WrongBookPage.ets            # 错题本
│   │   │   ├── StatsPage.ets                # 统计（Canvas 图表 + 打卡日历）
│   │   │   └── TimesTablePage.ets           # 乘法口诀表
│   │   ├── components/                      # 4 个复用组件
│   │   │   ├── KeypadComponent.ets          # 数字键盘（@Link 双向绑定输入值）
│   │   │   ├── QuestionCard.ets             # 题目卡片（题干/答案/倒计时进度条/反馈动画）
│   │   │   ├── BarChartComponent.ets        # Canvas 柱状图 + 正确率折线
│   │   │   └── BadgeComponent.ets           # 成就徽章（解锁高亮 / 未解锁灰色）
│   │   ├── data/                            # 数据层
│   │   │   ├── QuestionGenerator.ets        # 纯函数题目生成器（整除、非负、去重）
│   │   │   ├── RdbHelper.ets                # relationalStore 单例（3 张表）
│   │   │   └── PreferencesUtil.ets          # preferences 轻量存储
│   │   ├── model/                           # 数据模型 / 主题 / 成就规则
│   │   └── utils/DateUtil.ets               # 日期工具
│   └── resources/base/profile/main_pages.json
├── build-profile.json5 / oh-package.json5 / hvigorfile.ts（根 + entry）
├── privacy_statement.json          # 纯离线、数据仅本地
└── README.md
```

### 数据表（RDB，harmonymath.db）

- `practice_record(id, date, mode, difficulty, total, correct, duration_sec, created_at)`
- `wrong_question(id, stem, answer, user_answer, wrong_count, mastered, created_at)`
- `achievement(id, key UNIQUE, unlocked_at)`

### 技术约定

- 统一 V1 装饰器体系（@Entry / @Component / @State / @Prop / @Link / @Watch / @Builder）
- 统一 `@ohos.*` 风格 import；数据库 / 偏好全部 async/await + BusinessError 错误处理
- 题目生成器为纯函数逻辑，不依赖 UI；同轮题干去重；除法保证整除、结果非负

## 构建方式

1. 使用 DevEco Studio 打开工程根目录；
2. File → Project Structure → Signing Configs 配置自动签名（或使用命令行签名）；
3. 点击 Build → Build Hap(s) / Run，或命令行：

```bash
hvigorw assembleHap --mode module -p product=default
```

> 说明：`app_icon.png` 为 1×1 蓝色像素占位图（二进制 PNG，避免提交无效文件）。正式发布前请在 DevEco Studio 的 Image Asset 工具中替换为真实应用图标。

## 隐私

应用纯离线运行，不联网、不采集任何个人信息；所有数据仅存于设备本地（卸载即清除）。仅申请震动权限用于答题反馈，详见 `privacy_statement.json`。
