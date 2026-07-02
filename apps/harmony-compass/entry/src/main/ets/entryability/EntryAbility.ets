import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/IndexPage', (err) => {
      if (err.code) {
        console.error('Failed to load content:', JSON.stringify(err));
        return;
      }
      console.info('Loaded content successfully');
    });
  }

  onWindowStageDestroy(): void {
    console.info('Window stage destroyed');
  }

  onDestroy(): void {
    console.info('Ability destroyed');
  }
}