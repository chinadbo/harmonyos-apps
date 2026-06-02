import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { Constants } from '../common/Constants';
import { DatabaseHelper } from '../database/DatabaseHelper';
import { NotificationService } from '../service/NotificationService';
import { ExpiryChecker } from '../service/ExpiryChecker';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want): Promise<void> {
    AppStorage.SetOrCreate(Constants.STORAGE_THEME, 'light');
    AppStorage.SetOrCreate(Constants.STORAGE_NOTIFICATION, false);
    AppStorage.SetOrCreate(Constants.STORAGE_EXPIRED, 0);
    AppStorage.SetOrCreate(Constants.STORAGE_EXPIRING, 0);
    AppStorage.SetOrCreate(Constants.STORAGE_TOTAL, 0);

    await DatabaseHelper.getInstance().initialize(this.context);
    await NotificationService.getInstance().initialize(this.context);
    await ExpiryChecker.getInstance().initialize(this.context);
    await ExpiryChecker.getInstance().refreshAll();
  }

  onDestroy(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index');
  }

  onWindowStageDestroy(): void {
  }
}
