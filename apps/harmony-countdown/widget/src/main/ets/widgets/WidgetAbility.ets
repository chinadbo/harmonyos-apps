import FormExtensionAbility from '@ohos.app.ability.FormExtensionAbility';
import Want from '@ohos.app.ability.Want';
import formBindingData from '@ohos.app.form.formBindingData';
import formInfo from '@ohos.app.form.formInfo';
import dataPreferences from '@ohos.data.preferences';

export default class WidgetAbility extends FormExtensionAbility {
  private preferences?: dataPreferences.Preferences;

  async onCreate(): Promise<void> {
    this.preferences = await dataPreferences.getPreferences(this.context, 'widget_forms');
  }

  async onAddForm(want: Want): Promise<formBindingData.FormBindingData> {
    // Want.parameters 类型是 Record<string, Object>，不是 Map，不能用 .get()，需用方括号索引
    let formId: string = `${want.parameters?.['ohos.extra.param.key.form_identity'] ?? ''}`;
    if (formId.length > 0) {
      await this.addFormId(formId);
    }
    return formBindingData.createFormBindingData({
      title: '暂无事件',
      dateText: '去添加第一个纪念日吧',
      countdownText: '开始记录重要日子',
      noteText: 'HarmonyCountdown',
      eventCount: '0'
    });
  }

  async onRemoveForm(formId: string): Promise<void> {
    await this.removeFormId(formId);
  }

  onCastToNormalForm(formId: string): void {
  }

  onUpdateForm(formId: string): void {
  }

  async onAcquireFormState(want: Want): Promise<formInfo.FormState> {
    return formInfo.FormState.READY;
  }

  private async addFormId(formId: string): Promise<void> {
    if (!this.preferences) {
      this.preferences = await dataPreferences.getPreferences(this.context, 'widget_forms');
    }
    let formIds: string[] = this.preferences?.getSync('formIds', []) as string[];
    if (formIds.indexOf(formId) < 0) {
      formIds.push(formId);
      await this.preferences?.put('formIds', formIds);
      await this.preferences?.flush();
    }
  }

  private async removeFormId(formId: string): Promise<void> {
    if (!this.preferences) {
      this.preferences = await dataPreferences.getPreferences(this.context, 'widget_forms');
    }
    let formIds: string[] = this.preferences?.getSync('formIds', []) as string[];
    let filtered: string[] = formIds.filter((item: string) => item !== formId);
    await this.preferences?.put('formIds', filtered);
    await this.preferences?.flush();
  }
}
