import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import { Plant } from '../model/Plant'
import { CareRecord, CareType } from '../model/CareRecord'
import { PlantDiary } from '../model/PlantDiary'
import { DatabaseService } from './DatabaseService'
import { ReminderService } from './ReminderService'

export interface ReminderView {
  plant: Plant
  nextWaterDate: string
  dueToday: boolean
}

type DbRow = Record<string, Object | number | string | null>

export class PlantService {
  private static instance: PlantService = new PlantService()
  private context?: common.UIAbilityContext

  static getInstance(): PlantService {
    return PlantService.instance
  }

  setContext(context: common.UIAbilityContext): void {
    this.context = context
  }

  private getContext(): common.UIAbilityContext {
    if (!this.context) {
      throw new Error('UIAbilityContext has not been initialized')
    }
    return this.context
  }

  async prepare(context: common.UIAbilityContext): Promise<void> {
    this.setContext(context)
    await DatabaseService.getInstance().getStore(context)
    await this.updatePlantCount()
  }

  private async getStore(): Promise<relationalStore.RdbStore> {
    return DatabaseService.getInstance().getStore(this.getContext())
  }

  private isNumericColumn(column: string): boolean {
    return ['id', 'plantId', 'waterInterval', 'fertilizeInterval', 'reminderId'].includes(column)
  }

  private readCell(resultSet: relationalStore.ResultSet, index: number, column: string): string | number | null {
    if (this.isNumericColumn(column)) {
      return Number(resultSet.getLong(index))
    }
    return resultSet.getString(index)
  }

  private async queryList(sql: string, args: relationalStore.ValueType[] = []): Promise<DbRow[]> {
    const store = await this.getStore()
    const resultSet = await store.querySql(sql, args)
    const rows: DbRow[] = []
    if (resultSet.rowCount === 0) {
      resultSet.close()
      return rows
    }
    resultSet.goToFirstRow()
    do {
      const row: DbRow = {}
      for (let index = 0; index < resultSet.columnCount; index++) {
        const column = resultSet.getColumnName(index)
        row[column] = this.readCell(resultSet, index, column)
      }
      rows.push(row)
    } while (resultSet.goToNextRow())
    resultSet.close()
    return rows
  }

  private async queryOne(sql: string, args: relationalStore.ValueType[] = []): Promise<DbRow | undefined> {
    const rows = await this.queryList(sql, args)
    return rows.length > 0 ? rows[0] : undefined
  }

  private async updatePlantCount(): Promise<void> {
    const plants = await this.listPlants()
    AppStorage.setOrCreate('plantCount', plants.length)
  }

  async listPlants(): Promise<Plant[]> {
    const rows = await this.queryList('SELECT * FROM plants ORDER BY datetime(addedDate) DESC')
    return rows.map((row: DbRow) => Plant.fromRow(row))
  }

  async getPlantById(id: number): Promise<Plant | undefined> {
    const row = await this.queryOne('SELECT * FROM plants WHERE id = ?', [id])
    return row ? Plant.fromRow(row) : undefined
  }

  async savePlant(plant: Plant): Promise<Plant> {
    const store = await this.getStore()
    const values = {
      name: plant.name,
      species: plant.species,
      photoUri: plant.photoUri,
      addedDate: plant.addedDate,
      waterInterval: plant.waterInterval,
      fertilizeInterval: plant.fertilizeInterval,
      lastWateredAt: plant.lastWateredAt,
      lastFertilizedAt: plant.lastFertilizedAt,
      reminderId: plant.reminderId,
      notes: plant.notes
    }
    let targetId = plant.id
    if (plant.id > 0) {
      const predicates = new relationalStore.RdbPredicates('plants')
      predicates.equalTo('id', plant.id)
      await store.update(values, predicates)
    } else {
      targetId = Number(await store.insert('plants', values))
    }
    const storedPlant = (await this.getPlantById(targetId)) ?? new Plant({ ...plant, id: targetId })
    const reminderId = await ReminderService.getInstance().refreshPlantReminder(storedPlant)
    const reminderPredicates = new relationalStore.RdbPredicates('plants')
    reminderPredicates.equalTo('id', targetId)
    await store.update({ reminderId }, reminderPredicates)
    await this.updatePlantCount()
    return (await this.getPlantById(targetId)) ?? new Plant({ ...storedPlant, reminderId })
  }

  async deletePlant(id: number): Promise<void> {
    const plant = await this.getPlantById(id)
    const store = await this.getStore()
    if (plant && plant.reminderId > 0) {
      await ReminderService.getInstance().cancelReminder(plant.reminderId)
    }
    const carePredicates = new relationalStore.RdbPredicates('care_records')
    carePredicates.equalTo('plantId', id)
    await store.delete(carePredicates)
    const diaryPredicates = new relationalStore.RdbPredicates('plant_diary')
    diaryPredicates.equalTo('plantId', id)
    await store.delete(diaryPredicates)
    const plantPredicates = new relationalStore.RdbPredicates('plants')
    plantPredicates.equalTo('id', id)
    await store.delete(plantPredicates)
    await this.updatePlantCount()
  }

  async logCare(plantId: number, careType: CareType, note: string = ''): Promise<void> {
    const store = await this.getStore()
    const now = new Date().toISOString()
    await store.insert('care_records', {
      plantId,
      careType,
      careDate: now,
      note
    })
    const patch: Record<string, string> = {}
    if (careType === 'water') {
      patch.lastWateredAt = now
    }
    if (careType === 'fertilize') {
      patch.lastFertilizedAt = now
    }
    if (Object.keys(patch).length > 0) {
      const plantPredicates = new relationalStore.RdbPredicates('plants')
      plantPredicates.equalTo('id', plantId)
      await store.update(patch, plantPredicates)
      const plant = await this.getPlantById(plantId)
      if (plant) {
        const reminderId = await ReminderService.getInstance().refreshPlantReminder(plant)
        const reminderPredicates = new relationalStore.RdbPredicates('plants')
        reminderPredicates.equalTo('id', plantId)
        await store.update({ reminderId }, reminderPredicates)
      }
    }
  }

  async listCareRecordsByPlant(plantId: number): Promise<CareRecord[]> {
    const rows = await this.queryList('SELECT * FROM care_records WHERE plantId = ? ORDER BY datetime(careDate) DESC', [plantId])
    return rows.map((row: DbRow) => CareRecord.fromRow(row))
  }

  async createDiary(diary: PlantDiary): Promise<PlantDiary> {
    const store = await this.getStore()
    const diaryId = Number(await store.insert('plant_diary', {
      plantId: diary.plantId,
      title: diary.title,
      content: diary.content,
      photoUri: diary.photoUri,
      createdAt: diary.createdAt
    }))
    const row = await this.queryOne('SELECT * FROM plant_diary WHERE id = ?', [diaryId])
    return row ? PlantDiary.fromRow(row) : new PlantDiary({ ...diary, id: diaryId })
  }

  async listDiaries(plantId?: number): Promise<PlantDiary[]> {
    const rows = plantId && plantId > 0
      ? await this.queryList('SELECT * FROM plant_diary WHERE plantId = ? ORDER BY datetime(createdAt) DESC', [plantId])
      : await this.queryList('SELECT * FROM plant_diary ORDER BY datetime(createdAt) DESC')
    return rows.map((row: DbRow) => PlantDiary.fromRow(row))
  }

  async listRemindersView(): Promise<ReminderView[]> {
    const plants = await this.listPlants()
    return plants.map((plant: Plant) => ({
      plant,
      nextWaterDate: plant.formatDate(plant.getNextWaterDate()),
      dueToday: plant.isWaterDueToday()
    })).sort((left: ReminderView, right: ReminderView) => {
      if (left.dueToday === right.dueToday) {
        return left.nextWaterDate.localeCompare(right.nextWaterDate)
      }
      return left.dueToday ? -1 : 1
    })
  }

  async getTodayDuePlants(): Promise<Plant[]> {
    const plants = await this.listPlants()
    return plants.filter((plant: Plant) => plant.isWaterDueToday()).slice(0, 3)
  }
}
