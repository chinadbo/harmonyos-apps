import UIAbility from '@ohos.app.ability.UIAbility'
import Want from '@ohos.app.ability.Want'
import window from '@ohos.window'
import { DatabaseHelper } from '../database/DatabaseHelper'
import { WordDao } from '../database/WordDao'
import { NotificationService } from '../service/NotificationService'

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want): void {
    this.prepareApp()
  }

  private async prepareApp(): Promise<void> {
    await DatabaseHelper.init(this.context)
    const wordDao = new WordDao()
    const todayWord = await wordDao.getRecommendedWord()
    if (todayWord) {
      await NotificationService.publishDailyWord('HarmonyWord 今日推荐', `${todayWord.word}：${todayWord.definition}`)
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (error) => {
      if (error.code) {
        console.error(`load content failed: ${JSON.stringify(error)}`)
      }
    })
  }
}
