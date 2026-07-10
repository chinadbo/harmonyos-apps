import { AbilityConstant, UIAbility, Want } from '@ohos.app.ability.UIAbility';
import { window } from '@ohos.window';
import { relationalStore } from '@ohos.data.relationalStore';
import { DatabaseService } from '../service/DatabaseService';

export default class EntryAbility extends UIAbility {
  private dbService: DatabaseService | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.initDatabase();
  }

  onDestroy(): void {
    if (this.dbService) {
      this.dbService.close();
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error('Failed to load content:', JSON.stringify(err));
        return;
      }
      console.info('Succeeded in loading content.');
    });
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }

  private initDatabase(): void {
    this.dbService = new DatabaseService(this.context);
    this.dbService.init();
  }
}
