/**
 * 持仓（positions 表）模型及盈亏计算
 */

export interface Position {
  id: number
  symbol: string
  name: string
  type: string
  cost: number      // 成本单价
  shares: number    // 持仓数量
  createdAt: number
}

export function newPosition(symbol: string, name: string, type: string, cost: number, shares: number): Position {
  return {
    id: 0,
    symbol: symbol,
    name: name,
    type: type,
    cost: cost,
    shares: shares,
    createdAt: Date.now()
  }
}

export function posMarketValue(p: Position, price: number): number {
  return price * p.shares
}

export function posCostValue(p: Position): number {
  return p.cost * p.shares
}

export function posPnl(p: Position, price: number): number {
  return (price - p.cost) * p.shares
}

export function posRoi(p: Position, price: number): number {
  if (p.cost <= 0) {
    return 0
  }
  return (price - p.cost) / p.cost * 100
}

export function posDayPnl(p: Position, price: number, prevClose: number): number {
  return (price - prevClose) * p.shares
}
