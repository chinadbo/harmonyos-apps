import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/MainPage', (err) => {
      if (err && err.code) {
        console.error(`Failed to load the content. Code: ${err.code}, message: ${err.message}`)
      }
    })
  }
}
