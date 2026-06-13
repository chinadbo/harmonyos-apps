import { DatabaseHelper } from '../database/DatabaseHelper'
import { DietRecord } from '../model/DietRecord'
import { FoodItem } from '../model/FoodItem'

export class DietDao {
  private databaseHelper: DatabaseHelper = DatabaseHelper.getInstance()

  findAll(): DietRecord[] {
    return this.databaseHelper.getDietRecords().sort((left: DietRecord, right: DietRecord) => right.date.localeCompare(left.date))
  }

  findByDate(date: string): DietRecord | undefined {
    return this.findAll().find((record: DietRecord) => record.date === date)
  }

  save(record: DietRecord): void {
    let records = this.findAll()
    let index = records.findIndex((item: DietRecord) => item.id === record.id)
    if (index >= 0) {
      records[index] = record
    } else {
      records.unshift(record)
    }
    this.databaseHelper.saveDietRecords(records)
  }

  appendFood(date: string, foodItem: FoodItem): DietRecord {
    let records = this.findAll()
    let record = records.find((item: DietRecord) => item.date === date)
    if (!record) {
      record = new DietRecord({
        id: `record-${date}`,
        date: date,
        foodItems: []
      })
      records.unshift(record)
    }
    record.addFood(foodItem)
    this.databaseHelper.saveDietRecords(records)
    return record
  }
}
