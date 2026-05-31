export class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = []
  private data: T[] = []

  constructor(initialData: T[] = []) {
    this.data = initialData
  }

  totalCount(): number {
    return this.data.length
  }

  getData(index: number): T {
    return this.data[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener)
    if (index >= 0) {
      this.listeners.splice(index, 1)
    }
  }

  reload(items: T[]): void {
    this.data = items
    this.notifyDataReload()
  }

  append(item: T): void {
    this.data.push(item)
    this.notifyDataAdd(this.data.length - 1)
  }

  removeAt(index: number): void {
    if (index < 0 || index >= this.data.length) {
      return
    }
    this.data.splice(index, 1)
    this.notifyDataDelete(index)
  }

  clear(): void {
    this.data = []
    this.notifyDataReload()
  }

  items(): T[] {
    return [...this.data]
  }

  private notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded()
    })
  }

  private notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index)
    })
  }

  private notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataDelete(index)
    })
  }
}
