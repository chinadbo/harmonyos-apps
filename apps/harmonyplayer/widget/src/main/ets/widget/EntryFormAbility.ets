import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData({
      title: 'HarmonyPlayer',
      artist: '未在播放',
      isPlaying: false
    });
  }
}
