import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import Want from '@ohos.app.ability.Want';
import formBindingData from '@ohos.app.form.formBindingData';
import preferences from '@ohos.data.preferences';
import { Constants } from '../common/Constants';

export default class FridgeFormExtensionAbility extends FormExtensionAbility {
  onCreate(want: Want) {
    const pref: preferences.Preferences = preferences.getPreferencesSync(this.context, {
      name: Constants.PREFS_WIDGET
    });
    const formData: Record<string, number> = {
      expiringSoonCount: Number(pref.getSync(Constants.PREFS_EXPIRING_COUNT, 0)),
      expiredCount: Number(pref.getSync(Constants.PREFS_EXPIRED_COUNT, 0)),
      updatedAt: Number(pref.getSync(Constants.PREFS_UPDATED_AT, 0))
    };
    return formBindingData.createFormBindingData(formData);
  }

  onNewWant(want: Want) {
    const pref: preferences.Preferences = preferences.getPreferencesSync(this.context, {
      name: Constants.PREFS_WIDGET
    });
    const formData: Record<string, number> = {
      expiringSoonCount: Number(pref.getSync(Constants.PREFS_EXPIRING_COUNT, 0)),
      expiredCount: Number(pref.getSync(Constants.PREFS_EXPIRED_COUNT, 0)),
      updatedAt: Number(pref.getSync(Constants.PREFS_UPDATED_AT, 0))
    };
    return formBindingData.createFormBindingData(formData);
  }
}
