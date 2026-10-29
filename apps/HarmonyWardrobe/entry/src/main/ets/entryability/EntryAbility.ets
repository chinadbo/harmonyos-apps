import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import hilog from '@ohos.hilog'
import { WardrobeDb } from '../data/WardrobeDb'

const DOMAIN: number = 0x0001
const TAG: string = 'HarmonyWardrobe'

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onCreate')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    WardrobeDb.getInstance().init(this.context)
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'loadContent failed, code=%{public}d', err.code)
        return
      }
      hilog.info(DOMAIN, TAG, 'loadContent succeed')
    })
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onForeground')
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onBackground')
  }
}
