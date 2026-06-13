import { DatabaseHelper } from '../database/DatabaseHelper'
import { FoodItem } from '../model/FoodItem'

export class FoodDao {
  private databaseHelper: DatabaseHelper = DatabaseHelper.getInstance()

  findAll(): FoodItem[] {
    return this.databaseHelper.getFoodLibrary()
  }

  findByKeyword(keyword: string): FoodItem[] {
    let normalized = keyword.trim().toLowerCase()
    if (normalized.length === 0) {
      return this.findAll()
    }
    return this.findAll().filter((item: FoodItem) => {
      return item.name.toLowerCase().includes(normalized) || item.category.toLowerCase().includes(normalized)
    })
  }

  findById(id: string): FoodItem | undefined {
    return this.findAll().find((item: FoodItem) => item.id === id)
  }

  save(foodItem: FoodItem): void {
    let items = this.findAll()
    let index = items.findIndex((item: FoodItem) => item.id === foodItem.id)
    if (index >= 0) {
      items[index] = foodItem
    } else {
      items.unshift(foodItem)
    }
    this.databaseHelper.saveFoodLibrary(items)
  }
}
