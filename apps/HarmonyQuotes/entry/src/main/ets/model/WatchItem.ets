/**
 * 自选（watchlist 表）模型
 */

export interface WatchItem {
  id: number
  symbol: string
  name: string
  type: string
  sort: number
  alertHigh: number   // 0 表示未设置
  alertLow: number    // 0 表示未设置
  addedAt: number
}

export function newWatchItem(symbol: string, name: string, type: string, sort: number): WatchItem {
  return {
    id: 0,
    symbol: symbol,
    name: name,
    type: type,
    sort: sort,
    alertHigh: 0,
    alertLow: 0,
    addedAt: Date.now()
  }
}
