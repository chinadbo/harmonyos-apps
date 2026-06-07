@Observed
export class ShoppingItem {
  id: number;
  listId: number;
  name: string;
  quantity: number;
  unit: string;
  category: string;
  isCompleted: boolean;
  createTime: number;
  note: string;

  constructor(
    id: number = 0,
    listId: number = 0,
    name: string = '',
    quantity: number = 1,
    unit: string = '个',
    category: string = '其他',
    isCompleted: boolean = false,
    createTime: number = Date.now(),
    note: string = ''
  ) {
    this.id = id;
    this.listId = listId;
    this.name = name;
    this.quantity = quantity;
    this.unit = unit;
    this.category = category;
    this.isCompleted = isCompleted;
    this.createTime = createTime;
    this.note = note;
  }
}

export const ITEM_UNITS: string[] = ['个', '斤', '千克', '袋', '盒', '瓶', '包'];
