import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { DatabaseHelper } from '../database/DatabaseHelper';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    DatabaseHelper.getInstance().setContext(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        return;
      }
    });
  }

  onWindowStageDestroy(): void {
  }
}
