import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'

export default class EntryAbility extends UIAbility {
  onCreate(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (error) => {
      if (error.code !== 0) {
        console.error(`loadContent failed: ${JSON.stringify(error)}`)
      }
    })
  }

  onWindowStageDestroy(): void {
  }
}
