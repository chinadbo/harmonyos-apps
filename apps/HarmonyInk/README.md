# HarmonyInk · 墨迹笔顺

面向儿童及汉字初学者的汉字笔顺练习应用（HarmonyOS ArkTS，API 16）。内置一年级常用字笔画数据，以动画演示标准笔顺，用户在田字格中逐笔临摹，应用从**顺序、方向、覆盖度**三个维度实时评分并记录掌握度。

纯离线运行，无网络权限，仅申请 `ohos.permission.VIBRATE`。

## 功能

- **今日推荐 / 首页**：年级切换、每日一字、学习进度概览、最近练习。
- **字库**：按年级、笔画数（1-3 / 4-6 / 7+）筛选，支持汉字或拼音搜索，显示每字掌握度。
- **字详情**：Canvas 笔顺动画（播放 / 暂停 / 单步 / 重播、速度可调）、笔画类型拆解、练习记录。
- **临摹练习**（核心）：田字格 + 半透明底字引导，`onTouch` 逐点采集轨迹；按顺序 / 方向 / 覆盖度实时提示与单笔评分，全部笔画通过后生成整字得分，支持提示、重写、下一字。
- **统计**：总练习次数、已练字数、平均分、掌握度、近 28 天热力图、单字掌握度排行、最近记录。
- **设置**：动画速度、笔刷粗细、触觉反馈开关、重置练习数据、隐私说明。

## 技术栈

- ArkTS + ArkUI 声明式 UI，**V1 装饰器体系**（`@Component` / `@State` / `@Prop` / `@Watch`）
- Canvas 2D（`CanvasRenderingContext2D`）绘制田字格、笔顺动画、临摹轨迹
- `@ohos.data.relationalStore` 持久化练习记录
- `@ohos.data.preferences` 保存用户设置
- `@ohos.vibrator` 书写触觉反馈
- 统一 `@ohos.*` import 风格，未使用 `@kit.*`

## 目录结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets
├── pages/
│   ├── Index.ets            # 首页
│   ├── CharList.ets         # 字库列表
│   ├── CharDetail.ets       # 字详情 / 笔顺动画
│   ├── Practice.ets         # 田字格临摹 + 实时评分
│   ├── Stats.ets            # 统计 / 热力图
│   └── Settings.ets         # 设置
├── components/
│   ├── GridCell.ets         # 田字格组件（Canvas）
│   ├── StrokeAnim.ets       # 笔顺动画组件
│   ├── ScorePanel.ets       # 评分结果面板
│   └── ProgressRing.ets     # 掌握度进度环
├── engine/
│   ├── TraceMatcher.ets     # 轨迹匹配（起点 / 方向 / 覆盖度）
│   └── StrokeScorer.ets     # 笔顺评分算法
├── model/
│   ├── CharData.ets         # 笔画数据结构 + 字库仓库
│   └── PracticeRecord.ets   # 练习记录 / 掌握度
├── db/DbHelper.ets          # RDB 封装
└── common/
    ├── Constants.ets        # 常量
    ├── Theme.ets            # 主题 + 田字格绘制
    └── AppUtil.ets          # 设置 / 震动 / 日期工具

entry/src/main/resources/rawfile/chars.json   # 113 字笔画数据
tools/gen_chars.py                            # 笔画数据生成脚本
tools/stroke_gen.py                           # 笔画路径生成辅助库
```

> 架构文档中 `data/chars.json` 标注为 rawfile，实际放置于 `entry/src/main/resources/rawfile/chars.json`，通过 `resourceManager.getRawFileContent` 读取。

## 数据格式

```jsonc
{
  "char": "十",
  "pinyin": "shí",
  "grade": 1,
  "strokes": [
    {
      "index": 1,
      "type": "横",
      "points": [ { "x": 14, "y": 48 }, ... ],  // 0-100 归一化折线采样点
      "startDir": -2.9                          // 起笔方向角（度，y 轴向下）
    }
  ]
}
```

内置 113 个常用字（103 个一年级、10 个二年级扩展），共 581 笔，覆盖横、竖、撇、捺、点、提、横折、竖钩、横折钩、竖弯钩、撇折、卧钩等 21 类笔画。

### 重新生成数据

```bash
cd tools
python3 gen_chars.py
```

脚本使用横平竖直折线与二次贝塞尔曲线近似楷体笔顺，按弧长等距重采样（约 2.2 个归一化单位），并自动计算每笔 `startDir`。

## 评分算法

用户一笔输入 = 归一化点序列 P，当前标准笔画 = S：

1. **顺序（40 分）**：P 起点到 S 起点的距离 d，`startRatio = clamp(1 - d/15)`；d < 15 即顺序正确。
2. **方向（30 分）**：取 P 前 18% 弧长的主方向与 `S.startDir` 的夹角 θ，`dirRatio = clamp(1 - θ/45°)`。
3. **覆盖度（30 分）**：P 各点到 S 折线的最小距离均值 m，`coverRatio = clamp(1 - m/18)`。
4. **单笔分** = 40×startRatio + 30×dirRatio + 30×coverRatio；≥60 且起笔顺序正确才进入下一笔。
5. **整字分** = 单笔平均分，全程无重试额外 +5，封顶 100。

掌握度 = 最佳分 × 80% + 练习频次（最多 6 次）× 20%；**最佳分 ≥85 且练习 ≥3 次**视为已掌握。

## RDB 表结构

```sql
CREATE TABLE practice (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  char text NOT NULL,
  score integer NOT NULL,
  stroke_count integer NOT NULL,
  duration_ms integer NOT NULL,
  created_at integer NOT NULL
);
```

聚合查询使用 `GROUP BY char` 得到每字最佳分 / 次数 / 平均分，按 `strftime('%Y-%m-%d', ...)` 生成每日热力图数据。

## 构建运行

1. 使用 DevEco Studio（HarmonyOS NEXT 5.0.4 / API 16 SDK）打开项目根目录。
2. 等待 `oh-package` 同步完成（首次打开时 IDE 会自动补全 hvigor wrapper 与签名配置）。
3. 连接真机或启动模拟器，运行 `entry` 模块。

最低兼容版本已在根目录 `build-profile.json5` 中声明为 `5.0.4(16)`，无需额外三方依赖。

## 隐私

- 无网络、无媒体、无位置权限，仅 `ohos.permission.VIBRATE`。
- 全部字库随安装包内置；练习记录仅存本机，可在设置页清除。
- 详见根目录 `privacy_statement.json`。

## 已知边界

- 笔画路径为程序化折线近似，用于练习引导与评分，不替代书法字帖。
- 低年级字库以一年级为主，其余年级可继续扩充 `tools/gen_chars.py`。
- 评分对起笔位置较敏感，练习时请从金色圆点起笔。
