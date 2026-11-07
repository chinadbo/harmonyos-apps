/**
 * 首次启动演示数据：8 个自选 + 3 个指数 + 2 条持仓 + 30 日总资产净值曲线
 */

import { QuoteDB } from './QuoteDB'
import { MarketEngine } from '../market/MarketEngine'
import { generateCurveTo, mulberry32, hashSeed, fmtDate } from '../market/CandleGenerator'
import { Fmt } from '../common/Fmt'

const DEMO_WATCH: string[] = [
  'SH600519', // 贵州茅台
  'SH601318', // 中国平安
  'SH600036', // 招商银行
  'SZ300750', // 宁德时代
  'SZ002594', // 比亚迪
  'SZ000858', // 五粮液
  'OF110022', // 易方达消费行业
  'OF161725'  // 招商中证白酒
]

const DEMO_INDEX: string[] = ['IDX000001', 'IDX399001', 'IDX399006']

const NAV_DAYS: number = 30
const TOTAL_SYMBOL: string = '__TOTAL__'

interface DemoPositionSeed {
  symbol: string
  cost: number
  shares: number
}

const DEMO_POSITIONS: DemoPositionSeed[] = [
  { symbol: 'SH600519', cost: 1650, shares: 100 },
  { symbol: 'SZ300750', cost: 210, shares: 200 }
]

export async function seedDemoData(): Promise<void> {
  const db: QuoteDB = QuoteDB.getInstance()
  const engine: MarketEngine = MarketEngine.getInstance()

  let sort: number = 0
  for (const symbol of DEMO_INDEX) {
    const info = engine.getSymbolInfo(symbol)
    if (info) {
      await db.addWatch(info.symbol, info.name, info.type, sort++)
    }
  }
  for (const symbol of DEMO_WATCH) {
    const info = engine.getSymbolInfo(symbol)
    if (info) {
      await db.addWatch(info.symbol, info.name, info.type, sort++)
    }
  }

  for (const seed of DEMO_POSITIONS) {
    const info = engine.getSymbolInfo(seed.symbol)
    if (info) {
      await db.addPosition(info.symbol, info.name, info.type, seed.cost, seed.shares)
    }
  }

  // 生成 30 日总资产曲线，终点锚定当前持仓总市值
  let total: number = 0
  for (const seed of DEMO_POSITIONS) {
    const q = engine.getQuote(seed.symbol)
    total += q.price * seed.shares
  }
  if (total <= 0) {
    total = 300000
  }
  const rand: () => number = mulberry32((hashSeed(TOTAL_SYMBOL) ^ Math.floor(Date.now() / 86400000)) >>> 0)
  const curve: number[] = generateCurveTo(total, NAV_DAYS, rand)
  const today: number = Date.now()
  for (let i = 0; i < curve.length; i++) {
    const ts: number = today - (curve.length - 1 - i) * 86400000
    await db.addNav(TOTAL_SYMBOL, fmtDate(ts), Math.round(curve[i] * 100) / 100)
  }
}

export const DEMO_TOTAL_SYMBOL: string = TOTAL_SYMBOL

export function todayNavKey(): string {
  return Fmt.today()
}
