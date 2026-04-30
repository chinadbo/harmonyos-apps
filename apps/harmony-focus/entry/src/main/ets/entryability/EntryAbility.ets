import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import { databaseService } from '../services/DatabaseService'
import { notifyService } from '../services/NotifyService'
import { audioService } from '../services/AudioService'
import { timerService } from '../services/TimerService'
import { AppDefaults } from '../common/Constants'

export default class EntryAbility extends UIAbility {
  async onCreate(): Promise<void> {
    databaseService.setContext(this.context)
    notifyService.setContext(this.context)
    audioService.setContext(this.context)
    await databaseService.init(this.context)
    const settings = await databaseService.getSettings()
    AppStorage.SetOrCreate(AppDefaults.STORAGE_NOTIFICATION_ENABLED, settings.notificationEnabled)
    await timerService.hydrateFromSettings(settings)
  }

  onDestroy(): void {
    audioService.release()
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (error) => {
      if (error.code) {
        console.error(`Failed to load Index page: ${JSON.stringify(error)}`)
      }
    })
  }

  onWindowStageDestroy(): void {
  }
}
