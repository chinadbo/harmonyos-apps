/**
 * 静态评估函数：子力 + 位置权重
 */
import {
  PieceType, Color, Piece, GameState
} from '../model/Types';

// 子力基础价值
function pieceValue(t: PieceType): number {
  switch (t) {
    case PieceType.Pawn: return 100;
    case PieceType.Knight: return 320;
    case PieceType.Bishop: return 330;
    case PieceType.Rook: return 500;
    case PieceType.Queen: return 900;
    case PieceType.King: return 20000;
    default: return 0;
  }
}

// 白方视角位置权重表（黑方使用镜像 row -> 7 - row）
// 兵
const PST_PAWN: number[][] = [
  [0, 0, 0, 0, 0, 0, 0, 0],
  [50, 50, 50, 50, 50, 50, 50, 50],
  [10, 10, 20, 30, 30, 20, 10, 10],
  [5, 5, 10, 25, 25, 10, 5, 5],
  [0, 0, 0, 20, 20, 0, 0, 0],
  [5, -5, -10, 0, 0, -10, -5, 5],
  [5, 10, 10, -20, -20, 10, 10, 5],
  [0, 0, 0, 0, 0, 0, 0, 0]
];

// 马
const PST_KNIGHT: number[][] = [
  [-50, -40, -30, -30, -30, -30, -40, -50],
  [-40, -20, 0, 0, 0, 0, -20, -40],
  [-30, 0, 10, 15, 15, 10, 0, -30],
  [-30, 5, 15, 20, 20, 15, 5, -30],
  [-30, 0, 15, 20, 20, 15, 0, -30],
  [-30, 5, 10, 15, 15, 10, 5, -30],
  [-40, -20, 0, 5, 5, 0, -20, -40],
  [-50, -40, -30, -30, -30, -30, -40, -50]
];

// 象
const PST_BISHOP: number[][] = [
  [-20, -10, -10, -10, -10, -10, -10, -20],
  [-10, 0, 0, 0, 0, 0, 0, -10],
  [-10, 0, 5, 10, 10, 5, 0, -10],
  [-10, 5, 5, 10, 10, 5, 5, -10],
  [-10, 0, 10, 10, 10, 10, 0, -10],
  [-10, 10, 10, 10, 10, 10, 10, -10],
  [-10, 5, 0, 0, 0, 0, 5, -10],
  [-20, -10, -10, -10, -10, -10, -10, -20]
];

// 车
const PST_ROOK: number[][] = [
  [0, 0, 0, 0, 0, 0, 0, 0],
  [5, 10, 10, 10, 10, 10, 10, 5],
  [-5, 0, 0, 0, 0, 0, 0, -5],
  [-5, 0, 0, 0, 0, 0, 0, -5],
  [-5, 0, 0, 0, 0, 0, 0, -5],
  [-5, 0, 0, 0, 0, 0, 0, -5],
  [-5, 0, 0, 0, 0, 0, 0, -5],
  [0, 0, 0, 5, 5, 0, 0, 0]
];

// 后
const PST_QUEEN: number[][] = [
  [-20, -10, -10, -5, -5, -10, -10, -20],
  [-10, 0, 0, 0, 0, 0, 0, -10],
  [-10, 0, 5, 5, 5, 5, 0, -10],
  [-5, 0, 5, 5, 5, 5, 0, -5],
  [0, 0, 5, 5, 5, 5, 0, -5],
  [-10, 5, 5, 5, 5, 5, 0, -10],
  [-10, 0, 5, 0, 0, 0, 0, -10],
  [-20, -10, -10, -5, -5, -10, -10, -20]
];

// 王（中盘）
const PST_KING_MID: number[][] = [
  [-30, -40, -40, -50, -50, -40, -40, -30],
  [-30, -40, -40, -50, -50, -40, -40, -30],
  [-30, -40, -40, -50, -50, -40, -40, -30],
  [-30, -40, -40, -50, -50, -40, -40, -30],
  [-20, -30, -30, -40, -40, -30, -30, -20],
  [-10, -20, -20, -20, -20, -20, -20, -10],
  [20, 20, 0, 0, 0, 0, 20, 20],
  [20, 30, 10, 0, 0, 10, 30, 20]
];

function pstOf(t: PieceType): number[][] {
  switch (t) {
    case PieceType.Pawn: return PST_PAWN;
    case PieceType.Knight: return PST_KNIGHT;
    case PieceType.Bishop: return PST_BISHOP;
    case PieceType.Rook: return PST_ROOK;
    case PieceType.Queen: return PST_QUEEN;
    case PieceType.King: return PST_KING_MID;
    default: return PST_PAWN;
  }
}

export class Evaluator {
  /**
   * 静态评估：正值对白方有利，负值对黑方有利
   */
  static evaluate(state: GameState): number {
    if (state.status === 'checkmate') {
      // 当前走子方被将死
      return state.turn === Color.White ? -100000 : 100000;
    }
    if (state.status === 'stalemate' || state.status === 'draw') {
      return 0;
    }
    let score = 0;
    for (let r = 0; r < 8; r++) {
      for (let c = 0; c < 8; c++) {
        const p = state.board[r][c];
        if (!p) {
          continue;
        }
        const v = pieceValue(p.type);
        const table = pstOf(p.type);
        let pst = 0;
        if (p.color === Color.White) {
          // 表是从黑方视角（row=0 是黑方底线），白方取 7-r
          pst = table[7 - r][c];
        } else {
          pst = table[r][c];
        }
        if (p.color === Color.White) {
          score += v + pst;
        } else {
          score -= v + pst;
        }
      }
    }
    // 走子权小加成
    if (state.turn === Color.White) {
      score += 10;
    } else {
      score -= 10;
    }
    return score;
  }

  /**
   * 单步吃子得分（用于贪婪层）：返回走完后从 color 角度的净值
   */
  static captureValue(state: GameState, color: Color): number {
    const v = Evaluator.evaluate(state);
    return color === Color.White ? v : -v;
  }

  /**
   * 估计单子力价值（供 UI 显示）
   */
  static valueOf(p: Piece): number {
    return pieceValue(p.type);
  }
}
