import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (error?: BusinessError) => {
      if (error) {
        console.error(`Failed to load the content. Code: ${error.code}, message: ${error.message}`);
      }
    });
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}

interface BusinessError {
  code: number;
  message: string;
}
