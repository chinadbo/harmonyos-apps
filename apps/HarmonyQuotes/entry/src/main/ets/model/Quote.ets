/**
 * 行情数据模型：Quote / Candle / NavPoint 及派生计算
 */

export interface Quote {
  symbol: string        // SH600519 / OF110022 / IDX000001
  name: string
  type: string          // stock | fund | index
  price: number         // 现价
  prevClose: number     // 昨收
  open: number
  high: number
  low: number
  volume: number        // 当日累计成交量（股/份）
  minuteData: number[]  // 分时价格序列（随时间增长）
  avgData: number[]     // 分时均价序列
}

export interface Candle {
  date: string          // yyyy-MM-dd
  open: number
  high: number
  low: number
  close: number
  volume: number
}

export interface NavPoint {
  date: string
  close: number
}

export const TYPE_STOCK: string = 'stock'
export const TYPE_FUND: string = 'fund'
export const TYPE_INDEX: string = 'index'

export const TYPE_LABELS: Record<string, string> = {
  'stock': '股票',
  'fund': '基金',
  'index': '指数'
}

export function emptyQuote(): Quote {
  return {
    symbol: '',
    name: '--',
    type: 'stock',
    price: 0,
    prevClose: 0,
    open: 0,
    high: 0,
    low: 0,
    volume: 0,
    minuteData: [],
    avgData: []
  }
}

export function quoteChange(q: Quote): number {
  return q.price - q.prevClose
}

export function quoteChangePercent(q: Quote): number {
  if (q.prevClose <= 0) {
    return 0
  }
  return (q.price - q.prevClose) / q.prevClose * 100
}

export function quoteAmplitude(q: Quote): number {
  if (q.prevClose <= 0) {
    return 0
  }
  return (q.high - q.low) / q.prevClose * 100
}

export function quoteDirection(q: Quote): number {
  if (q.price > q.prevClose) {
    return 1
  }
  if (q.price < q.prevClose) {
    return -1
  }
  return 0
}
