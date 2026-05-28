import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import DatabaseService from '../service/DatabaseService';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'HarmonySleep', '%{public}s', 'Ability onCreate');
    DatabaseService.instance().init(this.context).catch((err: Error) => {
      hilog.error(0x0000, 'HarmonySleep', 'DB init failed: %{public}s', JSON.stringify(err));
    });
  }

  onDestroy(): void {
    hilog.info(0x0000, 'HarmonySleep', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'HarmonySleep', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'HarmonySleep', 'loadContent failed: %{public}d %{public}s', err.code, err.message);
        return;
      }
      hilog.info(0x0000, 'HarmonySleep', '%{public}s', 'loadContent succeeded');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'HarmonySleep', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'HarmonySleep', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'HarmonySleep', '%{public}s', 'Ability onBackground');
  }
}
