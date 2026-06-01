import { ItemCategory } from './Constants'

export class Item {
  id: number = 0
  tripId: number = 0
  templateId: string = ''
  name: string = ''
  category: string = ItemCategory.OTHER
  quantity: number = 1
  importance: number = 1
  note: string = ''
  isPacked: boolean = false
  isMissed: boolean = false
  sortOrder: number = 0
  createdAt: number = Date.now()
  updatedAt: number = Date.now()

  constructor(source?: Partial<Item>) {
    if (source) {
      Object.assign(this, source)
    }
  }
}

export interface CategoryItemGroup {
  category: string
  items: Item[]
}

export function createItemRow(item: Item): Record<string, number | string> {
  return {
    id: item.id,
    trip_id: item.tripId,
    template_id: item.templateId,
    name: item.name,
    category: item.category,
    quantity: item.quantity,
    importance: item.importance,
    note: item.note,
    is_packed: item.isPacked ? 1 : 0,
    is_missed: item.isMissed ? 1 : 0,
    sort_order: item.sortOrder,
    created_at: item.createdAt,
    updated_at: item.updatedAt
  }
}
