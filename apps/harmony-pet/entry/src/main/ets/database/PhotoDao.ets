import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import { DatabaseHelper } from './DatabaseHelper'
import type { PetPhoto } from '../model/PetPhoto'

export class PhotoDao {
  constructor(private context: common.UIAbilityContext) {
  }

  private async getStore(): Promise<relationalStore.RdbStore> {
    return DatabaseHelper.getInstance().getStore(this.context)
  }

  async insert(item: Omit<PetPhoto, 'id'>): Promise<number> {
    const store = await this.getStore()
    return store.insert('pet_photos', {
      pet_id: item.petId,
      photo_uri: item.photoUri,
      shot_date: item.shotDate,
      note: item.note,
      created_at: item.createdAt
    })
  }

  async delete(id: number): Promise<number> {
    const store = await this.getStore()
    await store.executeSql('DELETE FROM pet_photos WHERE id = ?', [id])
    return 1
  }

  async queryByPetId(petId: number): Promise<PetPhoto[]> {
    const store = await this.getStore()
    const result = await store.querySql(
      'SELECT * FROM pet_photos WHERE pet_id = ? ORDER BY shot_date DESC, created_at DESC',
      [petId]
    )
    const items: PetPhoto[] = []
    while (result.goToNextRow()) {
      items.push(this.readPhoto(result))
    }
    result.close()
    return items
  }

  private readPhoto(result: relationalStore.ResultSet): PetPhoto {
    return {
      id: result.getLong(result.getColumnIndex('id')),
      petId: result.getLong(result.getColumnIndex('pet_id')),
      photoUri: result.getString(result.getColumnIndex('photo_uri')),
      shotDate: result.getString(result.getColumnIndex('shot_date')),
      note: result.getString(result.getColumnIndex('note')),
      createdAt: result.getLong(result.getColumnIndex('created_at'))
    }
  }
}
