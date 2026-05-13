import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import DatabaseService from '../service/DatabaseService';
import WidgetUpdateService from '../service/WidgetUpdateService';

export default class EntryAbility extends UIAbility {
  async onCreate(): Promise<void> {
    try {
      await DatabaseService.init(this.context);
    } catch (e) {
      console.error('HarmonyCountdown', `DatabaseService init failed: ${e}`);
    }
    try {
      await WidgetUpdateService.init(this.context);
    } catch (e) {
      console.error('HarmonyCountdown', `WidgetUpdateService init failed: ${e}`);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/MainPage', (error) => {
      if (error.code !== 0) {
        return;
      }
    });
  }
}
