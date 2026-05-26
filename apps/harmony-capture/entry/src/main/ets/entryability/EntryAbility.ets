import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { HistoryDbService } from '../service/HistoryDbService';

export default class EntryAbility extends UIAbility {
  private readonly historyDbService: HistoryDbService = HistoryDbService.getInstance();

  async onCreate(): Promise<void> {
    AppStorage.setOrCreate('navStack', new NavPathStack());
    await this.historyDbService.init(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (error) => {
      if (error) {
        console.error(`Failed to load content. code=${error.code}, message=${error.message}`);
      }
    });
  }

  onDestroy(): void {
  }
}
