import FormExtensionAbility from '@ohos.app.ability.FormExtensionAbility'
import Want from '@ohos.app.ability.Want'
import formBindingData from '@ohos.app.form.formBindingData'
import hilog from '@ohos.hilog'
import WidgetService from '../service/WidgetService'

export default class PackFormExtensionAbility extends FormExtensionAbility {
  onCreate(want: Want): formBindingData.FormBindingData {
    hilog.info(0x0000, 'HarmonyPack', `PackFormExtensionAbility onCreate: ${JSON.stringify(want.parameters || {})}`)
    const formId = Number(want.parameters?.formId || 0)
    this.appendFormId(formId)
    this.refreshStorageAsync()
    return formBindingData.createFormBindingData({
      title: 'HarmonyPack',
      destination: '正在加载',
      dateText: '请稍候',
      progressText: '打包进度 0%',
      progressValue: '0',
      tripTypeText: '尚未设置',
      tripId: '0',
      emptyText: '打开应用查看详情'
    })
  }

  onNewWant(want: Want): void {
    hilog.info(0x0000, 'HarmonyPack', `PackFormExtensionAbility onNewWant: ${JSON.stringify(want.parameters || {})}`)
    const formId = Number(want.parameters?.formId || 0)
    this.appendFormId(formId)
    this.refreshStorageAsync()
  }

  onDestroy(formId: string): void {
    hilog.info(0x0000, 'HarmonyPack', `PackFormExtensionAbility onDestroy: ${formId}`)
    const formIds = (AppStorage.Get('formIds') as number[]) || []
    const target = Number(formId)
    AppStorage.SetOrCreate('formIds', formIds.filter((item: number) => item !== target))
  }

  private appendFormId(formId: number): void {
    if (formId <= 0) {
      return
    }
    const formIds = ((AppStorage.Get('formIds') as number[]) || []).slice()
    if (!formIds.includes(formId)) {
      formIds.push(formId)
      AppStorage.SetOrCreate('formIds', formIds)
    }
  }

  private async refreshStorageAsync(): Promise<void> {
    try {
      const snapshot = await WidgetService.buildSnapshot(this.context)
      AppStorage.SetOrCreate('widgetTitle', snapshot.title)
      AppStorage.SetOrCreate('widgetDestination', snapshot.destination)
      AppStorage.SetOrCreate('widgetDateText', snapshot.dateText)
      AppStorage.SetOrCreate('widgetProgressText', snapshot.progressText)
      AppStorage.SetOrCreate('widgetProgressValue', snapshot.progressValue)
      AppStorage.SetOrCreate('widgetTripTypeText', snapshot.tripTypeText)
      AppStorage.SetOrCreate('widgetTripId', snapshot.tripId)
      AppStorage.SetOrCreate('widgetEmptyText', snapshot.emptyText)
    } catch (error) {
      hilog.error(0x0000, 'HarmonyPack', `Failed to refresh widget storage: ${JSON.stringify(error)}`)
    }
  }
}
