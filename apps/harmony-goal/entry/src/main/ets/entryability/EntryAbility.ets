import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { goalViewModel } from '../viewmodel/GoalViewModel';

export default class EntryAbility extends UIAbility {
  async onCreate(): Promise<void> {
    AppStorage.SetOrCreate('appReady', false);
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    await goalViewModel.init(this.context);
    AppStorage.SetOrCreate('appReady', true);
    await windowStage.loadContent('pages/HomePage');
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}
