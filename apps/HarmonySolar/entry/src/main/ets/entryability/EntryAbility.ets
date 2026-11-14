import UIAbility from '@ohos.app.ability.UIAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';
import { SolarTermData } from '../engine/SolarTermData';

const DOMAIN: number = 0x0001;
const TAG: string = 'HarmonySolar';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'onCreate, reason: %{public}d', launchParam.launchReason);
    SolarTermData.init(this.context).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'load solar terms failed: %{public}s', err.message);
    });
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err: BusinessError) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'loadContent succeeded');
    });
    windowStage.getMainWindow().then((win: window.Window) => {
      win.setWindowBackgroundColor('#FBF6EC');
    }).catch((err: BusinessError) => {
      hilog.warn(DOMAIN, TAG, 'set window background failed: %{public}s', err.message);
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'onBackground');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onDestroy');
  }
}
