import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import { DatabaseHelper } from './DatabaseHelper'
import type { FeedLog } from '../model/FeedLog'
import { DateUtils } from '../common/DateUtils'

export class FeedDao {
  constructor(private context: common.UIAbilityContext) {
  }

  private async getStore(): Promise<relationalStore.RdbStore> {
    return DatabaseHelper.getInstance().getStore(this.context)
  }

  async insert(item: Omit<FeedLog, 'id'>): Promise<number> {
    const store = await this.getStore()
    return store.insert('feed_logs', {
      pet_id: item.petId,
      food_type: item.foodType,
      amount: item.amount,
      unit: item.unit,
      feed_time: item.feedTime,
      note: item.note,
      created_at: item.createdAt
    })
  }

  async queryByPetId(petId: number): Promise<FeedLog[]> {
    const store = await this.getStore()
    const result = await store.querySql(
      'SELECT * FROM feed_logs WHERE pet_id = ? ORDER BY feed_time DESC, created_at DESC',
      [petId]
    )
    const items: FeedLog[] = []
    while (result.goToNextRow()) {
      items.push(this.readLog(result))
    }
    result.close()
    return items
  }

  async queryTodayCount(petId: number): Promise<number> {
    const store = await this.getStore()
    const result = await store.querySql(
      'SELECT COUNT(1) AS total FROM feed_logs WHERE pet_id = ? AND substr(feed_time, 1, 10) = ?',
      [petId, DateUtils.today()]
    )
    const total: number = result.goToFirstRow() ? result.getLong(result.getColumnIndex('total')) : 0
    result.close()
    return total
  }

  async queryTodayAmount(petId: number): Promise<number> {
    const store = await this.getStore()
    const result = await store.querySql(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM feed_logs WHERE pet_id = ? AND substr(feed_time, 1, 10) = ?',
      [petId, DateUtils.today()]
    )
    const total: number = result.goToFirstRow() ? result.getDouble(result.getColumnIndex('total')) : 0
    result.close()
    return total
  }

  private readLog(result: relationalStore.ResultSet): FeedLog {
    return {
      id: result.getLong(result.getColumnIndex('id')),
      petId: result.getLong(result.getColumnIndex('pet_id')),
      foodType: result.getString(result.getColumnIndex('food_type')),
      amount: result.getDouble(result.getColumnIndex('amount')),
      unit: result.getString(result.getColumnIndex('unit')),
      feedTime: result.getString(result.getColumnIndex('feed_time')),
      note: result.getString(result.getColumnIndex('note')),
      createdAt: result.getLong(result.getColumnIndex('created_at'))
    }
  }
}
