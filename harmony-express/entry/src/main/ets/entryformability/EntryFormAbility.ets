import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import type Want from '@ohos.app.ability.Want';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(_want: Want): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData({
      title: 'Harmony Express',
      status: '暂无快递',
      summary: '打开应用添加单号，查看实时轨迹'
    });
  }

  onRemoveForm(_formId: string): void {
  }

  onFormEvent(_formId: string, _message: string): void {
  }
}
