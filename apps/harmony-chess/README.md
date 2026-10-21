# HarmonyChess — 鸿蒙国际象棋

> 品类：棋类游戏 / 国际象棋 / 策略 / 教育

HarmonyOS 原生国际象棋 App，集成**人机对弈、双人对弈、PGN 棋谱学习**三大场景，纯离线运行，无网络权限。

## 功能

- 🎯 **完整棋规引擎**：吃过路兵、王车易位、兵升变、50 回合和棋、将军/将杀/逼和判定
- 🤖 **3 档 AI 对手**：Lv1 随机 / Lv2 贪婪评估 / Lv3 Minimax 深度 2 + alpha-beta 剪枝
- 📖 **PGN 棋谱库**：标准 PGN 格式保存/加载/复盘回放
- 🎨 **Canvas 自绘棋盘**：8x8 交替色 + Unicode 棋子 + 高亮提示（选中/合法走法/最近一步/将军）
- 📳 **振动反馈**：走子时振动（可关）
- 🌗 **双视角**：支持黑白方翻转棋盘

## 页面

| 页面 | 说明 |
|------|------|
| HomePage | 首页：模式选择 |
| GamePage | 对弈主界面（棋盘 + 历史 + 控制条） |
| PgnListPage | 棋谱列表 |
| ReplayPage | 复盘回放（前进/后退/跳转） |
| SettingsPage | AI 难度/振动/主题设置 |

## 架构

```
ets/
├── entryability/        EntryAbility 入口
├── pages/               5 个 @Entry 页面
├── components/          ChessBoard / PromotionDialog / GameOverDialog / MoveHistory
├── engine/              ChessEngine / MoveGenerator / Evaluator / AIService
├── model/               Types (GameState/Move/Piece) / Fen
├── pgn/                 SanCodec / PgnParser
├── service/             StorageService (Preferences) / SoundService (vibrator)
└── common/              Constants / Logger
```

## 核心算法

- **合法走法生成**：分兵种生成伪合法走法 → 模拟走后己方王是否被将军 → 过滤
- **王车易位判定**：本行无阻挡 + 王/车未动 + 王经过的三格均不被攻击
- **吃过路兵**：state.enPassant 记录上一步双进兵的中间格
- **SAN 冲突消解**：同兵种多源时加列号；列号仍歧义时加行号
- **Minimax AI**：深度 2 + alpha-beta 剪枝 + 位置权重表（兵/马/王）

## 技术亮点

- **纯 V1 装饰器**：@Component + @State/@Prop/@Link/@StorageLink
- **@ohos.* 导入**：不使用 @kit.*
- **CanvasRenderingContext2D**：自绘棋盘，无图片资源依赖
- **preferences 持久化**：棋谱库本地存储
- **FEN 标准格式**：完整的 6 段 FEN 解析/生成

## 权限

仅需 `ohos.permission.VIBRATE`（走子振动）。**无网络权限，完全离线**。

## 构建

需要 DevEco Studio 5.0+ 和 HarmonyOS API 12 SDK：

```bash
hvigor assembleHap
```

或在 DevEco Studio 中打开本目录，点击 Build → Build Hap(s)。

## 自测

引擎层 `ChessEngine.perft(state, depth)` 可用于性能测试，验证走子生成正确性：
- perft(initial, 1) = 20
- perft(initial, 2) = 400
- perft(initial, 3) = 8902

## License

Apache-2.0
