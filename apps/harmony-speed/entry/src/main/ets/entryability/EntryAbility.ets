import UIAbility from '@ohos.app.ability.UIAbility'
import hilog from '@ohos.hilog'
import window from '@ohos.window'
import Want from '@ohos.app.ability.Want'
import AbilityConstant from '@ohos.app.ability.AbilityConstant'
import { speedDb } from '../database/SpeedDatabase'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'HarmonySpeed', '%{public}s', 'Ability onCreate')
  }

  onDestroy(): void {
    hilog.info(0x0000, 'HarmonySpeed', '%{public}s', 'Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'HarmonySpeed', '%{public}s', 'Ability onWindowStageCreate')

    // Init DB
    speedDb.init(this.context).catch((err: Error) => {
      hilog.error(0x0000, 'HarmonySpeed', 'DB init failed: %{public}s', err.message)
    })

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'HarmonySpeed', 'Failed to load content: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(0x0000, 'HarmonySpeed', '%{public}s', 'Succeeded in loading content')
    })
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'HarmonySpeed', '%{public}s', 'Ability onWindowStageDestroy')
  }

  onForeground(): void {
    hilog.info(0x0000, 'HarmonySpeed', '%{public}s', 'Ability onForeground')
  }

  onBackground(): void {
    hilog.info(0x0000, 'HarmonySpeed', '%{public}s', 'Ability onBackground')
  }
}
