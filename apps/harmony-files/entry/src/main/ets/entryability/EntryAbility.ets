import UIAbility from '@ohos.app.ability.UIAbility'
import hilog from '@ohos.hilog'
import window from '@ohos.window'
import AbilityConstant from '@ohos.app.ability.AbilityConstant'
import Want from '@ohos.app.ability.Want'
import { FavoritesService } from '../service/FavoritesService'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'HarmonyFiles', '%{public}s', 'Ability onCreate')
    FavoritesService.getInstance().init(this.context)
  }

  onDestroy(): void {
    hilog.info(0x0000, 'HarmonyFiles', '%{public}s', 'Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'HarmonyFiles', '%{public}s', 'Ability onWindowStageCreate')
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'HarmonyFiles', 'Failed to load Index page: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(0x0000, 'HarmonyFiles', 'Successfully loaded Index page')
    })
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'HarmonyFiles', '%{public}s', 'Ability onWindowStageDestroy')
  }

  onForeground(): void {
    hilog.info(0x0000, 'HarmonyFiles', '%{public}s', 'Ability onForeground')
  }

  onBackground(): void {
    hilog.info(0x0000, 'HarmonyFiles', '%{public}s', 'Ability onBackground')
  }
}
