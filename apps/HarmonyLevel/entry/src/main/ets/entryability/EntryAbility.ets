import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('[HarmonyLevel] onCreate');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error('[HarmonyLevel] loadContent failed: ' + JSON.stringify(err));
        return;
      }
      console.info('[HarmonyLevel] loadContent success');
    });
  }

  onDestroy(): void {
    console.info('[HarmonyLevel] onDestroy');
  }
}
