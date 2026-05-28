import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import formProvider from '@ohos.app.form.formProvider';
import Want from '@ohos.app.ability.Want';
import dataPreferences from '@ohos.data.preferences';

export default class SleepFormExtensionAbility extends FormExtensionAbility {
  private getFormData(): Record<string, number> {
    try {
      const prefs = dataPreferences.getPreferencesSync(this.context, { name: 'sleep_stats' });
      const lastDuration = prefs.getSync('lastDuration', 0) as number;
      const lastQuality = prefs.getSync('lastQuality', 0) as number;
      const weeklyAvg = prefs.getSync('weeklyAvg', 0) as number;
      return { lastDuration, lastQuality, weeklyAvg };
    } catch (err) {
      console.error('[SleepFormExtensionAbility] getFormData error:', JSON.stringify(err));
      return { lastDuration: 0, lastQuality: 0, weeklyAvg: 0 };
    }
  }

  onCreate(want: Want): formBindingData.FormBindingData {
    const data = this.getFormData();
    return formBindingData.createFormBindingData(data);
  }

  onCastToNormalForm(formId: string): void {
    console.info('[SleepFormExtensionAbility] onCastToNormalForm:', formId);
  }

  onUpdateForm(formId: string): void {
    const data = this.getFormData();
    formProvider.updateForm(formId, formBindingData.createFormBindingData(data))
      .catch((err: Error) => {
        console.error('[SleepFormExtensionAbility] updateForm error:', JSON.stringify(err));
      });
  }

  onDestroyForm(formId: string): void {
    console.info('[SleepFormExtensionAbility] onDestroyForm:', formId);
  }
}
