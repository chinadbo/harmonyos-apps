/**
 * RDB 封装（单例）：watchlist / positions / nav_history 三表
 * 初始化失败时自动降级为内存模式，保证不崩溃
 */

import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import { WatchItem } from '../model/WatchItem'
import { Position } from '../model/Position'
import { NavPoint } from '../model/Quote'

const DB_NAME: string = 'harmony_quotes.db'

const SQL_CREATE_WATCHLIST: string = `CREATE TABLE IF NOT EXISTS watchlist (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  symbol TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  sort INTEGER DEFAULT 0,
  alert_high REAL,
  alert_low REAL,
  added_at INTEGER
)`

const SQL_CREATE_POSITIONS: string = `CREATE TABLE IF NOT EXISTS positions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  symbol TEXT NOT NULL UNIQUE,
  name TEXT,
  type TEXT,
  cost REAL NOT NULL,
  shares REAL NOT NULL,
  created_at INTEGER
)`

const SQL_CREATE_NAV: string = `CREATE TABLE IF NOT EXISTS nav_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  symbol TEXT NOT NULL,
  date TEXT NOT NULL,
  close REAL NOT NULL,
  UNIQUE(symbol, date)
)`

interface MemNav {
  symbol: string
  date: string
  close: number
}

export class QuoteDB {
  private static instance: QuoteDB | null = null
  private store: relationalStore.RdbStore | null = null
  private memoryMode: boolean = false
  private memWatch: WatchItem[] = []
  private memPos: Position[] = []
  private memNav: MemNav[] = []
  private nextId: number = 1

  static getInstance(): QuoteDB {
    if (!QuoteDB.instance) {
      QuoteDB.instance = new QuoteDB()
    }
    return QuoteDB.instance
  }

  isMemoryMode(): boolean {
    return this.memoryMode
  }

  async init(context: common.Context): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      }
      this.store = await relationalStore.getRdbStore(context, config)
      await this.store.executeSql(SQL_CREATE_WATCHLIST)
      await this.store.executeSql(SQL_CREATE_POSITIONS)
      await this.store.executeSql(SQL_CREATE_NAV)
      this.memoryMode = false
    } catch (e) {
      this.store = null
      this.memoryMode = true
    }
  }

  // ---------------- watchlist ----------------

  async getWatchlist(): Promise<WatchItem[]> {
    if (this.memoryMode || !this.store) {
      return this.memWatch.slice()
    }
    try {
      const rs = await this.store.querySql(
        'SELECT id, symbol, name, type, sort, alert_high, alert_low, added_at FROM watchlist ORDER BY sort, id')
      const list: WatchItem[] = []
      while (rs.goToNextRow()) {
        list.push({
          id: rs.getLong(rs.getColumnIndex('id')),
          symbol: rs.getString(rs.getColumnIndex('symbol')),
          name: rs.getString(rs.getColumnIndex('name')),
          type: rs.getString(rs.getColumnIndex('type')),
          sort: rs.getLong(rs.getColumnIndex('sort')),
          alertHigh: rs.getDouble(rs.getColumnIndex('alert_high')),
          alertLow: rs.getDouble(rs.getColumnIndex('alert_low')),
          addedAt: rs.getLong(rs.getColumnIndex('added_at'))
        })
      }
      rs.close()
      return list
    } catch (e) {
      return this.memWatch.slice()
    }
  }

  async addWatch(symbol: string, name: string, type: string, sort: number = 0): Promise<void> {
    if (this.memoryMode || !this.store) {
      if (this.findBySymbol(this.memWatch, symbol) === null) {
        this.memWatch.push({
          id: this.nextId++, symbol: symbol, name: name, type: type,
          sort: sort, alertHigh: 0, alertLow: 0, addedAt: Date.now()
        })
      }
      return
    }
    try {
      await this.store.executeSql(
        'INSERT OR IGNORE INTO watchlist (symbol, name, type, sort, alert_high, alert_low, added_at) VALUES (?, ?, ?, ?, 0, 0, ?)',
        [symbol, name, type, sort, Date.now()])
    } catch (e) {
    }
  }

  async removeWatch(symbol: string): Promise<void> {
    if (this.memoryMode || !this.store) {
      this.memWatch = this.memWatch.filter((w: WatchItem) => w.symbol !== symbol)
      return
    }
    try {
      await this.store.executeSql('DELETE FROM watchlist WHERE symbol = ?', [symbol])
    } catch (e) {
    }
  }

  async setAlert(symbol: string, alertHigh: number, alertLow: number): Promise<void> {
    if (this.memoryMode || !this.store) {
      const item = this.findBySymbol(this.memWatch, symbol)
      if (item !== null) {
        item.alertHigh = alertHigh
        item.alertLow = alertLow
      }
      return
    }
    try {
      await this.store.executeSql(
        'UPDATE watchlist SET alert_high = ?, alert_low = ? WHERE symbol = ?',
        [alertHigh, alertLow, symbol])
    } catch (e) {
    }
  }

  // ---------------- positions ----------------

  async getPositions(): Promise<Position[]> {
    if (this.memoryMode || !this.store) {
      return this.memPos.slice()
    }
    try {
      const rs = await this.store.querySql(
        'SELECT id, symbol, name, type, cost, shares, created_at FROM positions ORDER BY id')
      const list: Position[] = []
      while (rs.goToNextRow()) {
        list.push({
          id: rs.getLong(rs.getColumnIndex('id')),
          symbol: rs.getString(rs.getColumnIndex('symbol')),
          name: rs.getString(rs.getColumnIndex('name')),
          type: rs.getString(rs.getColumnIndex('type')),
          cost: rs.getDouble(rs.getColumnIndex('cost')),
          shares: rs.getDouble(rs.getColumnIndex('shares')),
          createdAt: rs.getLong(rs.getColumnIndex('created_at'))
        })
      }
      rs.close()
      return list
    } catch (e) {
      return this.memPos.slice()
    }
  }

  async addPosition(symbol: string, name: string, type: string, cost: number, shares: number): Promise<void> {
    if (this.memoryMode || !this.store) {
      if (this.findBySymbol(this.memPos, symbol) === null) {
        this.memPos.push({
          id: this.nextId++, symbol: symbol, name: name, type: type,
          cost: cost, shares: shares, createdAt: Date.now()
        })
      }
      return
    }
    try {
      await this.store.executeSql(
        'INSERT OR IGNORE INTO positions (symbol, name, type, cost, shares, created_at) VALUES (?, ?, ?, ?, ?, ?)',
        [symbol, name, type, cost, shares, Date.now()])
    } catch (e) {
    }
  }

  async updatePosition(id: number, cost: number, shares: number): Promise<void> {
    if (this.memoryMode || !this.store) {
      for (const p of this.memPos) {
        if (p.id === id) {
          p.cost = cost
          p.shares = shares
        }
      }
      return
    }
    try {
      await this.store.executeSql('UPDATE positions SET cost = ?, shares = ? WHERE id = ?', [cost, shares, id])
    } catch (e) {
    }
  }

  async deletePosition(id: number): Promise<void> {
    if (this.memoryMode || !this.store) {
      this.memPos = this.memPos.filter((p: Position) => p.id !== id)
      return
    }
    try {
      await this.store.executeSql('DELETE FROM positions WHERE id = ?', [id])
    } catch (e) {
    }
  }

  // ---------------- nav_history ----------------

  async getNavHistory(symbol: string, limit: number): Promise<NavPoint[]> {
    if (this.memoryMode || !this.store) {
      const matched = this.memNav.filter((n: MemNav) => n.symbol === symbol)
      const points: NavPoint[] = matched.map((n: MemNav) => ({ date: n.date, close: n.close }))
      return points.length > limit ? points.slice(points.length - limit) : points
    }
    try {
      const rs = await this.store.querySql(
        'SELECT date, close FROM nav_history WHERE symbol = ? ORDER BY date DESC LIMIT ?', [symbol, limit])
      const list: NavPoint[] = []
      while (rs.goToNextRow()) {
        list.push({
          date: rs.getString(rs.getColumnIndex('date')),
          close: rs.getDouble(rs.getColumnIndex('close'))
        })
      }
      rs.close()
      list.reverse()
      return list
    } catch (e) {
      return []
    }
  }

  async addNav(symbol: string, date: string, close: number): Promise<void> {
    if (this.memoryMode || !this.store) {
      let found: boolean = false
      for (const n of this.memNav) {
        if (n.symbol === symbol && n.date === date) {
          n.close = close
          found = true
        }
      }
      if (!found) {
        this.memNav.push({ symbol: symbol, date: date, close: close })
      }
      return
    }
    try {
      await this.store.executeSql(
        'INSERT OR REPLACE INTO nav_history (symbol, date, close) VALUES (?, ?, ?)', [symbol, date, close])
    } catch (e) {
    }
  }

  // ---------------- clear ----------------

  async clearAll(): Promise<void> {
    this.memWatch = []
    this.memPos = []
    this.memNav = []
    if (this.memoryMode || !this.store) {
      return
    }
    try {
      await this.store.executeSql('DELETE FROM watchlist')
      await this.store.executeSql('DELETE FROM positions')
      await this.store.executeSql('DELETE FROM nav_history')
    } catch (e) {
    }
  }

  private findBySymbol<T extends object>(list: T[], symbol: string): T | null {
    for (const item of list) {
      const sym = (item as Record<string, Object>)['symbol']
      if (typeof sym === 'string' && sym === symbol) {
        return item
      }
    }
    return null
  }
}
