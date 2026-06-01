import UIAbility from '@ohos.app.ability.UIAbility'
import Want from '@ohos.app.ability.Want'
import window from '@ohos.window'
import hilog from '@ohos.hilog'
import TemplateDao from '../database/TemplateDao'
import DatabaseHelper from '../database/DatabaseHelper'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want): void {
    hilog.info(0x0000, 'HarmonyPack', `EntryAbility onCreate: ${JSON.stringify(want.parameters || {})}`)
    AppStorage.SetOrCreate('formIds', [])
    AppStorage.SetOrCreate('widgetTitle', 'HarmonyPack')
    AppStorage.SetOrCreate('widgetDestination', '暂无行程')
    AppStorage.SetOrCreate('widgetDateText', '点击创建新的旅行计划')
    AppStorage.SetOrCreate('widgetProgressText', '打包进度 0%')
    AppStorage.SetOrCreate('widgetProgressValue', '0')
    AppStorage.SetOrCreate('widgetTripTypeText', '尚未设置')
    AppStorage.SetOrCreate('widgetTripId', '0')
    AppStorage.SetOrCreate('widgetEmptyText', '立即开始添加行程')
    this.initializeData()
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (error) => {
      if (error.code) {
        hilog.error(0x0000, 'HarmonyPack', `Failed to load content: ${JSON.stringify(error)}`)
        return
      }
      hilog.info(0x0000, 'HarmonyPack', 'Window loaded successfully')
    })
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'HarmonyPack', 'Window stage destroyed')
  }

  onDestroy(): void {
    hilog.info(0x0000, 'HarmonyPack', 'EntryAbility destroyed')
  }

  onForeground(): void {
    hilog.info(0x0000, 'HarmonyPack', 'EntryAbility foreground')
  }

  onBackground(): void {
    hilog.info(0x0000, 'HarmonyPack', 'EntryAbility background')
  }

  private async initializeData(): Promise<void> {
    try {
      await DatabaseHelper.getInstance().getStore(this.context)
      await TemplateDao.ensureBuiltinTemplates(this.context)
    } catch (error) {
      const message = JSON.stringify(error)
      hilog.error(0x0000, 'HarmonyPack', `Failed to initialize data: ${message}`)
    }
  }
}
