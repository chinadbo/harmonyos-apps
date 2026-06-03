import UIAbility from '@ohos.app.ability.UIAbility'
import type Want from '@ohos.app.ability.Want'
import window from '@ohos.window'
import { AppStorageKeys } from '../common/AppStorageKeys'
import { HealthDao } from '../database/HealthDao'
import { PetDao } from '../database/PetDao'
import { NotificationService } from '../service/NotificationService'
import { DateUtils } from '../common/DateUtils'
import type { HealthEvent } from '../model/HealthEvent'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want): void {
    AppStorage.setOrCreate(AppStorageKeys.NAV_PATH_STACK, new NavPathStack())
    AppStorage.setOrCreate(AppStorageKeys.ACTIVE_PET_ID, 0)
    AppStorage.setOrCreate(AppStorageKeys.ACTIVE_PET_NAME, '我的宠物')
    AppStorage.setOrCreate(AppStorageKeys.TODAY_FEED_COUNT, 0)
    AppStorage.setOrCreate(AppStorageKeys.NEXT_FEED_TIME, '--:--')
    AppStorage.setOrCreate(AppStorageKeys.ACTIVE_REMINDERS, [])
    AppStorage.setOrCreate(AppStorageKeys.DATA_VERSION, 0)
    this.checkUpcomingHealthEvents().catch(() => {
    })
  }

  onDestroy(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (error) => {
      if (error && error.code) {
      }
    })
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
    this.checkUpcomingHealthEvents().catch(() => {
    })
  }

  onBackground(): void {
  }

  private async checkUpcomingHealthEvents(): Promise<void> {
    const healthDao: HealthDao = new HealthDao(this.context)
    const petDao: PetDao = new PetDao(this.context)
    const notificationService: NotificationService = new NotificationService()
    const items: HealthEvent[] = await healthDao.queryUpcoming()
    for (const item of items) {
      const pet = await petDao.queryById(item.petId)
      await notificationService.sendVaccineNotification(
        pet?.name ?? '宠物',
        item.title,
        DateUtils.daysUntil(item.nextDate)
      )
    }
  }
}
