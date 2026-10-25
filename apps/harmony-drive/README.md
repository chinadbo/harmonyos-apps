# HarmonyDrive 驾考通

HarmonyOS 驾驶员考试学习应用（纯离线，0 权限）。覆盖科目一 / 科目四题库刷题、100 题限时模拟考试、错题本、专项练习、考点速记与学习统计，并附带"每日一题"桌面卡片（Widget）。

## 功能

| 模块 | 说明 |
|------|------|
| 首页 Index | 题库完成度 / 今日刷题数 / 错题数 / 总正确率进度总览 + 六大功能入口 + 每日一题摘要，科目一/科目四一键切换 |
| 顺序练习 PracticePage | 全量顺序刷题 + 章节筛选，选择即判分、即时解析，进度自动续刷（Preferences） |
| 模拟考试 ExamPage | 100 题限时 45 分钟，倒计时告警（最后 5 分钟变红），答题卡面板、未答题提醒、自动交卷 |
| 成绩单 ExamResultPage | 分数环 + 合格判定（90 分）+ 薄弱章节 + 一键再考 / 查看错题本 |
| 错题本 WrongBookPage | 错题列表（错误次数、最近错误时间），勾选批量移除、一键全部重刷 |
| 专项练习 SpecialPage | 罚款处罚 / 记分规则 / 信号标志 / 事故处理 / 综合常识 五类考点专项突破 |
| 考点速记 TipsPage | Swiper 翻卡速记，正面问题反面要点，覆盖记分、罚款、标志、急救等高频考点 |
| 学习统计 StatsPage | 近 7 天正确率 Canvas 折线图（自绘网格、数据点、数值标签）+ 章节掌握度条 |
| 每日一题卡片 QuestionWidget | 2x2 桌面卡片，FormExtensionAbility 按日推送题目，点击直达练习页 |

## 架构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets   # 入口：题库/RDB/Preferences 初始化
├── data/
│   ├── Question.ets                # 数据模型 + 专项 tag / 考试常量
│   ├── QuestionBank.ets            # rawfile JSON 解析、章节索引、组卷、每日一题
│   ├── ExamEngine.ets              # 模拟考试引擎（组卷/限时/评分/入库）
│   └── StatsHelper.ets             # 正确率趋势、章节掌握度统计
├── store/
│   ├── DbHelper.ets                # RDB（relationalStore）：answer_record / wrong_book
│   └── PrefsHelper.ets             # Preferences：练习进度 / 当前科目 / 刷题打卡
├── components/
│   ├── QuestionCard.ets           # 题目卡片（题干/选项/判分/解析展开）
│   ├── OptionItem.ets              # 选项条目（正确/错误着色）
│   ├── ExamResultCard.ets          # 考试结果卡（分数环/薄弱章节）
│   └── MasteryBar.ets              # 章节掌握度条
├── pages/                          # 8 个页面（见上表）
└── widget/
    ├── QuestionWidget.ets          # FormExtensionAbility（onAddForm/onUpdateForm）
    └── pages/QuestionWidgetCard.ets # 2x2 卡片 UI，postCardAction 路由
```

- 题库：`entry/src/main/resources/rawfile/bank_subject1.json`（110 题）、`bank_subject4.json`（100 题），
  每题含 id / subject / chapter / tag / type / stem / options / answer / explanation。
- 持久化：RDB（`relationalStore.getRdbStore`，S1 安全等级）存答题记录与错题本；
  Preferences（`dataPreferences.getPreferences`）存练习进度与科目设置。
- 技术规范：V1 装饰器体系（@Component/@State/@Prop/@StorageLink…）、`@ohos.*` import 风格、Canvas onReady 后自绘折线图、setInterval 句柄在 aboutToDisappear 中清理。

## 权限

**0 权限**。`module.json5` 不含任何 `requestPermissions`，应用不联网、不采集任何数据，全部学习数据仅存于本机应用沙箱（隐私声明见 `privacy_statement.json`）。

## 构建

1. DevEco Studio 5.0+（HarmonyOS SDK，compatibleSdkVersion 5.0.0(12)）打开工程根目录。
2. `File > Sync and Refresh` 同步 oh-package 依赖。
3. 连接真机或启动模拟器，`Build > Build Hap(s)/APP`，或命令行：
   ```bash
   hvigorw assembleHap   # debug 构建 entry-default
   ```
4. 运行 `entry` 模块即可启动；桌面长按添加"驾考每日一题" 2x2 卡片体验 Widget。
