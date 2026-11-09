import { STAR_GOLD, STAR_PURPLE, STAR_BLUE, POOL_STANDARD, POOL_CHAR, POOL_WEAPON } from '../model/GachaModels';
import { todayStr, normalizeDateNumber } from '../common/Format';

export class ParsedRow {
  star: number = 0;
  itemName: string = '';
  pullNo: number = 0;
  poolName: string = '';
  poolType: number = -1;
  dateStr: string = '';
  valid: boolean = false;
  reason: string = '';
}

const RE_DATE: RegExp = /(\d{4})[-\/.年](\d{1,2})[-\/.月](\d{1,2})日?/;
const RE_STAR_NUM: RegExp = /([345])\s*[星★☆✦]/;
const RE_STAR_REV: RegExp = /[★☆✦]\s*([345])/;
const RE_STAR_BRACKET: RegExp = /\[\s*([345])\s*\]/;
const RE_STAR_CN: RegExp = /(五星|四星|三星)/;
const RE_STAR_CARD: RegExp = /(金卡|紫卡|蓝卡)/;
const RE_STAR_RARITY: RegExp = /(^|\s)(SSR|SR|R)(\s|$)/;
const RE_PULL: RegExp = /第\s*(\d+)\s*抽/;
const RE_PULL_LOOSE: RegExp = /(\d+)\s*抽/;
const RE_NAME: RegExp = /[一-龥A-Za-z·]{2,}/g;

const POOL_KEYWORDS: string[] = [
  '角色池', '武器池', '标准池', '常驻池', '角色up', 'up池', '卡池', '祈愿', '限定池', '活动池'
];

const NAME_BLACKLIST: string[] = [
  '五星', '四星', '三星', '金卡', '紫卡', '蓝卡', '获得', '出货', '保底', '抽到', '歪了'
];

function starFromText(s: string): number {
  const m1 = RE_STAR_NUM.exec(s);
  if (m1 !== null) {
    return parseInt(m1[1]);
  }
  const m2 = RE_STAR_REV.exec(s);
  if (m2 !== null) {
    return parseInt(m2[1]);
  }
  const m3 = RE_STAR_BRACKET.exec(s);
  if (m3 !== null) {
    return parseInt(m3[1]);
  }
  const m4 = RE_STAR_CN.exec(s);
  if (m4 !== null) {
    if (m4[1] === '五星') {
      return STAR_GOLD;
    }
    if (m4[1] === '四星') {
      return STAR_PURPLE;
    }
    return STAR_BLUE;
  }
  const m5 = RE_STAR_CARD.exec(s);
  if (m5 !== null) {
    if (m5[1] === '金卡') {
      return STAR_GOLD;
    }
    if (m5[1] === '紫卡') {
      return STAR_PURPLE;
    }
    return STAR_BLUE;
  }
  const m6 = RE_STAR_RARITY.exec(s.toUpperCase());
  if (m6 !== null) {
    if (m6[2] === 'SSR') {
      return STAR_GOLD;
    }
    if (m6[2] === 'SR') {
      return STAR_PURPLE;
    }
    return STAR_BLUE;
  }
  return 0;
}

function poolTypeFromText(s: string): number {
  if (s.indexOf('武器') >= 0) {
    return POOL_WEAPON;
  }
  if (s.indexOf('角色') >= 0) {
    return POOL_CHAR;
  }
  if (s.indexOf('标准') >= 0 || s.indexOf('常驻') >= 0) {
    return POOL_STANDARD;
  }
  return -1;
}

function pickName(s: string): string {
  RE_NAME.lastIndex = 0;
  let best = '';
  let m = RE_NAME.exec(s);
  while (m !== null) {
    const token = m[0];
    let isKeyword = false;
    for (const k of POOL_KEYWORDS) {
      if (token.indexOf(k) >= 0) {
        isKeyword = true;
        break;
      }
    }
    if (!isKeyword) {
      for (const k of NAME_BLACKLIST) {
        if (token === k) {
          isKeyword = true;
          break;
        }
      }
    }
    if (!isKeyword && token.length > best.length) {
      best = token;
    }
    m = RE_NAME.exec(s);
  }
  return best;
}

function tryCsv(line: string, row: ParsedRow): boolean {
  let sep = '';
  if (line.indexOf('|') >= 0) {
    sep = '|';
  } else if (line.split(',').length >= 3) {
    sep = ',';
  }
  if (sep === '') {
    return false;
  }
  const fields = line.split(sep).map((s: string) => s.trim()).filter((s: string) => s.length > 0);
  let star = 0;
  let name = '';
  let pull = 0;
  for (const f of fields) {
    const dm = RE_DATE.exec(f);
    if (dm !== null && row.dateStr.length === 0) {
      row.dateStr = normalizeDateNumber(dm[1], dm[2], dm[3]);
      continue;
    }
    if (star === 0) {
      const plain = /^([345])$/.exec(f);
      if (plain !== null) {
        star = parseInt(plain[1]);
        continue;
      }
      star = starFromText(f);
      if (star > 0) {
        continue;
      }
    }
    if (pull === 0) {
      const pm = RE_PULL.exec(f);
      if (pm !== null) {
        pull = parseInt(pm[1]);
        continue;
      }
      const num = /^(\d+)$/.exec(f);
      if (num !== null) {
        pull = parseInt(num[1]);
        continue;
      }
    }
    if (name.length === 0 && f.indexOf('抽') < 0) {
      const cand = pickName(f);
      if (cand.length > 0) {
        name = cand;
        row.poolType = poolTypeFromText(f);
        continue;
      }
    }
  }
  if (star > 0 && name.length > 0) {
    row.star = star;
    row.itemName = name;
    row.pullNo = pull;
    row.valid = true;
    return true;
  }
  return false;
}

export function parseLine(line: string): ParsedRow {
  const row = new ParsedRow();
  const csvOk = tryCsv(line, row);
  if (!csvOk) {
    parseFreeText(line, row);
  }
  if (row.dateStr.length === 0) {
    row.dateStr = todayStr();
  }
  if (row.valid && row.poolName.length === 0 && row.poolType >= 0) {
    if (row.poolType === POOL_WEAPON) {
      row.poolName = '武器';
    } else if (row.poolType === POOL_CHAR) {
      row.poolName = '角色';
    } else if (row.poolType === POOL_STANDARD) {
      row.poolName = '标准';
    }
  }
  return row;
}

function parseFreeText(line: string, row: ParsedRow): void {
  let work = ` ${line} `;

  const dm = RE_DATE.exec(work);
  if (dm !== null) {
    row.dateStr = normalizeDateNumber(dm[1], dm[2], dm[3]);
    work = work.replace(dm[0], ' ');
  }

  row.star = starFromText(work);
  work = work.replace(/[★☆✦]/g, ' ');
  work = work.replace(/(五|四|三)星|金卡|紫卡|蓝卡|SSR|SR|R/g, ' ');

  row.poolType = poolTypeFromText(work);

  const pm = RE_PULL.exec(work);
  if (pm !== null) {
    row.pullNo = parseInt(pm[1]);
    work = work.replace(pm[0], ' ');
  } else {
    const p2 = RE_PULL_LOOSE.exec(work);
    if (p2 !== null) {
      row.pullNo = parseInt(p2[1]);
      work = work.replace(p2[0], ' ');
    }
  }

  row.itemName = pickName(work);
  row.valid = row.star >= 3 && row.itemName.length > 0;
  if (!row.valid) {
    if (row.star < 3) {
      row.reason = '未识别到星级（需含 5星 / 五星 / ★5 / 金卡 等标记）';
    } else {
      row.reason = '未识别到物品名';
    }
  }
}

export function parseText(text: string): ParsedRow[] {
  const rows: ParsedRow[] = [];
  const lines = text.split(/\r?\n/);
  for (const raw of lines) {
    const line = raw.trim();
    if (line.length === 0) {
      continue;
    }
    if (line.startsWith('---') || line.startsWith('===') || line.startsWith('#')) {
      continue;
    }
    rows.push(parseLine(line));
  }
  return rows;
}

export function parseSummary(rows: ParsedRow[]): string {
  let ok = 0;
  for (const r of rows) {
    if (r.valid) {
      ok++;
    }
  }
  return `解析完成：成功 ${ok} 条，失败 ${rows.length - ok} 条`;
}
