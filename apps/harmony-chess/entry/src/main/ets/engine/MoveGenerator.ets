import {
  GameState, Move, Piece, PieceType, Color, Pos,
  inBoard, posEq, opposite
} from '../model/Types';

/**
 * 合法走法生成器：分兵种生成伪合法走法，再通过模拟过滤（走后己方王不能被将军）。
 * 特殊走法：
 * - 兵：直进 1/2、斜吃、吃过路兵、升变
 * - 王车易位：本行无阻挡 + 王/车未动 + 王经过的格不被攻击
 */
export class MoveGenerator {
  /**
   * 生成所有合法走法。
   * @param state 当前局面
   * @param from 可选：只生成 from 格的合法走法
   */
  static generate(state: GameState, from: Pos | null = null): Array<Move> {
    const pseudo = MoveGenerator.pseudoLegal(state, from);
    const legal: Array<Move> = [];
    for (const m of pseudo) {
      const next = MoveGenerator.applyMoveInternal(state, m);
      if (!MoveGenerator.isSquareAttacked(next, MoveGenerator.findKing(next, state.turn), opposite(state.turn))) {
        legal.push(m);
      }
    }
    return legal;
  }

  /** 伪合法走法（不检查己方王是否被将军） */
  static pseudoLegal(state: GameState, from: Pos | null = null): Array<Move> {
    const moves: Array<Move> = [];
    const turn = state.turn;
    for (let r = 0; r < 8; r++) {
      for (let c = 0; c < 8; c++) {
        const p = state.board[r][c];
        if (p === null || p.color !== turn) continue;
        if (from !== null && (from.row !== r || from.col !== c)) continue;
        const fromPos: Pos = { row: r, col: c };
        switch (p.type) {
          case PieceType.Pawn:
            MoveGenerator.genPawn(state, fromPos, p, moves);
            break;
          case PieceType.Knight:
            MoveGenerator.genKnight(state, fromPos, p, moves);
            break;
          case PieceType.Bishop:
            MoveGenerator.genSliding(state, fromPos, p, moves, [[-1,-1],[-1,1],[1,-1],[1,1]]);
            break;
          case PieceType.Rook:
            MoveGenerator.genSliding(state, fromPos, p, moves, [[-1,0],[1,0],[0,-1],[0,1]]);
            break;
          case PieceType.Queen:
            MoveGenerator.genSliding(state, fromPos, p, moves,
              [[-1,-1],[-1,1],[1,-1],[1,1],[-1,0],[1,0],[0,-1],[0,1]]);
            break;
          case PieceType.King:
            MoveGenerator.genKing(state, fromPos, p, moves);
            break;
        }
      }
    }
    return moves;
  }

  /** 兵 */
  private static genPawn(state: GameState, from: Pos, p: Piece, out: Array<Move>): void {
    const dir = p.color === Color.White ? -1 : 1;
    const startRow = p.color === Color.White ? 6 : 1;
    const promoteRow = p.color === Color.White ? 0 : 7;
    const r = from.row;
    const c = from.col;

    // 直进 1
    if (inBoard(r + dir, c) && state.board[r + dir][c] === null) {
      MoveGenerator.pushPawnMove(out, from, { row: r + dir, col: c }, p, null, r + dir === promoteRow);
      // 直进 2
      if (r === startRow && state.board[r + 2 * dir][c] === null) {
        MoveGenerator.pushPawnMove(out, from, { row: r + 2 * dir, col: c }, p, null, false);
      }
    }
    // 斜吃
    for (const dc of [-1, 1]) {
      const nr = r + dir;
      const nc = c + dc;
      if (!inBoard(nr, nc)) continue;
      const target = state.board[nr][nc];
      if (target !== null && target.color !== p.color) {
        MoveGenerator.pushPawnMove(out, from, { row: nr, col: nc }, p, target, nr === promoteRow);
      }
    }
    // 吃过路兵
    if (state.enPassantTarget !== null) {
      const ep = state.enPassantTarget;
      if (ep.row === r + dir && (ep.col === c - 1 || ep.col === c + 1)) {
        const captured = state.board[r][ep.col];
        if (captured !== null && captured.type === PieceType.Pawn && captured.color !== p.color) {
          out.push(MoveGenerator.makeMove(from, { row: ep.row, col: ep.col }, p, captured, false, false, true, null));
        }
      }
    }
  }

  private static pushPawnMove(out: Array<Move>, from: Pos, to: Pos, p: Piece,
                              captured: Piece | null, isPromo: boolean): void {
    if (isPromo) {
      for (const promo of [PieceType.Queen, PieceType.Rook, PieceType.Bishop, PieceType.Knight]) {
        out.push(MoveGenerator.makeMove(from, to, p, captured, false, false, false, promo));
      }
    } else {
      out.push(MoveGenerator.makeMove(from, to, p, captured, false, false, false, null));
    }
  }

  /** 马 */
  private static genKnight(state: GameState, from: Pos, p: Piece, out: Array<Move>): void {
    const offsets = [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]];
    for (const off of offsets) {
      const nr = from.row + off[0];
      const nc = from.col + off[1];
      if (!inBoard(nr, nc)) continue;
      const target = state.board[nr][nc];
      if (target === null || target.color !== p.color) {
        out.push(MoveGenerator.makeMove(from, { row: nr, col: nc }, p, target, false, false, false, null));
      }
    }
  }

  /** 滑子（象/车/后） */
  private static genSliding(state: GameState, from: Pos, p: Piece, out: Array<Move>,
                            dirs: Array<Array<number>>): void {
    for (const d of dirs) {
      let nr = from.row + d[0];
      let nc = from.col + d[1];
      while (inBoard(nr, nc)) {
        const target = state.board[nr][nc];
        if (target === null) {
          out.push(MoveGenerator.makeMove(from, { row: nr, col: nc }, p, null, false, false, false, null));
        } else {
          if (target.color !== p.color) {
            out.push(MoveGenerator.makeMove(from, { row: nr, col: nc }, p, target, false, false, false, null));
          }
          break;
        }
        nr += d[0];
        nc += d[1];
      }
    }
  }

  /** 王（含王车易位） */
  private static genKing(state: GameState, from: Pos, p: Piece, out: Array<Move>): void {
    const offsets = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]];
    for (const off of offsets) {
      const nr = from.row + off[0];
      const nc = from.col + off[1];
      if (!inBoard(nr, nc)) continue;
      const target = state.board[nr][nc];
      if (target === null || target.color !== p.color) {
        out.push(MoveGenerator.makeMove(from, { row: nr, col: nc }, p, target, false, false, false, null));
      }
    }
    // 王车易位
    MoveGenerator.genCastling(state, from, p, out);
  }

  private static genCastling(state: GameState, from: Pos, p: Piece, out: Array<Move>): void {
    const enemy = opposite(p.color);
    const homeRow = p.color === Color.White ? 7 : 0;
    if (from.row !== homeRow || from.col !== 4) return;

    const rights = p.color === Color.White
      ? { K: state.castlingRights.K, Q: state.castlingRights.Q }
      : { K: state.castlingRights.k, Q: state.castlingRights.q };

    // 短易位（王侧）
    if (rights.K) {
      const rook = state.board[homeRow][7];
      if (rook !== null && rook.type === PieceType.Rook && rook.color === p.color) {
        if (state.board[homeRow][5] === null && state.board[homeRow][6] === null) {
          // 王经过 e/f/g 三格不能被攻击
          if (!MoveGenerator.isSquareAttacked(state, { row: homeRow, col: 4 }, enemy)
              && !MoveGenerator.isSquareAttacked(state, { row: homeRow, col: 5 }, enemy)
              && !MoveGenerator.isSquareAttacked(state, { row: homeRow, col: 6 }, enemy)) {
            out.push(MoveGenerator.makeMove(from, { row: homeRow, col: 6 }, p, null, true, false, false, null));
          }
        }
      }
    }
    // 长易位（后侧）
    if (rights.Q) {
      const rook = state.board[homeRow][0];
      if (rook !== null && rook.type === PieceType.Rook && rook.color === p.color) {
        if (state.board[homeRow][1] === null && state.board[homeRow][2] === null
            && state.board[homeRow][3] === null) {
          if (!MoveGenerator.isSquareAttacked(state, { row: homeRow, col: 4 }, enemy)
              && !MoveGenerator.isSquareAttacked(state, { row: homeRow, col: 3 }, enemy)
              && !MoveGenerator.isSquareAttacked(state, { row: homeRow, col: 2 }, enemy)) {
            out.push(MoveGenerator.makeMove(from, { row: homeRow, col: 2 }, p, null, false, true, false, null));
          }
        }
      }
    }
  }

  /** 判断 square 是否被 byColor 方攻击 */
  static isSquareAttacked(state: GameState, sq: Pos, byColor: Color): boolean {
    // 兵攻击
    const pawnDir = byColor === Color.White ? -1 : 1;
    for (const dc of [-1, 1]) {
      const r = sq.row - pawnDir;
      const c = sq.col + dc;
      if (inBoard(r, c)) {
        const p = state.board[r][c];
        if (p !== null && p.color === byColor && p.type === PieceType.Pawn) return true;
      }
    }
    // 马
    const knightOff = [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]];
    for (const off of knightOff) {
      const r = sq.row + off[0];
      const c = sq.col + off[1];
      if (inBoard(r, c)) {
        const p = state.board[r][c];
        if (p !== null && p.color === byColor && p.type === PieceType.Knight) return true;
      }
    }
    // 王
    const kingOff = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]];
    for (const off of kingOff) {
      const r = sq.row + off[0];
      const c = sq.col + off[1];
      if (inBoard(r, c)) {
        const p = state.board[r][c];
        if (p !== null && p.color === byColor && p.type === PieceType.King) return true;
      }
    }
    // 直线滑子（车/后）
    const rookDirs = [[-1,0],[1,0],[0,-1],[0,1]];
    for (const d of rookDirs) {
      let r = sq.row + d[0];
      let c = sq.col + d[1];
      while (inBoard(r, c)) {
        const p = state.board[r][c];
        if (p !== null) {
          if (p.color === byColor && (p.type === PieceType.Rook || p.type === PieceType.Queen)) return true;
          break;
        }
        r += d[0];
        c += d[1];
      }
    }
    // 斜线滑子（象/后）
    const bishopDirs = [[-1,-1],[-1,1],[1,-1],[1,1]];
    for (const d of bishopDirs) {
      let r = sq.row + d[0];
      let c = sq.col + d[1];
      while (inBoard(r, c)) {
        const p = state.board[r][c];
        if (p !== null) {
          if (p.color === byColor && (p.type === PieceType.Bishop || p.type === PieceType.Queen)) return true;
          break;
        }
        r += d[0];
        c += d[1];
      }
    }
    return false;
  }

  /** 找王 */
  static findKing(state: GameState, color: Color): Pos {
    for (let r = 0; r < 8; r++) {
      for (let c = 0; c < 8; c++) {
        const p = state.board[r][c];
        if (p !== null && p.type === PieceType.King && p.color === color) {
          return { row: r, col: c };
        }
      }
    }
    return { row: -1, col: -1 };
  }

  static makeMove(from: Pos, to: Pos, piece: Piece, captured: Piece | null,
                  isK: boolean, isQ: boolean, isEP: boolean, promo: PieceType | null): Move {
    return {
      from: from, to: to, piece: piece, captured: captured,
      isCastlingK: isK, isCastlingQ: isQ, isEnPassant: isEP,
      promotion: promo, san: ''
    };
  }

  /**
   * 内部 applyMove（不产生新 history 项，不产生 SAN，用于合法性模拟）
   * 返回新的 GameState
   */
  static applyMoveInternal(state: GameState, m: Move): GameState {
    // 浅复制 board
    const board: Array<Array<Piece | null>> = [];
    for (let r = 0; r < 8; r++) {
      const row: Array<Piece | null> = [];
      for (let c = 0; c < 8; c++) {
        row.push(state.board[r][c]);
      }
      board.push(row);
    }
    board[m.from.row][m.from.col] = null;
    let movedPiece: Piece = m.piece;
    if (m.promotion !== null) {
      movedPiece = { type: m.promotion, color: m.piece.color };
    }
    board[m.to.row][m.to.col] = movedPiece;
    if (m.isEnPassant) {
      board[m.from.row][m.to.col] = null;
    }
    if (m.isCastlingK) {
      board[m.from.row][5] = board[m.from.row][7];
      board[m.from.row][7] = null;
    }
    if (m.isCastlingQ) {
      board[m.from.row][3] = board[m.from.row][0];
      board[m.from.row][0] = null;
    }
    return {
      board: board,
      turn: opposite(state.turn),
      castlingRights: state.castlingRights,
      enPassantTarget: null,
      halfmoveClock: state.halfmoveClock,
      fullmoveNumber: state.fullmoveNumber,
      history: state.history,
      status: state.status,
      winner: state.winner
    };
  }
}
