import { PieceType, Color, Piece } from '../model/Types';

export class Constants {
  static readonly INITIAL_FEN: string = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  static readonly PIECE_VALUE: Record<string, number> = {
    'p': 100, 'n': 320, 'b': 330, 'r': 500, 'q': 900, 'k': 20000
  };

  static pieceValue(t: PieceType): number {
    return Constants.PIECE_VALUE[t as string];
  }

  static unicodeOf(p: Piece): string {
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

  static fileLetter(col: number): string {
    return 'abcdefgh'.charAt(col);
  }

  static rankDigit(row: number): string {
    return String(8 - row);
  }

  static posToAlg(row: number, col: number): string {
    return Constants.fileLetter(col) + Constants.rankDigit(row);
  }

  static algToPos(alg: string): { row: number; col: number } {
    const col = 'abcdefgh'.indexOf(alg.charAt(0));
    const row = 8 - Number(alg.charAt(1));
    return { row: row, col: col };
  }
}
