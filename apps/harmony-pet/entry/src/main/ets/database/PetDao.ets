import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import { DatabaseHelper } from './DatabaseHelper'
import type { Pet } from '../model/Pet'

export class PetDao {
  constructor(private context: common.UIAbilityContext) {
  }

  private async getStore(): Promise<relationalStore.RdbStore> {
    return DatabaseHelper.getInstance().getStore(this.context)
  }

  async insert(pet: Omit<Pet, 'id'>): Promise<number> {
    const store = await this.getStore()
    return store.insert('pets', {
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      birth_date: pet.birthDate,
      gender: pet.gender,
      avatar_uri: pet.avatarUri,
      created_at: pet.createdAt
    })
  }

  async update(pet: Pet): Promise<number> {
    const store = await this.getStore()
    await store.executeSql(
      'UPDATE pets SET name = ?, species = ?, breed = ?, birth_date = ?, gender = ?, avatar_uri = ? WHERE id = ?',
      [pet.name, pet.species, pet.breed, pet.birthDate, pet.gender, pet.avatarUri, pet.id]
    )
    return 1
  }

  async delete(id: number): Promise<number> {
    const store = await this.getStore()
    await store.executeSql('DELETE FROM pets WHERE id = ?', [id])
    return 1
  }

  async queryAll(): Promise<Pet[]> {
    const store = await this.getStore()
    const result = await store.querySql('SELECT * FROM pets ORDER BY created_at DESC')
    const pets: Pet[] = []
    while (result.goToNextRow()) {
      pets.push(this.readPet(result))
    }
    result.close()
    return pets
  }

  async queryById(id: number): Promise<Pet | null> {
    const store = await this.getStore()
    const result = await store.querySql('SELECT * FROM pets WHERE id = ? LIMIT 1', [id])
    const pet: Pet | null = result.goToFirstRow() ? this.readPet(result) : null
    result.close()
    return pet
  }

  private readPet(result: relationalStore.ResultSet): Pet {
    return {
      id: result.getLong(result.getColumnIndex('id')),
      name: result.getString(result.getColumnIndex('name')),
      species: result.getString(result.getColumnIndex('species')),
      breed: result.getString(result.getColumnIndex('breed')),
      birthDate: result.getString(result.getColumnIndex('birth_date')),
      gender: result.getString(result.getColumnIndex('gender')),
      avatarUri: result.getString(result.getColumnIndex('avatar_uri')),
      createdAt: result.getLong(result.getColumnIndex('created_at'))
    }
  }
}
