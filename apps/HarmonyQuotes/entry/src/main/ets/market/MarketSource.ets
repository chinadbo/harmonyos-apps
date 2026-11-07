/**
 * 行情源抽象：页面统一面向 IMarketSource 编程，
 * 当前为 MockMarketSource（本地模拟），后续可替换为真实 API 实现
 */

import { Quote, Candle } from '../model/Quote'
import { MarketEngine } from './MarketEngine'

export interface IMarketSource {
  getQuotes(symbols: string[]): Promise<Quote[]>
  getHistory(symbol: string, days: number): Promise<Candle[]>
}

export class MockMarketSource implements IMarketSource {
  getQuotes(symbols: string[]): Promise<Quote[]> {
    return new Promise<Quote[]>((resolve) => {
      const engine: MarketEngine = MarketEngine.getInstance()
      engine.tick(1)
      resolve(engine.getQuotes(symbols))
    })
  }

  getHistory(symbol: string, days: number): Promise<Candle[]> {
    return new Promise<Candle[]>((resolve) => {
      resolve(MarketEngine.getInstance().getHistory(symbol, days))
    })
  }
}

let cachedSource: IMarketSource | null = null

export function getMarketSource(): IMarketSource {
  if (!cachedSource) {
    cachedSource = new MockMarketSource()
  }
  return cachedSource
}
