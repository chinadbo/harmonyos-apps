/**
 * 随机数与 K 线/分时序列生成器
 * - mulberry32：确定性伪随机（同 seed 同序列）
 * - gaussian：Box-Muller 正态分布
 * - 几何布朗运动生成日线与分钟级价格路径
 */

import { Candle } from '../model/Quote'

export function hashSeed(s: string): number {
  let h: number = 2166136261
  for (let i = 0; i < s.length; i++) {
    h = (((h ^ s.charCodeAt(i)) * 16777619) >>> 0)
  }
  return h >>> 0
}

export function mulberry32(seed: number): () => number {
  let a: number = seed >>> 0
  return (): number => {
    a = (a + 0x6D2B79F5) >>> 0
    let t: number = a
    t = Math.imul(t ^ (t >>> 15), t | 1)
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61)
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

export function gaussian(rand: () => number): number {
  let u: number = rand()
  const v: number = rand()
  if (u < 1e-9) {
    u = 1e-9
  }
  return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * v)
}

export function fmtDate(ts: number): string {
  const d = new Date(ts)
  const m = d.getMonth() + 1
  const day = d.getDate()
  const mm = m < 10 ? '0' + m : m
  const dd = day < 10 ? '0' + day : day
  return `${d.getFullYear()}-${mm}-${dd}`
}

function r2(v: number): number {
  return Math.round(v * 100) / 100
}

/**
 * 生成 days 根日 K 线（几何布朗运动，无年化漂移、含日内高波动幅度）
 */
export function generateCandles(basePrice: number, days: number, annualVol: number, rand: () => number): Candle[] {
  const sigma: number = annualVol / Math.sqrt(240)
  const result: Candle[] = []
  const now: number = Date.now()
  let close: number = basePrice
  for (let i = days - 1; i >= 0; i--) {
    const ts: number = now - i * 86400000
    const prevClose: number = close
    const z: number = gaussian(rand)
    close = prevClose * Math.exp(sigma * z)
    const gap: number = gaussian(rand) * sigma * 0.4
    const open: number = Math.max(0.01, prevClose + gap * prevClose)
    const hi: number = Math.max(open, close) * (1 + Math.abs(gaussian(rand)) * sigma * 0.5)
    const lo: number = Math.min(open, close) * (1 - Math.abs(gaussian(rand)) * sigma * 0.5)
    const volume: number = Math.round((0.5 + rand()) * 120000 * Math.sqrt(Math.max(basePrice, 5)))
    result.push({
      date: fmtDate(ts),
      open: r2(open),
      high: r2(hi),
      low: r2(lo),
      close: r2(close),
      volume: volume
    })
  }
  return result
}

/**
 * 生成 240 分钟分时路径：日内整体漂移 + 分钟级随机游走
 */
export function generateIntraday(open: number, minutes: number, dailySigma: number, rand: () => number): number[] {
  const mSigma: number = dailySigma / Math.sqrt(240)
  const drift: number = gaussian(rand) * mSigma * 8
  const path: number[] = [open]
  let p: number = open
  for (let i = 1; i < minutes; i++) {
    p = p * (1 + drift / minutes + gaussian(rand) * mSigma)
    p = Math.max(0.01, p)
    path.push(p)
  }
  return path
}

/**
 * 生成一段演示用净值/资产曲线，终点精确锚定 target 值（先随机游走再整体缩放）
 */
export function generateCurveTo(target: number, days: number, rand: () => number): number[] {
  const raw: number[] = [1]
  let v: number = 1
  for (let i = 1; i < days; i++) {
    v = v * (1 + gaussian(rand) * 0.012)
    raw.push(v)
  }
  const scale: number = target / raw[raw.length - 1]
  return raw.map((x: number) => x * scale)
}
