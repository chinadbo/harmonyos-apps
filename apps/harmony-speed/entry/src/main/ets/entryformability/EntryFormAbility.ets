import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility'
import formBindingData from '@ohos.app.form.formBindingData'
import formInfo from '@ohos.app.form.formInfo'
import Want from '@ohos.app.ability.Want'

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const obj = {
      downloadSpeed: '0.0',
      uploadSpeed: '0.0',
      ping: '0'
    }
    return formBindingData.createFormBindingData(obj)
  }

  onCastToNormalForm(formId: string): void {
  }

  onUpdateForm(formId: string): void {
  }

  onFormEvent(formId: string, message: string): void {
  }

  onRemoveForm(formId: string): void {
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY
  }
}
