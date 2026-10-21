/**
 * 棋盘 Canvas 组件
 */
import {
  Piece, Pos, Move, GameState, Color, pieceGlyph, posEq
} from '../model/Types';
import { ChessEngine } from '../engine/ChessEngine';
import { Constants } from '../common/Constants';

@Component
export struct ChessBoard {
  @Prop gameState: GameState;
  @Prop orientation: string; // 'white' | 'black'
  @Prop selected: Pos | null;
  @Prop legalTargets: Pos[];
  @Prop lastMove: Move | null;
  @Prop inCheckKing: Pos | null;
  onSquareTap: (pos: Pos) => void = (p: Pos) => {};

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State private canvasSize: number = 320;

  // 棋盘格 -> Canvas 坐标
  private squareOf(row: number, col: number): { x: number, y: number } {
    const n = this.canvasSize;
    const sq = n / 8;
    let r = row;
    let c = col;
    if (this.orientation === 'black') {
      r = 7 - r;
      c = 7 - c;
    }
    return { x: c * sq, y: r * sq };
  }

  private posFromXY(x: number, y: number): Pos | null {
    const n = this.canvasSize;
    if (n <= 0) return null;
    const sq = n / 8;
    let c = Math.floor(x / sq);
    let r = Math.floor(y / sq);
    if (r < 0 || r > 7 || c < 0 || c > 7) {
      return null;
    }
    if (this.orientation === 'black') {
      r = 7 - r;
      c = 7 - c;
    }
    return { row: r, col: c };
  }

  private redraw(): void {
    const ctx = this.ctx;
    const n = this.canvasSize;
    if (n <= 0) {
      return;
    }
    const sq = n / 8;

    // 背景
    ctx.fillStyle = Constants.COLOR_LIGHT_SQUARE;
    ctx.fillRect(0, 0, n, n);

    // 棋盘格
    for (let r = 0; r < 8; r++) {
      for (let c = 0; c < 8; c++) {
        const xy = this.squareOf(r, c);
        const isLight = (r + c) % 2 === 0;
        ctx.fillStyle = isLight ? Constants.COLOR_LIGHT_SQUARE : Constants.COLOR_DARK_SQUARE;
        ctx.fillRect(xy.x, xy.y, sq, sq);
      }
    }

    // 最近一步高亮
    if (this.lastMove) {
      ctx.fillStyle = Constants.COLOR_LAST_MOVE;
      let xy = this.squareOf(this.lastMove.from.row, this.lastMove.from.col);
      ctx.globalAlpha = 0.6;
      ctx.fillRect(xy.x, xy.y, sq, sq);
      xy = this.squareOf(this.lastMove.to.row, this.lastMove.to.col);
      ctx.fillRect(xy.x, xy.y, sq, sq);
      ctx.globalAlpha = 1.0;
    }

    // 选中格高亮
    if (this.selected) {
      const xy = this.squareOf(this.selected.row, this.selected.col);
      ctx.fillStyle = Constants.COLOR_SELECTED;
      ctx.globalAlpha = 0.7;
      ctx.fillRect(xy.x, xy.y, sq, sq);
      ctx.globalAlpha = 1.0;
    }

    // 被将军王格红闪
    if (this.inCheckKing) {
      const xy = this.squareOf(this.inCheckKing.row, this.inCheckKing.col);
      ctx.strokeStyle = Constants.COLOR_CHECK;
      ctx.lineWidth = 4;
      ctx.strokeRect(xy.x + 2, xy.y + 2, sq - 4, sq - 4);
    }

    // 合法目标圆点
    for (let i = 0; i < this.legalTargets.length; i++) {
      const t = this.legalTargets[i];
      const xy = this.squareOf(t.row, t.col);
      const cx = xy.x + sq / 2;
      const cy = xy.y + sq / 2;
      const target = this.gameState.board[t.row][t.col];
      ctx.fillStyle = Constants.COLOR_LEGAL_DOT;
      if (target) {
        // 吃子：圈
        ctx.strokeStyle = Constants.COLOR_LEGAL_DOT;
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.arc(cx, cy, sq * 0.42, 0, Math.PI * 2);
        ctx.stroke();
      } else {
        ctx.beginPath();
        ctx.arc(cx, cy, sq * 0.12, 0, Math.PI * 2);
        ctx.fill();
      }
    }

    // 棋子
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    const fontSize = Math.floor(sq * 0.78);
    ctx.font = `${fontSize}px sans-serif`;
    for (let r = 0; r < 8; r++) {
      for (let c = 0; c < 8; c++) {
        const p = this.gameState.board[r][c];
        if (!p) continue;
        const xy = this.squareOf(r, c);
        const cx = xy.x + sq / 2;
        const cy = xy.y + sq / 2 + 1;
        const glyph = pieceGlyph(p);
        if (p.color === Color.White) {
          // 描边 + 白填充
          ctx.lineWidth = 2;
          ctx.strokeStyle = Constants.COLOR_PIECE_WHITE_STROKE;
          ctx.strokeText(glyph, cx, cy);
          ctx.fillStyle = Constants.COLOR_PIECE_WHITE;
          ctx.fillText(glyph, cx, cy);
        } else {
          ctx.fillStyle = Constants.COLOR_PIECE_BLACK;
          ctx.fillText(glyph, cx, cy);
        }
      }
    }
  }

  build() {
    Stack() {
      Canvas(this.ctx)
        .width('100%')
        .aspectRatio(1)
        .backgroundColor('#00000000')
        .onReady(() => {
          this.redraw();
        })
        .onAreaChange((oldVal, newVal) => {
          const w = Number(newVal.width);
          if (!isNaN(w) && w > 0 && w !== this.canvasSize) {
            this.canvasSize = w;
            this.redraw();
          }
        })
        .onTouch((ev: TouchEvent) => {
          if (ev.type === TouchType.Down && ev.touches.length > 0) {
            const t = ev.touches[0];
            const pos = this.posFromXY(t.x, t.y);
            if (pos) {
              this.onSquareTap(pos);
            }
          }
        })
    }
    .width('100%')
    .aspectRatio(1)
    .onClick(() => {})
  }

  aboutToAppear(): void {
  }

  // 外部触发重绘（由父组件在状态变化后调用）
  refresh(): void {
    this.redraw();
  }
}
