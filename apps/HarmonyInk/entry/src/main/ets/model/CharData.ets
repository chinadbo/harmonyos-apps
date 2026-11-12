import common from '@ohos.app.ability.common';
import util from '@ohos.util';
import hilog from '@ohos.hilog';
import { Constants } from '../common/Constants';
import { DateUtil } from '../common/AppUtil';

const DOMAIN: number = 0x0000;
const TAG: string = 'HarmonyInk-repo';

/** 归一化笔画采样点（0-100，原点左上，y 轴向下） */
export interface StrokePoint {
  x: number;
  y: number;
}

/** 单笔数据：类型、折线采样点、起笔方向角（度） */
export interface Stroke {
  index: number;
  type: string;
  points: StrokePoint[];
  startDir: number;
}

/** 一个汉字条目 */
export interface CharEntry {
  char: string;
  pinyin: string;
  grade: number;
  strokes: Stroke[];
}

/**
 * 字库仓库：首次从 rawfile/chars.json 读取并缓存。
 * 所有页面共享同一个实例，避免重复解析。
 */
export class CharRepository {
  private static instance: CharRepository | undefined = undefined;
  private allChars: CharEntry[] = [];
  private pending: Promise<CharEntry[]> | undefined = undefined;

  static getInstance(): CharRepository {
    if (CharRepository.instance === undefined) {
      CharRepository.instance = new CharRepository();
    }
    return CharRepository.instance;
  }

  async load(context: common.UIAbilityContext): Promise<CharEntry[]> {
    if (this.allChars.length > 0) {
      return this.allChars;
    }
    if (this.pending !== undefined) {
      return this.pending;
    }
    this.pending = this.readRaw(context);
    const list: CharEntry[] = await this.pending;
    this.allChars = list;
    this.pending = undefined;
    return this.allChars;
  }

  private async readRaw(context: common.UIAbilityContext): Promise<CharEntry[]> {
    try {
      const data: Uint8Array = await context.resourceManager.getRawFileContent('chars.json');
      const decoder: util.TextDecoder = util.TextDecoder.create('utf-8');
      const text: string = decoder.decodeToString(data);
      const parsed: CharEntry[] = JSON.parse(text) as CharEntry[];
      hilog.info(DOMAIN, TAG, 'loaded %{public}d chars', parsed.length);
      return parsed;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'load chars failed: %{public}s', JSON.stringify(err));
      return [];
    }
  }

  getChars(): CharEntry[] {
    return this.allChars;
  }

  getByChar(char: string): CharEntry | undefined {
    for (let i = 0; i < this.allChars.length; i++) {
      if (this.allChars[i].char === char) {
        return this.allChars[i];
      }
    }
    return undefined;
  }

  getByGrade(grade: number): CharEntry[] {
    const result: CharEntry[] = [];
    for (let i = 0; i < this.allChars.length; i++) {
      if (grade <= 0 || this.allChars[i].grade === grade) {
        result.push(this.allChars[i]);
      }
    }
    return result;
  }

  /** 按日期种子挑选每日推荐字，同一天内稳定 */
  getDailyChar(grade: number): CharEntry | undefined {
    const pool: CharEntry[] = this.getByGrade(grade);
    if (pool.length === 0) {
      return this.allChars.length > 0 ? this.allChars[0] : undefined;
    }
    const index: number = Constants.dailySeed() % pool.length;
    return pool[index];
  }

  /** 当前字之外的下一字（同年级内循环） */
  getNextChar(char: string, grade: number): CharEntry | undefined {
    const pool: CharEntry[] = this.getByGrade(grade);
    if (pool.length === 0) {
      return undefined;
    }
    for (let i = 0; i < pool.length; i++) {
      if (pool[i].char === char) {
        return pool[(i + 1) % pool.length];
      }
    }
    return pool[0];
  }
}

/** 字库相关的纯函数工具 */
export class CharUtil {
  static strokeCount(entry: CharEntry): number {
    return entry.strokes.length;
  }

  static typeSummary(entry: CharEntry): string {
    const names: string[] = [];
    for (let i = 0; i < entry.strokes.length; i++) {
      names.push(entry.strokes[i].type);
    }
    return names.join('、');
  }

  static difficultyOf(entry: CharEntry): string {
    return Constants.difficultyLabel(entry.strokes.length);
  }

  static formatGrade(entry: CharEntry): string {
    return Constants.gradeLabel(entry.grade);
  }

  static matches(entry: CharEntry, keyword: string): boolean {
    const trimmed: string = keyword.trim();
    if (trimmed.length === 0) {
      return true;
    }
    return entry.char.indexOf(trimmed) >= 0 ||
      entry.pinyin.toLowerCase().indexOf(trimmed.toLowerCase()) >= 0;
  }

  static todayLabel(): string {
    return `${DateUtil.weekdayCN(new Date())} · ${DateUtil.todayKey()}`;
  }
}
