import FormExtensionAbility from '@ohos.app.ability.FormExtensionAbility'
import formBindingData from '@ohos.app.form.formBindingData'
import formProvider from '@ohos.app.form.formProvider'
import { FeedDao } from '../database/FeedDao'
import { PetDao } from '../database/PetDao'
import { AppStorageKeys } from '../common/AppStorageKeys'

export default class FeedWidgetAbility extends FormExtensionAbility {
  async onAddForm(formId: string, want: Record<string, Object>): Promise<formBindingData.FormBindingData> {
    return this.buildBindingData(formId)
  }

  async onUpdateForm(formId: string): Promise<void> {
    const data = await this.buildBindingData(formId)
    await formProvider.updateForm(formId, data)
  }

  onRemoveForm(formId: string): void {
  }

  onCastToNormalForm(formId: string): void {
  }

  async onVisibilityChange(newStatus: Record<string, number>): Promise<void> {
  }

  private async buildBindingData(formId: string): Promise<formBindingData.FormBindingData> {
    const petId: number = AppStorage.get<number>(AppStorageKeys.ACTIVE_PET_ID) ?? 0
    const petDao: PetDao = new PetDao(this.context)
    const feedDao: FeedDao = new FeedDao(this.context)
    const pet = petId > 0 ? await petDao.queryById(petId) : null
    const count: number = petId > 0 ? await feedDao.queryTodayCount(petId) : 0
    AppStorage.setOrCreate(AppStorageKeys.TODAY_FEED_COUNT, count)
    AppStorage.setOrCreate(AppStorageKeys.ACTIVE_PET_NAME, pet?.name ?? '我的宠物')
    const binding = formBindingData.createFormBindingData({
      petName: pet?.name ?? '我的宠物',
      todayFeedCount: count,
      nextFeedTime: AppStorage.get<string>(AppStorageKeys.NEXT_FEED_TIME) ?? '--:--'
    })
    return binding
  }
}
