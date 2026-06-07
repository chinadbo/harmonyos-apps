export type ShoppingListCategory = '超市' | '菜市场' | '网购' | '其他';

export const SHOPPING_LIST_CATEGORIES: ShoppingListCategory[] = ['超市', '菜市场', '网购', '其他'];

@Observed
export class ShoppingList {
  id: number;
  name: string;
  category: ShoppingListCategory;
  createTime: number;
  isArchived: boolean;

  constructor(
    id: number = 0,
    name: string = '',
    category: ShoppingListCategory = '超市',
    createTime: number = Date.now(),
    isArchived: boolean = false
  ) {
    this.id = id;
    this.name = name;
    this.category = category;
    this.createTime = createTime;
    this.isArchived = isArchived;
  }
}
