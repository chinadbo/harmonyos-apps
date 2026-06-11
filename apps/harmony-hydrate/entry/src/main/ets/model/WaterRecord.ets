export class WaterRecord {
  id: number
  amount: number
  timestamp: number
  date: string

  constructor(id: number = 0, amount: number = 0, timestamp: number = Date.now(), date: string = '') {
    this.id = id
    this.amount = amount
    this.timestamp = timestamp
    this.date = date
  }
}
