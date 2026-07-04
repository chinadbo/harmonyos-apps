import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import TorchService from '../services/TorchService';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        console.error('Failed to load content: ' + JSON.stringify(err));
        return;
      }
      console.info('Succeeded in loading content: ' + JSON.stringify(data));
    });
  }

  onBackground(): void {
    console.info('EntryAbility onBackground');
    TorchService.getInstance().turnOff();
  }

  onDestroy(): void {
    console.info('EntryAbility onDestroy');
    TorchService.getInstance().turnOff();
  }
}