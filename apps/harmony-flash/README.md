# HarmonyFlash 🃏

基于 **SM-2 间隔重复算法**的鸿蒙原生单词/闪卡学习 App，帮助你科学记忆，终身学习。

## ✨ 功能特性

- **SM-2 间隔重复** — 经典艾宾浩斯遗忘曲线算法，智能调度复习时间
- **3D 翻卡动画** — 流畅的 rotateY 翻转效果，沉浸式学习体验
- **内置 CET-4 词库** — 开箱即用 20 个大学英语四级高频词汇
- **自定义词库** — 创建任意主题的词库和闪卡
- **CoreSpeech TTS 发音** — 点击发音按钮即可听单词朗读
- **每日单词 Widget** — 2×2 桌面小组件，随时查看今日推荐词
- **学习统计** — 连续打卡天数、近7天折线图、各词库掌握率

## 🏗️ 架构

```
entry/src/main/ets/
├── entryability/         # UIAbility 入口
├── entryformability/     # Widget FormExtensionAbility
├── algorithm/            # SM-2 间隔重复算法
├── database/             # RDB 数据层（DeckDao/CardDao/StudyRecordDao）
├── model/                # 数据模型（Deck/Card/StudyRecord）
├── service/              # 服务（TTS/种子数据）
├── components/           # 复用组件（FlashCard/StatsChart/DeckCard/EmptyState）
└── pages/                # 页面（Index/DeckList/DeckDetail/CardEdit/Study/Stats/Settings）
```

## 📐 核心技术

| 技术 | 用途 |
|------|------|
| `@ohos.data.relationalStore` | RDB 本地数据库，存储词库/卡片/学习记录 |
| SM-2 Algorithm | 间隔重复调度，easeFactor + interval + repetitions |
| `@ohos.ai.textToSpeech` | 单词发音（canIUse 门控，不可用时静默降级） |
| `FormExtensionAbility` | 桌面 Widget，FormBindingData 传递今日单词 |
| Canvas + CanvasRenderingContext2D | 自绘折线图，无第三方依赖 |
| rotateY + animateTo | 3D 翻卡动画 |

## 🔧 构建方式

1. 使用 DevEco Studio 4.1 或更高版本打开项目
2. 签名配置：Project → Signing Configs
3. 连接真机或启动模拟器，点击 Run

**依赖：** API 12（HarmonyOS 5.0+），无三方库依赖

## 📂 数据模型

### Deck（词库）
```typescript
{ id, name, description, cardCount, masteredCount, createdAt, isBuiltIn }
```

### Card（闪卡）
```typescript
{ id, deckId, front, back, phonetic, example, easeFactor, interval, repetitions, nextReviewDate, masteryLevel }
```

## 🧠 SM-2 算法

| quality | 含义 | 行为 |
|---------|------|------|
| 0 | 完全不记得 | 重置 repetitions=0, interval=1 |
| 3 | 困难但记得 | 正常推进间隔，更新 EF |
| 5 | 轻松记得 | 正常推进间隔，提升 EF |

- `easeFactor` 最小值 1.3，防止间隔缩得过短
- 第1次复习：1天后；第2次：6天后；之后：interval × EF 天后

## 📊 数据存储

所有数据均存储在设备本地 `harmonyflash.db`（SQLite），不上传服务器，无需任何网络权限。

## 🔒 权限声明

本 App 无需任何特殊权限。TTS 使用系统内置能力，数据本地存储。

## 📝 License

MIT
