import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    console.info('HarmonyNutrition EntryAbility onCreate')
  }

  onDestroy(): void {
    console.info('HarmonyNutrition EntryAbility onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error(`Failed to load the content. Cause: ${JSON.stringify(err)}`)
        return
      }
      console.info('Succeeded in loading the content.')
    })
  }

  onWindowStageDestroy(): void {
    console.info('HarmonyNutrition window stage destroyed')
  }

  onForeground(): void {
    console.info('HarmonyNutrition moved to foreground')
  }

  onBackground(): void {
    console.info('HarmonyNutrition moved to background')
  }
}
