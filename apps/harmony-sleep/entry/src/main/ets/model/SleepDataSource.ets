import { SleepRecord } from './SleepRecord';

export class SleepDataSource implements IDataSource {
  private dataArray: SleepRecord[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.dataArray.length;
  }

  getData(index: number): SleepRecord {
    return this.dataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx !== -1) {
      this.listeners.splice(idx, 1);
    }
  }

  pushData(record: SleepRecord): void {
    this.dataArray.unshift(record);
    this.listeners.forEach(l => {
      l.onDataAdd(0);
    });
  }

  spliceData(index: number, deleteCount: number): void {
    this.dataArray.splice(index, deleteCount);
    this.listeners.forEach(l => {
      l.onDataDelete(index);
    });
  }

  reloadData(newData: SleepRecord[]): void {
    this.dataArray = newData;
    this.listeners.forEach(l => {
      l.onDataReloaded();
    });
  }

  appendData(record: SleepRecord): void {
    const index = this.dataArray.length;
    this.dataArray.push(record);
    this.listeners.forEach(l => {
      l.onDataAdd(index);
    });
  }

  getAll(): SleepRecord[] {
    return this.dataArray;
  }
}
