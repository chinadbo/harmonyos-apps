import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility'
import formBindingData from '@ohos.app.form.formBindingData'

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData({
      title: 'HarmonyNutrition',
      calories: 'Today 1240 / 1800 kcal',
      protein: 'Protein 82g'
    })
  }

  onUpdateForm(): void {
    console.info('HarmonyNutrition form updated')
  }

  onRemoveForm(): void {
    console.info('HarmonyNutrition form removed')
  }
}
