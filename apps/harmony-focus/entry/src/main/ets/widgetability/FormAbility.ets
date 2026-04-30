import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility'
import formBindingData from '@ohos.app.form.formBindingData'
import formProvider from '@ohos.app.form.formProvider'
import preferences from '@ohos.data.preferences'
import Want from '@ohos.app.ability.Want'
import { AppDefaults, SessionMode, TimerStatus } from '../common/Constants'

// Widget 专用 Preferences 文件名（与 TimerService 保持一致）
const WIDGET_PREFS_NAME = 'harmony_focus_widget'

export default class FormAbility extends FormExtensionAbility {
  onAddForm(_want: Want): formBindingData.FormBindingData {
    // 同步读取不可用时返回默认值，异步更新由 onUpdateForm 处理
    return this.buildDefaultFormData()
  }

  onRemoveForm(_formId: string): void {
  }

  onCastToNormalForm(_formId: string): void {
  }

  async onUpdateForm(formId: string): Promise<void> {
    const data = await this.readWidgetPrefs()
    await formProvider.updateForm(formId, data)
  }

  onFormEvent(_formId: string, _message: string): void {
  }

  /**
   * 从 Preferences 读取卡片数据
   * 主应用 TimerService 更新计时状态时同步写入此 Preferences
   */
  private async readWidgetPrefs(): Promise<formBindingData.FormBindingData> {
    try {
      const prefs = await preferences.getPreferences(this.context, WIDGET_PREFS_NAME)
      const todayPomodoros = await prefs.get(AppDefaults.STORAGE_TODAY_POMODOROS, 0) as number
      const timerStatus = await prefs.get(AppDefaults.STORAGE_TIMER_STATUS, TimerStatus.IDLE) as string
      const currentMode = await prefs.get(AppDefaults.STORAGE_CURRENT_MODE, SessionMode.FOCUS) as string
      return formBindingData.createFormBindingData({
        todayPomodoros,
        timerStatus,
        currentMode
      })
    } catch (err) {
      console.warn(`FormAbility.readWidgetPrefs error: ${JSON.stringify(err)}`)
      return this.buildDefaultFormData()
    }
  }

  private buildDefaultFormData(): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData({
      todayPomodoros: 0,
      timerStatus: TimerStatus.IDLE,
      currentMode: SessionMode.FOCUS
    })
  }
}
