/**
 * SAN (Standard Algebraic Notation) 编解码
 * 例：Nf3, exd5, O-O, O-O-O, e8=Q, Qxf7+, R1e2#
 */
import {
  PieceType, Color, Piece, Pos, Move, GameState
} from '../model/Types';
import { ChessEngine } from '../engine/ChessEngine';
import { posToAlg, algToPos } from '../model/Fen';

function pieceLetter(t: PieceType): string {
  switch (t) {
    case PieceType.Knight: return 'N';
    case PieceType.Bishop: return 'B';
    case PieceType.Rook: return 'R';
    case PieceType.Queen: return 'Q';
    case PieceType.King: return 'K';
    default: return '';
  }
}

function letterToPiece(ch: string): PieceType | null {
  switch (ch) {
    case 'N': return PieceType.Knight;
    case 'B': return PieceType.Bishop;
    case 'R': return PieceType.Rook;
    case 'Q': return PieceType.Queen;
    case 'K': return PieceType.King;
    default: return null;
  }
}

export class SanCodec {
  /**
   * 在给定 state 下生成 move 的 SAN 字符串
   */
  static encode(state: GameState, move: Move): string {
    // 王车易位
    if (move.isCastling) {
      const s = (move.to.col === 6) ? 'O-O' : 'O-O-O';
      return s + SanCodec.suffix(state, move);
    }
    let out = '';
    const piece = move.piece;
    const isPawn = piece.type === PieceType.Pawn;
    if (!isPawn) {
      out += pieceLetter(piece.type);
      // 冲突消解
      const candidates = SanCodec.findSameTypeMoves(state, move);
      if (candidates.length > 1) {
        let needFile = false;
        let needRank = false;
        for (let i = 0; i < candidates.length; i++) {
          const c = candidates[i];
          if (c.from.row === move.from.row && c.from.col === move.from.col) {
            continue;
          }
          if (c.from.col !== move.from.col) {
            needFile = true;
          } else if (c.from.row !== move.from.row) {
            needRank = true;
          }
        }
        if (!needFile && !needRank) {
          needFile = true;
        }
        if (needFile) {
          out += String.fromCharCode('a'.charCodeAt(0) + move.from.col);
        }
        if (needRank) {
          out += String.fromCharCode('1'.charCodeAt(0) + (7 - move.from.row));
        }
      }
    } else {
      // 兵吃子需带起始列
      if (move.captured) {
        out += String.fromCharCode('a'.charCodeAt(0) + move.from.col);
      }
    }
    if (move.captured) {
      out += 'x';
    }
    out += posToAlg(move.to);
    if (move.promotion) {
      out += '=' + pieceLetter(move.promotion);
    }
    out += SanCodec.suffix(state, move);
    return out;
  }

  /**
   * 找出与 move 同兵种同色能走到同一目标格的候选
   */
  private static findSameTypeMoves(state: GameState, move: Move): Move[] {
    const all = ChessEngine.legalMoves(state);
    const same: Move[] = [];
    for (let i = 0; i < all.length; i++) {
      const m = all[i];
      if (m.piece.type === move.piece.type &&
          m.piece.color === move.piece.color &&
          m.to.row === move.to.row &&
          m.to.col === move.to.col) {
        same.push(m);
      }
    }
    return same;
  }

  private static suffix(state: GameState, move: Move): string {
    const next = ChessEngine.applyMove(state, move);
    if (next.status === 'checkmate') {
      return '#';
    }
    if (ChessEngine.isInCheck(next, next.turn)) {
      return '+';
    }
    return '';
  }

  /**
   * 解析 SAN 字符串为合法 Move（在 state 下匹配）
   * 返回 null 表示解析失败
   */
  static decode(state: GameState, san: string): Move | null {
    let s = san;
    // 去掉结果后缀、注释符号
    s = s.replace(/[!?+#]+$/, '');
    if (s.length === 0) {
      return null;
    }

    const all = ChessEngine.legalMoves(state);

    // 王车易位
    if (s === 'O-O' || s === '0-0') {
      for (let i = 0; i < all.length; i++) {
        if (all[i].isCastling && all[i].to.col === 6) {
          return all[i];
        }
      }
      return null;
    }
    if (s === 'O-O-O' || s === '0-0-0') {
      for (let i = 0; i < all.length; i++) {
        if (all[i].isCastling && all[i].to.col === 2) {
          return all[i];
        }
      }
      return null;
    }

    // 升变
    let promotion: PieceType | null = null;
    const eqIdx = s.indexOf('=');
    if (eqIdx >= 0 && eqIdx + 1 < s.length) {
      promotion = letterToPiece(s.charAt(eqIdx + 1));
      s = s.substring(0, eqIdx);
    }

    // 目标格
    if (s.length < 2) {
      return null;
    }
    const destStr = s.substring(s.length - 2);
    const dest = algToPos(destStr);
    if (!dest) {
      return null;
    }
    let prefix = s.substring(0, s.length - 2);

    // 判断兵种
    let ptype: PieceType = PieceType.Pawn;
    if (prefix.length > 0) {
      const ch = prefix.charAt(0);
      const t = letterToPiece(ch);
      if (t) {
        ptype = t;
        prefix = prefix.substring(1);
      }
    }

    // prefix 剩余部分是 disambiguation + 可选 'x'
    let fileHint = -1;
    let rankHint = -1;
    for (let i = 0; i < prefix.length; i++) {
      const ch = prefix.charAt(i);
      if (ch === 'x') {
        continue;
      }
      if (ch >= 'a' && ch <= 'h') {
        fileHint = ch.charCodeAt(0) - 'a'.charCodeAt(0);
      } else if (ch >= '1' && ch <= '8') {
        rankHint = 7 - (ch.charCodeAt(0) - '1'.charCodeAt(0));
      }
    }

    for (let i = 0; i < all.length; i++) {
      const m = all[i];
      if (m.piece.type !== ptype) continue;
      if (m.to.row !== dest.row || m.to.col !== dest.col) continue;
      if (fileHint >= 0 && m.from.col !== fileHint) continue;
      if (rankHint >= 0 && m.from.row !== rankHint) continue;
      if (promotion && m.promotion !== promotion) continue;
      if (!promotion && m.promotion) continue;
      return m;
    }
    return null;
  }
}
