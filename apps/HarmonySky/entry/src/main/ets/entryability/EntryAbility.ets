import UIAbility from '@ohos.app.ability.UIAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { settingsPrefKeys, defaultCityName } from '../model/models';
import { initPreferences, getString, getNumber, getBoolean } from '../utils/prefs';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    initPreferences(this.context)
      .then(() => {
        AppStorage.SetOrCreate('cityName', getString(settingsPrefKeys.city, defaultCityName));
        AppStorage.SetOrCreate('latitude', getNumber(settingsPrefKeys.lat, 39.9042));
        AppStorage.SetOrCreate('longitude', getNumber(settingsPrefKeys.lon, 116.4074));
        AppStorage.SetOrCreate('themeDark', getBoolean(settingsPrefKeys.themeDark, true));
      })
      .catch(() => {
        AppStorage.SetOrCreate('cityName', defaultCityName);
        AppStorage.SetOrCreate('latitude', 39.9042);
        AppStorage.SetOrCreate('longitude', 116.4074);
        AppStorage.SetOrCreate('themeDark', true);
      });
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error(`[HarmonySky] failed to load content, code=${err.code}`);
        return;
      }
      windowStage.getMainWindow((winErr, win) => {
        if (winErr.code === 0 && win !== undefined) {
          win.setWindowSystemBarProperties({
            statusBarContentColor: '#F2F5FF',
            isStatusBarLightIcon: false
          });
        }
      });
    });
  }

  onDestroy(): void {
  }
}
