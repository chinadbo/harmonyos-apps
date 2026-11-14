import { SolarTerm } from '../model/SolarTerm';

export class Palette {
  static readonly PAGE_BG: string = '#FBF6EC';
  static readonly CARD_BG: string = '#FFFFFF';
  static readonly INK: string = '#2B2B2B';
  static readonly INK_SOFT: string = '#7A7468';
  static readonly INK_FAINT: string = '#A9A294';
  static readonly HAIRLINE: string = '#EAE2D3';
  static readonly GOLD: string = '#B8894A';
  static readonly GOLD_SOFT: string = '#F2E7D5';
  static readonly SEAL_RED: string = '#B94A3E';
  static readonly SPRING: string = '#5E9B6B';
  static readonly SUMMER: string = '#D96C4A';
  static readonly AUTUMN: string = '#C9922F';
  static readonly WINTER: string = '#5B7E9E';
}

export class Utils {
  static readonly HOU_LABELS: string[] = ['初候', '二候', '三候'];
  static readonly SEASONS: string[] = ['春', '夏', '秋', '冬'];

  static pad2(value: number): string {
    return value < 10 ? '0' + value : '' + value;
  }

  static seasonColor(season: string): string {
    if (season === '春') {
      return Palette.SPRING;
    }
    if (season === '夏') {
      return Palette.SUMMER;
    }
    if (season === '秋') {
      return Palette.AUTUMN;
    }
    return Palette.WINTER;
  }

  static seasonDeep(season: string): string {
    if (season === '春') {
      return '#3F7550';
    }
    if (season === '夏') {
      return '#A8452A';
    }
    if (season === '秋') {
      return '#96681A';
    }
    return '#3D5D79';
  }

  static seasonSoft(season: string): string {
    if (season === '春') {
      return '#EAF2E9';
    }
    if (season === '夏') {
      return '#FBE9E2';
    }
    if (season === '秋') {
      return '#F8EEDA';
    }
    return '#E8EFF5';
  }

  static seasonEn(season: string): string {
    if (season === '春') {
      return 'SPRING';
    }
    if (season === '夏') {
      return 'SUMMER';
    }
    if (season === '秋') {
      return 'AUTUMN';
    }
    return 'WINTER';
  }

  static fullDate(date: Date): string {
    return date.getFullYear() + '年' + (date.getMonth() + 1) + '月' + date.getDate() + '日';
  }

  static termMoment(term: SolarTerm): string {
    const d: Date = new Date(term.date);
    return d.getFullYear() + '年' + (d.getMonth() + 1) + '月' + d.getDate() + '日 ' +
      Utils.pad2(d.getHours()) + ':' + Utils.pad2(d.getMinutes());
  }

  static shortMoment(term: SolarTerm): string {
    return Utils.momentFromIso(term.date);
  }

  static momentFromIso(iso: string): string {
    const d: Date = new Date(iso);
    return (d.getMonth() + 1) + '月' + d.getDate() + '日 ' +
      Utils.pad2(d.getHours()) + ':' + Utils.pad2(d.getMinutes());
  }

  static weekday(date: Date): string {
    const names: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    return names[date.getDay()];
  }

  static daysText(days: number): string {
    if (days <= 0) {
      return '就是今天';
    }
    if (days === 1) {
      return '明天';
    }
    return '还有 ' + days + ' 天';
  }

  static progressPercent(progress: number): string {
    return Math.round(progress * 100) + '%';
  }
}
