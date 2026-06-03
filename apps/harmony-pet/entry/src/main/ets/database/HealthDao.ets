import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import { DatabaseHelper } from './DatabaseHelper'
import type { HealthEvent } from '../model/HealthEvent'
import { DateUtils } from '../common/DateUtils'

export class HealthDao {
  constructor(private context: common.UIAbilityContext) {
  }

  private async getStore(): Promise<relationalStore.RdbStore> {
    return DatabaseHelper.getInstance().getStore(this.context)
  }

  async insert(item: Omit<HealthEvent, 'id'>): Promise<number> {
    const store = await this.getStore()
    return store.insert('health_events', {
      pet_id: item.petId,
      event_type: item.eventType,
      title: item.title,
      event_date: item.eventDate,
      next_date: item.nextDate,
      hospital: item.hospital,
      note: item.note,
      reminder_id: item.reminderId,
      created_at: item.createdAt
    })
  }

  async update(item: HealthEvent): Promise<number> {
    const store = await this.getStore()
    await store.executeSql(
      'UPDATE health_events SET event_type = ?, title = ?, event_date = ?, next_date = ?, hospital = ?, note = ?, reminder_id = ? WHERE id = ?',
      [item.eventType, item.title, item.eventDate, item.nextDate, item.hospital, item.note, item.reminderId, item.id]
    )
    return 1
  }

  async delete(id: number): Promise<number> {
    const store = await this.getStore()
    await store.executeSql('DELETE FROM health_events WHERE id = ?', [id])
    return 1
  }

  async queryByPetId(petId: number): Promise<HealthEvent[]> {
    const store = await this.getStore()
    const result = await store.querySql(
      'SELECT * FROM health_events WHERE pet_id = ? ORDER BY event_date DESC, created_at DESC',
      [petId]
    )
    const items: HealthEvent[] = []
    while (result.goToNextRow()) {
      items.push(this.readEvent(result))
    }
    result.close()
    return items
  }

  async queryUpcoming(): Promise<HealthEvent[]> {
    const store = await this.getStore()
    const start: string = DateUtils.today()
    const endDate: Date = new Date()
    endDate.setDate(endDate.getDate() + 30)
    const end: string = DateUtils.toDateOnly(endDate)
    const result = await store.querySql(
      'SELECT * FROM health_events WHERE next_date IS NOT NULL AND next_date != "" AND next_date >= ? AND next_date <= ? ORDER BY next_date ASC',
      [start, end]
    )
    const items: HealthEvent[] = []
    while (result.goToNextRow()) {
      items.push(this.readEvent(result))
    }
    result.close()
    return items
  }

  private readEvent(result: relationalStore.ResultSet): HealthEvent {
    return {
      id: result.getLong(result.getColumnIndex('id')),
      petId: result.getLong(result.getColumnIndex('pet_id')),
      eventType: result.getString(result.getColumnIndex('event_type')),
      title: result.getString(result.getColumnIndex('title')),
      eventDate: result.getString(result.getColumnIndex('event_date')),
      nextDate: result.getString(result.getColumnIndex('next_date')),
      hospital: result.getString(result.getColumnIndex('hospital')),
      note: result.getString(result.getColumnIndex('note')),
      reminderId: result.getLong(result.getColumnIndex('reminder_id')),
      createdAt: result.getLong(result.getColumnIndex('created_at'))
    }
  }
}
