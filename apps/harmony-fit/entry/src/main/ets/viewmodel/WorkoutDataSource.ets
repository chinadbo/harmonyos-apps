import { WorkoutRecord } from '../model/WorkoutRecord'

export class WorkoutDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []
  private data: WorkoutRecord[] = []

  totalCount(): number {
    return this.data.length
  }

  getData(index: number): WorkoutRecord {
    return this.data[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener)
    if (index !== -1) {
      this.listeners.splice(index, 1)
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded()
    })
  }

  setData(records: WorkoutRecord[]): void {
    this.data = records
    this.notifyDataReload()
  }

  addRecord(record: WorkoutRecord): void {
    this.data.unshift(record)
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(0)
    })
  }

  removeRecord(index: number): void {
    if (index < 0 || index >= this.data.length) {
      return
    }
    this.data.splice(index, 1)
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataDelete(index)
    })
  }

  getAllData(): WorkoutRecord[] {
    return this.data
  }
}
