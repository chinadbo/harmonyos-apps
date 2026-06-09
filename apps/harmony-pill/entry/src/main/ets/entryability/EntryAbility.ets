import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'

import { pillDatabase } from '../services/PillDatabase'

export default class EntryAbility extends UIAbility {
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    await pillDatabase.init(this.context)
    windowStage.loadContent('pages/Index')
  }
}
