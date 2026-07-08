import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err) {
        console.error('Failed to load content:', err);
      }
    });
  }

  onWindowStageDestroy(): void {
    console.info('WindowStage destroyed');
  }

  onDestroy(): void {
    console.info('Ability destroyed');
  }

  onForeground(): void {
    console.info('Ability foreground');
  }

  onBackground(): void {
    console.info('Ability background');
  }
}
