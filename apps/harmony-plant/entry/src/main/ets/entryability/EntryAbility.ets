import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import { PlantService } from '../service/PlantService'

export default class EntryAbility extends UIAbility {
  async onCreate(): Promise<void> {
    AppStorage.setOrCreate('plantCount', 0)
    await PlantService.getInstance().prepare(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error(`Failed to load the content. Cause: ${JSON.stringify(err)}`)
      }
    })
  }

  onWindowStageDestroy(): void {
  }
}
