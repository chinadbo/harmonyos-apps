import UIAbility from '@ohos.app.ability.UIAbility'
import Want from '@ohos.app.ability.Want'
import AbilityConstant from '@ohos.app.ability.AbilityConstant'
import window from '@ohos.window'
import abilityAccessCtrl from '@ohos.abilityAccessCtrl'
import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import { DatabaseService } from '../service/DatabaseService'
import { PreferencesService } from '../service/PreferencesService'
import { SensorService } from '../service/SensorService'

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      await DatabaseService.getInstance().initDB(this.context)
      await PreferencesService.getInstance().init(this.context)
    } catch (error) {
      console.error(`EntryAbility onCreate failed: ${JSON.stringify(error)}`)
    }
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    windowStage.loadContent('pages/Index', (error) => {
      if (error.code) {
        console.error(`loadContent failed: ${JSON.stringify(error)}`)
      }
    })
    await this.requestMotionPermissionAndStart()
  }

  async onForeground(): Promise<void> {
    await this.requestMotionPermissionAndStart()
  }

  onBackground(): void {
  }

  onDestroy(): void {
    SensorService.getInstance().stopListening()
  }

  private async requestMotionPermissionAndStart(): Promise<void> {
    try {
      const atManager = abilityAccessCtrl.createAtManager()
      const permission = 'ohos.permission.ACTIVITY_MOTION'
      const result = await atManager.requestPermissionsFromUser(this.context as common.UIAbilityContext, [permission])
      const granted = result.authResults.length > 0 && result.authResults[0] === 0
      if (!granted) {
        promptAction.showToast({ message: '未授予运动权限，无法启动计步' })
        return
      }
      SensorService.getInstance().startListening()
    } catch (error) {
      promptAction.showToast({ message: '未授予运动权限，无法启动计步' })
      console.error(`requestMotionPermissionAndStart failed: ${JSON.stringify(error)}`)
    }
  }
}
