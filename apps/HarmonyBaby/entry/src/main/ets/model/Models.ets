import { TimeUtils } from '../utils/TimeUtils';

/** 喂养类型 */
export enum FeedType {
  NursingLeft = 'nursing_left',
  NursingRight = 'nursing_right',
  Bottle = 'bottle',
  Solid = 'solid'
}

/** 尿布类型 */
export enum DiaperType {
  Wet = 'wet',
  Dirty = 'dirty',
  Mixed = 'mixed',
  Dry = 'dry'
}

/** 睡眠质量 */
export enum SleepQuality {
  Good = 'good',
  Fair = 'fair',
  Poor = 'poor'
}

/** 宝宝性别 */
export enum BabyGender {
  Boy = 'boy',
  Girl = 'girl'
}

export class FeedRecord {
  id: number = -1;
  type: string = FeedType.Bottle;
  amount: number = 0;
  duration: number = 0;
  note: string = '';
  startTime: number = 0;
  endTime: number = 0;
}

export class DiaperRecord {
  id: number = -1;
  type: string = DiaperType.Wet;
  note: string = '';
  changeTime: number = 0;
}

export class SleepRecord {
  id: number = -1;
  startTime: number = 0;
  endTime: number = 0;
  quality: string = SleepQuality.Good;
  note: string = '';

  /** 睡眠时长（毫秒），进行中的按当前时间计算 */
  duration(): number {
    const end = this.endTime > 0 ? this.endTime : Date.now();
    return end - this.startTime;
  }
}

export class GrowthRecord {
  id: number = -1;
  measureTime: number = 0;
  weight: number = 0;
  height: number = 0;
  headCirc: number = 0;
  note: string = '';
}

/** 宝宝档案（Preferences 存储） */
export class BabyProfile {
  name: string = '';
  birthday: number = 0;
  gender: string = BabyGender.Boy;
}

/** 单日统计 */
export class DaySummary {
  startMs: number = 0;
  label: string = '';
  feedCount: number = 0;
  feedMl: number = 0;
  diaperCount: number = 0;
  sleepMs: number = 0;
}

/** 一段时间内四类记录的集合 */
export class PeriodRecords {
  feeds: FeedRecord[] = [];
  diapers: DiaperRecord[] = [];
  sleeps: SleepRecord[] = [];
  growth: GrowthRecord[] = [];
}

/** 看板/月历中合并展示的记录条目 */
export class DailyRecord {
  kind: string = '';
  recordId: number = -1;
  icon: string = '📝';
  title: string = '';
  subtitle: string = '';
  timeMs: number = 0;
}

export function feedIcon(type: string): string {
  switch (type) {
    case FeedType.NursingLeft:
    case FeedType.NursingRight:
      return '🤱';
    case FeedType.Solid:
      return '🥣';
    default:
      return '🍼';
  }
}

export function feedTitle(type: string): string {
  switch (type) {
    case FeedType.NursingLeft:
      return '母乳 · 左侧';
    case FeedType.NursingRight:
      return '母乳 · 右侧';
    case FeedType.Solid:
      return '辅食';
    default:
      return '奶瓶';
  }
}

export function diaperIcon(type: string): string {
  switch (type) {
    case DiaperType.Wet:
      return '💦';
    case DiaperType.Dirty:
      return '💩';
    case DiaperType.Mixed:
      return '🚼';
    default:
      return '🧷';
  }
}

export function diaperTitle(type: string): string {
  switch (type) {
    case DiaperType.Wet:
      return '小便';
    case DiaperType.Dirty:
      return '大便';
    case DiaperType.Mixed:
      return '混合';
    default:
      return '干爽';
  }
}

export function sleepQualityText(quality: string): string {
  switch (quality) {
    case SleepQuality.Good:
      return '睡得香';
    case SleepQuality.Fair:
      return '一般';
    case SleepQuality.Poor:
      return '易醒';
    default:
      return '';
  }
}

/** 合并一段时间内的四类记录为按时间倒序的展示列表 */
export function buildDailyRecords(records: PeriodRecords): DailyRecord[] {
  const list: DailyRecord[] = [];
  const feeds = records.feeds;
  for (let i = 0; i < feeds.length; i++) {
    const r = feeds[i];
    const item = new DailyRecord();
    item.kind = 'feed';
    item.recordId = r.id;
    item.icon = feedIcon(r.type);
    item.title = feedTitle(r.type);
    item.timeMs = r.startTime;
    if (r.type === FeedType.Bottle) {
      item.subtitle = r.amount + 'ml';
    } else if (r.type === FeedType.Solid) {
      item.subtitle = r.note;
    } else {
      item.subtitle = TimeUtils.formatDuration(r.duration);
    }
    if (r.note.length > 0 && r.type !== FeedType.Solid) {
      item.subtitle = item.subtitle + ' · ' + r.note;
    }
    list.push(item);
  }
  const diapers = records.diapers;
  for (let i = 0; i < diapers.length; i++) {
    const r = diapers[i];
    const item = new DailyRecord();
    item.kind = 'diaper';
    item.recordId = r.id;
    item.icon = diaperIcon(r.type);
    item.title = diaperTitle(r.type);
    item.subtitle = r.note;
    item.timeMs = r.changeTime;
    list.push(item);
  }
  const sleeps = records.sleeps;
  for (let i = 0; i < sleeps.length; i++) {
    const r = sleeps[i];
    const item = new DailyRecord();
    item.kind = 'sleep';
    item.recordId = r.id;
    item.icon = '😴';
    if (r.endTime > 0) {
      item.title = TimeUtils.formatDuration(r.duration());
      item.subtitle = sleepQualityText(r.quality);
    } else {
      item.title = '睡眠中';
      item.subtitle = TimeUtils.formatTime(r.startTime) + ' 入睡';
    }
    item.timeMs = r.startTime;
    list.push(item);
  }
  const growth = records.growth;
  for (let i = 0; i < growth.length; i++) {
    const r = growth[i];
    const item = new DailyRecord();
    item.kind = 'growth';
    item.recordId = r.id;
    item.icon = '📏';
    item.title = '成长记录';
    let sub = '';
    if (r.weight > 0) {
      sub = r.weight + 'kg';
    }
    if (r.height > 0) {
      sub = sub.length > 0 ? sub + ' · ' + r.height + 'cm' : r.height + 'cm';
    }
    if (r.headCirc > 0) {
      sub = sub.length > 0 ? sub + ' · 头围' + r.headCirc + 'cm' : '头围' + r.headCirc + 'cm';
    }
    item.subtitle = sub;
    item.timeMs = r.measureTime;
    list.push(item);
  }
  list.sort((a: DailyRecord, b: DailyRecord) => b.timeMs - a.timeMs);
  return list;
}
