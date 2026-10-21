import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GameState, Move, Pos, PieceType, Color, GameRecord, posEq, cloneState } from '../model/Types';
import { ChessEngine } from '../engine/ChessEngine';
import { AIService } from '../engine/AIService';
import { MoveGenerator } from '../engine/MoveGenerator';
import { PgnParser } from '../pgn/PgnParser';
import { StorageService } from '../service/StorageService';
import { SoundService } from '../service/SoundService';
import { ChessBoard } from '../components/ChessBoard';
import { PromotionDialog } from '../components/PromotionDialog';
import { GameOverDialog } from '../components/GameOverDialog';
import { MoveHistory } from '../components/MoveHistory';

interface RouterParams {
  mode: string;
  level: number;
}

@Entry
@Component
struct GamePage {
  @State gameState: GameState = ChessEngine.initial();
  @State selected: Pos | null = null;
  @State legalTargets: Array<Pos> = [];
  @State lastMove: Move | null = null;
  @State checkPos: Pos | null = null;
  @State orientation: string = 'white';
  @State mode: string = 'pvp';
  @State aiLevel: number = 0;
  @State statusText: string = '白方走棋';
  @State redrawNonce: number = 0;
  @State aiThinking: boolean = false;

  private promotionController: CustomDialogController | null = null;
  private gameOverController: CustomDialogController | null = null;
  private pendingPromotionFrom: Pos | null = null;
  private pendingPromotionTo: Pos | null = null;

  aboutToAppear(): void {
    const params = router.getParams() as RouterParams;
    if (params) {
      if (params.mode) this.mode = params.mode;
      if (params.level) this.aiLevel = params.level;
    }
    this.refreshStatus();
  }

  private refreshStatus(): void {
    const s = this.gameState;
    if (s.status === 'checkmate') {
      this.statusText = (s.winner === Color.White ? '白方' : '黑方') + '获胜（将杀）';
    } else if (s.status === 'stalemate') {
      this.statusText = '逼和';
    } else if (s.status === 'draw50') {
      this.statusText = '和棋（50回合）';
    } else if (s.status === 'resigned') {
      this.statusText = (s.winner === Color.White ? '白方' : '黑方') + '获胜（对手认输）';
    } else if (s.status === 'agreed') {
      this.statusText = '和棋（协议）';
    } else {
      const turn = s.turn === Color.White ? '白方' : '黑方';
      if (ChessEngine.isInCheck(s, s.turn)) {
        this.statusText = turn + '走棋 · 被将军！';
      } else {
        this.statusText = turn + '走棋';
      }
    }
    // 将军格
    if (ChessEngine.isInCheck(s, s.turn)) {
      this.checkPos = MoveGenerator.findKing(s, s.turn);
    } else {
      this.checkPos = null;
    }
  }

  private onSquareTap(pos: Pos): void {
    if (this.aiThinking) return;
    if (this.gameState.status !== 'active') return;

    // AI 模式下，玩家只控制白方
    if (this.mode === 'ai' && this.gameState.turn === Color.Black) return;

    const s = this.gameState;
    const piece = s.board[pos.row][pos.col];

    if (this.selected === null) {
      // 第一次点击：选中己方棋子
      if (piece !== null && piece.color === s.turn) {
        this.selected = pos;
        const moves = ChessEngine.legalMoves(s, pos);
        const targets: Array<Pos> = [];
        for (const m of moves) {
          targets.push(m.to);
        }
        this.legalTargets = targets;
      }
      this.redrawNonce++;
      return;
    }

    // 已选中：再点
    if (posEq(this.selected, pos)) {
      this.selected = null;
      this.legalTargets = [];
      this.redrawNonce++;
      return;
    }
    // 点自己另一个棋子 → 改选
    if (piece !== null && piece.color === s.turn) {
      this.selected = pos;
      const moves = ChessEngine.legalMoves(s, pos);
      const targets: Array<Pos> = [];
      for (const m of moves) {
        targets.push(m.to);
      }
      this.legalTargets = targets;
      this.redrawNonce++;
      return;
    }
    // 点目标：尝试走子
    const from = this.selected;
    const moves = ChessEngine.legalMoves(s, from);
    let chosen: Move | null = null;
    const promoMoves: Array<Move> = [];
    for (const m of moves) {
      if (m.to.row === pos.row && m.to.col === pos.col) {
        if (m.promotion !== null) {
          promoMoves.push(m);
        } else {
          chosen = m;
          break;
        }
      }
    }

    if (promoMoves.length > 0) {
      // 需要选升变
      this.pendingPromotionFrom = from;
      this.pendingPromotionTo = pos;
      this.showPromotionDialog();
      return;
    }

    if (chosen !== null) {
      this.executeMove(chosen);
    } else {
      this.selected = null;
      this.legalTargets = [];
      this.redrawNonce++;
    }
  }

  private showPromotionDialog(): void {
    this.promotionController = new CustomDialogController({
      builder: PromotionDialog({
        onSelect: (t: PieceType) => {
          this.onPromotionSelected(t);
        }
      }),
      autoCancel: false
    });
    this.promotionController.open();
  }

  private onPromotionSelected(t: PieceType): void {
    if (this.pendingPromotionFrom === null || this.pendingPromotionTo === null) return;
    const moves = ChessEngine.legalMoves(this.gameState, this.pendingPromotionFrom);
    for (const m of moves) {
      if (m.to.row === this.pendingPromotionTo.row
          && m.to.col === this.pendingPromotionTo.col
          && m.promotion === t) {
        this.executeMove(m);
        break;
      }
    }
    this.pendingPromotionFrom = null;
    this.pendingPromotionTo = null;
  }

  private executeMove(m: Move): void {
    let next = ChessEngine.applyMove(this.gameState, m);
    next = ChessEngine.updateStatus(next);
    this.gameState = next;
    this.lastMove = next.history[next.history.length - 1];
    this.selected = null;
    this.legalTargets = [];
    this.refreshStatus();
    this.redrawNonce++;
    SoundService.vibrate(30);

    if (next.status !== 'active') {
      this.onGameOver();
      return;
    }

    // AI 走子
    if (this.mode === 'ai' && next.turn === Color.Black) {
      this.aiThinking = true;
      setTimeout(() => {
        const aiMove = AIService.pickMove(this.gameState, this.aiLevel);
        if (aiMove !== null) {
          let after = ChessEngine.applyMove(this.gameState, aiMove);
          after = ChessEngine.updateStatus(after);
          this.gameState = after;
          this.lastMove = after.history[after.history.length - 1];
          this.refreshStatus();
          this.redrawNonce++;
          SoundService.vibrate(20);
          if (after.status !== 'active') {
            this.onGameOver();
          }
        }
        this.aiThinking = false;
      }, 100);
    }
  }

  private onGameOver(): void {
    const s = this.gameState;
    let title = '对局结束';
    let message = '';
    if (s.status === 'checkmate') {
      message = (s.winner === Color.White ? '白方' : '黑方') + '将杀获胜！';
    } else if (s.status === 'stalemate') {
      message = '逼和（无子可动）';
    } else if (s.status === 'draw50') {
      message = '和棋（50回合规则）';
    } else if (s.status === 'resigned') {
      message = (s.winner === Color.White ? '白方' : '黑方') + '获胜（认输）';
    } else if (s.status === 'agreed') {
      message = '和棋（协议）';
    }
    this.gameOverController = new CustomDialogController({
      builder: GameOverDialog({
        title: title,
        message: message,
        onConfirm: () => {
          this.saveGameRecord();
        },
        onCancel: () => {}
      }),
      autoCancel: false
    });
    this.gameOverController.open();
  }

  private saveGameRecord(): void {
    const s = this.gameState;
    let result = '*';
    if (s.status === 'checkmate' || s.status === 'resigned') {
      result = s.winner === Color.White ? '1-0' : '0-1';
    } else if (s.status === 'stalemate' || s.status === 'draw50' || s.status === 'agreed') {
      result = '1/2-1/2';
    }
    const white = this.mode === 'ai' ? 'Player' : 'White';
    const black = this.mode === 'ai' ? `AI-Lv${this.aiLevel}` : 'Black';
    const pgn = PgnParser.generate(s, white, black, result, this.mode);
    const rec: GameRecord = {
      id: 'g' + Date.now(),
      title: `${white} vs ${black} · ${new Date().toLocaleDateString()}`,
      pgn: pgn,
      result: result,
      createdAt: Date.now(),
      mode: this.mode,
      aiLevel: this.aiLevel
    };
    const ok = StorageService.saveRecord(rec);
    promptAction.showToast({ message: ok ? '棋谱已保存' : '保存失败' });
  }

  build() {
    Column() {
      // 顶部信息栏
      Row() {
        Button('← 返回')
          .fontSize(14)
          .height(36)
          .backgroundColor('#999999')
          .onClick(() => {
            router.back();
          })
        Blank()
        Text(this.statusText)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        Blank()
        Button(this.aiThinking ? '思考中' : '翻转')
          .fontSize(14)
          .height(36)
          .backgroundColor(this.aiThinking ? '#CCCCCC' : '#5B7DB1')
          .enabled(!this.aiThinking)
          .onClick(() => {
            this.orientation = this.orientation === 'white' ? 'black' : 'white';
            this.redrawNonce++;
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })

      // 棋盘
      ChessBoard({
        gameState: this.gameState,
        orientation: this.orientation,
        selected: this.selected,
        legalTargets: this.legalTargets,
        lastMove: this.lastMove,
        checkPos: this.checkPos,
        redrawNonce: this.redrawNonce,
        onSquareTap: (pos: Pos) => {
          this.onSquareTap(pos);
        }
      })
        .width('100%')

      // 走子历史（紧凑模式）
      Row() {
        MoveHistory({ history: this.gameState.history })
          .layoutWeight(1)
          .height(120)
      }
      .width('100%')
      .margin({ top: 8 })

      // 底部控制
      Row({ space: 8 }) {
        Button('认输')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#D9534F')
          .enabled(this.gameState.status === 'active' && !this.aiThinking)
          .onClick(() => {
            const next = cloneState(this.gameState);
            next.status = 'resigned';
            next.winner = this.mode === 'ai'
              ? Color.Black
              : (next.turn === Color.White ? Color.Black : Color.White);
            this.gameState = next;
            this.refreshStatus();
            this.redrawNonce++;
            this.onGameOver();
          })
        Button('提和')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F0AD4E')
          .enabled(this.gameState.status === 'active' && !this.aiThinking)
          .onClick(() => {
            const next = cloneState(this.gameState);
            next.status = 'agreed';
            this.gameState = next;
            this.refreshStatus();
            this.redrawNonce++;
            this.onGameOver();
          })
        Button('保存')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#5B7DB1')
          .onClick(() => {
            this.saveGameRecord();
          })
        Button('新局')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#6BA368')
          .onClick(() => {
            this.gameState = ChessEngine.initial();
            this.selected = null;
            this.legalTargets = [];
            this.lastMove = null;
            this.checkPos = null;
            this.refreshStatus();
            this.redrawNonce++;
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF3E7')
  }
}
