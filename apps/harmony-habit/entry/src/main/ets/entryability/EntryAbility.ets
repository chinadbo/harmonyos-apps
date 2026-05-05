import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want): void {
    console.info(`EntryAbility onCreate: ${JSON.stringify(want.parameters ?? {})}`);
  }

  onDestroy(): void {
    console.info('EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err && err.code) {
        console.error(`Failed to load page: ${JSON.stringify(err)}`);
        return;
      }
      console.info('Main page loaded');
    });
  }

  onWindowStageDestroy(): void {
    console.info('Window stage destroyed');
  }
}
