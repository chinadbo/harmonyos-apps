import { Course } from './CourseModel';

export interface DataChangeListener {
  onDataReloaded(): void;
  onDataAdd(index: number): void;
  onDataChange(index: number): void;
  onDataDelete(index: number): void;
  onDataMove(from: number, to: number): void;
}

export interface IDataSource {
  totalCount(): number;
  getData(index: number): Course | undefined;
  registerDataChangeListener(listener: DataChangeListener): void;
  unregisterDataChangeListener(listener: DataChangeListener): void;
}

export class BasicDataSource implements IDataSource {
  protected listeners: DataChangeListener[] = [];
  protected items: Course[] = [];

  totalCount(): number {
    return this.items.length;
  }

  getData(index: number): Course | undefined {
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

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataReloaded());
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataAdd(index));
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataChange(index));
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataDelete(index));
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataMove(from, to));
  }
}

export class CourseDataSource extends BasicDataSource {
  setItems(items: Course[]): void {
    this.items = items.slice();
    this.notifyDataReload();
  }

  getItems(): Course[] {
    return this.items.slice();
  }
}
