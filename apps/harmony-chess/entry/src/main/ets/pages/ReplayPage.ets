import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GameState, Move, GameRecord } from '../model/Types';
import { ChessEngine } from '../engine/ChessEngine';
import { PgnParser, PgnGame } from '../pgn/PgnParser';
import { StorageService } from '../service/StorageService';
import { ChessBoard } from '../components/ChessBoard';

interface RouterParams {
  recordId: string;
}

@Entry
@Component
struct ReplayPage {
  @State recordId: string = '';
  @State record: GameRecord | null = null;
  @State pgnGame: PgnGame | null = null;
  @State currentPly: number = 0;
  @State displayState: GameState = ChessEngine.initial();
  @State totalPly: number = 0;
  @State redrawNonce: number = 0;
  @State lastMove: Move | null = null;
  @State errorMsg: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as RouterParams;
    if (params && params.recordId) {
      this.recordId = params.recordId;
      this.loadRecord();
    }
  }

  private loadRecord(): void {
    const rec = StorageService.getRecord(this.recordId);
    if (rec === null) {
      this.errorMsg = '棋谱不存在';
      return;
    }
    this.record = rec;
    const parsed = PgnParser.parse(rec.pgn);
    if (parsed === null) {
      this.errorMsg = 'PGN 解析失败';
      return;
    }
    this.pgnGame = parsed;
    this.totalPly = parsed.moves.length;
    this.jumpTo(0);
  }

  private jumpTo(ply: number): void {
    if (this.pgnGame === null) return;
    const target = Math.max(0, Math.min(ply, this.totalPly));
    const state = PgnParser.replayTo(this.pgnGame, target);
    if (state === null) {
      promptAction.showToast({ message: '解析失败，无法回放到该步' });
      return;
    }
    this.displayState = state;
    this.currentPly = target;
    if (target > 0 && state.history.length > 0) {
      this.lastMove = state.history[state.history.length - 1];
    } else {
      this.lastMove = null;
    }
    this.redrawNonce++;
  }

  build() {
    Column() {
      Row() {
        Button('← 返回')
          .fontSize(14)
          .height(36)
          .backgroundColor('#999999')
          .onClick(() => { router.back(); })
        Blank()
        Text(this.record !== null ? this.record.title : '复盘')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          .margin({ left: 12, right: 12 })
        Text(`${this.currentPly} / ${this.totalPly}`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding(12)

      if (this.errorMsg.length > 0) {
        Column() {
          Text(this.errorMsg)
            .fontSize(16)
            .fontColor('#D9534F')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        ChessBoard({
          gameState: this.displayState,
          orientation: 'white',
          selected: null,
          legalTargets: [],
          lastMove: this.lastMove,
          checkPos: null,
          redrawNonce: this.redrawNonce,
          onSquareTap: () => {}
        })
          .width('100%')

        // 控制条
        Row({ space: 8 }) {
          Button('⏮')
            .layoutWeight(1)
            .height(44)
            .enabled(this.currentPly > 0)
            .onClick(() => { this.jumpTo(0); })
          Button('◀')
            .layoutWeight(1)
            .height(44)
            .enabled(this.currentPly > 0)
            .onClick(() => { this.jumpTo(this.currentPly - 1); })
          Button('▶')
            .layoutWeight(1)
            .height(44)
            .enabled(this.currentPly < this.totalPly)
            .onClick(() => { this.jumpTo(this.currentPly + 1); })
          Button('⏭')
            .layoutWeight(1)
            .height(44)
            .enabled(this.currentPly < this.totalPly)
            .onClick(() => { this.jumpTo(this.totalPly); })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12 })

        // 当前步数显示
        if (this.lastMove !== null) {
          Text(`最近一步：${this.lastMove.san}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF3E7')
  }
}
