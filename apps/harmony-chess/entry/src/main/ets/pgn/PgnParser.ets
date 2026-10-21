/**
 * PGN 解析与生成（简化版）
 * 支持 Tag Pairs + Movetext（SAN），不支持变体/注释嵌套
 */
import { GameState, Move, GameRecord } from '../model/Types';
import { ChessEngine } from '../engine/ChessEngine';
import { SanCodec } from './SanCodec';

export interface PgnGame {
  tags: Record<string, string>;
  moves: string[];  // SAN 字符串列表
  result: string;
}

export class PgnParser {
  /**
   * 解析单局 PGN
   */
  static parse(pgn: string): PgnGame | null {
    const tags: Record<string, string> = {};
    const lines = pgn.split('\n');
    let i = 0;
    // tag pairs
    while (i < lines.length) {
      const line = lines[i].trim();
      if (line.length === 0) {
        i++;
        continue;
      }
      if (line.startsWith('[')) {
        const m = line.match(/^\[\s*(\w+)\s+"([^"]*)"\s*\]\s*$/);
        if (m) {
          tags[m[1]] = m[2];
        }
        i++;
      } else {
        break;
      }
    }
    // movetext
    let movetext = '';
    for (; i < lines.length; i++) {
      movetext += lines[i] + ' ';
    }
    movetext = movetext.trim();
    // 去注释 {} 和 ;
    movetext = movetext.replace(/\{[^}]*\}/g, ' ');
    movetext = movetext.replace(/;[^\n]*/g, ' ');
    // 去变体（）—— 简化：直接剔除
    movetext = movetext.replace(/\([^()]*\)/g, ' ');

    const tokens = movetext.split(/\s+/);
    const moves: string[] = [];
    let result = '*';
    for (let k = 0; k < tokens.length; k++) {
      const t = tokens[k];
      if (!t) continue;
      if (t === '1-0' || t === '0-1' || t === '1/2-1/2' || t === '*') {
        result = t;
        continue;
      }
      // 跳过 move number（如 "1." "23..."）
      if (/^\d+\.(\.\.)?$/.test(t)) {
        continue;
      }
      if (/^\d+\.\S/.test(t)) {
        // 形如 "1.e4"
        const idx = t.indexOf('.');
        const san = t.substring(idx + 1);
        if (san.length > 0) {
          moves.push(san);
        }
        continue;
      }
      moves.push(t);
    }
    return { tags: tags, moves: moves, result: result };
  }

  /**
   * 把 PGN 解析为重放用的 Move 序列
   */
  static parseMoves(pgn: string): Move[] | null {
    const g = PgnParser.parse(pgn);
    if (!g) {
      return null;
    }
    let state = ChessEngine.initial();
    const out: Move[] = [];
    for (let i = 0; i < g.moves.length; i++) {
      const mv = SanCodec.decode(state, g.moves[i]);
      if (!mv) {
        return null;
      }
      mv.san = g.moves[i];
      out.push(mv);
      state = ChessEngine.applyMove(state, mv);
    }
    return out;
  }

  /**
   * 根据 state.history 生成 PGN
   */
  static generate(
    state: GameState,
    tags: Record<string, string>,
    result: string
  ): string {
    let out = '';
    const keys = ['Event', 'Site', 'Date', 'Round', 'White', 'Black', 'Result'];
    const allTags: Record<string, string> = {};
    for (let i = 0; i < keys.length; i++) {
      const k = keys[i];
      if (k === 'Result') {
        allTags[k] = result;
      } else if (tags[k]) {
        allTags[k] = tags[k];
      } else {
        allTags[k] = '?';
      }
    }
    // 附加自定义 tag
    const extraKeys = Object.keys(tags);
    for (let i = 0; i < extraKeys.length; i++) {
      const k = extraKeys[i];
      if (!allTags[k]) {
        allTags[k] = tags[k];
      }
    }
    const allKeys = Object.keys(allTags);
    for (let i = 0; i < allKeys.length; i++) {
      const k = allKeys[i];
      out += `[${k} "${allTags[k]}"]\n`;
    }
    out += '\n';
    // movetext
    for (let i = 0; i < state.history.length; i++) {
      if (i % 2 === 0) {
        out += `${Math.floor(i / 2) + 1}. `;
      }
      const san = state.history[i].san ? state.history[i].san : '?';
      out += san + ' ';
    }
    out += result;
    return out;
  }

  /**
   * 由 GameState 推出结果字符串
   */
  static resultOf(state: GameState): string {
    if (state.status === 'checkmate' || state.status === 'resigned') {
      if (!state.winner) return '*';
      return state.winner === 'w' ? '1-0' : '0-1';
    }
    if (state.status === 'stalemate' || state.status === 'draw') {
      return '1/2-1/2';
    }
    return '*';
  }
}
