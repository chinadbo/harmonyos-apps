import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility'
import formBindingData from '@ohos.app.form.formBindingData'
import formProvider from '@ohos.app.form.formProvider'
import Want from '@ohos.app.ability.Want'
import { PlantService } from '../../service/PlantService'

export default class PlantFormExtensionAbility extends FormExtensionAbility {
  private currentFormId: string = ''

  async onCreate(formId: string, want: Want): Promise<formBindingData.FormBindingData> {
    this.currentFormId = `${formId}`
    PlantService.getInstance().setContext(this.context)
    return await this.buildFormData()
  }

  async onNewWant(want: Want): Promise<void> {
    PlantService.getInstance().setContext(this.context)
    if (this.currentFormId.length > 0) {
      await this.updateForm(this.currentFormId)
    }
  }

  private async buildFormData(): Promise<formBindingData.FormBindingData> {
    const plants = await PlantService.getInstance().getTodayDuePlants()
    return formBindingData.createFormBindingData({
      title: '今日浇水',
      subtitle: plants.length > 0 ? `待浇水 ${plants.length} 株` : '待处理植物',
      plants: plants.map((plant) => plant.name)
    })
  }

  private async updateForm(formId: string): Promise<void> {
    const data = await this.buildFormData()
    await formProvider.updateForm(Number(formId), data)
  }
}
