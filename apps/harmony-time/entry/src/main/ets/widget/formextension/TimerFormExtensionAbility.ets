import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility'
import formBindingData from '@ohos.app.form.formBindingData'
import formProvider from '@ohos.app.form.formProvider'
import preferences from '@ohos.data.preferences'
import Want from '@ohos.app.ability.Want'

const PREF_STORE_NAME = 'timer_prefs'

export default class TimerFormExtensionAbility extends FormExtensionAbility {
  onCreate(want: Want): formBindingData.FormBindingData {
    console.info('TimerFormExtensionAbility onCreate')
    const formData = this.getTimerFormData()
    return formBindingData.createFormBindingData(formData)
  }

  onNewWant(want: Want): void {
    console.info('TimerFormExtensionAbility onNewWant')
    const formId = want.parameters?.['ohos.extra.param.key.form_identity'] as string
    if (formId) {
      const formData = this.getTimerFormData()
      const bindingData = formBindingData.createFormBindingData(formData)
      formProvider.updateForm(formId, bindingData)
    }
  }

  onCastToNormal(formId: string): void {
    console.info('TimerFormExtensionAbility onCastToNormal: ' + formId)
  }

  onUpdate(formId: string): void {
    console.info('TimerFormExtensionAbility onUpdate: ' + formId)
    const formData = this.getTimerFormData()
    const bindingData = formBindingData.createFormBindingData(formData)
    formProvider.updateForm(formId, bindingData)
  }

  onVisibilityChange(newStatus: Record<string, number>): void {
    console.info('TimerFormExtensionAbility onVisibilityChange')
  }

  onEvent(formId: string, message: string): void {
    console.info('TimerFormExtensionAbility onEvent: ' + formId + ', msg: ' + message)
  }

  onDestroy(formId: string): void {
    console.info('TimerFormExtensionAbility onDestroy: ' + formId)
  }

  private getTimerFormData(): Record<string, string | boolean> {
    let currentProject = '无计时'
    let elapsedTime = '00:00:00'
    let isRunning = false

    try {
      const store = preferences.getPreferencesSync(this.context, PREF_STORE_NAME)
      const projectId = store.getSync('runningProjectId', -1) as number
      const startTime = store.getSync('timerStartTime', 0) as number

      if (projectId !== -1 && startTime > 0) {
        isRunning = true
        currentProject = '项目 #' + projectId.toString()
        const elapsed = Math.floor((Date.now() - startTime) / 1000)
        elapsedTime = this.formatTime(elapsed)
      }
    } catch (err) {
      console.error('TimerFormExtensionAbility getTimerFormData error: ' + JSON.stringify(err))
    }

    return {
      'currentProject': currentProject,
      'elapsedTime': elapsedTime,
      'isRunning': isRunning
    }
  }

  private formatTime(seconds: number): string {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    const s = seconds % 60
    return `${this.pad(h)}:${this.pad(m)}:${this.pad(s)}`
  }

  private pad(n: number): string {
    return n < 10 ? '0' + n.toString() : n.toString()
  }
}
