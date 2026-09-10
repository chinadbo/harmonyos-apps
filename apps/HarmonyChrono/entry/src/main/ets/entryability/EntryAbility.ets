import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import { dataStore } from '../model/DataStore'
import { timerService } from '../services/TimerService'

export default class EntryAbility extends UIAbility {
  async onCreate(): Promise<void> {
    await dataStore.init(this.context)
    timerService.setContext(this.context)
    await timerService.initializeDefaults()
    await timerService.restore()
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/StopwatchPage', (error) => {
      if (error.code) {
        console.error(`Failed to load StopwatchPage: ${JSON.stringify(error)}`)
      }
    })
  }

  onDestroy(): void {
    timerService.destroy()
  }
}
