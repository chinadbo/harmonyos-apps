import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { StorageService } from '../service/StorageService';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    StorageService.init(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/HomePage', (err) => {
      if (err.code) {
        console.error('HarmonyChess loadContent failed: ' + JSON.stringify(err));
        return;
      }
    });
  }

  onDestroy(): void {
  }
}
