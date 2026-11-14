import { LunarDate, LunarMonthOption, SolarDateResult } from '../model/LunarDate';

/**
 * 纯 ArkTS 农历算法，数据表覆盖 1900-2100 年。
 * LUNAR_INFO 每位含义：
 *   bit 0-3   : 闰月月份（0 表示无闰月）
 *   bit 4-15  : 1-12 月大小（1 为大月 30 天）
 *   bit 16    : 闰月大小（1 为大月 30 天）
 */
const LUNAR_INFO: number[] = [
  0x04bd8, 0x04ae0, 0x0a570, 0x054d5, 0x0d260, 0x0d950, 0x16554, 0x056a0, 0x09ad0, 0x055d2,
  0x04ae0, 0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540, 0x0d6a0, 0x0ada2, 0x095b0, 0x14977,
  0x04970, 0x0a4b0, 0x0b4b5, 0x06a50, 0x06d40, 0x1ab54, 0x02b60, 0x09570, 0x052f2, 0x04970,
  0x06566, 0x0d4a0, 0x0ea50, 0x06e95, 0x05ad0, 0x02b60, 0x186e3, 0x092e0, 0x1c8d7, 0x0c950,
  0x0d4a0, 0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4, 0x025d0, 0x092d0, 0x0d2b2, 0x0a950, 0x0b557,
  0x06ca0, 0x0b550, 0x15355, 0x04da0, 0x0a5b0, 0x14573, 0x052b0, 0x0a9a8, 0x0e950, 0x06aa0,
  0x0aea6, 0x0ab50, 0x04b60, 0x0aae4, 0x0a570, 0x05260, 0x0f263, 0x0d950, 0x05b57, 0x056a0,
  0x096d0, 0x04dd5, 0x04ad0, 0x0a4d0, 0x0d4d4, 0x0d250, 0x0d558, 0x0b540, 0x0b6a0, 0x195a6,
  0x095b0, 0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50, 0x06d40, 0x0af46, 0x0ab60, 0x09570,
  0x04af5, 0x04970, 0x064b0, 0x074a3, 0x0ea50, 0x06b58, 0x05ac0, 0x0ab60, 0x096d5, 0x092e0,
  0x0c960, 0x0d954, 0x0d4a0, 0x0da50, 0x07552, 0x056a0, 0x0abb7, 0x025d0, 0x092d0, 0x0cab5,
  0x0a950, 0x0b4a0, 0x0baa4, 0x0ad50, 0x055d9, 0x04ba0, 0x0a5b0, 0x15176, 0x052b0, 0x0a930,
  0x07954, 0x06aa0, 0x0ad50, 0x05b52, 0x04b60, 0x0a6e6, 0x0a4e0, 0x0d260, 0x0ea65, 0x0d530,
  0x05aa0, 0x076a3, 0x096d0, 0x04afb, 0x04ad0, 0x0a4d0, 0x1d0b6, 0x0d250, 0x0d520, 0x0dd45,
  0x0b5a0, 0x056d0, 0x055b2, 0x049b0, 0x0a577, 0x0a4b0, 0x0aa50, 0x1b255, 0x06d20, 0x0ada0,
  0x14b63, 0x09370, 0x049f8, 0x04970, 0x064b0, 0x168a6, 0x0ea50, 0x06b20, 0x1a6c4, 0x0aae0,
  0x092e0, 0x0d2e3, 0x0c960, 0x0d557, 0x0d4a0, 0x0da50, 0x05d55, 0x056a0, 0x0a6d0, 0x055d4,
  0x052d0, 0x0a9b8, 0x0a950, 0x0b4a0, 0x0b6a6, 0x0ad50, 0x055a0, 0x0aba4, 0x0a5b0, 0x052b0,
  0x0b273, 0x06930, 0x07337, 0x06aa0, 0x0ad50, 0x14b55, 0x04b60, 0x0a570, 0x054e4, 0x0d160,
  0x0e968, 0x0d520, 0x0daa0, 0x16aa6, 0x056d0, 0x04ae0, 0x0a9d4, 0x0a2d0, 0x0d150, 0x0f252,
  0x0d520
];

const BASE_UTC: number = Date.UTC(1900, 0, 31);
const DAY_MS: number = 86400000;
const MIN_YEAR: number = 1901;
const MAX_YEAR: number = 2099;
const WEEKDAYS: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

export class LunarCalendar {
  static readonly GAN: string[] = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  static readonly ZHI: string[] = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
  static readonly ZODIAC: string[] = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'];
  static readonly CN_MONTH: string[] = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '腊'];
  static readonly CN_DAY: string[] = [
    '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
    '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
    '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
  ];

  static minYear(): number {
    return MIN_YEAR;
  }

  static maxYear(): number {
    return MAX_YEAR;
  }

  private static cyclical(index: number): string {
    const g: number = ((index % 10) + 10) % 10;
    const z: number = ((index % 12) + 12) % 12;
    return LunarCalendar.GAN[g] + LunarCalendar.ZHI[z];
  }

  private static yearDays(year: number): number {
    const info: number = LUNAR_INFO[year - 1900];
    let sum: number = 348;
    for (let i: number = 0x8000; i > 0x8; i >>= 1) {
      sum += (info & i) !== 0 ? 1 : 0;
    }
    return sum + LunarCalendar.leapDays(year);
  }

  static leapMonth(year: number): number {
    if (year < 1900 || year > 2100) {
      return 0;
    }
    return LUNAR_INFO[year - 1900] & 0xf;
  }

  private static leapDays(year: number): number {
    if (LunarCalendar.leapMonth(year) === 0) {
      return 0;
    }
    return (LUNAR_INFO[year - 1900] & 0x10000) !== 0 ? 30 : 29;
  }

  static monthDays(year: number, month: number): number {
    if (month < 1 || month > 12) {
      return 0;
    }
    return (LUNAR_INFO[year - 1900] & (0x10000 >> month)) !== 0 ? 30 : 29;
  }

  static daysInMonth(year: number, month: number, isLeap: boolean): number {
    if (isLeap) {
      return LunarCalendar.leapMonth(year) === month ? LunarCalendar.leapDays(year) : 0;
    }
    return LunarCalendar.monthDays(year, month);
  }

  static yearGanZhi(year: number): string {
    return LunarCalendar.cyclical(year - 4);
  }

  static zodiac(year: number): string {
    return LunarCalendar.ZODIAC[((year - 4) % 12 + 12) % 12];
  }

  static monthGanZhi(year: number, month: number): string {
    const yearStem: number = ((year - 4) % 10 + 10) % 10;
    const stem: number = (yearStem % 5 * 2 + month + 1) % 10;
    const branch: number = (month + 1) % 12;
    return LunarCalendar.GAN[stem] + LunarCalendar.ZHI[branch];
  }

  static dayGanZhi(year: number, month: number, day: number): string {
    const offset: number = Math.floor((Date.UTC(year, month - 1, day) - BASE_UTC) / DAY_MS);
    return LunarCalendar.cyclical(offset + 40);
  }

  static solarToLunar(year: number, month: number, day: number): LunarDate {
    let offset: number = Math.floor((Date.UTC(year, month - 1, day) - BASE_UTC) / DAY_MS);
    let temp: number = 0;
    let y: number = 1900;
    while (y < 2101 && offset > 0) {
      temp = LunarCalendar.yearDays(y);
      offset -= temp;
      y++;
    }
    if (offset < 0) {
      offset += temp;
      y--;
    }
    const lunarYear: number = y;
    const leap: number = LunarCalendar.leapMonth(lunarYear);
    let isLeap: boolean = false;
    let m: number = 1;
    while (m < 13 && offset > 0) {
      if (leap > 0 && m === leap + 1 && !isLeap) {
        m--;
        isLeap = true;
        temp = LunarCalendar.leapDays(lunarYear);
      } else {
        temp = LunarCalendar.monthDays(lunarYear, m);
      }
      if (isLeap && m === leap + 1) {
        isLeap = false;
      }
      offset -= temp;
      m++;
    }
    if (offset === 0 && leap > 0 && m === leap + 1) {
      if (isLeap) {
        isLeap = false;
      } else {
        isLeap = true;
        m--;
      }
    }
    if (offset < 0) {
      offset += temp;
      m--;
    }
    const lunarMonth: number = m;
    const lunarDay: number = offset + 1;
    return LunarCalendar.buildLunarDate(lunarYear, lunarMonth, lunarDay, isLeap, year, month, day);
  }

  private static buildLunarDate(lunarYear: number, lunarMonth: number, lunarDay: number,
    isLeap: boolean, solarYear: number, solarMonth: number, solarDay: number): LunarDate {
    const monthName: string = (isLeap ? '闰' : '') + LunarCalendar.CN_MONTH[lunarMonth - 1] + '月';
    const dayName: string = LunarCalendar.CN_DAY[lunarDay - 1];
    const ganzhiYear: string = LunarCalendar.yearGanZhi(lunarYear);
    const ganzhiMonth: string = LunarCalendar.monthGanZhi(lunarYear, lunarMonth);
    const ganzhiDay: string = LunarCalendar.dayGanZhi(solarYear, solarMonth, solarDay);
    const zodiac: string = LunarCalendar.zodiac(lunarYear);
    const result: LunarDate = {
      year: lunarYear,
      month: lunarMonth,
      day: lunarDay,
      isLeap: isLeap,
      ganzhiYear: ganzhiYear,
      ganzhiMonth: ganzhiMonth,
      ganzhiDay: ganzhiDay,
      zodiac: zodiac,
      monthName: monthName,
      dayName: dayName,
      text: ganzhiYear + '年 ' + monthName + dayName
    };
    return result;
  }

  static lunarToSolar(lunarYear: number, lunarMonth: number, lunarDay: number, isLeap: boolean): SolarDateResult {
    let offset: number = 0;
    for (let y: number = 1900; y < lunarYear; y++) {
      offset += LunarCalendar.yearDays(y);
    }
    const leap: number = LunarCalendar.leapMonth(lunarYear);
    for (let m: number = 1; m <= 12; m++) {
      if (m === lunarMonth) {
        if (isLeap) {
          offset += LunarCalendar.monthDays(lunarYear, m);
        }
        break;
      }
      offset += LunarCalendar.monthDays(lunarYear, m);
      if (leap === m) {
        offset += LunarCalendar.leapDays(lunarYear);
      }
    }
    offset += lunarDay - 1;
    const utc: Date = new Date(BASE_UTC + offset * DAY_MS);
    const sy: number = utc.getUTCFullYear();
    const sm: number = utc.getUTCMonth() + 1;
    const sd: number = utc.getUTCDate();
    const local: Date = new Date(sy, sm - 1, sd);
    const result: SolarDateResult = {
      year: sy,
      month: sm,
      day: sd,
      weekday: WEEKDAYS[local.getDay()]
    };
    return result;
  }

  static monthOptions(year: number): LunarMonthOption[] {
    const options: LunarMonthOption[] = [];
    const leap: number = LunarCalendar.leapMonth(year);
    for (let m: number = 1; m <= 12; m++) {
      const normal: LunarMonthOption = {
        month: m,
        isLeap: false,
        label: LunarCalendar.CN_MONTH[m - 1] + '月'
      };
      options.push(normal);
      if (leap === m) {
        const leapOption: LunarMonthOption = {
          month: m,
          isLeap: true,
          label: '闰' + LunarCalendar.CN_MONTH[m - 1] + '月'
        };
        options.push(leapOption);
      }
    }
    return options;
  }

  static dayLabel(day: number): string {
    return LunarCalendar.CN_DAY[day - 1];
  }
}
