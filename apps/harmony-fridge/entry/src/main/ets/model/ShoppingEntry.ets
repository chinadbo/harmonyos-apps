export class ShoppingEntry {
  id: number = 0;
  foodItemId: number = 0;
  name: string = '';
  quantityText: string = '1份';
  completed: number = 0;
  createdAt: number = 0;

  constructor(source?: ShoppingEntry) {
    if (!source) {
      return;
    }
    this.id = source.id;
    this.foodItemId = source.foodItemId;
    this.name = source.name;
    this.quantityText = source.quantityText;
    this.completed = source.completed;
    this.createdAt = source.createdAt;
  }

  static create(name: string, quantityText: string, foodItemId: number = 0): ShoppingEntry {
    const entry: ShoppingEntry = new ShoppingEntry();
    entry.name = name;
    entry.quantityText = quantityText;
    entry.foodItemId = foodItemId;
    entry.createdAt = Date.now();
    return entry;
  }
}
