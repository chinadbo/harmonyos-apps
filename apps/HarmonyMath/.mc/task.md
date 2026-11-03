# 任务：完整实现 HarmonyMath 鸿蒙应用

工作目录：当前目录（HarmonyMath）。请完整实现一个可编译的 HarmonyOS ArkTS 应用：小学生数学口算训练。

## 必读
- `.mc/CONTEXT.md`：编码规范（V1 装饰器、@ohos.* import、常见陷阱）。必须严格遵守。

## 设计文档
按以下架构实现（模块划分、数据模型、API 规范以此为准）：

### 页面（6个，注册进 main_pages.json）
1. **Index.ets** — 首页：显示连续打卡天数，4 种模式入口（加减/乘除/混合/错题重练），难度选择（3档），进入练习页；底部导航到统计页/口诀表/错题本
2. **PracticePage.ets** — 练习页：接收模式+难度参数，题目卡片显示题干，自定义数字键盘输入，即时判分（答对绿色动画+震动，答错红色+震动），60s/120s 可选限时模式，答完或超时跳结果页
3. **ResultPage.ets** — 结果页：得分/正确率/用时/错题列表摘要，写入 practice_record 表，更新打卡（streak_days），解锁成就判断，按钮"再来一组"/"返回首页"
4. **WrongBookPage.ets** — 错题本：wrong_question 列表（题干/正确答案/错误次数），支持重练（跳 PracticePage wrongMode）、标记已掌握、清空
5. **StatsPage.ets** — 统计页：近 7 天练习量 Canvas 柱状图 + 正确率折线，打卡日历视图（当月），累计总数
6. **TimesTablePage.ets** — 乘法口诀表：9x9 网格展示，点击单元格高亮整行整列

### 组件（4个）
- KeypadComponent：数字键盘（0-9、清除、确认），@Link 输入值回调
- BarChartComponent：Canvas 柱状图，@Prop 数据数组
- BadgeComponent：成就徽章（已解锁高亮/未解锁灰色）
- QuestionCard：题目卡片（题干大字、用户答案、倒计时进度条）

### 数据层
- QuestionGenerator.ets：纯逻辑生成器。模式 add/sub/mul/div/mixed/wrong；难度 1(10以内)/2(100以内)/3(乘法口诀+两步带括号)；除法整除、结果非负；同轮题干去重
- RdbHelper.ets：relationalStore，3 表见下；单例；async/await + BusinessError
- PreferencesUtil.ets：streak_days/last_practice_date/sound_on/vibrate_on/daily_goal

### RDB 表
```sql
practice_record(id, date TEXT, mode TEXT, difficulty INTEGER, total INTEGER, correct INTEGER, duration_sec INTEGER, created_at INTEGER)
wrong_question(id, stem TEXT, answer INTEGER, user_answer INTEGER, wrong_count INTEGER DEFAULT 1, mastered INTEGER DEFAULT 0, created_at INTEGER)
achievement(id, key TEXT UNIQUE, unlocked_at INTEGER)
```

### 成就规则
first_practice（首次练习）/ streak_3 / streak_7（连续打卡）/ total_100 / total_1000（累计题数）/ perfect_10（单轮全对）

## 项目文件清单（必须齐全）
- AppScope/app.json5、AppScope/resources/base/element/string.json、AppScope/resources/base/media/（app_icon 用简单占位 png 可以用现有默认样式描述，若无法生成二进制 png 则在 README 说明）
- entry/src/main/module.json5（含 VIBRATE 权限声明）
- entry/src/main/ets/entryability/EntryAbility.ets（onCreate 初始化 RDB + Preferences）
- entry/src/main/resources/base/profile/main_pages.json（6 页面）
- entry/src/main/resources/base/element/string.json（应用名等）
- build-profile.json5、oh-package.json5（根 + entry）
- privacy_statement.json（纯离线、数据仅本地）
- README.md（功能/架构/构建方式）

## 质量要求
- 每个 .ets 文件 import 正确、无未使用变量
- UI 用 Stack/Column/Row/Flex 布局，配合 @State 动画（transition/animateTo）
- 代码总量的目标：30+ 文件、2000 行左右 ArkTS
- 完成后自检：所有页面在 main_pages.json 注册、所有 import 的模块真实存在、无 V2 装饰器
