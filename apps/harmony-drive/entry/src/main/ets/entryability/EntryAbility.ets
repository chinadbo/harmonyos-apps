import AbilityConstant from '@ohos.app.ability.AbilityConstant'
import common from '@ohos.app.ability.common'
import Want from '@ohos.app.ability.Want'
import hilog from '@ohos.hilog'
import { QuestionBank } from '../data/QuestionBank'
import { DbHelper } from '../store/DbHelper'
import { PrefsHelper } from '../store/PrefsHelper'

const TAG = 'HarmonyDrive'
const DOMAIN = 0x0001

export default class EntryAbility extends common.UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'Ability onCreate')
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy')
  }

  async onWindowStageCreate(windowStage: common.WindowStage): Promise<void> {
    const context = this.context
    AppStorage.setOrCreate('currentSubject', 1)
    AppStorage.setOrCreate('refreshKey', 0)
    try {
      const subject = await PrefsHelper.getSubject()
      AppStorage.setOrCreate('currentSubject', subject)
    } catch (err) {
      hilog.error(DOMAIN, TAG, `prefs init failed: ${JSON.stringify(err)}`)
    }
    try {
      await QuestionBank.load(context)
      await DbHelper.init(context)
      await PrefsHelper.init(context)
    } catch (err) {
      hilog.error(DOMAIN, TAG, `data init failed: ${JSON.stringify(err)}`)
    }
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'loadContent failed')
        return
      }
      hilog.info(DOMAIN, TAG, 'loadContent succeed')
    })
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}
