import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility'
import Want from '@ohos.app.ability.Want'
import formBindingData from '@ohos.app.form.formBindingData'

export default class WaterFormExtensionAbility extends FormExtensionAbility {
  onCreate(want: Want): formBindingData.FormBindingData {
    const formData = formBindingData.createFormBindingData({
      total: 0,
      goal: 2000
    })
    return formData
  }

  onNewWant(want: Want): void {
  }
}
