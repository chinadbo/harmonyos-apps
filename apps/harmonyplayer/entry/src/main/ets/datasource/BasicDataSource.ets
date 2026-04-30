/**
 * BasicDataSource — IDataSource 基类实现
 * 供 LazyForEach 使用的通用数据源基类
 */
export class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return 0;
  }

  getData(index: number): Object {
    return null as unknown as Object;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => listener.onDataReloaded());
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => listener.onDataAdded(index));
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => listener.onDataChanged(index));
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => listener.onDataDeleted(index));
  }
}
