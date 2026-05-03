import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import formProvider from '@ohos.app.form.formProvider';
import Want from '@ohos.app.ability.Want';
import { DatabaseHelper } from '../data/DatabaseHelper';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    DatabaseHelper.getInstance().setContext(this.context);
    const data = {
      monthlyBalance: '0.00',
      todayExpense: '0.00',
      currency: '¥'
    };
    return formBindingData.createFormBindingData(data);
  }

  onFormEvent(formId: string, message: string): void {
    DatabaseHelper.getInstance().setContext(this.context);
    void this.refreshForm(Number(formId));
  }

  private async refreshForm(formId: number): Promise<void> {
    const summary = await DatabaseHelper.getInstance().getWidgetSummary();
    const data = formBindingData.createFormBindingData({
      monthlyBalance: summary.monthlyBalance.toFixed(2),
      todayExpense: summary.todayExpense.toFixed(2),
      currency: summary.currency
    });
    await formProvider.updateForm(formId, data);
  }
}
