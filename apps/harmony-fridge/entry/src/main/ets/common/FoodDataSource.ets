import { FoodItem } from '../model/FoodItem';

export class FoodDataSource implements IDataSource {
  private items: FoodItem[] = [];
  private listeners: DataChangeListener[] = [];

  constructor(initialItems: FoodItem[] = []) {
    this.items = initialItems;
  }

  totalCount(): number {
    return this.items.length;
  }

  getData(index: number): FoodItem {
    return this.items[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index: number = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index);
    });
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataDelete(index);
    });
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataChange(index);
    });
  }

  setData(items: FoodItem[]): void {
    this.items = items;
    this.notifyDataReload();
  }

  getItems(): FoodItem[] {
    return this.items;
  }
}
