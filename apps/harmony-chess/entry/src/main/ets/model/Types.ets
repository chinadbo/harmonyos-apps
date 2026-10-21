export enum PieceType {
  Pawn = 'p',
  Knight = 'n',
  Bishop = 'b',
  Rook = 'r',
  Queen = 'q',
  King = 'k'
}

export enum Color {
  White = 'w',
  Black = 'b'
}

// 兼容性别名（部分子模块用了 PieceColor 命名）
export type PieceColor = Color;

export interface Pos {
  row: number;
  col: number;
}

export interface Piece {
  type: PieceType;
  color: Color;
}

export interface Move {
  from: Pos;
  to: Pos;
  piece: Piece;
  captured: Piece | null;
  isCastlingK: boolean;
  isCastlingQ: boolean;
  isEnPassant: boolean;
  promotion: PieceType | null;
  san: string;
}

export interface CastlingRights {
  K: boolean;
  Q: boolean;
  k: boolean;
  q: boolean;
}

export type GameStatus = 'active' | 'checkmate' | 'stalemate' | 'draw50' | 'resigned' | 'agreed';

export interface GameState {
  board: Array<Array<Piece | null>>;
  turn: Color;
  castlingRights: CastlingRights;
  enPassantTarget: Pos | null;
  halfmoveClock: number;
  fullmoveNumber: number;
  history: Array<Move>;
  status: GameStatus;
  winner: Color | null;
}

export interface GameRecord {
  id: string;
  title: string;
  pgn: string;
  result: string;
  createdAt: number;
  mode: string;
  aiLevel: number;
}

export function posEq(a: Pos, b: Pos): boolean {
  return a.row === b.row && a.col === b.col;
}

export function inBoard(r: number, c: number): boolean {
  return r >= 0 && r < 8 && c >= 0 && c < 8;
}

export function opposite(c: Color): Color {
  return c === Color.White ? Color.Black : Color.White;
}

export function pieceGlyph(p: Piece): string {
  if (p.color === Color.White) {
    switch (p.type) {
      case PieceType.King: return '♔';
      case PieceType.Queen: return '♕';
      case PieceType.Rook: return '♖';
      case PieceType.Bishop: return '♗';
      case PieceType.Knight: return '♘';
      case PieceType.Pawn: return '♙';
    }
  } else {
    switch (p.type) {
      case PieceType.King: return '♚';
      case PieceType.Queen: return '♛';
      case PieceType.Rook: return '♜';
      case PieceType.Bishop: return '♝';
      case PieceType.Knight: return '♞';
      case PieceType.Pawn: return '♟';
    }
  }
  return '';
}

export function cloneState(s: GameState): GameState {
  const board: Array<Array<Piece | null>> = [];
  for (let r = 0; r < 8; r++) {
    const row: Array<Piece | null> = [];
    for (let c = 0; c < 8; c++) {
      const p = s.board[r][c];
      row.push(p === null ? null : { type: p.type, color: p.color });
    }
    board.push(row);
  }
  const history: Array<Move> = [];
  for (const m of s.history) {
    history.push(cloneMove(m));
  }
  return {
    board: board,
    turn: s.turn,
    castlingRights: { K: s.castlingRights.K, Q: s.castlingRights.Q, k: s.castlingRights.k, q: s.castlingRights.q },
    enPassantTarget: s.enPassantTarget === null ? null : { row: s.enPassantTarget.row, col: s.enPassantTarget.col },
    halfmoveClock: s.halfmoveClock,
    fullmoveNumber: s.fullmoveNumber,
    history: history,
    status: s.status,
    winner: s.winner
  };
}

export function cloneMove(m: Move): Move {
  return {
    from: { row: m.from.row, col: m.from.col },
    to: { row: m.to.row, col: m.to.col },
    piece: { type: m.piece.type, color: m.piece.color },
    captured: m.captured === null ? null : { type: m.captured.type, color: m.captured.color },
    isCastlingK: m.isCastlingK,
    isCastlingQ: m.isCastlingQ,
    isEnPassant: m.isEnPassant,
    promotion: m.promotion,
    san: m.san
  };
}
