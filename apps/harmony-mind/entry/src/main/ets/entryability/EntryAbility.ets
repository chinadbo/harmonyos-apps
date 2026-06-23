import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    try {
      windowStage.loadContent('pages/HomePage', (error) => {
        if (error && error.code) {
          console.error(`loadContent failed: ${JSON.stringify(error)}`);
        }
      });
    } catch (error) {
      console.error(`onWindowStageCreate failed: ${JSON.stringify(error)}`);
    }
  }
}
