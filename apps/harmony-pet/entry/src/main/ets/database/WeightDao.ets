import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import { DatabaseHelper } from './DatabaseHelper'
import type { WeightRecord } from '../model/WeightRecord'
import { DateUtils } from '../common/DateUtils'

export class WeightDao {
  constructor(private context: common.UIAbilityContext) {
  }

  private async getStore(): Promise<relationalStore.RdbStore> {
    return DatabaseHelper.getInstance().getStore(this.context)
  }

  async insert(item: Omit<WeightRecord, 'id'>): Promise<number> {
    const store = await this.getStore()
    return store.insert('weight_records', {
      pet_id: item.petId,
      weight: item.weight,
      record_date: item.recordDate,
      note: item.note,
      created_at: item.createdAt
    })
  }

  async queryByPetId(petId: number): Promise<WeightRecord[]> {
    const store = await this.getStore()
    const result = await store.querySql(
      'SELECT * FROM weight_records WHERE pet_id = ? ORDER BY record_date DESC, created_at DESC LIMIT 30',
      [petId]
    )
    const items: WeightRecord[] = []
    while (result.goToNextRow()) {
      items.push(this.readRecord(result))
    }
    result.close()
    return items
  }

  async queryTodayCount(petId: number): Promise<number> {
    const store = await this.getStore()
    const result = await store.querySql(
      'SELECT COUNT(1) AS total FROM weight_records WHERE pet_id = ? AND record_date = ?',
      [petId, DateUtils.today()]
    )
    const count: number = result.goToFirstRow() ? result.getLong(result.getColumnIndex('total')) : 0
    result.close()
    return count
  }

  private readRecord(result: relationalStore.ResultSet): WeightRecord {
    return {
      id: result.getLong(result.getColumnIndex('id')),
      petId: result.getLong(result.getColumnIndex('pet_id')),
      weight: result.getDouble(result.getColumnIndex('weight')),
      recordDate: result.getString(result.getColumnIndex('record_date')),
      note: result.getString(result.getColumnIndex('note')),
      createdAt: result.getLong(result.getColumnIndex('created_at'))
    }
  }
}
