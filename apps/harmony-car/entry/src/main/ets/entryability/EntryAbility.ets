import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { databaseService } from '../services/DatabaseService';

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want): void {
    databaseService.init(this.context).catch((err: Error) => {
      console.error('DatabaseService init failed:', err.message);
    });
  }

  onDestroy(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (error) => {
      if (error.code) {
        return;
      }
    });
  }

  onWindowStageDestroy(): void {
  }
}
