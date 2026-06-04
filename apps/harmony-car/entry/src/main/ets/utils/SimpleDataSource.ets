export class SimpleDataSource<T> implements IDataSource {
  private items: T[] = [];
  private listeners: DataChangeListener[] = [];

  constructor(items: T[] = []) {
    this.items = [...items];
  }

  totalCount(): number {
    return this.items.length;
  }

  getData(index: number): T {
    return this.items[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    this.listeners = this.listeners.filter((item: DataChangeListener) => item !== listener);
  }

  reload(items: T[]): void {
    this.items = [...items];
    this.listeners.forEach((listener: DataChangeListener) => {
      if (listener.onDataReloaded) {
        listener.onDataReloaded();
      }
    });
  }

  append(item: T): void {
    this.items.push(item);
    this.listeners.forEach((listener: DataChangeListener) => {
      if (listener.onDataAdd) {
        listener.onDataAdd(this.items.length - 1);
      }
    });
  }

  remove(index: number): void {
    if (index < 0 || index >= this.items.length) {
      return;
    }
    this.items.splice(index, 1);
    this.listeners.forEach((listener: DataChangeListener) => {
      if (listener.onDataDelete) {
        listener.onDataDelete(index);
      }
    });
  }
}
