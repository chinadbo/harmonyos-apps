import { Clothing } from '../model/WardrobeModels'

export class ClothingDataSource implements IDataSource {
  private items: Clothing[] = []
  private listeners: DataChangeListener[] = []

  totalCount(): number {
    return this.items.length
  }

  getData(index: number): Clothing {
    return this.items[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  notifyReload(items: Clothing[]): void {
    this.items = items
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded()
    })
  }

  add(item: Clothing): void {
    this.items.push(item)
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(this.items.length - 1)
    })
  }
}
