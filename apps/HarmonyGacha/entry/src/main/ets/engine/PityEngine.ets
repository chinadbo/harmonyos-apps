import { GachaRecord, STAR_GOLD, POOL_WEAPON } from '../model/GachaModels';
import { clampN } from '../common/Format';

export const EXPECTED_GOLD_PULLS: number = 62;
export const BASE_GOLD_RATE: number = 0.006;
export const SOFT_RATE_STEP: number = 0.06;

export class PityConfig {
  hardPity: number = 90;
  softStart: number = 74;

  constructor(hardPity: number, softStart: number) {
    this.hardPity = hardPity;
    this.softStart = softStart;
  }
}

export function pityConfigOf(poolType: number): PityConfig {
  if (poolType === POOL_WEAPON) {
    return new PityConfig(80, 66);
  }
  return new PityConfig(90, 74);
}

function sortRecords(records: GachaRecord[]): GachaRecord[] {
  return records.slice().sort((a: GachaRecord, b: GachaRecord) => {
    if (a.createdAt !== b.createdAt) {
      return a.createdAt - b.createdAt;
    }
    return a.id - b.id;
  });
}

export function computePity(records: GachaRecord[], poolId: number): number {
  const perPool: Map<number, number> = new Map();
  const sorted = sortRecords(records);
  for (const r of sorted) {
    if (r.poolId !== poolId) {
      continue;
    }
    const prev = perPool.get(r.poolId);
    const counter = (prev === undefined ? 0 : prev) + 1;
    perPool.set(r.poolId, counter);
    if (r.star === STAR_GOLD) {
      perPool.set(r.poolId, 0);
    }
  }
  const val = perPool.get(poolId);
  return val === undefined ? 0 : val;
}

export function goldPullNumbers(records: GachaRecord[]): number[] {
  const counters: Map<number, number> = new Map();
  const result: number[] = [];
  const sorted = sortRecords(records);
  for (const r of sorted) {
    const prev = counters.get(r.poolId);
    const counter = (prev === undefined ? 0 : prev) + 1;
    if (r.star === STAR_GOLD) {
      result.push(r.pullNo > 0 ? r.pullNo : counter);
      counters.set(r.poolId, 0);
    } else {
      counters.set(r.poolId, counter);
    }
  }
  return result;
}

export function avgGoldPulls(records: GachaRecord[]): number {
  const pulls = goldPullNumbers(records);
  if (pulls.length === 0) {
    return 0;
  }
  let sum = 0;
  for (const p of pulls) {
    sum += p;
  }
  return sum / pulls.length;
}

export function luckIndex(records: GachaRecord[]): number {
  const pulls = goldPullNumbers(records);
  if (pulls.length === 0) {
    return -1;
  }
  let sum = 0;
  for (const p of pulls) {
    sum += p;
  }
  const avg = sum / pulls.length;
  const ratio = avg / EXPECTED_GOLD_PULLS;
  const score = (2 - ratio) * 50;
  return Math.round(clampN(score, 0, 100));
}

export function luckLabel(index: number): string {
  if (index < 0) {
    return '暂无出金';
  }
  if (index >= 75) {
    return '欧皇';
  }
  if (index >= 55) {
    return '小欧';
  }
  if (index >= 45) {
    return '平稳';
  }
  if (index >= 25) {
    return '小非';
  }
  return '非酋';
}

export function luckDescription(index: number): string {
  if (index < 0) {
    return '还没有出金记录，先去抽一发吧。';
  }
  if (index >= 75) {
    return '出金均抽数远低于期望，出货节奏非常顺。';
  }
  if (index >= 55) {
    return '出金节奏略快于期望，运气在线。';
  }
  if (index >= 45) {
    return '出金节奏与期望基本一致，心态平稳。';
  }
  if (index >= 25) {
    return '出金节奏略慢于期望，属于正常波动。';
  }
  return '出金均抽数远高于期望，非酋本酋，下个保底不远了。';
}

export function pullGoldProb(n: number, cfg: PityConfig): number {
  if (n >= cfg.hardPity) {
    return 1;
  }
  if (n >= cfg.softStart) {
    return BASE_GOLD_RATE + SOFT_RATE_STEP * (n - cfg.softStart + 1);
  }
  return BASE_GOLD_RATE;
}

export function cumulativeGoldProb(n: number, cfg: PityConfig): number {
  let survive = 1;
  for (let i = 1; i <= n; i++) {
    survive = survive * (1 - pullGoldProb(i, cfg));
  }
  return 1 - survive;
}

export function goldHistogram(records: GachaRecord[]): number[] {
  const bins: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  const pulls = goldPullNumbers(records);
  for (const p of pulls) {
    const idx = Math.min(Math.floor((p - 1) / 10), 8);
    bins[idx]++;
  }
  return bins;
}
