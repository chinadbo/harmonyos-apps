import { LyricLine } from '../model/LyricLine';

    export class LyricParser {
      static parse(content: string): LyricLine[] {
        const lines: LyricLine[] = [];
        const rowList: string[] = content.split(/?
/);
        const regex: RegExp = /\[(\d{2}):(\d{2})(?:\.(\d{1,2}))?\]/g;
        for (const row of rowList) {
          const text: string = row.replace(regex, '').trim();
          regex.lastIndex = 0;
          let match: RegExpExecArray | null = regex.exec(row);
          while (match !== null) {
            const line: LyricLine = new LyricLine();
            const minutes: number = Number(match[1]);
            const seconds: number = Number(match[2]);
            const centiseconds: number = Number(match[3] ?? '0');
            line.timeMs = minutes * 60 * 1000 + seconds * 1000 + centiseconds * 10;
            line.text = text;
            lines.push(line);
            match = regex.exec(row);
          }
        }
        lines.sort((left: LyricLine, right: LyricLine) => left.timeMs - right.timeMs);
        return lines;
      }

      static findCurrentLine(lines: LyricLine[], timeMs: number): number {
        if (lines.length === 0) {
          return 0;
        }
        let index: number = 0;
        for (let i = 0; i < lines.length; i++) {
          if (lines[i].timeMs <= timeMs) {
            index = i;
            continue;
          }
          break;
        }
        return index;
      }
    }
