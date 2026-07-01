import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import hilog from '@ohos.hilog';
import { Want } from '@ohos.app.ability.Want';
import { AbilityConstant } from '@ohos.app.ability.AbilityConstant';
import { NAV_STACK_KEY } from '../constants/AppConstants';

const DOMAIN = 0xFF11;
const TAG = 'HarmonyTempo';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'onCreate');
    if (!AppStorage.has(NAV_STACK_KEY)) {
      AppStorage.setOrCreate(NAV_STACK_KEY, new NavPathStack());
    }
    if (!AppStorage.has('isDarkMode')) {
      AppStorage.setOrCreate('isDarkMode', true);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
      }
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageDestroy');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'onBackground');
  }
}
