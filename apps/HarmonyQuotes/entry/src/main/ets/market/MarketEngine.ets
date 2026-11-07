/**
 * 模拟行情引擎（单例）
 * - 内置 30+ 标的池（股票 SH/SZ、基金 OF、指数 IDX）
 * - 每个标的按 symbol 哈希 + 当日日期做种子，几何布朗运动生成 120 日历史 K 线
 * - 启动时按当前墙钟时间定位分时进度；tick() 推进分钟随机游走
 */

import { Quote, Candle, emptyQuote } from '../model/Quote'
import { mulberry32, gaussian, generateCandles, generateIntraday, hashSeed, fmtDate } from './CandleGenerator'

export interface SymbolInfo {
  symbol: string
  name: string
  type: string
  base: number
  vol: number
}

interface SymbolState {
  symbol: string
  name: string
  type: string
  price: number
  prevClose: number
  open: number
  high: number
  low: number
  volume: number
  minuteData: number[]
  avgData: number[]
  minuteIndex: number
  candles: Candle[]
  mSigma: number
  rand: () => number
  volPerTick: number
}

const HISTORY_DAYS: number = 120
const MINUTES_PER_DAY: number = 240

export const UNIVERSE: SymbolInfo[] = [
  { symbol: 'IDX000001', name: '上证指数', type: 'index', base: 3050, vol: 0.16 },
  { symbol: 'IDX399001', name: '深证成指', type: 'index', base: 9600, vol: 0.20 },
  { symbol: 'IDX399006', name: '创业板指', type: 'index', base: 1850, vol: 0.25 },
  { symbol: 'SH600519', name: '贵州茅台', type: 'stock', base: 1580, vol: 0.24 },
  { symbol: 'SH601318', name: '中国平安', type: 'stock', base: 52, vol: 0.22 },
  { symbol: 'SH600036', name: '招商银行', type: 'stock', base: 36, vol: 0.20 },
  { symbol: 'SH601899', name: '紫金矿业', type: 'stock', base: 15, vol: 0.30 },
  { symbol: 'SH600900', name: '长江电力', type: 'stock', base: 25, vol: 0.15 },
  { symbol: 'SH601012', name: '隆基绿能', type: 'stock', base: 19, vol: 0.38 },
  { symbol: 'SH688981', name: '中芯国际', type: 'stock', base: 48, vol: 0.36 },
  { symbol: 'SH600030', name: '中信证券', type: 'stock', base: 22, vol: 0.28 },
  { symbol: 'SH601398', name: '工商银行', type: 'stock', base: 6, vol: 0.12 },
  { symbol: 'SH600887', name: '伊利股份', type: 'stock', base: 29, vol: 0.20 },
  { symbol: 'SH603288', name: '海天味业', type: 'stock', base: 35, vol: 0.24 },
  { symbol: 'SZ000001', name: '平安银行', type: 'stock', base: 11, vol: 0.24 },
  { symbol: 'SZ000858', name: '五粮液', type: 'stock', base: 128, vol: 0.26 },
  { symbol: 'SZ000333', name: '美的集团', type: 'stock', base: 72, vol: 0.20 },
  { symbol: 'SZ002594', name: '比亚迪', type: 'stock', base: 210, vol: 0.32 },
  { symbol: 'SZ300750', name: '宁德时代', type: 'stock', base: 190, vol: 0.34 },
  { symbol: 'SZ300059', name: '东方财富', type: 'stock', base: 14, vol: 0.34 },
  { symbol: 'SZ002415', name: '海康威视', type: 'stock', base: 30, vol: 0.25 },
  { symbol: 'SZ000651', name: '格力电器', type: 'stock', base: 40, vol: 0.20 },
  { symbol: 'SZ002714', name: '牧原股份', type: 'stock', base: 42, vol: 0.30 },
  { symbol: 'SH600276', name: '恒瑞医药', type: 'stock', base: 45, vol: 0.25 },
  { symbol: 'OF110022', name: '易方达消费行业', type: 'fund', base: 3.2, vol: 0.18 },
  { symbol: 'OF161725', name: '招商中证白酒', type: 'fund', base: 0.9, vol: 0.24 },
  { symbol: 'OF005827', name: '易方达蓝筹精选', type: 'fund', base: 1.9, vol: 0.20 },
  { symbol: 'OF320007', name: '诺安成长混合', type: 'fund', base: 1.4, vol: 0.30 },
  { symbol: 'OF001102', name: '前海开源国家比较优势', type: 'fund', base: 1.1, vol: 0.22 },
  { symbol: 'OF000961', name: '天弘沪深300', type: 'fund', base: 1.5, vol: 0.16 },
  { symbol: 'OF519674', name: '银河创新成长', type: 'fund', base: 6.2, vol: 0.26 },
  { symbol: 'OF000198', name: '天弘余额宝', type: 'fund', base: 1.0, vol: 0.02 }
]

export class MarketEngine {
  private static instance: MarketEngine | null = null
  private states: Map<string, SymbolState> = new Map<string, SymbolState>()
  private inited: boolean = false

  static getInstance(): MarketEngine {
    if (!MarketEngine.instance) {
      MarketEngine.instance = new MarketEngine()
    }
    return MarketEngine.instance
  }

  init(): void {
    if (this.inited) {
      return
    }
    const daySeed: number = Math.floor(Date.now() / 86400000)
    this.states.clear()
    for (const cfg of UNIVERSE) {
      const rand: () => number = mulberry32((hashSeed(cfg.symbol) ^ daySeed) >>> 0)
      const candles: Candle[] = generateCandles(cfg.base, HISTORY_DAYS, cfg.vol, rand)
      const last: Candle = candles[candles.length - 1]
      const prevClose: number = candles.length >= 2 ? candles[candles.length - 2].close : last.open
      const dailySigma: number = cfg.vol / Math.sqrt(240)
      const minuteData: number[] = generateIntraday(last.open, MINUTES_PER_DAY, dailySigma, rand)
      const progress: number = this.sessionProgress()
      let hi: number = Math.max(last.open, minuteData[0])
      let lo: number = Math.min(last.open, minuteData[0])
      for (let i = 0; i < progress; i++) {
        hi = Math.max(hi, minuteData[i])
        lo = Math.min(lo, minuteData[i])
      }
      const price: number = minuteData[progress - 1]
      const st: SymbolState = {
        symbol: cfg.symbol,
        name: cfg.name,
        type: cfg.type,
        price: price,
        prevClose: prevClose,
        open: r2(last.open),
        high: r2(hi),
        low: r2(lo),
        volume: Math.round(last.volume * progress / MINUTES_PER_DAY),
        minuteData: minuteData,
        avgData: this.calcAvg(minuteData, progress),
        minuteIndex: progress - 1,
        candles: candles,
        mSigma: dailySigma,
        rand: rand,
        volPerTick: Math.max(1, Math.round(last.volume / MINUTES_PER_DAY * 0.6))
      }
      this.states.set(cfg.symbol, st)
    }
    this.inited = true
  }

  /**
   * 基于当前时间估算当日已过分钟数（9:30-11:30 / 13:00-15:00），
   * 至少推进 96 分钟保证首屏图表有内容
   */
  private sessionProgress(): number {
    const d = new Date()
    const hm: number = d.getHours() * 60 + d.getMinutes()
    let m: number = 0
    if (hm < 570) {
      m = 0
    } else if (hm < 690) {
      m = hm - 570
    } else if (hm < 780) {
      m = 120
    } else if (hm < 900) {
      m = 120 + (hm - 780)
    } else {
      m = 240
    }
    return Math.max(96, Math.min(MINUTES_PER_DAY, m))
  }

  private calcAvg(minuteData: number[], count: number): number[] {
    const avg: number[] = []
    let sum: number = 0
    for (let i = 0; i < count && i < minuteData.length; i++) {
      sum += minuteData[i]
      avg.push(sum / (i + 1))
    }
    return avg
  }

  /**
   * 推进行情：分钟未走完时沿预生成路径微幅随机游走；已走完后价格小幅抖动
   */
  tick(steps: number = 1): void {
    for (const st of this.states.values()) {
      for (let s = 0; s < steps; s++) {
        if (st.minuteIndex < MINUTES_PER_DAY - 1) {
          st.minuteIndex++
          const base: number = st.minuteData[st.minuteIndex]
          const jittered: number = Math.max(0.01, base * (1 + (st.rand() - 0.5) * st.mSigma))
          st.minuteData[st.minuteIndex] = jittered
          st.price = jittered
        } else {
          st.price = Math.max(0.01, st.price * (1 + (st.rand() - 0.5) * st.mSigma * 2))
          st.minuteData[MINUTES_PER_DAY - 1] = st.price
          st.minuteIndex = MINUTES_PER_DAY - 1
        }
        st.high = Math.max(st.high, st.price)
        st.low = Math.min(st.low, st.price)
        st.volume += Math.round(st.volPerTick * (0.5 + st.rand()))
      }
      st.avgData = this.calcAvg(st.minuteData, st.minuteIndex + 1)
    }
  }

  getQuotes(symbols: string[]): Quote[] {
    const list: Quote[] = []
    for (const sym of symbols) {
      const st = this.states.get(sym)
      if (!st) {
        continue
      }
      const n: number = st.minuteIndex + 1
      list.push({
        symbol: st.symbol,
        name: st.name,
        type: st.type,
        price: r2(st.price),
        prevClose: st.prevClose,
        open: st.open,
        high: st.high,
        low: st.low,
        volume: st.volume,
        minuteData: st.minuteData.slice(0, n),
        avgData: st.avgData.slice(0, n)
      })
    }
    return list
  }

  getQuote(symbol: string): Quote {
    const list: Quote[] = this.getQuotes([symbol])
    return list.length > 0 ? list[0] : emptyQuote()
  }

  getHistory(symbol: string, days: number): Candle[] {
    const st = this.states.get(symbol)
    if (!st) {
      return []
    }
    const all: Candle[] = st.candles
    if (days >= all.length) {
      return all.slice()
    }
    return all.slice(all.length - days)
  }

  getUniverse(): SymbolInfo[] {
    return UNIVERSE.slice()
  }

  getSymbolInfo(symbol: string): SymbolInfo | null {
    for (const cfg of UNIVERSE) {
      if (cfg.symbol === symbol) {
        return cfg
      }
    }
    return null
  }
}

function r2(v: number): number {
  return Math.round(v * 100) / 100
}
