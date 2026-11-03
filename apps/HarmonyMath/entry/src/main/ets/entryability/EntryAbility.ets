import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import { RdbHelper } from '../data/RdbHelper';
import { PreferencesUtil } from '../data/PreferencesUtil';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    const rdb: RdbHelper = RdbHelper.getInstance();
    rdb.init(this.context).catch((err: BusinessError) => {
      console.error(`[EntryAbility] rdb init failed, code=${err.code}`);
    });
    const prefs: PreferencesUtil = PreferencesUtil.getInstance();
    prefs.init(this.context).catch((err: BusinessError) => {
      console.error(`[EntryAbility] preferences init failed, code=${err.code}`);
    });
  }

  onDestroy(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err: BusinessError) => {
      if (err && err.code) {
        console.error(`[EntryAbility] loadContent failed, code=${err.code}`);
        return;
      }
      console.info('[EntryAbility] loadContent succeeded');
    });
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}
