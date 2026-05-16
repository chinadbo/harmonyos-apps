import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility'
import formBindingData from '@ohos.app.form.formBindingData'
import formProvider from '@ohos.app.form.formProvider'
import Want from '@ohos.app.ability.Want'
import preferences from '@ohos.data.preferences'
import { SensorService } from '../service/SensorService'

const PREFS_NAME = 'harmonyfit_form'
const KEY_STEP_GOAL = 'stepGoal'
const KEY_FORM_IDS = 'formIds'
const DEFAULT_STEP_GOAL = 8000

export default class EntryFormAbility extends FormExtensionAbility {

  async onAddForm(want: Want): Promise<formBindingData.FormBindingData> {
    const formId = want.parameters?.['ohos.extra.param.key.form_identity'] as string
      ?? want.parameters?.['ohos.extra.param.key.form.identity'] as string
      ?? ''
    if (formId) {
      await this.saveFormId(formId)
    }
    return await this.buildBindingData()
  }

  async onUpdateForm(formId: string): Promise<void> {
    try {
      const bindingData = await this.buildBindingData()
      await formProvider.updateForm(formId, bindingData)
    } catch (error) {
      console.error(`EntryFormAbility onUpdateForm failed: ${JSON.stringify(error)}`)
    }
  }

  async onRemoveForm(formId: string): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(this.context, PREFS_NAME)
      const idsJson = await prefs.get(KEY_FORM_IDS, '[]') as string
      const ids: string[] = JSON.parse(idsJson)
      const updated = ids.filter(id => id !== formId)
      await prefs.put(KEY_FORM_IDS, JSON.stringify(updated))
      await prefs.flush()
    } catch (error) {
      console.error(`EntryFormAbility onRemoveForm failed: ${JSON.stringify(error)}`)
    }
  }

  private async saveFormId(formId: string): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(this.context, PREFS_NAME)
      const idsJson = await prefs.get(KEY_FORM_IDS, '[]') as string
      const ids: string[] = JSON.parse(idsJson)
      if (!ids.includes(formId)) {
        ids.push(formId)
        await prefs.put(KEY_FORM_IDS, JSON.stringify(ids))
        await prefs.flush()
      }
    } catch (error) {
      console.error(`EntryFormAbility saveFormId failed: ${JSON.stringify(error)}`)
    }
  }

  private async buildBindingData(): Promise<formBindingData.FormBindingData> {
    try {
      const steps = SensorService.getInstance().getTodaySteps()
      const prefs = await preferences.getPreferences(this.context, PREFS_NAME)
      const goal = await prefs.get(KEY_STEP_GOAL, DEFAULT_STEP_GOAL) as number
      const progress = goal > 0 ? `${Math.min(100, Math.floor(steps / goal * 100))}%` : '0%'
      return formBindingData.createFormBindingData({
        steps: `${steps}`,
        goal: `${goal}`,
        progress
      })
    } catch (error) {
      console.error(`EntryFormAbility buildBindingData failed: ${JSON.stringify(error)}`)
      return formBindingData.createFormBindingData({
        steps: '0',
        goal: `${DEFAULT_STEP_GOAL}`,
        progress: '0%'
      })
    }
  }
}
