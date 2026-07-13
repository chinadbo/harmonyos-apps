import { AbilityConstant, UIAbility, Want } from '@ohos.app.ability';
import { window } from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('[EntryAbility] onCreate');
  }

  onDestroy(): void {
    console.info('[EntryAbility] onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.info('[EntryAbility] onWindowStageCreate');
    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        console.error('[EntryAbility] Failed to load MainPage', JSON.stringify(err));
        return;
      }
      console.info('[EntryAbility] MainPage loaded successfully');
    });
  }

  onWindowStageDestroy(): void {
    console.info('[EntryAbility] onWindowStageDestroy');
  }

  onForeground(): void {
    console.info('[EntryAbility] onForeground');
  }

  onBackground(): void {
    console.info('[EntryAbility] onBackground');
  }
}
