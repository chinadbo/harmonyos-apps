import util from '@ohos.util';
import common from '@ohos.app.ability.common';
import { SolarTerm, TermDateEntry, TermDetailInfo, TermFile } from '../model/SolarTerm';

const DAY_MS: number = 86400000;

export class SolarTermData {
  private static terms: SolarTerm[] = [];
  private static byId: Map<string, SolarTerm> = new Map();
  private static byName: Map<string, SolarTerm[]> = new Map();
  private static loading: Promise<void> | null = null;
  private static loaded: boolean = false;

  static init(context: common.UIAbilityContext): Promise<void> {
    if (SolarTermData.loaded) {
      return Promise.resolve();
    }
    if (SolarTermData.loading !== null) {
      return SolarTermData.loading;
    }
    const task: Promise<void> = SolarTermData.load(context);
    SolarTermData.loading = task;
    return task;
  }

  private static async load(context: common.UIAbilityContext): Promise<void> {
    try {
      const data: Uint8Array = await context.resourceManager.getRawFileContent('terms.json');
      const decoder: util.TextDecoder = util.TextDecoder.create('utf-8');
      const text: string = decoder.decodeToString(data);
      const file: TermFile = JSON.parse(text) as TermFile;
      const detailMap: Map<string, TermDetailInfo> = new Map();
      for (let i: number = 0; i < file.details.length; i++) {
        detailMap.set(file.details[i].name, file.details[i]);
      }
      const result: SolarTerm[] = [];
      for (let i: number = 0; i < file.terms.length; i++) {
        const entry: TermDateEntry = file.terms[i];
        const date: Date = new Date(entry.date);
        const year: number = date.getFullYear();
        const detail: TermDetailInfo | undefined = detailMap.get(entry.name);
        if (detail === undefined) {
          continue;
        }
        const term: SolarTerm = {
          id: year + '-' + entry.name,
          name: entry.name,
          en: entry.en,
          season: entry.season,
          date: entry.date,
          year: year,
          julianDay: date.getTime() / DAY_MS + 2440587.5,
          description: detail.description,
          yuxiang: detail.yuxiang,
          customs: detail.customs,
          healthTips: detail.healthTips,
          poem: detail.poem,
          taboos: detail.taboos,
          suitable: detail.suitable
        };
        result.push(term);
      }
      result.sort((a: SolarTerm, b: SolarTerm): number => {
        return new Date(a.date).getTime() - new Date(b.date).getTime();
      });
      SolarTermData.terms = result;
      SolarTermData.byId = new Map();
      SolarTermData.byName = new Map();
      for (let i: number = 0; i < result.length; i++) {
        const term: SolarTerm = result[i];
        SolarTermData.byId.set(term.id, term);
        const list: SolarTerm[] | undefined = SolarTermData.byName.get(term.name);
        if (list === undefined) {
          SolarTermData.byName.set(term.name, [term]);
        } else {
          list.push(term);
        }
      }
      SolarTermData.loaded = true;
    } catch (err) {
      console.error('SolarTermData load failed: ' + String(err));
    } finally {
      SolarTermData.loading = null;
    }
  }

  static isReady(): boolean {
    return SolarTermData.loaded;
  }

  static getAll(): SolarTerm[] {
    return SolarTermData.terms;
  }

  static getYears(): number[] {
    const years: number[] = [];
    for (let i: number = 0; i < SolarTermData.terms.length; i++) {
      const year: number = SolarTermData.terms[i].year;
      if (years.indexOf(year) < 0) {
        years.push(year);
      }
    }
    years.sort((a: number, b: number): number => a - b);
    return years;
  }

  static getByYear(year: number): SolarTerm[] {
    const result: SolarTerm[] = [];
    for (let i: number = 0; i < SolarTermData.terms.length; i++) {
      if (SolarTermData.terms[i].year === year) {
        result.push(SolarTermData.terms[i]);
      }
    }
    return result;
  }

  static getBySeason(year: number, season: string): SolarTerm[] {
    const result: SolarTerm[] = [];
    for (let i: number = 0; i < SolarTermData.terms.length; i++) {
      const term: SolarTerm = SolarTermData.terms[i];
      if (term.year === year && term.season === season) {
        result.push(term);
      }
    }
    return result;
  }

  static getById(id: string): SolarTerm | undefined {
    return SolarTermData.byId.get(id);
  }

  static getByName(name: string): SolarTerm[] {
    const list: SolarTerm[] | undefined = SolarTermData.byName.get(name);
    return list === undefined ? [] : list;
  }

  static getForDate(date: Date): SolarTerm | undefined {
    const ms: number = date.getTime();
    let current: SolarTerm | undefined = undefined;
    for (let i: number = 0; i < SolarTermData.terms.length; i++) {
      if (new Date(SolarTermData.terms[i].date).getTime() <= ms) {
        current = SolarTermData.terms[i];
      } else {
        break;
      }
    }
    if (current === undefined && SolarTermData.terms.length > 0) {
      current = SolarTermData.terms[0];
    }
    return current;
  }

  static getNext(date: Date): SolarTerm | undefined {
    const ms: number = date.getTime();
    for (let i: number = 0; i < SolarTermData.terms.length; i++) {
      if (new Date(SolarTermData.terms[i].date).getTime() > ms) {
        return SolarTermData.terms[i];
      }
    }
    return undefined;
  }

  static getProgress(date: Date, current: SolarTerm, next: SolarTerm | undefined): number {
    const now: number = date.getTime();
    const start: number = new Date(current.date).getTime();
    if (next === undefined) {
      return 1;
    }
    const end: number = new Date(next.date).getTime();
    if (now <= start) {
      return 0;
    }
    if (now >= end) {
      return 1;
    }
    return (now - start) / (end - start);
  }

  static getDaysToNext(date: Date, next: SolarTerm | undefined): number {
    if (next === undefined) {
      return 0;
    }
    const diff: number = new Date(next.date).getTime() - date.getTime();
    return Math.max(0, Math.ceil(diff / DAY_MS));
  }

  static getHouIndex(date: Date, current: SolarTerm): number {
    const elapsed: number = date.getTime() - new Date(current.date).getTime();
    const days: number = elapsed / DAY_MS;
    if (days <= 0) {
      return 0;
    }
    const index: number = Math.floor(days / 5);
    return Math.min(2, index);
  }

  static getUpcoming(date: Date, count: number): SolarTerm[] {
    const result: SolarTerm[] = [];
    const ms: number = date.getTime();
    for (let i: number = 0; i < SolarTermData.terms.length && result.length < count; i++) {
      if (new Date(SolarTermData.terms[i].date).getTime() > ms) {
        result.push(SolarTermData.terms[i]);
      }
    }
    return result;
  }
}
