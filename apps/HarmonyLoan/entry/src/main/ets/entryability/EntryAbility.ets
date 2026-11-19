import UIAbility from '@ohos.app.ability.UIAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import PrefsService from '../service/PrefsService';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('HarmonyLoan EntryAbility onCreate');
  }

  onDestroy(): void {
    console.info('HarmonyLoan EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    PrefsService.init(this.context).catch((err: BusinessError) => {
      console.error(`PrefsService init failed: ${JSON.stringify(err)}`);
    });
    windowStage.loadContent('views/Index', (err: BusinessError) => {
      if (err.code) {
        console.error(`loadContent failed: ${JSON.stringify(err)}`);
      }
    });
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }

  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    return AbilityConstant.OnContinueResult.AGREE;
  }
}
