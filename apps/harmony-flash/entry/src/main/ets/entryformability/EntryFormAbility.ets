import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import Want from '@ohos.app.ability.Want';
import formBindingData from '@ohos.app.form.formBindingData';
import formInfo from '@ohos.app.form.formInfo';
import hilog from '@ohos.hilog';

const TAG = 'EntryFormAbility';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    hilog.info(0x0000, TAG, 'onAddForm');
    return this.buildFormData();
  }

  onCastToNormalForm(formId: string): void {
    hilog.info(0x0000, TAG, 'onCastToNormalForm: %{public}s', formId);
  }

  onUpdateForm(formId: string): void {
    hilog.info(0x0000, TAG, 'onUpdateForm: %{public}s', formId);
  }

  onFormEvent(formId: string, message: string): void {
    hilog.info(0x0000, TAG, 'onFormEvent: %{public}s, %{public}s', formId, message);
  }

  onRemoveForm(formId: string): void {
    hilog.info(0x0000, TAG, 'onRemoveForm: %{public}s', formId);
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }

  private buildFormData(): formBindingData.FormBindingData {
    const data: Record<string, string> = {
      word: 'achieve',
      phonetic: '/əˈtʃiːv/',
      meaning: '达到；实现',
      example: 'Hard work helps you achieve goals.'
    };
    return formBindingData.createFormBindingData(data);
  }
}
