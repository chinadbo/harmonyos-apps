import {
  GameState, Move, Piece, PieceType, Color, Pos,
  opposite, cloneState, cloneMove
} from '../model/Types';
import { MoveGenerator } from './MoveGenerator';
import { Fen } from '../model/Fen';
import { Constants } from '../common/Constants';
import { SanCodec } from '../pgn/SanCodec';

export class ChessEngine {
  static initial(): GameState {
    return Fen.parse(Constants.INITIAL_FEN);
  }

  static legalMoves(state: GameState, from: Pos | null = null): Array<Move> {
    return MoveGenerator.generate(state, from);
  }

  static isInCheck(state: GameState, color: Color): boolean {
    const king = MoveGenerator.findKing(state, color);
    if (king.row < 0) return false;
    return MoveGenerator.isSquareAttacked(state, king, opposite(color));
  }

  /**
   * 应用一步走子，返回新状态（不可变）
   * 注意：调用前必须确保 m 是合法走法
   */
  static applyMove(state: GameState, m: Move): GameState {
    const next = cloneState(state);
    // 移动棋子
    next.board[m.from.row][m.from.col] = null;
    let movedPiece: Piece = { type: m.piece.type, color: m.piece.color };
    if (m.promotion !== null) {
      movedPiece = { type: m.promotion, color: m.piece.color };
    }
    next.board[m.to.row][m.to.col] = movedPiece;
    // 吃过路兵：吃掉旁边的兵
    if (m.isEnPassant) {
      next.board[m.from.row][m.to.col] = null;
    }
    // 王车易位：动车
    if (m.isCastlingK) {
      next.board[m.from.row][5] = next.board[m.from.row][7];
      next.board[m.from.row][7] = null;
    }
    if (m.isCastlingQ) {
      next.board[m.from.row][3] = next.board[m.from.row][0];
      next.board[m.from.row][0] = null;
    }

    // 更新王车易位权
    const rights = next.castlingRights;
    if (m.piece.type === PieceType.King) {
      if (m.piece.color === Color.White) { rights.K = false; rights.Q = false; }
      else { rights.k = false; rights.q = false; }
    }
    if (m.piece.type === PieceType.Rook) {
      if (m.from.row === 7 && m.from.col === 0) rights.Q = false;
      if (m.from.row === 7 && m.from.col === 7) rights.K = false;
      if (m.from.row === 0 && m.from.col === 0) rights.q = false;
      if (m.from.row === 0 && m.from.col === 7) rights.k = false;
    }
    // 被吃车也更新
    if (m.captured !== null && m.captured.type === PieceType.Rook) {
      if (m.to.row === 7 && m.to.col === 0) rights.Q = false;
      if (m.to.row === 7 && m.to.col === 7) rights.K = false;
      if (m.to.row === 0 && m.to.col === 0) rights.q = false;
      if (m.to.row === 0 && m.to.col === 7) rights.k = false;
    }

    // 更新吃过路兵目标
    if (m.piece.type === PieceType.Pawn && Math.abs(m.to.row - m.from.row) === 2) {
      const midRow = (m.from.row + m.to.row) / 2;
      next.enPassantTarget = { row: midRow, col: m.from.col };
    } else {
      next.enPassantTarget = null;
    }

    // 半回合/全回合
    if (m.piece.type === PieceType.Pawn || m.captured !== null) {
      next.halfmoveClock = 0;
    } else {
      next.halfmoveClock = state.halfmoveClock + 1;
    }
    if (state.turn === Color.Black) {
      next.fullmoveNumber = state.fullmoveNumber + 1;
    }

    next.turn = opposite(state.turn);

    // 生成 SAN（基于走前 state）
    const san = SanCodec.moveToSan(state, m);
    const historyMove = cloneMove(m);
    historyMove.san = san;
    next.history = state.history.concat([historyMove]);

    return next;
  }

  /** 更新对局状态：将杀/逼和/50回合 */
  static updateStatus(state: GameState): GameState {
    const next = cloneState(state);
    if (next.halfmoveClock >= 100) {
      next.status = 'draw50';
      return next;
    }
    const moves = ChessEngine.legalMoves(next);
    if (moves.length === 0) {
      if (ChessEngine.isInCheck(next, next.turn)) {
        next.status = 'checkmate';
        next.winner = opposite(next.turn);
      } else {
        next.status = 'stalemate';
      }
    }
    return next;
  }

  /** 性能测试（perft）—— 用于自测 */
  static perft(state: GameState, depth: number): number {
    if (depth === 0) return 1;
    const moves = MoveGenerator.generate(state);
    if (depth === 1) return moves.length;
    let nodes = 0;
    for (const m of moves) {
      const next = ChessEngine.applyMove(state, m);
      nodes += ChessEngine.perft(next, depth - 1);
    }
    return nodes;
  }
}
