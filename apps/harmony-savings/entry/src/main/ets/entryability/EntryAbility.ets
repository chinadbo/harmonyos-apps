import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import { DatabaseHelper } from '../database/DatabaseHelper'

export default class EntryAbility extends UIAbility {
  async onCreate(): Promise<void> {
    await DatabaseHelper.getInstance().init(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/HomePage', (error) => {
      if (error.code) {
        console.error(`load content failed: ${JSON.stringify(error)}`)
      }
    })
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}
