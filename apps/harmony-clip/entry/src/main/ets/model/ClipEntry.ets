export enum ClipType {
  TEXT = 'text',
  URL = 'url',
  EMAIL = 'email',
  PHONE = 'phone',
  JSON = 'json',
}

export interface ClipEntry {
  id: number;
  content: string;
  type: ClipType;
  isPrivate: boolean;
  isFavorite: boolean;
  createTime: number;
  previewText: string;
}

export interface DataChangeListener {
  onDataReloaded(): void;
  onDataAdded(index: number): void;
  onDataMoved(from: number, to: number): void;
  onDataDeleted(index: number): void;
  onDataChanged(index: number): void;
}

export class ClipDataSource implements IDataSource {
  private dataList: ClipEntry[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.dataList.length;
  }

  getData(index: number): ClipEntry {
    return this.dataList[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx >= 0) {
      this.listeners.splice(idx, 1);
    }
  }

  setData(list: ClipEntry[]): void {
    this.dataList = list;
    this.notifyReload();
  }

  addItem(item: ClipEntry): void {
    this.dataList.unshift(item);
    this.notifyAdded(0);
  }

  deleteItem(index: number): void {
    this.dataList.splice(index, 1);
    this.notifyDeleted(index);
  }

  updateItem(index: number, item: ClipEntry): void {
    this.dataList[index] = item;
    this.notifyChanged(index);
  }

  getAll(): ClipEntry[] {
    return this.dataList;
  }

  private notifyReload(): void {
    this.listeners.forEach(l => l.onDataReloaded());
  }

  private notifyAdded(index: number): void {
    this.listeners.forEach(l => l.onDataAdded(index));
  }

  private notifyDeleted(index: number): void {
    this.listeners.forEach(l => l.onDataDeleted(index));
  }

  private notifyChanged(index: number): void {
    this.listeners.forEach(l => l.onDataChanged(index));
  }
}
