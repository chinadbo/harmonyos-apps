import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import { ClipDatabase } from '../database/ClipDatabase';
import { ClipService } from '../service/ClipService';

const DOMAIN = 0xF001;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(DOMAIN, TAG, 'onCreate');
    // Initialize NavPathStack in AppStorage for cross-page sharing
    if (!AppStorage.has('navStack')) {
      AppStorage.setOrCreate('navStack', new NavPathStack());
    }
    // Set default retentionDays if not present
    if (!AppStorage.has('retentionDays')) {
      AppStorage.setOrCreate('retentionDays', 30);
    }
    try {
      await ClipDatabase.getInstance().init(this.context);
      const retentionDays = AppStorage.get<number>('retentionDays') as number;
      await ClipService.getInstance().cleanExpired(retentionDays);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'DB init failed: %{public}s', JSON.stringify(err));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
      }
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
}
