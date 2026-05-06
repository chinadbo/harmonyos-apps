import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import Want from '@ohos.app.ability.Want';
import formBindingData from '@ohos.app.form.formBindingData';

export default class WeatherFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const data = {
      city: 'Beijing',
      temperature: '26°',
      description: 'Sunny',
      updatedAt: 'Now'
    };
    return formBindingData.createFormBindingData(data);
  }
}
