import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import AbilityConstant from '@ohos.app.ability.AbilityConstant'
import Want from '@ohos.app.ability.Want'
import { DatabaseHelper } from '../database/DatabaseHelper'
import { TimerService } from '../service/TimerService'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('EntryAbility onCreate')

    // Initialize AppStorage
    AppStorage.SetOrCreate<number>('runningProjectId', -1)
    AppStorage.SetOrCreate<number>('runningEntryId', -1)
    AppStorage.SetOrCreate<number>('timerStartTime', 0)
    AppStorage.SetOrCreate<boolean>('isTimerRunning', false)
    AppStorage.SetOrCreate<number>('elapsedSeconds', 0)

    // Initialize database
    DatabaseHelper.getInstance().init(this.context)

    // Restore timer state from preferences
    const timerService = TimerService.getInstance()
    timerService.restoreFromPreferences(this.context)
  }

  onDestroy(): void {
    console.info('EntryAbility onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.info('EntryAbility onWindowStageCreate')
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        console.error('Failed to load content: ' + JSON.stringify(err))
        return
      }
      console.info('Succeeded in loading content')
    })
  }

  onWindowStageDestroy(): void {
    console.info('EntryAbility onWindowStageDestroy')
  }

  onForeground(): void {
    console.info('EntryAbility onForeground')
  }

  onBackground(): void {
    console.info('EntryAbility onBackground')
  }
}
