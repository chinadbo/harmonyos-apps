import { Constants } from '../common/Constants';
import { DateUtils } from '../common/DateUtils';

export class CategoryStat {
  category: string = '';
  count: number = 0;

  constructor(category: string = '', count: number = 0) {
    this.category = category;
    this.count = count;
  }
}

export class FoodItem {
  id: number = 0;
  name: string = '';
  quantity: number = 1;
  unit: string = Constants.DEFAULT_UNITS[0];
  category: string = Constants.CATEGORIES[0];
  expiryDate: string = DateUtils.todayText();
  storageArea: string = Constants.STORAGE_AREAS[0];
  note: string = '';
  createdAt: number = 0;
  updatedAt: number = 0;

  constructor(source?: FoodItem) {
    if (!source) {
      return;
    }
    this.id = source.id;
    this.name = source.name;
    this.quantity = source.quantity;
    this.unit = source.unit;
    this.category = source.category;
    this.expiryDate = source.expiryDate;
    this.storageArea = source.storageArea;
    this.note = source.note;
    this.createdAt = source.createdAt;
    this.updatedAt = source.updatedAt;
  }

  static createEmpty(): FoodItem {
    const item: FoodItem = new FoodItem();
    item.createdAt = Date.now();
    item.updatedAt = Date.now();
    return item;
  }
}
