/**
 * FEN 解析与生成
 * 格式：<棋子布局> <走子方> <易位权> <过路兵格> <半回合计数> <回合数>
 */
import {
  PieceType, Color, Pos, Piece, GameState
} from '../model/Types';

function fenCharToPiece(ch: string): Piece | null {
  const lower = ch.toLowerCase();
  let t: PieceType;
  switch (lower) {
    case 'p': t = PieceType.Pawn; break;
    case 'n': t = PieceType.Knight; break;
    case 'b': t = PieceType.Bishop; break;
    case 'r': t = PieceType.Rook; break;
    case 'q': t = PieceType.Queen; break;
    case 'k': t = PieceType.King; break;
    default: return null;
  }
  const c: Color = (ch === lower) ? Color.Black : Color.White;
  return { type: t, color: c };
}

function pieceToFenChar(p: Piece): string {
  let ch = p.type as string;
  if (p.color === Color.White) {
    ch = ch.toUpperCase();
  }
  return ch;
}

// 'e3' -> Pos
export function algToPos(s: string): Pos | null {
  if (s.length !== 2) {
    return null;
  }
  const col = s.charCodeAt(0) - 'a'.charCodeAt(0);
  const rank = s.charCodeAt(1) - '1'.charCodeAt(0);
  if (col < 0 || col > 7 || rank < 0 || rank > 7) {
    return null;
  }
  return { row: 7 - rank, col: col };
}

export function posToAlg(p: Pos): string {
  const col = String.fromCharCode('a'.charCodeAt(0) + p.col);
  const rank = String.fromCharCode('1'.charCodeAt(0) + (7 - p.row));
  return col + rank;
}

export class Fen {
  static parse(fen: string): GameState {
    const parts = fen.split(' ');
    const boardStr = parts.length > 0 ? parts[0] : '';
    const turnStr = parts.length > 1 ? parts[1] : 'w';
    const castleStr = parts.length > 2 ? parts[2] : '-';
    const epStr = parts.length > 3 ? parts[3] : '-';
    const halfStr = parts.length > 4 ? parts[4] : '0';
    const fullStr = parts.length > 5 ? parts[5] : '1';

    const board: (Piece | null)[][] = [];
    for (let i = 0; i < 8; i++) {
      const row: (Piece | null)[] = [];
      for (let j = 0; j < 8; j++) {
        row.push(null);
      }
      board.push(row);
    }
    const rows = boardStr.split('/');
    for (let r = 0; r < rows.length && r < 8; r++) {
      const rowStr = rows[r];
      let c = 0;
      for (let i = 0; i < rowStr.length && c < 8; i++) {
        const ch = rowStr.charAt(i);
        if (ch >= '1' && ch <= '8') {
          c += (ch.charCodeAt(0) - '0'.charCodeAt(0));
        } else {
          board[r][c] = fenCharToPiece(ch);
          c++;
        }
      }
    }

    const turn: Color = turnStr === 'w' ? Color.White : Color.Black;
    const cr = {
      K: castleStr.indexOf('K') >= 0,
      Q: castleStr.indexOf('Q') >= 0,
      k: castleStr.indexOf('k') >= 0,
      q: castleStr.indexOf('q') >= 0
    };
    const ep: Pos | null = epStr === '-' ? null : algToPos(epStr);
    const half = parseInt(halfStr);
    const full = parseInt(fullStr);

    return {
      board: board,
      turn: turn,
      castlingRights: cr,
      enPassantTarget: ep,
      halfmoveClock: isNaN(half) ? 0 : half,
      fullmoveNumber: isNaN(full) ? 1 : full,
      history: [],
      status: 'active',
      winner: null
    };
  }

  static stringify(state: GameState): string {
    let boardStr = '';
    for (let r = 0; r < 8; r++) {
      let empty = 0;
      for (let c = 0; c < 8; c++) {
        const p = state.board[r][c];
        if (!p) {
          empty++;
        } else {
          if (empty > 0) {
            boardStr += empty.toString();
            empty = 0;
          }
          boardStr += pieceToFenChar(p);
        }
      }
      if (empty > 0) {
        boardStr += empty.toString();
      }
      if (r < 7) {
        boardStr += '/';
      }
    }
    const turn = state.turn === Color.White ? 'w' : 'b';
    let castle = '';
    if (state.castlingRights.K) castle += 'K';
    if (state.castlingRights.Q) castle += 'Q';
    if (state.castlingRights.k) castle += 'k';
    if (state.castlingRights.q) castle += 'q';
    if (castle.length === 0) castle = '-';
    const ep = state.enPassantTarget ? posToAlg(state.enPassantTarget) : '-';
    return `${boardStr} ${turn} ${castle} ${ep} ${state.halfmoveClock} ${state.fullmoveNumber}`;
  }
}
