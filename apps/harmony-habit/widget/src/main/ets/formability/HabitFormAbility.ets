import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import formProvider from '@ohos.app.form.formProvider';
import preferences from '@ohos.data.preferences';

export default class HabitFormAbility extends FormExtensionAbility {
  private async readData(): Promise<Record<string, Object>> {
    const store = await preferences.getPreferences(this.context, 'HarmonyHabitWidget');
    return {
      todayDone: Number(await store.get('today_done', 0)),
      todayTotal: Number(await store.get('today_total', 0)),
      todayQuote: String(await store.get('today_quote', '今天完成一小步，长期就是一大步。'))
    };
  }

  async onAddForm(formId: string): Promise<formBindingData.FormBindingData> {
    const data = await this.readData();
    return formBindingData.createFormBindingData(data);
  }

  async onUpdateForm(formId: string): Promise<void> {
    const data = await this.readData();
    const binding = formBindingData.createFormBindingData(data);
    await formProvider.updateForm(formId, binding);
  }

  onCastToNormalForm(formId: string): void {
  }

  onRemoveForm(formId: string): void {
  }
}
