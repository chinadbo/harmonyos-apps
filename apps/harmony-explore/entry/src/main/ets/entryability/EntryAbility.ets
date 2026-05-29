import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import { DatabaseService } from '../service/DatabaseService'

export default class EntryAbility extends UIAbility {
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    AppStorage.SetOrCreate('abilityContext', this.context)
    AppStorage.SetOrCreate('refreshToken', 0)
    AppStorage.SetOrCreate('selectedCheckInId', 0)
    await DatabaseService.getInstance().init(this.context)
    windowStage.loadContent('pages/Index', (err) => {
      if (err && err.code) {
        console.error(`Failed to load the content. Code: ${err.code}, message: ${err.message}`)
      }
    })
  }
}
