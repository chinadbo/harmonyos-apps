/**
 * AI 服务：随机 / 贪婪 / Minimax+AlphaBeta
 */
import { Color, Move, GameState, opposite } from '../model/Types';
import { ChessEngine } from './ChessEngine';
import { Evaluator } from './Evaluator';

export class AIService {
  /**
   * 选一步走法。level: 1 随机，2 贪婪，3 minimax 深度 2
   */
  static pickMove(state: GameState, level: number): Move | null {
    const moves = ChessEngine.legalMoves(state);
    if (moves.length === 0) {
      return null;
    }
    if (level === 1) {
      return AIService.pickRandom(moves);
    }
    if (level === 2) {
      return AIService.pickGreedy(state, moves);
    }
    return AIService.pickSearch(state, moves, 2);
  }

  private static pickRandom(moves: Move[]): Move {
    const idx = Math.floor(Math.random() * moves.length);
    return moves[idx];
  }

  private static pickGreedy(state: GameState, moves: Move[]): Move {
    const color = state.turn;
    let best: Move = moves[0];
    let bestScore = -Infinity;
    for (let i = 0; i < moves.length; i++) {
      const mv = moves[i];
      const next = ChessEngine.applyMove(state, mv);
      const v = Evaluator.captureValue(next, color);
      if (v > bestScore) {
        bestScore = v;
        best = mv;
      }
    }
    return best;
  }

  private static pickSearch(state: GameState, moves: Move[], depth: number): Move {
    const color = state.turn;
    let best: Move = moves[0];
    let alpha = -Infinity;
    const beta = Infinity;
    for (let i = 0; i < moves.length; i++) {
      const mv = moves[i];
      const next = ChessEngine.applyMove(state, mv);
      const v = AIService.alphabeta(next, depth - 1, alpha, beta,
        false, color);
      if (v > alpha) {
        alpha = v;
        best = mv;
      }
    }
    return best;
  }

  /**
   * alpha-beta 剪枝
   * @param rootColor 根节点走子方（评估以此方视角）
   */
  private static alphabeta(
    state: GameState,
    depth: number,
    alpha: number,
    beta: number,
    maximizing: boolean,
    rootColor: Color
  ): number {
    if (depth === 0 || state.status !== 'active') {
      const v = Evaluator.evaluate(state);
      return rootColor === Color.White ? v : -v;
    }
    const moves = ChessEngine.legalMoves(state);
    if (moves.length === 0) {
      const v = Evaluator.evaluate(state);
      return rootColor === Color.White ? v : -v;
    }
    if (maximizing) {
      let value = -Infinity;
      for (let i = 0; i < moves.length; i++) {
        const next = ChessEngine.applyMove(state, moves[i]);
        const child = AIService.alphabeta(next, depth - 1, alpha, beta, false, rootColor);
        if (child > value) value = child;
        if (value > alpha) alpha = value;
        if (alpha >= beta) break;
      }
      return value;
    } else {
      let value = Infinity;
      for (let i = 0; i < moves.length; i++) {
        const next = ChessEngine.applyMove(state, moves[i]);
        const child = AIService.alphabeta(next, depth - 1, alpha, beta, true, rootColor);
        if (child < value) value = child;
        if (value < beta) beta = value;
        if (alpha >= beta) break;
      }
      return value;
    }
  }

  /**
   * 描述难度
   */
  static levelName(level: number): string {
    if (level === 1) return 'Lv1 随机';
    if (level === 2) return 'Lv2 贪婪';
    if (level === 3) return 'Lv3 搜索';
    return 'Lv?';
  }
}
